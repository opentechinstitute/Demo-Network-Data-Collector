local uci = "luci.model.uci".cursor()
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
	  do return end
   else
	  return true
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

return oinfo
