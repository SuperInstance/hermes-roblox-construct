--[[
    ROBUX-CONSTRUCT: CommandInterface [v1.0.0-Alpha]
    Purpose: High-level Intent-to-Action translation for the Captain.
    Mechanism: Command-Action-Outcome (CAO) loops.
]]

local CommandInterface = {}
CommandInterface.__index = CommandInterface

-- Intent Types
CommandInterface.INTENTS = {
    SCAVENGE   = "SCAVENGE",   -- Search area for scrap/resources
    STABILIZE  = "STABILIZE",  -- Fix unanchored/glitchy entities
    MONITOR    = "MONITOR",    -- Set up observational loops
    RECON      = "RECON",      -- Map unknown sectors of the DataModel
    REBUILD    = "REBUILD"     -- Full-scale environmental reconstruction
}

function CommandInterface.new(captain_id)
    local self = setmetatable({}, CommandInterface)
    self.CaptainID = captain_id
    self.ActiveCommands = {}
    return self
end

--[[
    Translates a high-level intent into a set of swarm instructions.
    @param intent string: One of CommandInterface.INTENTS
    @param target table: Parameters for the command (e.g., {sector = "Pegasos", radius = 50})
]]
function CommandInterface:IssueOrder(intent, target)
    print("[COMMAND-INTERFACE]: Received Intent: " .. intent .. " for Target: " .. tostring(target))
    
    local command_id = "CMD_" .. math.random(1000, 9999)
    local command_packet = {
        id = command_id,
        intent = intent,
        parameters = target,
        status = "PENDING",
        timestamp = tick()
    }
    
    table.insert(self.ActiveCommands, command_packet)
    self:_dispatchToSwarm(command_packet)
    
    return command_id
end

-- Internal dispatch mechanism (Simulation of Swarm Routing)
function CommandInterface:_dispatchToSwarm(packet)
    print("[COMMAND-INTERFACE]: Dispatching packet " .. packet.id .. " to the SwarmBus...")
    -- In production, this would interface with the SwarmBus and the ReflexDriver
end

return CommandInterface
