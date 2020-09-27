do_install_append () {
	install -d -m 0755 ${D}${sysconfdir}
	install -m 0644 ${S}/inittab ${D}${sysconfdir}/
	sed -i 's/id:5:initdefault:/id:3:initdefault:/' ${D}${sysconfdir}/inittab
}
