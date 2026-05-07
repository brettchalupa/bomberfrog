local M = {}

local OPTION = {
  PLAY = 1,
  PATTERN_TEST = 2,
}
local options = {
  [OPTION.PLAY] = "Play",
  [OPTION.PATTERN_TEST] = "Bullet Pattern Test"
}
local current_option = 1

function M.init(_state)
end

function M.update(dt, _state)
  if input.pressed(input.DOWN) then
    sfx.play("player_shoot_1")
    current_option += 1
    if current_option > #options then
      current_option = 1
    end
  end
  if input.pressed(input.UP) then
    sfx.play("player_shoot_2")
    current_option -= 1
    if current_option < 1 then
      current_option = #options
    end
  end

  if input.pressed(input.BTN1) then
    sfx.play("confirm")
    if current_option == OPTION.PLAY then
      Scene.switch_to(Scene.KEY.GAMEPLAY)
    elseif current_option == OPTION.PATTERN_TEST then
      Scene.switch_to(Scene.KEY.PATTERN_TEST)
    end
  end
end

function M.draw(dt, _state)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text("BOMBERFROG", 10, 10, gfx.COLOR_WHITE)
  gfx.text("your bomb is your life!", 10, 20, gfx.COLOR_LIGHT_GRAY)

  for i = 1, #options do
    local value = options[i]
    local y = 30 + i * 24
    gfx.text(value, 20, y, gfx.COLOR_PEACH)

    if i == current_option then
      gfx.circ_fill(12, y + 6, 3, gfx.COLOR_PEACH)
    end
  end
end

return M
