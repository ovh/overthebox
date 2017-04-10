#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define KernelPackage/rdc321x-wdt
  SUBMENU:=$(OTHER_MENU)
  TITLE:=RDC321x watchdog
  DEPENDS:=@TARGET_x86_rdc
  KCONFIG:=CONFIG_RDC321X_WDT
  FILES:=$(LINUX_DIR)/drivers/$(WATCHDOG_DIR)/rdc321x_wdt.ko
  AUTOLOAD:=$(call AutoLoad,50,rdc321x_wdt)
endef

define KernelPackage/rdc321x-wdt/description
  RDC-321x watchdog driver
endef

$(eval $(call KernelPackage,rdc321x-wdt))

define KernelPackage/sound-soc-intel-sst
  TITLE:=Intel SoC Codec support
  DEPENDS:=@TARGET_x86_overthebox +kmod-sound-core +kmod-sound-soc-core +sound-soc-intel-sst-firmware
  KCONFIG:=\
	CONFIG_SND_SOC_INTEL_SST \
	CONFIG_SND_SOC_INTEL_SST_ACPI \
	CONFIG_SND_SST_IPC \
	CONFIG_SND_SST_IPC_ACPI \
	CONFIG_SND_SST_MFLD_PLATFORM \
	CONFIG_SND_SOC_INTEL_HASWELL \
	CONFIG_SND_SOC_INTEL_BAYTRAIL \
	CONFIG_SND_SOC_INTEL_HASWELL_MACH \
	CONFIG_SND_SOC_MAX98090 \
	CONFIG_SND_SOC_INTEL_BYT_MAX98090_MACH \
	CONFIG_SND_SOC_RT5640 \
	CONFIG_SND_SOC_INTEL_BYT_RT5640_MACH \
	CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH \
	CONFIG_SND_SOC_RT5670 \
	CONFIG_SND_SOC_INTEL_CHT_BSW_RT5672_MACH \
	CONFIG_SND_SOC_RT5645 \
	CONFIG_SND_SOC_INTEL_CHT_BSW_RT5645_MACH
  FILES:= \
	$(LINUX_DIR)/sound/soc/intel/common/snd-soc-sst-acpi.ko \
	$(LINUX_DIR)/sound/soc/intel/common/snd-soc-sst-dsp.ko \
	$(LINUX_DIR)/sound/soc/intel/common/snd-soc-sst-ipc.ko \
	$(LINUX_DIR)/sound/soc/intel/atom/sst/snd-intel-sst-core.ko \
	$(LINUX_DIR)/sound/soc/intel/atom/sst/snd-intel-sst-acpi.ko \
	$(LINUX_DIR)/sound/soc/intel/atom/snd-soc-sst-mfld-platform.ko \
	$(LINUX_DIR)/sound/soc/intel/baytrail/snd-soc-sst-baytrail-pcm.ko \
	$(LINUX_DIR)/sound/soc/intel/haswell/snd-soc-sst-haswell-pcm.ko \
	$(LINUX_DIR)/sound/soc/intel/boards/snd-soc-sst-haswell.ko \
	$(LINUX_DIR)/sound/soc/codecs/snd-soc-rt5640.ko \
	$(LINUX_DIR)/sound/soc/intel/boards/snd-soc-sst-byt-rt5640-mach.ko \
	$(LINUX_DIR)/sound/soc/codecs/snd-soc-max98090.ko \
	$(LINUX_DIR)/sound/soc/intel/boards/snd-soc-sst-byt-max98090-mach.ko \
	$(LINUX_DIR)/sound/soc/codecs/snd-soc-rt5645.ko \
	$(LINUX_DIR)/sound/soc/intel/boards/snd-soc-sst-cht-bsw-rt5645.ko \
	$(LINUX_DIR)/sound/soc/codecs/snd-soc-rt5670.ko \
	$(LINUX_DIR)/sound/soc/codecs/snd-soc-rl6231.ko \
	$(LINUX_DIR)/sound/soc/intel/boards/snd-soc-sst-cht-bsw-rt5672.ko
  AUTOLOAD:=$(call AutoLoad,58,snd-soc-core snd-soc-max9809 snd-soc-rl6231 snd-soc-rt5640 snd-soc-rt5645 snd-soc-rt5670 snd-soc-sst-dsp snd-soc-sst-ipc snd-soc-sst-acpi snd-soc-sst-haswell-pcm snd-soc-sst-baytrail-pcm snd-soc-sst-mfld-platform snd-intel-sst-core snd-intel-sst-acpi snd-soc-sst-haswell snd-soc-sst-byt-rt5640-mach snd-soc-sst-byt-max98090-mach snd-soc-sst-bytcr-rt5640 snd-soc-sst-cht-bsw-rt5672 snd-soc-sst-cht-bsw-rt5645)
  $(call AddDepends/sound)
endef

$(eval $(call KernelPackage,sound-soc-intel-sst))

