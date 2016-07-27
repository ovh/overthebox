#!/usr/bin/env bash
set -e

grep -v " overthebox " overthebox-openwrt/feeds.conf.default > overthebox-openwrt/feeds.conf
echo "src-link overthebox $(readlink -f overthebox-feeds)" >> overthebox-openwrt/feeds.conf


cd overthebox-openwrt
./scripts/feeds update -a
./scripts/feeds install -a -p overthebox
./scripts/feeds install -p overthebox -f netifd
./scripts/feeds install -p overthebox -f dnsmasq
./scripts/feeds install -a


cp ../config .config
make defconfig


# compile tools and toolchain
make tools/install -j$(nproc)
make toolchain/install -j$(nproc)
make package/toolchain/compile -j$(nproc)

# compile first package to avoid compilation error :/
make package/toolchain/install -j$(nproc)
make package/lua/host/compile -j$(nproc)
make package/luci-base/host/compile -j$(nproc)
make package/intltool/host/compile -j$(nproc)
make package/gettext-full/host/compile -j$(nproc)
make package/grub2-efi/host/compile -j$(nproc)
make package/grub2/host/compile -j$(nproc)
make package/ncurses/install -j$(nproc)
make package/ncurses/host/install -j$(nproc)

# fulle compile
make -j$(nproc)

./scripts/diffconfig.sh  > bin/x86-glibc/config

if [ -n "$RSYNC" ];
then
    TAG=$(git describe --tags --match='v[0-9].*')
    rsync -a bin/x86-glibc/ $RSYNC/$TAG
fi
