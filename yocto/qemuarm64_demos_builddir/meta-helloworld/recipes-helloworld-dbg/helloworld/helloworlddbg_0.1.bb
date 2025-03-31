DESCRIPTION = "Simple helloworld debug application"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://helloworld.c"

S = "${WORKDIR}"

#-------------------------DEBUGGING Approaches-------------------------
#----- Make a 'debug' binary
#--- Attempt 1: via CFLAGS
#CFLAGS:prepend = "-g -ggdb -O0"
# Did not work

# How to see?
# bitbake -e hello |grep "^WORKDIR="
# ...
# Look under the WORKDIR..

#--- Attempt 2: instead use TARGET_CFLAGS
#TARGET_CFLAGS += "-g -ggdb -Og -Wall -std=gnu99"
# Setting TARGET_CFLAGS specifying -Og *does* result in debug binaries:
# $ file ...tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/image/usr/bin/*
# ...tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/image/usr/bin/helloworld:     ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /usr/lib/ld-linux-armhf.so.3, BuildID[sha1]=..., for GNU/Linux 5.15.0, with debug_info, not stripped
# ...tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/image/usr/bin/helloworld_dbg: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /usr/lib/ld-linux-armhf.so.3, BuildID[sha1]=..., for GNU/Linux 5.15.0, with debug_info, not stripped
# But this isn’t the best way...

#--- Attempt 3: use DEBUG_BUILD = "1"; build packages with debugging information
# Considered the 'correct' way during dev/debug
#DEBUG_BUILD = "1"

#--- Attempt 4: use *Package Splitting* ; perhaps the best way for production
# Next, let's use package splitting by setting INHIBIT_PACKAGE_DEBUG_SPLIT to 0!
INHIBIT_PACKAGE_DEBUG_SPLIT = "0"
# Pakages are now *split*:
# ls .../tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/
# hello/    hello-dbg/    hello-dev/    hello-doc/    hello-locale/  hello.shlibdeps  hello-src/   hello-staticdev/
#
# Now we find that both the production binaries as well as debug binaries are generated (as expected):
#  Production binaries: look under <recipe>/PV-PR/packages-split/<recipe>/<path/to/binaries>
#   tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello/usr/bin/hello*
#  Debug binaries: look under <recipe>/PV-PR/packages-split/<recipe-dbg>/<path/to/binaries>/.debug
#   tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello-dbg/usr/bin/.debug
#

# PACKAGE_DEBUG_SPLIT_STYLE
# Furthermore, when package splitting's done, the PACKAGE_DEBUG_SPLIT_STYLE var
# controls where the debug info's placed; set to:
#  (a) .debug [default]: debug binaries are placed in a .debug directory in the
#      same dirname of the binary produced (as seen above)
#  (b) debug-file-directory: into a central debug-file-directory, /usr/lib/debug
#  (c) debug-with-srcpkg : all source code will be placed into /usr/src/debug
#     f.e. PACKAGE_DEBUG_SPLIT_STYLE = 'debug-file-directory'

#PACKAGE_DEBUG_SPLIT_STYLE = "debug-file-directory"
#PACKAGE_DEBUG_SPLIT_STYLE = "debug-with-srcpkg"

# (a) With PACKAGE_DEBUG_SPLIT_STYLE unset, it defaults to ".debug", and debug binaries are found here:
# ls .../tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello-dbg/usr/bin/.debug/
#-rwxr-xr-x 2 kaiwan kaiwan 6.7K Mar 31 11:45 helloworld*
#-rwxr-xr-x 2 kaiwan kaiwan 7.5K Mar 31 11:45 helloworld_dbg*

# (b) With PACKAGE_DEBUG_SPLIT_STYLE = "debug-file-directory": debug binaries are found here:
# ls .../tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello-dbg/usr/lib/debug/usr/bin/
# ...and the 'source' is here:
# .../tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello-dbg/usr/src/

# (c) With PACKAGE_DEBUG_SPLIT_STYLE = "debug-with-srcpkg": debug binaries are found here:
#  tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello-dbg/usr/bin/.debug/
# ...and the 'source' is here:
# ... /tmp-glibc/work/arm1176jzfshf-vfp-kaiwanTECH-linux-gnueabi/hello/1.0/packages-split/hello-src/usr/src/debug/hello/1.0/

# Interestingly:
# - DEBUG_BUILD can be 0, and the package splitting approach still works
#   (generates debug binaries in appropriate locations)
# - In all cases, the debug binaries are *NOT* placed in the target rootfs;
#   So, when you need to debug a given package, copy the <pkgname>-dbg
#   and/or the  <pkgname>-dev packages to the target rootfs, extract and
#   then debug via GDB (or whatever).
#----------------------------------------------------------------------

do_configure:prepend() {
 # what's the WORKDIR variable's value?
	bbplain ">>> WORKDIR = S = ${WORKDIR}"
	bbplain ">>> build dir B = ${B}"
	bbplain ">>> dest dir D  = ${D}"
#	bbplain ">>> TARGET_CFLAGS = ${TARGET_CFLAGS}"
	bbplain ">>> DEBUG_BUILD = ${DEBUG_BUILD}"
	bbplain ">>> INHIBIT_PACKAGE_DEBUG_SPLIT = ${INHIBIT_PACKAGE_DEBUG_SPLIT} ; 0=>debug mode"
	bbplain ">>>   PACKAGE_DEBUG_SPLIT_STYLE = ${PACKAGE_DEBUG_SPLIT_STYLE} ; empty=>default: .debug dirs"
}
do_compile() {
	${CC} ${LDFLAGS} helloworld.c -o helloworld
	${CC} ${TARGET_CFLAGS} ${LDFLAGS} helloworld.c -o helloworld_dbg
}
do_install() {
	# ${bindir} = /usr/bin
	install -d ${D}${bindir}
	install -m 0755 helloworld ${D}${bindir}
	install -m 0755 helloworld_dbg ${D}${bindir}
}
