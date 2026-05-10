local M = {}

local function y_cent()
  return usagi.GAME_H / 2
end

function M.init(_state)
  MovementTestState = {
    player = Player.init()
  }
  music.stop()
end

function M.update(dt, _state)
  Player.update(dt, MovementTestState.player)

  if input.pressed(input.BTN3) then
    Scene.switch_to(Scene.KEY.MAIN_MENU)
  end
end

function M.draw(dt, _state)
  gfx.clear(gfx.COLOR_DARK_BLUE)
  gfx.text("PLAYER TEST", 10, 10, gfx.COLOR_WHITE)

  gfx.text("fire = " .. input.mapping_for(input.BTN1), 180, 10, gfx.COLOR_PEACH)
  gfx.text("focus = " .. input.mapping_for(input.BTN2), 180, 20, gfx.COLOR_PEACH)
  gfx.text("bomb (back to menu) = " .. input.mapping_for(input.BTN3), 180, 30, gfx.COLOR_PEACH)

  local player = MovementTestState.player
  Player.draw(dt, player)
end

return M
