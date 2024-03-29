# Recipe generated by yct_recipe_gen
# (c) kaiwanTECH
# Saturday 25 February 2023 05:13:34 PM IST
# (Note- this script generates syntax appropriate for honister 3.4 onwards, the syntax is of the form x:y not x_y !
# For lower versions, you'll have to manually change the syntax).
DESCRIPTION = "Classic K&R helloworld C program"

# Section: 'examples'; replace with appropriate section; f.e.: utils, graphics, apps, ...
SECTION = "examples"

HOMEPAGE = ""

# NOTE: 
# We could set - and comment out - LICENSE to "CLOSED" to allow you to at least start
# building - if this is not accurate with respect to the licensing of the
# software being built (it will not be in most cases) you must specify the
# correct value before using this recipe for anything other than initial
# testing/development!
#LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = ""
# LICENSE set to 'Dual MIT/GPL'; change if you wish...
LICENSE = "GPL-2.0 | MIT"
LIC_FILES_CHKSUM = "\
	file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
	"

# Fill dependencies for this recipe;
# (Note- honister 3.4 onwards, the syntax is of the form x:y not x_y !
# f.e. = "bash dpkg python"
RDEPENDS:${PN} = ""

# Location of files
#  Tip: append '; unpack=0 \' to not unpack the file
SRC_URI = " file://helloworld_loops.c \
   "

# The FILE_${PN} addition below is required to avoid the 'installed but not shipped in any package'
# error; it's left commented out by default
# (Note- honister 3.4 onwards, the syntax is of the form x:y not x_y !
#FILES:${PN} += "${base_prefix}/ helloworld_loops.c \"

IMAGE_FEATURES += ""

S = "${WORKDIR}"
# FYI, ${S} = ${WORKDIR} = tmp/work/${PACKAGE_ARCH}-poky-${TARGET_OS}/${PN}/${PV}-${PR}
#  ${D} = ${WORKDIR}/image
# f.e
#  poky/rpi-build/tmp/work/aarch64-poky-linux/myprj/1.0-r0/image/
#                 [               WORKDIR                 ][image]
#      [build-dir][             tmp workdir               ]
# [rootfs] is a 'partial' rootfs - one made for ONLY this recipe's rootfs
# content! The final rootfs is a union of all the recipe/pkg [rootfs]'s

do_configure () {
	# Specify any needed configure commands here
	:
}

do_compile () {
	# Specify compilation commands here
	${CC} ${CFLAGS} ${LDFLAGS} ${WORKDIR}/helloworld_loops.c -o ${WORKDIR}/helloworld_loops
}

do_install () {
	# Specify install commands here; examples below:
	# (1) create a dir /etc/init.d with:
	#  install -d -m 0755 ${D}/etc/init.d
	# (2) Tip: to generate a soft link, first cd to the dir
      #     and then create it;
	#  cd /etc/rc5.d
	#  ln -s ../init.d/myprg_install.sh S99myprg
	install -d -m 0755 ${D}/${bindir}
	install -m 0755 ${WORKDIR}/helloworld_loops ${D}/${bindir}
		# $bindir = /usr/bin/
}
