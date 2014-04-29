Quantitative Data Collected by the Test Harness

Each demo kit is equipped with a Raspberry Pi, used to run a standard network data collection program assessing ??? link quality between nodes, number of clients, amount of data transfer, ???

The current test harness Includes the following Metrics

Logfiles (simply grabbing logfiles)
 internet connectivity (ping time to internet from node)
 mesh connectivity (ping time to all nodes on network from node)
 
 distance to internet (traceroute to internet from node)
 distance to all nodes on network (traceroute from node)
 
 Actual throughput (iperf unidirectional and bidirectional)
 Available bandwidth (iperf)
 number of clients (Arp table or station dump compared with nodogsplash client list)

Client information (nodogsplash  total and per client  info from ndsctl status & clients)
 amount of time active (uptime)
 total amount of data down/up-loaded
 average amount of data  down/up-load speed
 address being used by clients
 Clients who have leases

Desired and scripted, but not integrated into the harness
 OLSR neighbor, routes, etc. list (TXT-info)
 unique users on the network (MACs of clients with leases over time compared)

Desired, unimplemented & unintegrated, tests
 CPU load
 Applications on network (/etc/config/application per node for propegation)
 RF of nearby nodes (station dump per node)
 wireless & network configuration (/etc/config files)
 Capacity of network to handle streaming data (Jitter configuration for iperf)




Test Harness Componsition

* Router Client
  * Built in SSH key for test-server
  * Built in SSH key that all nodes respond to from each other. (so they can request iperf server, etc.)
  * Extra packages needed
    * iperf
    * LuCI Json-RPC
  * On node Test suite

** Test Suite:
The test suite will consist of a controller script that accepts commands and calls a series of test scripts.

** Architecture:

  * Controller: Accepts RPC commands from "test server" to run certain tests on the network.
    * Network Info: Grabs and parses olsr-info into a lua table that can be used to  a list of nodes on the network as well as if a gateway exists.
  * Tests:
    * 

Test Server
  * Test harness



Test sending data to and back on testbed with ssh keys.

Prototype: