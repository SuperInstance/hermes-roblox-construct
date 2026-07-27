--[[
    SIMULATION: Manifestation Pipeline End-to-End Test
    This script mocks the Roblox environment to verify the logic of the orchestration loop.
]]

-- Mocking the Roblox Environment (Since we are in a CLI)
local Roblox = {
    print = function(...) print("[ROBLOX_SIM] " .. ...) end,
    tick = function() return os.time() end,
    Color3 = { new = function(r,g,b) return {r=r, g=g, b=b} end }
}

-- Mocking the Modules
local Scoping = { validateScope = function(v) return true end }
local ScrapConverter = require("./templates/shared/ScrapConverter")
local ManifestationBridge = require("./templates/shared/engine/ManifestationBridge")
local TemplateEngine = require("./templates/shared/engine/TemplateEngine")
local ManifestListener = require("./templates/shared/ManifestListener")

-- Mocking the HttpService for the Bridge
local HttpService = {
    JSONDecode = function(s) 
        -- Simulating a recurring webhook stream
        local mock_payloads = {
            '{"id": "test_1", "archetype": "MARITIME", "properties": {"material": "wood", "scale": 5}}',
            '{"id": "test_2", "archetype": "DIGITAL", "properties": {"material": "silicon", "scale": 1}}',
            '{"id": "test_3", "archetype": "URBAN", "properties": {"material": "metal", "scale": 10}}'
        }
        return mock_payloads[math.random(1, #mock_payloads)]
    end
}

-- Mocking the Global environment for the Bridge to work
_G = { HttpService = HttpService }

print("--- STARTING MANIFESTATION PIPELINE SIMULATION ---")

-- 1. Initialize the Stack
local bridge = ManifestationBridge.new("http://mock-cloudflare-edge.com", 1.0)
bridge.IsListening = true -- Manually override for simulation

local listener = ManifestListener.new(bridge)
local engine = TemplateEngine.new(listener, bridge)

-- 2. Simulate a "Wave" of data
print("[SIM]: Injecting mock telemetry wave...")
-- Manually injectting data into the bridge buffer to bypass actual HTTP calls
bridge.ManifestBuffer = {
    {id = "wave_001", archetype = "MARITIME", properties = {material = "wood", scale = 5}},
    {id = "wave_002", archetype = "DIGITAL", properties = {material = "silicon", scale = 1}},
    {id = "wave_003", archetype = "URBAN", properties = {material = "metal", scale = 10}}
}

-- 3. The Heartbeat Loop
print("[SIM]: Running 3 cycles of the Orchestration Loop...")
for i = 1, 3 do
    print("\n--- Heartbeat Cycle " .. i .. " ---")
    
    -- Step A: Listener checks the bridge
    local caught = listener:Listen()
    print("[SIM]: Listener caught " .. caught .. " new manifests.")

    -- Step B: Engine processes the buffer
    engine:ProcessNext()
end

print("\n--- SIMULATION COMPLETE ---")
