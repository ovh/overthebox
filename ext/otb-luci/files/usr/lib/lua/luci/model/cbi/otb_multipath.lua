-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :

local sys = require "luci.sys"
local fw = require "luci.model.firewall"

local m = Map("network", "Multipath configuration", "")
fw.init(m.uci)

local help = "Upload and Download values without units are considered bytes/s.</br>"
help = help .. "You can also specify the value in Gbits / Mbits / Kbits.</br>"
help = help .. "e.g. '2500000' represents 2500000 bytes/s with is 20000000 bits/s"
help = help .. " and can be written '20Mbits'"

local s = m:section(TypedSection, "interface", "Interfaces", help)
s.anonymous = false
s.addremove = false

s.filter = function(self, section)
    local zone = fw:get_zone_by_network(section)
    if zone and zone:name() == "wan" then return true end
    return nil
end

s:option(Value, "upload", "Upload")
s:option(Value, "download", "Download")

local multipath = s:option(ListValue, "multipath", "Multipath")
multipath.default = "on"
multipath:value("on")
multipath:value("off")
multipath:value("backup")

return m
