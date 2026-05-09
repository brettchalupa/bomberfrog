-- module for managing game save data

local M = {}

local save_data = {}

function M.load()
  save_data = usagi.load() or { best_times = {} }
end

local function save()
  save_data.version = Metadata.version
  usagi.save(save_data)
end

function M.save_time(level, time)
  save_data.best_times = save_data.best_times or {}
  save_data.best_times[level] = time
  save()
end

-- Returns the best time for the passed in level, returning `nil` if there's no
-- best time yet
function M.best_time_for(level)
  if save_data.best_times == nil then
    return nil
  end
  return save_data.best_times[level]
end

return M
