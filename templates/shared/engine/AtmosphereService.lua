--[[
    ROBUX-CONSTRUCT: AtmosphereService [v1.0.0-Alpha]
    Purpose: Translates the "Mood" from EchoDirector into visual and auditory Roblox environments.
    Mechanism: Parametric environment manipulation (Lighting, Fog, Sound).
]]

local AtmosphereService = {}
AtmosphereService.__index = AtmosphereService

-- Mood Configuration: (FogColor, LightingColor, FogEnd, SoundPitch)
local MOOD_CONFIGS = {
    ["SERENE"] = {
        FogColor = Color3.new(0.8, 0.9, 1.0),
        AmbientColor = Color3.new(0.5, 0.5, 0.6),
        FogEnd = 500,
        SoundPitch = 1.0,
        Intensity = 0.1
    },
    ["ACTIVE"] = {
        FogColor = Color3.new(0.4, 0.5, 0.6),
        AmbientColor = Color3.new(0.3, 0.3, 0.4),
        FogEnd = 300,
        SoundPitch = 1.0,
        Intensity = 0.4
    },
    ["ABYSSAL"] = {
        FogColor = Color3.new(0.05, 0.05, 0.15),
        AmbientColor = Color3.new(0.1, 0.1, 0.2),
        FogEnd = 120,
        SoundPitch = 0.8,
        Intensity = 0.7
    },
    ["STORM"] = {
        FogColor = Color3.new(0.1, 0.0, 0.0),
        AmbientColor = Color3.new(0.2, 0.0, 0.0),
        FogEnd = 60,
        SoundPitch = 0.6,
        Intensity = 1.0
    }
}

function AtmosphereService.new()
    local self = setmetatable({}, AtmosphereService)
    self.CurrentMood = "SERENE"
    return self
end

--[[
    Applies the visual/auditory properties of a mood to the Roblox environment.
    @param mood string: The target mood (e.g., "ABYSSAL")
    @param lighting_service: Roblox Lighting Service
    @param sound_service: Roblox SoundService
]]
function AtmosphereService:ApplyMood(mood, lighting_service, sound_service)
    local config = MOOD_CONFIGS[mood] or MOOD_CONFIGS["SERENE"]
    
    if not lighting_service or not sound_service then
        warn("[ATMOSPHERE-SERVICE]: Required Roblox services not provided!")
        return
    end

    -- 1. Update Lighting
    lighting_service.FogColor = config.FogColor
    lighting_service.Ambient = config.AmbientColor
    lighting_service.FogEnd = config.FogEnd
    
    -- 2. Update Sound (Conceptual - assumes a background loop exists)
    local bg_sound = sound_service:FindFirstChild("BackgroundLoop")
    if bg_sound and bg_sound:IsA("Sound") then
        bg_sound.PlaybackSpeed = config.SoundPitch
    end

    self.CurrentMood = mood
    print("[ATMOSPHERE-SERVICE]: Environment transitioned to " .. mood)
end

return AtmosphereService
