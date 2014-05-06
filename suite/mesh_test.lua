-- Usage: mesh_test.lua <server ip> <communication port> [test name]...
-- e.g. mesh_test.lua 10.10.10.5 5151 ping iperf

local json = require "luci.json"
local ip = require "luci.ip"

local data = {}

-- test (string): name of test
function run_test(test)
   local test = require "net_tests."..test
   get_network_info()
   local reqs = test:get_reqs()
   local test_data = get_test_data(reqs)
   local results = test:run_tests(test_data)
   return results
end


function get_test_data(requirements)
   local test_data = {}
   local data_type, net_data
   for data_type,net_data in requirements do
	  assert(data[data_type])
	  test_data[data_type] = data[data_type]
   end
   return test_data
end

function get_network_info()
   --Get JSON-info
   local raw_olsr_info = sys.exec("echo /all | nc 127.0.0.1 9090")
   --Transform json info into a table
   local json_table = json.decode(json_info)
   
   --This function parses the network and creates a table out of it.
   --what we want to do it to actually take each section and write it to the "data" table above in a consistant way so that every test knows how to get it.
--[[ AVAILABLE DATA
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

   data['nodes'] = json_table.neighbors
   
end
   
-- args (table): table of command line arguments
function main(args)
   local test
   prepare_logging()
   for _,test in ipairs(args) do
	  local results = run_test(test)
	  log_result(test, results)
   end
   end_logging()
   save_to_server()
end


function save_to_server()
   --here is where we use the data.server & data.port variable to send the data using some service back to the server that originally called us.
   local logs = get_logs()
   send_to_host(data.server, data.port, logs)
end

--! @arg data (string) The data to send to the host
--! @arg host (string) The address of the host
--! @arg port (int) The port to connect to on the host
--! @brief Simple client service that sends a chunk of data to a specified host on a specified port.
function send_to_host(host, port, data)
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

function get_logs()
   --get the log-file from wherever it is.

end

function prepare_logging()
   --This is where we would prepare the file to write test results and the current date/time to.
end

function log_results(test, results)
   --This is where we would create the section for the specific test and log the results table that it passes us.
end

function end_logging()
   --This is where we would close out the logging for the tool. If we were using json it would simply close the curly brace prepare logging started.
end

function set_host(ip, port)
   --we should actually use the commotion helpers ip checker here.... but not for this stub.
   data.server = ip
   data.port = port
end

--place host address and port in the data table
if arg[1] and arg[2] then
   assert(ip.IPv4(arg[1]) or ip.IPv6(arg[1]))
   assert(type(arg[2]) == "number", "abs expects a number")
   set_server(arg[1], arg[2])
   --remove the host address
   table.remove(arg, 1)
   --remove the port, that is now the first item in the array since we removed the host
   table.remove(arg, 1)
else
   print("you need to specify a server and port")
   os.exit(1)
end

--If there is an argument still defied as 1
if arg[1] then
   --remove server and pass on all other args
   main(arg)
else
   --if no test specified, run them all
   main("all")
end



