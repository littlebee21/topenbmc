FILESEXTRAPATHS:prepend:evb-ast2600 := "${THISDIR}/${PN}:"

SRC_URI:append:evb-ast2600 = " file://sol-default.override.yml"
