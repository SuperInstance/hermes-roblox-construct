import math

def get_grid_key(pos, cell_size):
    gx = math.floor(pos[0] / cell_size)
    gy = math.floor(pos[1] / cell_size)
    gz = math.floor(pos[2] / cell_size)
    return f"{gx},{gy},{gz}"

def test_spatial_partitioning():
    cell_size = 20
    agents = [
        {"id": 1, "pos": (5, 5, 5)},
        {"id": 2, "pos": (7, 7, 7)},
        {"id": 3, "pos": (100, 100, 100)}, # Far away
    ]
    
    grid = {}
    for a in agents:
        key = get_grid_key(a["pos"], cell_size)
        if key not in grid:
            grid[key] = []
        grid[key].append(a["id"])
        
    print(f"Grid mapping: {grid}")
    assert len(grid) == 2
    print("Spatial Partitioning: PASSED")

def test_intent_vector_logic():
    # Simulated Vector math for intent
    target = [10, 0, 10]
    current_pos = [0, 0, 0]
    
    # Direction vector = (target - pos).Unit
    dx = target[0] - current_pos[0]
    dy = target[1] - current_pos[1]
    dz = target[2] - current_pos[2]
    mag = math.sqrt(dx**2 + dy**2 + dz**2)
    
    unit_dir = [dx/mag, dy/mag, dz/mag]
    print(f"Intent Direction: {unit_dir}")
    assert abs(unit_dir[0] - 0.707) < 0.01 # 10/sqrt(200) approx 0.707
    print("Intent Vector Logic: PASSED")

if __name__ == "__main__":
    test_spatial_partitioning()
    test_intent_vector_logic()
    print("ALL SWARM LOGIC TESTS PASSED")
