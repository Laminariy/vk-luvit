local Class = require("./utils/class")


local function DEFAULT_FILTER(event)
  return event.object
end

local function ALL_FILTER(event)
  return event
end

local Blueprint = Class()

  function Blueprint:init()
    self.handlers = {} -- {event_type = {{filter, handler}}, all={...}}

    -- router
    local router_mt = {}

    function router_mt.__index(_, event_type)
      return function(filter, handler)
        self:add_handler(event_type, filter, handler)
      end
    end

    self.on = setmetatable({}, router_mt)
  end

  function Blueprint:add_handler(event, filter, handler)
    if not handler then
      handler = filter
      filter = event == "all" and ALL_FILTER or DEFAULT_FILTER
    end

    if not self.handlers[event] then
      self.handlers[event] = {}
    end
    table.insert(self.handlers[event], {filter, handler})
  end

  function Blueprint:delete_handler(event, filter, handler)
    if not handler then
      handler = filter
      filter = event == "all" and ALL_FILTER or DEFAULT_FILTER
    end

    if self.handlers[event] then
      for i, sub_handler in ipairs(self.handlers[event]) do
        if sub_handler[1] == filter and sub_handler[2] == handler then
          table.remove(self.handlers[event], i)
          break
        end
      end
      if #(self.handlers[event]) == 0 then
        self.handlers[event] = nil
      end
    end
  end

  function Blueprint:load(longpoll)
    for event, handlers in pairs(self.handlers) do
      for _, handler in ipairs(handlers) do
        longpoll:add_handler(event, handler[1], handler[2])
      end
    end
  end

  function Blueprint:unload(longpoll)
    for event, handlers in pairs(self.handlers) do
      for _, handler in ipairs(handlers) do
        longpoll:delete_handler(event, handler[1], handler[2])
      end
    end
  end

return Blueprint
