SPR_SIZE = 16
Player = require("player")
Bullet = require("bullet")
Enemy = require("enemy")
Chip = require("chip")
Bomb = require("bomb")
Explosion = require("explosion")
Pixels = require("pixels")
Starfield = require("starfield")
Scene = require("scene")
Save = require("save")
Metadata = require("metadata")
Util = require("util")

function _config()
  return {
    name = "BOMBERFROG",
    game_id = "com.brettmakesgames.bomberfrog",
    icon = 1,
    pixel_perfect = false,
  }
end

function _init()
  input.set_mouse_visible(false)
  Save.load()

  State = {
    t = 0,
    draw_debug = false,
  }

  Scene.switch_to(Scene.KEY.MAIN_MENU)
end

function _update(dt)
  State.t += dt

  assert(State.current_scene)

  if State.pending_scene then
    local current = Scene.current()
    if current.close then
      current.close()
    end

    State.current_scene = State.pending_scene
    State.pending_scene = nil

    local new_scene = Scene.current()
    if new_scene.init then
      new_scene.init(State)
    end
  end

  Scene.current().update(dt, State)
end

function _draw(dt)
  Scene.current().draw(dt, State)
end
