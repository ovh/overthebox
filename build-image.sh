#!/bin/sh

set -e
set -x

umask 0022
unset GREP_OPTIONS SED

_err() {
	echo "$*" >&2
	exit 1
}

[ "$OTB_IB"    ] || _err "missing OTB_IB"
[ "$OTB_FILES" ] || _err "missing OTB_FILES"

rm -rf ib
mkdir -p ib
tar xf "$OTB_IB" -C ib --strip-components=1
tar xf "$OTB_FILES" -C ib
cd ib

if [ "$OTB_DEVICE" ]; then
	[ "$OTB_TOKEN"   ] || _err "missing OTB_TOKEN"
	[ "$OTB_SERVICE" ] || _err "missing OTB_SERVICE"
	cat <<-EOF
	Creating customized image for
	    device:  $OTB_DEVICE
	    token:   $OTB_TOKEN
	    service: $OTB_SERVICE
	EOF
	mkdir -p files/etc/config
	cat > files/etc/config/overthebox <<-EOF
	config config 'me'
	    option device_id '$OTB_DEVICE'
	    option token '$OTB_TOKEN'
	    option service '$OTB_SERVICE'
	EOF
fi

make image FILES=files PACKAGES="otb -dnsmasq"
