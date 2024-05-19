DESCRIPTION = "Network Block Device"
HOMEPAGE = "http://nbd.sourceforge.net"
SECTION = "net"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "autoconf-archive bison-native glib-2.0 libnl"

SRC_URI = "https://sourceforge.net/projects/nbd/files/nbd/3.9/nbd-3.9.tar.gz"
SRC_URI[md5sum] = "b8bfea3c6d1dd1972959713f8c88ab96"

inherit autotools pkgconfig

do_configure:prepend() {
    cp ${WORKDIR}/nbd-3.9/*  ${WORKDIR}/onbd-1.0 -r
}

do_install() {
    install -d ${D}/usr/bin
    install -m 0755 ${WORKDIR}/build/nbd-client ${D}${bindir}/onbd-client
}