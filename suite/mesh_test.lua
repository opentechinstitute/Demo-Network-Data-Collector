-- Usage: mesh_test.lua <server ip> <communication port> [test name]...
-- e.g. mesh_test.lua 10.10.10.5 5151 ping iperf
-- [test name] defaults to all

local json = require "luci.json"
local ip = require "luci.ip"
local olsr_info = require "olsr_info"
local sys

local data = {}

-- test (string): name of test
function run_test(test_name)
   local cur_test = "net_tests."..test_name
   --when using require with a variable you need to run it as a function
   local test = require(cur_test)
   local reqs = test:get_reqs()
   local test_data = get_test_data(reqs)
   local results = test:run_tests(test_data)
   return results
end


function get_test_data(requirements)
   local test_data = {}
   local data_type, net_data
   for data_type,net_data in pairs(requirements) do
	  assert(data[net_data] ~= nil, "A required value does not exist")
	  test_data[net_data] = data[net_data]
   end
   return test_data
end

--TODO define the way tests will use this data, and what they need.
function get_network_info()
   --Get JSON-info
   local network_info = olsr_info:get_all()
   --if  nothing is returned we are not running olsr.
   if not network_info then return nil end
   for info_type, return_data in pairs(network_info) do
	  data[info_type] = return_data
	  log_results(info_type, data[info_type])
   end
   return true
end

-- args (table): table of command line arguments
function main(tests)
   local test
   prepare_logging()
   if not get_network_info() then
	  fatal_failure()
	  return nil
   end
   for _,test in ipairs(tests) do
	  print("planning to run test ".. test)
	  local results = run_test(test)
	  log_results(test, results)
	  print("test done")
   end
   print("tests complted")
   end_logging()
   save_to_server()
end

--Use the data.server & data.port variable to send the data using some service back to the server that originally called us.
function save_to_server()
   local logs = get_logs()
   print("saving tests to server")
   send_to_host(data.server, data.port, logs)
end

function fatal_failure()
   log_results("failure", {failure=true})
   end_logging()
   save_to_server()
end

--! @arg data (string) The data to send to the host
--! @arg host (string) The address of the host
--! @arg port (int) The port to connect to on the host
--! @brief Simple client service that sends a chunk of data to a specified host on a specified port.
function send_to_host(host, port, data)
   sndtimeo = '100'
   rcvtimeo = '50'
   print("connecting")
   local sock, code, msg = nixio.connect(host, port)
   if not sock then
	  print("NO SOCKET")
	  return nil, code, msg
   end
   sock:setsockopt("socket", "sndtimeo", sndtimeo or 15)
   sock:setsockopt("socket", "rcvtimeo", rcvtimeo or 15)

   print("sending data")
   -- If data is a string, then send it.
   if type(data) == "string" then
	  sock:send(data)
   end
   print("shutting down socket")
   --Send close signal to the harness
   sock:shutdown()

   print("closing socket")
   --Close the socket locally.
   sock:close()
   print("DONE sending data. Exiting test program.")
   os.exit(0)
end

function get_logs()
   --get the log-file from wherever it is.
   file = io.open("/tmp/test_suite", "r")
   text = file:read("*a")
   file:close()
   return text
end

--prepare the file to write test results and the current date/time to.
function prepare_logging()
   --Erase any old test data
   file = io.open("/tmp/test_suite", "w+")
   file:write("{\n")
   file:close()
end

function log_results(test, results)
   --This is where we would create the section for the specific test and log the results table that it passes us.
   if type(results) ~= "string" then
	  results = json.encode(results)
   end
   --Erase any old test data
   file = io.open("/tmp/test_suite", "a+")
   --add a comma after the previous item
   file:write(",\n")
   --key the results by the name of the test & write the results
   file:write("\""..test.."\" : "..results)
   file:close()
end

function end_logging()
   --This is where we would close out the logging for the tool. If we were using json it would simply close the curly brace prepare logging started.
      --Erase any old test data
   file = io.open("/tmp/test_suite", "a+")
   file:write("}")
   file:close()
end

function set_server(ip, port)
   --we should actually use the commotion helpers ip checker here.... but not for this stub.
   data.server = ip
   data.port = port
end

--place host address and port in the data table
if arg[1] and arg[2] then
   assert(ip.IPv4(arg[1]) or ip.IPv6(arg[1]))
   if not tonumber(arg[2]) then
	  print("No port specified")
	  os.exit(1)	  
   end
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
   --TODO define all tests here
   all_tests = {'ping'}
   main(all_tests)
end



