
local m,s,o


m=Map("tz-qos")


s=m:section(TypedSection,"tzqos",translate("TZ QOS"))

s.anonymous=true

s:tab("tzqos")
o=s:taboption("tzqos",Flag,"enable",translate("On/Off"))
o=s:taboption("tzqos",Value,"up",translate("上行带宽限制"), translate("kbit/s"))
o=s:taboption("tzqos",Value,"down",translate("下行带宽限制"), translate("kbit/s"))




local apply=luci.http.formvalue("cbi.apply")
if apply then
        io.popen("/sbin/qos.sh")   
end     
     


return m








