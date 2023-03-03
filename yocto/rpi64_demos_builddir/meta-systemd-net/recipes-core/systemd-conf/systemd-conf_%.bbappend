# ref: https://hub.mender.io/t/how-to-configure-networking-using-systemd-in-yocto-project/1097
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# TODO : rm 'eth' nw config file from system
SRC_URI += " \
    file://03-en.network \
    file://01-wlan.network \
"
#   file://02-eth.network 

FILES:${PN} += " \
	${sysconfdir} \
	${sysconfdir}/systemd \
	${sysconfdir}/systemd/network \
    ${sysconfdir}/systemd/network/03-en.network \
    ${sysconfdir}/systemd/network/01-wlan.network \
"
#   ${sysconfdir}/systemd/network/02-eth.network 

do_install:append() {
    install -d ${D}${sysconfdir}
    install -d ${D}${sysconfdir}/systemd
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/03-en.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/01-wlan.network ${D}${sysconfdir}/systemd/network
#   install -m 0644 ${WORKDIR}/02-eth.network ${D}${sysconfdir}/systemd/network
}
