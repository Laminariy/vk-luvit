local Class = require("./utils/class")
local json = require("json").stringify


local Keyboard = Class()

  function Keyboard:init(params)
    self.current_row = 0
    self.keyboard = {
      one_time = params.one_time,
      inline = params.inline,
      buttons = {}
    }
    self:row()
  end

  function Keyboard:get_json()
    return json(self.keyboard)
  end

  function Keyboard:row()
    self.current_row = self.current_row + 1
    self.keyboard.buttons[self.current_row] = {}
  end

  function Keyboard:button(action, color)
    local button = {
      action = action,
      color = color
    }
    table.insert(self.keyboard.buttons[self.current_row], button)
  end


local COLORS = {
  PRIMARY = "primary",
  SECONDARY = "secondary",
  POSITIVE = "positive",
  NEGATIVE = "negative"
}

local ACTIONS = {}

  function ACTIONS.Text(label, payload)
    return {
      type = "text",
      label = label,
      payload = payload
    }
  end

  function ACTIONS.OpenLink(label, link, payload)
    return {
      type = "open_link",
      label = label,
      link = link,
      payload = payload
    }
  end

  function ACTIONS.Location(payload)
    return {
      type = "location",
      payload = payload
    }
  end

  function ACTIONS.VKPay(hash, payload)
    return {
      type = "vkpay",
      hash = hash,
      payload = payload
    }
  end

  function ACTIONS.VKApps(label, app_id, owner_id, hash, payload)
    return {
      type = "open_app",
      label = label,
      app_id = app_id,
      owner_id = owner_id,
      hash = hash,
      payload = payload
    }
  end

  function ACTIONS.Callback(label, payload)
    return {
      type = "callback",
      label = label,
      payload = payload
    }
  end

return {
  Keyboard = Keyboard,
  ACTIONS = ACTIONS,
  COLORS = COLORS
}
