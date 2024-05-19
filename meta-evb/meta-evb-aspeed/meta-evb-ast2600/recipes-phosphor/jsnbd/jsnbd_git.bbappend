FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://usb_install.sh"
SRC_URI += "file://usb_uninstall.sh"


do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/usb_uninstall.sh  ${D}${bindir}
    install -m 0755 ${WORKDIR}/usb_install.sh  ${D}${bindir}
}