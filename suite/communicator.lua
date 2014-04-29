#!/usr/bin/lua

local sys = require "luci.sys"
local https = require "luci.httpclient"
local log = require "luci.commotion.debugger".log
local json = require "luci.json"

local com = {}

-- ip (string): the ip address of the server
-- results (table): The table of results from the test
-- collector (string): The name of the collector service running on the server
function com:send_results(ip, results, collector)

   -- TODO Replace this with a variable passed.
   local server="https://"..ip.."/"..collector
   local json_data = json.encode(results)
   if json_data then
	  local packet = self:build_packet(json_data)
   else
	  log("No JSON data created")
	  return false
   end
   if self:send_data(server, packet) then
	  return true
   else
	  log("Could not send data to server")
	  return false
   end
end

-- data (string) The JSON formatted results you wish to send.
function com:build_packet(data)
   local options = {}
   options.headers =  {}
   options.headers["Connection"] = "keep-alive"
   options.headers["Content-Type"] = "application/x-www-form-urlencoded"
   options.sndtimeo = '100'
   options.rcvtimeo = '50'
   options.method = "POST"
   options.message= {}
   options.body = {}
   options.body.host = sys.hostname()
   options.body.json = data
end

function com:send_data(url, options)
   local stat, code, err
   stat, code, err  = https.request_raw(bb_listener_url, options)
   if err then
	  log("Could not send test data.")
	  log("stat"..tostring(stat))
	  log("err"..tostring(err))
	  log("code"..tostring(code))
	  return false
   else
	  return true
   end
end


return com
