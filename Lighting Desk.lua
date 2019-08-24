--*************************************************************
--*************************************************************

--CHANGE THE TWO VARIBALES BELOW TO YOUR NUMBER OPF SCENES AND CHANNELS NEEDED, SCENE FADER MUST EQUAL THE AMOUNT OF MOMENTARY BUTTONS CONNECTED TO THE CONTROL SCRIPT INPUT
--CHANNEL FADERS ARE CONNECTED TO CONTROL SCRIPT FIRST AND MUST BE AN INTEGER FADER/KNOB FROM 0 - 255 IN VALUE
--SCENES FADER ARE CONNECTED TO THE CONTROL SCRIPT INPUT NUMBER : NUM_CHANNELS +1 AND ALSO BE AN INTEGER FADER/KNOB FROM 0 - 255 IN VALUE
--MASTER FADER MUST BE CONNECTED TO CONTROL SCRIPT INPUT NUMBER : NUM_CHANNELS + NUM_SCENES +1. 
--MOMENTARY BUTTON ARE USED FOR SCENE STATE RECORDERS THEY ARE CONNECTED TO CONTROL SCRIPT INPUT NUMBER: NUM_CHANNELS + NUM_SCENES +2 
--OUTPUT CVUSTOM CONTROL LEDS ARE TO BE LINKED UP ON THE OUPUT PINS AFTER THE TEXT OUTPUT. BOTH THESE OUPUT PINS ARE EQUAL TO THE NUMBER OF CHANNELS 

NUM_CHANNELS = 24 -- CHANGE THIS VARIABLE FOR NUMBER OF CHANNELS IN YOUR DESK DESIGN
NUM_SCENES  = 16 -- CHANGE THIS VARIABLE FOR NUMBER OF SCENE FADERS IN YOUR DESK DESIGN


--******************************************************
--******************************************************


-- Create meta classes 
local channels = {}
local subgroup = {}
local master = {}
local output = {}


------------------------
--CHANNEL CLASS
------------------------
channels.new = function(id, value) 
  local self = {}
  local value = value
  local inputId = id 

self.setValue = function(_value)
  value = _value
  end
self.printValue = function(arg) 
  print(value)
end

self.getValue = function()
  return value
end

self.getId = function()
  return inputId
end
return self
end

--------------------------
-- SUBGROUP CLASS
--------------------------
subgroup.new = function(id, _value)
  local self = {}
  local channelStateArray = {}
  local groupId = id 
  local value = _value
   
self.setSceneState = function(channelStates)
  for i=1,NUM_CHANNELS do 
    channelStateArray[i] = channelStates[i].getValue()
  end
end  

self.setFaderValue = function(_value)
  value = _value
end

self.printValue = function()
  print(value)
end

self.printState = function()
  print("Subgroup state: ")
  for i=1,NUM_CHANNELS do
  if channelStateArray[i] == nil then
    print("nil")
  else
    print(channelStateArray[i])
  end
  end
  
end

self.getChannelStateArray = function()
  return channelStateArray
end

self.getFaderValue = function()
  return value
  end
return self
end

-----------------
--OUTPUT CLASS
-----------------
output.new = function(channel, id, master)
  self = {}
  self.channel = channel
  self.ouputValue = Controls.Outputs[id].Value
  local master = master

self.findHighest = function(v1, v2)
  if v1 > v2 then
    return v1
  else
    return v2
  end
end
-- ADDS TOGETHER SCENE STATE AND MAPS IT TO CHANNELS OUPUT
self.addScenesToOutput = function(subgroupArray, event)
  local _val
  local subgroup
  local subgroupFaderVal
  local highestvalue = 0

  for i=1,NUM_SCENES do
    subgroup = subgroupArray[i]
    subgroupFaderVal = subgroup.getFaderValue()
    if subgroup.getChannelStateArray()[event.Index] ~= nil then 
      channelValue = subgroup.getChannelStateArray()[event.Index]
      if subgroupFaderVal == 0 then 
        _val = 0
      end
      _val = math.floor((channelValue * (subgroupFaderVal / 255))+0.5) --ROUND VALUES AND APPLY SCENCE STATE TO OUPUT PROPORTIONAL TO THE SCENES FADER POSITION
      highestvalue = self.findHighest(highestvalue, _val)   --ADD TOGETHER SCENES CHANNEL OUTPUTS IF THERE IS MORE THAN ONE OF CHANNELS IN RECORDED SCENE STATE
     end   
  end
  if highestvalue > 255 then prevvalue = 255 end --CATCH ANY ATTEMPT TO EXCEED 255
  self.outputValue = prevvalue
  return highestvalue
end 

