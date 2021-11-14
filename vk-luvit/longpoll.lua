local Class = require("./utils/class")
local http = require("simple-http")


local LongPoll = Class()

  function LongPoll:init(api, group_id, wait, error_handler)
    self.handlers = {} -- {event = {handler1, handler2}, all={...}}
    self.error_handler = error_handler
    self.running = false

    self.api = api
    self.group_id = group_id or api.groups.get_by_id()[1].id

    self.wait = wait or 25

    -- router
    local router_mt = {}

    function router_mt.__index(_, event_type)
      return function(handler)
        self:add_handler(event_type, handler)
      end
    end

    self.on = setmetatable({}, router_mt)
  end

  function LongPoll:set_server()
    local server = self.api.groups.getLongPollServer({group_id=self.group_id})
    self.server = server.server
    self.key = server.key
    self.ts = server.ts
  end

  function LongPoll:get_events()
    local url = "%s?act=a_check&key=%s&ts=%s&wait=%s"
    url = url:format(self.server, self.key, self.ts, self.wait)
    return http.request("GET", url)
  end

  function LongPoll:coro_run()
    if not self.server then
      self:set_server()
    end

    local events, err
    self.running = true
    while self.running do
      events, err = self:get_events()
      if events then
        if events.failed then
          self:set_server()
        else
          self.ts = events.ts
          for _, event in ipairs(events.updates) do
            self:handle_event(event)
          end
        end
      else
        if self.error_handler then
          self.error_handler(err)
        end
      end
    end
  end

  function LongPoll:run()
    coroutine.wrap(self.coro_run)(self)
  end

  function LongPoll:stop()
    self.running = false
  end

  function LongPoll:add_handler(event, handler)
    if not self.handlers[event] then
      self.handlers[event] = {}
    end
    table.insert(self.handlers[event], handler)
  end

  function LongPoll:delete_handler(event, handler)
    for i, sub_handler in ipairs(self.handlers[event] or {}) do
      if handler == sub_handler then
        table.remove(i)
        break
      end
    end
    if #(self.handlers[event] or {}) == 0 then
      self.handlers[event] = nil
    end
  end

  function LongPoll:handle_event(event)
    local ev_type, event_obj = event.type, event.object
    if self.handlers[ev_type] then
      for _, handler in ipairs(self.handlers[ev_type]) do
        coroutine.wrap(handler)(event_obj)
      end
    end
    if self.handlers["all"] then
      for _, handler in ipairs(self.handlers["all"]) do
        coroutine.wrap(handler)(event)
      end
    end
  end

return LongPoll
