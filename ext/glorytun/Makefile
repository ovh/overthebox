include $(TOPDIR)/rules.mk

PKG_NAME:=glorytun
PKG_VERSION:=0.3.4
PKG_RELEASE:=0
PKG_SOURCE:=glorytun-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/angt/glorytun/releases/download/v$(PKG_VERSION)
PKG_HASH:=137d9c525a05bb605163df0465367d36e943715ca773ce43d5ea66f0597600a3
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/glorytun
SECTION:=net
CATEGORY:=Network
DEPENDS:=+kmod-tun +libsodium +librt
TITLE:=Glorytun
URL:=https://github.com/angt/glorytun
SUBMENU:=VPN
endef

define Package/glorytun/description
Glorytun is a vpn designed to improve your internet connectivity:
 - Fast and highly secure.
 - Multipath and active failover.
 - Traffic shaping.
 - Path MTU discovery without ICMP.
endef

define Package/glorytun/conffiles
/etc/config/glorytun
endef

define Package/glorytun/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/glorytun $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) init $(1)/etc/init.d/glorytun
	$(INSTALL_DIR) $(1)/etc/config
	touch $(1)/etc/config/glorytun
endef

$(eval $(call BuildPackage,glorytun))
