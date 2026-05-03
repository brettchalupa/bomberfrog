SPR_SIZE = 16
require("util")
Player = require("player")
Enemy = require("enemy")
Bullet = require("bullet")

local HIT_SFX_MIN_GAP = 0.20 -- 200ms

local DEST = {
  { x = usagi.GAME_W - 80, y = 60 },
  { x = usagi.GAME_W - 80, y = 120 },
  { x = usagi.GAME_W - 44, y = 90 },
}
local LEVELS = {
  [1] = {
    waves = {
      {
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
      }
    }
  }
}

function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

local function init_enemies(level_idx, wave_idx)
  local level = LEVELS[level_idx]
  assert(level, "expected non-nil level for idx: " .. level_idx)
  local wave = level.waves[wave_idx]
  assert(wave, "expected non-nil wave for idx: " .. wave_idx)
  local enemies = {}

  for i = 1, #wave do
    local e = wave[i]
    print("inserted enemy")
    table.insert(enemies, Enemy.init(e.kind, e.dest.x, e.dest.y))
  end

  return enemies
end

function _init()
  state = {
    level = 1,
    wave = 1,
    player = Player.init(),
    t = 0,
    last_hit_sfx_t = 0,
    enemies = {},
  }

  state.enemies = init_enemies(state.level, state.wave)
end

function _update(dt)
  state.t += dt
  local player = state.player

  Player.update(dt, player)

  local play_enemy_hit = false
  local pbullets = player.bullets
  for i = 1, #pbullets do
    local b = pbullets[i]
    if b.alive then
      for j = 1, #state.enemies do
        local e = state.enemies[j]

        if b.alive and e.alive and circs_overlap(b, e) then
          play_enemy_hit = true
          b.alive = false
          Enemy.hit(e)
        end
      end
    end
  end
  if play_enemy_hit and state.t - state.last_hit_sfx_t > HIT_SFX_MIN_GAP then
    local sfx_idx = math.random(1, 4)
    sfx.play("enemy_hit_" .. sfx_idx)
    state.last_hit_sfx_t = state.t
  end

  for i = 1, #state.enemies do
    local e = state.enemies[i]
    Enemy.update(dt, e, state.player)

    if e.alive then
      for j = 1, #e.bullets do
        local b = e.bullets[j]

        if b.alive and player.alive then
          local b_hit_circ = { x = b.x, y = b.y, r = b.r / 2 }
          if circs_overlap(b_hit_circ, Player.hit_circ(player)) then
            b.alive = false
            Player.hit(player)
          end
        end
      end
    end
  end

  if not player.alive then
    if input.pressed(input.BTN2) then
      sfx.play("confirm")
      _init()
    end
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLUE)

  Player.draw(dt, state.player)

  for i = 1, #state.enemies do
    Enemy.draw(state.enemies[i])
  end

  if not state.player.alive then
    local txt = "DEAD!"
    local txt_w, txt_h = usagi.measure_text(txt)
    gfx.text(txt, usagi.GAME_W / 2 - txt_w / 2, usagi.GAME_H / 2 - txt_h / 2, gfx.COLOR_DARK_PURPLE)
    gfx.text(txt, usagi.GAME_W / 2 - txt_w / 2 - 1, usagi.GAME_H / 2 - txt_h / 2 - 1, gfx.COLOR_PEACH)

    local txt2 = "press button 2 to restart"
    local txt2_w, txt2_h = usagi.measure_text(txt2)
    gfx.text(txt2, usagi.GAME_W / 2 - txt2_w / 2, usagi.GAME_H / 2 - txt2_h / 2 + 14, gfx.COLOR_DARK_PURPLE)
    gfx.text(txt2, usagi.GAME_W / 2 - txt2_w / 2 - 1, usagi.GAME_H / 2 - txt2_h / 2 + 14 - 1, gfx.COLOR_PEACH)
  end

  if usagi.IS_DEV then
    gfx.text("lvl:" .. state.level .. ",wve:" .. state.wave, 10, 10, gfx.COLOR_BLACK)
  end
end
