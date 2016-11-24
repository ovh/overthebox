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
  KCONFIG:=
  FILES:=$(PKG_BUILD_DIR)/r8723bs.ko
  AUTOLOAD:=$(call AutoLoad,50,mac80211 r8723bs)
endef

EXTRA_CFLAGS += \
	-DCONFIG_TRAFFIC_PROTECT \
	-DCONFIG_LOAD_PHY_PARA_FROM_FILE

PKG_EXTRA_KCONFIG:= \
        CONFIG_RTL8723BS=m

PKG_EXTRA_CFLAGS:= \
        $(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=m,%,$(filter %=m,$(PKG_EXTRA_KCONFIG)))) \
        $(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=y,%,$(filter %=y,$(PKG_EXTRA_KCONFIG)))) \
        $(if $(CONFIG_LEDS_TRIGGERS), -DCONFIG_MAC80211_LEDS -DCONFIG_LEDS_TRIGGERS) \
        $(if $(CONFIG_PACKAGE_MAC80211_DEBUGFS), -DCONFIG_CFG80211_DEBUGFS -DCONFIG_MAC80211_DEBUGFS) \
        $(if $(CONFIG_PACKAGE_MAC80211_MESH), -DCONFIG_MAC80211_MESH) \
        -DBACKPORTED_KERNEL_NAME=\\\"$(PKG_SOURCE)\\\" \
        -DBACKPORTED_KERNEL_VERSION=\\\"$(PKG_SOURCE_VERSION)\\\" \
        -DBACKPORTS_VERSION=\\\"unknown\\\" \

define KernelPackage/rtl8723bs/config
	menu "Configuration"
		depends on PACKAGE_kmod-rtl8723bs

	config TRAFFIC_PROTECT
		bool "CONFIG_TRAFFIC_PROTECT"
		default y
		help
		  CONFIG_TRAFFIC_PROTECT

	config LOAD_PHY_PARA_FROM_FILE
		bool "LOAD_PHY_PARA_FROM_FILE"
		default y
		help	
		  CONFIG_LOAD_PHY_PARA_FROM_FILE

	config HW_PWRP_DETECTION
		bool "HW_PWRP_DETECTION"
		help
		  CONFIG_HW_PWRP_DETECTION

	config INTEL_WIDI
		bool "INTEL_WIDI"
		help
		  CONFIG_INTEL_WIDI

	config EXT_CLK
		bool "CONFIG_EXT_CLK"
		help
		   CONFIG_EXT_CLK

	config CALIBRATE_TX_POWER_BY_REGULATORY
		bool "CONFIG_CALIBRATE_TX_POWER_BY_REGULATORY"
		default y
		help
		   CONFIG_CALIBRATE_TX_POWER_BY_REGULATORY

	config CALIBRATE_TX_POWER_TO_MAX
		bool "CONFIG_CALIBRATE_TX_POWER_TO_MAX"
		help
		  CONFIG_CALIBRATE_TX_POWER_TO_MAX

	config ODM_ADAPTIVITY
		bool "CONFIG_ODM_ADAPTIVITY"
		help
		  CONFIG_ODM_ADAPTIVITY

	config SKIP_SIGNAL_SCALE_MAPPING
		bool "CONFIG_SKIP_SIGNAL_SCALE_MAPPING"
		help
		  CONFIG_SKIP_SIGNAL_SCALE_MAPPING

	config GPIO_WAKEUP
		bool "CONFIG_GPIO_WAKEUP"
		help
		  CONFIG_GPIO_WAKEUP

	config PNO_SUPPORT
		bool "CONFIG_PNO_SUPPORT"
		help
		  CONFIG_PNO_SUPPORT

	config PNO_SET_DEBUG
		bool "CONFIG_PNO_SET_DEBUG"
		depends on PNO_SUPPORT
		help
		   CONFIG_PNO_SET_DEBUG

	config WOWLAN
		bool "CONFIG_WOWLAN"
		help
		   CONFIG_WOWLAN

	config CONFIG_AP_WOWLAN
		bool "CONFIG_AP_WOWLAN"
		help
		   CONFIG_AP_WOWLAN

	endmenu
endef


define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		$(PKG_EXTRA_KCONFIG) \
		EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS)" \
                LINUXINCLUDE="-I$(PKG_BUILD_DIR)/ -I$(PKG_BUILD_DIR)/include -I$(PKG_BUILD_DIR)/hal -I$(STAGING_DIR)/usr/include/mac80211-backport/uapi -I$(STAGING_DIR)/usr/include/mac80211-backport \
                        -I$(STAGING_DIR)/usr/include/mac80211/uapi -I$(STAGING_DIR)/usr/include/mac80211 \
                        -I$(LINUX_DIR)/include -I$(LINUX_DIR)/include/$(LINUX_UAPI_DIR) \
                        -I$(LINUX_DIR)/include/generated/uapi/ -Iarch/$(LINUX_KARCH)/include \
                        -Iarch/$(LINUX_KARCH)/include/$(LINUX_UAPI_DIR) \
                        -Iarch/$(LINUX_KARCH)/include/generated \
                        -Iarch/$(LINUX_KARCH)/include/generated/$(LINUX_UAPI_DIR) \
                        -include generated/autoconf.h \
                        -include backport/backport.h " \
                V="$(V)" \
		modules
endef

define KernelPackage/rtl8723bs/install
	$(INSTALL_DIR) $(1)/lib/firmware
	$(INSTALL_DIR) $(1)/lib/firmware/rtlwifi
	$(CP) $(PKG_BUILD_DIR)/rtl8723bs_nic.bin $(1)/lib/firmware/rtlwifi/
	$(CP) $(PKG_BUILD_DIR)/rtl8723bs_wowlan.bin $(1)/lib/firmware/rtlwifi/
endef

$(eval $(call KernelPackage,rtl8723bs))
