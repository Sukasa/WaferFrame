function InitRainbow()
  BL()
  Steps = {
      0,  1,  0,
     -1,  0,  0, 
      0,  0,  1,
      0, -1,  0,
      1,  0,  0,
      0,  0, -1,
      1,  0,  0
  }
  StepCount = 6
  MaxSteps = 255
  Step = 6
  StepsRemaining = MaxSteps
  return 10
end

function Rainbow()
  A()
  
  Ls[1] = BR
  Ls[2] = Ls[2] + Steps[Step * 3 + 1]
  Ls[3] = Ls[3] + Steps[Step * 3 + 2]
  Ls[4] = Ls[4] + Steps[Step * 3 + 3]
  
  StepsRemaining = StepsRemaining - 1
  if (StepsRemaining == 0) then
    StepsRemaining = MaxSteps
    if Step == 6 then
      Step = -1
    end
    Step = (Step + 1) % StepCount
  end
end

function InitChaser()
  BL()
  Step = 0
  Xk = Step
  StepCount = 1
  MaxSteps = 18
  return 50
end

function InitChaser2()
  Steps = {
     255,   0,   0,
       0, 255,   0,
       0,   0, 255,
     255,   0, 255,
       0, 255, 255,
     255, 255,   0,
     255, 255, 128
  }
  CStep = 0
  CStepCount = 7
  return InitChaser()
end

function Chaser()
  Ls[Xk*4+2]=0
  Ls[(44-Xk)*4+2]=0
  Ls[Step*4+2]=64
  Ls[(44-Step)*4+2]=64
  Xk = Step
  Step=Step+StepCount  
  Ls[Step*4+2]=255
  Ls[(44-Step)*4+2]=255
  if Step == 0 or Step == MaxSteps then
    StepCount = -StepCount
  end
end

function Chaser2()
  Ls[Xk*4+2]=0
  Ls[Xk*4+3]=0
  Ls[Xk*4+4]=0
  
  Ls[(44-Xk)*4+2]=0
  Ls[(44-Xk)*4+3]=0
  Ls[(44-Xk)*4+4]=0
  
  Ls[Step*4+2]=(Steps[CStep*3+1]+1)/4
  Ls[Step*4+3]=(Steps[CStep*3+2]+1)/4
  Ls[Step*4+4]=(Steps[CStep*3+3]+1)/4
  
  Ls[(44-Step)*4+2]=(Steps[CStep*3+1]+1)/4
  Ls[(44-Step)*4+3]=(Steps[CStep*3+2]+1)/4
  Ls[(44-Step)*4+4]=(Steps[CStep*3+3]+1)/4
  
  Xk = Step
  Step=Step+StepCount  
  
  Ls[Step*4+2]=Steps[CStep*3+1]
  Ls[Step*4+3]=Steps[CStep*3+2]
  Ls[Step*4+4]=Steps[CStep*3+3]
  
  Ls[(44-Step)*4+2]=Steps[CStep*3+1]
  Ls[(44-Step)*4+3]=Steps[CStep*3+2]
  Ls[(44-Step)*4+4]=Steps[CStep*3+3]
  
  if Step == 0 or Step == MaxSteps then
    StepCount = -StepCount
  end
  if Step == 0 then
    CStep = (CStep + 1) % CStepCount
  end
end

function InitParty()
  return 100
end

function Party()
  for i=0,NumLs-1 do
    local k=i*4
    Ls[k+1]=BR
    Ls[k+2]=math.random(255)
    Ls[k+3]=math.random(255)
    Ls[k+4]=math.random(255)
  end
end

function InitChristmas()
  BL()
  Steps = {
     255,   0,   0,
       0, 255,   0,
       0,   0, 255,
     255,   0, 255
  }
  Step = 0
  Xk = 0
  StepCount = 4
  return 600
end

function Christmas()
  A()
  if Xk > 0 then
    Ls[1] = BR
    Ls[2] = 0
    Ls[3] = 0
    Ls[4] = 0
  else
    Ls[1] = BR
    Ls[2] = Steps[Step*3+3]
    Ls[3] = Steps[Step*3+2]
    Ls[4] = Steps[Step*3+1]
    Step = ((Step + 1) % StepCount)
  end
  Xk = (Xk + 1) % 3
end

function InitNetflix()
  BL()
  return 250
end

function Netflix()
  -- Nothing
end

function InitWhite()
  BL()
  for i=0,NumLs-1 do
    Ls[i*4+2]=255
    Ls[i*4+3]=160
    Ls[i*4+4]=96
  end
  return 100
end

function White()
  for i=0,NumLs-1 do
    Ls[i*4+1]=BR
  end
end

function InitRomantic()
  BL()
  Step = 0
  StepCount = 1
  return 30
end

function Romantic()
  A()
  Step = Step + StepCount
  if Step == 0 or Step == 255 then
    StepCount = -StepCount
  end
  local Hint = math.floor(math.max(0, Step - 96) / 4)
  Ls[1]=BR
  Ls[4]=Step
  Ls[3]=Hint
  Ls[2]=Hint
end