#!/bin/bash

#touch /home/root/78999.txt
GPIO_P0=936
GPIO_P1=937
GPIO_F6=862
GPIO_F7=863

bash /usr/bin/bios-status-control.sh

echo out > /sys/class/gpio/gpio${GPIO_F7}/direction
echo out > /sys/class/gpio/gpio${GPIO_F6}/direction
echo 0 > /sys/class/gpio/gpio${GPIO_F7}/value
echo 0 > /sys/class/gpio/gpio${GPIO_F6}/value
echo 300 > /usr/bin/mointor.txt
sleep 1
echo 1 > /sys/class/gpio/gpio${GPIO_F7}/value
echo in > /sys/class/gpio/gpio${GPIO_F7}/direction
echo in > /sys/class/gpio/gpio${GPIO_F6}/direction


exit 0;
