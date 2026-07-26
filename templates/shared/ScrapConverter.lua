--[[
    ROBUX-CONSTRUCT: ScrapConverter [v1.0.0-Alpha]
    Purpose: Converts "Raw Scrap" (unstructured data) into "Structured Assets" (Manifest-ready objects).
    Philosophy: Everything discarded has a potential for resurgence.
]]

local ScrapConverter = {}
ScrapConverter.__index = ScrapConverter

-- Archetypes for classification
ScrapConverter.ARCHETYPES = {
    MARITIME = "MARITIME", -- Wood, metal, ropes, nets
    URBAN    = "URBAN",    -- Poles, asphalt, streetlights, cars
    DIGITAL  = "DIGITAL",  -- Components, wires, silicon, scrap-code
    DOMESTIC = "DOMESTIC"  -- Furniture, toys, householdware
}

--[[
    @param raw_scrap table: A table of unorganized properties (e.g. {material="wood", scale=2, origin="dock"})
    @return ScrapConverter: A new converter instance
]]
function ScrapConverter.new(raw_scrap)
    local self = setmetatable({}, ScrapConverter)
    self.RawData = raw_scrap or {}
    self.Archetype = ScrapConverter._classify(raw_scrap)
    self.IsStabilized = false
    return self
end

-- Internal classification logic
function ScrapConverter._classify(data)
    local mat = tostring(data.material or data.type or ""):lower()
    if mat:find("wood") or mat:find("rope") or mat:find("metal") or mat:find("dock") then
        return ScrapConverter.ARCHETYPES.MARITIME
    elseif mat:find("pole") or mat:find("street") or mat:find("car") or mat:find("urban") then
        return ScrapConverter.ARCHETYPES.URBAN
    elseif mat:find("wire") or mat:find("chip") or mat:find("digital") or mat:find("computer") then
        return ScrapConverter.ARCHETYPES.DIGITAL
    else
        return ScrapConverter.ARCHETYPES.DOMESTIC
    end
end

--[[
    Transforms raw properties into a Manifestation Table.
    @return table: A table ready for the Manifestation Engine.
]]
function ScrapConverter:Stabilize()
    local data = self.RawData
    
    -- Apply basic "Identity" anchoring
    local manifest = {
        id = data.id or "scrap_" .. math.random(1000, 9999),
        archetype = self.Archetype,
        properties = {
            size = data.scale or 1,
            material = data.material or "Unknown",
            color = data.color or Color3.new(0.5, 0.5, 0.5)
        },
        timestamp = tick()
    }
    
    self.IsStabilized = true
    print("[SCRAP-CONVERTER]: Item stabilized as " .. self.Archetype)
    return manifest
end

return ScrapConverter