define KernelPackage/sound-soc-intel-hda
  TITLE:=Intel HDA SoC support
  DEPENDS:=@TARGET_x86_overthebox +sound-soc-intel-sst
  KCONFIG:=\
	CONFIG_SND_HDA_GENERIC \
	CONFIG_SND_HDA_INTEL \
	CONFIG_SND_HDA_CODEC_REALTEK \
	CONFIG_SND_HDA_CODEC_HDMI
  FILES:= \
	$(LINUX_DIR)/sound/hda/snd-hda-core.ko \
	$(LINUX_DIR)/sound/pci/hda/snd-hda-codec.ko \
	$(LINUX_DIR)/sound/pci/hda/snd-hda-controller.ko \
	$(LINUX_DIR)/sound/pci/hda/snd-hda-codec-generic.ko \
	$(LINUX_DIR)/sound/pci/hda/snd-hda-codec-realtek.ko \
	$(LINUX_DIR)/sound/pci/hda/snd-hda-codec-hdmi.ko \
	$(LINUX_DIR)/sound/pci/hda/snd-hda-intel.ko
  AUTOLOAD:=$(call AutoLoad,59,snd-hda-core snd-hda-codec snd-hda-controller snd-hda-codec-generic snd-hda-codec-realtek snd-hda-codec-hdmi snd-hda-intel)
  $(call AddDepends/sound)
endef


define KernelPackage/sound-soc-intel-hda/config
	menu "Configuration"
		depends on PACKAGE_kmod-sound-soc-intel-hda

	config KERNEL_SND_HDA_HWDEP
		bool "SND_HDA_HWDEP"
		default y
		help
		   CONFIG_SND_HDA_HWDEP

	config KERNEL_SND_HDA_INPUT_BEEP
		bool "SND_HDA_INPUT_BEEP"
		default y
		help
		   SND_HDA_INPUT_BEEP

	config KERNEL_SND_HDA_INPUT_BEEP_MODE
		int "SND_HDA_INPUT_BEEP_MODE 0=off 1=on"
		default 1
		help
		   CONFIG_SND_HDA_INPUT_BEEP_MODE

	config KERNEL_SND_HDA_PREALLOC_SIZE
		int "CONFIG_SND_HDA_PREALLOC_SIZE"
		default 64
		help
		   CONFIG_EXT_CLK

	config KERNEL_SND_HDA_CODEC_ANALOG
		bool "SND_HDA_CODEC_ANALOG"
		default n
		help
		  CONFIG_SND_HDA_CODEC_ANALOG

	config KERNEL_SND_HDA_RECONFIG
		bool "SND_HDA_RECONFIG"
		default y
		help
		   CONFIG_SND_HDA_RECONFIG

	config KERNEL_SND_HDA_INPUT_JACK
                bool "SND_HDA_INPUT_JACK"
                default y
                help
                   CONFIG_SND_HDA_INPUT_JACK

	config KERNEL_SND_HDA_PATCH_LOADER
                bool "SND_HDA_PATCH_LOADER"
                default y
                help
                   CONFIG_SND_HDA_PATCH_LOADER

	config KERNEL_SND_HDA_CODEC_SIGMATEL
		bool "CONFIG_SND_HDA_CODEC_SIGMATEL"
		default n
		help
		   CONFIG_SND_HDA_CODEC_SIGMATEL

	config KERNEL_SND_HDA_CODEC_VIA
                bool "CONFIG_SND_HDA_CODEC_VIA"
                default n
                help
                   CONFIG_SND_HDA_CODEC_VIA

	config KERNEL_SND_HDA_CODEC_CIRRUS
                bool "CONFIG_SND_HDA_CODEC_CIRRUS"
                default n
                help
                   CONFIG_SND_HDA_CODEC_CIRRUS

	config KERNEL_SND_HDA_CODEC_CONEXANT
                bool "CONFIG_SND_HDA_CODEC_CONEXANT"
                default n
                help
                   CONFIG_SND_HDA_CODEC_CONEXANT

	config KERNEL_SND_HDA_CODEC_CA0110
                bool "CONFIG_SND_HDA_CODEC_CA0110"
                default n
                help
                   CONFIG_SND_HDA_CODEC_CA0110

        config KERNEL_SND_HDA_CODEC_CA0132
                bool "CONFIG_SND_HDA_CODEC_CA0132"
                default n
                help
                   CONFIG_SND_HDA_CODEC_CA0132

	config KERNEL_SND_HDA_CODEC_CMEDIA
                bool "CONFIG_SND_HDA_CODEC_CMEDIA"
                default n
                help
                   CONFIG_SND_HDA_CODEC_CMEDIA

	config KERNEL_SND_HDA_CODEC_SI3054
                bool "CONFIG_SND_HDA_CODEC_SI3054"
                default n
                help
                   CONFIG_SND_HDA_CODEC_SI3054

	endmenu
endef

$(eval $(call KernelPackage,sound-soc-intel-hda))
