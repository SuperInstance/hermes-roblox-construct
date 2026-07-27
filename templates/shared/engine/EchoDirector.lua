--[[
    ROBUX-CONSTRUCT: EchoDirector [v1.0.0-Alpha]
    Purpose: The "Game Director" or "Dungeon Master" layer.
    Mechanism: Translates player tempo and environmental variables into world-state "Moods."
]]

local EchoDirector = {}
EchoDirector.__index = EchoDirector

-- World State Archetypes
EchoDirector.MOODS = {
    SERENE = "SERENE",       -- Low risk, low reward, high visibility.
    ACTIVE = "ACTIVE",       -- Standard gameplay, regular scavenging.
    ABYSSAL = "ABYSSAL",     -- High risk, high reward, low visibility, high turbulence.
    STORM = "STORM"          -- Extreme risk, chaotic spawn rates, "Boss" triggers.
}

function EchoDirector.new(player_tempo_thresholds)
    local self = setmetatable({}, EchoDirector)
    self.Thresholds = player_tempo_thresholds or {
        low = 10,    -- Scavenge rate
        mid = 50,    -- Scavenge rate
        high = 150   -- Scavenge rate
    }
    self.CurrentMood = EchoDirector.MOODS.SERENE
    self.Intensity = 0.0 -- 0.0 to 1.0 scale
    return self
end

--[[
    Updates the world mood based on current player performance and environmental state.
    @param player_tempo number: Current rate of successful scavenges/actions.
    @param environmental_noise number: Environmental turbulence (0.0 to 1.0).
]]
function EchoDirector:Update(player_tempo, environmental_noise)
    -- 1. Calculate Intensity (A blend of skill and environment)
    local tempo_factor = math.min(player_tempo / self.Thresholds.high, 1.0)
    self.Intensity = (tempo_factor * 0.7) + (environmental_noise * 0.3)

    -- 2. Determine Mood based on Intensity
    if self.Intensity < 0.3 then
        self.CurrentMood = EchoDirector.MOODS.SERENE
    elseif self.Intensity < 0.6 then
        self.CurrentMood = EchoDirector.MOODS.ACTIVE
    elseif self.Intensity < 0.85 then
        self.CurrentMood = EchoDirector.MOODS.ABYSSAL
    else
        self.CurrentMood = EchoDirector.MOODS.STORM
    end

    print("[ECHO-DIRECTOR]: Intensity: " .. string.format("%.2f", self.Intensity) .. " | Mood: " .. self.CurrentMood)
    return self.CurrentMood
end

return EchoDirector
