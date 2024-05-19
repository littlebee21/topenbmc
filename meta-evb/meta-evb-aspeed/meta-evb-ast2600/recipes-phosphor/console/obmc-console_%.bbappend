FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
OBMC_CONSOLE_HOST_TTYS = "ttyS0 ttyVUART0"

SRC_URI:append = " file://server.ttyS0.conf \
		   file://client.2200.conf \
		   file://client.2201.conf \
                   file://server.ttyVUART0.conf "

SRC_URI:remove = "file://${BPN}.conf"

SYSTEMD_SERVICE:${PN}:remove = "obmc-console-ssh.socket"
EXTRA_OECONF:append = " --enable-concurrent-servers"

do_install:append() {
        # Install the server configuration
        install -m 0755 -d ${D}${sysconfdir}/${BPN}
        install -m 0644 ${WORKDIR}/*.conf ${D}${sysconfdir}/${BPN}/
}
