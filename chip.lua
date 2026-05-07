-- chips are small collectibles that build up the player's bomb meter

local M = {}

local SIZE = 4
local FRICTION = 3
local PULL_STRENGTH = 1400

M.PULL_RADIUS_IDLE = 80
M.PULL_RADIUS_FIRING = 28

function M.drop(count, x, y)
  for i = 1, count do
    local angle = math.random() * math.pi * 2
    local speed = 50 + math.random() * 40
    table.insert(State.chips, {
      x = x,
      y = y,
      vel = { x = math.cos(angle) * speed, y = math.sin(angle) * speed },
      r = SIZE / 2,
      alive = true,
    })
  end
end

function M.update(dt, c, player, player_firing)
  if not c.alive then
    return
  end

  c.vel.x -= c.vel.x * FRICTION * dt
  c.vel.y -= c.vel.y * FRICTION * dt

  local px = player.x + SPR_SIZE / 2
  local py = player.y + SPR_SIZE / 2
  local dx = px - c.x
  local dy = py - c.y
  local dist = math.sqrt(dx * dx + dy * dy)
  local pull_radius = player_firing and M.PULL_RADIUS_FIRING or M.PULL_RADIUS_IDLE

  if player.alive and dist > 0 and dist < pull_radius then
    c.vel.x += (dx / dist) * PULL_STRENGTH * dt
    c.vel.y += (dy / dist) * PULL_STRENGTH * dt
  end

  c.x += c.vel.x * dt
  c.y += c.vel.y * dt
end

M.color = gfx.COLOR_PEACH

function M.draw(c)
  if not c.alive then
    return
  end
  gfx.rect_fill(c.x - SIZE / 2, c.y - SIZE / 2, SIZE, SIZE, M.color)
end

return M
