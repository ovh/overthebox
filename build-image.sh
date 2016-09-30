#!/usr/bin/env bash
set -e

export OTB_TAG=`git describe --tags --match='v[0-9].*' 2>/dev/null`
export OTB_VERSION=${OTB_TAG#v}

[ -d overthebox-openwrt ] || \
    git clone --depth=1 https://github.com/ovh/overthebox-openwrt --branch master

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
