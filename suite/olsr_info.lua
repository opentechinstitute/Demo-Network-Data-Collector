local uci = require "luci.model.uci".cursor()
local log = require "luci.commotion.debugger".log
local util = require "luci.util"
local sys = require "luci.sys"
local json = require "luci.json"


local oinfo = {}

function oinfo:get_plugin()
   -- Discover our own olsrd json_info plugin
   local plugins = uci:get_all("olsrd")
   local json_info_plugin, json_info_host, json_info_port
   uci:foreach('olsrd', 'LoadPlugin',
			   function(s)
				  if string.find(s.library, "olsrd_jsoninfo") then
					 json_info_plugin = s[".name"]
					 json_info_host = s.listen
					 json_info_port = s.port
				  end
   end)
   
   if not json_info_plugin then
	  log("commotion-bigboard-send: Can't find jsoninfo plugin")
	  return false
   else
	  return json_info_plugin, json_info_host, json_info_port
   end
end

function oinfo:get_info()
   --Check that required plugins are installed.
   local plugin, host, port
   plugin, host, port = self:get_plugin()
   
   if not plugin then
	  log("Can't find jsoninfo plugin. Mesh Network tests cannot be run.")
	  do return nil end
   end

   --Get JSON-info
   local json_info = sys.exec("echo /all | nc "..host.." "..port)
   --Transform json info into a table
   local json_table = json.decode(json_info)

   if json_table then
	  return json_table
   else
	  return false
   end
end


function oinfo:get_all()
   --The function that should fun all the data gathering and parsing for this tool and return it.
   local info = {}
   info["raw"] = self:get_info()
   --if no data is gathered error out
   if not info.raw then return nil end

   --This function parses the network and creates a table out of it.
   --what we want to do it to actually take each section and write it to the "data" table above in a consistant way so that every test knows how to get it.
--[[
   AVAILABLE DATA
   mid	        table: 0x834750
   hna	        table: 0x830e58
   interfaces	table: 0x829198
   neighbors	table: 0x82ecf0
   systemTime	1396646341
   links	    table: 0x829b90
   routes	    table: 0x83ef40
   config	    table: 0x8204c0
   plugins	    table: 0x850448
   topology	    table: 0x831608
   timeSinceStartup	83072318
   gateways	    table: 0x83f8b0
]]--
   --A working example is nodes.
   --NODES
   info["nodes"] = self:get_nodes(info.raw.routes)
   --GATEWAY
   info["internet"] = false
   for _,x in ipairs(info.nodes) do
	  if x == "0.0.0.0" then
		 info["gateway"] = true
	  end
   end
   --ETC
   return info
end


--! @arg routes (table) The routes table from json info.
function oinfo:get_nodes(routes)
   local node_list = {}
   local route, item, data
   for _,route in ipairs(routes) do
	  for item, data in pairs(route) do
		 if item == "destination" then
			table.insert(node_list, data)
		 end
	  end
   end
   return node_list
end


return oinfo
