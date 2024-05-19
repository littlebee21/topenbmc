# bios control gpio
# preprare bios gpio value 0 (because bios cant run problem)
# GPIO_L2=906
if [ -d /sys/class/gpio/gpio906 ]
then
    echo out > /sys/class/gpio/gpio906/direction
    echo 0 > /sys/class/gpio/gpio906/value
else
    echo 906 > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio906/direction
    echo 0 > /sys/class/gpio/gpio906/value
fi

# GPIO_X1=1001
if [ -d /sys/class/gpio/gpio1001 ]
then
    echo out > /sys/class/gpio/gpio1001/direction
    echo 0 > /sys/class/gpio/gpio1001/value
else
    echo 1001 > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio1001/direction
    echo 0 > /sys/class/gpio/gpio1001/value
fi

echo bios status set 0