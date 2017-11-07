#!/bin/sh

cat <<EOF > $1
local pcall, dofile, _G = pcall, dofile, _G

module "luci.version"

if pcall(dofile, "/etc/openwrt_release") and _G.DISTRIB_DESCRIPTION then
	distname    = ""
	distversion = _G.DISTRIB_DESCRIPTION
        distmodel   = _G.DISTRIB_MODEL
        distversionnumber  = _G.DISTRIB_VERSIONNUMBER
	if distmodel then
		--distrevision = _G.DISTRIB_REVISION
		if not distversion:find(distmodel,1,true) then
			distversion = distversion .. " " .. distmodel
		end
	end
else
	distname    = "OpenWrt"
	distversion = "Development Snapshot"
end

luciname    = "${3:-LuCI}"
luciversion = "${2:-Git}"
EOF
