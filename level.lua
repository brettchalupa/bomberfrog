-- anchor points on the map
local DEST = {
  { x = usagi.GAME_W - 80, y = 60 },  -- top, front
  { x = usagi.GAME_W - 80, y = 120 }, -- bottom, front
  { x = usagi.GAME_W - 44, y = 90 },  -- middle, back
}

-- Table of levels, which contain waves, which are tables of enemy configurations
return {
  [1] = {
    background = "space",
    waves = {
      {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[3]
        },
      },
      {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[2]
        },
      },
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
          kind = Enemy.kind.kernel,
          dest = DEST[3]
        },
      },
      {
        {
          kind = Enemy.kind.kernel,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.kernel,
          dest = DEST[2]
        },
      },
      {
        {
          kind = Enemy.kind.kernel,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.kernel,
          dest = DEST[2]
        },
        {
          kind = Enemy.kind.shotgun,
          dest = DEST[3]
        },
      },
      {
        {
          kind = Enemy.kind.flower,
          dest = DEST[3]
        },
      },
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
          kind = Enemy.kind.midboss,
          dest = DEST[3]
        }
      },
      {
        {
          kind = Enemy.kind.flower,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.shotgun,
          dest = DEST[2]
        },
      },
      {
        {
          kind = Enemy.kind.flower,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.flower,
          dest = DEST[2]
        },
        {
          kind = Enemy.kind.flower,
          dest = DEST[3]
        },
      },
      {
        {
          kind = Enemy.kind.flower,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.flower,
          dest = DEST[2]
        },
        {
          kind = Enemy.kind.kernel,
          dest = DEST[3]
        },
      },
      {
        {
          kind = Enemy.kind.midboss,
          dest = DEST[1]
        },
        {
          kind = Enemy.kind.midboss,
          dest = DEST[2]
        },
      },
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
        },
      },
    },
  }, -- level 1 end
  [2] = {
    background = "city",
    waves = {
      {
        {
          kind = Enemy.kind.popcorn,
          dest = DEST[3]
        },
      },
    }
  }, -- level 2 end
}
