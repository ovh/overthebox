include $(TOPDIR)/rules.mk

PKG_NAME:=otb-luci
PKG_VERSION:=0.3
PKG_RELEASE:=0

PKG_LICENSE:=GPLv3

include $(INCLUDE_DIR)/package.mk

MY_DEPENDS := \
    lua liblua libuci-lua libubus-lua uhttpd rpcd \
    luci luci-ssl luci-base \
    luci-lib-jsonc luci-lib-ip luci-lib-nixio \
    luci-mod-admin-full luci-app-firewall \
    luci-proto-3g luci-theme-material

define Package/$(PKG_NAME)
SECTION:=OVH
CATEGORY:=OverTheBox
DEPENDS:=$(foreach p,$(MY_DEPENDS),+$(p))
TITLE:=$(PKG_NAME)
PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
OverTheBox LuCI
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
