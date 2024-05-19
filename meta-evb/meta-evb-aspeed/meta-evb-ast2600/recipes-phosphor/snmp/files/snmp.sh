#!/bin/bash

# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.50 power on
# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.51 power off
# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.51 fan 30
# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.51 fan 60
# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.51 fan 90
# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.55  sensor dps1600
# snmpwalk -v 1 -c public localhost .1.3.6.1.4.1.2021.56  sensor lm75
# snmpwalk -v 2c -c public localhost  .1.3.6.1.4.1.2021.10.1.3.3  #15分钟cpu的负载
# snmpwalk -v 2c -c public localhost .1.3.6.1.4.1.2021.10.1.3   #监控cpuload
# snmpwalk -v 2c -c public localhost .1.3.6.1.2.1.25.2.2  #获取内存总数

if [[ "$1" == "start" ]] && [[ "$2" == "" ]]; then
    knull=$(sed -n '222p' /etc/snmp/snmpd.conf)
    if [ "$knull" == "" ];then
	sed -i '84c view system included  .1'  /etc/snmp/snmpd.conf
	sed -i '222c extend .1.3.6.1.4.1.2021.50 host_power_on /usr/bin/snmp.sh power on' /etc/snmp/snmpd.conf
	sed -i '222a extend .1.3.6.1.4.1.2021.51 host_power_off /usr/bin/snmp.sh power off' /etc/snmp/snmpd.conf
	sed -i '223a extend .1.3.6.1.4.1.2021.52 fan_control /usr/bin/snmp.sh fan 30 ' /etc/snmp/snmpd.conf
	sed -i '224a extend .1.3.6.1.4.1.2021.53 fan_control /usr/bin/snmp.sh fan 60 ' /etc/snmp/snmpd.conf
	sed -i '225a extend .1.3.6.1.4.1.2021.54 fan_control /usr/bin/snmp.sh fan 90 ' /etc/snmp/snmpd.conf
	sed -i '226a extend .1.3.6.1.4.1.2021.55 sensor_get /usr/bin/snmp.sh sensor dps1600 ' /etc/snmp/snmpd.conf
	sed -i '227a extend .1.3.6.1.4.1.2021.56 sensro_get /usr/bin/snmp.sh sensor lm75 ' /etc/snmp/snmpd.conf
	systemctl restart snmpd.service
	systemctl stop snmptrapd.service
    fi
fi


function power_on()
{
    /usr/bin/poweron.sh
    if [ $? -eq 0 ]; then
	busctl set-property xyz.openbmc_project.State.Chassis0  /xyz/openbmc_project/state/chassis0  xyz.openbmc_project.State.Chassis CurrentPowerState s xyz.openbmc_project.State.Chassis.PowerState.On
    else
      echo "host power on failed"
     fi 
}
function power_off()
{
    /usr/bin/poweroff.sh
    if [ $? -eq 0 ]; then
	busctl set-property xyz.openbmc_project.State.Chassis0  /xyz/openbmc_project/state/chassis0  xyz.openbmc_project.State.Chassis CurrentPowerState s xyz.openbmc_project.State.Chassis.PowerState.Off
    else
      echo "host power off failed"
     fi 
}

function fan_ctrl()
{
    if [ "$1" == 30 ]; then
        ls /sys/class/hwmon/hwmon0/pwm* | head -n 4 | xargs -n 1 -I {} sh -c 'echo 30 > {}'
        if [ $? -eq 0 ]; then
                echo "fan send $1 ok"
        else
                echo "fan send $1 failed "
        fi
    fi

    if [ "$1" == 60 ]; then
        ls /sys/class/hwmon/hwmon0/pwm* | head -n 4 | xargs -n 1 -I {} sh -c 'echo 60 > {}'
        if [ $? -eq 0 ]; then
                echo "fan send $1 ok"
        else
                echo "fan send $1 failed "
        fi
    fi

    if [ "$1" == 90 ]; then
        ls /sys/class/hwmon/hwmon0/pwm* | head -n 4 | xargs -n 1 -I {} sh -c 'echo 90 > {}'
        if [ $? -eq 0 ]; then
                echo "fan send $1 ok"
        else
                echo "fan send $1 failed "
        fi
    fi
}

get_snmp_ip()
{
    ret=$(busctl get-property xyz.openbmc_project.Network.SNMP /xyz/openbmc_project/network/snmp/manager/1 xyz.openbmc_project.Network.Client Address)
    if [[ $? == 0 ]];then
      echo " GET IP " $ret
    else
      echo "Please input HostIP"
      exit
    fi
    for i in `seq ${#ret}`
    do
	ret1=${ret:$i-1:1}
	if [ "$ret1" == "\"" ];
	then
	    left=$i
	fi
    done
    ret_ip=${ret:3:$left-4}
}  

function sensor_get()
{
    get_snmp_ip
    dev=`ls /sys/class/hwmon/hwmon*/name`
    for i in $dev; do
        d=`cat $i`
    if [[ $d == $1 ]];then
        sen=${i%/*};

	if [[ "$1" == "dps1600" ]];then
	    sensor_in=$sen"/in1_input"
	    ret_in=`cat $sensor_in`
	    ret_in=`expr $ret_in / 1000`
	    value_in=$1"  "$2"  value="$ret_in
	    echo $value_in
	    snmptrap -v2c -c public $ret_ip:162 "sensor " .1.3.6.1.4.1.2021.251.1 0 s "$value_in"

	    sleep 1

	    sensor_po=$sen"/power1_input"
	    ret_po=`cat $sensor_po`
	    ret_po=`expr $ret_po / 1000000`
	    value_po=$1"  "$3"  value="$ret_po
	    echo $value_po
	    snmptrap -v2c -c public $ret_ip:162 "sensor " .1.3.6.1.4.1.2021.251.1 0 s "$value_po"

	    sleep 1

	    sensor_tm=$sen"/temp1_input"
	    ret_tm=`cat $sensor_tm`
	    ret_tm=`expr $ret_tm / 1000`
	    value_tm=$1"  "$4"  value="$ret_tm
	    echo $value_tm
	    snmptrap -v2c -c public $ret_ip:162 "sensor " .1.3.6.1.4.1.2021.251.1 0 s "$value_tm"
	fi

	if [[ "$1" == "lm75" ]];then
	    sensor_tm=$sen"/temp1_input"
	    ret_tm=`cat $sensor_tm`
	    ret_tm=`expr $ret_tm / 1000`
	    value_tm=$1"  "$2"  value="$ret_tm
	    echo $value_tm
	    snmptrap -v2c -c public $ret_ip:162 "sensor " .1.3.6.1.4.1.2021.251.1 0 s "$value_tm"
	fi
    fi
    done
}

while [ -n "$1" ]; do
        case "$1" in
                power) echo "ready for power" ;;
                fan) echo "ready for fan" ;;
                sensor) echo "ready for sensor" ;;
        esac
        if [ -n "$2" ]; then
                case "$2" in
                        on)  power_on ;;
                        off) power_off ;;
			30) fan_ctrl 30 ;;
			60) fan_ctrl 60 ;;
			90) fan_ctrl 90 ;;
			dps1600) sensor_get "dps1600" "power-in" "total-power" "power-temp";;
			lm75) sensor_get "lm75" "cpu-temp";;
                esac
        fi
        shift
done
