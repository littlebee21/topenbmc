#!/bin/bash

#touch /home/root/456.txt
GPIO_P0=936
GPIO_P1=937
GPIO_F6=862
GPIO_F7=863

echo 1 > /sys/class/gpio/gpio${GPIO_P0}/value
echo 1 > /sys/class/gpio/gpio${GPIO_P1}/value
echo out > /sys/class/gpio/gpio${GPIO_F6}/direction

echo 1 > /sys/class/gpio/gpio${GPIO_F6}/value

echo 1 > /sys/class/gpio/gpio${GPIO_F7}/value
echo 1 > /sys/class/gpio/gpio${GPIO_P1}/value
echo 0 > /sys/class/gpio/gpio${GPIO_P0}/value
echo 0 > /sys/class/gpio/gpio${GPIO_F6}/value

sleep 1
echo 1 > /sys/class/gpio/gpio${GPIO_F6}/value
echo in > /sys/class/gpio/gpio${GPIO_F6}/direction
exit 0;
