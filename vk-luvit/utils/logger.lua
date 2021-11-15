--[[
Copyright (c) 2004-2013 Kepler Project.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
local printer = require("pretty-print")
printer.theme["FATAL"] = "27;31"
printer.theme["ERROR"] = "1;31"
printer.theme["WARN"] = "27;33"
printer.theme["INFO"] = "27;32"
printer.theme["DEBUG"] = "27;36"
printer.theme["TRACE"] = "27;34"

local function DEFAULT_APPEND(self, level, message)
  local time = os.date("%H:%M:%S")
  local colored = printer.colorize(level, "[%s %s]"):format(level, time)
  local msg = ("%s %s"):format(colored, message)
  printer.print(msg)
end


local DEFAULT_LEVELS = {
	-- The lowest possible rank and is intended to turn off logging.
	"OFF",
	-- Severe errors that cause premature termination. Expect these to be
	-- immediately visible on a status console.
	"FATAL",
	-- Other runtime errors or unexpected conditions. Expect these to be
	-- immediately visible on a status console.
	"ERROR",
	-- Use of deprecated APIs, poor use of API, 'almost' errors, other runtime
	-- situations that are undesirable or unexpected, but not necessarily
	-- "wrong". Expect these to be immediately visible on a status console.
	"WARN",
	-- Interesting runtime events (startup/shutdown). Expect these to be
	-- immediately visible on a console, so be conservative and keep to a
	-- minimum.
	"INFO",
	-- Detailed information on the flow through the system. Expect these to be
	-- written to logs only. Generally speaking, most lines logged by your
	-- application should be written as DEBUG.
	"DEBUG",
	-- Most detailed information. Expect these to be written to logs only.
	"TRACE"
}

local function indexof(val, t)
	local index = {}
	for k,v in pairs(t) do
		index[v] = k
	end
	return index[val]
end

-------------------------------------------------------------------------------
-- Creates a new logger object
-- @param append Function used by the logger to append a message with a
--	log-level to the log stream.
-- @return Table representing the new logger object.
-------------------------------------------------------------------------------
return function(append, settings)
	if type(append) ~= "function" then
    append = DEFAULT_APPEND
	end

	local logger = {}
	logger.append = append

	-- initialize all default values
	if type(settings) ~= "table" then
		settings = {}
	end
	setmetatable(settings, {
		__index = {
			levels = DEFAULT_LEVELS,
			init_level = DEFAULT_LEVELS[7]
		}
	})
	logger.levels = settings.levels
	logger.levelIndexByName = {}
	for k,v in ipairs(settings.levels) do
		logger.levelIndexByName[v] = k
	end

	-- Per level function.
	for _,l in pairs(logger.levels) do
		if type(l) == 'string' then
			logger[l:lower()] = function(self, msg)
				return self:log(l, msg)
			end
		else
			print('logger.lua err: cannot create log level function for none string ' ..
			      'default level ' .. tostring(l))
		end
	end

	function logger:setLevel(level)
		local order
		-- print('logger.lua debug: requested level is ' .. level)
		if type(level) == "number" then
			order = level
			level = self.levels[order]
		elseif type(level) == "string" then
			order = indexof(level, self.levels)
		end
		if not level then
			print('logger.lua err: level should be of type "number", not ' .. type(level))
			return
		end
		if not order then
			print('logger.lua err: level should be of type "string", not ' .. type(level))
			return
		end
		-- print('logger.lua debug: changing level to ' .. level .. ' (order = ' .. order .. ')')
		self.level = level
		self.level_order = order
	end
	-- initialize log level.
	logger:setLevel(settings.init_level)

	-- generic log function.
	function logger:log(level, msg)
		local order
		if type(level) == "number" then
			order = level
			level = self.levels[order]
		elseif type(level) == "string" then
			order = indexof(level, self.levels)
		end
		-- print('logger.lua debug: current level is ' .. self.level .. ' (order = ' .. self.level_order .. ')')
		-- print('logger.lua debug: testing against ' .. order)
		if order <= self.level_order then
			return self:append(level, msg)
		else
			return
		end
	end

	return logger
end
