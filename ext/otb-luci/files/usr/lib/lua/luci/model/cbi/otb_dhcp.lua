-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :
local sys = require "luci.sys"

local config = "dhcp"

local m = Map(config, "DHCP", "")

-- DHCP server
local dhcp_section = m:section(TypedSection, "dhcp", "Server", "", "")
dhcp_section.anonymous = true
dhcp_section.filter = function(self, section)
    local interface = m.uci:get(config, section, "interface")
    if interface ~= "lan" then return nil end
    return true
end
dhcp_section:option(Value, "start", "Range start")
dhcp_section:option(Value, "limit", "Number of leases")

-- Static leases
local static_lease_section = m:section(TypedSection, "host", "Static leases", "", "")
static_lease_section.anonymous = true
static_lease_section.addremove = true
local sls_name = static_lease_section:option(Value, "name", "Name")
local sls_mac  = static_lease_section:option(Value, "mac", "Mac address")
local sls_ip   = static_lease_section:option(Value, "ip", "IP")
sys.net.host_hints(function(m, v4, v6, name)
    if m and v4 then
        sls_ip:value(v4)
        sls_mac:value(m, "%s (%s)" %{ m, name or v4 })
    end
end)

return m
