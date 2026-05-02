SPR_SIZE = 16
require("util")
Pattern = require("pattern")
Player = require("player")
Enemy = require("enemy")
Bullet = require("bullet")

function _config()
  return { name = "BOMBERFROG", game_id = "com.brettmakesgames.bomberfrog" }
end

local function init_enemies()
  return {
    Enemy.init(usagi.GAME_W - 44, 60),
    Enemy.init(usagi.GAME_W - 44, 120),
    Enemy.init(usagi.GAME_W - 80, 90)
  }
end

function _init()
  state = {
    player = Player.init(),
    enemies = init_enemies(),
  }
end

function _update(dt)
  local player = state.player

  Player.update(dt, player)

  local pbullets = player.bullets
  for i = 1, #pbullets do
    local b = pbullets[i]
    if b.alive then
      for j = 1, #state.enemies do
        local e = state.enemies[j]

        if e.alive and circs_overlap(b, e) then
          b.alive = false
          Enemy.hit(e)
        end
      end
    end
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
      _init()
    end
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLUE)
  gfx.text("Bomberfrog!", 10, 10, gfx.COLOR_WHITE)

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
end
