-- parallax starfield: two layers of small specks scrolling right-to-left to
-- imply forward motion. dim colors so stars never compete with bullets for
-- attention.

local M = {}

local LAYERS = {
  { count = 40, speed = 15, color = gfx.COLOR_LIGHT_GRAY, size = 1 },
  { count = 20, speed = 40, color = gfx.COLOR_WHITE,      size = 1 },
}

local function populate()
  local stars = {}
  for li = 1, #LAYERS do
    local layer = LAYERS[li]
    for _ = 1, layer.count do
      table.insert(stars, {
        x = math.random() * usagi.GAME_W,
        y = math.random() * usagi.GAME_H,
        speed = layer.speed,
        color = layer.color,
        size = layer.size,
      })
    end
  end
  return stars
end

local stars = populate()

function M.init()
  stars = populate()
end

function M.update(dt)
  for i = 1, #stars do
    local s = stars[i]
    s.x -= s.speed * dt
    if s.x + s.size < 0 then
      s.x = usagi.GAME_W
      s.y = math.random() * usagi.GAME_H
    end
  end
end

function M.draw()
  for i = 1, #stars do
    local s = stars[i]
    gfx.rect_fill(s.x, s.y, s.size, s.size, s.color)
  end
end

return M
