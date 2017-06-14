#!/bin/sh

set -e

OTB_DIST=otb
if [ -n "$1" ] && [ -n "${1%%-*}" ]; then
    OTB_DIST=$1
    shift 1
fi

OTB_REPO=${OTB_REPO:-http://$(curl -sS ipaddr.ovh):8000}
OTB_SOURCE=https://github.com/ovh/overthebox-lede
OTB_NUMBER=17.06.09
OTB_VERSION=$(git rev-parse --short HEAD)

[ -d source ] || \
	git clone --depth 1 "$OTB_SOURCE" --branch "otb-$OTB_NUMBER" source

rsync -avh custom/ source/

cd source

cat > feeds.conf <<EOF
src-git packages https://git.lede-project.org/feed/packages.git;lede-17.01
src-git luci https://github.com/openwrt/luci.git;for-15.05
src-git overthebox https://github.com/ovh/overthebox-feeds.git
EOF

scripts/feeds update -a
scripts/feeds install -a -d m -f -p overthebox

OTB_FEEDS_VERSION=$(git -C feeds/overthebox rev-parse --short HEAD)

echo "$OTB_VERSION-$OTB_FEEDS_VERSION" > version

cat >> .config <<EOF
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="$OTB_DIST"
CONFIG_VERSION_REPO="$OTB_REPO"
CONFIG_VERSION_NUMBER="$OTB_NUMBER"
CONFIG_PACKAGE_$OTB_DIST=y
EOF

make defconfig
make clean
make "$@"
