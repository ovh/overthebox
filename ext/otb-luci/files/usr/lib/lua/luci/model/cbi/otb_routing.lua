-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :
local sys = require "luci.sys"

local config = "network"
local defaultPriority = 25000;
local internalPriorities = {100, 30000, 30200};

local m = Map(config, "Routing", "")
m.on_before_save = function()
    m.uci:foreach(config, "rule", function(s)
        -- Set the default priority if it's not defined already
        if not s.priority then
            m.uci:set(config, s[".name"], "priority", defaultPriority)
        end
    end)
end

local s = m:section(TypedSection, "rule", "Route a specific device using a specific WAN", "", "")
s.addremove = true

-- Filter internal rules
s.filter = function(self, section)
    local priority = m.uci:get(config, section, "priority")
    if priority then
      for _, p in ipairs(internalPriorities) do
        if (priority == tostring(p)) then return false end
      end
    end
    return true
end

local sIP = s:option(Value, "src", "Source IP")
sIP.rmempty = true
sys.net.host_hints(function(mac, v4, v6, name)
    if not v4 then return end
    sIP:value(tostring(v4).."/32", "%s/32 (%s)" %{ tostring(v4), name or mac })
end)

local dIP = s:option(Value, "dest_ip", "Destination IP")
dIP.rmempty = true

local wan = s:option(Value, "lookup", "WAN")
m.uci:foreach(config, "interface", function(s)
    if not s.ip4table then return end
    wan:value(s.ip4table, s[".name"])
end)

return m
