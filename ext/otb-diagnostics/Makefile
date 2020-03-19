include $(TOPDIR)/rules.mk

PKG_NAME:=otb-diagnostics
PKG_VERSION:=0.7
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
SECTION:=OVH
CATEGORY:=OverTheBox
DEPENDS:=+lsof +TARGET_x86:dmidecode +tc +lsblk +iputils-ping
TITLE:=OverTheBox diagnostics
PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
OverTheBox diagnostics
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) otb-action-diagnostic $(1)/bin
	$(INSTALL_DIR) $(1)/usr/share/otb/diagnostics.d
	$(INSTALL_BIN) diags/* $(1)/usr/share/otb/diagnostics.d
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
