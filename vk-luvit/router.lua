local logger = require('./utils/logger')


local function DEFAULT_FILTER(event)
  return event.object
end

local function ALL_FILTER(event)
  return event
end


local Router = {}
  Router.__index = Router

  function Router:init()
    self.handlers = {} -- {event_type={{filter=fn, handler=fn}}}
    self.on = setmetatable({}, {
      __index = function(_, event_type)
        return function(filter, handler)
          self:add_handler(event_type, filter, handler)
        end
      end})
  end

  function Router:add_handler(event_type, filter, handler)
    if not handler then
      handler = filter
      filter = event_type == 'all' and ALL_FILTER or DEFAULT_FILTER
    end

    if not self.handlers[event_type] then
      self.handlers[event_type] = {}
    end
    table.insert(self.handlers[event_type], {
      filter = filter,
      handler = handler
    })
  end

  local function co_handler(filter, handler, event)
    local filter_res = {filter(event)}
    if next(filter_res) ~= nil then
      handler(unpack(filter_res))
    end
  end

  function Router:handle_event(event)
    logger:trace("Handle event: " .. event.type)
    local co, success, err
    if self.handlers[event.type] then
      for _, handler in ipairs(self.handlers[event.type]) do
        co = coroutine.create(co_handler)
        success, err = coroutine.resume(co, handler.filter, handler.handler, event)
        if not success then
          logger:error(err)
        end
      end
    end
    if self.handlers['all'] then
      for _, handler in ipairs(self.handlers['all']) do
        co = coroutine.create(co_handler)
        success, err = coroutine.resume(co, handler.filter, handler.handler, event)
        if not success then
          logger:error(err)
        end
      end
    end
  end

return setmetatable(Router, {__call = function(cls, ...)
  local o = setmetatable({}, cls)
  o:init(...)
  return o
end})
