NumLs = 52
MB = 11
CurrentMode = "Rainbow"
BR=224

dofile("Modes.lua")
dofile("MQTT.lua")

-- DNS-resolve an NTP time source and set the time/dst offset in the callback
function TST()
  net.dns.resolve("0.pool.ntp.org", ST)
end

TC = 0

function ChangeMode(mode)
  if type(_G[mode]) == "function" then
    CurrentMode = _G[mode]
	  if _G["Init"..mode] then
  	  local d = _G["Init"..mode]()
	    tmr.alarm(0, d, tmr.ALARM_AUTO, Ti)
	  else
  	  tmr.alarm(0, 250, tmr.ALARM_AUTO, Ti)
  	end
    return true
  end
  return false
end

function BL()
  Ls={}
  for i = 0, NumLs - 1 do
    local k = i * 4
    Ls[k + 1] = BR
    Ls[k + 2] = 0
    Ls[k + 3] = 0
    Ls[k + 4] = 0
  end
end

function ST2()
  if (rtctime.get() == 0) and (TC < 100) then
    tmr.alarm(1, 100, tmr.ALARM_SINGLE, ST2)
    TC = TC + 1
    return
  end
  LTU = rtctime.get()
  -- Go from unix timestamp to day of year (roughly)
  T = math.floor(((rtctime.get() % 126230400) % 31536000) / 86400)
  TZ = -8 -- PST = UTC-8
  if(T>=133 and T<310) then -- If during DST period, switch to PDT
    TZ = -7
  end
end

function ST(_, IPAddr)
  if IPAddr ~= nil then
    sntp.sync(IPAddr) 
	  TC = 0
    tmr.alarm(1, 2000, tmr.ALARM_SINGLE, ST2)
  else
    -- Failed to do DNS lookup; try again
    tmr.alarm(1, 500, tmr.ALARM_SINGLE, TST)
  end
end

-- Get current hour of the day as a floating-point number from 0 <= n < 24
function CH()
  return((rtctime.get() % 86400) / 3600 + 24 + TZ) % 24
end

-- In the "tail" of bits needed to properly command the DotStar strip
function IT()
  Tl = string.rep(string.char(0xff), NumLs*2)
end

-- S the control data to the DotStar strip
function S()
  return spi.send(1, 0, 0, 0, 0, Ls, Tl)
end

-- A the strip colours down the strip bit by bit
function A()
  for i = NumLs - 2, 0, -1 do
    local src = i * 4
    local dst = src + 4
    Ls[dst + 1] = Ls[src + 1]
	  Ls[dst + 2] = Ls[src + 2]
    Ls[dst + 3] = Ls[src + 3]
    Ls[dst + 4] = Ls[src + 4]
  end
end

-- Update Ti.  Calc BR, update LED strip colours, draw new LED at head, and push to strip
function Ti()
  T = CH()
  if T < 7 then
    BR = 1
  elseif T < 8 then
    BR = math.floor(1+((T%1)*30))
  elseif T < 22 then
    BR=31
  elseif T < 23 then
    BR = math.floor(31 - ((T % 1) * 30))
  else
    BR = 1
  end
  
  MB = math.min(math.max(MB, 0), 31)
  BR = math.min(MB, BR) + 224
  
  CurrentMode()
  
  -- Sync time every hour
  if LTU > 0 and (rtctime.get() - LTU > 3600) then
    TST()
	LTU = 0
  end
  
  S()
end

function AW()
	if wifi.sta.status() ~= 5 then
		tmr.alarm(1, 1000, tmr.ALARM_SINGLE, AW)
	else
		TST()
	end
end

-- Initialization function
function In()
  spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_HIGH, 8, 0)  
  TZ = 0
  LTU = 0
  AW()
  BL()
  IT()  
  InitMQTT()
  ChangeMode(CurrentMode)
end

print("Starting.  Call tmr.stop(1) to abort.")
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, In)