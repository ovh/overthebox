include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=cherrytrail-gpio-powerbutton
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
TITLE:=Cherrytrail power button support
DEPENDS:=@GPIO_SUPPORT @TARGET_x86
FILES:=$(PKG_BUILD_DIR)/$(PKG_NAME).ko
AUTOLOAD:=$(call AutoProbe,$(PKG_NAME))
endef

MAKE_OPTS:= \
    ARCH="$(LINUX_KARCH)" \
    CROSS_COMPILE="$(TARGET_CROSS)" \
    SUBDIRS="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" $(MAKE_OPTS) modules
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
