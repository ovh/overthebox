#!/bin/sh
# vim: set noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 :

# Avoid more than one switch
SINGLETON_COUNT=0

setup_switch_dev() {
	if [ $SINGLETON_COUNT -gt 1 ]; then
		return 1
	fi

	local name
	config_get name "$1" name
	name="${name:-$1}"

	# Just silently skip switches we are not familiar with
	# In the future it would be nice to be much more generic than that :)
	if [ "$name" != "otbv2sw" ]; then
		return 0
	fi

	SINGLETON_COUNT=$((SINGLETON_COUNT+1))

	swconfig dev "$name" load network
}

setup_switch() {
	config_load network
	config_foreach setup_switch_dev switch
}
