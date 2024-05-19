SUMMARY = "yugu eeprom"
DESCRIPTION = "add yugu virtual eeprom"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI = " \
    file://eeprom-tw \
    file://eeprom-sn \
    file://fru.c \
    "
S = "${WORKDIR}"
do_compile() {
    ${CC} ${LDFLAGS} fru.c -o fru
}

do_install() {
    install -d ${D}${base_bindir}
    install -m 4777 ${WORKDIR}/eeprom-tw ${D}/bin/eeprom-tw
    install -d ${D}${base_bindir}
    install -m 4777 ${WORKDIR}/eeprom-sn ${D}/bin/eeprom-sn
    install -d ${D}${bindir}
    install -m 0755 fru  ${D}${bindir}
}
