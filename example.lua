local Bot = require("vk-luvit").Bot


local bot = Bot('Your token')

bot.on.message_new(function(event)
  bot.api.messages.send({
    peer_id = event.message.from_id,
    random_id = 0,
    message = event.message.text
  })
end)

bot:run()
