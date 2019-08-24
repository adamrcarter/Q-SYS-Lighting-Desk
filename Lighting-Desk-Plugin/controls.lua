local channelCount = props["Channels"].Value
local sceneCount = props["Scenes"].Value

table.insert(ctrls,
    {
        Name = "ChannelFader",
        ControlType = "Knob",
        ControlUnit = "Integer",
        Min = 0,
        Max = 255,
        PinStyle = "Both",
        Count = channelCount,
    })
    table.insert(ctrls,
    {
        Name = "SceneFader",
        ControlType = "Knob",
        ControlUnit = "Integer",
        Min = 0,
        Max = 255,
        PinStyle = "Both",
        Count = sceneCount,
    })
    table.insert(ctrls,
    {
        Name = "MasterFader",
        ControlType = "Knob",
        ControlUnit = "Integer",
        Min = 0,
        Max = 100,
        PinStyle = "Both",
        Count = 1,
    })
    table.insert(ctrls,
    {
        Name = "SceneRecord",
        ControlType = "Button",
        ButtonType = "Momentary",
        PinStyle = "Both",
        Count = sceneCount,
    })
    table.insert(ctrls,
    {
        Name = "ChannelLED",
        ControlType = "Indicator",
        IndicatorType = "LED",
        PinStyle = "Both",
        Count = channelCount,
    })
    