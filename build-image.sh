#!/usr/bin/env bash
set -e

export OPENWRT_VERSION="3f98448d670ab2e908c8d6002d8c6f8ff5d1d9bd"
# export OPENWRT_VERSION=`git ls-remote --tags https://github.com/openwrt/openwrt | awk -F/ '{ print $3 }' | sort -r | head -n1 2>/dev/null`
export OTB_TAG=`git ls-remote --tags https://github.com/ovh/overthebox-feeds | grep -v "\^{}$" | awk '{print $2,$1}' | awk -F'/' '{print $3}' | sort -r -V -t. | head -n1 2>/dev/null`
export OTB_VERSION=`echo "$OTB_TAG" | cut -f1 -d' '`
export OTB_COMMIT=`echo "$OTB_TAG" | cut -f2 -d' '`

echo "--- Openwrt version: $OPENWRT_VERSION	---"
echo "--- OverTheBox version: $OTB_VERSION	---"
echo "--- OverTheBox commit: $OTB_COMMIT	---"

[ -d overthebox-openwrt ] || {
	git clone https://github.com/openwrt/openwrt.git overthebox-openwrt
	cd overthebox-openwrt
	git checkout ${OPENWRT_VERSION}
	cd ..
#	git clone --depth=1 https://github.com/openwrt/openwrt.git --tag ${OPENWRT_TAG} overthebox-openwrt
}

rsync -avh otb/ overthebox-openwrt/
cd overthebox-openwrt
sed -i "/^src-git overthebox/ s/$/^$OTB_COMMIT/" feeds.conf

./scripts/feeds update -a
./scripts/feeds install -a -f -p overthebox
./scripts/feeds install -a
rsync -avh ../otb/feeds/packages/ feeds/packages/

make dirclean

cp ../config .config
make defconfig
# make kernel_menuconfig CONFIG_TARGET=subtarget

make -j$(nproc)

./scripts/diffconfig.sh  > bin/x86-glibc/config
cp -a bin/x86-glibc/packages/overthebox bin/x86-glibc/packages/ovh
cp ./staging_dir/target-x86_64_glibc-2.21/root-x86/lib/upgrade/platform.sh bin/x86-glibc/

[ -n "${RSYNC}" ] && rsync -a bin/x86-glibc/ ${RSYNC}/${OTB_TAG}
