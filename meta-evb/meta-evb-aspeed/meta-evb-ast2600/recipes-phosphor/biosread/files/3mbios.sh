#!/bin/sh

SROM=$1
HMCODE=$2
BIOS=$3
flag1=0
flag2=0
flag3=0
dev=/dev/mtd6

gpiol2=/sys/class/gpio/gpio906
gpiox1=/sys/class/gpio/gpio1001

copy()
{
echo "###################first satstp###################"
dd if=$dev of=/home/root/bios-sorm.bin bs=32k skip=0 seek=0 count=1
echo "bios-sorm"
dd if=$dev of=/home/root/bios-hmcode.bin bs=32k skip=1 seek=0 count=31
echo "bios-hmcode"
dd if=$dev of=/home/root/bios-3m.bin bs=64k skip=16 seek=0 count=48
echo "bios-3m"
dd if=$dev of=/home/root/bios-4m.bin bs=64k skip=64 seek=0 count=64
echo "bios-4m"
flash_eraseall $dev
sleep 1
}

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

execet()
{
echo "################################### seconed strapt ########################"
if [ $flag1 -eq 0 ]; then
    dd if=/home/root/bios-sorm.bin of=/dev/mtd6
else
    if [ $flag1 -eq 1 ]; then
	dd if=$SROM of=/home/root/bios-sorm.bin bs=1 skip=0 seek=128 count=32640
	sleep 1
	dd if=/home/root/bios-sorm.bin of=/dev/mtd6 bs=1 skip=0 seek=0 count=32768
    else
	if [ $flag1 -eq 2 ]; then
	    dd if=$SROM of=/home/root/bios-sorm.bin bs=1 skip=128 seek=128 count=17624
	    sleep 1
	    dd if=/dev/zero of=/home/root/bios-sorm.bin bs=1 skip=0 seek=17752 count=15016
	    sleep 1
	    dd if=/home/root/bios-sorm.bin of=/dev/mtd6 bs=1 skip=0 seek=0 count=32768
	else
	    echo "SROM ERROR!!!!"
	    exit
	fi
    fi
fi
echo "SROM UPDATE"


if [ $flag2 -eq 0 ]; then
    dd if=/home/root/bios-hmcode.bin of=/dev/mtd6 bs=32k skip=0 seek=1 count=31
else
    if [ $flag2 -eq 1 ]; then
	let sizehm=992-$FILE_SIZE_HM-480
	let sizehm1=$FILE_SIZE_HM+480
	echo "the hmcode= $sizehm"
	dd if=$HMCODE of=/home/root/bios-hmcode.bin bs=1k skip=0 seek=480 count=$FILE_SIZE_HM
	dd if=/dev/zero of=/home/root/bios-hmcode.bin bs=1k skip=0 seek=$sizehm1 count=$sizehm
	dd if=/home/root/bios-hmcode.bin of=$dev bs=32k skip=0 seek=1 count=31
	echo "PRINT HMCODE"
	ls -lh /home/root/bios-hmcode.bin
    else
	echo "HMCODE  ERROR!!!!"
	exit
    fi
fi
echo "HMCODE UPDATE"

if [ $flag3 -eq 0 ]; then
    dd if=/home/root/bios-3m.bin of=$dev bs=64k skip=0 seek=16 count=48
else
    if [ $flag3 -eq 1 ]; then
	dd if=$BIOS of=$dev bs=64k skip=0 seek=16 count=48
    else
	echo "BIOS ERROR !!!!!"
	exit
    fi
fi
echo "BIOS UPDATE"

dd if=/home/root/bios-4m.bin of=$dev bs=64k skip=0 seek=64 count=64
rm /home/root/bios-sorm.bin /home/root/bios-hmcode.bin /home/root/bios-3m.bin /home/root/bios-4m.bin
echo "UPDATE SUCCEFF"
}

if [ -e $SROM ];then
    FILE_SIZE_SROM=`ls -l $SROM | awk '{ print $5 }'`  #注意是`号
    size=32640
    size1=17624
    if [ $FILE_SIZE_SROM -eq $size ];then
	flag1=1;
    else
    	if [ $FILE_SIZE_SROM -eq $size1 ];then
	flag1=2;
	else
		echo "SROM file size error"
		exit
	fi
    fi
else
    echo "NO SORM FILE"
    flag1=0;
fi

if [ -e $HMCODE ];then
    FILE_SIZE_HM=`ls -lh $HMCODE | awk '{ print $5 }'`  #注意是`号
    FILE_SIZE_HM=${FILE_SIZE_HM:0:2}
    echo "HMCODE = $FILE_SIZE_HM"
    if [ $FILE_SIZE_HM -gt 63 ]; then
	flag2=1
    else
	echo "HMCODE file size error"
	exit
    fi

else
    echo "NO HMCODE FILE"
    flag2=0
fi


if [ -e $BIOS ];then
    FILE_SIZE_BIOS=`ls -l $BIOS | awk '{ print $5 }'`  #注意是`号
    size=3145728
    if [ $FILE_SIZE_BIOS -eq $size ]; then
	flag3=1
    else
	echo "BIOS file error"
	exit
    fi
else
    echo "NO BIOS FILE"
    flag3=0
fi


gpioinit
power_status #power on
echo 1 > $gpiol2/value
echo 0 > $gpiox1/value
spi_bind
copy
execet
echo "bios-1 update succeff"

spi_bind  #unbind

echo 0 > $gpiol2/value
echo 1 > $gpiox1/value
spi_bind
copy
execet
echo "bios-2 update succeff"

sleep 1
spi_bind #unbind
echo 0 > $gpiol2/value
echo 0 > $gpiox1/value
echo 906 > /sys/class/gpio/unexport
echo 1001 > /sys/class/gpio/unexport
power_off
sleep 4
power_on


