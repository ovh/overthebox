-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :

local sys = require "luci.sys"
local fw = require "luci.model.firewall"
local tpl = require "luci.template"
require("uci")

-- This functions adds known IPs and names to the input value
function ipHelper(input)
  sys.net.host_hints(function(mac, v4, v6, name)
    if v4 then
      input:value(tostring(v4), "%s (%s)" %{ tostring(v4), name or mac })
    end
  end)
end

function hiddenValue(name, value)
  local ret = s:option(Value, name, "")
  ret.default = value
  ret.template = "hidden_input"
  ret.title = ""
  return ret
end

function checkOtherRedirections(cur)
  local present = false

  if cur == nil then
    return false
  end

  cur:foreach("firewall","redirect", function(s)
    if not isDMZ(s.target, s.src, s.dest, s.proto, s.src_dport, s.dest_port) then
      present = true
    end
  end)

  return present
end

local function isempty(s)
  return s == nil or s == ''
end

function isDMZ(target, src, dest, proto, src_port, dest_port)
  return target == "DNAT" and src == "tun"
  and dest == "lan" and proto == "all" and
  isempty(src_dport) and isempty(dest_port)
end

local cur = uci.cursor()
local redirectPresent = false

redirectPresent = checkOtherRedirections(cur)

local dmzPresent = false

if not redirectPresent then
  cur:foreach("firewall","redirect", function(s)
    if isDMZ(s.target, s.src, s.dest, s.proto, s.src_dport, s.dest_port) then
      dmzPresent = true
    end
  end)
end

-- If no dmz is present, add an empty one
if not dmzPresent and not redirectPresent then
  local nDMZ = cur:add("firewall", "redirect")
  cur:set("firewall", nDMZ, "target", "DNAT")
  cur:set("firewall", nDMZ, "src", "tun")
  cur:set("firewall", nDMZ, "dest", "lan")
  cur:set("firewall", nDMZ, "dest_ip", "")
  cur:set("firewall", nDMZ, "proto", "all")
  cur:set("firewall", nDMZ, "enabled", "0")
  cur:commit("firewall")
end

local m = Map("firewall", "Firewall - DMZ", "")
fw.init(m.uci)

s = m:section(TypedSection, "redirect", "")
s.anonymous = true
s.addremove = false

if redirectPresent then
  local tpl_networks = tpl.Template(nil, [[
  <div class="cbi-section">
    Please disable or delete other redirection before enabling a DMZ
  </div>
  ]])
  function s.render(self)
    tpl_networks:render()
  end
  return m
end

hiddenValue("dest", "lan")
hiddenValue("target", "DNAT")

local dest = s:option(Value, "dest_ip", "Destination IP")
dest.optional = false
dest.datatype = "ip4addr"
ipHelper(dest)

local enabled = s:option(Flag, "enabled", "Enabled")
enabled.optional = false
enabled.rmempty = false

hiddenValue("proto", "all")
hiddenValue("src", "tun")

s.anonymous = true
s.addremove = false

return m
