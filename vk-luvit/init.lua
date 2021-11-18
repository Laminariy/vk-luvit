local API = require("./api")
local LongPoll = require("./longpoll")
local Blueprint = require("./blueprint")
local Keyboard = require("./keyboard")
return {
  API = API,
  LongPoll = LongPoll,
  Bot = LongPoll,
  Blueprint = Blueprint,
  Keyboard = Keyboard,
  kb = Keyboard.Keyboard,
  kb_colors = Keyboard.COLORS,
  kb_actions = Keyboard.ACTIONS
}
