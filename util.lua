local M = {}
function M.normalize_vec(vec)
  local mag = math.sqrt(vec.x * vec.x + vec.y * vec.y)
  if mag == 0.0 then
    return vec
  end
  vec.x = vec.x / mag
  vec.y = vec.y / mag
  return vec
end

function M.clamp(min, val, max)
  if val < min then
    return min
  end
  if val > max then
    return max
  end
  return val
end

function M.circs_overlap(c1, c2)
  local dx = c1.x - c2.x
  local dy = c1.y - c2.y
  local distance_sq = (dx * dx) + (dy * dy)

  local radius_sum = c1.r + c2.r
  local radius_sum_sq = radius_sum * radius_sum

  return distance_sq < radius_sum_sq
end

return M
