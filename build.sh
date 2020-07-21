#!/bin/sh

set -e

umask 0022
unset GREP_OPTIONS SED

OTB_REPO=${OTB_REPO:-LOCAL}
OTB_TARGET=${OTB_TARGET:-x86_64}
OTB_CONFIG=${OTB_CONFIG:-nice-bb usb-full legacy}
OTB_VERSION="$(git describe --tag --always)"

OTB_PKGS="jq curl ca-bundle ca-certificates otb-backup
graph glorytun kmod-macvlan tc kmod-sched kmod-sched-cake
otb-diagnostics otb-remote otb-web ip-tiny usb-modeswitch
libimobiledevice usbmuxd iptables-mod-trace kmod-ipt-raw
rng-tools conntrack conntrackd dnsmasq kmod-nf-nathelper
kmod-nf-nathelper-extra comgt iperf3 vim htop dmesg
iputils-ping bmon bwm-ng screen mtr ss strace tcpdump
ethtool sysstat pciutils mini_snmpd libustream-mbedtls"

case "$OTB_TARGET" in
	x86_64)
		OTB_PKGS="$OTB_PKGS otb-v2b otb-v2c"
		OTB_CONFIG="$OTB_CONFIG net-full"
		;;
esac

for i in $OTB_TARGET $OTB_CONFIG; do
	if [ ! -f "config/$i" ]; then
		echo "Config $i not found !"
		exit 1
	fi
done

rm -rf openwrt/bin openwrt/files openwrt/tmp
cp -rf root openwrt/files

cat >> openwrt/files/etc/banner <<EOF
-----------------------------------------------------
 VERSION:     $OTB_VERSION

 BUILD REPO:  $(git config --get remote.origin.url)
 BUILD DATE:  $(date -u)
-----------------------------------------------------
EOF

cat > openwrt/feeds.conf <<EOF
src-link packages $(readlink -f feeds/packages)
src-link luci     $(readlink -f feeds/luci)
src-link routing  $(readlink -f feeds/routing)
src-link ext      $(readlink -f ext)
EOF

cat > openwrt/.config <<EOF
$(for i in $OTB_TARGET $OTB_CONFIG; do cat "config/$i"; done)
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="OverTheBox"
CONFIG_VERSION_NUMBER="$OTB_VERSION"
CONFIG_VERSION_CODE="v$(cat root/etc/otb-version)"
CONFIG_VERSION_REPO="$OTB_REPO"
CONFIG_VERSION_HOME_URL="https://github.com/ovh/overthebox"
CONFIG_VERSION_BUG_URL="https://github.com/ovh/overthebox/issues"
CONFIG_VERSION_SUPPORT_URL="https://community.ovh.com/c/telecom/overthebox"
$(for i in otb $OTB_PKGS; do echo "CONFIG_PACKAGE_$i=y"; done)
EOF

echo "Building for the target $OTB_TARGET"

cd openwrt

cp .config .config.keep
scripts/feeds clean
scripts/feeds update -a -f
# shellcheck disable=SC2086
scripts/feeds install -d y $OTB_PKGS
mv .config.keep .config

make defconfig
if ! make "$@"; then
	make "$@" -j1 V=s 2>&1 | tee error.log
	exit 1
fi
