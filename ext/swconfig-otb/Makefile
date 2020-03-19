include $(TOPDIR)/rules.mk

PKG_NAME:=python-swconfig-otb
PKG_VERSION:=1.4
PKG_RELEASE:=2
PKG_LICENSE:=MIT

PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
-include $(TOPDIR)/feeds/packages/lang/python/python-package.mk

# old style
ifndef PYTHON_PKG_DIR
$(call include_mk, python-package.mk)
endif

define Package/$(PKG_NAME)
  SECTION:=OVH
  CATEGORY:=OverTheBox
  TITLE:=Tools to manage OVH OverTheBox switches
  DEPENDS:=+python-light +python-logging +python-pyserial +lsof +otb-luci-swconfig
endef

define Package/$(PKG_NAME)/description
	A python module to manage OVH OverTheBox switches
endef

define Build/Prepare
	$(CP) ./files/* $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root="$(PKG_INSTALL_DIR)")
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/lib/network
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/swconfig.py $(1)/usr/bin/swconfig
	$(CP) $(PKG_BUILD_DIR)/switch.sh $(1)/lib/network/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/swconfig-reset $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/swconfig-reset-todo $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
