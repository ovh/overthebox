#!/bin/sh

set -e

OTB_SOURCE=https://github.com/ovh/overthebox-lede
OTB_NUMBER=17.06.18
OTB_VERSION=$(git rev-parse --short HEAD)

[ -d source ] || \
	git clone --depth 1 "$OTB_SOURCE" --branch "otb-$OTB_NUMBER" source

rsync -avh custom/ source/

cd source

cp .config .config.keep
scripts/feeds update -a
scripts/feeds install -a -d y -f -p overthebox
cp .config.keep .config

OTB_FEEDS_VERSION=$(git -C feeds/overthebox rev-parse --short HEAD)
OTB_REPO=${OTB_REPO:-http://$(curl -sS ipaddr.ovh):8000}
OTB_DIST=${OTB_DIST:-otb}

if [ -n "$1" ] && [ -d "feeds/overthebox/$1" ]; then
    OTB_DIST=$1
    shift 1
fi

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
make "$@" || exit

[ -d bin ] && [ -f key-build ] && \
	find bin -name '*.img.gz' -exec ./staging_dir/host/bin/usign -S -m {} -s key-build \;
