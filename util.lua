local M = {}

-- (M:SS.cc speedrun format)
function M.time_str(time)
  local minutes = math.floor(time / 60)
  local seconds = math.floor(time % 60)
  local centis = math.floor(time * 100) % 100
  return string.format("%d:%02d.%02d", minutes, seconds, centis)
end

return M
