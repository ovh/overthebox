include $(TOPDIR)/rules.mk

PKG_NAME:=otb-v2b
PKG_VERSION:=0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
SECTION:=OVH
CATEGORY:=OverTheBox
TITLE:=$(PKG_NAME)
DEPENDS:=+python-swconfig-otb
KCONFIG:=\
    CONFIG_KEYBOARD_GPIO=y \
    CONFIG_PINCTRL_CHERRYVIEW=y \
    CONFIG_INPUT_SOC_BUTTON_ARRAY=y
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
