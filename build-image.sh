#!/usr/bin/env bash
set -e

BRANCH=chaos_calmer
TAG=$(git describe --tags --match='v[0-9].*')

[ -d overthebox-openwrt ] || \
    git clone --depth=1 https://github.com/ovh/overthebox-openwrt --branch ${BRANCH}

rsync -avh otb/ overthebox-openwrt/

cd overthebox-openwrt

./scripts/feeds update -a
./scripts/feeds install -a -f -p overthebox
./scripts/feeds install -a

make dirclean

cp ../config .config
make defconfig

make -j1 V=s

./scripts/diffconfig.sh  > bin/x86-glibc/config
cp -a bin/x86-glibc/packages/overthebox bin/x86-glibc/packages/ovh
cp ./staging_dir/target-x86_64_glibc-2.21/root-x86/lib/upgrade/platform.sh bin/x86-glibc/

[ -n "${RSYNC}" ] && rsync -a bin/x86-glibc/ ${RSYNC}/${TAG}
