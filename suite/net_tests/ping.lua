local sys = require "luci.sys"
local ping = {}

ping.data = {}
ping.results = {}
ping.requirements = {"nodes", "server", "internet"}

--get reqs just returns the information it needs to do its work.
function ping:get_reqs()
   print("getting ping requirements")
    return self.requirements
end

function ping:run_tests(test_data)
   print("starting ping test")
   self:set_data(test_data)
   self:get_data()
--   self:get_average()
--   self:get_bounds()
   self.results['raw_data'] = self.data['ping_data']
   --send back results of all tests
   print("ping test complete")
   return self.results
end

function ping:get_data()
   --here we put the server ip into our local node table
   local results = {}
   local nodes = {self.data.server}
   --If we have internet connectivity add in the internet sites we ping.
   if self.data.internet then
	  table.insert(nodes, "8.8.8.8")
	  table.insert(nodes, "www.opentechinstitute.org")
   end
   --Here we use the node data passed to us to add each of them to the node table.
   for _,ip in ipairs(self.data.nodes) do
	  table.insert(nodes, ip)
   end
   for _,node in ipairs(nodes) do
	  local test_data = {}
	  --Check if it responds at all
	  if sys.net.pingtest(node) then
		 --Here is where we call the function that would actually ping the node and get the average.
		 test_data = self:run_ping(node)
	  else
		 test_data = "NO CONNECTION"
	  end
	  --If test data is returned add it to the results table.
	  if test_data then
		 table.insert(results, test_data)
	  end
   end
   self.data['ping_data'] = results
end

-- ip (string) The ip address of the object to ping
function ping:run_ping(ip)
   print("Pinging "..ip)
   --ping the node 4 times.
   local results = luci.util.execi("ping -c 4 " .. ip)
   if not results then
	  print("no results found")
	  return nil
   else
	  print("parsing results")
	  return self:parse_ping(results)
   end
end

-- ping_data (iterator) A line buffered iterator of a ping.
function ping:parse_ping(ping_data)
   local results = {}
   --TODO
   if not ping_data then
	  return nil
   end
   for line in ping_data do
	  local parsed_line
	  if line:match("^PING") then
		 results.target = line:match("^PING%s(%d*%.%d*%.%d*%.%d*)%s")
	  elseif line:match("^(%d*)%sbytes") then
		 ping_parse = "^(%d*)%sbytes%sfrom%s(%d*%.%d*%.%d*%.%d*)%:%sseq%=(%d*)%sttl%=(%d*)%stime%=(%d*%.%d*)%s(%a*)"
		 local bytes, addr, seq, ttl, time, time_mod
		 bytes, addr, seq, ttl, time, time_mod = line:match(ping_parse)
		 if not results.raw then
			results.raw = {}
		 end
		 --add results to table
		 table.insert(results.raw, { bytes=bytes,
									addr=addr,
									seq=seq,
									ttl=ttl,
									time=time,
									time_mod=time_mod } )
	  elseif line:match("^%d.-loss$") then
		 results.loss = line:match("^%d.-%,%s(%d*%%)%spacket%sloss$")
	  elseif line:match("^round%-trip") then
		 local min, avg, max
		 min, avg, max = line:match("^.-%=%s(%d*%.?%d*)%/(%d*%.?%d*)%/(%d*%.?%d*)%s")
		 results.min = min
		 results.avg = avg
		 results.max = max
	  end
   end
   print("results parsed")
   return results
end

function ping:get_average()
   local data = self.data['ping_data']
   local ping_average = {}
   for _, node in ipairs(data) do
	  local total = 0
	  local num  = 0
	  for i, single_ping in ipairs(node) do
		 num = num + 1
		 --Add the milisecond count of each ping to the total
		 total = total  + single_ping['ms']
		 --parse data to get pings
	  end
	  local average = total / num
	  --put down this nodes average ping number (keyed by ip) in the ping_average table
	  ping_average[node['ip']] = average
   end
   --set the ping average table
   self.results['average'] = ping_average
end

--get the high and low times for pings
function ping:get_bounds()
   local data = self.data['ping_data']
   local list = {}
   for i, node in ipairs(data) do
	  local high
	  local low
	  for i, single_ping in ipairs(data) do
		 if not high then high = single_ping['ms'] end
		 if not low then low = single_ping['ms'] end
		 --parse data to get pings high and lows
		 if single_ping['ms'] > high then
			high = single_ping['ms']
		 end
		 if single_ping['ms'] < low then
			low = single_ping['ms']
		 end
	  end
	  list.high[node['ip']] = high
	  list.low[node['ip']] = low
   end
   self.results['high'] = list.high
   self.results['low'] = list.low
end

function ping:set_data(test_data)
   local name
   for _,name in ipairs(ping.requirements) do
	  assert(test_data[name] ~= nil, "missing a requirement for ping to continue")
	  self.data[name] = test_data[name]
   end
end

return ping
