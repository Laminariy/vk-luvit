local vk = require("vk-luvit")


local api = vk.api("Your token")
local longpoll = vk.longpoll(api)

longpoll:add_handler("message_new", function(msg)
  local message = msg.message
  api.messages.send({
    peer_id = message.from_id,
    random_id = 0,
    message = message.text
  })
end)

longpoll:run()
