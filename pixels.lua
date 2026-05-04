-- short-lived 2px-square particles for entity-death bursts. simpler than
-- Explosion's puff circles: fixed size, single color per spawn, no fade.

local M = {}

local SIZE = 2
local FRICTION = 1.5

function M.spawn(x, y, count, color)
  for _ = 1, count do
    local angle = math.random() * math.pi * 2
    local speed = 60 + math.random() * 140
    local life = 0.5 + math.random() * 0.5
    table.insert(State.pixels, {
      alive = true,
      x = x,
      y = y,
      vel = { x = math.cos(angle) * speed, y = math.sin(angle) * speed },
      life = life,
      color = color,
    })
  end
end

function M.update(dt, p)
  p.vel.x -= p.vel.x * FRICTION * dt
  p.vel.y -= p.vel.y * FRICTION * dt
  p.x += p.vel.x * dt
  p.y += p.vel.y * dt
  p.life -= dt
  if p.life <= 0 then
    p.alive = false
  end
end

function M.draw(p)
  gfx.rect_fill(p.x, p.y, SIZE, SIZE, p.color)
end

return M
