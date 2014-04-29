-- Usage: mesh_test.lua <server ip> [test name]...
-- e.g. mesh_test.lua 10.10.10.5 ping iperf

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
   --This function parses the network and creates a table out of it.
   --Here is battlemesh does somthing like it.
   --from https://github.com/battlemesh/battlemesh-packages/blob/master/packages/wbm-test-scripts/files/root/random_node_netperf.lua
   nodearray = {}
   nodes_file = io.popen("wget -q http://[::1]:2006/route -O - | awk '{print $1}' | grep fd..: | cut -d ':' -f 3 | sort -u")
   while true do
	  local line = nodes_file:read('*l')
	  if line == nil then break end
	  nodearray[#nodearray + 1] = line
   end
   nodes_file:close()
   --what we want to do it to actually take each section and write it to the "data" table above in a consistant way so that every test knows how to get it.
   data['nodes'] = table_of_node_data
   
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
   send_to_server()
end

function save_to_server()
   --here is where we would use the data.server variable to send the data using some service back to our server that originally called us.
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

function set_server(ip)
   --we should actually use the commotion helpers ip checker here.... but not for this stub.
   data.server = ip
end

--place server in the data table
if arg[1] then
   set_server(arg[1])
else
   print("you need to specify a server")
   os.exit(1)
end

if arg[2] then
   --remove server and pass on all other args
   table.remove(arg, 1)
   main(arg)
else
   --if no test specified, run them all
   main("all")
end



