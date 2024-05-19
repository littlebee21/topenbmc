#!/bin/sh
if [  -d "/sys/bus/i2c/drivers/lm75/4-0048" ];then
        echo 3-0049 > /sys/bus/i2c/drivers/lm75/unbind
        echo 4-0048 > /sys/bus/i2c/drivers/lm75/unbind
fi

