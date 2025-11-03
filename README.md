# OverTheBox

Version: v1.1.3

OverTheBox is an open source solution developed by OVHcloud to aggregate and encrypt multiple internet connections and terminates it over OVHcloud infrastructure which make clients benefit security, reliability, net neutrality, as well as dedicated public IPv4.

The aggregation is based on MPTCP, which is ISP, WAN type, and latency independent "whether it was Fiber, VDSL, SHDSL, ADSL or even 4G", different scenarios can be configured to have either aggregation or failover based on MPTCP.

The solution takes advantage of the OpenWRT system, which is user friendly and also adds the possibility of installing other packages like VPN, QoS, routing protocols, monitoring, etc. through web-interface or terminal.

More informations on our commercial offers are available at [ovhcloud.com](https://www.ovhcloud.com/fr/internet/overthebox/)

## Changelog

* [English](CHANGELOG.md)
* [Français](CHANGELOG_fr.md)

## Install from pre-compiled images

Guide to install the image is available in french [here](https://docs.ovh.com/fr/overthebox/).
You can download all supported images [here](http://downloads.overthebox.net/).

### On Linux

Plug a USB drive, find the device you want to flash the image on using `dmesg`, `lsblk`,`fdisk -l` or the tool your most comfortable with.

**This example will use `/dev/sdX` as the targeted block device, you have to change the following commands with your own device name**

```sh
# Download the lastest master's image
wget http://downloads.overthebox.net/develop/targets/x86/64/latest.img.gz
# Extract and flash the image on your device
gunzip -c latest.img.gz | sudo dd of=/dev/sdX bs=512
sync
```

Once you boot on your USB key, the image will be flashed by default on `mmcblk0`, see [the recovery section](#create-a-recovery-key) for more information.

## Install from source

### Dependencies

You need a classical build environment like `build-essential` on Debian and `git`.
Some feeds might not available over `git` but only via `subversion` or `mercurial`.

On Debian you'll need to install the following:

```sh
sudo apt install build-essential git unzip ncurses-dev libz-dev libssl-dev
  python subversion gettext gawk wget curl rsync perl
```

### Prepare and build

```sh
git clone https://github.com/ovh/overthebox.git
cd overthebox
./build.sh
```

The script `build.sh` accepts all `make` arguments (like `-j`).
When finished, files are located in the directory `openwrt/bin`.

### Custom arch build

By default the build script will create the packages for the `x86_64` architecture.
You can specify a custom build target by adding a `OTB_ARCH` environment variable to the build and the corresponding `config/$OTB_ARCH` file.

To build the project for the raspberry pi 3:

```sh
OTB_ARCH="rpi3" ./build.sh
```

## Create a recovery key

By default the image will try to flash itself on a device called `mmcblk0`, this is the default block device on our hardwares.

If you wish to target another block device you can add `recovery=sda` to the kernel command line to flash the image on `/dev/sda`.
If the device doesn't exists, the recovery process is skipped.
This [file](https://github.com/ovh/overthebox/blob/master/root/lib/preinit/00_recovery) is responsible for flashing the image before the system starts.

## Credits

Our solution is mainly based on:

* [OpenWRT](https://openwrt.org)
* [MultiPath TCP (MPTCP)](https://www.mptcp.dev/)
* [Shadowsocks](https://shadowsocks.org)
