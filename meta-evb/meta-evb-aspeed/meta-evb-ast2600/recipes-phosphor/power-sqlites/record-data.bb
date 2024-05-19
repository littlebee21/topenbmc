SUMMARY = "record-data"
DESCRIPTION = "record Data from dbus, and write to sqlite3"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

# 包含的库
DEPENDS = " curl systemd sqlite3"
RDEPENDS:${PN} += "bash"

SRC_URI = " \
           file://record.sh \
           file://record-data.service \
           file://total_consumption.cpp \
           file://total_consumption.service \
           "

S = "${WORKDIR}"

do_compile() {
    ${CXX} ${LDFLAGS} total_consumption.cpp -o total_consumption
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 record.sh ${D}${bindir}
    install -m 0755 total_consumption ${D}${bindir}

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/record-data.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/total_consumption.service ${D}${systemd_system_unitdir}
}
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "record-data.service"
SYSTEMD_SERVICE:${PN} += "total_consumption.service"
