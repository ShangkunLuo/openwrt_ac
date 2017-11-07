module("luci.controller.uhttpdsim",package.seeall)


function index()
	
    entry({"admin","system","uhttpdsim"},cbi("admin_system/uhttpdsim"),translate("Web Server"),70)

end
