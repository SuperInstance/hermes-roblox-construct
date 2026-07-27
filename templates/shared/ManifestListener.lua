--[[
    ROBUX-CONSTRUCT: ManifestListener [v1.0.0-Alpha]
    Purpose: The "Ear" of the system. Listens to the Bridge and notifies the Engine.
]]

local ManifestListener = {}
ManifestListener.__index = ManifestListener

function ManifestListener.new(bridge)
    local self = setmetatable({}, ManifestListener)
    self.Bridge = bridge
    self.LastProcessedId = nil
    return self
end

function ManifestListener:Listen()
    local manifests = self.Bridge:GetPendingManifests()
    local processed_count = 0

    for _, manifest in ipairs(manifests) do
        print("[LISTENER]: Caught manifest: " .. tostring(manifest.id))
        self:_onManifestReceived(manifest)
        processed_count = processed_count + 1
    end

    return processed_count
end

function ManifestListener:_onManifestReceived(manifest)
    -- This is where the event is broadcasted to the engine
    -- In a real Roblox environment, this would trigger Spawning logic
    print("[LISTENER]: Routing manifest " .. tostring(manifest.id) .. " to the Template Engine.")
end

return ManifestListener
