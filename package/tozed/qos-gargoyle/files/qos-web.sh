#!/bin/sh

# NOTICE:
#
# *** upload and download name is reversed in gargoyle QoS ***
# *** 上传和下载的意义在 gargoyle QoS 里和一般理解是相反的 ***
#
# *** This script use gargoyle QoS upload and download name ***
# *** 这个脚本里使用 gargoyle QoS 的叫法 ***

qos_status_file=/tmp/qos_status
qos_rule_file=/tmp/qos_rule
qos_rule_new_file=/tmp/qos_rule_new
qos_total_speed_file=/tmp/qos_total_speed
num_rule=20
num_class=20
percent_bandwidth=10

log_debug () {
    logger -s -p DEBUG -t "QoS Web: " $1
}

log_error () {
    logger -s -p ERROR -t "QoS Web: " $1
}

# $1 ip address
get_postfix () {
    # replace . / with _
    local postfix=${1//./_}
    postfix=`echo $postfix | sed 's,/,_,'`

    echo $postfix
}

# $1 ip address
get_upload_class_name () {
    local postfix=$(get_postfix $1)
    local upload_class_name=uclass_$postfix

    echo $upload_class_name
}

# $1 ip address
get_upload_rule_name () {
    local postfix=$(get_postfix $1)
    local upload_rule_name=upload_rule_$postfix

    echo $upload_rule_name
}

# $1 ip address
get_download_class_name () {
    local postfix=$(get_postfix $1)
    local download_class_name=dclass_$postfix

    echo $download_class_name
}

# $1 ip address
get_download_rule_name () {
    local postfix=$(get_postfix $1)
    local download_rule_name=download_rule_$postfix

    echo $download_rule_name
}

# $1 class name $2 speed
add_upload_class () {
    uci set qos_gargoyle.$1=upload_class
    uci set qos_gargoyle.$1.name=$1
    uci set qos_gargoyle.$1.percent_bandwidth=$percent_bandwidth
    uci set qos_gargoyle.$1.min_bandwidth=0
    uci set qos_gargoyle.$1.max_bandwidth=$2
}

# $1 class name $2 speed
add_download_class () {
    uci set qos_gargoyle.$1=download_class
    uci set qos_gargoyle.$1.name=$1
    uci set qos_gargoyle.$1.percent_bandwidth=$percent_bandwidth
    uci set qos_gargoyle.$1.min_bandwidth=0
    uci set qos_gargoyle.$1.max_bandwidth=$2
}

# $1 speed(kbps)
add_default_upload_class () {
    uci set qos_gargoyle.uclass_default=upload_class
    uci set qos_gargoyle.uclass_default.name=uclass_default
    uci set qos_gargoyle.uclass_default.percent_bandwidth=80
    uci set qos_gargoyle.uclass_default.min_bandwidth=0
    uci set qos_gargoyle.uclass_default.max_bandwidth=$1
}

# $1 speed(kbps)
add_default_download_class () {
    uci set qos_gargoyle.dclass_default=download_class
    uci set qos_gargoyle.dclass_default.name=dclass_default
    uci set qos_gargoyle.dclass_default.percent_bandwidth=80
    uci set qos_gargoyle.dclass_default.min_bandwidth=0
    uci set qos_gargoyle.dclass_default.max_bandwidth=$1
}

# $1 speed(kbps)
add_default_class () {
    add_default_upload_class $1
    add_default_download_class $1
}

# $1 class name
del_class () {
    uci delete qos_gargoyle.$1
}

clean_upload_class () {
    while true; do
        local name=`uci get qos_gargoyle.@upload_class[0].name 2>/dev/null`
        if [ -z $name ]; then
            break
        fi

        del_class @upload_class[0]
    done
}

clean_download_class () {
    while true; do
        local name=`uci get qos_gargoyle.@download_class[0].name 2>/dev/null`
        if [ -z $name ]; then
            break
        fi

        del_class @download_class[0]
    done
}

clean_class () {
    clean_upload_class
    clean_download_class
}

# $1 ip address $2 speed(kbps)
add_upload_rule () {
    local upload_class_name=$(get_upload_class_name $1)
    local upload_rule_name=$(get_upload_rule_name $1)

    add_upload_class $upload_class_name $2
    uci set qos_gargoyle.${upload_rule_name}=upload_rule
    uci set qos_gargoyle.${upload_rule_name}.destination=$1
    uci set qos_gargoyle.${upload_rule_name}.class=$upload_class_name
}

# $1 ip address $2 speed(kbps)
add_download_rule () {
    local download_class_name=$(get_download_class_name $1)
    local download_rule_name=$(get_download_rule_name $1)

    add_download_class $download_class_name $2
    uci set qos_gargoyle.${download_rule_name}=download_rule
    uci set qos_gargoyle.${download_rule_name}.source=$1
    uci set qos_gargoyle.${download_rule_name}.class=$download_class_name
}

# $1 ip address $2 upload speed(kbps) $3 download speed(kbps)
add_rule () {
    add_upload_rule $1 $3
    add_download_rule $1 $2
}

# $1 ip address
del_upload_rule () {
    local upload_rule_name=$(get_upload_rule_name $1)
    local upload_class_name=$(get_upload_class_name $1)

    uci delete qos_gargoyle.${upload_rule_name}
    # must delete related class
    del_class $upload_class_name
}

# $1 ip address
del_download_rule () {
    local download_rule_name=$(get_download_rule_name $1)
    local download_class_name=$(get_download_class_name $1)

    uci delete qos_gargoyle.${download_rule_name}
    # must delete related class
    del_class $download_class_name
}

# $1 ip address
del_rule () {
    del_upload_rule $1
    del_download_rule $1
}

clean_upload_rule () {
    while true; do
        local class=`uci get qos_gargoyle.@upload_rule[0].class 2>/dev/null`
        if [ -z $class ]; then
            break
        fi

        del_class $class
        uci delete qos_gargoyle.@upload_rule[0]
    done
}

clean_download_rule () {
    while true; do
        local class=`uci get qos_gargoyle.@download_rule[0].class 2>/dev/null`
        if [ -z $class ]; then
            break
        fi

        del_class $class
        uci delete qos_gargoyle.@download_rule[0]
    done
}

clean_rule () {
    clean_upload_rule
    clean_download_rule
}

# add_default_upload_rule () {
#     uci set qos_gargoyle.upload_rule_default=upload_rule
#     uci set qos_gargoyle.upload_rule_default.class=uclass_default
# }

# add_default_download_rule () {
#     uci set qos_gargoyle.download_rule_default=download_rule
#     uci set qos_gargoyle.download_rule_default.class=dclass_default
# }

reload () {
    uci commit qos_gargoyle
    /etc/init.d/qos_gargoyle reload
}

# $1 speed(kbps)
set_upload_speed () {
    uci set qos_gargoyle.upload.total_bandwidth=$1
    uci set qos_gargoyle.uclass_default.max_bandwidth=$1
}

# $1 speed(kbps)
set_download_speed () {
    uci set qos_gargoyle.download.total_bandwidth=$1
    uci set qos_gargoyle.dclass_default.max_bandwidth=$1
}

web_show_rule () {
    rm -f $qos_rule_file

    local i=0
    while true; do
        local upload_ip=`uci get qos_gargoyle.@upload_rule[$i].destination 2>/dev/null`
        if [ -z $upload_ip ]; then
            break
        fi

        local upload_class_name=$(get_upload_class_name $upload_ip)
        local upload_speed=`uci get qos_gargoyle.${upload_class_name}.max_bandwidth 2>/dev/null`
        if [ -z "$upload_speed" ]; then
            continue
        fi

        local download_ip=`uci get qos_gargoyle.@download_rule[$i].source 2>/dev/null`
        if [ -z "$download_ip" ] || [ "$upload_ip" != "$download_ip" ]; then
            continue
        fi

        local download_class_name=$(get_download_class_name $download_ip)
        local download_speed=`uci get qos_gargoyle.${download_class_name}.max_bandwidth 2>/dev/null`
        if [ -z "$download_speed" ]; then
            continue
        fi
        echo $upload_ip $download_speed $upload_speed >> $qos_rule_file

        i=$((i+1))
    done
}

web_qos_status () {
    local enabled

    [ -f /etc/rc.d/S50qos_gargoyle ] && enabled=1 || enabled=0

    echo -n $enabled > $qos_status_file
}

web_enable () {
    /etc/init.d/qos_gargoyle enable
    /etc/init.d/qos_gargoyle reload
}

web_disable () {
    /etc/init.d/qos_gargoyle disable
    /etc/init.d/qos_gargoyle reload
    /etc/init.d/network restart
}

web_change_rule () {
    clean_rule

    while read -r line; do
        local ip=${line%% *}
        local two_speed=${line#* }
        local upload_speed=${two_speed%% *}
        upload_speed=${upload_speed// /}
        local download_speed=${two_speed##* }

        if [ -z "$ip" ] || [ -z "$upload_speed" ] || [ -z "$download_speed" ]; then
            log_error "invalid rule: $line"
            uci revert qos_gargoyle
            return
        fi

        add_rule $ip $upload_speed $download_speed
    done < $qos_rule_new_file

    reload
}

web_get_total_speed () {
    local upload_speed=`uci get qos_gargoyle.upload.total_bandwidth`
    local download_speed=`uci get qos_gargoyle.download.total_bandwidth`

    echo $download_speed $upload_speed > $qos_total_speed_file
}

# $1 upload speed(kbps) $2 download speed(kbps)
web_set_total_speed () {
    set_upload_speed $2
    set_download_speed $1

    reload
}

case $1 in
    web_qos_status)
        web_qos_status
        ;;
    web_enable)
        web_enable
        ;;
    web_disable)
        web_disable
        ;;
    web_get_total_speed)
        web_get_total_speed
        ;;
    web_set_total_speed)
        shift
        web_set_total_speed $@
        ;;
    web_show_rule)
        web_show_rule
        ;;
    web_change_rule)
        web_change_rule
        ;;
    *)
        log_error "unknown command: $@"
        ;;
esac
