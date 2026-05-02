-- bullet fire pattern functions

-- enemy bullet speed; constant for now but likely to be dynamic in future
local BULLET_SPEED = 120 -- px/s

local M = {}

-- inserts a bullet into the enemy's table at its position with the passed in
-- velocity
local function shoot(e, vel)
  table.insert(e.bullets, Bullet.fire(e.x, e.y, vel, Bullet.kind.ENEMY))
end

function M.fire_aimed(e, p)
  local a = math.atan(p.y - e.y, p.x - e.x)
  local vel = { x = math.cos(a) * BULLET_SPEED, y = math.sin(a) * BULLET_SPEED }
  shoot(e, vel)

  e.pattern_shots_remaining -= 1
  if e.pattern_shots_remaining <= 0 then
    e.fire_func = M.fire_ring
    e.fire_delay = .8
    e.fire_countdown = 2
    e.pattern_shots_remaining = 2
  end
end

function M.fire_ring(e, _p)
  local n = 12
  for i = 1, n do
    local a = (i / n) * math.pi * 2
    local vel = { x = math.cos(a) * BULLET_SPEED, y = math.sin(a) * BULLET_SPEED }
    shoot(e, vel)
  end

  e.pattern_shots_remaining -= 1
  if e.pattern_shots_remaining <= 0 then
    e.fire_func = M.fire_spiral
    e.fire_delay = 0.2
    e.fire_countdown = 3
    e.pattern_shots_remaining = 4
  end
end

function M.fire_spiral(e, _p)
  local n = 12
  for i = 1, n do
    local a = e.spiral_angle + (i / n) * math.pi * 2
    local vel = { x = math.cos(a) * BULLET_SPEED, y = math.sin(a) * BULLET_SPEED }
    shoot(e, vel)
  end
  e.spiral_angle += 0.3

  e.pattern_shots_remaining -= 1
  if e.pattern_shots_remaining <= 0 then
    e.fire_func = M.fire_aimed
    e.fire_delay = 1.5
    e.pattern_shots_remaining = 2
    e.fire_countdown = 1
  end
end

return M
