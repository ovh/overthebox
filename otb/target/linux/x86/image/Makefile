# 
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

export PATH=$(TARGET_PATH):/sbin

GRUB2_MODULES = biosdisk boot chain configfile ext2 linux ls part_gpt part_msdos fat exfat ext2 reboot serial vga search search_fs_uuid search_label
GRUB2_MODULES_ISO = biosdisk boot chain configfile iso9660 linux ls part_msdos reboot serial vga
GRUB2_MODULES_EFI = part_gpt part_msdos search search_fs_uuid search_label fat exfat ext2 boot chain configfile iso9660 linux ls reboot serial efi_uga efi_gop gfxterm blocklist 
GRUB_TERMINALS =
GRUB_SERIAL_CONFIG =
GRUB_TERMINAL_CONFIG =
GRUB_CONSOLE_CMDLINE =

USE_ATKBD = generic kvm_guest

ifneq ($(strip $(foreach subtarget,$(USE_ATKBD),$(CONFIG_TARGET_x86_$(subtarget)))),)
  GRUB2_MODULES += at_keyboard
  GRUB2_MODULES_ISO += at_keyboard
endif

ifneq ($(CONFIG_GRUB_CONSOLE),)
  GRUB_CONSOLE_CMDLINE += console=tty0
  GRUB_TERMINALS += console
endif

GRUB_SERIAL:=$(call qstrip,$(CONFIG_GRUB_SERIAL))

ifneq ($(GRUB_SERIAL),)
  GRUB_CONSOLE_CMDLINE += console=$(GRUB_SERIAL),$(CONFIG_GRUB_BAUDRATE)n8
  GRUB_SERIAL_CONFIG := serial --unit=0 --speed=$(CONFIG_GRUB_BAUDRATE) --word=8 --parity=no --stop=1 --rtscts=off
  GRUB_TERMINALS += serial
endif

ifneq ($(GRUB_TERMINALS),)
  GRUB_TERMINAL_CONFIG := terminal_input $(GRUB_TERMINALS); terminal_output $(GRUB_TERMINALS)
endif

SIGNATURE:=$(shell dd if=/dev/urandom bs=4 count=1 2>/dev/null | hexdump -v -e '"%08x"')

ROOTPART:=$(call qstrip,$(CONFIG_TARGET_ROOTFS_PARTNAME))
ROOTPART:=$(if $(ROOTPART),$(ROOTPART),PARTUUID=$(SIGNATURE)-02)
EFI_ROOTPART:=$(strip $(shell uuidgen | sed "s/[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]$$/0002/" | tr '[a-z]' '[A-Z]'))

GRUB_TIMEOUT:=$(call qstrip,$(CONFIG_GRUB_TIMEOUT))

ifneq ($(CONFIG_GRUB_IMAGES),)

  BOOTOPTS:=$(call qstrip,$(CONFIG_GRUB_BOOTOPTS))

  define Image/cmdline/ext4
    root=$(ROOTPART) rootfstype=ext4 rootwait
  endef

  define Image/cmdline/rescue
    root=/dev/sda2 rootfstype=ext4 rootwait
  endef

  define Image/cmdline/jffs2-64k
    block2mtd.block2mtd=$(ROOTPART),65536,rootfs,5 root=/dev/mtdblock0 rootfstype=jffs2 rootwait
  endef

  define Image/cmdline/jffs2-128k
    block2mtd.block2mtd=$(ROOTPART),131072,rootfs,5 root=/dev/mtdblock0 rootfstype=jffs2 rootwait
  endef

  define Image/cmdline/squashfs
    block2mtd.block2mtd=$(ROOTPART),65536,rootfs,5 root=/dev/mtdblock0 rootfstype=squashfs rootwait
  endef

  define Image/cmdline/efi
    $(subst $(SIGNATURE)-02,$2,$(call Image/cmdline/$(1)))
  endef

