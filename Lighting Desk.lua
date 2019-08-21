function calculateDecimalValue(value)
  local linearVal = 10^((value-10) / 20)
  local decimalVal = linearVal*255
  return decimalVal
end

-- Create meta classes 
channels = {}
local subgroup = {groupId = 0, value = 0, channelStateArray = {}}
local master = {vale = 0}
local output = {ouputValue = 0, outputPin = nil, subgroups = {}, channels = {}, master = nil }

------------------------
--CHANNEL CLASS
------------------------
channels.new = function(id, value) 
  local self = {}
  local value = calculateDecimalValue(value)
  local inputId = id 

self.setValue = function(_value)
  value = calculateDecimalValue(_value)
end

self.printValue = function(arg) 
  print(value)
end

self.getValue = function()
  return value
end
return self
end

--------------------------
-- SUBGROUP CLASS
--------------------------
function subgroup:new (o, id, _value, _channelStateArray)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.channelStateArray = initState(_channelStateArray)
  self.groupId = id 
  self.value = calculateDecimalValue(_value)
  return o
end

function subgroup:mixWithChannels(channelVals)
  local postMixChannelValues = {}
  for i=1,6 do
    local _val = channelVals[i] + self.channelStateArray[i]
    if _val > 255 then _val = 255 end
    if self.value ~= 0 then 
      _val = _val * self.value/255
    else
      _val = 0
    end      
    table.insert(postMixChannelValues, _val)
  end
  return postMixChannelValues  
end

function initState(controls)
    local statearray = {}
    for i=1,6 do
      table.insert(statearray, calculateDecimalValue(controls[i].value))
    end
    return statearray
  end 
   
function subgroup:setSceneState(channelStates)
  for i=1,6 do 
    self.channelStateArray[i] = channelStates[i]:getValue()
  end
end  

function subgroup:setFaderValue(value)
  self.value = calculateDecimalValue(value)
end

function subgroup:printValue()
  print(self.value)
end

function subgroup:printState()
  print("Subgroup state: ")
  for i=1,6 do
    print(self.channelStateArray[i])
  end
end

-----------------
--OUTPUT CLASS
-----------------
function output:new (o, subgroups, channel, master)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.outputPin = Controls.Inputs[channel.inputId]
  self.subgroups = subgroups 
  self.channel = channel
  self.ouputValue = Controls.Outputs[channel.inputId].Value
  return o
end

function output:setOutputPinValue(event)
  local _val
  local subgroup
  local subgroupFaderVal
  local prevvalue = 0
  print("event index inside ouput", event.Index)
  for i=1,6 do
    subgroup = self.subgroups[i]
    subgroupFaderVal = subgroup.value
    _val = subgroup.channelStateArray[event.Index] + subgroupFaderVal   
    if _val > 255 then _val = 255 end
    if subgroupFaderVal ~= 0 then 
      _val = _val * subgroupFaderVal/255
    else
      _val = 0
    end
    prevvalue = prevvalue + _val   
    end
    self.outputValue = _val   
    self.outputPin.Value = prevvalue
    print("val = " , self.outputPin.Index)
 
end 

function output:printValue()
  print("ouput= ", self.OutputValue)
end

master = Controls.Inputs[13].Value

--Create new objects for all classes
channelArray = {}

for i=1,6 do
  channelArray[i]= channels.new(i, Controls.Inputs[i].Value)
end
for i,v in ipairs(channelArray) do print(i,v:getValue()) end

subgroupArray = {}
for i=7,12 do
  table.insert(subgroupArray, subgroup:new(nil, i, Controls.Inputs[i].Value, channelArray))
end
for i,v in ipairs(subgroupArray) do print(i,v.value) end

outputArray = {}
for i=1,6 do
  table.insert(outputArray, output:new(nil, subgroupArray, channelArray[i], master))
 
end
-----------------------------------------------------
--EVENT HANDLER FUNCTIONS FOR FADERS + SCENE BUTTONS
------------------------------------------------------
function handleRecordPress(event)
  print(event.Index)
  subgroupArray[event.Index-13]:setSceneState(channelArray)
  print("Scene state recorded: ")
  subgroupArray[event.Index-13]:printState()
end

function handleCHFaderChange(event)
  print(calculateDecimalValue(event.Value))
  channelArray[event.Index]:setValue(event.Value)
  outputArray[event.Index]:setOutputPinValue(event)
  print(Controls.Outputs[event.Index].Value)
  print("event index = ", event.Index)
end

function handleSceneFaderChange(event)
  subgroupArray[event.Index-6]:setFaderValue(event.Value)
  subgroupArray[event.Index-6]:printState()
end

---------------------------------------------
--CONNECT INPUTS WITH EVENT HANDLER FUNCTION
---------------------------------------------
for i=1,6 do
  Controls.Inputs[i].EventHandler = handleCHFaderChange
end

for i=7,12 do
  Controls.Inputs[i].EventHandler = handleSceneFaderChange
end

for i=14,19 do
  Controls.Inputs[i].EventHandler = handleRecordPress
end 