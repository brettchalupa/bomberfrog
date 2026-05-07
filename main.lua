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
  assert(State.current_scene)

  if State.pending_scene then
    if State.current_scene.close then
      State.current_scene.close()
    end

    State.current_scene = State.pending_scene
    State.pending_scene = nil

    if State.current_scene.init then
      State.current_scene.init(State)
    end
  end

  State.t += dt

  assert(State.current_scene.update)
  State.current_scene.update(dt, State)
end

function _draw(dt)
  assert(State.current_scene.draw)
  State.current_scene.draw(dt, State)
end
