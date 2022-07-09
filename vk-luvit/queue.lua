local logger = require('./utils/logger')
local queue_to_vkscript = require('./utils/queue_to_vkscript')
local set_interval = require('timer').setInterval


local Queue = {}
  Queue.__index = Queue

  --- Create Queue object
  -- @param vk (table) - vk object
  -- @return Queue object
  function Queue:init(vk)
    self.vk = vk
    self.queue = {} -- {{method, params}, {method, params}}
    local interval = 1/(20 * #vk.token)
    set_interval(interval*1000, function()
      coroutine.wrap(self.send_queue)(self)
    end)
  end

  --- Send queue
  function Queue:send_queue()
    if #self.queue == 0 then return end
    local queue = {}
    local waiters = {}
    local count = math.min(25, #self.queue)
    for i=1, count do
      queue[i], waiters[i] = unpack(self.queue[1])
      table.remove(self.queue, 1)
    end
    local res, err = self.vk:request('execute', {code=queue_to_vkscript(queue)})

    if not res then
      logger:error(err)
      return
    end

    local co_suc, co_err
    for i, val in ipairs(res) do
      co_suc, co_err = coroutine.resume(waiters[i], val)
      if not co_suc then
        logger:error(co_err)
      end
    end
  end

  --- Make queued vk request
  -- @param method (string) vk method to execute
  -- @param params (table|nil) table of method args
  -- @return data (table|nil) result or nil if error
  -- @return error(nil|table) nil or error
  function Queue:request(method, params)
    table.insert(self.queue, {{method, params}, coroutine.running()})
    return coroutine.yield()
  end

return setmetatable(Queue, {__call = function(cls, ...)
  local o = setmetatable({}, cls)
  o:init(...)
  return o
end})
