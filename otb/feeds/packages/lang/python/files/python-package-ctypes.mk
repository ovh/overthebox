#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-ctypes
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) ctypes module
  DEPENDS:=+python-light
endef

$(eval $(call PyBasePackage,python-ctypes, \
	/usr/lib/python$(PYTHON_VERSION)/ctypes \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_ctypes.so \
	/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_ctypes_test.so \
))
