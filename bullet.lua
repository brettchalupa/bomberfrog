local M = {}

M.kind = {
  PLAYER = 1,
  ENEMY = 2,
}

function M.fire(x, y, vel, kind)
  local r = 4
  if kind == M.kind.ENEMY then
    r = 8
  end
  return {
    alive = true,
    x = x,
    y = y,
    t = 0,
    vel = vel,
    r = r,
    kind = kind
  }
end

function M.update(dt, b)
  if b.alive then
    b.t += dt
    b.x += b.vel.x * dt
    b.y += b.vel.y * dt

    if b.x > usagi.GAME_W or b.x + SPR_SIZE < 0 or b.y > usagi.GAME_H or b.y + SPR_SIZE < 0 then
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

    if State.draw_debug then
      local hitc = M.hit_circ(b)
      gfx.circ(hitc.x, hitc.y, hitc.r, gfx.COLOR_RED)
    end
  end
end

function M.hit_circ(b)
  local circ = { x = b.x, y = b.y, r = b.r }

  -- bullet hit circles are smaller for enemy bullets
  if b.kind == M.kind.ENEMY then
    circ.r = circ.r / 2
  end

  return circ
end

return M
