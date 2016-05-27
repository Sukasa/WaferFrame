dofile("Modes.lua")
NumLEDs = 60
CurrentMode = "Rainbow"
MaxBrightness = 31

-- DNS-resolve an NTP time source and set the time/dst offset in the callback
function TrySetTime()
  net.dns.resolve("0.pool.ntp.org", SetTime)
end

TimeCount = 0

function ChangeMode(mode)
  if type(_G[mode]) == "function" then
    CurrentMode = _G[mode]
	if _G["Init"..mode] then
	  local d = _G["Init"..mode]()
	  tmr.alarm(0, d, tmr.ALARM_AUTO, Tick)
	else
	  tmr.alarm(0, 250, tmr.ALARM_AUTO, Tick)
	end
    return true
  end
  return false
end

function Blank()
  LEDs={}
  for i = 0, NumLEDs - 1 do
    local k = i * 4
    LEDs[k + 1] = 240
    LEDs[k + 2] = 0
    LEDs[k + 3] = 0
    LEDs[k + 4] = 0
  end
end

function SetTime2()
  if (rtctime.get() == 0) and (TimeCount < 100) then
    tmr.alarm(1, 100, tmr.ALARM_SINGLE, SetTime2)
    TimeCount = TimeCount + 1
    return
  end
  LastTimeUpdate = rtctime.get()
  -- Go from unix timestamp to day of year (roughly)
  T = math.floor(((rtctime.get() % 126230400) % 31536000) / 86400)
  Timezone = -8 -- PST = UTC-8
  if(T>=133 and T<310) then -- If during DST period, switch to PDT
    Timezone = -7
  end
  print("Time sync complete")
end

function SetTime(_, IPAddr)
  if IPAddr ~= nil then
    sntp.sync(IPAddr) 
	TimeCount = 0
    tmr.alarm(1, 2000, tmr.ALARM_SINGLE, SetTime2)
  else
    -- Failed to do DNS lookup; try again
    tmr.alarm(1, 500, tmr.ALARM_SINGLE, TrySetTime)
  end
end

-- Get current hour of the day as a floating-point number from 0 <= n < 24
function CurrentHour()
  return((rtctime.get() % 86400) / 3600 + 24 + Timezone) % 24
end

-- Initialize the "tail" of bits needed to properly command the DotStar strip
function InitTail()
  Tail = {}
  for i = 1, NumLEDs * 2 do
    Tail[i] = 0xff
  end
end

-- Send the control data to the DotStar strip
function Send()
  return spi.send(1, 0, 0, 0, 0, LEDs, Tail)
end

-- Advance the strip colours down the strip bit by bit
function Advance()
  for i = NumLEDs - 2, 0, -1 do
    local src = i * 4
    local dst = src + 4
    LEDs[dst + 1] = LEDs[src + 1]
	LEDs[dst + 2] = LEDs[src + 2]
    LEDs[dst + 3] = LEDs[src + 3]
    LEDs[dst + 4] = LEDs[src + 4]
  end
end

-- Update tick.  Calc brightness, update LED strip colours, draw new LED at head, and push to strip
function Tick()
  T = CurrentHour()
  if T < 7 then
    Brightness = 1
  elseif T < 8 then
    Brightness = math.floor(1+((T%1)*30))
  elseif T < 22 then
    Brightness=31
  elseif T < 23 then
    Brightness = math.floor(31 - ((T % 1) * 30))
  else
    Brightness = 1
  end
  
  MaxBrightness = math.min(math.max(MaxBrightness, 0), 31)
  Brightness = math.min(MaxBrightness, Brightness) + 224
  
  CurrentMode()
  
  -- Sync time every hour
  if LastTimeUpdate > 0 and (rtctime.get() - LastTimeUpdate > 3600) then
    TrySetTime()
	LastTimeUpdate = 0
  end
  
  Send()
end

function AwaitWifi()
	if wifi.sta.status() ~= 5 then
		tmr.alarm(1, 1000, tmr.ALARM_SINGLE, AwaitWifi)
	else
		print("WiFi connection detected - getting time...")
		TrySetTime()
	end
end

-- Initialization function
function Initialize()
  print("Starting program...")

  spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_HIGH, 8, 0)
  
  Timezone = 0
  LastTimeUpdate = 0
  AwaitWifi()

  ChangeMode(CurrentMode)

  InitTail()
  tmr.alarm(0, 10, tmr.ALARM_AUTO, Tick)
end

print("Starting.  Call tmr.stop(1) to abort.")
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, Initialize)