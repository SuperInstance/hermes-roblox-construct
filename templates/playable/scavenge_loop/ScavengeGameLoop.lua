--[[
    ROBUX-CONSTRUCT: ScavengeGameLoop [v1.0.0-Alpha]
    Purpose: A playable prototype loop for a "Deckhand" experience.
    Mechanism: Scavenge -> Manifest -> Consolidate -> Upgrade.
]]

local Swarm = require(script.Parent.Parent.shared.engine.SwarmCoordinator)
local Engine = require(script.Parent.Parent.shared.engine.TemplateEngine)
local Bridge = require(script.Parent.Parent.shared.engine.ManifestationBridge)

local ScavengeLoop = {}
ScavengeLoop.__index = ScavengeLoop

function ScavengeLoop.new()
    local self = setmetatable({}, ScavengeLoop)
    self.Credits = 0
    self.Inventory = {}
    self.ActiveSwarm = {}
    return self
end

--[[
    The primary game tick.
]]
function ScavengeLoop:RunTick(dt)
    -- 1. Check for new "Scrap Signals" from the bridge
    local manifests = Bridge:GetPendingManifests()
    
    for _, manifest in ipairs(manifests) do
        print("[GAME-LOOP]: New scrap discovered in the swell!")
        self:HandleDiscovery(manifest)
    end
    
    -- 2. Update the Swarm behaviors
    Swarm:Update(dt)
    
    -- 3. Check for "Consolidation" (Scavengers returning to the ship)
    self:CheckInventory()
end

function ScavengeLoop:HandleDiscovery(manifest)
    -- Use the TemplateEngine to manifest the physical object
    local entity = Engine:Manifest(manifest)
    
    -- Assign an agent to it
    local scavenger = Swarm:SpawnAgent({
        role = "SCAVENGER",
        target = entity,
        intent = "COLLECT"
    })
    
    table.insert(self.ActiveSwarm, scavenger)
end

function ScavengeLoop:CheckInventory()
    -- Logic for agents returning to 'Plato's Shell' to bank credits
end

return ScavengeLoop
