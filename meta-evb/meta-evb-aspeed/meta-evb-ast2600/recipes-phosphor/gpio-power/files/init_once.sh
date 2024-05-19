#!/bin/bash

# Set all output GPIOs as such and drive them with reasonable values.
function set_gpio_active_low() {
  if [ $# -eq 1 ]; then
    echo $1 > /sys/class/gpio/export
    return;
  fi

  if [ $# -eq 2 ]; then
    echo $1 > /sys/class/gpio/export
    echo $2 > /sys/class/gpio/gpio$1/direction
    return;
  fi

}

GPIO_BASE=$(cat /sys/devices/platform/ahb/ahb:apb/1e780000.gpio/gpio/*/base)

# FM_BMC_READY_N, GPIO P1(power-on), out
set_gpio_active_low $((${GPIO_BASE} + 120 + 1)) out

# FM_BMC_READY_N, GPIO P0(power-off), out
set_gpio_active_low $((${GPIO_BASE} + 120 + 0)) out

# FM_BMC_READY_N, GPIO F6(ack), out
set_gpio_active_low $((${GPIO_BASE} + 40 + 6)) 

# FM_BMC_READY_N, GPIO F7(reset), out
set_gpio_active_low $((${GPIO_BASE} + 40 + 7)) 
exit 0;
