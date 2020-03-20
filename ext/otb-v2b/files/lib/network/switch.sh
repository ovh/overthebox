#!/bin/sh

setup_vlan() {
	local device vlan ports
	config_get device "$1" device
	[ "$device" = "otbv2sw" ] || return 0
	config_get vlan "$1" vlan
	config_get ports "$1" ports
	swconfig-v2b set "$vlan" $ports
}

setup_switch() {
	config_load network
	config_foreach setup_vlan switch_vlan
}