ifneq ($(CONFIG_EFI_IMAGES),)
  define Image/Build/efi
	# left here because the image builder doesnt need these
	rm -rf $(KDIR)/root.grub/ || true
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	echo '(hd0) $(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img' > $(KDIR)/grub2/device.map
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#$(strip $(call Image/cmdline/efi,$(1),$(EFI_ROOTPART)) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#set root.*#search --file /boot/grub/$(SIGNATURE).cfg --set=root#g' \
		./grub.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	$(CP) $(KDIR)/root.grub/boot/grub/grub.cfg $(KDIR)/root.grub/boot/grub/$(SIGNATURE).cfg
	grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/core.img \
		-O i386-pc \
		-p '(hd0,gpt1)/boot/grub' \
		-c $(KDIR)/root.grub/boot/grub/grub.cfg \
		$(GRUB2_MODULES)
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img $(KDIR)/grub2/
	PADDING="$(CONFIG_TARGET_IMAGES_PAD)" SIGNATURE="$(SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_generic.sh \
		$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $(KDIR)/root.grub \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(KDIR)/root.$(1) \
		256
	# Setup grub
	grub-bios-setup \
		--device-map="$(KDIR)/grub2/device.map" \
		-d "$(KDIR)/grub2" \
		-r "hd0,msdos1" \
		"$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
	# Build the efi grub version
	rm -rf $(KDIR)/grub2.efi/ || true
	$(INSTALL_DIR) $(KDIR)/grub2.efi/efi/boot/
	# Setup EFI Grub
	echo "search --file /boot/grub/$(SIGNATURE).cfg --set=root" > $(KDIR)/grub2.efi/efi/boot/grub.cfg
	echo "configfile /boot/grub/grub.cfg" >> $(KDIR)/grub2.efi/efi/boot/grub.cfg
	#
	grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/x86_64-efi \
		-o $(KDIR)/grub2.efi/efi/boot/bootx64.efi \
		-O x86_64-efi \
		-p /efi/boot \
		-c $(KDIR)/grub2.efi/efi/boot/grub.cfg \
		$(GRUB2_MODULES_EFI)
	# Create EFI vfat image
	rm $(KDIR)/kernel.efi || true
	mkfs.fat -C $(KDIR)/kernel.efi -S 512 $(shell echo $$(( $(CONFIG_TARGET_KERNEL_PARTSIZE) * 1024 )))
	mcopy -s -i "$(KDIR)/kernel.efi" $(KDIR)/grub2.efi/* ::/
	# Append EFI boot image to MBR grub image
	dd if="$(KDIR)/kernel.efi" bs=512 conv=notrunc >> "$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
	# Add 33 block for GPT
	dd if="/dev/zero" bs=512 count=33 conv=notrunc >> "$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
	# Set the new EFI partition (data are already present on image) and change PARTUUID od root partition
	(echo n; echo 3; echo ; echo ; echo EF00; echo x; echo c; echo 2; echo $(EFI_ROOTPART); echo w; echo Y) | gdisk "$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
	# Add GPT Grub partition for legacy bios
	dd if=/dev/zero bs=512 count=2048 conv=notrunc >> "$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
	(echo x; echo e; echo m; echo n; echo 4; echo ; echo ; echo EF02; echo w; echo Y; echo Y) | gdisk "$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
	grub-bios-setup \
		--device-map="$(KDIR)/grub2/device.map" \
		-d "$(KDIR)/grub2" \
		-r "hd0,gpt1" \
		"$(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img"
  endef
endif

  define Image/Build/grub2
	# left here because the image builder doesnt need these
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/core.img \
		-O i386-pc \
		-c ./grub-early.cfg \
		$(GRUB2_MODULES)
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img $(KDIR)/grub2/
	echo '(hd0) $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img' > $(KDIR)/grub2/device.map
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#$(strip $(call Image/cmdline/$(1)) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		./grub.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	PADDING="$(CONFIG_TARGET_IMAGES_PAD)" SIGNATURE="$(SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_generic.sh \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $(KDIR)/root.grub \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(KDIR)/root.$(1) \
		256
	grub-bios-setup \
		--device-map="$(KDIR)/grub2/device.map" \
		-d "$(KDIR)/grub2" \
		-r "hd0,msdos1" \
		"$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img"
	$(call Image/Build/grub/$(1))
  endef
endif

ROOTDELAY=10

define Image/Build/squashfs
	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
endef

define Image/Build/iso
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/eltorito.img \
		-O i386-pc \
		-c ./grub-early.cfg \
		$(GRUB2_MODULES_ISO)
	cat \
		$(STAGING_DIR_HOST)/lib/grub/i386-pc/cdboot.img \
		$(KDIR)/grub2/eltorito.img \
		> $(KDIR)/root.grub/boot/grub/eltorito.img
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#root=/dev/sr0 rootfstype=iso9660 rootwait $(strip $(call Image/cmdline/$(1)) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		./grub-iso.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	mkisofs -R -b boot/grub/eltorito.img -no-emul-boot -boot-info-table \
		-o $(KDIR)/root.iso $(KDIR)/root.grub $(TARGET_DIR)
endef

ifneq ($(CONFIG_VDI_IMAGES),)
  define Image/Build/vdi
	rm $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vdi || true
	qemu-img convert -f raw -O vdi \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vdi
	# XXX: VBoxManage insists on setting perms to 0600
	chmod 0644 $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vdi
  endef
endif

ifneq ($(CONFIG_VMDK_IMAGES),)
  define Image/Build/vmdk
	rm $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vmdk || true
	qemu-img convert -f raw -O vmdk \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vmdk
  endef
endif

define Image/Build/gzip
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-rootfs-$(1).img
endef

define Image/Build/embedded
	# Copy the base rootfs in a new file
	$(CP) $(KDIR)/root.$(1) $(KDIR)/root.embedded.$(1)
	# Generate debugfs command file
	echo "mkdir /recovery" > embed_recovery.cmd
	echo "cd /recovery" >> embed_recovery.cmd
	echo "write $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img.gz $(IMG_PREFIX)-combined-$(1).img.gz" >> embed_recovery.cmd
	debugfs -w -f embed_recovery.cmd $(KDIR)/root.embedded.$(1)
	rm embed_recovery.cmd
	# Generate the new image using embedded roofs
	# left here because the image builder doesnt need these
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/core.img \
		-O i386-pc \
		-c ./grub-early.cfg \
		$(GRUB2_MODULES)
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img $(KDIR)/grub2/
	echo '(hd0) $(BIN_DIR)/$(IMG_PREFIX)-embedded-$(1).img' > $(KDIR)/grub2/device.map
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#$(strip $(call Image/cmdline/$(1)) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		./grub.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	PADDING="$(CONFIG_TARGET_IMAGES_PAD)" SIGNATURE="$(SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_generic.sh \
		$(BIN_DIR)/$(IMG_PREFIX)-embedded-$(1).img \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $(KDIR)/root.grub \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(KDIR)/root.embedded.$(1) \
		256
	grub-bios-setup \
		--device-map="$(KDIR)/grub2/device.map" \
		-d "$(KDIR)/grub2" \
		-r "hd0,msdos1" \
		"$(BIN_DIR)/$(IMG_PREFIX)-embedded-$(1).img"
	$(call Image/Build/grub/$(1))
endef

define Image/Build/gzip_embedded
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-embedded-$(1).img
endef

define Image/Build/rescue
	# Copy the base rootfs in a new file
	$(CP) $(KDIR)/root.$(1) $(KDIR)/root.rescue-$(2).$(1)

	# Generate temp recovery cmd file to put in rescue fs
	echo "#!/bin/sh" > tmp.rc.local
	echo "/sbin/overthebox_usb_recovery" >> tmp.rc.local
	echo "exit 0;" >> tmp.rc.local 

	echo "#!/bin/sh" > tmp.otb_recue
	echo "if dmidecode | grep -ic DE3815TYKH; then" >> tmp.otb_recue
	echo "	echo -n 'Flashing firmware, please wait...'" >> tmp.otb_recue
	echo "	if gunzip -c /recovery/openwrt-x86-64-combined-$(2).img.gz | dd of=/dev/mmcblk0; then" >> tmp.otb_recue
	echo "		sync && echo 'done';" >> tmp.otb_recue
	echo "		halt;" >> tmp.otb_recue
	echo "		exit 0;" >> tmp.otb_recue
	echo "	fi" >> tmp.otb_recue
	echo "fi" >> tmp.otb_recue
	echo 'echo "NUC OTB not detected, Starting manual prompt"' >> tmp.otb_recue
	echo 'echo "Browse for your OTB img file and dd it to your desired device"' >> tmp.otb_recue
	echo 'echo "Example compressed img: gunzip -c /tmp/openwrt-x86-64-combined-$(2).img.gz | dd of=/dev/sdx"' >> tmp.otb_recue
	echo 'echo "Example non compressed: dd if=/tmp/openwrt-x86-64-combined-$(2).img of=/dev/sdx"' >> tmp.otb_recue
	echo 'echo "Be patient and do not interrupt, copying process may take a while"' >> tmp.otb_recue
	echo 'echo "Good Luck :-)"' >> tmp.otb_recue
	echo 'exit 1' >> tmp.otb_recue

	# Generate debugfs command file
	echo "mkdir /recovery" > rescue_recovery.cmd
	echo "cd /recovery" >> rescue_recovery.cmd
	echo "write $(BIN_DIR)/$(IMG_PREFIX)-combined-$(2).img.gz $(IMG_PREFIX)-combined-$(2).img.gz" >> rescue_recovery.cmd
	echo "unlink /etc/uci-defaults" >> rescue_recovery.cmd
	echo "cd /sbin" >> rescue_recovery.cmd
	echo "write tmp.otb_recue overthebox_usb_recovery" >> rescue_recovery.cmd
	echo "set_inode_field overthebox_usb_recovery mode 0100744" >> rescue_recovery.cmd
	echo "cd /etc" >> rescue_recovery.cmd
	echo "rm rc.local" >> rescue_recovery.cmd
	echo "write tmp.rc.local rc.local" >> rescue_recovery.cmd
	echo "set_inode_field rc.local mode 0100644" >> rescue_recovery.cmd
	debugfs -w -f rescue_recovery.cmd $(KDIR)/root.rescue-$(2).$(1)
	rm rescue_recovery.cmd
	rm tmp.otb_recue
	rm tmp.rc.local
	# Generate the new image using rescue roofs
	# left here because the image builder doesnt need these
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/core.img \
		-O i386-pc \
		-c ./grub-early.cfg \
		$(GRUB2_MODULES)
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img $(KDIR)/grub2/
	echo '(hd0) $(BIN_DIR)/$(IMG_PREFIX)-rescue-$(2).img' > $(KDIR)/grub2/device.map
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#$(strip $(call Image/cmdline/rescue) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#OpenWrt#OverTheBox USB live recue#g' \
		./grub.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	PADDING="$(CONFIG_TARGET_IMAGES_PAD)" SIGNATURE="$(SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_generic.sh \
		$(BIN_DIR)/$(IMG_PREFIX)-rescue-$(2).img \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $(KDIR)/root.grub \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(KDIR)/root.rescue-$(2).$(1) \
		256
	grub-bios-setup \
		--device-map="$(KDIR)/grub2/device.map" \
		-d "$(KDIR)/grub2" \
		-r "hd0,msdos1" \
		"$(BIN_DIR)/$(IMG_PREFIX)-rescue-$(2).img"
	$(call Image/Build/grub/$(1))
endef

define Image/Build/gzip_rescue
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-rescue-$(1).img
endef

define Image/Build/gzip_efi
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-uefi-gpt-$(1).img
endef

ifneq ($(CONFIG_TARGET_IMAGES_GZIP),)
  ifneq ($(CONFIG_TARGET_IMAGES_RESCUE),)
    define Image/Build/rescue/ext4
	$(call Image/Build/rescue,ext4,ext4)
	$(call Image/Build/gzip_rescue,ext4)
    endef
    define Image/Build/rescue/squashfs
	$(call Image/Build/rescue,ext4,squashfs)
	$(call Image/Build/gzip_rescue,squashfs)
    endef
  endif
  ifneq ($(CONFIG_TARGET_IMAGES_EMBEDDED),)
    define Image/Build/embedded/ext4
	$(call Image/Build/embedded,ext4)
	$(call Image/Build/gzip_embedded,ext4)
    endef
  endif
  define Image/Build/gzip/ext4
	$(call Image/Build/gzip,ext4)
	$(call Image/Build/embedded/ext4)
	$(call Image/Build/rescue/ext4)
  endef
  ifneq ($(CONFIG_TARGET_IMAGES_PAD),)
    define Image/Build/gzip/squashfs
	$(call Image/Build/gzip,squashfs)
	$(call Image/Build/rescue/squashfs)
    endef
    define Image/Build/gzip/jffs2-64k
	$(call Image/Build/gzip,jffs2-64k)
    endef
    define Image/Build/gzip/jffs2-128k
	$(call Image/Build/gzip,jffs2-128k)
    endef
  endif
endif

define Image/BuildKernel
	$(CP) $(KDIR)/bzImage $(BIN_DIR)/$(IMG_PREFIX)-vmlinuz
  ifneq ($(CONFIG_X86_ETHERBOOT_IMAGES),)
	rm -f $(BIN_DIR)/$(IMG_PREFIX)-etherboot
	$(STAGING_DIR_HOST)/bin/mkelfImage \
		--append=$(CONFIG_X86_ETHERBOOT_BOOTOPTS) \
		$(KDIR)/bzImage \
		$(BIN_DIR)/$(IMG_PREFIX)-etherboot
  endif
endef

define Image/Build/Profile/ar525w
	cp $(KDIR)/bzImage $(KDIR)/bzImage.tmp
	$(SCRIPT_DIR)/pad_image $(1) $(KDIR)/bzImage.tmp $(KDIR)/root.$(1) 32
	$(STAGING_DIR_HOST)/bin/airlink -b 1 $(KDIR)/bzImage.tmp $(KDIR)/root.$(1) \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-ar525w.img
	$(STAGING_DIR_HOST)/bin/airlink -e -b 1 $(KDIR)/bzImage.tmp $(KDIR)/root.$(1) \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-ar525w-web.img
endef

define Image/Build/Profile/sitecom
	cp $(KDIR)/bzImage $(KDIR)/bzImage.tmp
	#32k config data + 20 bytes header + 2 bytes checksum after kernel image
	$(SCRIPT_DIR)/pad_image $(1) $(KDIR)/bzImage.tmp $(KDIR)/root.$(1) 32790
	$(TOPDIR)/target/linux/rdc/image/mkimg_sitecom.pl $(KDIR)/bzImage.tmp > $(KDIR)/tmp.img
	cat $(KDIR)/root.$(1) >> $(KDIR)/tmp.img
	cp $(KDIR)/tmp.img $(BIN_DIR)/$(IMG_PREFIX)-$(1)-sitecom.img
	rm $(KDIR)/tmp.img $(KDIR)/bzImage.tmp
endef

define Image/Build/Profile/bifferboard
	$(TOPDIR)/target/linux/rdc/image/mkimg_bifferboard.py $(KDIR)/bzImage $(KDIR)/root.$(1) \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-bifferboard.img
endef

define Image/Prepare
	$(call Image/Prepare/grub2)
endef

define Image/Build/Initramfs
	$(CP) $(KDIR)/bzImage-initramfs $(BIN_DIR)/$(IMG_PREFIX)-ramfs.bzImage
endef

define Image/Build
	$(call Image/Build/$(1))
  ifneq ($(1),iso)
	$(call Image/Build/grub2,$(1))
	$(call Image/Build/efi,$(1))
	$(call Image/Build/vdi,$(1))
	$(call Image/Build/vmdk,$(1))
	$(CP) $(KDIR)/root.$(1) $(BIN_DIR)/$(IMG_PREFIX)-rootfs-$(1).img
  else
	$(CP) $(KDIR)/root.iso $(BIN_DIR)/$(IMG_PREFIX).iso
  endif
	$(CP) $(KDIR)/bzImage $(BIN_DIR)/$(IMG_PREFIX)-vmlinuz
	$(call Image/Build/gzip/$(1))
ifeq ($(CONFIG_EFI_IMAGES),y)
	$(call Image/Build/gzip_efi,$(1))
endif
	$(call Image/Build/Profile/$(PROFILE),$(1))
ifeq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),y)
	$(call Image/Build/Initramfs)
endif
endef

$(eval $(call BuildImage))
