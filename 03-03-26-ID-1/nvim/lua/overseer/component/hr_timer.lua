-- High-resolution task timer component for overseer.nvim
-- Uses vim.uv.hrtime() for nanosecond precision instead of os.time()
--
-- Usage: Add "hr_timer" to your component_aliases.default in overseer.setup()

-- Shared table to store high-res timestamps (accessible from init.lua render function)
_G._overseer_hr_times = _G._overseer_hr_times or {}

return {
  desc = "Track task duration with nanosecond precision",
  constructor = function()
    return {
      on_start = function(self, task)
        _G._overseer_hr_times[task.id] = { start = vim.uv.hrtime() }
      end,
      on_complete = function(self, task)
        if _G._overseer_hr_times[task.id] then
          _G._overseer_hr_times[task.id].stop = vim.uv.hrtime()
        end
      end,
      on_reset = function(self, task)
        _G._overseer_hr_times[task.id] = nil
      end,
      on_dispose = function(self, task)
        _G._overseer_hr_times[task.id] = nil
      end,
    }
  end,
}
