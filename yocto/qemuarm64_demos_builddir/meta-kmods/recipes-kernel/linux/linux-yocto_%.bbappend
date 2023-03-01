FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " file://defconfig \
             file://fragment.cfg \
	"

do_kernel_configme_prepend() {
  bbplain ">>> kernel config: linux-yocto_%.bbappend here"
}
