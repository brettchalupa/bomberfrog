local M = {}

M.kind = {
  PLAYER = 1,
  ENEMY = 2,
}

function M.fire(x, y, dir, speed, kind)
  return {
    alive = true,
    x = x,
    y = y,
    r = 4,
    speed = speed, -- px/s
    dir = dir,
    kind = kind
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
    local color = gfx.COLOR_RED
    if b.kind == M.kind.ENEMY then
      color = gfx.COLOR_DARK_PURPLE
    end
    gfx.circ_fill(b.x, b.y, b.r, color)
    gfx.circ_fill(b.x, b.y, b.r - 2, gfx.COLOR_WHITE)
  end
end

return M
