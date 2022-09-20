#!/bin/sh

key=${1:-key-build}

[ -d openwrt/bin ] && [ -f "$key" ] && \
	find openwrt/bin \
	\( -name '*.img.gz' -or -name 'Packages' \) \
	-exec openwrt/staging_dir/host/bin/usign -S -m {} -s "$key" \;
