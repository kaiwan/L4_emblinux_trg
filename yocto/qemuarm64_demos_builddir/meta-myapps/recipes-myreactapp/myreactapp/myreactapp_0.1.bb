SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Demo: a recipe within 'meta-myapps' layer; builds a C prg named 'react' (try it!)"
SECTION = "apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "\
	file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
	"

# Location of files
#  Tip: append '; unpack=0 \' to not unpack the file
SRC_URI = " file://common.c \
            file://common.h \
            file://Makefile \
            file://react.c \
   "

# The FILE_${PN} addition below is required to avoid the 'installed but not shipped in any package'
# error; it's left commented out by default
# (Note- honister 3.4 onwards, the syntax is of the form x:y not x_y !
#FILES:${PN} += "${base_prefix}/ helloworld_loops.c \"

S = "${WORKDIR}"

#do_compile () {
#   echo "$(pwd); ls: $(ls)"
#}
do_install () {
    bbplain "********* myreactapp recipe: do_install() *********"
	# Specify install commands here; examples below:
	# (1) create a dir /etc/init.d with:
	#  install -d -m 0755 ${D}/etc/init.d
	# (2) Tip: to generate a soft link, first cd to the dir
    #     and then create it;
	#  cd /etc/rc5.d
	#  ln -s ../init.d/myprg_install.sh S99myprg
	echo "S = ${S}; ls:  $(ls $S)"
	install -d -m 0755 ${D}${bindir}
	install -m 0755 ${S}/react ${D}${bindir}
		# $bindir = /usr/bin/
}
