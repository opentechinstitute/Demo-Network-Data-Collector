local net = require "luci.sys.net"
local iperf = {}

iperf.data = {}
iperf.results = {}
iperf.requirements = {"nodes", "server"}

--get reqs just returns the information it needs to do its work.
function iperf:get_reqs()
    return self.requirements
end

function iperf:run_tests(test_data)
   self:set_data(test_data)
   --a more scoped out test to give you an idea of how it would work
   self:run_iperf_tests()
   --Data parsers that set data gathered to results.
   self:get_throughput()
   self:get_bandwidth()
   --return raw data as well for further parsing
   self.results['raw_data'] = self.data['test_data']
   return self.results
end

function iperf:get_throughput()
   local data = self.data['test_data']
   local tp_data = {}
   for i, node in ipairs(data) do
	  local throughput
	  for i, single_line in ipairs(data) do
		 --TODO
		 --parse data here
	  end
	  tp_data[node['ip']] = throughput
   end
   self.results.throughput = tp_data
end

function iperf:get_bandwidth()
   local data = self.data['test_data']
   local bw_data = {}
   for i, node in ipairs(data) do
	  local bandwidth
	  for i, single_line in ipairs(data) do
		 --TODO
		 --parse data here
	  end
	  bw_data[node['ip']] = bandwidth
   end
   self.results.bandwidth = bw_data
end


function iperf:run_iperf_tests()
   local results = {}
   local addr_list = self:get_addresses()

   for _,ip in ipairs(nodes) do
	  local test_data, raw_data
	  --check that we can still see them
	  if net.pingtest(node) then
		 --start iperf server on node to test.
		 if self:start_server(ip) then
			--run the client and gather command line output
			raw_data = self:run_client(ip)
			--parse client ourput into a table of test data to be further parsed later
			test_data = self:parse_data(raw_data)
		 else
			test_data = "Server could not be created on target."
		 end
		 --turn off the server (if any runnign) on the node to be tested.
		 self:stop_server(ip)
	  else
		 test_data = "NO CONNECTION"
	  end
	  --If test data is returned add it to the results table.
	  if test_data then
		 table.insert(results, test_data)
	  end
   end
   --put this test into the results table
   self.data['test_data'] = results
end

-- ip (string): The ip address the client should connect to.
function iperf:run_client(ip)
   --Start up an iperf client and have it connect to the ip passed to it
   --Collect the results as a line-buffered iterator (execi)
   local results = luci.util.execi("iperf --client " .. ip)
   if not results then
	  return nil
   end
end

-- raw (iterator): Raw line buffered iterator pulled from iperf
function iperf:parse_data(raw)
   local parsed_data = {}
   --parse the raw command line output into some actual data.
   if not raw then
	  return nil
   end
   --It looks incorrect because execi creates an iterator, not a table. So you don't have to use pairs() or another iterator.
   for line in raw do
	  --TODO
	  --Parse each line here into its component parts.
   end
   return parsed_data
end

-- ip (string): The ip address to create an iperf server on.
function iperf:start_server(ip)
   --This needs to connect to another node and have it start a iperf server
end

-- ip (string): The ip address to stop an iperf server on.
function iperf:stop_server(ip)
   --This needs to connect to another node and have it stop an iperf server
end

function iperf:get_addresses()
   --here we put the server ip into our local node table
   local nodes = {data.server}
   --Here we use the node data passed to us to add each of them to the node table.
   for _,ip in ipairs(data.nodes) do
	  table.insert(nodes, ip)
   end
   return nodes
end

function iperf:set_data(test+data)
   local name
   for _,name in ipairs(iperf.requirements) do
	  assert(test_data[name])
	  self.data[name] = test_data[name]
   end
end


return iperf
