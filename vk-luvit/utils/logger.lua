local printer = require('pretty-print')
local normalize = require('path').normalize


local Logger = {}

  Logger.levels = {
    -- The lowest possible rank and is intended to turn off logging.
    'OFF',
    -- Severe errors that cause premature termination. Expect these to be
    -- immediately visible on a status console.
    'FATAL',
    -- Other runtime errors or unexpected conditions. Expect these to be
    -- immediately visible on a status console.
    'ERROR',
    -- Use of deprecated APIs, poor use of API, 'almost' errors, other runtime
    -- situations that are undesirable or unexpected, but not necessarily
    -- "wrong". Expect these to be immediately visible on a status console.
    'WARN',
    -- Interesting runtime events (startup/shutdown). Expect these to be
    -- immediately visible on a console, so be conservative and keep to a
    -- minimum.
    'INFO',
    -- Detailed information on the flow through the system. Expect these to be
    -- written to logs only. Generally speaking, most lines logged by your
    -- application should be written as DEBUG.
    'DEBUG',
    -- Most detailed information. Expect these to be written to logs only.
    'TRACE'
  }

  Logger.colors = {
    FATAL = '27;31',
    ERROR = '1;31',
    WARN = '27;33',
    INFO = '27;32',
    DEBUG = '27;36',
    TRACE = '27;34'
  }

  function Logger:__index(key)
    return Logger[key] or function(_, ...)
      local level = string.upper(key)
      for lvl, name in ipairs(self.levels) do
        if name == level then
          level = lvl
          break
        end
      end
      self:log(level, ...)
    end
  end

  function Logger:__call(...)
    self:log(6, ...)
  end

  function Logger:set_level(level)
    level = level or 5
    if type(level) == 'string' then
      level = string.upper(level)
      for lvl, name in ipairs(self.levels) do
        if name == level then
          level = lvl
          break
        end
      end
    end
    self.level = level
  end

  function Logger.colorize(text, color_code)
    return '\27[' .. color_code .. 'm' .. text .. '\27[0m'
  end

  function Logger:set_log_func(name, fn)
    self.funcs[name] = fn
  end

  function Logger:log(level, ...)
    local dbg = debug.getinfo(3, 'Sl')
    local info = {
      current_level = self.level,
      level_name = self.levels[level],
      msg_level = level,
      time = os.time(),
      formated_time = os.date('%H:%M:%S'),
      current_line = dbg.currentline,
      src = normalize(dbg.short_src):gsub('.*(vkmud.*)', '%1')
    }
    info.level_color = self.colors[info.level_name]
    for _, fn in pairs(self.funcs) do
      fn(info, ...)
    end
  end

  local function default_log(info, ...)
    if info.msg_level > info.current_level then return end
    local level_color, level_name, time = info.level_color, info.level_name, info.formated_time
    local info_str = Logger.colorize('[%s %s]', level_color):format(level_name, time)
    info_str = string.format('%s %s', info_str, ('[%s:%u]'):format(info.src, info.current_line))
    local n = select('#', ...)
    local args = {...}
    for i = 1, n do
      args[i] = printer.dump(args[i])
    end
    local msg = ('%s %s'):format(info_str, table.concat(args, '    '))
    printer.print(msg)
  end

return setmetatable({level=5, funcs={default=default_log}}, Logger)
