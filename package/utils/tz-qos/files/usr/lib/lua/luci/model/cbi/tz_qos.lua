
local m,s,o


m=Map("tz-qos")


s=m:section(TypedSection,"tzqos",translate("TZ QOS"))

s.anonymous=true

s:tab("tzqos")
o=s:taboption("tzqos",Flag,"enable",translate("On/Off"))
o=s:taboption("tzqos",Value,"up",translate("Upload limit"), translate("kbit/s"))
o=s:taboption("tzqos",Value,"down",translate("Download limit"), translate("kbit/s"))




local apply=luci.http.formvalue("cbi.apply")
if apply then
        io.popen("/sbin/qos.sh")   
end     
     


return m








