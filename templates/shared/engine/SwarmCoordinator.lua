--[[
    ROBUX-CONSTRUCT: SwarmCoordinator [v1.0.0]
    Architecture: Distributed Intent-Based Swarming
    
    Purpose:
    Manages high-level 'Intent' commands and translates them into collective 
    steering vectors. Uses a Spatial Partitioning Grid to prevent O(N^2) 
    complexity when calculating neighbor interactions.
    
    Mechanisms:
    - Message Bus: Asynchronous command propagation via task.defer.
    - Spatial Grid: Bucketed partitioning for O(N) neighbor lookups.
    - Intent-based Steer: Shifts swarm macro-behavior (Flocking/Herding) without 
      calculating individual paths for every member every frame.
]]

local SwarmCoordinator = {}
SwarmCoordinator.__index = SwarmCoordinator

-- Types
type Agent = {
    Instance: any,
    Position: Vector3,
    Velocity: Vector3,
    Radius: number,
    GroupID: string,
    Metadata: {[string]: any}
}

type SwarmIntent = {
    Type: "FLOCK" | "HERD" | "SWARM" | "DEFEND" | "CIRCLE",
    Target: Vector3?,
    Strength: number,
    Radius: number
}

-- Constants
local GRID_CELL_SIZE = 20
local MAX_AGENTS_PER_FRAME = 50 -- Batching for Task Scheduler optimization

-- Internal State
local _agents = {} -- [AgentID] = Agent
local _spatial_grid = {} -- [GridKey] = {AgentID, ...}
local _active_intents = {} -- [IntentID] = SwarmIntent

-- Helper: Grid Key Generation
local function getGridKey(pos: Vector3): string
    local gx = math.floor(pos.X / GRID_CELL_SIZE)
    local gy = math.floor(pos.Y / GRID_CELL_SIZE)
    local gz = math.floor(pos.Z / GRID_CELL_SIZE)
    return gx .. "," .. gy .. "," .. gz
end

--[[ 
    Updates the spatial partitioning grid. 
    Called periodically or on agent movement.
]]
function SwarmCoordinator.updateGrid()
    _spatial_grid = {}
    for id, agent in pairs(_agents) do
        local key = getGridKey(agent.Position)
        if not _spatial_grid[key] then
            _spatial_grid[key] = {}
        end
        table.insert(_spatial_grid[key], id)
    end
end

--[[ 
    Finds neighbors within radius using spatial bucketing.
    Optimized to significantly reduce distance checks.
]]
function SwarmCoordinator.getNeighbors(pos: Vector3, radius: number): {Agent}
    local neighbors = {}
    local min_x = math.floor((pos.X - radius) / GRID_CELL_SIZE)
    local max_x = math.floor((pos.X + radius) / GRID_CELL_SIZE)
    local min_y = math.floor((pos.Y - radius) / GRID_CELL_SIZE)
    local max_y = math.floor((pos.Y + radius) / GRID_CELL_SIZE)
    local min_z = math.floor((pos.Z - radius) / GRID_CELL_SIZE)
    local max_z = math.floor((pos.Z + radius) / GRID_CELL_SIZE)

    for x = min_x, max_x do
        for y = min_y, max_y do
            for z = min_z, max_z do
                local key = x .. "," .. y .. "," .. z
                local cell = _spatial_grid[key]
                if cell then
                    for _, agentId in ipairs(cell) do
                        local agent = _agents[agentId]
                        if agent and (agent.Position - pos).Magnitude <= radius then
                            table.insert(neighbors, agent)
                        end
                    end
                end
            end
        end
    end
    return neighbors
end

--[[
    Message Bus: Broadcasts a high-level intent to the swarm.
    Uses task.defer to prevent blocking the main loop.
]]
function SwarmCoordinator.broadcastIntent(intent: SwarmIntent)
    local intentId = "INTENT_" .. tick()
    task.defer(function()
        _active_intents[intentId] = intent
        -- Cleanup intent after a lifecycle or if overridden
        task.delay(5, function()
            _active_intents[intentId] = nil
        end)
    end)
    return intentId
end

--[[
    Core Loop: Manages the group-level Cohesion vectors.
    Calculated via macro-agents to prevent N^2 degradation.
]]
function SwarmCoordinator.step(dt: number)
    -- 1. Update Grid (Optimized: could be staggered across frames)
    SwarmCoordinator.updateGrid()

    -- 2. Process Intents
    -- We calculate a "Global Swarm Vector" for each intent type
    -- so agents don't need to check every intent individually.
    local globalSteer = Vector3.zero
    local intentCount = 0

    for _, intent in pairs(_active_intents) do
        if intent.Target then
            local dir = (intent.Target - Vector3.new(0,0,0)) -- Placeholder for swarm center
            -- Real implementation would use a weighted average of agent positions
            -- for the intent's target reference point if not explicitly provided.
            globalSteer += dir.Unit * intent.Strength
            intentCount += 1
        end
    end

    if intentCount > 0 then
        globalSteer /= intentCount
    end

    -- 3. Agent Update (Staggered Processing)
    -- We use a batching approach to keep the frame rate stable on Roblox.
    local processed = 0
    for id, agent in pairs(_agents) do
        if processed >= MAX_AGENTS_PER_FRAME then
            -- We stop and defer the rest to the next frame
            task.defer(SwarmCoordinator.step, dt)
            break
        end

        -- Compute Behaviors
        -- A: Intent-Based (The 'High-Level' behavior)
        local intentionForce = globalSteer * 0.5

        -- B: Flocking (The 'Low-Level' behavior)
        -- separation, alignment, cohesion...
        -- Optimized: We only fetch neighbors in our local grid bucket
        local neighbors = SwarmCoordinator.getNeighbors(agent.Position, 15)
        local flockingForce = Vector3.zero
        
        if #neighbors > 0 then
            local center = Vector3.zero
            local alignment = Vector3.zero
            local separation = Vector3.zero

            for _, n in ipairs(neighbors) do
                center += n.Position
                alignment += n.Velocity
                local diff = agent.Position - n.Position
                separation += (diff.Unit / diff.Magnitude)
            end
            
            local count = #neighbors
            center /= count
            alignment /= count
            
            flockingForce = (center - agent.Position).Unit * 0.1 -- Cohesion
                         + alignment.Unit * 0.1                 -- Alignment
                         + separation.Unit * 0.5                -- Separation
            end

        -- Integration
        local totalForce = intentionForce + flockingForce
        agent.Velocity = (agent.Velocity + totalForce * dt).Unit * 15 -- Clamp max speed
        agent.Position += agent.Velocity * dt

        processed += 1
    end
end

-- Public API
function SwarmCoordinator.registerAgent(agent: Agent)
    _agents[tostring(agent.Instance)] = agent
end

function SwarmCoordinator.unregisterAgent(agentInstance: any)
    _agents[tostring(agentInstance)] = nil
end

return SwarmCoordinator
