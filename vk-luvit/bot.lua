local VK = require('./vk')
local Queue = require('./queue')
local APIWrapper = require('./api_wrapper')
local LongPoll = require('./longpoll')
local Router = require('./router')
local logger = require('./utils/logger')


local Bot = {}
  Bot.__index = Bot

  function Bot:init(options)
    if type(options) == 'string' or not options.token then
      options = {token = options}
    end
    local vk = VK(options.token, options.version)
    if options.queued then
      vk = Queue(vk)
    end
    self.api = APIWrapper(vk)
    self.longpoll = LongPoll(vk, options.group_id, options.wait)
    self.router = Router()
    self.on = self.router.on

    self.running = false
  end

  function Bot:run()
    logger:info("Bot longpoll started...")
    self.running = true
    coroutine.wrap(function()
      while self.running do
        for _, event in ipairs(self.longpoll:get_updates()) do
          self.router:handle_event(event)
        end
      end
    end)()
  end

  function Bot:stop()
    -- TO DO: longpoll stopping only after next request
    self.running = false
    logger:info("Bot longpoll stopped...")
  end

return setmetatable(Bot, {__call = function(cls, ...)
  local o = setmetatable({}, cls)
  o:init(...)
  return o
end})