--CALCULATE THE OUPUT BASED ON CHANNELS FADER POSTION AND THE SUMED CHANNEL VALUE OF THE SUBGROUP
self.calculateOutput = function(subgroupLevel, channelArray, event)
  if subgroupLevel == nil then subgroupLevel = 0 end
  local outputValue = self.findHighest(channelArray[event.Index].getValue(),  subgroupLevel)
  if outputValue > 255 and subgroupLevel ~= 0 then outputValue  = 255 end 
  outputValue = math.floor((outputValue * master)+0.5) --ROUND OUPUT VAL
  return outputValue
end

self.printValue = function()
  print("ouput= ", self.OutputValue)
end

self.setMaster= function(arg)
  master = arg
end
return self
end

master = 1

--Create new objects for all classes
local channelArray = {}

for i=1,NUM_CHANNELS do
  channelArray[i]= channels.new(i, Controls.Inputs[i].Value)
end
--for i,v in ipairs(channelArray) do print(i,v.getValue()) end

local subgroupArray = {}
for i= NUM_CHANNELS + 1, (NUM_CHANNELS + NUM_SCENES +1) do
  table.insert(subgroupArray, subgroup.new(i, Controls.Inputs[i].Value, channelArray))
end


local outputArray = {}
for i = 1, NUM_CHANNELS do
  table.insert(outputArray, output.new(channelArray[i].getValue(), channelArray[i].getId(), master)) 
end
-----------------------------------------------------
--EVENT HANDLER FUNCTIONS FOR FADERS + SCENE BUTTONS
------------------------------------------------------
function handleRecordPress(event)
  local indexCorrection = (NUM_SCENES*2) + 1 -- takes into count nnum of scenes and their buttons plus master fader
  subgroupArray[event.Index - indexCorrection].setSceneState(channelArray)
  subgroupArray[event.Index - indexCorrection].printState()
end

function handleCHFaderChange(event)
  channelArray[event.Index].setValue(event.Value)
  local subgroupLevel = outputArray[event.Index].addScenesToOutput(subgroupArray, event)
  Controls.Outputs[event.Index].Value = outputArray[event.Index].calculateOutput(subgroupLevel, channelArray, event)
  Controls.Outputs[event.Index].String = Controls.Outputs[event.Index].Value
  if Controls.Outputs[event.Index].Value > 0 then Controls.Outputs[NUM_CHANNELS + event.Index].Value = true else Controls.Outputs[NUM_CHANNELS +event.Index].Value = false end
end

function handleSceneFaderChange(event)
  subgroupArray[event.Index-NUM_SCENES].setFaderValue(event.Value)
  subgroupArray[event.Index-NUM_SCENES].printState()
 
  for i=1,NUM_CHANNELS do -- iterate over each ouput and calculate the output value
    e = {["Index"]= i} --SIMULATE AN EVENT 
    local subgroupLevel = outputArray[i].addScenesToOutput(subgroupArray, e)
    Controls.Outputs[i].Value = outputArray[i].calculateOutput(subgroupLevel, channelArray, e) 
    Controls.Outputs[i].String = Controls.Outputs[i].Value
    if Controls.Outputs[i].Value > 0 then Controls.Outputs[NUM_CHANNELS +i].Value = true else Controls.Outputs[NUM_CHANNELS +i].Value = false end  
  end
end

function handleMasterFaderChange(event)
  master = Controls.Inputs[event.Index].Value/100
  print("master val", master)
  
  for i=1,NUM_CHANNELS do -- iterate over each ouput and calculate the output value
    ev = {["Index"]= i} --SIMULATE AN EVENT 
    outputArray[i].setMaster(master)
    local subgroupLevel = outputArray[i].addScenesToOutput(subgroupArray, ev)
    Controls.Outputs[i].Value = outputArray[i].calculateOutput(subgroupLevel, channelArray, ev) 
    Controls.Outputs[i].String = Controls.Outputs[i].Value 
    if Controls.Outputs[i].Value > 0 then Controls.Outputs[NUM_CHANNELS +i].Value = true else Controls.Outputs[NUM_CHANNELS +i].Value = false end 
  end
end

---------------------------------------------
--CONNECT INPUTS WITH EVENT HANDLER FUNCTION
---------------------------------------------
for i=1,NUM_CHANNELS do
  Controls.Inputs[i].EventHandler = handleCHFaderChange
end

for i=NUM_CHANNELS+1,NUM_SCENES + NUM_CHANNELS do
  Controls.Inputs[i].EventHandler = handleSceneFaderChange
end

for i=NUM_CHANNELS + NUM_SCENES +2,(NUM_CHANNELS + (NUM_SCENES*2) +1) do
  Controls.Inputs[i].EventHandler = handleRecordPress
end 

Controls.Inputs[NUM_CHANNELS + NUM_SCENES +1].EventHandler = handleMasterFaderChange
