DEPENDS:append:evb-ast2600 = " evb-ast2600-yaml-config"

FILESEXTRAPATHS:prepend:evb-ast2600 := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append:evb-ast2600 = " \
    -Dsensor-yaml-gen=${STAGING_DIR_HOST}${datadir}/evb-ast2600-yaml-config/ipmi-sensors.yaml \
    -Dfru-yaml-gen=${STAGING_DIR_HOST}${datadir}/evb-ast2600-yaml-config/ipmi-fru-read.yaml \
     "

RDEPENDS:${PN}:remove:evb-ast2600 = "clear-once"
