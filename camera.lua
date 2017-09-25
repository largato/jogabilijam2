flux = require "libs/flux/flux"

local Object = require 'libs/classic/classic'

Camera = Object:extend()

function Camera:new()
   self.x = 0
   self.y = 0
   self.scaleX = 1
   self.scaleY = 1
   self.panSpeed = 50
   self.scale = 1
end

function Camera:update(dt)
   flux.update(dt)
end

function Camera:set()
   love.graphics.push()
   love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
   love.graphics.pop()
end

function Camera:panTo(timeInSeconds, newX, newY)
   flux.to(self, timeInSeconds, {x = newX, y = newY})
end

function Camera:panToObject(timeInSeconds, obj)
   newX = obj.x
   newY = obj.y
   flux.to(self, timeInSeconds, {x = obj.x, y=obj.y})
end

return Camera
