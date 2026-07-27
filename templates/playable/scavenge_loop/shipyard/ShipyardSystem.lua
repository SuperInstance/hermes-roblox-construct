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

function ShipyardSystem:LoadManifest(manifest_data)
    self.Manifest = manifest_data
    print("[SHIPYARD]: Manifest loaded into memory.")
end

function ShipyardSystem:PurchaseUpgrade(upgrade_id, level)
    if not self.Manifest or not self.Manifest.upgrades[upgrade_id] then
        print("[SHIPYARD]: Error - Unknown Upgrade ID: " .. tostring(upgrade_id))
        return false
    end

    local upgrade_info = self.Manifest.upgrades[upgrade_id].levels[level]
    if not upgrade_info then
        print("[SHIPYARD]: Error - Invalid Upgrade Level: " .. level)
        return false
    end

    local cost = upgrade_info.cost

    if self.PlayerData.credits >= cost then
        self.PlayerData.credits -= cost
        self.PlayerData.upgrades[upgrade_id] = (self.PlayerData.upgrades[upgrade_id] or 0) + 1
        print("[SHIPYARD]: Purchase Successful! " .. upgrade_id .. " Lvl " .. level .. ". New Balance: " .. self.PlayerData.credits)
        return true
    else
        print("[SHIPYARD]: Insufficient Credits! Required: " .. cost .. ", Available: " .. self.PlayerData.credits)
        return false
    end
end

return ShipyardSystem
