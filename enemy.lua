local M = {}

local HIT_FLASH_TIME = 0.1 -- s

function M.init(x, y)
  return {
    hp = 20,
    alive = true,
    x = x,
    y = y,
    r = 10,
    hit_timer = 0,
  }
end

function M.hit(e)
  e.hit_timer = HIT_FLASH_TIME
  e.hp -= 1
  if e.hp < 0 then
    e.alive = false
  end
end

function M.dead(e)
  return e.hp > 0
end

function M.update(dt, e)
  if e.hit_timer > 0 then
    e.hit_timer -= dt
  end
end

function M.draw(e)
  if not e.alive then
    return
  end

  if e.hit_timer > 0 then
    gfx.circ_fill(e.x, e.y, e.r, gfx.COLOR_ORANGE)
  else
    gfx.circ_fill(e.x, e.y, e.r, gfx.COLOR_RED)
    gfx.circ_fill(e.x, e.y, 8, gfx.COLOR_WHITE)
    gfx.circ_fill(e.x, e.y, 6, gfx.COLOR_RED)
    gfx.circ_fill(e.x, e.y, 4, gfx.COLOR_WHITE)
    gfx.circ_fill(e.x, e.y, 2, gfx.COLOR_RED)
  end
end

return M
