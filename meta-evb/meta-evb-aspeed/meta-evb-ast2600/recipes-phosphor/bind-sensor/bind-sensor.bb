SUMMARY = "Simple power application"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd
DEPENDS += "systemd sdbusplus"
RDEPENDS:${PN} += "bash"

SRC_URI = " \
	   file://lm75.sh \
	   file://lm75bye.sh \
	   file://tmp421.sh \
	   file://tmp421bye.sh \
	   file://mointor.txt \
	   file://sensor-sh.c \
	   file://mointor.sh \
	   file://sensor-sh.service \
	   "

S = "${WORKDIR}"
do_compile() {
    ${CC} ${LDFLAGS} sensor-sh.c -o sensor-sh
}


do_install() {
    install -d ${D}${bindir}
    install -m 0755 sensor-sh ${D}${bindir}
    install -m 0755 lm75.sh ${D}${bindir}
    install -m 0755 lm75bye.sh ${D}${bindir}
    install -m 0755 tmp421bye.sh ${D}${bindir}
    install -m 0755 tmp421.sh ${D}${bindir}
    install -m 0755 mointor.txt ${D}${bindir}
    install -m 0755 mointor.sh ${D}${bindir}

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/sensor-sh.service ${D}${systemd_system_unitdir}
}
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "sensor-sh.service"
