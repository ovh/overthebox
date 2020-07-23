-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :
module("luci.controller.overthebox", package.seeall)

function index()
  entry({"admin", "overthebox"}, alias("admin", "overthebox", "overview"), "OverTheBox", 10).index = true
  entry({"admin", "overthebox", "overview"}, template("otb_overview"), "Overview", 1)
  entry({"admin", "overthebox", "dhcp"}, cbi("otb_dhcp"), "DHCP", 2)
  entry({"admin", "overthebox", "dns"}, cbi("otb_dns"), "DNS", 3)
  entry({"admin", "overthebox", "routing"}, cbi("otb_routing"), "Routing", 4)
  entry({"admin", "overthebox", "multipath"}, cbi("otb_multipath"), "Multipath", 6)

  entry({"admin", "overthebox", "firewall"}, alias("admin", "overthebox", "firewall", "firewall"), _("Firewall"), 7)
  entry({"admin", "overthebox", "firewall", "firewall"}, cbi("otb_firewall"), "Port Forwards", 1).leaf = true
  entry({"admin", "overthebox", "firewall", "dmz"}, cbi("otb_dmz"), "DMZ", 2).leaf = true

  entry({"admin", "overthebox", "confirm_service"}, call("otb_confirm_service")).dependent = false
  entry({"admin", "overthebox", "time"}, call("otb_time")).dependent = false
  entry({"admin", "overthebox", "dhcp_leases_status"}, call("otb_dhcp_leases_status")).dependent = false
end

function otb_confirm_service()
  local service = luci.http.formvalue("service") or ""
  if os.execute("otb-confirm-service "..service) then
    luci.http.status(200, "OK")
  else
    luci.http.status(500, "ERROR")
  end
end

function otb_time()
  luci.http.prepare_content("application/json")
  luci.http.write_json({ timestamp = tostring(os.time()) })
end

function otb_dhcp_leases_status()
  local s = require "luci.tools.status"
  luci.http.prepare_content("application/json")
  luci.http.write('[')
  luci.http.write_json(s.dhcp_leases())
  luci.http.write(',')
  luci.http.write_json(s.dhcp6_leases())
  luci.http.write(']')
end
