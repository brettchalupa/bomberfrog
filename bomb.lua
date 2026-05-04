local M = {}

M.CHIP_COST = 12

-- damage the bomb deals
local DAMAGE = 20
-- radius growth per second
local EXPAND_SPEED = 200

function M.init(x, y)
  return {
    alive = true,
    x = x,
    y = y,
    r = 4,
    max_r = usagi.GAME_W,
    -- enemies already damaged by this bomb; the radius sweeps over each
    -- enemy for many frames, so we gate per-enemy to avoid re-damaging
    hits = {},
  }
end

function M.update(dt, b)
  b.r += EXPAND_SPEED * dt

  if b.r > b.max_r then
    b.alive = false
  end

  if not b.alive then
    return
  end

  for _, e in ipairs(State.enemies) do
    if e.alive and e.arrived and not b.hits[e] and Util.circs_overlap(b, e) then
      Enemy.hit(e, DAMAGE)
      Explosion.spawn(e.x, e.y, 18)
      b.hits[e] = true
    end

    for _, bullet in ipairs(e.bullets) do
      if bullet.alive and Util.circs_overlap(b, bullet) then
        bullet.alive = false
      end
    end
  end
end

-- concentric trailing rings: outermost is the leading edge in white,
-- inner rings lag behind in warmer colors so the explosion reads as a
-- shockwave with a trail.
local RING_COLORS = {
  gfx.COLOR_WHITE,
  gfx.COLOR_WHITE,
  gfx.COLOR_PEACH,
  gfx.COLOR_YELLOW,
  gfx.COLOR_ORANGE,
  gfx.COLOR_RED,
}
local RING_GAP = 5

function M.draw(b)
  for i = 1, #RING_COLORS do
    local r = b.r - (i - 1) * RING_GAP
    if r > 0 then
      gfx.circ(b.x, b.y, r, RING_COLORS[i])
    end
  end
end

return M
