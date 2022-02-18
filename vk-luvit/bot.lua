local Class = require('./utils/class')
local VKRequest = require('./vk_request')
local Queue = require('./queue')
local APIWrapper = require('./api_wrapper')
local LongPoll = require('./longpoll')
local Router = require('./router')
local logger = require('./utils/logger')


local Bot = Class{}

  function Bot:init(options)
    if type(options) == 'string' or not options.token then
      options = {token = options}
    end
    local vk_request = VKRequest(options.token, options.version)
    if options.queued then
      vk_request = Queue(vk_request)
    end
    self.api = APIWrapper(vk_request)
    self.longpoll = LongPoll(vk_request, options.group_id, options.wait)
    self.router = Router()
    self.on = self.router.on

    self.running = false
  end

  function Bot:connect_router(router)
    self.router:connect(router)
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

return Bot
