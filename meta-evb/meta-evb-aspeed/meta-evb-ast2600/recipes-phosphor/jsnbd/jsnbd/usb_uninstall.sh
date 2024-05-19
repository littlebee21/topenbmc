#!/bin/sh
gadget_name=myusb
gadget_dir=/sys/kernel/config/usb_gadget/$gadget_name

cd $gadget_dir
rm configs/c.1/mass_storage.usb0
rmdir functions/mass_storage.usb0
rmdir configs/c.1/strings/0x409
rmdir configs/c.1
rmdir strings/0x409
rmdir $gadget_dir

onbd-client -d /dev/nbd1 > /tmp/nbdMount