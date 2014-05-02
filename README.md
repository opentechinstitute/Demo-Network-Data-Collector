A data collector for commotion wireless demonstration and test networks.

### NOT to be used on production networks or networks with sensitive data.

## Architecture

The demonstration network data collector is a two part code-base.

The first component is the *test harness.* The harness is a python automated test framework that will be run on a raspberry-pi (or other debian installed device) that is connected to a demonstration or test network. This tool is responsible for identifying the devices on the network, initiating the test suite contained on them, monitoring and organizing the completion of tests on the network, collecting the output of those tests, and collating the results for easy analysis.

The second component is the on-router *test suite.* This lua based test-suite will run a series of tests between itself and all the other nodes on the network and then send the results back to the test harness device.

### Harness (pi)

The harness has the following responsibilities.

  * Start tests on test suites using an ssh command
  * Create a server to receive test data.
  * Attempt to retry tests that fail.
  * Collect all tests from entire network
  * The ability to be run at various intervals (cron job)

### test suites (node)

The network nodes require the following extra components
  * Loaded with the public key of the test harness to accept commands from it.
  * Built in public [single purpose SSH key](http://blog.jolexa.net/2011/02/tip-single-purpose-password-less-ssh-key/) for harness & other nodes to accept specific commands required for testing
  * auto-start script to capture restarts for long-running demo networks.

The test suites have the following responsibilities.
  * Identify all devices on the network.
  * Run tests against/with other nodes on the network.
  * Gather results from tests.
  * Send results from all tests back to initial server.
  * Give updates on the test status when requested?
  * Be able to cancel stalled tests

#### tests
  * application
    * This test will gather data about the applications advertised on the node.
  * stability (restart data)
    * This test will check a specified file that records restart times and capture all restarts and the current node time. The current node time is needed in networks without internet access to sync with the times that the client is recording for when that test is initialized. These three times will give comparisons across the times that will allow for the *real* time to be identified.
  * clients
    * This test will gather the no-dog-splash client data as well as the data about currently connected clients to identify how many unique users were using the network, from what nodes, at what rate.
    * number of clients (Arp table or station dump compared with nodogsplash client list)
    * Client information (nodogsplash  total and per client  info from ndsctl status & clients)
      * amount of time active (uptime)
      * total amount of data down/up-loaded
      * average amount of data  down/up-load speed
      * address being used by clients
      * clients who have leases
  * iperf
    * This test will gather the actual througput, bandwidth, and jitter of a link between the node and the rest of the network.
    * Actual throughput (iperf unidirectional and bidirectional)
    * Available bandwidth (iperf)
    * Capacity of network to handle streaming data (Jitter configuration for iperf)
  * ping
    * This test will give a basic connectivity measure between the node and all devices on the network.
	* internet connectivity (ping time to internet from node)
    * mesh connectivity (ping time to all nodes on network from node)
  * radio (station dump)
    * This test will give radio information about nearby wireless devices to allow us to calculate the effect of the radio environment on our networks.
    * RF of nearby nodes (station dump per node)
  * traceroute
    * This test will gather *actual* routing data for packets sent between nodes. This will capture the *real* path, instead of the assumptions based upon the  routing table of the path.
    * distance to internet (traceroute to internet from node)
    * distance to all nodes on network (traceroute from node)
  * Node Info
    * CPU load
## Hardware Requirements
This demo setup will require a device to act as the test harness. We will be using raspberry pi's for this. It will also require one or more router clients that have the full commotion install.

## Setup
  * Create SSH keys.
  * Create openwrt images. (Integration with Commotion build script still needs to be done.)
  * Install openwrt images on routers.
  * Install Raspberry-pi with debian derivative.
  * Install harness & ssh keys on Raspberry-pi.
  * Run harness setup scripts on pi
  * Connect raspberry-pi to a mesh node over Ethernet.
  * Setup rest of mesh-network

### Harness setup scripts

The harness setup scripts will do a series of things.

  * Create the required directories for data storage.
  * setup a cron job for how often the tests should be run.
  * firewall configuration?
  * possibly run a network-setup set of custom tests from just the node it is plugged into to get quicker snapshots of the network and its connectivity over the setup period? This would give us a great *live* view of how network setup occurred, what changes the team made over time, etc. The data here would be useful for making network setup quicker, more efficiant, etc.
  
## Test Flow

### Harness Startup

  * The harness will create a new test folder for this round of tests in the testing data directory and a test info logfile.
  * The harness will log the full testing start time in the test info log
  * The harness will start up a simple socket server to receive test data on.

### Harness Network Identification
  * The harness will request the network neighbor information from the node it is directly connected to using the single purpose testing ssh key.
  * The harness will then create a test-schedule using this list of available nodes.
  
### Test initialization
  * The harness will log the test start time in the test info log
  * The harness will initialize the test using the single purpose testing ssh key.
  * The node will create a list of nodes on the network
  * The node will then run through the requested tests against/with the nodes it can see on the network and the harness server.
    * Any tests that require another node to cooperate (iperf) will be started using a single purpose ssh key
    * All non-cooperative tests will be run against all nodes (and pre-configured internet sites and the test harness for some tests)
	* All tests will be stored in both raw form and in somewhat parsed formats.
### test response
  * The node will open up a socket to the test harness server and dump the JSON data to the server
  * The harness will save the JSON data received
  * The harness will take key data points about that nodes tests and save them to the test info logfile
### test storage
  * The harness will log the test end time in the test info log
  * If the node did not return data the harness will log a failed test.
  * The harness will parse the JSON log and pull out some *key* information to populate into a summary section of the log-data.
### iteration
  * The harness will continue this test process for every node in the test schedule
  * If any nodes failed to return data the test harness will attempt to retry those tests again at the end.
  * Once complete the test harness will one again request network neighbor information from its directly connected node and compare the returned list with its test harness. It will then run tests on any new nodes on the network.
## test analysis
  * The harness will log the full testing end time in the test info log
  * The harness will gather cross-node information about the network
    * unique users on the network (MACs of clients with leases over time compared)
## Roadmap / TODO 
  * Simple harness socket server (Done)
  * Simple socket sender for node (in process)
  * harness setup scripts
  * harness data collection and collation scripts
  * harness test logging/timing tools
  * node test scripts (in process)
  * node test runner (in process)
  * harness data analysis scripts
  * harness data visualization web-server (not planned, just a future wish.)
