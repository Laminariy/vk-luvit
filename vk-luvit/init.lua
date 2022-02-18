local VKRequest = require('./vk_request')
local Queue = require('./queue')
local APIWrapper = require('./api_wrapper')


local function API(options)
  -- token, version, queued
  local vk_request = VKRequest(options.token, options.version)
  if options.queued then
    vk_request = Queue(vk_request)
  end
  return APIWrapper(vk_request)
end


return {
  API = API,
  Bot = require('./bot'),
  Router = require('./router')
}
