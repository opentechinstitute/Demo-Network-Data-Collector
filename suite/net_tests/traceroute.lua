local net = require "luci.sys.net"
local traceroute = {}

traceroute.data = {}
traceroute.results = {}
traceroute.requirements = {"nodes", "server", "internet"}

--get reqs just returns the information it needs to do its work.
function traceroute:get_reqs()
    return self.requirements
end

function traceroute:run_tests(test_data)
   self:set_data(test_data)
   self:get_data()
   self:get_average()
   self:get_bounds()
   self.results['raw_data'] = self.data['traceroute_data']
   --send back results of all tests
   return self.results
end

function traceroute:get_data()
   --here we put the server ip into our local node table
   local results = {}
   local nodes = {data.server}
   --If we have internet connectivity add in the internet sites we traceroute.
   if data.internet then
	  table.insert(nodes, "8.8.8.8")
	  table.insert(nodes, "www.opentechinstitute.org")
   end
   --Here we use the node data passed to us to add each of them to the node table.
   for _,ip in ipairs(data.nodes) do
	  table.insert(nodes, ip)
   end
   for _,node in ipairs(nodes) do
	  local test_data = {}
	  --Check if it responds at all
	  if net.pingtest(node) then
		 --Here is where we call the function that would actually traceroute the node and get the average.
		 test_data = self:run_traceroute(node)
	  else
		 test_data = "NO CONNECTION"
	  end
	  --If test data is returned add it to the results table.
	  if test_data then
		 table.insert(results, test_data)
	  end
   end
   self.data['traceroute_data'] = results
end

-- ip (string) The ip address of the object to traceroute
function traceroute:run_traceroute(ip)
   --traceroute the node 4 times.
   local results = luci.util.execi("traceroute -n " .. ip)
   if not results then
	  return nil
   else
	  return = self:parse_traceroute(results)
   end
end

-- traceroute_data (iterator) A line buffered iterator of a traceroute.
function traceroute:parse_traceroute(traceroute_data)
   local results = {}
   --TODO
   if not traceroute_data then
	  return nil
   end
   for line in traceroute_data do
	  local parsed_line
	  --TODO
	  --Parse each line here into its component parts.
	  table.insert(results, parsed_line)
   end
   return results
end

-- ip (string): The ip address the client should connect to.
function traceroute:run_client(ip)
   --Start up an iperf client and have it connect to the ip passed to it
   --Collect the results as a line-buffered iterator (execi)
   local results = luci.util.execi("iperf --client " .. ip)
   if not results then
	  return nil
   else
	  return results
   end
end


function traceroute:set_data(test+data)
   local name
   for _,name in ipairs(traceroute.requirements) do
	  assert(test_data[name])
	  self.data[name] = test_data[name]
   end
end

return traceroute
