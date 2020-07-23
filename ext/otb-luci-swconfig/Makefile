include $(TOPDIR)/rules.mk

PKG_NAME:=otb-luci-swconfig
PKG_VERSION:=0.1
PKG_RELEASE:=0

PKG_LICENSE:=GPLv3

include $(INCLUDE_DIR)/package.mk

MY_DEPENDS := otb-luci

define Package/$(PKG_NAME)
SECTION:=OVH
CATEGORY:=OverTheBox
DEPENDS:=$(foreach p,$(MY_DEPENDS),+$(p))
TITLE:=$(PKG_NAME)
PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
OverTheBox switch config in LuCI
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
