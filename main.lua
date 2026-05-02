SPR_SIZE = 16
require("util")
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
  Player.update(dt, state.player)

  -- figure out how to make this more efficient
  local pbullets = state.player.bullets
  for i = 1, #pbullets do
    local b = pbullets[i]
    if b.alive then
      for j = 1, #state.enemies do
        local e = state.enemies[j]

        if e.alive and circs_overlap(b, e) then
          Enemy.hit(e)
        end
      end
    end
  end

  for i = 1, #state.enemies do
    Enemy.update(dt, state.enemies[i], state.player)
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLUE)
  gfx.text("Bomberfrog!", 10, 10, gfx.COLOR_WHITE)

  for i = 1, #state.enemies do
    Enemy.draw(state.enemies[i])
  end

  Player.draw(dt, state.player)
end
