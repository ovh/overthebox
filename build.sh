#!/bin/sh

set -e

OTB_NUMBER=$(git describe --tag --always)

OTB_SRC=${OTB_SRC:-17.06.18}
OTB_REPO=${OTB_REPO:-http://$(curl -sS ipaddr.ovh):8000}
OTB_DIST=${OTB_DIST:-otb}

git clone https://github.com/ovh/overthebox-lede source || true
git -C source fetch --all
git -C source checkout "origin/otb-$OTB_SRC" -B "otb-$OTB_SRC"

feed=${OTB_FEED:-feed}

if [ -z "$OTB_FEED" ]; then
	OTB_FEED_SRC=${OTB_FEED_SRC:-master}
	git clone https://github.com/ovh/overthebox-feeds "$feed" || true
	git -C "$feed" fetch --all
	git -C "$feed" checkout "origin/$OTB_FEED_SRC" -B "$OTB_FEED_SRC"
fi

echo "$OTB_SRC-$(git -C "$feed" describe --tag --always)" > source/version

if [ -n "$1" ] && [ -d "$feed/$1" ]; then
	OTB_DIST=$1
	shift 1
fi

rsync -avh custom/ source/

cat > source/feeds.conf <<EOF
src-git packages https://git.lede-project.org/feed/packages.git;lede-17.01
src-git luci https://github.com/openwrt/luci.git;for-15.05
src-link overthebox $(readlink -f "$feed")
EOF

cat >> source/.config <<EOF
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="$OTB_DIST"
CONFIG_VERSION_REPO="$OTB_REPO"
CONFIG_VERSION_NUMBER="$OTB_NUMBER"
CONFIG_PACKAGE_$OTB_DIST=y
EOF

cd source

echo "Building $(cat version)"

cp .config .config.keep
scripts/feeds update -a
scripts/feeds install -a -d y -f -p overthebox
cp .config.keep .config

make defconfig
make "$@"
