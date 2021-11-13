local vk = require("vk-luvit")
local vk_api, vk_lp = vk.api, vk.longpoll

local function main()
  local token = "Your token or table of tokens"
  local version = "5.131"
  local api = vk_api(token, version)
  local longpoll = vk_lp(api)
  longpoll:add_handler("message_new", function(msg)
    local message = msg.message
    api.messages.send({
      peer_id = message.from_id,
      random_id = 0,
      message = message.text
    })
  end)
  longpoll:run()
end

coroutine.wrap(main)()
