SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(UCLIBC_BROKEN_PACKAGES) \
	amule asterisk asterisk14-chan-capi \
	bluez-hcidump chillispot \
	dump ficy gdb \
	gnuplot htop inetutils \
	ircd-hybrid \
	libopensync mdadm \
	msynctool netatalk obexftp \
	puppy quagga sendmail \
	unfs3 usbutils util-linux
