SPR_SIZE = 16
require("util")
Player = require("player")

function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

function _init()
  state = {
    player = Player.init()
  }
end

function _update(dt)
  Player.update(dt, state.player)
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLUE)
  gfx.text("Bomberfrog!", 10, 10, gfx.COLOR_WHITE)

  Player.draw(dt, state.player)
end
