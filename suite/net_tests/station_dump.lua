local sys = require "luci.sys"

local s_dump = {}


s_dump.data = {}
s_dump.results = {}

--get reqs just returns the information it needs to do its work.
function s_dump:get_reqs()
    return nil
end

function s_dump:run_tests(test_data)
   self:get_client_splash_info()
   self:get_arp()
   return self.results
end

function s_dump:get_dump()
   local ifaces = self:get_wireless_ifaces()
   local stations = {}
   for iface in ifaces do
	  local current = {}
	  local station = false
	  for line in util.execi("iw dev "..iface.." station dump") do
		 --if regex "^Station%s then station=true end
		 if station then
			table.insert(station, current)
			current = nil
			current = {}
		 end
		 local key, val = self:parse_line(line)
		 current[key] = val
	  end
   end
end

function s_dump:parse_line(line)
   --parse line and identify key item and value.

   return key, val
end

function s_dump:get_wireless_ifaces()
   local interfaces = {}
   --add all interaces that are wireless to the interfaces table
   return interfaces
end

return s_dump


