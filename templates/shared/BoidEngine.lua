--[[
    ROBUX-CONSTRUCT: BoidEngine [v1.0.0-Alpha]
    Purpose: High-performance flocking/schooling simulation optimized for Roblox DataModel.
    Mechanism: Grouped-Vector-Update (GVU) to allow emergent behavior with minimal overhead.
]]

local BoidEngine = {}
BoidEngine.__index = BoidEngine

-- Constants for the "Schooling" physics
local SEPARATION_DISTANCE = 3.0
local ALIGNMENT_WEIGHT = 0.5
local COHESION_WEIGHT = 0.2
local MAX_SPEED = 15.0

--[[
    Initializes a 'School' unit. 
    Instead of simulating 100 individual agents, we simulate a 'Unit' with 
    statistical variance, reducing CPU load while maintaining visual complexity.
]]
function BoidEngine.new(archetype, initial_position, member_count)
    local self = setmetatable({}, BoidEngine)
    self.Archetype = archetype -- e.g., 'FISH_SCHOOL'
    self.Position = initial_position -- Vector3
    self.Velocity = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit * 10
    self.MemberCount = member_count
    self.Density = 1.0 -- Multiplier for the 'visual spread'
    return self
end

--[[
    Computes the next frame of movement for the entire unit as a single calculation.
    This is the 'Unit-Level Rendering' approach.
]]
function BoidEngine:Update(environment_forces)
    -- 1. Apply External Forces (The Sea/Currents)
    if environment_forces and environment_forces.current_vector then
        self.Velocity = (self.Velocity + environment_forces.current_vector * 0.1).Unit * MAX_SPEED
    end

    -- 2. Emergent Behavior (Simplified Boid Math for Groups)
    -- Rather than N^2 complexity, we use a 'Collective Drift' vector
    local drift = self.Velocity * 0.95 
    
    -- 3. Integrate new information (The Manifestation)
    -- If the sensor detects a predator or a food source, the unit 'reacts' as a single mass.
    if environment_forces and environment_forces.target_vector then
        local steer = (environment_forces.target_vector - self.Position).Unit
        self.Velocity = (self.Velocity + steer * ALIGNMENT_WEIGHT).Unit * MAX_SPEED
    end

    -- 4. Update Position
    self.Position = self.Position + (self.Velocity * 0.03) -- DeltaTime

    return self.Position, self.Velocity
end

return BoidEngine
