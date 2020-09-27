FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI += " file://u-boot-rpienv.patch;patchdir=${S} \
   "

do_install_append() {
 echo "in u-boot do_inst..."
}
