local Pattern = require("pattern") -- NOTE: required before enemy since enemy relies upon it

local M = {}

local HIT_FLASH_TIME = 0.1 -- s
local DEATH_PIXEL_COUNT = 24
local FLY_IN_SPEED = 160   -- px/s
local ARRIVE_DIST = 1      -- px

M.kind = {
  popcorn = {
    name = "Popcorn",
    color = gfx.COLOR_INDIGO,
    hp = 20,
    r = 7,
    chips = 6,
    death_sfx = "popcorn_death",
    sequence = {
      { fn = Pattern.fire_aimed, params = {}, count = 6, delay = 0.07, start_gap = 0.8 },
    }
  },
  kernel = {
    name = "Kernel",
    color = gfx.COLOR_DARK_PURPLE,
    hp = 28,
    r = 9,
    chips = 10,
    death_sfx = "popcorn_death",
    sequence = {
      { fn = Pattern.fire_aimed, params = { speed = 240, kind = Bullet.kind.ENEMY_SMALL }, count = 6, delay = 0.02, start_gap = 0.4 },
      { fn = Pattern.fire_aimed, params = { speed = 240, kind = Bullet.kind.ENEMY_SMALL }, count = 8, delay = 0.02, start_gap = 0.6 },
    }
  },
  shotgun = {
    name = "Shotgun",
    color = gfx.COLOR_DARK_GRAY,
    hp = 34,
    r = 10,
    chips = 10,
    death_sfx = "popcorn_death",
    sequence = {
      { fn = Pattern.fire_fan, params = { n = 4, speed = 180, kind = Bullet.kind.ENEMY_SMALL },                        count = 3, delay = 0.06, start_gap = 0.8 },
      { fn = Pattern.fire_fan, params = { n = 5, speed = 180, kind = Bullet.kind.ENEMY_SMALL },                        count = 3, delay = 0.06, start_gap = 0.8 },
      { fn = Pattern.fire_fan, params = { n = 10, spread = math.pi / 4, speed = 200, kind = Bullet.kind.ENEMY_SMALL }, count = 3, delay = 0.06, start_gap = 0.8 },
    }
  },
  flower = {
    name = "Flower",
    color = gfx.COLOR_DARK_GREEN,
    hp = 40,
    r = 12,
    chips = 20,
    death_sfx = "popcorn_death",
    sequence = {
      { fn = Pattern.fire_ring, params = { n = 20 }, count = 1,  delay = 0.08, start_gap = 1 },
      { fn = Pattern.fire_ring, params = { n = 20 }, count = 4,  delay = 0.08, start_gap = 1 },
      { fn = Pattern.fire_ring, params = { n = 20 }, count = 8,  delay = 0.08, start_gap = 1 },
      { fn = Pattern.fire_ring, params = { n = 40 }, count = 10, delay = 0.08, start_gap = 1.5 },
    }
  },
  midboss = {
    name = "Midboss",
    color = gfx.COLOR_RED,
    hp = 200,
    r = 16,
    chips = 12,
    death_sfx = "boss_death",
    sequence = {
      { fn = Pattern.fire_aimed,  params = { speed = 240, kind = Bullet.kind.ENEMY_SMALL },       count = 10, delay = 0.03, start_gap = 1.5 },
      { fn = Pattern.fire_aimed,  params = { speed = 240, kind = Bullet.kind.ENEMY_SMALL },       count = 10, delay = 0.03, start_gap = 0.5 },
      { fn = Pattern.fire_ring,   params = { n = 12, speed = 180, kind = Bullet.kind.ENEMY_BIG }, count = 5,  delay = 0.08, start_gap = 2 },
      { fn = Pattern.fire_spiral, params = { n = 6, spin = 0.15 },                                count = 10, delay = 0.04, start_gap = 3 },
    }
  },
  boss = {
    name = "Boss",
    color = gfx.COLOR_RED,
    hp = 400,
    r = 24,
    chips = 12,
    death_sfx = "boss_death",
    sequence = {
      { fn = Pattern.fire_wall,  params = { n = 6, base_angle = math.pi, gap_n = 4, gap_shift = 3, spread = math.pi / 4, speed = 100 },        count = 16, delay = 0.15, start_gap = 1.0 },
      { fn = Pattern.fire_aimed, params = { speed = 240, kind = Bullet.kind.ENEMY_SMALL },                                                     count = 10, delay = 0.03, start_gap = 1.3 },
      { fn = Pattern.fire_aimed, params = { speed = 120, kind = Bullet.kind.ENEMY_LARGE },                                                     count = 20, delay = 0.05, start_gap = 1.0 },
      { fn = Pattern.fire_wall,  params = { n = 6, base_angle = math.pi - 0.5, gap_n = 4, gap_shift = -3, spread = math.pi / 3, speed = 100 }, count = 16, delay = 0.15, start_gap = 1.0 },
      { fn = Pattern.fire_aimed, params = { speed = 240, kind = Bullet.kind.ENEMY_SMALL },                                                     count = 10, delay = 0.03, start_gap = 1.3 },
      { fn = Pattern.fire_wall,  params = { n = 6, base_angle = math.pi + 0.5, gap_n = 4, gap_shift = 3, spread = math.pi / 4, speed = 100 },  count = 16, delay = 0.15, start_gap = 1.0 },
    }
  }
}

