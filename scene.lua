local M = {
  gameplay = require("scenes.gameplay"),
  main_menu = require("scenes.main_menu"),
  pattern_test = require("scenes.pattern_test")
}

M.KEY = {
  GAMEPLAY = "gameplay",
  MAIN_MENU = "main_menu",
  PATTERN_TEST = "pattern_test",
}

-- State stores the scene key (a string), not the module table so that module
-- references don't go stale
function M.switch_to(key)
  assert(M[key], "unknown scene: " .. tostring(key))

  if State.current_scene == nil then
    State.current_scene = key

    if M[key].init then
      M[key].init(State)
    end
  else
    State.pending_scene = key
  end
end

function M.current()
  return M[State.current_scene]
end

return M
