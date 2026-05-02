local M = {}

local HIT_FLASH_TIME = 0.1 -- s
local PARTICLE_COUNT = 24
local PARTICLE_SIZE = 2
local BULLET_SPEED = 120 -- px/s

function M.init(x, y)
  return {
    hp = 100,
    alive = true,
    x = x,
    y = y,
    r = 10,
    hit_timer = 0,
    particles = {},
    bullets = {},
    fire_delay = 1,     -- sec
    fire_countdown = 2, -- sec
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
    e.alive = false
    emit_death_particles(e)
  end
end

function M.dead(e)
  return e.hp > 0
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
      local vel = { x = -BULLET_SPEED, y = 0 }
      if p then
        -- aimed shot at player
        local a = math.atan(p.y - e.y, p.x - e.x)
        vel = { x = math.cos(a) * BULLET_SPEED, y = math.sin(a) * BULLET_SPEED }
      end
      table.insert(e.bullets, Bullet.fire(e.x, e.y, vel, Bullet.kind.ENEMY))
      e.fire_countdown = e.fire_delay
    end

    for i = 1, #e.bullets do
      Bullet.update(dt, e.bullets[i])
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
