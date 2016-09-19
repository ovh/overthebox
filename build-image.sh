#!/usr/bin/env bash
set -e

rsync -avh otb/ overthebox-openwrt/

cd overthebox-openwrt

./scripts/feeds update -a
./scripts/feeds install -a -f -p overthebox
./scripts/feeds install -a

make dirclean

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

# full compile
make -j$(nproc)

./scripts/diffconfig.sh  > bin/x86-glibc/config
cp -a bin/x86-glibc/packages/overthebox bin/x86-glibc/packages/ovh
cp ./staging_dir/target-x86_64_glibc-2.21/root-x86/lib/upgrade/platform.sh bin/x86-glibc/

if [ -n "$RSYNC" ];
then
    TAG=$(git describe --tags --match='v[0-9].*')
    rsync -a bin/x86-glibc/ $RSYNC/$TAG
fi
