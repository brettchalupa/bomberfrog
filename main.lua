SPR_SIZE = 16
Player = require("player")
Enemy = require("enemy")
Bullet = require("bullet")
Chip = require("chip")
Bomb = require("bomb")
Explosion = require("explosion")
Pixels = require("pixels")

local scene = {
  gameplay = require("scenes.gameplay")
}

function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

function _init()
  State = {
    t = 0,
  }
  scene.gameplay.init(State)
  input.set_mouse_visible(false)
end

function _update(dt)
  State.t += dt

  scene.gameplay.update(dt, State)
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLUE)
  scene.gameplay.draw(dt, State)
end
