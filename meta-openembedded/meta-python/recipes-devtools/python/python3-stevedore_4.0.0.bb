DESCRIPTION = "Manage dynamic plugins for Python applications"
HOMEPAGE = "https://docs.openstack.org/stevedore/latest/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI[sha256sum] = "f82cc99a1ff552310d19c379827c2c64dd9f85a38bcd5559db2470161867b786"

DEPENDS += "${PYTHON_PN}-pbr-native"

inherit pypi setuptools3

RDEPENDS:${PN} += "${PYTHON_PN}-pbr ${PYTHON_PN}-six"

BBCLASSEXTEND = "native"
