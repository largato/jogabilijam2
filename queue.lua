-- stolen from rosetta code https://rosettacode.org/wiki/Queue/Definition#Lua

local Object = require "libs/classic/classic"
local Queue = Object:extend()

function Queue:new()
  self.first = 0
  self.last = -1
end

function Queue:push(value)
  self.last = self.last + 1
  self[self.last] = value
end

function Queue:pop()
  if self.first > self.last then
    return nil
  end

  local val = self[self.first]
  self[self.first] = nil
  self.first = self.first + 1
  return val
end

function Queue:empty()
  return self.first > self.last
end

return Queue
