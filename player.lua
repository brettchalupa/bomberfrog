local M = {
}

DIR = {
  RIGHT = 1,
  LEFT = -1
}

local BULLET_SPEED = 600 -- px/s
local MAX_PLAYER_BULLETS = 12
local SPREAD_DEG = 4

-- returns nil if there are no available bullets, intentional to limit number of
-- active player bullets and encourage getting closer
local function find_available_bullet_idx(bullets)
  local idx = nil
  for i = 1, #bullets do
    if not bullets[i].alive then
      idx = i
      break
    end
  end
  return idx
end

-- creates a pool of bullets
local function init_bullets()
  local bullets = {}
  for i = 1, MAX_PLAYER_BULLETS do
    bullets[i] = Bullet.fire(0, 0, { x = BULLET_SPEED, y = 0 }, Bullet.kind.PLAYER)
    bullets[i].alive = false
  end
  return bullets
end

function M.init()
  return {
    x = 32,
    y = usagi.GAME_H / 2 - SPR_SIZE / 2,
    speed = 120,       -- px/s
    fire_delay = 0.1,  -- s
    fire_cooldown = 0, -- s
    bullets = init_bullets()
  }
end

local function fire(x, y, a)
  local vel = { x = math.cos(a) * BULLET_SPEED, y = math.sin(a) * BULLET_SPEED }
  return Bullet.fire(x, y, vel, Bullet.kind.PLAYER)
end

function M.update(dt, p)
  assert(p, "player `p` is nil when it shouldn't be")

  if p.fire_cooldown > 0 then
    p.fire_cooldown -= dt
  end

  local delta = { x = 0, y = 0 }
  if input.down(input.DOWN) then
    delta.y = 1
  elseif input.down(input.UP) then
    delta.y = -1
  end
  if input.down(input.LEFT) then
    delta.x = -1
  elseif input.down(input.RIGHT) then
    delta.x = 1
  end

  if p.fire_cooldown <= 0 and input.down(input.BTN1) then
    p.fire_cooldown = p.fire_delay
    local x = p.x + 10
    local bullet_idx = find_available_bullet_idx(p.bullets)
    if bullet_idx then
      p.bullets[bullet_idx] = fire(x, p.y + 2, math.rad(-SPREAD_DEG))
    end
    local bullet_idx_2 = find_available_bullet_idx(p.bullets)
    if bullet_idx_2 then
      p.bullets[bullet_idx_2] = fire(x, p.y + 8, math.rad(0))
    end
    local bullet_idx_3 = find_available_bullet_idx(p.bullets)
    if bullet_idx_3 then
      p.bullets[bullet_idx_3] = fire(x, p.y + 12, math.rad(SPREAD_DEG))
    end
  end

  delta = normalize_vec(delta)
  p.x += delta.x * p.speed * dt
  p.x = clamp(0, p.x, usagi.GAME_W - SPR_SIZE)
  p.y += delta.y * p.speed * dt
  p.y = clamp(0, p.y, usagi.GAME_H - SPR_SIZE)

  for i = 1, #p.bullets do
    local b = Bullet.update(dt, p.bullets[i])
  end
end

function M.draw(dt, p)
  gfx.rect_fill(p.x, p.y, SPR_SIZE, SPR_SIZE, gfx.COLOR_DARK_GREEN)
  gfx.rect_fill(p.x + 6, p.y + 6, SPR_SIZE - 12, SPR_SIZE - 12, gfx.COLOR_PINK)

  for i = 1, #p.bullets do
    Bullet.draw(p.bullets[i])
  end
end

return M
