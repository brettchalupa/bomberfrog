-- bullet fire pattern functions

-- enemy bullet speed; constant for now but likely to be dynamic in future
local BULLET_SPEED = 120 -- px/s

local M = {}

-- inserts a bullet into the enemy's table at its position with the passed in
-- velocity
local function shoot(e, vel)
  table.insert(e.bullets, Bullet.fire(e.x, e.y, vel, Bullet.kind.ENEMY))
end

function M.fire_aimed(e, player, params)
  local speed = params.speed or BULLET_SPEED
  local a = math.atan(player.y - e.y, player.x - e.x)
  local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
  shoot(e, vel)
end

function M.fire_ring(e, _player, params)
  local speed = params.speed or BULLET_SPEED
  local n = params.n
  for i = 1, n do
    local a = (i / n) * math.pi * 2
    local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
    shoot(e, vel)
  end
end

function M.fire_spiral(e, _player, params)
  local speed = params.speed or BULLET_SPEED
  local n = params.n
  for i = 1, n do
    local a = e.spiral_angle + (i / n) * math.pi * 2
    local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
    shoot(e, vel)
  end
  e.spiral_angle += params.spin
end

return M
