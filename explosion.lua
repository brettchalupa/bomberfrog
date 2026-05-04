-- short-lived puff particles spawned on bomb impact. each particle has
-- its own random color, lifetime, and size so a burst reads as chaotic
-- instead of uniform.

local M = {}

local COLORS = {
  gfx.COLOR_WHITE,
  gfx.COLOR_PEACH,
  gfx.COLOR_YELLOW,
  gfx.COLOR_ORANGE,
  gfx.COLOR_RED,
}
local FRICTION = 2

function M.spawn(x, y, count)
  for _ = 1, count do
    local angle = math.random() * math.pi * 2
    local speed = 60 + math.random() * 140
    local life = 0.4 + math.random() * 0.6
    table.insert(State.explosions, {
      alive = true,
      x = x,
      y = y,
      vel = { x = math.cos(angle) * speed, y = math.sin(angle) * speed },
      life = life,
      max_life = life,
      r = 6 + math.random() * 8,
      color = COLORS[math.random(1, #COLORS)],
    })
  end
end

function M.update(dt, ex)
  ex.vel.x -= ex.vel.x * FRICTION * dt
  ex.vel.y -= ex.vel.y * FRICTION * dt
  ex.x += ex.vel.x * dt
  ex.y += ex.vel.y * dt
  ex.life -= dt
  if ex.life <= 0 then
    ex.alive = false
  end
end

-- radius shrinks with remaining life so particles fade by getting smaller
function M.draw(ex)
  local r = ex.r * (ex.life / ex.max_life)
  if r < 0.5 then return end
  gfx.circ_fill(ex.x, ex.y, r, ex.color)
end

return M
