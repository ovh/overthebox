#!/bin/sh

set -e

umask 0022
unset GREP_OPTIONS SED

_get_repo() {
	git clone "$2" "$1" 2>/dev/null || true
	git -C "$1" remote set-url origin "$2"
	git -C "$1" fetch origin
	git -C "$1" fetch origin --tags
	git -C "$1" checkout "origin/$3" -B "$3"
}

OTB_DIST=${OTB_DIST:-otb}
OTB_HOST=${OTB_HOST:-$(curl -sS ipaddr.ovh)}
OTB_PORT=${OTB_PORT:-8000}
OTB_REPO=${OTB_REPO:-http://$OTB_HOST:$OTB_PORT/$OTB_PATH}
OTB_TARGET=${OTB_TARGET:-x86_64}
OTB_TARGET_CONFIG="config-$OTB_TARGET"

if [ ! -f "$OTB_TARGET_CONFIG" ]; then
	echo "Target $OTB_TARGET not found !"
	exit 1
fi

_get_repo source https://github.com/ovh/overthebox-lede "otb-17.10.30"
_get_repo feeds/packages https://github.com/openwrt/packages "lede-17.01"
_get_repo feeds/luci https://github.com/openwrt/luci "for-15.05"

if [ -z "$OTB_FEED" ]; then
	OTB_FEED=feeds/overthebox
	_get_repo "$OTB_FEED" https://github.com/ovh/overthebox-feeds "${OTB_FEED_SRC:-master}"
fi

if [ -n "$1" ] && [ -f "$OTB_FEED/$1/Makefile" ]; then
	OTB_DIST=$1
	shift 1
fi

rm -rf source/bin source/files source/tmp
cp -rf root source/files

cat >> source/files/etc/banner <<EOF
-----------------------------------------------------
 PACKAGE:     $OTB_DIST
 VERSION:     $(git describe --tag --always)

 BUILD REPO:  $(git config --get remote.origin.url)
 BUILD DATE:  $(date -u)
-----------------------------------------------------
EOF

cat > source/feeds.conf <<EOF
src-link packages $(readlink -f feeds/packages)
src-link luci $(readlink -f feeds/luci)
src-link overthebox $(readlink -f "$OTB_FEED")
EOF

cat "$OTB_TARGET_CONFIG" config -> source/.config <<EOF
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="$OTB_DIST"
CONFIG_VERSION_REPO="$OTB_REPO"
CONFIG_VERSION_NUMBER="$(git describe --tag --always)"
CONFIG_VERSION_CODE="$(git -C "$OTB_FEED" describe --tag --always)"
CONFIG_PACKAGE_$OTB_DIST=y
CONFIG_PACKAGE_${OTB_DIST}-full=m
EOF

echo "Building $OTB_DIST for the target $OTB_TARGET"

cd source

cp .config .config.keep
scripts/feeds clean
scripts/feeds update -a
scripts/feeds install -a -d y -f -p overthebox
cp .config.keep .config

make defconfig
make "$@"
