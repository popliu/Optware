###########################################################
#
# libxslt
#
###########################################################

#
# LIBXSLT_VERSION, LIBXSLT_SITE and LIBXSLT_SOURCE define
# the upstream location of the source code for the package.
# LIBXSLT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBXSLT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBXSLT_SITE=http://xmlsoft.org/sources
LIBXSLT_VERSION=1.1.12
LIBXSLT_SOURCE=libxslt-$(LIBXSLT_VERSION).tar.gz
LIBXSLT_DIR=libxslt-$(LIBXSLT_VERSION)
LIBXSLT_UNZIP=zcat

#
# LIBXSLT_IPK_VERSION should be incremented when the ipk changes.
#
LIBXSLT_IPK_VERSION=1

#
# LIBXSLT_CONFFILES should be a list of user-editable files
#LIBXSLT_CONFFILES=/opt/etc/libxslt.conf /opt/etc/init.d/SXXlibxslt

#
# LIBXSLT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBXSLT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBXSLT_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libxml2
LIBXSLT_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# LIBXSLT_BUILD_DIR is the directory in which the build is done.
# LIBXSLT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBXSLT_IPK_DIR is the directory in which the ipk is built.
# LIBXSLT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBXSLT_BUILD_DIR=$(BUILD_DIR)/libxslt
LIBXSLT_SOURCE_DIR=$(SOURCE_DIR)/libxslt
LIBXSLT_IPK_DIR=$(BUILD_DIR)/libxslt-$(LIBXSLT_VERSION)-ipk
LIBXSLT_IPK=$(BUILD_DIR)/libxslt_$(LIBXSLT_VERSION)-$(LIBXSLT_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBXSLT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBXSLT_SITE)/$(LIBXSLT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libxslt-source: $(DL_DIR)/$(LIBXSLT_SOURCE) $(LIBXSLT_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(LIBXSLT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXSLT_SOURCE) $(LIBXSLT_PATCHES)
	$(MAKE) libxml2-stage
	rm -rf $(BUILD_DIR)/$(LIBXSLT_DIR) $(LIBXSLT_BUILD_DIR)
	$(LIBXSLT_UNZIP) $(DL_DIR)/$(LIBXSLT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(LIBXSLT_PATCHES) | patch -d $(BUILD_DIR)/$(LIBXSLT_DIR) -p1
	mv $(BUILD_DIR)/$(LIBXSLT_DIR) $(LIBXSLT_BUILD_DIR)
	(cd $(LIBXSLT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBXSLT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBXSLT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--without-python \
		--without-crypto \
		--with-libxml-libs-prefix=$(STAGING_DIR)/opt \
		--with-libxml-include-prefix=$(STAGING_DIR)/opt \
	)
	touch $(LIBXSLT_BUILD_DIR)/.configured

libxslt-unpack: $(LIBXSLT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXSLT_BUILD_DIR)/.built: $(LIBXSLT_BUILD_DIR)/.configured
	rm -f $(LIBXSLT_BUILD_DIR)/.built
	$(MAKE) -C $(LIBXSLT_BUILD_DIR)
	touch $(LIBXSLT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libxslt: $(LIBXSLT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXSLT_BUILD_DIR)/.staged: $(LIBXSLT_BUILD_DIR)/.built
	rm -f $(LIBXSLT_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBXSLT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	# follow libxml's convention in putting -config bins in STAGING/bin
	cp $(STAGING_DIR)/opt/bin/xslt-config $(STAGING_DIR)/bin
	# remove .la to avoid libtool problems
	rm $(STAGING_LIB_DIR)/libxslt.la
	rm $(STAGING_LIB_DIR)/libexslt.la
	touch $(LIBXSLT_BUILD_DIR)/.staged

libxslt-stage: $(LIBXSLT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBXSLT_IPK_DIR)/opt/sbin or $(LIBXSLT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBXSLT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBXSLT_IPK_DIR)/opt/etc/libxslt/...
# Documentation files should be installed in $(LIBXSLT_IPK_DIR)/opt/doc/libxslt/...
# Daemon startup scripts should be installed in $(LIBXSLT_IPK_DIR)/opt/etc/init.d/S??libxslt
#
# You may need to patch your application to make it use these locations.
#
$(LIBXSLT_IPK): $(LIBXSLT_BUILD_DIR)/.built
	rm -rf $(LIBXSLT_IPK_DIR) $(BUILD_DIR)/libxslt_*_armeb.ipk
	$(MAKE) -C $(LIBXSLT_BUILD_DIR) DESTDIR=$(LIBXSLT_IPK_DIR) install
	rm $(LIBXSLT_IPK_DIR)/opt/lib/libxslt.la
	rm $(LIBXSLT_IPK_DIR)/opt/lib/libexslt.la
#	install -d $(LIBXSLT_IPK_DIR)/opt/etc/
#	install -m 755 $(LIBXSLT_SOURCE_DIR)/libxslt.conf $(LIBXSLT_IPK_DIR)/opt/etc/libxslt.conf
#	install -d $(LIBXSLT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBXSLT_SOURCE_DIR)/rc.libxslt $(LIBXSLT_IPK_DIR)/opt/etc/init.d/SXXlibxslt
	install -d $(LIBXSLT_IPK_DIR)/CONTROL
	install -m 644 $(LIBXSLT_SOURCE_DIR)/control $(LIBXSLT_IPK_DIR)/CONTROL/control
#	install -m 644 $(LIBXSLT_SOURCE_DIR)/postinst $(LIBXSLT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(LIBXSLT_SOURCE_DIR)/prerm $(LIBXSLT_IPK_DIR)/CONTROL/prerm
#	echo $(LIBXSLT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBXSLT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXSLT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libxslt-ipk: $(LIBXSLT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libxslt-clean:
	-$(MAKE) -C $(LIBXSLT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libxslt-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBXSLT_DIR) $(LIBXSLT_BUILD_DIR) $(LIBXSLT_IPK_DIR) $(LIBXSLT_IPK)
