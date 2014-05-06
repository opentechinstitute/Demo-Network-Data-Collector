local nixio = require "nixio"
local json = require "luci.json"
local sys = require "luci.sys"

--! @arg data (string) The data to send to the host
--! @arg host (string) The address of the host
--! @arg port (int) The port to connect to on the host
--! @brief Simple client service that sends a chunk of data to a specified host on a specified port.
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

   -- If data is a string, then send it.
   if type(data) == "string" then
	  sock:send(data)
   end

	--Send close signal to the harness
	sock:shutdown()
	
	--Close the socket locally.
	sock:close()
end

--Get JSON-info
local json_info = sys.exec("echo /all | nc 127.0.0.1 9090")
--print(json_info)
   --Transform json info into a table
local json_table = json.decode(json_info)
local json_str = tostring(json_table)

print(send_data('10.10.173.120', 5151, json_info))
