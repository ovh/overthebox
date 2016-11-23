#
# Copyright (C) 2014-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8723bs
PKG_VERSION:=20161123
PKG_RELEASE=1

PKG_SOURCE_URL:=https://github.com/hadess/rtl8723bs
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=b3def82d8cbd0e7011bfaa6b70cd74725863e833
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz

PKG_MAINTAINER:=DUPONCHEEL Sébastien <sebastien.duponcheel@corp.ovh.com>
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8723bs
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek rtl8723bs SDIO Wi-Fi driver
  DEPENDS:=+kmod-mac80211 +@DRIVER_11N_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/r8723bs.ko
  AUTOLOAD:=$(call AutoLoad,50,mac80211 r8723bs)
endef

NOSTDINC_FLAGS = \
	-I$(PKG_BUILD_DIR) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-include backport/backport.h

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS) -DCONFIG_RTL8723BS=m" \
		modules
endef

define KernelPackage/rtl8723bs/install
	$(INSTALL_DIR) $(1)/lib/firmware
	$(INSTALL_DIR) $(1)/lib/firmware/rtlwifi
	$(CP) $(PKG_BUILD_DIR)/rtl8723bs_nic.bin $(1)/lib/firmware/rtlwifi/
	$(CP) $(PKG_BUILD_DIR)/rtl8723bs_wowlan.bin $(1)/lib/firmware/rtlwifi/
endef

$(eval $(call KernelPackage,rtl8723bs))
