FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
	    file://sensor-line.patch \
	    file://fru-fix.patch"
