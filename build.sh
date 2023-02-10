#!/bin/sh

set -e

umask 0022
unset GREP_OPTIONS SED

OTB_REPO=${OTB_REPO:-LOCAL}
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

# Get Version
OTB_VERSION=${OTB_VERSION:=$(git describe --tag --always)}
OTB_FEEDS_VERSION=${OTB_FEEDS_VERSION:=$(git -C feeds/overthebox describe --tag --always)}

rm -rf openwrt/bin openwrt/files openwrt/tmp
cp -rf root openwrt/files

cat >> openwrt/files/etc/banner <<EOF
-----------------------------------------------------
 VERSION:     $OTB_VERSION - $OTB_FEEDS_VERSION

 BUILD REPO:  $(git config --get remote.origin.url)
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
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="OverTheBox"
CONFIG_VERSION_REPO="$OTB_REPO"
CONFIG_VERSION_NUMBER="$OTB_VERSION"
CONFIG_VERSION_CODE="$OTB_FEEDS_VERSION"
CONFIG_VERSION_HOME_URL="https://github.com/ovh/overthebox"
CONFIG_VERSION_BUG_URL="https://github.com/ovh/overthebox/issues"
CONFIG_VERSION_SUPPORT_URL="https://community.ovh.com/c/telecom/overthebox"
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
