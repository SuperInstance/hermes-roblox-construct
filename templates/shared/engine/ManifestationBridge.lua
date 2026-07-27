--[[
    ROBUX-CONSTRUCT: ManifestationBridge [v1.0.0-Alpha]
    Purpose: Acts as the internal buffer/relay between the Listener and the Orchestrator.
]]

local ManifestationBridge = {}
ManifestationBridge.__index = ManifestationBridge

function ManifestationBridge.new(webhookUrl, pollingRate)
    local self = setmetatable({}, ManifestationBridge)
    self.WebhookUrl = webhookUrl
    self.PollingRate = pollingRate or 1.0
    self.PendingManifests = {}
    self.IsRunning = false
    return self
end

function ManifestationBridge:Start()
    self.IsRunning = true
    print("[BRIDGE]: Manifestation Bridge Online.")
end

function ManifestationBridge:Stop()
    self.IsRunning = false
    print("[BRIDGE]: Manifestation Bridge Offline.")
end

-- This method is called by the ManifestListener when it finds a new ID
function ManifestationBridge:AddManifest(manifestData)
    table.insert(self.PendingManifests, manifestData)
    print("[BRIDGE]: Manifest queued. Buffer size: " .. #self.PendingManifests)
end

-- This method is called by the Orchestrator to retrieve work
function ManifestationBridge:GetPendingManifests()
    local manifests = self.PendingManifests
    self.PendingManifests = {} -- Clear the buffer after retrieval
    return manifests
end

return ManifestationBridge
