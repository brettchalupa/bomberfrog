function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

function _init()
end

function _update(dt)
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text("Hello, Bomberfrog!", 10, 10, gfx.COLOR_WHITE)
end
