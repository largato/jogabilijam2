require "entitymanager"

local Object = require 'libs/classic/classic'

Scene = Object:extend()

function Scene:new(camera, map)
   self.map = map
   self.camera = camera
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
   manager:draw(0,0)
   c:unset()
end

function Scene:update(dt)
   self.camera:update(dt)
   self.map:update(dt)
   manager:update(dt)
end

return Scene
