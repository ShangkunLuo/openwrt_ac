#!/bin/sh

sleep_interval=15
check_interval=60
reset_internal=120

arp_ip_list_file=/tmp/arp_ip_list

log_debug () {
    logger -s -p DEBUG -t "QoS daemon: " $1
}

log_error () {
    logger -s -p ERROR -t "QoS daemon: " $1
}

is_ip_in_range () {
    # $1 start ip, $2 endip, $3 test ip
    s=`echo $1 | awk -F\. '{printf("%03d%03d%03d%03d\n", $1,$2,$3,$4)}'`
    e=`echo $2 | awk -F\. '{printf("%03d%03d%03d%03d\n", $1,$2,$3,$4)}'`
    t=`echo $3 | awk -F\. '{printf("%03d%03d%03d%03d\n", $1,$2,$3,$4)}'`
    if [[ $t -ge $s && $t -le $e ]]; then
	echo true
    else
	echo false
    fi
}

update_arp_ip_list() {
    # $1 arp list file
    # get lan arps whose flag!=0x0 (flag==0x0 means invalid arp)
    cat /proc/net/arp | grep br-* | awk '{print $1" "$3" "$4}' | grep -v 0x0 | awk '{print $1" "$3}' > $1
}

is_qos_enabled () {
    [ -f /etc/rc.d/S50qos_gargoyle ] && echo true || echo false
}

# $1 ip address, $2 class, $3 upload speed, $4 download speed
del_rule () {
    log_debug "del_rule: ip: $1, class: $2, upload speed: $3, download speed: $4"

    tc filter del dev imq0 parent 1: protocol ip prio ${2} u32 match ip src ${1}/32 flowid 1:${2} 2>/dev/null
    tc qdisc del dev imq0 parent 1:${2} handle ${2}:1 sfq headdrop limit 5 divisor 256 2>/dev/null
    tc class del dev imq0 parent 1:1 classid 1:${2} hfsc ls m2 100Mbit ul m2 ${3}kbit 2>/dev/null

    tc filter del dev br-lan parent 1: protocol ip prio ${2} u32 match ip dst ${1}/32 flowid 1:${2} 2>/dev/null
    tc qdisc del dev br-lan parent 1:${2} handle ${2}:1 sfq headdrop limit 6 divisor 256 2>/dev/null
    tc class del dev br-lan parent 1:1 classid 1:${2} hfsc ls m2 100Mbit ul m2 ${4}kbit 2>/dev/null
}

reset_tc () {
    log_debug "reset tc settings"

    tc qdisc del dev br-lan root
    tc qdisc del dev imq0 root

    local download_bandwidth=`uci get qos_gargoyle.upload.total_bandwidth 2>/dev/null`
    local default_download_class_percent=`uci get qos_gargoyle.dclass_default.percent_bandwidth 2>/dev/null`
    let download_ls_m2_rate="10 * ${default_download_class_percent}"
    local default_download_class_speed=`uci get qos_gargoyle.dclass_default.max_bandwidth 2>/dev/null`
    tc qdisc add dev br-lan root handle 1:0 hfsc default 1
    tc class add dev br-lan parent 1:0 classid 1:1 hfsc ls rate 1000Mbit ul rate ${download_bandwidth}kbit
    tc class add dev br-lan parent 1:1 classid 1:2 hfsc ls m2 ${download_ls_m2_rate}Mbit ul m2 ${default_download_class_speed}kbit
    tc qdisc add dev br-lan parent 1:2 handle 2:1 sfq headdrop limit 300 divisor 256
    tc filter add dev br-lan parent 1:0 protocol ip handle 0x2 fw flowid 1:2
    tc filter add dev br-lan parent 2: handle 1 flow divisor 256 map key nfct-src and 0xff
    tc qdisc change dev br-lan root handle 1:0 hfsc default 2

    local upload_bandwidth=`uci get qos_gargoyle.upload.total_bandwidth 2>/dev/null`
    local default_upload_class_percent=`uci get qos_gargoyle.uclass_default.percent_bandwidth 2>/dev/null`
    let upload_ls_m2_rate="10 * ${default_upload_class_percent}"
    local default_upload_class_speed=`uci get qos_gargoyle.uclass_default.max_bandwidth 2>/dev/null`
    tc qdisc add dev imq0 root handle 1:0 hfsc default 1
    tc class add dev imq0 parent 1:0 classid 1:1 hfsc ls rate 1000Mbit ul rate ${upload_bandwidth}kbit
    tc class add dev imq0 parent 1:1 classid 1:2 hfsc ls m2 ${upload_ls_m2_rate}Mbit ul m2 ${default_upload_class_speed}kbit
    tc qdisc add dev imq0 parent 1:2 handle 2:1 sfq headdrop limit 75 divisor 256
    tc filter add dev imq0 parent 1:0 prio 9999 protocol ip handle 0x200 fw flowid 1:2
    tc filter add dev imq0 parent 2: handle 1 flow divisor 256 map key dst and 0xff
    tc qdisc change dev imq0 root handle 1:0 hfsc default 2
}

