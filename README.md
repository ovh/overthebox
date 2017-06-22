# OverTheBox

OverTheBox is an open source solution developed by OVH to aggregate and encrypt multiple internet connections and terminates it over OVH/Cloud infrastructure which make clients benefit security, reliability, net neutrality, as well as dedicated public IP.

The aggregation is based on MPTCP, which is ISP, WAN type, and latency independent "whether it was Fiber, VDSL, SHDSL, ADSL or even 4G", different scenarios can be configured to have either aggregation, load-balancing or failover based on MPTCP or even OpenWRT mwan3 package.

The solution takes advantage of the OpenWRT system, which is user friendly and also the possibility of installing other packages like VPN, QoS, routing protocols, monitoring, etc. through web-interface or terminal.


More information is available here:
[https://www.ovhtelecom.fr/overthebox/](https://www.ovhtelecom.fr/overthebox/)


## Prerequisites

* an x86 machine
* 2GiB of RAM


## Install from pre-compiled images

Guide to install the image is available in french [here](https://www.ovhtelecom.fr/overthebox/guides.xml).
You can download all supported images [here](http://downloads.overthebox.ovh/stable/x86/64/).


## Install from source

### Dependencies

You need a classical build environnement like `build-essential` on debian and `git`.
Some feeds might not available over `git` but only via `subversion` or `mercurial`.

On debian you'll need to install the following:
```shell
$ sudo apt install build-essential git unzip ncurses-dev libz-dev \
libssl-dev python uuid-dev subversion gettext libxml-parser-perl \
libpopt-dev gawk curl rsync
```

### Prepare

```shell
$ git clone https://github.com/ovh/overthebox.git
$ cd overthebox
```

### Build

```shell
$ ./build.sh
```

You can also specify the image you want to build (eg: otb / otb-debug).

The default build will use `otb`.

You can optionally add arguments to the build.

```shell
$ ./build.sh otb-debug -j8
```

When finished, files are located in the directory `source/bin`.


## Credits

Our solution is mainly based on:

* [OpenWRT](https://openwrt.org)
* [LEDE](https://lede-project.org)
* [MultiPath TCP (MPTCP)](https://multipath-tcp.org)
* [Shadowsocks](https://shadowsocks.org)
