local stringify = require('json').stringify


local keyboard_mt = {
  __tostring = function(keyboard)
    return stringify(keyboard)
  end,
  __index = {
    row = function(keyboard)
      table.insert(keyboard.buttons, {})
    end,
    button = function(keyboard, action, color)
      if #keyboard.buttons == 0 then
        table.insert(keyboard.buttons, {})
      end
      table.insert(keyboard.buttons[#keyboard.buttons], {
        action = action,
        color = color
      })
    end,
    clear = function(keyboard)
      keyboard.buttons = {}
    end,
    get = function(keyboard)
      return stringify(keyboard)
    end
  }
}

return function(one_time, inline)
  local keyboard = {
    one_time = one_time,
    inline = inline,
    buttons = {}
  }
  return setmetatable(keyboard, keyboard_mt)
end
