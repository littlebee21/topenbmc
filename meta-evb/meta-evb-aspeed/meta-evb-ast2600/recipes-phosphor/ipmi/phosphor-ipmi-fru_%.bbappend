inherit obmc-phosphor-systemd
DEPENDS:append:evb-ast2600 = " evb-ast2600-yaml-config"

FILESEXTRAPATHS:prepend:evb-ast2600 := "${THISDIR}/${PN}:"

EXTRA_OECONF:append:evb-ast2600 = " \
    YAML_GEN=${STAGING_DIR_HOST}${datadir}/evb-ast2600-yaml-config/ipmi-fru-read.yaml \
    PROP_YAML=${STAGING_DIR_HOST}${datadir}/evb-ast2600-yaml-config/ipmi-extra-properties.yaml \
    "
EEPROM_NAMES = "motherboard cpu"

EEPROMFMT = "system/{0}"
EEPROM_ESCAPEDFMT = "system-{0}"
EEPROMS = "${@compose_list(d, 'EEPROMFMT', 'EEPROM_NAMES')}"
EEPROMS_ESCAPED = "${@compose_list(d, 'EEPROM_ESCAPEDFMT', 'EEPROM_NAMES')}"

ENVFMT = "obmc/eeproms/{0}"
SYSTEMD_ENVIRONMENT_FILE:${PN}:append:evb-ast2600 := " ${@compose_list(d, 'ENVFMT', 'EEPROMS')}"

TMPL = "obmc-read-eeprom@.service"
TGT = "multi-user.target"
INSTFMT = "obmc-read-eeprom@{0}.service"
FMT = "../${TMPL}:${TGT}.wants/${INSTFMT}"

SYSTEMD_LINK:${PN}:append:evb-ast2600 := " ${@compose_list(d, 'FMT', 'EEPROMS_ESCAPED')}"

