SPR_SIZE = 16
Player = require("player")
Enemy = require("enemy")
Bullet = require("bullet")
Chip = require("chip")
Bomb = require("bomb")
Explosion = require("explosion")
Pixels = require("pixels")
Scene = require("scene")

function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

function _init()
  input.set_mouse_visible(false)
  State = {
    t = 0,
  }

  Scene.switch_to(Scene.main_menu)
end

function _update(dt)
  State.t += dt

  State.current_scene.update(dt, State)
end

function _draw(dt)
  State.current_scene.draw(dt, State)
end
