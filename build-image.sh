#!/usr/bin/env bash
set -e

grep -v " overthebox " overthebox-openwrt/feeds.conf.default > overthebox-openwrt/feeds.conf
echo "src-link overthebox $(readlink -f overthebox-feeds)" >> overthebox-openwrt/feeds.conf

cp config overthebox-openwrt/.config

cd overthebox-openwrt
./scripts/feeds update -a
./scripts/feeds install -a -p overthebox
./scripts/feeds install -p overthebox -f netifd
./scripts/feeds install -p overthebox -f dnsmasq
./scripts/feeds install -a

make defconfig

make -j$(nproc)

./scripts/diffconfig.sh  > bin/x86-glibc/config

if [ -n "$RSYNC" ];
then
    TAG=$(git describe --tags --match='v[0-9].*')
    rsync -a bin/x86-glibc/ $RSYNC/$TAG
fi
