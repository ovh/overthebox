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

### Prepare

```shell
$ git clone https://github.com/ovh/overthebox.git
$ cd overthebox
```

or choose a specific branch, for old releases you may need to update submodules:

```shell
$ git clone https://github.com/ovh/overthebox.git --branch v0.4
$ cd overthebox
$ git submodule update --init --remote
```


### Build

```shell
$ ./build-image.sh
```
Files are located in `overthebox-openwrt/bin/x86-glibc/` directory.


## Credits

Our solution is mainly based on:

* [OpenWRT](https://openwrt.org)
* [MultiPath TCP (MPTCP)](https://multipath-tcp.org)
* [Shadowsocks](https://shadowsocks.org)
