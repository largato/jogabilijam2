require "entitymanager"

local Object = require 'libs/classic/classic'
local SampleChar = require "samplechar"

Scene = Object:extend()
Scene.currentScene = nil

function Scene:new(camera, map)
   self.map = map
   self.camera = camera

   for k, object in pairs(map.objects) do
      local parts = object.name:split("-")
      local characterType = parts[1]
      local characterName = parts[2]
      manager:add(SampleChar(object.x, object.y, 96, characterType))
   end

   self.playerChars = manager:getByType("Player")
   self.cpuChars = manager:getByType("CPU")
   self.currentChar = 0
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

function Scene:selectChar(index)
   if self.currentChar == index then
      return
   end

   if self.currentChar > 0 then
      self.playerChars[self.currentChar].selected = false
   end

   self.playerChars[index].selected = true
   self.currentChar = index
end

function Scene:nextChar()
   local index = self.currentChar % table.getn(self.playerChars) + 1
   self:selectChar(index)
   print("selected char", self.currentChar)
end

function Scene:previousChar()
   local index = (self.currentChar - 2) % table.getn(self.playerChars) + 1
   self:selectChar(index)
   print("selected char", self.currentChar)
end

function love.keypressed(key, scancode, isRepeat)
   if key=="left" and not isRepeat then
      Scene.currentScene:previousChar()
   elseif key=="right" and not isRepeat then
      Scene.currentScene:nextChar()
   elseif key=="space" and not isRepeat then
      Scene.currentScene.camera:panTo(2, Scene.currentScene.map.width * Scene.currentScene.map.tilewidth / 2 - Scene.currentScene.camera.width / 2,
                                      Scene.currentScene.map.height * Scene.currentScene.map.tileheight / 2 - Scene.currentScene.camera.height / 2)
   end
end



return Scene
