-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :
local sys = require "luci.sys"

local config = "dhcp"

local m = Map(config, "DNS", "")

-- DNS section
local dns_section = m:section(TypedSection, "dnsmasq", "Servers", "", "")
dns_section.anonymous = true
dns_section:option(DynamicList, "server", "Servers")

-- Local domains
local local_domains = m:section(TypedSection, "hostrecord", "Local domains", "", "")
local_domains.anonymous = true
local_domains.addremove = true
local_domains:option(Value, "name", "Domain")
local_domains:option(Value, "ip", "IP")

return m
