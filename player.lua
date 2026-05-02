local M = {
}

function M.init()
  return {
    x = 32,
    y = usagi.GAME_H / 2 - SPR_SIZE / 2,
    speed = 160 -- px/s
  }
end

function M.update(dt, p)
  assert(p, "player `p` is nil when it shouldn't be")

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

  delta = normalize_vec(delta)
  p.x += delta.x * p.speed * dt
  p.x = clamp(0, p.x, usagi.GAME_W - SPR_SIZE)
  p.y += delta.y * p.speed * dt
  p.y = clamp(0, p.y, usagi.GAME_H - SPR_SIZE)
end

function M.draw(dt, p)
  gfx.rect_fill(p.x, p.y, SPR_SIZE, SPR_SIZE, gfx.COLOR_DARK_GREEN)
end

return M
