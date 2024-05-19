#!/bin/sh
IMAGE_FILE=$(find /tmp/images/ -name "image.pnor")  #查找image文件。之后将得到的文件民返回
if [ -e $IMAGE_FILE ];
then
    echo "$IMAGE_FILE exits"
fi
REMOVE_FILE=${IMAGE_FILE:0:20}
echo "remove file $REMOVE_FILE"

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

function file_size()
{
    FILE_SIZE=`ls -l $IMAGE_FILE | awk '{ print $5 }'`  #注意是`号
    echo "file size = $FILE_SIZE"
    size=8388608
    if [ $FILE_SIZE -eq $size ];
    then
        echo "FILE_SIZE is OK";   #判断文件名大小
    else
        echo "FILE_SIZE is NOT OK REMOVE file";   #判断文件名大小
	rm -rf $REMOVE_FILE
        exit
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
function exec_update()
{
    if flashcp -v $IMAGE_FILE /dev/mtd6; then
	echo "BIOS UPDATE SUCCEFF"
    else
	echo "BIOS UPDATE FAILED"
    fi
}



if [ -e $IMAGE_FILE ];then
    file_size
    echo "Bios update start at $(date)"
    gpioinit
    power_status #power on
    echo 1 > $gpiol2/value
    echo 0 > $gpiox1/value
    spi_bind
    exec_update
    echo "bios-1 update succeff"

    spi_bind  #unbind

    echo 0 > $gpiol2/value
    echo 1 > $gpiox1/value
    spi_bind
    exec_update
    echo "bios-2 update succeff"

    sleep 8
    power_off
    spi_bind #unbind
    echo 0 > $gpiol2/value
    echo 0 > $gpiox1/value
    echo 906 > /sys/class/gpio/unexport
    echo 1001 > /sys/class/gpio/unexport
    rm -rf $REMOVE_FILE
    echo "REMOVE file succeff"
    sleep 8
    power_on
else
    echo "Image file not have"
    exit 1
fi

