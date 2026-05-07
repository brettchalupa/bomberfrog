-- bullet fire pattern functions

-- enemy bullet speed; constant for now but likely to be dynamic in future
local BULLET_SPEED = 120 -- px/s

local M = {}

-- inserts a bullet into the enemy's table at its position with the passed in
-- velocity
local function shoot(e, vel, kind)
  table.insert(e.bullets, Bullet.fire(e.x, e.y, vel, kind))
end

function M.fire_aimed(e, player, params)
  local speed = params.speed or BULLET_SPEED
  local center = Player.center(player)
  local a = math.atan(center.y - e.y, center.x - e.x)
  local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
  local kind = params.kind or Bullet.kind.ENEMY_DEFAULT
  shoot(e, vel, kind)
end

function M.fire_fan(e, player, params)
  local speed = params.speed or BULLET_SPEED
  local spread = params.spread or math.pi / 8
  local n = params.n
  local center = Player.center(player)
  local base = math.atan(center.y - e.y, center.x - e.x)
  for i = 1, n do
    local t = n == 1 and 0 or (i - 1) / (n - 1) - 0.5
    local a = base + t * spread
    local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
    local kind = params.kind or Bullet.kind.ENEMY_DEFAULT
    shoot(e, vel, kind)
  end
end

-- n is bullets fired; gap_n is slots skipped. spread covers all slots
-- (n + gap_n), so wider gap also widens the wall. gap_shift offsets the gap in
-- slot units (-ve = left of aim). for centered output, n should be even.
function M.fire_wall(e, player, params)
  local speed = params.speed or BULLET_SPEED
  local spread = params.spread or math.pi * 5 / 6
  local n = params.n
  local gap_n = params.gap_n or 2
  local slots = n + gap_n
  local base = params.base_angle
  if not base then
    local center = Player.center(player)
    base = math.atan(center.y - e.y, center.x - e.x)
  end
  local shift = params.gap_shift or 0
  local gap_lo = math.floor(n / 2) + 1 + shift
  if gap_lo < 1 then gap_lo = 1 end
  if gap_lo > slots - gap_n + 1 then gap_lo = slots - gap_n + 1 end
  local gap_hi = gap_lo + gap_n - 1
  for i = 1, slots do
    if i < gap_lo or i > gap_hi then
      local t = slots == 1 and 0 or (i - 1) / (slots - 1) - 0.5
      local a = base + t * spread
      local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
      local kind = params.kind or Bullet.kind.ENEMY_DEFAULT
      shoot(e, vel, kind)
    end
  end
end

function M.fire_ring(e, _player, params)
  local speed = params.speed or BULLET_SPEED
  local n = params.n
  for i = 1, n do
    local a = (i / n) * math.pi * 2
    local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
    local kind = params.kind or Bullet.kind.ENEMY_DEFAULT
    shoot(e, vel, kind)
  end
end

function M.fire_spiral(e, _player, params)
  local speed = params.speed or BULLET_SPEED
  local n = params.n
  for i = 1, n do
    local a = e.spiral_angle + (i / n) * math.pi * 2
    local vel = { x = math.cos(a) * speed, y = math.sin(a) * speed }
    local kind = params.kind or Bullet.kind.ENEMY_DEFAULT
    shoot(e, vel, kind)
  end
  e.spiral_angle += params.spin
end

return M
