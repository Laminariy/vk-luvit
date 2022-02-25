local VK = require('./vk')
local Queue = require('./queue')
local APIWrapper = require('./api_wrapper')


local function API(options)
  if type(options) == 'string' or not options.token then
    options = {token = options}
  end
  local vk = VK(options.token, options.version)
  if options.queued then
    vk = Queue(vk)
  end
  return APIWrapper(vk)
end


-- TO DO: access to logger settings
return {
  VK = VK,
  Queue = Queue,
  APIWrapper = APIWrapper,
  API = API,
  Router = require('./router'),
  LongPoll = require('./longpoll'),
  Bot = require('./bot'),
  Keyboard = require('./keyboard')
}
