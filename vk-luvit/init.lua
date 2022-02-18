local VK = require('./vk')
local Queue = require('./queue')
local APIWrapper = require('./api_wrapper')


local function API(options)
  -- token, version, queued
  local vk = VK(options.token, options.version)
  if options.queued then
    vk = Queue(vk)
  end
  return APIWrapper(vk)
end


return {
  VK = VK,
  API = API,
  Bot = require('./bot'),
  Keyboard = require('./keyboard')
}
