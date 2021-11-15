local Class = require("./utils/class")


local function msg_obj(api, peer_id, msg_id)
  local msg = {
    api = api,
    peer_id = peer_id,
    msg_id = msg_id
  }

  function msg:edit(params)
    local def_params = {
      peer_id = self.peer_id,
      message_id = self.msg_id
    }
    if type(params) == "string" then
      def_params.message = params
    else
      if params then
        for k, v in pairs(params) do
          def_params[k] = v
        end
      end
    end
    return self.api.messages.edit(def_params)
  end

  function msg:delete(params)
    local def_params = {
      delete_for_all = true,
      peer_id = self.peer_id,
      message_ids = {self.msg_id}
    }
    if params then
      for k, v in pairs(params) do
        def_params[k] = v
      end
    end
    return self.api.messages.delete(def_params)
  end

  return msg
end

local Msg = Class()

  function Msg:init(api, peer_id, reply_to)
    self.api = api
    self.peer_id = peer_id
    self.reply_id = reply_to
  end

  function Msg:send(params)
    local def_params = {
      random_id = 0,
      peer_id = self.peer_id
    }
    if type(params) == "string" then
      def_params.message = params
    else
      if params then
        for k, v in pairs(params) do
          def_params[k] = v
        end
      end
    end

    local msg_id = self.api.messages.send(def_params)
    return msg_obj(self.api, self.peer_id, msg_id)
  end

  function Msg:reply(params)
    local def_params = {
      random_id = 0,
      peer_id = self.peer_id,
      reply_to = self.reply_to
    }
    if type(params) == "string" then
      def_params.message = params
    else
      if params then
        for k, v in pairs(params) do
          def_params[k] = v
        end
      end
    end

    local msg_id = self.api.messages.send(def_params)
    return msg_obj(self.api, self.peer_id, msg_id)
  end

return Msg
