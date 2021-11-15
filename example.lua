local vk = require("vk-luvit")


local api = vk.API("Your token")
local bot = vk.Bot(api)

bot.on.message_new(function(msg)
  local message = msg.message
  api.messages.send({
    peer_id = message.from_id,
    random_id = 0,
    message = message.text
  })
end)

bot:run()
