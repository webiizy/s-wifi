-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.
local nw  = require "luci.model.network".init()
local ifaces = nw.get_interfaces()                       
local iface
m=Map("coovachilli")

s1 = m:section(TypedSection, "interface")
hs_wan=s1:option( ListValue, "HS_WANIF","WAN interface:")
hs_wan:value("default","default")
for  i,iface in ipairs(ifaces) do
        hs_wan:value(iface:name(),iface:name())
end
hs_wan.default="default"

hs_lan=s1:option( ListValue, "HS_LANIF","LAN interface:")
hs_lan.default="br-lan"
--hs_lan:value("eth1","interface 1")
--hs_lan:value("eth0","interface 2")
for  i,iface in ipairs(ifaces) do
        hs_lan:value(iface:name(),iface:name())
end

s5 = m:section(TypedSection, "hotspot")
hs_check=s5:option( Flag, "HS_HOTSPOT_CHECK", "Enable Hotspot:" )

s2 = m:section(TypedSection, "uam_server")

hs_uf=s2:option( Value, "HS_UAMFORMAT","Link Login:")
hs_us=s2:option( Value, "HS_UAMSECRET","UAM secret:")
hs_ua=s2:option( TextValue, "HS_UAMALLOW","Wall gaden:")

s3 = m:section(TypedSection, "dns_server")

hs_d1=s3:option( Value, "HS_DNS1","DNS 1:")
hs_d2=s3:option( Value, "HS_DNS2","DNS 2:")

s4 = m:section(TypedSection, "radius_server")

hs_r1=s4:option( Value, "HS_RADIUS","Radius 1:")
hs_r2=s4:option( Value, "HS_RADIUS2","Radius 2:")
hs_rs=s4:option( Value, "HS_RADSECRET","Radius secret:")

--lib
function read_nested(file)
--    if not Path.isfile(file) then return nil end

    local file = io.open(file, "r")
    local d = {}
    local h = {}
    local r = {}
    local p = d
    local i = 0

    local function parse(line)
        local m, n

        -- section opening
        m = line:match("^[%s]*%[([^/.]+)%]$")
        if m then
            table.insert(h, { p, m=m })
            p[m] = {}
            p = p[m]
            return true
        end

        -- section closing
        m = line:match("^[%s]*%[/([^/.]+)%]$")
        if m then
            local hl = #h
            if hl == 0 or h[hl].m ~= m then
                return nil
            end
            p = table.remove(h).p
            if not p then p = d end
            return true
        end

        -- kv-pair
        m,n = line:match("^[%s]*([%w%p]-)=(.*)$")
        if m then
            p[m] = n
            return true
        end

        -- ignore empty lines
        if line:match("^$") then
            return true
        end

        -- ignore comments
        if line:match("^#") then
            return true
        end

        -- reject everything else
        return nil
    end

    for line in file:lines() do
        i = i + 1
        if not parse(line) then
            table.insert(r, i)
        end
	end
	file:close()
	return d,r   
end

function write(file, data)
--    if type(data) ~= "table" then return nil end
    local file = io.open(file, "w")
    if not file then
        return nil
    end
    for k,v in pairs(data) do
            file:write(string.format("%s=%s\n", tostring(k), tostring(v)))
    end
    file:close()
    return true
end

--local test= uci.get("coovachilli", "interface", "HS_WANIF")


function m.on_save(self)
	local path = "/etc/chilli/defaults"
	local dataconf = read_nested(path)
	dataconf["HS_LANIF"]=m:get("Interface","HS_LANIF")
	dataconf["HS_UAMFORMAT"]=m:get("UAM","HS_UAMFORMAT")
	dataconf["HS_UAMSECRET"]=m:get("UAM","HS_UAMSECRET")
	dataconf["HS_UAMALLOW"]=m:get("UAM","HS_UAMALLOW")
	dataconf["HS_DNS1"]=m:get("DNS","HS_DNS1")
	dataconf["HS_DNS2"]=m:get("DNS","HS_DNS2")
	dataconf["HS_RADIUS"]=m:get("Radius","HS_RADIUS")
	dataconf["HS_RADIUS2"]=m:get("Radius","HS_RADIUS2") 
	dataconf["HS_RADSECRET"]=m:get("Radius","HS_RADSECRET")
	hotspot_enable=m:get("Hotspot","HS_HOTSPOT_CHECK")  
        if hotspot_enable == nil or hotspot_enable == ''    
        then                                                              
                dataconf["HS_HOTSPOT_CHECK"]=0                 
        else                                                 
                dataconf["HS_HOTSPOT_CHECK"]=m:get("Hotspot","HS_HOTSPOT_CHECK")
        end
	hs_wanif=m:get("Interface","HS_WANIF")
	if hs_wanif ~= nil and tostring(hs_wanif) ~= "default"
	then
		dataconf["HS_WANIF"]=hs_wanif
	else
		dataconf["HS_WANIF"]=nil
	end
	write(path,dataconf)	
	os.execute("/etc/init.d/chilli restart &")
end

function m.on_after_save(self)
	--luci.util.exec("/etc/init.d/chilli restart")
	--os.execute("/etc/init.d/chilli restart &")
end

return m
