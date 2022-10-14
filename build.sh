#!/bin/sh

set -e

umask 0022
unset GREP_OPTIONS SED

OTB_ARCH=${OTB_ARCH:-x86_64}
OTB_CONFIG=${OTB_CONFIG:-net-full nice-bb usb-full legacy}
OTB_PKGS=${OTB_PKGS:-vim-full netcat htop iputils-ping bmon bwm-ng screen mtr ss strace tcpdump-mini ethtool sysstat pciutils mini_snmpd dmesg nano fuse-utils gdb rsync}

# Optionnal package
OTB_PKGS_M="prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic
prometheus-node-exporter-lua-netstat prometheus-node-exporter-lua-openwrt
prometheus-node-exporter-lua-textfile prometheus-node-exporter-lua-wifi
prometheus-node-exporter-lua-wifi_stations"

for i in $OTB_ARCH $OTB_CONFIG; do
	if [ ! -f "config/$i" ]; then
		echo "Config $i not found !"
		exit 1
	fi
done

# Fetch submodule
git submodule sync
git submodule update --init --recursive --remote

echo "submodule status :\n$(git submodule status)"

# CONFIG_VERSION parameters
OTB_VERSION_SYSTEM=${OTB_VERSION_SYSTEM:=$(git describe --tag --always)}
OTB_VERSION_FEEDS=${OTB_VERSION_FEEDS:=$(git -C feeds/overthebox describe --tag --always)}
OTB_VERSION_OPENWRT=${OTB_VERSION_OPENWRT:=$(git -C openwrt describe --tag --always)}
OTB_VERSION_REPO=${OTB_REPO:-http://downloads.overthebox.net/}
OTB_VERSION_DIST=${OTB_VERSION_DIST:-OverTheBox}
OTB_VERSION_HOME_URL=${OTB_VERSION_HOME_URL:-https://github.com/ovh/overthebox}
OTB_VERSION_BUG_URL=${OTB_VERSION_BUG_URL:-https://github.com/ovh/overthebox/issue}
OTB_VERSION_SUPPORT_URL=${OTB_VERSION_SUPPORT_URL:-https://community.ovh.com/c/telecom/overthebox}
OTB_VERSION_MANUFACTURER=${OTB_VERSION_MANUFACTURER:-OVHcloud}
OTB_VERSION_MANUFACTURER_URL=${OTB_VERSION_MANUFACTURER_URL:-https://ovhcloud.com/}

# KERNEL_BUILD parameters
OTB_KERNEL_BUILD_DOMAIN=${OTB_KERNEL_BUILD_DOMAIN:-https://ovh.github.io/cds/}
OTB_KERNEL_BUILD_USER=${OTB_KERNEL_BUILD_USER:-cds}

rm -rf openwrt/bin openwrt/files openwrt/tmp
cp -rf root openwrt/files

cat >> openwrt/files/etc/banner <<EOF
-----------------------------------------------------
 VERSION SYSTEM: $OTB_VERSION_SYSTEM
 VERSION FEEDS:  $OTB_VERSION_FEEDS
 VERSION OPENWRT: $OTB_VERSION_OPENWRT

 BUILD REPO:  $OTB_VERSION_HOME_URL
 BUILD DATE:  $(date -u)
-----------------------------------------------------
EOF

cat > openwrt/feeds.conf <<EOF
src-link packages $(readlink -f feeds/packages)
src-link luci $(readlink -f feeds/luci)
src-link routing $(readlink -f feeds/routing)
src-link overthebox $(readlink -f feeds/overthebox)
EOF


cat > openwrt/.config <<EOF
$(for i in $OTB_ARCH $OTB_CONFIG; do cat "config/$i"; done)
CONFIG_VERSION_DIST="$OTB_VERSION_DIST"
CONFIG_VERSION_REPO="$OTB_VERSION_REPO"
CONFIG_VERSION_NUMBER="$OTB_VERSION_SYSTEM"
CONFIG_VERSION_CODE="$OTB_VERSION_FEEDS"
CONFIG_VERSION_HOME_URL="$OTB_VERSION_HOME_URL"
CONFIG_VERSION_BUG_URL="$OTB_VERSION_BUG_URL"
CONFIG_VERSION_SUPPORT_URL="$OTB_VERSION_SUPPORT_URL"
CONFIG_VERSION_MANUFACTURER_URL="$OTB_VERSION_MANUFACTURER_URL"
CONFIG_VERSION_MANUFACTURER="$OTB_VERSION_MANUFACTURER"
CONFIG_KERNEL_BUILD_DOMAIN="$OTB_KERNEL_BUILD_DOMAIN"
CONFIG_KERNEL_BUILD_USER="$OTB_KERNEL_BUILD_USER"
$(for i in otb $OTB_PKGS; do echo "CONFIG_PACKAGE_$i=y"; done)
$(for i in $OTB_PKGS_M; do echo "CONFIG_PACKAGE_$i=m"; done)
EOF

echo "Building for arch $OTB_ARCH"

cd openwrt

cp .config .config.keep
scripts/feeds clean
scripts/feeds update -a
scripts/feeds install -a -d y -f -p overthebox
# shellcheck disable=SC2086
scripts/feeds install -d y $OTB_PKGS
scripts/feeds install -d m $OTB_PKGS_M
cp .config.keep .config

make defconfig
if ! make "$@"; then
    make "$@" -j1 V=s 2>&1 | tee error.log
    exit 1
fi
