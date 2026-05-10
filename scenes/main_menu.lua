local M = {}

local OPTION = {
  PLAY = 1,
  MOVEMENT_TEST = 2,
  PATTERN_TEST = 3,
}
local options = {
  [OPTION.PLAY] = "Play",
  [OPTION.MOVEMENT_TEST] = "Player Test",
  [OPTION.PATTERN_TEST] = "Bullet Pattern Test",
}
local current_option = 1

function M.init(_state)
  music.loop("crystal_menu")
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
    elseif current_option == OPTION.MOVEMENT_TEST then
      Scene.switch_to(Scene.KEY.MOVEMENT_TEST)
    end
  end
end

function M.draw(dt, _state)
  local padding = 10
  gfx.clear(gfx.COLOR_DARK_PURPLE)
  gfx.text("BOMBERFROG", padding, padding, gfx.COLOR_WHITE)
  gfx.text("your bomb is your life!", padding, 20, gfx.COLOR_LIGHT_GRAY)
  gfx.spr(1, 72, 7)

  local build = Metadata.build
  local _build_w, build_h = usagi.measure_text(build)
  gfx.text(build, padding, usagi.GAME_H - build_h - padding, gfx.COLOR_LIGHT_GRAY)

  local dev_credit = "game by Brett Chalupa"
  local dev_credit_w, dev_credit_h = usagi.measure_text(dev_credit)
  gfx.text(dev_credit, usagi.GAME_W - dev_credit_w - padding, usagi.GAME_H - dev_credit_h * 3 - padding - 8,
    gfx.COLOR_WHITE)

  local music_credit = "music by Chromatic Arcana"
  local music_credit_w, music_credit_h = usagi.measure_text(music_credit)
  gfx.text(music_credit, usagi.GAME_W - music_credit_w - padding, usagi.GAME_H - music_credit_h * 2 - padding - 4,
    gfx.COLOR_WHITE)

  local eng_credit = "made with USAGI ENGINE"
  local eng_credit_w, eng_credit_h = usagi.measure_text(eng_credit)
  gfx.text(eng_credit, usagi.GAME_W - eng_credit_w - padding, usagi.GAME_H - eng_credit_h - padding,
    gfx.COLOR_WHITE)

  -- NOTE: hardcoded to level 1 for the alpha
  local best_time = Save.best_time_for(1)
  if best_time then
    local bt_text = "Fastest clear: " .. Util.time_str(best_time)
    local bt_text_w = usagi.measure_text(bt_text)
    gfx.text(bt_text, usagi.GAME_W - bt_text_w - 10, 10, gfx.COLOR_PINK)
  end

  for i = 1, #options do
    local value = options[i]
    local y = 30 + i * 20
    gfx.text(value, 20, y, gfx.COLOR_PEACH)

    if i == current_option then
      gfx.circ_fill(12, y + 6, 3, gfx.COLOR_PEACH)
    end
  end
end

return M
