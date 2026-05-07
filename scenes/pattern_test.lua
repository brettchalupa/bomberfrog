local M = {}

local function y_cent()
  return usagi.GAME_H / 2
end

local function init_enemy(kind)
  return Enemy.init(kind, usagi.GAME_W + 20, y_cent(), { x = usagi.GAME_W - 80, y = y_cent() })
end

function M.init(_state)
  PatternTestState = {
    current_enemy = init_enemy(Enemy.kind.popcorn),
    mock_player = { x = 80, y = y_cent() - SPR_SIZE / 2, s = SPR_SIZE }
  }
end

function M.update(dt, _state)
  if input.key_pressed(input.KEY_1) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.popcorn)
  elseif input.key_pressed(input.KEY_2) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.kernel)
  elseif input.key_pressed(input.KEY_3) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.flower)
  elseif input.key_pressed(input.KEY_4) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.midboss)
  end

  if input.pressed(input.BTN2) then
    sfx.play("confirm")
    Scene.switch_to(Scene.KEY.MAIN_MENU)
  end

  Enemy.update(dt, PatternTestState.current_enemy, PatternTestState.mock_player)
end

function M.draw(dt, _state)
  gfx.clear(gfx.COLOR_BLUE)
  gfx.text("BULLET PATTERN TEST", 10, 10, gfx.COLOR_WHITE)

  local player = PatternTestState.mock_player
  gfx.rect_fill(player.x, player.y, player.s, player.s, gfx.COLOR_PEACH)

  Enemy.draw(PatternTestState.current_enemy)

  gfx.text(PatternTestState.current_enemy.name, 200, 10, gfx.COLOR_BLACK)
  gfx.text("sequence_idx: " .. PatternTestState.current_enemy.sequence_idx, 200, 20, gfx.COLOR_DARK_GREEN)
end

return M
