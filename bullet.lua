local M = {}

function M.fire(x, y, dir)
  return {
    alive = true,
    x = x,
    y = y,
    speed = 600, -- px/s
    dir = dir,
  }
end

function M.update(dt, b)
  if b.alive then
    b.x += b.speed * b.dir * dt

    if b.x > usagi.GAME_W or b.x + SPR_SIZE < 0 then
      b.alive = false
    end
  end
end

function M.draw(b)
  if b.alive then
    gfx.circ_fill(b.x, b.y, 4, gfx.COLOR_RED)
  end
end

return M
