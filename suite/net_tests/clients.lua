local sys = require "luci.sys"

local clients = {}


clients.data = {}
clients.results = {}

--get reqs just returns the information it needs to do its work.
function clients:get_reqs()
    return nil
end

function clients:run_tests(test_data)
   self:get_client_splash_info()
   self:get_arp()
   return self.results
end

--TODO (Stole this from luci_commotion... it does not do everything we need, but is a good stub to start from.)
function clients:get_client_splash_info()
   if sys.call("/etc/init.d/nodogsplash enabled") ~= 0 then
	  return dhcp_lease_fallback()
   end
   local convert = function(x)
	  return tostring(math.floor(tonumber(x)/60)).." "..i18n.translate("minutes")
   end
   local function total_kB(a, b) return tostring(math.floor(a+b)).." kByte" end
   local function total_kb(a, b) return tostring(math.floor(a+b)).." kbit/s" end
   local clients = {}
   i = 0
   for line in util.execi("ndsctl clients") do
	  if string.match(line, "^client_id.*$") then
		 i = i + 1
		 clients[i] = {}
	  end
	  string.gsub(line, "^(.+=.+)$",
			   function(str)
				  local sstr = util.split(str, "=")
				  local key = sstr[1]
				  local val = sstr[2]
				  clients[i][key] = val
			   end)
   end
   for i,x in ipairs(clients) do
	  if clients[i] ~= nil then
		 clients[i].curr_conn = "No"
		 clients[i].duration = convert(clients[i].duration)
		 clients[i].bnd_wdth = total_kB(clients[i].downloaded, clients[i].uploaded)
		 clients[i].avg_spd = total_kb(clients[i].avg_down_speed, clients[i].avg_up_speed)
	  end
   end
   self.results['clients'] = clients
end


function clients:get_arp()
   local arp_table = {}
   local ap_iface = self:get_ap_interface()
   for line in util.execi("arp -a") do
	  local parsed = parse_arp_line(line)
	  --We only want hosts on our AP interface so we know they are clients.
	  if parsed['iface'] == ap_iface then
		 table.insert(arp_table, parsed)
	  end
   end
   self.results['ARP'] = arp_table
end

function clients:get_ap_interace()
   --get the current ap interface.

end

function clients:parse_arp_line(line)
   local parsed = {}
   --- parse a single arp table line
   --  bobs-Air.my.network.net (192.168.122.220) at 6a:a6:bb:2a:5e:00 [ether] on wlan0
   return parsed
end

return clients
