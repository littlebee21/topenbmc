RMCPP_IFACE = "eth0"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://ipmi-sol-push.patch"
