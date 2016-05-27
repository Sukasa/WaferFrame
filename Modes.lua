function InitRainbow()
  Blank()
  Steps = {
    {  0,  1,  0 },
    { -1,  0,  0 },
    {  0,  0,  1 },
    {  0, -1,  0 },
    {  1,  0,  0 },
    {  0,  0, -1 }
  }
  StepCount = 6
  MaxStepsRemaining = 255
  CurrentStep = { 1, 0, 0 }
  CurrentStepNum = 0
  StepsRemaining = MaxStepsRemaining
  return 10
end

function Rainbow()
  Advance()
  
  LEDs[1] = Brightness
  LEDs[2] = LEDs[2] + CurrentStep[1]
  LEDs[3] = LEDs[3] + CurrentStep[2]
  LEDs[4] = LEDs[4] + CurrentStep[3]
  
  StepsRemaining = StepsRemaining - 1
  if (StepsRemaining == 0) then
    StepsRemaining = MaxStepsRemaining
    CurrentStepNum = (CurrentStepNum % StepCount) + 1
    CurrentStep = Steps[CurrentStepNum]
  end
end

function InitParty()
  return 100
end

function Party()
  for i=1,NumLEDs do
    local k=i*4
    LEDs[k]=Brightness
    LEDs[k+1]=math.random(255)
    LEDs[k+2]=math.random(255)
    LEDs[k+3]=math.random(255)
  end
end

function InitChristmas()
  Blank()
  return 600
end

function Christmas()
  Advance()
  LEDs[1] = Brightness
  LEDs[2] = XC[XS*3+3]
  LEDs[3] = XC[XS*3+2]
  LEDs[4] = XC[XS*3+1]
  XS = (XS % XSM) + 1
end

function InitRomantic()
  Blank()
  XC = {
    { 255,   0,   0},
    {   0, 255,   0},
    {   0,   0, 255},
    { 255, 255,   0}
  }
  XS = 1
  XSM = 4
  RomVal = 0
  RomMod = 1
  return 30
end

function Romantic()
  Advance()
  RomVal = RomVal + RomMod
  if RomVal == 0 or RomVal == 255 then
    RomMod = -RomMod
  end
  local Hint = math.floor(math.max(0, RomVal - 96) / 4)
  LEDs[1]=Brightness
  LEDs[4]=RomVal
  LEDs[3]=Hint
  LEDs[2]=Hint
end