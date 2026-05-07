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
    draw_debug = false,
  }

  Scene.switch_to(Scene.KEY.MAIN_MENU)
end

function _update(dt)
  assert(State.current_scene)

  if State.pending_scene then
    local current = Scene.current()
    if current.close then
      current.close()
    end

    State.current_scene = State.pending_scene
    State.pending_scene = nil

    local next_scene = Scene.current()
    if next_scene.init then
      next_scene.init(State)
    end
  end

  State.t += dt

  Scene.current().update(dt, State)
end

function _draw(dt)
  Scene.current().draw(dt, State)
end
