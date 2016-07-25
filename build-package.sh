#!/usr/bin/env bash
set -e

SDK_URL="http://downloads.overthebox.ovh/trunk/x86/64/OpenWrt-SDK-x86-64_gcc-4.8-linaro_glibc-2.21.Linux-x86_64.tar.bz2"

if [ ! "$(ls -A sdk 2>/dev/null)" ]; 
then 
    curl $SDK_URL | tar jx 
    mv OpenWrt-SDK-x86-64_gcc-4.8-linaro_glibc-2.21.Linux-x86_64/ sdk/;
    ln -s $(pwd)/overthebox-feeds sdk/package/overthebox;  
fi

make -C sdk defconfig

ARG=$@
if [ "$#" -eq 0 ]; then
    ARG=$(cd overthebox-feeds; ls */Makefile |xargs dirname) 
fi

for I in $ARG;
do
    make -C sdk package/$I/install
done




