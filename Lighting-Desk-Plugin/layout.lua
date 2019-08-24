local channelNum = props["Channels"].Value
local sceneNum = props["Scenes"].Value
local channelGap = 36

for i=1, channelNum do
    local ctl_str = tostring(channelNum==1 and "" or " "..i)
    layout["ChannelFader"..ctl_str] =
    {
        PrettyName = string.format( "Channel~Fader %i",i ),
        Style = "Fader",
        Color = {110, 198, 241},
        Size = {36, 128},
        Position = {55+36*(i-1), 230},
    }
    layout["ChannelLED"..ctl_str] =
    {
        PrettyName = string.format( "Channel~LED %i",i ),
        Style = "Led",
        Color = {0,0,255},
        OffColor = {0,0,123},
        Size = {16, 16},
        Position = {(55+(channelGap-16))+36*(i-1), 230-30}
    }
end

for i=1, sceneNum do
    local ctl_str = tostring(sceneNum==1 and "" or " "..i)
    layout["SceneFader"..ctl_str] =
    {
        PrettyName = string.format( "Scene~Fader %i",i ),
        Style = "Fader",
        Color = {110, 198, 241},
        Size = {36, 128},
        Position = {(55+(channelGap-16))+36*(i-1), 455}
    }
    layout["SceneRecord"..ctl_str] =
    {
        PrettyName = string.format( "Scene~Record %i",i ),
        Style = "Button",
        Color = {105,105,255},
        OffColor = {100,100,123},
        Size = {36, 16},
        Position = {55+36*(i-1), 455+140},
        ButtonStyle = "Momentary",
    }
end

layout["MasterFader"] = 
    {
        PrettyName = string.format( "Master~Fader"),
        Style = "Fader",
        Color = {255, 30, 40},
        Size = {36, 128},
        Position = {(55+50)+36*(sceneNum), 455},
    }

graphics ={
    {
        Type = "GroupBox",
        Fill = {230, 240, 245},
        CornerRadius = 8,
        StrokeColor = {255,255,255},
        StrokeWidth =1,
        Postion = {0,0},
        Size = {104*(sceneNum-1), 620}
    }
}
