# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# v1.0
## [v1.0.3] - 2024-10-21
### Changed
- system: Upgrade to [openWRT 23.05.5](https://openwrt.org/releases/23.05/notes-23.05.5)
- system: Update luci feeds to [c344ad02a06a92fb9d8fab237cfc878a06b71ffd](https://github.com/openwrt/luci/tree/c344ad02a06a92fb9d8fab237cfc878a06b71ffd)
- system: Update package feeds to [df37b4e764207e82347c38f1efa4f0fd2c87d4ab](https://github.com/openwrt/packages/tree/df37b4e764207e82347c38f1efa4f0fd2c87d4ab)
- system: Update routing feeds to [e351d1e623e9ef2ab78f28cb1ce8d271d28c902d](https://github.com/openwrt/routing/tree/e351d1e623e9ef2ab78f28cb1ce8d271d28c902d)
- mptcpd: Upgrade to [v0.12](https://github.com/multipath-tcp/mptcpd/releases/tag/v0.12)
- otb-action-speedtest: Change default behavior to use interactive formatting, use -j parameter for json output

### Fixed
- glorytun: Take in account link set in backup
- glorytun: Use auto rate which improve behaviour
- overthebox: Suppress mmcli error output in scripts to avoid unnecessary logs
- luci: Fix an issue on multipath graph when a label with space was set
- otb-action-speedtest: Script output a compliant json when used with -j parameter

### Removed
- luci: Removed deprecated traffic control options from interface configuration pages.

## [v1.0.2] - 2024-10-02
### Added
- luci: add help section, with links to ovhcloud & openwrt documentation
- luci: MPTCP status is visible in overview
- openwrt: Add utility package qmi-utils, luci-proto-qmi, hwinfo, lscpu, pciutils and usbutils
- openwrt: Add kernel module kmod-usb-storage-uas
- openwrt: Add optionnal package minicom, speedtest-nperf

### Changed
- luci: Improve random color generation in graph
- luci: Graph in overview section include all available interfaces
- otb-lte-watchdog: Program is properly daemonize

### Fixed
- otb-tracker: LTE module is discovered automatically and no more hardcoded
- luci: Overview don't crash if an interface do not have an associated device
- luci: Remove service preload limit
- overthebox: xtun is removed from configuration on upgrade from v0.9
- lte: Interface is correctly configure on first boot
- lte: Interface metrics are set higher than ethernet interface

### Removed
- luci: Remove realtime graph section in overthebox

## [v1.0.1] - 2024-08-08
### Added
- luci: serviceID can now be copy/paste on register page
- luci: add luci-app-nlbwmon
- speedtest: reimplement otb-action-speedtest with librespeed

### Changed
- autoqos: Various improvement on autoqos, to set automatically SQM on low bandwidth links
- speedtest: update otb-test-download-shadowsocks to use librespeed

### Fixed
- luci: Replace deprecated ovh theme by bootstrap on upgrade
- system: File rc.local.user is no more override on upgrade
- glorytun: small fix on a specific case on 4G without internet connectivity

### Removed
- Removed package bandwidth replaced by luci-app-nlbwmon

## [v1.0.0] - 2024-06-05
### Changed
- openwrt: Upgrade to 23.05.2
- openwrt: Upgrade linux kernel to 5.15.137 with MPTCPv1 upstream
- openwrt: Update packages to support [nftables](https://openwrt.org/docs/guide-user/firewall/misc/nftables)
- mptcp: Migration to MPTCPv1, official linux kernel implementation of [MPTCP](https://www.mptcp.dev/)
- glorytun: Upgrade to v0.3.4 a version planned for never released v0.7, this remove glorytun TCP tunnel all traffic is now transmit through a unique UDP tunnel
- shadowsocks-libev: Upgrade to support MPTCPv1
- qos: Migration to cake, which allow a better QoS configuration out-of-the-box, without user intervention
- uqmi: Improve integration of uqmi to support LTE nvme module

### Removed
- Removed glorytun-tcp, replaced by a unique UDP tunnel
- Removed iptables, replaced by netfilter
- Removed MPTCPv0, linux kernel doesn't include patch to support this implementation

# v0.9

**Device with a unique ethernet interface are no more supported**

## [v0.9.4] - 2024-06-05
### Fixed
- luci: Registration don't block if a service doesn't have an associated device

## [v0.9.3] - 2024-02-22
### Added
- luci: Add French translation on OverTheBox section
- arp-scan: Add package in available optionnal package

### Fixed
- luci: Graph for wwan0 interface are shown correctly
- luci: Registration wait correctly for service activation

## [v0.9.2] - 2024-01-16
### Added
- luci: Enable French translation on openwrt luci pages (translation is not yet available on overthebox section)
- luci: Add a progress bar on registration page which show registration step progression
- luci: Interface can now be labeled in network section
- luci: Add WAN graph in realtime graph section
- luci: Add LAN graph in realtime graph section
- luci: Add a button to reset OTB v2b switch configuration
- openwrt: Add package qmi-utils and luci-proto-qmi to support LTE nvme card

### Changed
- luci: Interfaces label are shown instead of interfaces name if it exists in overview section
- luci: Replace service and wan view with a network map in overview section
- luci: Board model is shorten for known hardware (OTB v2c, OTB v2b, Qemu)
- luci: Interface label are preserved while editing switch configuration
- luci: Some rpc call have been factorized in a dedicated tools, browser cache may need to be refreshed

### Fixed
- luci: Vlan eth0.3 and eth0.4 are reserved for port 13 and port 14 to avoid issues while editing the switch
- luci: Kernel logs are correctly shown
- luci: Redirection to HTTPS is correclty enforced
- luci: Interface containing a "-" do not break overview
- openwrt: Redirection from overthebox.ovh is now working as intended
- otb-remote: Username/password is correctly configured on LUCI for HTTPS access

## [v0.9.1] - 2023-11-14
### Added
- luci-app-sqm: A new tool to manage QoS, its mostly useful on link which are impacted by high latency variations
- luci-app-statistics: Which allow to collect more details statistics on otb systems
- collectd: Add various optionnal plugin to expand data collection by luci-app-statistics

### Changed
- openwrt: Upgrade LUCI web interface to openWRT 21.02 native version
- openwrt: Enable HTTPS redirect for LUCI, modern browser are limiting JS in HTTP.
- luci: Full rewrite of "OverTheBox" section in web interface

### Fixed
- In case of Out-Of-Memory, we kernel panic. Before we were randomly killing processes which was silently degrading the system without a clear cut
- Resolve a bug introduce on v0.9.0 on OTBv2c LEDS

## [v0.9.0] - 2023-05-17
### Changed
- openwrt: Upgrade to 21.02.5
- openwrt: Upgrade kernel to 5.4.217  patch with mptcp v0.96
- openwrt: Update packages to support distributed switch architecture [DSA](https://openwrt.org/docs/guide-user/network/dsa/dsa-mini-tutorial)
- dnsmasq: Add ovhcloud isp dns in default dnsmasq configuration
- iperf3: Moved as a dependency of overthebox package
- otb-diagnostics: Backport never released v0.7 improvement
- otb-tracker: Backport never released v0.6.34 improvement
- otb-remote : Migrate from rsa to ed25519 for device key. This as no impact on customer side, ed25519 is not yet supported for customer key, this is only used to setup a ssh tunnel between an overthebox and our remote-access servers.

### Removed
- Remove deprecated packages graph, cherrytrail-gpio-powerbutton
- Remove explicit include of libcap package (this was a fix for v0.8 on openwrt 19.07)

### Fixed
- Resolve an issue with ip2asn which was not setting correctly wan interface whois information
- Fork iperf3 to keep v3.7.1 version, due to compilation issue with openwrt 21.02 upstream package
- Import udhcpc.user config file directly from overthebox root directory to avoid a conflict with upstream package

# v0.8
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

# v0.6
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
