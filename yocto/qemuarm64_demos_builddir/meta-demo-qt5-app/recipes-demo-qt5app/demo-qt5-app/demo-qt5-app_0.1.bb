# Recipe generated by yct_recipe_gen
# (c) kaiwanTECH
# Wednesday 08 March 2023 12:49:09 PM IST
# (Note- this script generates syntax appropriate for honister 3.4 onwards, the syntax is of the form x:y not x_y !
# For lower versions, you'll have to manually change the syntax).
DESCRIPTION = "Demo - recipe for a v simple Qt GUI Hello, world app"

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
DEPENDS += "qtbase"

# Location of files
#  Tip: append '; unpack=0 \' to not unpack the file
SRC_URI = " file://qt1.pro \
	file://qthw1.c \
   "

#If you need autostart:
#SRC_URI += "file://myguiapp.service"

# The FILE_${PN} addition below is required to avoid the 'installed but not shipped in any package'
# error; it's left commented out by default
# (Note- honister 3.4 onwards, the syntax is of the form x:y not x_y !
FILES_${PN} += "${bindir}/qt1"

S = "${WORKDIR}"

do_configure () {
	# Specify any needed configure commands here
}

do_compile () {
	bbplain 'in do_compile '
	cd ${S}
	qmake
	ls -l Makefile
	sed -i -e 's/$(CC) -c $(CFLAGS) $(INCPATH) -o qthw1.o qthw1.c/$(CXX) -c $(CFLAGS) $(INCPATH) -o qthw1.o qthw1.c/' Makefile || bbplain 'sed FAIL' && bbplain 'sed OK'
	make
}

do_install_append () {
    install -d ${D}${bindir}
    install -m 0755 ${S}/qt1 ${D}${bindir}/
	# while debugging...
	bbplain 'do_install_append: (${D}${bindir}/qt1)'
	# TIP- while dbg, I used 'bitbake demo-qt5-app -c devshell' as well to get
	# into it's WORKDIR and figure things out!

    # Uncomment if you want to autostart this application as a service     
    #install -Dm 0644 ${WORKDIR}/myguiapp.service ${D}${systemd_system_unitdir}/myguiapp.service
}

# Does the magic!
inherit qmake5
