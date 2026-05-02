function normalize_vec(vec)
  mag = math.sqrt(vec.x * vec.x + vec.y * vec.y)
  if mag == 0.0 then
    return vec
  end
  vec.x = vec.x / mag
  vec.y = vec.y / mag
  return vec
end

function clamp(min, val, max)
  if val < min then
    return min
  end
  if val > max then
    return max
  end
  return val
end
