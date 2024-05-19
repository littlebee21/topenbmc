FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://config-palmetto.json"
SRC_URI += " file://fan-full-speed.sh"
SRC_URI += " file://phosphor-pid-control.service"
SRC_URI += " file://fan-reboot-control.service"

FILES:${PN}:append = " ${bindir}/fan-full-speed.sh"
FILES:${PN}:append = " ${datadir}/swampd/config.json"

inherit systemd
RDEPENDS:${PN} += "bash"

SYSTEMD_SERVICE:${PN}:append = " phosphor-pid-control.service"
SYSTEMD_SERVICE:${PN}:append = " fan-reboot-control.service"

do_install:append() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/fan-full-speed.sh ${D}/${bindir}

    install -d ${D}${datadir}/swampd
    install -m 0644 -D ${WORKDIR}/config-palmetto.json \
        ${D}${datadir}/swampd/config.json

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/phosphor-pid-control.service \
        ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/fan-reboot-control.service \
        ${D}${systemd_unitdir}/system
}