# $1 ip address, $2 class, $3 upload speed, $4 download speed
add_rule () {
    log_debug "add_rule: ip: $1, class: $2, upload speed: $3, download speed: $4"

    tc class add dev imq0 parent 1:1 classid 1:${2} hfsc ls m2 100Mbit ul m2 ${3}kbit
    tc qdisc add dev imq0 parent 1:${2} handle ${2}:1 sfq headdrop limit 5 divisor 256
    tc filter add dev imq0 parent 1: protocol ip prio ${2} u32 match ip src ${1}/32 flowid 1:${2}
    tc filter add dev imq0 parent ${2}: handle 1 flow divisor 256 map key dst and 0xff

    tc class add dev br-lan parent 1:1 classid 1:${2} hfsc ls m2 100Mbit ul m2 ${4}kbit
    tc qdisc add dev br-lan parent 1:${2} handle ${2}:1 sfq headdrop limit 6 divisor 256
    tc filter add dev br-lan parent 1: protocol ip prio ${2} u32 match ip dst ${1}/32 flowid 1:${2}
    tc filter add dev br-lan parent ${2}: handle 1 flow divisor 256 map key nfct-src and 0xff
}

local num=0
while true; do
    sleep $sleep_interval
    num=$((num + 1))

    log_debug "check, check..."

    let should_check="num % (check_interval / sleep_interval)"

    local enabled=$(is_qos_enabled)
    if [ "$enabled" == "false" ]; then
        log_debug "QoS disabled"
        num=0
        continue
    fi

    if [ $should_check != 0 ]; then
        continue
    fi

    update_arp_ip_list $arp_ip_list_file

    local i=0 tc_reseted=0 line
    while read line; do
        local ip=${line%% *}

        local j=0
        while true; do
            local start=`uci get qos_gargoyle.@tozed_rule[$j].start 2>/dev/null`
            if [ ! -n "$start" ]; then
                break
            fi

            local end=`uci get qos_gargoyle.@tozed_rule[$j].end 2>/dev/null`
            local in_range=$(is_ip_in_range "$start" "$end" "$ip")
            if [ "$in_range" != "true" ]; then
                break
            fi

            if [ "$tc_reseted" -eq "0" ]; then
                reset_tc
                tc_reseted=1
            fi

            local download_speed=`uci get qos_gargoyle.@tozed_rule[$j].download 2>/dev/null`
            local upload_speed=`uci get qos_gargoyle.@tozed_rule[$j].upload 2>/dev/null`
            class=$((100 + j*800 + i))
            add_rule $ip $class $upload_speed $download_speed
            j=$((j+1))
        done

        i=$((i+1))
    done < $arp_ip_list_file

    let should_reset="num % (reset_internal / sleep_interval)"
    if [ $should_reset == 0 ]; then
        num=0

        if [ $tc_reseted == 0 ]; then
            reset_tc
        fi
    fi
done
