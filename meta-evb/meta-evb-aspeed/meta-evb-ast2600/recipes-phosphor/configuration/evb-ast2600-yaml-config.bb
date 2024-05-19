SUMMARY = "YAML configuration for evb-ast2600"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
inherit allarch

SRC_URI = " \
    file://evb-ast2600-ipmi-fru.yaml \
    file://evb-ast2600-ipmi-fru-properties.yaml \
    file://evb-ast2600-ipmi-sensors.yaml \
    file://evb-ast2600-ipmi-fru-cpu.yaml \
    "

S = "${WORKDIR}"

do_install() {
    cat evb-ast2600-ipmi-fru.yaml \
	evb-ast2600-ipmi-fru-cpu.yaml > fru-read.yaml

    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/ipmi-fru-read.yaml
    install -m 0644 -D evb-ast2600-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/ipmi-extra-properties.yaml
    install -m 0644 -D evb-ast2600-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/ipmi-sensors.yaml
}

FILES:${PN}-dev = " \
    ${datadir}/${BPN}/ipmi-fru-read.yaml \
    ${datadir}/${BPN}/ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/ipmi-sensors.yaml \
    "

ALLOW_EMPTY:${PN} = "1"
