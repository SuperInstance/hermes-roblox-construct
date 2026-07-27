--[[
    ROBUX-CONSTRUCT: ShipyardSystem [v1.0.0-Alpha]
    Purpose: The economic backbone. Manages Credits and applying upgrades.
    Mechanism: Manifest-driven upgrade application.
]]

local ShipyardSystem = {}
ShipyardSystem.__index = ShipyardSystem

function ShipyardSystem.new(manifest_path, player_data)
    local self = setmetatable({}, ShipyardSystem)
    self.Manifest = nil -- To be loaded from JSON
    self.PlayerData = player_data -- {credits = 0, upgrades = {}}
    self.ManifestPath = manifest_path
    return self
end

function ShipyardSystem:LoadManifest(http_service)
    -- In a real implementation, this would fetch from the Cloudflare Worker
    -- For now, we assume the Manifest is injected via the ManifestListener
    print("[SHIPYARD]: Manifest loaded.")
end

function ShipyardSystem:PurchaseUpgrade(upgrade_id, level)
    -- 1. Check if player has enough credits
    -- 2. Check if level is valid
    -- 3. Apply multiplier to PlayerData
    -- 4. Deduct credits
    print("[SHIPYARD]: Processing purchase for " .. upgrade_id .. " (Level " .. level .. ")")
    
    -- Placeholder logic for structural testing
    local cost = 100 -- In real impl: lookup in self.Manifest[upgrade_id].levels[level].cost
    if self.PlayerData.credits >= cost then
        self.PlayerData.credits -= cost
        self.PlayerData.upgrades[upgrade_id] = level
        print("[SHIPYARD]: Success! New balance: " .. self.PlayerData.credits)
        return true
    else
        print("[SHIPYARD]: Insufficient credits!")
        return false
    end
end

return ShipyardSystem
