local logger = require('./utils/logger')
local http = require('simple-http')


local LongPoll = {}
  LongPoll.__index = LongPoll

  --- Create LongPoll object
  -- @param vk (table) - vk object
  -- @param group_id (number|nil)
  -- @param wait (number)
  function LongPoll:init(vk, group_id, wait)
    self.vk = vk
    self.group_id = group_id or vk:request('groups.getById')[1].id
    self.wait = wait or 25
  end

  --- Set longpoll server
  function LongPoll:set_server()
    local server, err = self.vk:request('groups.getLongPollServer',
                                        {group_id=self.group_id})
    if server then
      self.server = server.server
      self.key = server.key
      self.ts = server.ts
      return true
    end
    self.server = nil
    self.key = nil
    self.ts = nil
    return false, err
  end

  --- Get group events (updates)
  -- @return events (table) event list
  function LongPoll:get_updates()
    if not self.server then
      local success, err = self:set_server()
      if not success then
        logger:error(err)
        return {}
      end
    end

    local url = '%s?act=a_check&key=%s&ts=%s&wait=%s'
    url = url:format(self.server, self.key, self.ts, self.wait)
    local event, err = http.request('GET', url)
    if not event then
      logger:error(err)
      return {}
    end
    if event.failed then
      self:set_server()
      return {}
    end
    self.ts = event.ts
    return event.updates
  end

return setmetatable(LongPoll, {__call = function(cls, ...)
  local o = setmetatable({}, cls)
  o:init(...)
  return o
end})
