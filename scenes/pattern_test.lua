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
    player = Player.init()
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
    PatternTestState.current_enemy = init_enemy(Enemy.kind.shotgun)
  elseif input.key_pressed(input.KEY_4) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.flower)
  elseif input.key_pressed(input.KEY_5) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.midboss)
  elseif input.key_pressed(input.KEY_6) then
    sfx.play("confirm")
    PatternTestState.current_enemy = init_enemy(Enemy.kind.boss)
  end

  if input.pressed(input.BTN2) then
    sfx.play("confirm")
    Scene.switch_to(Scene.KEY.MAIN_MENU)
  end

  Player.update(dt, PatternTestState.player)
  Enemy.update(dt, PatternTestState.current_enemy, PatternTestState.player)
end

function M.draw(dt, _state)
  gfx.clear(gfx.COLOR_DARK_BLUE)
  gfx.text("BULLET PATTERN TEST", 10, 10, gfx.COLOR_WHITE)

  local player = PatternTestState.player
  Player.draw(dt, player)

  Enemy.draw(PatternTestState.current_enemy)

  gfx.text(PatternTestState.current_enemy.name, 200, 10, gfx.COLOR_BLACK)
  gfx.text("sequence_idx: " .. PatternTestState.current_enemy.sequence_idx, 200, 20, gfx.COLOR_DARK_GREEN)
end

return M
