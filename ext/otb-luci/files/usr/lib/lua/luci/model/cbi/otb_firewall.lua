-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :

local sys = require "luci.sys"
local fw = require "luci.model.firewall"
local io = require "io"
require("uci")

-- Add an input type=hidden to the form
function hiddenValue(name, value)
  local ret = s:option(Value, name, "")
  ret.default = value
  ret.template = "hidden_input"
  ret.title = ""
  return ret
end

local function isempty(s)
  return s == nil or s == ''
end

-- This functions adds known IPs and names to the input value
function ipHelper(input)
  sys.net.host_hints(function(mac, v4, v6, name)
    if v4 then
      input:value(tostring(v4), "%s (%s)" %{ tostring(v4), name or mac })
    end
  end)
end

function isDMZ(target, src, dest, proto, src_port, dest_port)
  return target == "DNAT" and src == "tun"
  and dest == "lan" and proto == "all" and
  isempty(src_dport) and isempty(dest_port)
end

function checkDmzActive(cur)
  local present = false

  if cur == nil then
    return false
  end

  cur:foreach("firewall","redirect", function(s)
    if isDMZ(s.target, s.src, s.dest, s.proto, s.src_dport, s.dest_port) and s.enabled == "1" then
      present = true
    end
  end)
  return present
end

local cur = uci.cursor()
local modeDMZ = checkDmzActive(cur)

local m = Map("firewall", "Firewall - Port Forwards", "")
fw.init(m.uci)

s = m:section(TypedSection, "redirect", "Redirect")
s.anonymous = true
s.addremove = true

if modeDMZ then
  s.addremove = false
  s:option(DummyValue, "Warning", "Please disable the DMZ before trying to create a redirection")
  return m
end

s.filter = function(self, section)
  local target    = m.uci:get("firewall", section, "target")
  local dest      = m.uci:get("firewall", section, "dest")
  local src       = m.uci:get("firewall", section, "src")
  local proto     = m.uci:get("firewall", section, "proto")
  local dest_port = m.uci:get("firewall", section, "dest_port")
  local src_dport = m.uci:get("firewall", section, "src_dport")

  if isDMZ(target, src, dest, proto, src_dport, dest_port) then
    return nil
  end
  return true
end

local src_dport = s:option(Value, "src_dport", "Source port")
src_dport.datatype = "port"
src_dport.rmempty = false
function src_dport.validate(self, value)
  if isempty(value) then
    return nil, translate("You must specify the source port")
  end
  return value
end

local dest_port = s:option(Value, "dest_port", "Destination port")
dest_port.datatype = "port"
dest_port.rmempty = false
function dest_port.validate(self, value)
  if isempty(value) then
    return nil, translate("You must specify the destination port")
  end
  return value
end

local dest = s:option(Value, "dest_ip", "Destination IP")
dest.datatype = "ip4addr"
dest.rmempty = false
ipHelper(dest)
function dest.validate(self, value)
  if isempty(value) then
    return nil, translate("You must specify the destination IP")
  end
  return value
end

local proto = s:option(Value, "proto", "Protocol")
proto:value("tcp","TCP")
proto:value("udp", "UDP")
proto:value("tcp udp", "TCP+UDP")
proto.default = "tcp"
proto.rmempty = false
function proto.validate(self, value)
  if isempty(value) then
    return nil, translate("You must specify the protocol to use")
  end
  return value
end


hiddenValue("target", "DNAT")
hiddenValue("src", "tun")
hiddenValue("dest", "lan")
hiddenValue("enabled", "1")

return m
