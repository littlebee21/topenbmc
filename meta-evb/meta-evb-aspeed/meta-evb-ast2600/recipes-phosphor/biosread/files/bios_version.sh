#!/bin/sh

gpiol2=/sys/class/gpio/gpio906
gpiox1=/sys/class/gpio/gpio1001

function gpioinit()
{
#set L2 direction
if [ ! -e $gpiol2 ];then
    echo  906 >   /sys/class/gpio/export
    if [ $? -ne 0 ]; then
     echo "gpio 906 set failed."
     exit 1
    fi
    echo out  >  $gpiol2/direction
    echo "set gpio 376 direction successed"
fi
#set x1 direction
if [ ! -e $gpiox1 ];then
    echo  1001 >   /sys/class/gpio/export
    if [ $? -ne 0 ]; then
     echo "gpio 1001 set failed."
     exit 1
    fi
    echo out  >  $gpiox1/direction
    echo "set gpio 1001 direction successed"
fi
}

function spi_bind()
{
    SPI_FILE="/sys/bus/spi/devices/spi2.0"
    SPI_BIND="/sys/bus/spi/drivers/spi-nor/spi2.0"
    if [ -e $SPI_FILE ];then
	if [ ! -e $SPI_BIND ];then
	    echo "bind spi2.0"
	    if echo spi2.0 > /sys/bus/spi/drivers/spi-nor/bind; then
		echo "BInd SPI2.0 SUCCEFF"
	    else
		echo "Bind SPI2.0 failed"
		exit
	    fi
	else
	    if echo spi2.0 > /sys/bus/spi/drivers/spi-nor/unbind;then
		echo "SPI2.0 UNBIND SUCCEFF"
	    else
		echo "SPI2.0 UNBIND FAILED"
		exit
	    fi
	fi
    else
	echo "SPI FILE NOT HAVE"
	exit
    fi
}

function power_on()
{
    echo "START POWER ON"
    ipmitool power on
}
function power_off()
{
    echo "START POWER OFF"
    ipmitool power off
}
function power_status()
{
    POWER_STATUS=$(busctl get-property  xyz.openbmc_project.State.Chassis0  /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition)
    POWER_STATUS=${POWER_STATUS:0-4:3}   #使用busctl命令获取状态，并且截取字符串比较
    if [ "$POWER_STATUS" == "Off" ];
    then
	echo "the power is off"
	power_on
	sleep 2
    else
	echo "the power is on"
    fi
}



if [ $1 -eq 1 ];then
    echo "Bios version get at $(date)"
    gpioinit
    usleep 5
    power_status #power on
    echo 1 > $gpiol2/value
    echo 0 > $gpiox1/value
    spi_bind
    usleep 5

else
    if [ $1 -eq 0 ];then
	echo "Bios version release at $(date)"
	spi_bind  #unbind
	usleep 5
	echo 0 > $gpiol2/value
	echo 0 > $gpiox1/value
	usleep 5
	echo 906 > /sys/class/gpio/unexport
	echo 1001 > /sys/class/gpio/unexport
    fi
fi
