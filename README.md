# Overthebox

Overthebox is an open source solution developed by OVH to aggregate and encrypt multiple internet connections and terminates it over OVH/Cloud infrastructure which make clients benefit security, reliability, net neutrality, as well as dedicated public IP.

The aggregation is based on MPTCP, which is ISP, WAN type, and latency independent "whether it was Fiber, VDSL, SHDSL, ADSL or even 4G, ", different scenarios can be configured to have either aggregation, load-balancing or failover based on MPTCP or even Openwrt mwan3 package.

The solution takes advantage of the latest Openwrt system, which is user friendly and also the possibility of installing other packages like VPN, QoS, routing protocols, monitoring, etc. through web-interface or terminal.


More information is available here :
[https://www.ovhtelecom.fr/overthebox/](https://www.ovhtelecom.fr/overthebox/)


## Prerequisite

* an x86 machine
* 2Gb of RAM


## Install from pre-compiled images

Guide to install the image is available on (french) :
[https://docs.ovh.com/pages/releaseview.action?pageId=18121070](https://docs.ovh.com/pages/releaseview.action?pageId=18121070)


### image :
[http://downloads.overthebox.ovh/trunk/x86/64/openwrt-x86-64-embedded-ext4.img.gz](http://downloads.overthebox.ovh/trunk/x86/64/openwrt-x86-64-embedded-ext4.img.gz)


### virtualbox image :
[http://downloads.overthebox.ovh/trunk/x86/64/openwrt-x86-64-combined-ext4.vdi](http://downloads.overthebox.ovh/trunk/x86/64/openwrt-x86-64-combined-ext4.vdi)


## install from source

```shell
$ git clone https://github.com/ovh/overthebox.git --recursive
```

or

```shell
$ git clone https://github.com/ovh/overthebox.git
$ cd overthebox
$ git submodule update --init
```


## choose your version

```shell
$ git checkout v0.4
$ git submodule update --remote
$ git submodule
+6b9ca16a1231d43968be80c6a114cc7c1bbfc9bc overthebox-feeds (v0.4.7)
 4ea78f7a1407657399fd865dfacd301d98a25414 overthebox-openwrt (heads/overthebox)
```

## building packages

Building package use a SDK already compiled by us.
```shell
$ ./build-package.sh
```

## building full image

```shell
$ ./build-image.sh
```

