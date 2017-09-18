local flux = require "libs/flux/flux"

Camera = {
    x = 0,
    y = 0,
    scaleX = 1,
    scaleY = 1,
    panSpeed = 50,
    scale = 1,
    width = 0,
    heigth = 0,
    originalWidth = 0,
    originalHeight = 0
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

function Camera:set()
   love.graphics.push()
   love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
   love.graphics.pop()
end

function Camera:setSize(w, h)
   self.width = w
   self.originalWidth = w
   self.height = h
   self.originalHeight = h
end

function Camera:panTo(timeInSeconds, newX, newY)
   flux.to(self, timeInSeconds, {x = newX, y = newY})
end

function Camera:panToObject(timeInSeconds, obj)
   newX = obj.x
   newY = obj.y
   flux.to(self, timeInSeconds, {x = obj.x, y=obj.y})
end

function Camera:zoomOut(timeInSeconds)
   flux.to(self, 1, {scaleX = self.scaleX - 0.1,
                     scaleY = self.scaleY - 0.1,
                     width  = self.width + (self.originalWidth*0.1),
                     height = self.height + (self.originalHeight*0.1)})
end

function Camera:zoomIn(timeInSeconds)
   flux.to(self, 1, {scaleX = self.scaleX + 0.1,
                     scaleY = self.scaleY + 0.1,
                     width  = self.width - (self.originalWidth*0.1),
                     height = self.height - (self.originalHeight*0.1)})
end

return Camera
