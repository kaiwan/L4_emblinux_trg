# ref: https://hub.mender.io/t/how-to-configure-networking-using-systemd-in-yocto-project/1097
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://wpa_supplicant-wlan0.conf"

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN}:append = " wpa_supplicant@wlan0.service  "

do_install:append () {
   install -d ${D}${sysconfdir}/wpa_supplicant/
   install -D -m 600 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/
   install -D -m 600 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant.conf

   install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/

# hint: "Created symlink /etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service → /lib/systemd/system/wpa_supplicant@.service"
   ln -s ${systemd_unitdir}/system/wpa_supplicant@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
}
