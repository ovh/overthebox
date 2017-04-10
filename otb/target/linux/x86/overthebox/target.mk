ARCH:=x86_64
BOARDNAME:=OverTheBox
DEFAULT_PACKAGES += kmod-button-hotplug kmod-e1000e kmod-e1000 kmod-r8169
ARCH_PACKAGES:=x86_64
MAINTAINER:=Imre Kaloz <kaloz@openwrt.org>
CPU_TYPE := silvermont
CPU_CFLAGS_silvermont := -march=silvermont -mtune=silvermont

define Target/Description
        Build images for OverTheBox v1 and v2
endef
