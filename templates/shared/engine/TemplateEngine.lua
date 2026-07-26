--[[
    ROBUX-CONSTRUCT: TemplateEngine [v1.0.0-Alpha]
    Purpose: The "Hands" of the system. Translates Manifestation JSON into physical Roblox Instances.
    Mechanism: Archetype-based instantiation and property mapping.
]]

local TemplateEngine = {}
TemplateEngine.__index = TemplateEngine

function TemplateEngine.new(manifest_listener, bridge)
    local self = setmetatable({}, TemplateEngine)
    self.Listener = manifest_listener
    self.Bridge = bridge
    return self
end

function TemplateEngine:ProcessNext()
    local pending = self.Bridge:GetPendingManifests()
    
    for _, manifest in ipairs(pending) do
        print("[ENGINE]: Processing Manifest ID: " .. tostring(manifest.id))
        self:Manifest(manifest)
    end
end

function TemplateEngine:Manifest(manifest)
    local archetype = manifest.archetype or "UNKNOWN"
    local props = manifest.properties or {}
    
    print("[ENGINE]: Manifesting " .. archetype .. " item: " .. (manifest.id or "unnamed"))
    
    local instance_class = self:_get_class_from_archetype(archetype)
    
    local new_instance = {
        ClassName = instance_class,
        Name = manifest.id or "Manifested_Entity",
        Properties = props,
        Parent = "Workspace"
    }
    
    self:_apply_identity(new_instance, manifest)
    
    print("[ENGINE]: Successfully manifested " .. new_instance.ClassName .. " (" .. new_instance.Name .. ")")
    return new_instance
end

function TemplateEngine:_get_class_from_archetype(archetype)
    local mapping = {
        ["MARITIME"] = "Part",
        ["URBAN"]    = "Part",
        ["DIGITAL"]  = "Part",
        ["DOMESTIC"] = "Part"
    }
    return mapping[archetype] or "Part"
end

function TemplateEngine:_apply_identity(instance, manifest)
    instance.Anchored = true
    instance.CanCollide = true
    instance.IdentityTag = manifest.id
    print("[ENGINE]: Applied identity anchoring to " .. instance.Name)
end

return TemplateEngine
