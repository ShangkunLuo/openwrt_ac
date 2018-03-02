--[[
	http://www.redwave.cc
]]--

module("luci.controller.tz_qos", package.seeall)


function index()
	local fs = require "nixio.fs"
	if fs.access("/etc/config/tz-qos") then
		entry({"admin", "network","tz-qos"}, cbi("tz_qos"), "TZ QOS", 40)
		end
	
end

