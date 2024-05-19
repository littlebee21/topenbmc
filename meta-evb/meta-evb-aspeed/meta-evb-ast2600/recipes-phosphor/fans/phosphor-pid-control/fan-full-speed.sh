#!bin/bash

echo 100 > /sys/class/hwmon/*/pwm0
echo 100 > /sys/class/hwmon/*/pwm1
echo 100 > /sys/class/hwmon/*/pwm2
echo 100 > /sys/class/hwmon/*/pwm3