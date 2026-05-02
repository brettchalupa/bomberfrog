local Pattern = require("pattern") -- NOTE: required before enemy since enemy relies upon it

local M = {}

local HIT_FLASH_TIME = 0.1 -- s
local PARTICLE_COUNT = 24
local PARTICLE_SIZE = 2

M.kind = {
  popcorn = {
    hp = 100,
    r = 7,
    death_sfx = "popcorn_death",
    sequence = {
      { fn = Pattern.fire_aimed, params = {}, count = 6, delay = 0.1, start_gap = 1 },
    }
  },
  boss = {
    hp = 200,
    r = 12,
    death_sfx = "boss_death",
    sequence = {
      { fn = Pattern.fire_aimed,  params = { speed = 240 },        count = 10, delay = 0.05, start_gap = 1.5 },
      { fn = Pattern.fire_aimed,  params = { speed = 240 },        count = 10, delay = 0.05, start_gap = 0.5 },
      { fn = Pattern.fire_ring,   params = { n = 12 },             count = 5,  delay = 0.08, start_gap = 3 },
      { fn = Pattern.fire_spiral, params = { n = 6, spin = 0.15 }, count = 10, delay = 0.04, start_gap = 6 },
    }
  }
}

function M.init(kind, x, y)
  local sequence = kind.sequence
  local first_phase = sequence[1]
  return {
    hp = kind.hp,
    alive = true,
    x = x,
    y = y,
    r = kind.r,
    hit_timer = 0,
    particles = {},
    bullets = {},
    fire_countdown = first_phase.start_gap, -- counts down until next shot; secs
    spiral_angle = 0,
    sequence = sequence,
    sequence_idx = 1,
    pattern_shots_remaining = first_phase.count,
  }
end

local function emit_death_particles(e)
  for _ = 1, PARTICLE_COUNT do
    local angle = math.random() * math.pi * 2
    local speed = 60 + math.random() * 100
    e.particles[#e.particles + 1] = {
      x = e.x,
      y = e.y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      life = 0.5 + math.random() * 0.5,
    }
  end
end

function M.hit(e)
  e.hit_timer = HIT_FLASH_TIME
  e.hp -= 1
  if e.hp < 0 then
    sfx.play(e.death_sfx or "popcorn_death")
    e.alive = false
    emit_death_particles(e)
  end
end

function M.dead(e)
  return e.hp > 0
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

  for i = #e.particles, 1, -1 do
    local p = e.particles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life <= 0 then
      table.remove(e.particles, i)
    end
  end

  if e.alive then
    if e.fire_countdown > 0 then
      e.fire_countdown -= dt
    end

    if e.fire_countdown <= 0 then
      fire_bullet(e, p)
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
  for i = 1, #e.particles do
    local p = e.particles[i]
    gfx.rect_fill(p.x, p.y, PARTICLE_SIZE, PARTICLE_SIZE, gfx.COLOR_RED)
  end

  if not e.alive then
    return
  end

  if e.hit_timer > 0 then
    gfx.circ_fill(e.x, e.y, e.r, gfx.COLOR_ORANGE)
  else
    gfx.circ_fill(e.x, e.y, e.r, gfx.COLOR_RED)
    gfx.circ_fill(e.x, e.y, 8, gfx.COLOR_WHITE)
    gfx.circ_fill(e.x, e.y, 6, gfx.COLOR_RED)
    gfx.circ_fill(e.x, e.y, 4, gfx.COLOR_WHITE)
    gfx.circ_fill(e.x, e.y, 2, gfx.COLOR_RED)
  end

  for i = 1, #e.bullets do
    Bullet.draw(e.bullets[i])
  end
end

return M
