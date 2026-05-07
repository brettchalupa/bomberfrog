local M = {}

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
          kind = Enemy.kind.kernel,
          dest = DEST[3]
        },
      },
      [4] = {
        {
          kind = Enemy.kind.kernel,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.kernel,
          dest = DEST[2]
        },
      },
      [5] = {
        {
          kind = Enemy.kind.flower,
          dest = DEST[3]
        },
      },
      [6] = {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[2]
        },
        {
          kind = Enemy.kind.midboss,
          dest = DEST[3]
        }
      },
      [7] = {
        {
          kind = Enemy.kind.midboss,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.midboss,
          dest = DEST[2]
        },
      }
    }
  }
}

local function init_enemies_for_wave(state)
  local level_idx = state.level
  local wave_idx = state.wave
  local level = LEVELS[level_idx]
  assert(level, "expected non-nil level for idx: " .. level_idx)
  local wave = level.waves[wave_idx]
  assert(wave, "expected non-nil wave for idx: " .. wave_idx)
  local enemies = {}

  for i = 1, #wave do
    local e = wave[i]
    table.insert(enemies, Enemy.init(e.kind, usagi.GAME_W + 16, e.dest.y, e.dest))
  end

  state.enemies = enemies
end


function M.init(state)
  state.level = 1
  state.wave = 1
  state.player = Player.init()
  state.last_hit_sfx_t = 0
  state.enemies = {}
  state.chips = {}
  state.bombs = {}
  state.explosions = {}
  state.pixels = {}

  init_enemies_for_wave(state)
end

local function all_enemies_dead(enemies)
  for i = 1, #enemies do
    if enemies[i].alive then
      return false
    end
  end

  return true
end

local function try_advance_wave(state)
  if all_enemies_dead(state.enemies) then
    state.wave += 1
    -- NOTE: temp wrapping until we have concept of levels
    if state.wave > #LEVELS[state.level].waves then
      state.wave = 1
    end

    init_enemies_for_wave(state)
  end
end

local function update_chips(dt, player)
  local player_firing = input.held(input.BTN1)
  for i = #State.chips, 1, -1 do
    local c = State.chips[i]
    Chip.update(dt, c, player, player_firing)
    if c.alive and player.alive and util.circ_overlap(c, Player.collect_circ(player)) then
      sfx.play("collect_chip_" .. math.random(1, 3))
      local prev_count = player.chip_count
      player.chip_count += 1
      player.chip_count = math.min(player.chip_count, Bomb.CHIP_COST)
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

function M.update(dt, state)
  local player = state.player

  Player.update(dt, player)

  for i = #state.bombs, 1, -1 do
    local b = state.bombs[i]
    Bomb.update(dt, b)

    if not b.alive then
      table.remove(state.bombs, i)
    end
  end

  for i = #state.explosions, 1, -1 do
    local ex = state.explosions[i]
    Explosion.update(dt, ex)

    if not ex.alive then
      table.remove(state.explosions, i)
    end
  end

  for i = #state.pixels, 1, -1 do
    local p = state.pixels[i]
    Pixels.update(dt, p)

    if not p.alive then
      table.remove(state.pixels, i)
    end
  end

  local play_enemy_hit = false
  local pbullets = player.bullets
  for i = 1, #pbullets do
    local b = pbullets[i]
    if b.alive then
      for j = 1, #state.enemies do
        local e = state.enemies[j]

        if b.alive and e.alive and util.circ_overlap(b, e) then
          play_enemy_hit = true
          b.alive = false
          Enemy.hit(e)
        end
      end
    end
  end
  if play_enemy_hit and state.t - state.last_hit_sfx_t > HIT_SFX_MIN_GAP then
    sfx.play("enemy_hit_" .. math.random(1, 4))
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
          if util.circ_overlap(b_hit_circ, Player.hit_circ(player)) then
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

  try_advance_wave(state)
end

function M.draw(dt, state)
  gfx.clear(gfx.COLOR_BLUE)

  for i = 1, #state.chips do
    Chip.draw(state.chips[i])
  end

  -- if usagi.IS_DEV and state.player.alive then
  --   local r = input.held(input.BTN1) and Chip.PULL_RADIUS_FIRING or Chip.PULL_RADIUS_IDLE
  --   gfx.circ(state.player.x + SPR_SIZE / 2, state.player.y + SPR_SIZE / 2, r, gfx.COLOR_WHITE)
  -- end

  Player.draw(dt, state.player)

  for i = 1, #state.enemies do
    Enemy.draw(state.enemies[i])
  end

  for _, b in ipairs(state.bombs) do
    Bomb.draw(b)
  end

  for _, ex in ipairs(state.explosions) do
    Explosion.draw(ex)
  end

  for _, p in ipairs(state.pixels) do
    Pixels.draw(p)
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

  -- HUD - bomb bar
  local bg_color = gfx.COLOR_WHITE
  if Player.bombable(state.player) then
    bg_color = gfx.COLOR_RED
  end
  gfx.rect_fill(7, usagi.GAME_H - 12 - 1, 4 * Bomb.CHIP_COST + 2, 8, bg_color)
  gfx.rect_fill(8, usagi.GAME_H - 12, 4 * state.player.chip_count, 6, Chip.color)

  -- dev-only helpers
  if usagi.IS_DEV then
    gfx.text("lvl:" .. state.level .. ",wve:" .. state.wave, 10, 10, gfx.COLOR_INDIGO)
  end
end

return M
