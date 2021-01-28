PREFIX = /usr/

all: install

install:
	install -Dm 755 instantlaunch.sh ${DESTDIR}${PREFIX}bin/instantlaunch
	install -m 644 instantlaunch.desktop $(DESTDIR)$(PREFIX)share/applications/
	install -m 644 xml/appimage.xml $(DESTDIR)$(PREFIX)share/mime/pacakges/xml/

uninstall:
	rm ${DESTDIR}${PREFIX}bin/instantlaunch
	rm ${DESTDIR}${PREFIX}share/applications/instantlaunch.desktop
	rm ${DESTDIR}${PREFIX}share/mime/pacakges/xml/appimage.xml
