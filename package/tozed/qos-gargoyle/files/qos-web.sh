#!/bin/sh

# NOTICE:
#
# *** upload and download name is reversed in gargoyle QoS ***
# *** 上传和下载的意义在 gargoyle QoS 里和一般理解是相反的 ***
#
# *** This script use gargoyle QoS upload and download name ***
# *** 这个脚本里使用 gargoyle QoS 的叫法 ***

qos_rule_file=/tmp/qos_rule_file
qos_rule_file_new=/tmp/qos_rule_file_new
num_rule=20
num_class=20
percent_bandwidth=10

log_debug () {
    logger -s -p DEBUG -t "QoS Web: " $1
}

log_error () {
    logger -s -p ERROR -t "QoS Web: " $1
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
    for i in `seq 0 $num_class`; do
        local name=`uci get qos_gargoyle.@upload_class[$i].name 2>/dev/null`
        if [ -z $name ]; then
            log_debug "clean_upload_class: stop at qos_gargoyle.@upload_class[$i]"
            break
        fi

        del_class @upload_class[$i]
    done
}

clean_download_class () {
    for i in `seq 0 $num_class`; do
        local name=`uci get qos_gargoyle.@download_class[$i].name 2>/dev/null`
        if [ -z $name ]; then
            log_debug "clean_download_class: stop at qos_gargoyle.@download_class[$i]"
            break
        fi

        del_class @download_class[$i]
    done
}

clean_class () {
    clean_upload_class
    clean_download_class
}

# $1 ip address $2 speed(kbps)
add_upload_rule () {
    add_upload_class uclass_${1//./_} $2
    uci set qos_gargoyle.upload_rule_${1//./_}=upload_rule
    uci set qos_gargoyle.upload_rule_${1//./_}.source=$1
    uci set qos_gargoyle.upload_rule_${1//./_}.class=uclass_${1//./_}
}

# $1 ip address $2 speed(kbps)
add_download_rule () {
    add_download_class dclass_${1//./_} $2
    uci set qos_gargoyle.download_rule_${1//./_}=download_rule
    uci set qos_gargoyle.download_rule_${1//./_}.source=$1
    uci set qos_gargoyle.download_rule_${1//./_}.class=dclass_${1//./_}
}

# $1 ip address $2 upload speed(kbps) $3 download speed(kbps)
add_rule () {
    add_upload_rule $1 $2
    add_download_rule $1 $3
}

# $1 ip address
del_upload_rule () {
    uci delete qos_gargoyle.upload_rule_${1//./_}
    # must delete related class
    del_class uclass_${1//./_}
}

# $1 ip address
del_download_rule () {
    uci delete qos_gargoyle.download_rule_${1//./_}
    # must delete related class
    del_class dclass_${1//./_}
}

# $1 ip address
del_rule () {
    del_upload_rule $1
    del_download_rule $1
}

clean_upload_rule () {
    for i in `seq 0 $num_rule`; do
        local class=`uci get qos_gargoyle.@upload_rule[$i].class 2>/dev/null`
        if [ -z $class ]; then
            log_debug "clean_upload_rule: stop at qos_gargoyle.@upload_class[$i]"
            break
        fi

        del_class $class
        uci delete qos_gargoyle.@upload_rule[$i]
    done
}

clean_download_rule () {
    for i in `seq 0 $num_rule`; do
        local class=`uci get qos_gargoyle.@download_rule[$i].class 2>/dev/null`
        if [ -z $class ]; then
            log_debug "clean_download_rule: stop at qos_gargoyle.@upload_class[$i]"
            break
        fi

        del_class $class
        uci delete qos_gargoyle.@download_rule[$i]
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

    for i in `seq 0 $num_rule`; do
        local upload_ip=`uci get qos_gargoyle.@upload_rule[$i].source 2>/dev/null`
        if [ -z $upload_ip ]; then
            log_debug "web_show_rule: stop at qos_gargoyle.@upload_class[$i]"
            break
        fi

        local upload_class=`uci get qos_gargoyle.@upload_rule[$i].class 2>/dev/null`
        local upload_speed=`uci get qos_gargoyle.${class}.max_bandwidth 2>/dev/null`
        if [ -z "$upload_speed" ]; then
            log_error "qos_gargoyle.@upload_rule[$i]: error: upload_speed is null"
            continue
        fi

        local download_ip=`uci get qos_gargoyle.@download_rule[$i].source 2>/dev/null`
        if [ -z "$download_ip" ] || [ "$upload_ip" != "$download_ip" ]; then
            log_error "qos_gargoyle.@download_rule[$i]: download_ip: $download_ip download_ip and upload_ip not match"
            continue
        fi

        local download_class=`uci get qos_gargoyle.@download_rule[$i].class 2>/dev/null`
        local download_speed=`uci get qos_gargoyle.${class}.max_bandwidth 2>/dev/null`
        if [ -z "$download_speed" ]; then
            log_error "qos_gargoyle.@download_rule[$i]: error: download_speed is null"
            continue
        fi
        echo $ip $upload_speed $download_speed >> $qos_rule_file
    done
}

web_enable () {
    /etc/init.d/qos_gargoyle enable
}

web_disable () {
    /etc/init.d/qos_gargoyle disable
}

web_change_rule () {
    clean_rule

    while read -r line; do
        ip=${a%% *}
        speed=${a##* }
        [ -z "$ip" ] || [ -z "$speed" ] && continue

        add_rule $ip $upload_speed $download_speed
    done < $qos_rule_file_new

    add_default_rule
}
