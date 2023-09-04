# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.8.1] - 2023-11-21

### Added

- Add python3 support

### Removed

- Deletion of deprecated package graph

### Fixed

- Resolve a bug on opkg which was sometime failing due to absence of ipv6

## [v0.8.0] - 2023-04-18

### Added

- Add otb-v2c package which include specific customization for this platform

### Changed

- Upgrade openWRT to 19.07.10
- Upgrade linux kernel to 4.14.276  patch with MPTCP v0.94
- Replace OTB v2b package swconfig based on python2 to a C implementation
- Use official openwrt package jq and dnsmasq instead of our own fork
- Various improvement on build script and openWRT configuration generation

### Removed

- Deletion of deprecated packages yara, svfs, otb-full and otb in image
- Remove configuration for unsupported targets : mipsel32 and neoplus2

### Fixed

- Resolve a bug on OTB v2b where a LTE USB modem was not correctly detected at boot
- Hotspot sharing with an iPhone on iOS 14 and superior is working again

## [v0.6.35] - 2023-04-18

### Added

- Add package otb-graph, this is plan to be a replacement for graph package. This is used to retrieve necessary information to realize bandwidth and system usage graphics on customer panel.
- Add action otb-action-qos, which allow to determine automatically a correct "traffic control" value on each WAN interfaces.
- Add package Nano by default in image.
- Add optional packages : prometheus-node-exporter-lua-x. Those packages are not installed by default, but can be installed using opkg.

### Changed

- Update official openwrt 18.06 packages.
- Move functional code of otb-action-speedtest to lib/overthebox. This change has no impact on the behavior of action otb-action-speedtest.
- Use git module to build an image

### Fixed

- Resolve an issue with jq parser, which was generating a large amount of logs if wan interfaces where unreachable.
- Resolve a bug on LUCI web interface, which was showing 0.0.0.0 instead of OverTheBox service public IP.
- Resolve a bug with action otb-action-sysupgrade which was not retrieving the correct URL to download an image if an URL was not provide as an argument.


## [v0.6.33] - 2021-09-24

### Added

- Use of new OVHcloud provisioning URL

### Fixed

- Do not print interface to change DHCP if the device has more than one ethernet port
- Upgrade of the shadowsocks-libev version to solve some memory leak problems
- Fix for otb-action-speedtest that sometimes returns 0
- Minor fixes

## [>= v0.6.32] - 2021-02-06

The version inferior at v0.6.33 are no more supported due to changed in our provisionning infrastructure
