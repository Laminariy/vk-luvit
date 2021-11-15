local vk = require("vk-luvit")


local api = vk.API("Your token")
local bot = vk.Bot(api)

bot.on.message_new(function(event)
  msg:send("Hello!")
end)

bot:run()
