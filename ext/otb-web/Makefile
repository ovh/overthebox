include $(TOPDIR)/rules.mk

PKG_NAME:=otb-web
PKG_VERSION:=0.1
PKG_RELEASE:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
SECTION:=OVH
CATEGORY:=OverTheBox
TITLE:=$(PKG_NAME)
PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
OverTheBox Web UI
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
