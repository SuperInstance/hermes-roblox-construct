--[[
    ROBUX-CONSTRUCT: DynamicEvents [v1.0.0-Alpha]
    Purpose: The "Chaos Engine." Triggers high-stakes environmental and boss encounters.
    Mechanism: Threshold-based Event Dispatcher.
]]

local DynamicEvents = {}
DynamicEvents.__index = DynamicEvents

-- Event Types
DynamicEvents.EVENT_TYPES = {
    STORM = "STORM",
    LEVIATHAN_SPAWN = "LEVIATHAN_SPAWN",
    RELIC_SURGE = "RELIC_SURGE",
    CURRENT_SHIFT = "CURRENT_SHIFT"
}

function DynamicEvents.new(echo_director, atmosphere_service)
    local self = setmetatable({}, DynamicEvents)
    self.Director = echo_director
    self.Atmosphere = atmosphere_service
    self.ActiveEvents = {}
    return self
end

--[[
    Evaluates the world state and triggers events based on the EchoDirector's "Mood".
]]
function DynamicEvents:Update(dt)
    local current_mood = self.Director:GetCurrentMood()
    
    -- 1. The Storm Trigger
    if current_mood == "STORM" and not self:IsEventActive(DynamicEvents.EVENT_TYPES.STORM) then
        self:TriggerStorm()
    elseif current_mood == "CALM" and self:IsEventActive(DynamicEvents.EVENT_TYPES.STORM) then
        self:EndStorm()
    end

    -- 2. The Leviathan (The Boss)
    -- If the stress/tempo is extremely high, chance a Leviathan spawn
    if current_mood == "STORM" and math.random() < 0.001 then -- Low probability per tick
        if not self:IsEventActive(DynamicEvents.EVENT_TYPES.LEVIATHAN_SPAWN) then
            self:TriggerLeviathan()
        end
    end
end

function DynamicEvents:IsEventActive(event_type)
    for _, e in ipairs(self.ActiveEvents) do
        if e.type == event_type then return true end
    end
    return false
end

function DynamicEvents:TriggerStorm()
    print("[EVENT]: A Storm is brewing! The sea is turning violent.")
    table.insert(self.ActiveEvents, {type = DynamicEvents.EVENT_TYPES.STORM, startTime = tick()})
    self.Atmosphere:SetMode("STORM_VISUALS")
end

function DynamicEvents:EndStorm()
    print("[EVENT]: The storm has passed. The waters are calming.")
    for i, e in ipairs(self.ActiveEvents) do
        if e.type == DynamicEvents.EVENT_TYPES.STORM then
            table.remove(self.ActiveEvents, i)
            break
        end
    end
    self.Atmosphere:SetMode("CALM_VISUALS")
end

function DynamicEvents:TriggerLeviathan()
    print("[EVENT]: !!! LEVIATHAN DETECTED !!! A massive signal has emerged from the depths.")
    table.insert(self.ActiveEvents, {type = DynamicEvents.EVENT_TYPES.LEVIATHAN_SPAWN, startTime = tick()})
    -- In a real engine, this would call the TemplateEngine to spawn a massive, moving mesh
end

return DynamicEvents