function M.init(kind, x, y, dest)
  local sequence = kind.sequence
  local first_phase = sequence[1]
  return {
    name = kind.name,
    color = kind.color,
    hp = kind.hp,
    alive = true,
    x = x,
    y = y,
    r = kind.r,
    hit_timer = 0,
    bullets = {},
    chips = kind.chips,
    fire_countdown = first_phase.start_gap, -- counts down until next shot; secs
    spiral_angle = 0,
    sequence = sequence,
    sequence_idx = 1,
    pattern_shots_remaining = first_phase.count,
    dest = dest,
    arrived = false,
  }
end

function M.hit(e, dmg)
  dmg = dmg or 1
  e.hit_timer = HIT_FLASH_TIME
  e.hp -= dmg
  if e.hp <= 0 then
    sfx.play(e.death_sfx or "popcorn_death")
    e.alive = false
    Pixels.spawn(e.x, e.y, DEATH_PIXEL_COUNT, gfx.COLOR_RED)
    assert(e.chips, "nil chips for e")
    Chip.drop(e.chips, e.x, e.y)
  end
end

local function advance_phase(e)
  e.sequence_idx += 1

  if e.sequence_idx > #e.sequence then
    e.sequence_idx = 1
  end

  local phase = e.sequence[e.sequence_idx]
  assert(phase, "expected non-nil phase when advancing sequence")

  if phase.fn == Pattern.fire_spiral then
    e.spiral_angle = 0
  end

  e.fire_countdown = phase.start_gap
  e.pattern_shots_remaining = phase.count
end

local function fire_bullet(e, p)
  assert(p, "expected non-nil player `p`")

  local phase = e.sequence[e.sequence_idx]
  phase.fn(e, p, phase.params)
  e.pattern_shots_remaining -= 1
  if e.pattern_shots_remaining > 0 then
    e.fire_countdown = phase.delay
  else
    advance_phase(e)
  end
end

function M.update(dt, e, p)
  if e.hit_timer > 0 then
    e.hit_timer -= dt
  end

  if e.alive then
    if not e.arrived then
      local dx = e.dest.x - e.x
      local dy = e.dest.y - e.y
      local dist = math.sqrt(dx * dx + dy * dy)
      local step = FLY_IN_SPEED * dt
      if dist <= step + ARRIVE_DIST then
        e.x = e.dest.x
        e.y = e.dest.y
        e.arrived = true
      else
        e.x = e.x + (dx / dist) * step
        e.y = e.y + (dy / dist) * step
      end
    else
      if e.fire_countdown > 0 then
        e.fire_countdown -= dt
      end

      if e.fire_countdown <= 0 then
        fire_bullet(e, p)
      end
    end

    for i = #e.bullets, 1, -1 do
      local b = e.bullets[i]
      Bullet.update(dt, b)
      if not b.alive then
        table.remove(e.bullets, i)
      end
    end
  end
end

function M.draw(e)
  if not e.alive then
    return
  end

  if e.hit_timer > 0 then
    gfx.circ_fill(e.x, e.y, e.r, gfx.COLOR_ORANGE)
  else
    gfx.circ_fill(e.x, e.y, e.r, e.color)
    gfx.circ_fill(e.x, e.y, 4, gfx.COLOR_WHITE)
    gfx.circ_fill(e.x, e.y, 2, e.color)
  end

  if usagi.IS_DEV then
    if State.draw_debug then
      gfx.circ(e.x, e.y, e.r, gfx.COLOR_RED)
    end
  end

  for i = 1, #e.bullets do
    Bullet.draw(e.bullets[i])
  end
end

return M
