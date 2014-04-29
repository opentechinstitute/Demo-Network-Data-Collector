local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local apps = {}


apps.data = {}
apps.results = {}

--get reqs just returns the information it needs to do its work.
function apps:get_reqs()
    return nil
end

function apps:run_tests(test_data)
   self:get_known()
   self:get_all()
   return self.results
end


function apps:get_known()
--[[config known_apps 'known_apps'
	option 102_46214_46146_46509001 'approved'
	option http_58_47_47102_46214_46146_4650_585984_47media_47_95design_47media_47index_46html 'approved'
	option 102_46214_46146_46503002 'approved'
	option http_58_47_47102_46214_46146_4650_589001_47 'approved']]--
   local known_apps = uci:get_all("applications", "known_apps")
   self.results['known_apps'] = known_apps
end

function apps:get_all()
   local applications = {}
   uci:foreach("applications",
			   "application",
			   function(s)
				  applications[s['.name']] = {}
				  for v_name, value in pairs(s) do
					 applications[s['.name']][v_name] = value
				  end
   )
   self.results['applications'] = applications
end

return apps




--[[
   THIS is what the config file looks like.
   
   config settings 'settings'
	option autoapprove '1'
	option expiration '86400'
	option allowpermanent '1'
	option disabled '0'
	list category 'Community'
	list category 'Collaboration'
	list category 'Fun'
	option checkconnect '0'

config known_apps 'known_apps'
	option 102_46214_46146_46509001 'approved'
	option http_58_47_47102_46214_46146_4650_585984_47media_47_95design_47media_47index_46html 'approved'
	option 102_46214_46146_46503002 'approved'
	option http_58_47_47102_46214_46146_4650_589001_47 'approved'

config application '102_46214_46146_46503002'
	option name 'IS4CWN Tidepools'
	option protocol 'IPv4'
	option ttl '5'
	option ipaddr '102.214.146.50'
	option port '3002'
	option uuid '102_46214_46146_46503002'
	option fingerprint 'C87F9F7399E087D536FDA825A60C7BEECB5A5B403DA31F637AC001066B6A6756'
	option signature 'AED1F10BE4FD3F6821A35CBA98ABC4EF4EFE8CEDF10B64EEB4AF7C010AF6242254AEA2B357062B602637821D6FDB08906BF045C253E79C3F27CBF276CDE3F305'
	option icon 'http://thisnode/luci-static/commotion/commotion_tiny.png'
	option description 'Tidepools provides a map of the Summit locations and sessions, including an Etherpad link for each session for collaborative note taking. You also can add your own events and locations to the map, such as a meeting or a great place to eat.'
	option expiration 'Thu Oct  3 22:55:07 2013'
	option approved '1'
	option noconnect '0'
	list type 'Collaboration'

config application 'http_58_47_47102_46214_46146_4650_589001_470'
	option name 'Etherpad'
	option protocol 'IPv4'
	option ttl '5'
	option ipaddr 'http://102.214.146.50:9001/'
	option uuid 'http_58_47_47102_46214_46146_4650_589001_470'
	option fingerprint 'C87F9F7399E087D536FDA825A60C7BEECB5A5B403DA31F637AC001066B6A6756'
	option signature 'E0CD37FDB95ACE902D869C3A8AEF681C446BDE0E56A1455E91C5790841805A4442BD24881B1DF54428F90AB284EC1BB218F6DD51FAFDA39CC8AFC8157A78E408'
	option icon 'http://103.214.146.1/luci-static/commotion/commotion_tiny.png'
	option description 'Etherpad is a collaborative document-editing tool available for taking notes during conference sessions. Check out the Tidepools map, which has etherpad links for each session.'
	option expiration 'Thu Oct  3 22:55:10 2013'
	option approved '1'
	option noconnect '0'
	list type 'Collaboration'

config application 'http_58_47_47102_46214_46146_4650_585984_47media_47_95design_47media_47index_46html0'
	option name 'MediaGrid'
	option protocol 'IPv4'
	option ttl '5'
	option ipaddr 'http://102.214.146.50:5984/media/_design/media/index.html'
	option uuid 'http_58_47_47102_46214_46146_4650_585984_47media_47_95design_47media_47index_46html0'
	option fingerprint 'C87F9F7399E087D536FDA825A60C7BEECB5A5B403DA31F637AC001066B6A6756'
	option signature '161C1C68F032A89478E1EA7AE72EA7AC387C668684962E8A6CF171C135D6F8012215DAADDA3672B2CEBE95A26930D55899E490F9FA77AA8B023C8E642E83730B'
	option icon 'http://103.214.146.1/luci-static/commotion/commotion_tiny.png'
	option description 'File sharing and encrypted web chat for IS4CWN 2013. Upload photos and documentation, presentation materials, anything you would like!'
	option expiration 'Thu Oct  3 22:55:11 2013'
	option approved '1'
	option noconnect '0'
	list type 'Collaboration']]--
