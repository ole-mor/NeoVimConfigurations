# Overseer.nvim — High-Resolution Task Duration Timer

## Problem

Overseer.nvim uses `os.time()` to record task start/end timestamps, which only provides **integer second** precision. For fast builds (< 1 second), the duration always shows `00:00`, making it useless for benchmarking build/run times.

```
# Default overseer output — useless for fast tasks
SUCCESS: make all
00:00 14 seconds ago
```

## Solution

Use `vim.uv.hrtime()` (**nanosecond** resolution) via a custom Overseer **component file** that hooks into the task lifecycle, paired with a custom **render function** that formats the precise duration.

### Result

```
SUCCESS: make run
0.0223s 19 seconds ago
SUCCESS: make all
0.2778s 52 seconds ago
> [100%] Built target jin
```

## Architecture

The implementation has two parts:

1. **Component file** — A Lua file at `~/.config/nvim/lua/overseer/component/hr_timer.lua` that overseer discovers automatically via its runtime path.
2. **Render function** — A custom render in `init.lua` that reads the high-res timestamps and formats them.

They communicate via `_G._overseer_hr_times`, a global table keyed by task ID.

```
┌─────────────────────────────┐     ┌──────────────────────────────┐
│  hr_timer.lua (component)   │     │  init.lua (render function)  │
│                             │     │                              │
│  on_start:                  │     │  reads _G._overseer_hr_times │
│    store vim.uv.hrtime()  ──┼──►  │  calculates elapsed_ns       │
│  on_complete:               │     │  formats as "0.2778s"        │
│    store vim.uv.hrtime()  ──┼──►  │                              │
│                             │     │                              │
│  Shared via:                │     │                              │
│  _G._overseer_hr_times      │     │                              │
└─────────────────────────────┘     └──────────────────────────────┘
```

## Implementation

### Step 1: Create the component file

Create `~/.config/nvim/lua/overseer/component/hr_timer.lua`:

```lua
-- High-resolution task timer component for overseer.nvim
-- Uses vim.uv.hrtime() for nanosecond precision instead of os.time()

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
```

> **Why this path?** Overseer discovers components via `require("overseer.component.<name>")`. Your nvim config's `lua/` directory is in the Neovim runtime path, so `lua/overseer/component/hr_timer.lua` is automatically found as component `"hr_timer"`.

### Step 2: Configure overseer in init.lua

Add this to your lazy.nvim plugin list:

```lua
{
  "stevearc/overseer.nvim",
  config = function()
    require("overseer").setup({
        -- Add hr_timer component to all tasks via the default alias
        component_aliases = {
          default = {
            "on_exit_set_status",
            "on_complete_notify",
            { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
            "hr_timer",
          },
        },
        task_list = {
            open_on_start = true,
            direction = "bottom",
            min_height = 25,
            render = function(task)
              local render = require("overseer.render")
              local ret = {
                render.status_and_name(task),
              }
              vim.list_extend(ret, render.source_lines(task))
              -- Precise duration using high-res timer from hr_timer component
              local duration_chunks = {}
              local hr = (_G._overseer_hr_times or {})[task.id]
              if hr and hr.start then
                local elapsed_ns
                if hr.stop then
                  elapsed_ns = hr.stop - hr.start
                else
                  elapsed_ns = vim.uv.hrtime() - hr.start
                end
                local elapsed_s = elapsed_ns / 1e9
                local dur_str
                if elapsed_s < 60 then
                  dur_str = string.format("%.4fs", elapsed_s)
                elseif elapsed_s < 3600 then
                  dur_str = string.format("%dm %.2fs",
                    math.floor(elapsed_s / 60), elapsed_s % 60)
                else
                  dur_str = string.format("%dh %dm %.1fs",
                    math.floor(elapsed_s / 3600),
                    math.floor((elapsed_s % 3600) / 60),
                    elapsed_s % 60)
                end
                duration_chunks = { { dur_str } }
              end
              table.insert(ret, render.join(
                duration_chunks,
                render.time_since_completed(task, { hl_group = "Comment" })
              ))
              vim.list_extend(ret, render.result_lines(task, { oneline = true }))
              vim.list_extend(ret, render.output_lines(task, { num_lines = 1 }))
              return render.remove_empty_lines(ret)
            end,
        },
    })
  end,
},
```

## Key Technical Details

| Aspect | Detail |
|---|---|
| Timer source | `vim.uv.hrtime()` — nanosecond resolution monotonic clock |
| Extension point | File-based component at `lua/overseer/component/hr_timer.lua` |
| Registration | Added to `component_aliases.default` in `setup()` |
| Communication | Global table `_G._overseer_hr_times` shared between component and render |
| Precision format | `%.4fs` for < 60s, `%dm %.2fs` for < 1h, `%dh %dm %.1fs` for longer |
| Cleanup | `on_reset` and `on_dispose` hooks clear stale entries |
| Accuracy | Wall-clock time from process spawn to exit (~microsecond overhead from Lua callback) |

## What didn't work (and why)

| Approach | Why it failed |
|---|---|
| `register_component()` | Function doesn't exist in overseer's public API |
| `add_component_alias()` | Function doesn't exist — the correct way is `component_aliases` in `setup()` |
| `User OverseerTaskNew` autocmd | Overseer doesn't fire User autocmds for task lifecycle |
| Monkey-patching `overseer.new_task` | Tasks from `:OverseerRun` bypass `new_task` and call `Task.new()` directly |
| `os.time()` formatting | Only integer-second precision — always shows `0.0s` for sub-second tasks |

## Customization

### Changing decimal precision

Edit the format string in the render function:

```lua
-- 4 decimal places (default): "0.2778s"
dur_str = string.format("%.4fs", elapsed_s)

-- 2 decimal places: "0.28s"
dur_str = string.format("%.2fs", elapsed_s)

-- 6 decimal places (microsecond): "0.277812s"
dur_str = string.format("%.6fs", elapsed_s)
```

### Removing the "time since completed" text

Replace the `render.join(...)` line with just:
```lua
table.insert(ret, duration_chunks)
```

## File Structure

```
~/.config/nvim/
├── init.lua                              # overseer setup + custom render
└── lua/
    └── overseer/
        └── component/
            └── hr_timer.lua              # high-res timer component
```

## Requirements

- Neovim 0.11+ (for `vim.uv.hrtime()` and overseer compatibility)
- [overseer.nvim](https://github.com/stevearc/overseer.nvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim) (or adapt for your plugin manager)
