local M = {
  gameplay = require("scenes.gameplay"),
  main_menu = require("scenes.main_menu")
}

function M.switch_to(scene)
  if State.current_scene == nil then
    State.current_scene = scene

    if State.current_scene.init then
      State.current_scene.init(State)
    end
  else
    State.pending_scene = scene
  end
end

return M
