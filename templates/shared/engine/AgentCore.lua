--[[
    ROBUX-CONSTRUCT: AgentCore [v1.0.0]
    Purpose: High-fidelity agent representation linked to SwarmCoordinator.
]]

local SwarmCoordinator = require(script.Parent.Parent.Parent.SwarmCoordinator)

local AgentCore = {}
AgentCore.__index = AgentCore

function AgentCore.new(instance, archetype)
    local self = setmetatable({}, AgentCore)
    
    self.Instance = instance
    self.Archetype = archetype
    self.Position = instance.Position
    self.Velocity = instance.Velocity or Vector3.new(0,0,0)
    self.Radius = 2.0
    self.GroupID = "DEFAULT"
    self.Metadata = {}
    
    -- Register with the central coordinator
    SwarmCoordinator.registerAgent(self)
    
    return self
end

function AgentCore:Destroy()
    SwarmCoordinator.unregisterAgent(self.Instance)
    self.Instance = nil
end

-- Added for testing/validation
function AgentCore:GetState()
    return {
        Pos = self.Position,
        Vel = self.Velocity
    }
end

return AgentCore
