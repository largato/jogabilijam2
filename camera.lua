local flux = require "libs/flux/flux"

Camera = {
    x = 0,
    y = 0,
    width = 640,
    height = 480,
    speed = 50
}

function Camera:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function Camera:update(dt)
   flux.update(dt)
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
