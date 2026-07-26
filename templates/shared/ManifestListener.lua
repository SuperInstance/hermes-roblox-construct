--[[
    ROBUX-CONSTRUCT: ManifestListener [v1.0.0-Alpha]
    Purpose: The 'Ear' of the simulation. Listens for Manifestation signals.
    Mechanism: Polling/Webhook Bridge to the Cloudflare Relay.
]]

local HttpService = game:GetService("HttpService")
local ManifestListener = {}
ManifestListener.__index = ManifestListener

-- Configuration
local CLOUD_RELAY_URL = "https://your-cloudflare-worker.workers.dev/manifest"
local POLL_INTERVAL = 2.0 -- Seconds between checks

function ManifestListener.new(config)
    local self = setmetatable({}, ManifestListener)
    self.URL = config and config.url or CLOUD_RELAY_URL
    self.Interval = config and config.interval or POLL_INTERVAL
    self.IsActive = false
    self.LastProcessedID = ""
    return self
end

function ManifestListener:Start()
    self.IsActive = true
    task.spawn(function()
        while self.IsActive do
            self:Poll()
            task.wait(self.Interval)
        end
    end)
    print("[MANIFEST-LISTENER]: Listening for signals from the Deep...")
end

function ManifestListener:Stop()
    self.IsActive = false
    print("[MANIFEST-LISTENER]: Standing down.")
end

function ManifestListener:Poll()
    local success, response = pcall(function()
        return HttpService:GetAsync(self.URL .. "?last_id=" .. self.LastProcessedID)
    end)

    if success and response ~= "" then
        local data = HttpService:JSONDecode(response)
        if data and data.manifest_id and data.manifest_id ~= self.LastProcessedID then
            self.LastProcessedID = data.manifest_id
            self:ProcessManifest(data)
        end
    elseif not success then
        warn("[MANIFEST-LISTENER]: Signal lost. Connection error to Cloudflare relay.")
    end
end

function ManifestListener:ProcessManifest(manifest)
    print("[MANIFEST-LISTENER]: New Signal Detected! ID: " .. manifest.manifest_id)
    print(string.format("[TRANS-LOG]: Type: %s | Entity: %s | Location: %s", 
        manifest.archetype, manifest.entity_type, manifest.location.depth))
end

return ManifestListener
