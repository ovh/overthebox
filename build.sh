

grep -v " overthebox " overthebox-openwrt/feeds.conf.default > overthebox-openwrt/feeds.conf
echo "src-link overthebox $(readlink -f overthebox-feeds)" >> overthebox-openwrt/feeds.conf

