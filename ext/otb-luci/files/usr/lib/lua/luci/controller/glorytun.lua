-- vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2 :
module("luci.controller.glorytun", package.seeall)

function index()
  entry({"admin", "glorytun", "show"}, call("gt_show")).dependent = false
  entry({"admin", "glorytun", "path"}, call("gt_path")).dependent = false
end

function gt_show()
  local data = {}
  local dump = io.popen("glorytun show")
  if dump then
    for line in dump:lines() do
      local word = string.split(line, " ")
      table.insert(data, {
        dev = word[2],
        pid = tonumber(word[3]),
        bind = { ipaddr = word[4], port = tonumber(word[5]) },
        peer = { ipaddr = word[6], port = tonumber(word[7]) },
        mtu = tonumber(word[8]),
        cipher = word[9]
      })
    end
  end
  luci.http.prepare_content("application/json")
  luci.http.write_json(data)
end

function gt_path()
  local data = {}
  local dump = io.popen("glorytun path")
  if dump then
    for line in dump:lines() do
      local word = string.split(line, " ")
      table.insert(data, {
        state = word[2],
        status = word[3],
        bind = { ipaddr = word[4], port = tonumber(word[5]) },
        public = { ipaddr = word[6], port = tonumber(word[7]) },
        peer = { ipaddr = word[8], port = tonumber(word[9]) },
        mtu = tonumber(word[10]),
        rtt = tonumber(word[11]),
        rttvar = tonumber(word[12]),
        rate = word[13],
        beat = tonumber(word[14]),
        losslimit = tonumber(word[15]),
        rate_tx = tonumber(word[16]),
        loss_tx = tonumber(word[17]),
        total_tx = tonumber(word[18]),
        rate_rx = tonumber(word[19]),
        loss_rx = tonumber(word[20]),
        total_rx = tonumber(word[21])
      })
    end
  end
  luci.http.prepare_content("application/json")
  luci.http.write_json(data)
end
