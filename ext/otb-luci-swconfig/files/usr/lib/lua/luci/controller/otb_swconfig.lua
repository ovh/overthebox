-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :
module("luci.controller.otb_swconfig", package.seeall)

function index()
  local has_switch = false

  local uci = require("luci.model.uci").cursor()
  uci:foreach("network", "switch", function(s)
    if s.name == 'otbv2sw' then
      has_switch = true
      return
    end
  end)

  if has_switch then
    entry({"admin", "overthebox", "switch"}, template("otb_swconfig"), "Switch", 30)
    entry({"admin", "overthebox", "switch_config"}, call("switch_config")).dependent = false
    entry({"admin", "overthebox", "switch_reset"}, call("switch_reset")).dependent = false
  end
end

function switch_config()
  local data = {}
  local uci = require("luci.model.uci").cursor()
  uci:foreach("network", "switch_vlan", function(s)
    if not (s["device"] == 'otbv2sw') then return end

    local vlan = tonumber(s.vlan)
    local ports
    if s.ports then
      ports = string.split(s.ports, " ")
    end

    -- LAN
    local portType = "wan"
    if vlan == 2 then portType = "lan" end

    for i, port in ipairs(ports) do
      -- Check if the port is tagged
      local taggedValue = false
      if string.find(port, "t") then
        port = string.match(port,"(%d+)t")
        taggedValue = true
      end

      if not data[port] then
        data[port] = { type = portType, tagged = taggedValue }
      end
    end
  end)
  luci.http.prepare_content("application/json")
  luci.http.write_json(data)
end

function switch_reset()
  local wans = luci.http.formvalue("wans")
  if os.execute("swconfig-reset "..wans) then
    luci.http.status(200, "OK")
  else
    luci.http.status(500, "ERROR")
  end
end
