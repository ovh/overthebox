#!/usr/bin/env bash
set -e

export OPENWRT_VERSION=`git ls-remote --tags https://github.com/openwrt/openwrt | awk -F/ '{ print $3 }' | sort -r | head -n1 2>/dev/null`
export OTB_TAG=`git ls-remote --tags https://github.com/ovh/overthebox-feeds | awk -F/ '{ print $3 }' | sort -r | head -n1 2>/dev/null`
export OTB_VERSION=${OTB_TAG#v}

echo "Openwrt version: $OPENWRT_VERSION"
echo "OverTheBox version: $OTB_VERSION"

[ -d overthebox-openwrt ] || \
	git clone --depth=1 https://github.com/openwrt/openwrt.git --tag ${OPENWRT_TAG} overthebox-openwrt

rsync -avh otb/ overthebox-openwrt/

cd overthebox-openwrt

./scripts/feeds update -a
./scripts/feeds install -a -f -p overthebox
./scripts/feeds install -a

make dirclean

cp ../config .config
make defconfig

make -j$(nproc)

./scripts/diffconfig.sh  > bin/x86-glibc/config
cp -a bin/x86-glibc/packages/overthebox bin/x86-glibc/packages/ovh
cp ./staging_dir/target-x86_64_glibc-2.21/root-x86/lib/upgrade/platform.sh bin/x86-glibc/

[ -n "${RSYNC}" ] && rsync -a bin/x86-glibc/ ${RSYNC}/${OTB_TAG}
