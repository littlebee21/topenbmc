FILESEXTRAPATHS:prepend:evb-ast2600 := "${THISDIR}/${PN}:"
EXTRA_OEMESON:append:evb-ast2600 = " -Dupdate-functional-on-fail=true -Dnegative-errno-on-fail=false"

NAMES = " \
        "
ITEMSFMT = "ahb/apb/{0}.conf"

ITEMS = "${@compose_list(d, 'ITEMSFMT', 'NAMES')}"
ITEMS += "ahb/apb/pwm-tacho-controller@1e610000.conf"
ITEMS += "ahb/apb/bus@1e78a000/i2c-bus@400/tmp422@4c.conf"
ITEMS += "ahb/apb/bus@1e78a000/i2c-bus@800/psu@58.conf"
ITEMS += "ahb/apb/bus@1e78a000/i2c-bus@800/psu@5b.conf"
ITEMS += "ahb/apb/bus@1e78a000/i2c-bus@200/lm75@49.conf"
ITEMS += "ahb/apb/bus@1e78a000/i2c-bus@280/lm75@48.conf"
ITEMS += "iio-hwmon.conf "

ENVS = "obmc/hwmon/{0}"
SYSTEMD_ENVIRONMENT_FILE:${PN}:append:evb-ast2600 = " ${@compose_list(d, 'ENVS', 'ITEMS')}"
