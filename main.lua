SPR_SIZE = 16
Util = require("util")
Player = require("player")
Enemy = require("enemy")
Bullet = require("bullet")
Chip = require("chip")
Bomb = require("bomb")
Explosion = require("explosion")
Fx = require("fx")

local HIT_SFX_MIN_GAP = 0.20 -- 200ms

local DEST = {
  { x = usagi.GAME_W - 80, y = 60 },
  { x = usagi.GAME_W - 80, y = 120 },
  { x = usagi.GAME_W - 44, y = 90 },
}
local LEVELS = {
  [1] = {
    waves = {
      [1] = {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[3]
        },
      },
      [2] = {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[2]
        },
      },
      [3] = {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[2]
        },
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[3]
        },
      },
      [4] = {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[2]
        },
        {
          kind = Enemy.kind.boss,
          dest = DEST[3]
        }
      },
      [5] = {
        {
          kind = Enemy.kind.boss,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.boss,
          dest = DEST[2]
        },
      }
    }
  }
}

function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

local function init_enemies_for_wave()
  local level_idx = State.level
  local wave_idx = State.wave
  local level = LEVELS[level_idx]
  assert(level, "expected non-nil level for idx: " .. level_idx)
  local wave = level.waves[wave_idx]
  assert(wave, "expected non-nil wave for idx: " .. wave_idx)
  local enemies = {}

  for i = 1, #wave do
    local e = wave[i]
    table.insert(enemies, Enemy.init(e.kind, usagi.GAME_W + 16, e.dest.y, e.dest))
  end

  State.enemies = enemies
end

function _init()
  State = {
    level = 1,
    wave = 1,
    player = Player.init(),
    t = 0,
    last_hit_sfx_t = 0,
    enemies = {},
    chips = {},
    bombs = {},
    explosions = {},
    fx = Fx.init(),
  }

  init_enemies_for_wave()

  input.set_mouse_visible(false)
end

local function all_enemies_dead(enemies)
  for i = 1, #enemies do
    if enemies[i].alive then
      return false
    end
  end

  return true
end

local function try_advance_wave()
  if all_enemies_dead(State.enemies) then
    State.wave += 1
    -- NOTE: temp wrapping until we have concept of levels
    if State.wave > #LEVELS[State.level].waves then
      State.wave = 1
    end

    init_enemies_for_wave()
  end
end

local function update_chips(dt, player)
  local player_firing = input.down(input.BTN1)
  for i = #State.chips, 1, -1 do
    local c = State.chips[i]
    Chip.update(dt, c, player, player_firing)
    if c.alive and player.alive and Util.circs_overlap(c, Player.collect_circ(player)) then
      Util.play_random_sfx("collect_chip", 3)
      local prev_count = player.chip_count
      player.chip_count += 1
      player.chip_count = Util.min(player.chip_count, Bomb.CHIP_COST)
      if prev_count ~= Bomb.CHIP_COST and Player.bombable(player) then
        sfx.play("bomb_ready")
      end
      c.alive = false
    end
    if not c.alive then
      table.remove(State.chips, i)
    end
  end
end

function _update(dt)
  Fx.update(dt)
  if Fx.is_hitstopped() then
    return
  end

  State.t += dt

  local player = State.player

  Player.update(dt, player)

  for i = #State.bombs, 1, -1 do
    local b = State.bombs[i]
    Bomb.update(dt, b)

    if not b.alive then
      table.remove(State.bombs, i)
    end
  end

  for i = #State.explosions, 1, -1 do
    local ex = State.explosions[i]
    Explosion.update(dt, ex)

    if not ex.alive then
      table.remove(State.explosions, i)
    end
  end

  local play_enemy_hit = false
  local pbullets = player.bullets
  for i = 1, #pbullets do
    local b = pbullets[i]
    if b.alive then
      for j = 1, #State.enemies do
        local e = State.enemies[j]

        if b.alive and e.alive and Util.circs_overlap(b, e) then
          play_enemy_hit = true
          b.alive = false
          Enemy.hit(e)
        end
      end
    end
  end
  if play_enemy_hit and State.t - State.last_hit_sfx_t > HIT_SFX_MIN_GAP then
    Util.play_random_sfx("enemy_hit", 4)
    State.last_hit_sfx_t = State.t
  end

  for i = 1, #State.enemies do
    local e = State.enemies[i]
    Enemy.update(dt, e, State.player)

    if e.alive then
      for j = 1, #e.bullets do
        local b = e.bullets[j]

        if b.alive and player.alive then
          local b_hit_circ = { x = b.x, y = b.y, r = b.r / 2 }
          if Util.circs_overlap(b_hit_circ, Player.hit_circ(player)) then
            b.alive = false
            Player.hit(player)
          end
        end
      end
    end
  end

  update_chips(dt, player)

  if not player.alive then
    if input.pressed(input.BTN2) then
      sfx.play("confirm")
      _init()
    end
  end

  try_advance_wave()
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLUE)

  for i = 1, #State.chips do
    Chip.draw(State.chips[i])
  end

  if usagi.IS_DEV and State.player.alive then
    local r = input.down(input.BTN1) and Chip.PULL_RADIUS_FIRING or Chip.PULL_RADIUS_IDLE
    gfx.circ(State.player.x + SPR_SIZE / 2, State.player.y + SPR_SIZE / 2, r, gfx.COLOR_WHITE)
  end

  Player.draw(dt, State.player)

  for i = 1, #State.enemies do
    Enemy.draw(State.enemies[i])
  end

  for _, b in ipairs(State.bombs) do
    Bomb.draw(b)
  end

  for _, ex in ipairs(State.explosions) do
    Explosion.draw(ex)
  end

  if not State.player.alive then
    local txt = "DEAD!"
    local txt_w, txt_h = usagi.measure_text(txt)
    gfx.text(txt, usagi.GAME_W / 2 - txt_w / 2, usagi.GAME_H / 2 - txt_h / 2, gfx.COLOR_DARK_PURPLE)
    gfx.text(txt, usagi.GAME_W / 2 - txt_w / 2 - 1, usagi.GAME_H / 2 - txt_h / 2 - 1, gfx.COLOR_PEACH)

    local txt2 = "press button 2 to restart"
    local txt2_w, txt2_h = usagi.measure_text(txt2)
    gfx.text(txt2, usagi.GAME_W / 2 - txt2_w / 2, usagi.GAME_H / 2 - txt2_h / 2 + 14, gfx.COLOR_DARK_PURPLE)
    gfx.text(txt2, usagi.GAME_W / 2 - txt2_w / 2 - 1, usagi.GAME_H / 2 - txt2_h / 2 + 14 - 1, gfx.COLOR_PEACH)
  end

  -- HUD - bomb bar
  local bg_color = gfx.COLOR_WHITE
  if Player.bombable(State.player) then
    bg_color = gfx.COLOR_RED
  end
  gfx.rect_fill(7, usagi.GAME_H - 12 - 1, 4 * Bomb.CHIP_COST + 2, 8, bg_color)
  gfx.rect_fill(8, usagi.GAME_H - 12, 4 * State.player.chip_count, 6, Chip.color)

  -- dev-only helpers
  if usagi.IS_DEV then
    gfx.text("lvl:" .. State.level .. ",wve:" .. State.wave, 10, 10, gfx.COLOR_BLACK)
  end
end
