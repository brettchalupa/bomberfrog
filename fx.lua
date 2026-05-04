-- screen-wide effects: hitstop. timers live on State.fx so a single _init
-- wipes them; per-effect state stays in this module.

local M = {}

function M.init()
  return {
    hitstop_t = 0,
  }
end

-- request a hitstop (sim freeze) of at least `dur` seconds; longest active
-- wins so back-to-back triggers don't cut each other short
function M.hitstop(dur)
  State.fx.hitstop_t = math.max(State.fx.hitstop_t, dur)
end

function M.is_hitstopped()
  return State.fx.hitstop_t > 0
end

-- tick down active timers; call once per _update before sim work.
function M.update(dt)
  if State.fx.hitstop_t > 0 then
    State.fx.hitstop_t -= dt
  end
end

return M
