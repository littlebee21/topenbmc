FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://blacklist.txt"
SRC_URI += "file://whitelist.txt"
SRC_URI += "file://blacklist_time.txt"

FILES:${PN}:append = " \
     /data/blacklist.txt \
     /data/whitelist.txt \
     /data/blacklist_time.txt \
     "

EXTRA_OEMESON:append = " \
     -Dinsecure-tftp-update=disabled \
     -Dbmcweb-logging=enabled \
     -Drest=enabled \
     -Dredfish=enabled \
     -Dhost-serial-socket=enabled \
     -Dredfish-dbus-log=enabled \
     -Dredfish-bmc-journal=disabled \
     "
DEPENDS += " sqlite3"

inherit obmc-phosphor-discovery-service

REGISTERED_SERVICES:${PN} += "obmc_redfish:tcp:443:"
REGISTERED_SERVICES:${PN} += "obmc_rest:tcp:443:"

do_install:append() {
    install -d ${D}/data
    install -m 0755 ${WORKDIR}/blacklist.txt ${D}/data/blacklist.txt
    install -m 0755 ${WORKDIR}/whitelist.txt ${D}/data/whitelist.txt
    install -m 0755 ${WORKDIR}/blacklist_time.txt ${D}/data/blacklist_time.txt
}
