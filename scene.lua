local M = {
  gameplay = require("scenes.gameplay"),
  main_menu = require("scenes.main_menu")
}

function M.switch_to(scene)
  State.current_scene = scene
  State.current_scene.init(State)
end

return M
