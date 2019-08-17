function calculateDecimalValue(value)
    local linearVal = 10^((value-10) / 20)
    local decimalVal = linearVal*255
    return decimalVal
  end
  
  -- Create meta classes 
  channel = {inputId = 1,value = 0, InputRef = 1}
  subgroup = {groupId = 0, value = 0, channelStateArray = {}}
  master = {vale = 0}
  
  -- derived class for channel object
  function channel:new (o, id, InputRef)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.inputRef = InputRef
    self.value = calculateDecimalValue(InputRef.Value)
    self.inputId = id 
    return o
  end
  
  function channel:setValue(value)
    self.value = calculateDecimalValue(value)
  end
  
  function channel:printValue()
    print(self.value)
  end
  
  function channel:getValue()
    return self.value
  end
  --------------
  
  -- Class for subgroup ---
  
  function subgroup:new (o, id, controls)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.channelStateArray = initState(controls)
    self.groupId = id 
    self.value = calculateDecimalValue(controls.Inputs[id].Value)
    return o
  end
  
  function initState(controls)
      local statearray = {}
      for i=1,6 do
        table.insert(statearray, calculateDecimalValue(controls.Inputs[i].Value))
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
  
  -- mixes group state\scene with current fader values 
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
  
  function subgroup:printValue()
    print(self.value)
  end
  
  function subgroup:printState()
        print("Subgroup state: ")
        for i=1,6 do
        print(self.channelStateArray[i])
      end
  end
  
  --Create new objects for all classes
  channelArray = {}
  for i=1,6 do
    table.insert(channelArray, channel:new(nil, i, Controls.Inputs[i]))
  end
  
  subgroupArray = {}
  for i=7,12 do
    table.insert(subgroupArray, subgroup:new(nil, i, Controls))
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
    channelArray[event.Index]:printValue()
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
  