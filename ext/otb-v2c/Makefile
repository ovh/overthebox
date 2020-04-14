include $(TOPDIR)/rules.mk

PKG_NAME:=otb-v2c
PKG_VERSION:=0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
SECTION:=OVH
CATEGORY:=OverTheBox
TITLE:=$(PKG_NAME)
DEPENDS:=+kmod-leds-apu2
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
