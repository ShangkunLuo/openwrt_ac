m = Map("uhttpdsim", translate("Web Server"))
m.on_after_commit = function() 
	require "luci.model.uci"
	local uci = luci.model.uci.cursor()	
        local port = uci:get("uhttpdsim","main","port")
	local l_list={"0.0.0.0:"..port,"[::]:"..port}
	uci:delete("uhttpd","main","listen_http")
	uci:set_list("uhttpd","main","listen_http",l_list)
        uci:commit("uhttpd")
	luci.sys.call("/etc/init.d/uhttpd restart") 
end
s=m:section(NamedSection,"main",translate("main"))
s.anonymous=true
--a=s:option(ListValue,"addr",translate("Address"))
--a:value("0.0.0.0")
p=s:option(Value, "port", translate("Port"),translate("If you change the port,the link will be disconnected!"))
p.datatype = "portrange"
p.placeholder = "0-65535"

return m
