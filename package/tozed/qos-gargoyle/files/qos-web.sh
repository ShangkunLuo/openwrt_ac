#!/bin/sh

qos_rule_file=/tmp/qos_rule_file
num_rule=20
num_class=20
percent_bandwidth=10

show_rule () {
    rm -f $qos_rule_file

    for i in `seq 1 $num_rule`; do
        local ip=`uci get qos_gargoyle.@upload_rule[$i].source 2>/dev/null`
        [ ! -n $ip ] && break
        local class=`uci get qos_gargoyle.@upload_rule[$i].class 2>/dev/null`
        local speed=`uci get qos_gargoyle.${class}.max_bandwidth 2>/dev/null`
        [ -n $ip ] && [ -n $speed ] && echo $ip $speed >> $qos_rule_file
    done
}

# $1 class name $2 speed
add_class () {
    uci set qos_gargoyle.$1=upload_class
    uci set qos_gargoyle.$1.percent_bandwidth=$percent_bandwidth
    uci set qos_gargoyle.$1.max_bandwidth=speed
}

# $1 class name
del_class () {
    uci delete qos_gargoyle.$1
}

clean_class () {
    for i in `seq 1 $num_class`; do
        local name=`uci get qos_gargoyle.@upload_class[$i].name 2>/dev/null`
        [ ! -n $name ] && break
        del_class $class
    end
}

add_default_rule () {
    uci add qos_gargoyle.upload_rule_default=upload_rule
    uci set qos_gargoyle.upload_rule_default.class=uclass_default
}

# $1 ip address $2 speed(kbps)
add_rule () {
    add_class uclass_${1//./_} $2
    uci add qos_gargoyle.upload_rule_${ip//./_}=upload_rule
    uci set qos_gargoyle.upload_rule_${ip//./_}.source=$1
    uci set qos_gargoyle.upload_rule_${ip//./_}.class=uclass_${1//./_}
}

# $1 ip address
del_rule () {
    uci delete qos_gargoyle.upload_rule_${ip//./_}
    # must delete related class
    del_class uclass_${1//./_}
}

clean_rule () {
    for i in `seq 1 $num_rule`; do
        local class=`uci get qos_gargoyle.@upload_rule[$i].class 2>/dev/null`
        [ ! -n $class ] && break
        del_class $class
        uci delete qos_gargoyle.@upload_rule[$i]
    end
}

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

enable () {
    /etc/init.d/qos_gargoyle enable
}

disable () {
    /etc/init.d/qos_gargoyle disable
}
