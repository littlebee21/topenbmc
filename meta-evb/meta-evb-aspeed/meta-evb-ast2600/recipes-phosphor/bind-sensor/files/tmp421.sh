#!/bin/sh
if [ ! -d "/sys/bus/i2c/drivers/tmp421/7-004c" ];then
        echo 7-004c > /sys/bus/i2c/drivers/tmp421/bind
fi

