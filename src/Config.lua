CONFIG = {}
-- defaults
-- CONFIG["GW_HOSTNAME"]="lorawangw"
-- CONFIG["GW_ROUTER"]="router.eu.thethings.network"
-- CONFIG["GW_NTP_SERVER"]="nl.pool.ntp.org"
-- CONFIG["GW_PORT"]=1700
-- CONFIG["GW_FREQ"]=868100000
-- CONFIG["GW_BW"]="BW125"
-- CONFIG["GW_SF"]="ALL"
-- CONFIG["GW_LAT"]="0.0"
-- CONFIG["GW_LON"]="0.0"
-- CONFIG["GW_ALT"]=0
-- CONFIG["GW_NSS"]=0
-- CONFIG["GW_DIO0"]=1
-- CONFIG["GW_DIO1"]=2
-- defaults
CONFIG["GW_HOSTNAME"]="lorawangw"
-- CONFIG["GW_ROUTER"]="router.us.thethings.network"
CONFIG["GW_ROUTER"]="192.168.2.106"
-- CONFIG["GW_NTP_SERVER"]="nl.pool.ntp.org"
CONFIG["GW_NTP_SERVER"]="us.pool.ntp.org"
-- CONFIG["GW_PORT"]=1700
CONFIG["GW_PORT"]=1680
CONFIG["GW_FREQ"]=904300000
CONFIG["GW_BW"]="BW125"
CONFIG["GW_SF"]="ALL"
CONFIG["GW_LAT"]="32.79242" --djl Fanuel Park "0.0"
CONFIG["GW_LON"]="-117.24457" --djl "0.0"
CONFIG["GW_ALT"]=2 --djl 0
CONFIG["GW_NSS"]=0
CONFIG["GW_DIO0"]=8 --djl D8 1
CONFIG["GW_DIO1"]=1 --djl D1 2

local function printConfig()
  print("Configuration")
  print("\tGW_HOSTNAME",'"'..CONFIG["GW_HOSTNAME"]..'"')
  print("\tGW_ROUTER  ",'"'..CONFIG["GW_ROUTER"]..'"')
  print("\tGW_PORT    ",'"'..CONFIG["GW_PORT"]..'"')
  print("\tGW_FREQ    ",CONFIG["GW_FREQ"])
  print("\tGW_BW      ",'"'..CONFIG["GW_BW"]..'"')
  print("\tGW_SF      ",'"'..CONFIG["GW_SF"]..'"')
  print("\tGW_LAT     ",'"'..CONFIG["GW_LAT"]..'"')
  print("\tGW_LON     ",'"'..CONFIG["GW_LON"]..'"')
  print("\tGW_ALT     ",CONFIG["GW_ALT"])
  print("\tGW_NSS     ",CONFIG["GW_NSS"])
  print("\tGW_DIO0    ",CONFIG["GW_DIO0"])
  print("\tGW_DIO1    ",CONFIG["GW_DIO1"])
end

local function saveConfig()
  CONFIG.save=nil
  CONFIG.print=nil
  file.open('config.json',"w+")
  file.write(cjson.encode(CONFIG))
  file.close()
  CONFIG.save=saveConfig
  CONFIG.print=printConfig
end

if file.exists('config.json') then
  file.open('config.json')
  local json=file.read()
  file.close()
  CONFIG=cjson.decode(json)
else
  print("no config found, using default values")
end

CONFIG.print=printConfig
CONFIG.save=saveConfig

-- a simple telnet server
local s=net.createServer(net.TCP)
s:listen(23,function(c)
  con_std = c
  function s_output(str)
    if(con_std~=nil)
    then con_std:send(str)
    end
  end
  node.output(s_output, 0)   -- re-direct output to function s_ouput.
  c:on("receive",function(c,l)
    node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
  end)
  c:on("disconnection",function(c)
    con_std = nil
    node.output(nil)        -- un-regist the redirect output function, output goes to serial
  end)
  print("LoRaWanGateway")
  printConfig()
  statistics()
end)
