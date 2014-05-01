local nixio = require "nixio"
local json = require "luci.json"
local sys = require "luci.sys"

-- data (string) The JSON formatted results you wish to send.
function build_packet(data)
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

function send_data(host, port, data)
   sndtimeo = '100'
   rcvtimeo = '50'
   local sock, code, msg = nixio.connect(host, port)
   if not sock then
	  print("NO SOCKET")
	  return nil, code, msg
   end
   sock:setsockopt("socket", "sndtimeo", sndtimeo or 15)
   sock:setsockopt("socket", "rcvtimeo", rcvtimeo or 15)

	if type(data) == "string" then
		sock:send(data)
	end

	-- Create source and fetch response
	local linesrc = sock:linesource()
	local line, code, error = linesrc()
	
	if not line then
		sock:close()
		print("NO DATA")
		return nil, code, error
	end

	print("================================")
	print(line)
	print("================================")
	sock:close()
end
--[[
   local protocol, status, msg = line:match("^([%w./]+) ([0-9]+) (.*)")
	
	if not protocol then
		sock:close()
		return nil, -3, "invalid response magic: " .. line
	end
	
	local response = {
		status = line, headers = {}, code = 0, cookies = {}, uri = uri
	}
	
	line = linesrc()
	while line and line ~= "" do
		local key, val = line:match("^([%w-]+)%s?:%s?(.*)")
		if key and key ~= "Status" then
			if type(response.headers[key]) == "string" then
				response.headers[key] = {response.headers[key], val}
			elseif type(response.headers[key]) == "table" then
				response.headers[key][#response.headers[key]+1] = val
			else
				response.headers[key] = val
			end
		end
		line = linesrc()
	end
	
	if not line then
		sock:close()
		return nil, -4, "protocol error"
	end
end
]]--


   --Get JSON-info
local json_info = sys.exec("echo /all | nc 127.0.0.1 9090")
   --Transform json info into a table
local json_table = json.decode(json_info)
local json_str = tostring(json_table)

print(send_data('10.114.207.62', 5151, json_info))
