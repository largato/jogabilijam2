require "entitymanager"

Scene = {
   map = nil,
   camera = nil
}

function Scene:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function Scene:setCamera(c)
   self.camera = c
end

function Scene:setMap(m)
   self.map = m
end

function Scene:draw()
   local c = self.camera
   c:set()
   self.map:resize(c.width, c.height)
   self.map:draw(-c.x, -c.y, c.scaleX, c.scaleY)
   manager:draw()
   c:unset()
end

function Scene:update(dt)
   self.camera:update(dt)
   self.map:update(dt)
   manager:update(dt)
end

return Scene
