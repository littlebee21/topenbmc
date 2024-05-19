SUMMARY = "Simple power application"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	   file://bios.c \
	   file://bios_update.sh \
	   file://bios_version.sh \
	   file://3mbios.sh \
	   file://bios_version.txt  \
	   "

S = "${WORKDIR}"

do_compile() {
    ${CC} ${LDFLAGS} bios.c -o bios_read
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 bios_read  ${D}${bindir}
    install -m 0755 bios_update.sh  ${D}${bindir}
    install -m 0755 3mbios.sh  ${D}${bindir}
    install -m 0755 bios_version.sh  ${D}${bindir}
    install -m 0755 bios_version.txt  ${D}${bindir}
}

