#!/bin/sh

sleep_interval=15
check_dhcp_interval=30
check_arp_interval=285
reset_tc_interval=3585

class_num=100
check_dhcp_leases_time=0
start_time=`date +%s`

arp_ip_list_file=/tmp/arp_ip_list
dhcp_leases_file=/tmp/dhcp.leases
qos_lock_file=/var/run/qos_updating
qos_start_time_file=/tmp/qos_start_time

log_debug () {
    # logger -s -p DEBUG -t "QoS daemon: " $1
    return
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
    (cat /proc/net/arp | grep br-* | awk '{print $1" "$3" "$4}' | grep -v 0x0 | awk '{print $1" "$3}') > $1
}

is_qos_enabled () {
    [ -f /etc/rc.d/S50qos_gargoyle ] && echo true || echo false
}

# $1 ip address
is_ip_in_rule () {
    local ip_hex=`printf '%02x' ${1//./ }`
    local output=`tc filter show dev br-lan | grep $ip_hex -B 1 | head -n1`

    echo $output
}

# $1 ip address, $2 upload speed(write back), $3 download speed(write back)
get_rate_limit () {
    local i=0
    while true; do
        local start=`uci get qos_gargoyle.@tozed_rule[$i].start 2>/dev/null`
        if [ -z "$start" ]; then
            break
        fi

        local end=`uci get qos_gargoyle.@tozed_rule[$i].end 2>/dev/null`
        if [ -z "$end" ]; then
            break
        fi

        local res=$(is_ip_in_range $start $end $1)
        if [ "$res" != "true" ]; then
            i=$((i + 1))
            continue
        fi

        eval $2=`uci get qos_gargoyle.@tozed_rule[$i].upload 2>/dev/null`
        eval $3=`uci get qos_gargoyle.@tozed_rule[$i].download 2>/dev/null`
        break
    done
}

# $1 ip address, $2 class(write back), $3 upload speed, $4 download speed
check_rule () {
    local output=$(is_ip_in_rule $1)
    if [ -z "$output" ]; then
        echo 1
        return
    fi

    local class=${output##*:}
    eval $2=$class

    # check speed
    output=`tc class show dev imq0 | grep "1\:$class"`
    local upload_speed=${output%% }
    local upload_speed=${upload_speed##* }
    upload_speed=${upload_speed%Kbit}
    if [ "$upload_speed" != "$3" ]; then
        echo 2
        return
    fi

    output=`tc class show dev br-lan | grep "1\:$class"`
    local download_speed=${output%% }
    local download_speed=${download_speed##* }
    download_speed=${download_speed%Kbit}
    if [ "$download_speed" != "$4" ]; then
        echo 2
        return
    fi

    echo 0
    return
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

    # reset to initial value
    class_num=100
    check_dhcp_leases_time=0
}

# $1 ip address, $2 class, $3 upload speed, $4 download speed
_add_rule () {
    tc class add dev imq0 parent 1:1 classid 1:${2} hfsc ls m2 100Mbit ul m2 ${3}kbit
    tc qdisc add dev imq0 parent 1:${2} handle ${2}:1 sfq headdrop limit 5 divisor 256
    tc filter add dev imq0 parent 1: protocol ip prio ${2} u32 match ip src ${1}/32 flowid 1:${2}
    tc filter add dev imq0 parent ${2}: handle 1 flow divisor 256 map key dst and 0xff

    tc class add dev br-lan parent 1:1 classid 1:${2} hfsc ls m2 100Mbit ul m2 ${4}kbit
    tc qdisc add dev br-lan parent 1:${2} handle ${2}:1 sfq headdrop limit 6 divisor 256
    tc filter add dev br-lan parent 1: protocol ip prio ${2} u32 match ip dst ${1}/32 flowid 1:${2}
    tc filter add dev br-lan parent ${2}: handle 1 flow divisor 256 map key nfct-src and 0xff

    class_num=$(($2 + 1))

    log_debug "_add_rule: ip: $1, class: $2, upload speed: $3, download speed: $4, class_num: $class_num"
}

# $1 ip address
add_rule () {
    local upload_speed=0 download_speed=0
    get_rate_limit $1 upload_speed download_speed

    if [ "$upload_speed" == "0" ] || [ "$download_speed" == "0" ]; then
        echo 1
        return
    fi

    _add_rule $1 $class_num $upload_speed $download_speed
    echo 0
}

# $1 ip address
process_ip_address () {
    local output=$(is_ip_in_rule $1)
    if [ -z "$output" ]; then
        add_rule $1
    fi
}

get_leasetime () {
    local value=`uci get dhcp.lan.leasetime 2>/dev/null`
    local leasetime=${value/m/}
    if [ "$leasetime" != "$value" ]; then
        echo $((leasetime * 60))
        return
    fi

    leasetime=${value/h/}
    if [ "$leasetime" != "$value" ]; then
        echo $((leasetime * 3600))
        return
    fi

    leasetime=${value/d/}
    if [ "$leasetime" != "$value" ]; then
        echo $((leasetime * 3600 * 24))
        return
    fi

    echo 0
    log_error "unrecognized leasetime: $value"
}

check_dhcp_lease () {
    local leasetime=$(get_leasetime)
    local before=$((check_dhcp_leases_time + leasetime))
    local ip_set=`awk '$1 > '"$before"' {print $3}' $dhcp_leases_file`
    for ip in $ip_set; do
        process_ip_address $ip
    done

    check_dhcp_leases_time=`date +%s`
}

check_arp_table () {
    local line

    update_arp_ip_list $arp_ip_list_file

    while read -r line; do
        local ip=${line%% *}

        process_ip_address $ip
    done < $arp_ip_list_file
}

local num=0
while true; do
    sleep $sleep_interval
    num=$((num + 1))

    log_debug "check, check..."

    if [ -f "$qos_lock_file" ]; then
        continue
    fi

    local enabled=$(is_qos_enabled)
    if [ "$enabled" == "false" ]; then
        log_debug "QoS disabled"
        num=0
        continue
    fi

    if [ $qos_start_time -gt $start_time ]; then
        log_debug "qos_gargoyle restarted"
        start_time=qos_start_time
        reset_tc
    fi

    let should_check_dhcp="num % (check_dhcp_interval / sleep_interval)"
    if [ $should_check_dhcp == 0 ]; then
        check_dhcp_lease
    fi

    let should_check_arp="num % (check_arp_interval / sleep_interval)"
    local qos_start_time=`cat $qos_start_time_file 2>/dev/null`
    [ -z $qos_start_time ] && qos_start_time=0

    if [ $should_check_arp == 0 ]; then
        check_arp_table
    fi

    let should_reset_tc="num % (reset_tc_interval / sleep_interval)"
    if [ $should_reset_tc == 0 ]; then
        reset_tc
        check_arp_table
        num=0
    fi
done
