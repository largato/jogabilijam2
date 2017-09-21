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
      manager:add(SampleChar(map, object.layer, object.x, object.y, 96, characterType))
   end

   self.playerChars = manager:getByType("Player")
   self.cpuChars = manager:getByType("CPU")
   self.currentChar = 0
   self:nextChar()
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

function Scene:highlightChar(index)
   if self.currentChar == index then
      return
   end

   if self.currentChar > 0 then
      self.playerChars[self.currentChar].highlighted = false
   end

   self.playerChars[index].highlighted = true
   self.currentChar = index
end

function Scene:selectChar(index)
   if self.currentChar > 0 then
      self.playerChars[self.currentChar].selected = true
   end
end

function Scene:unselectChar(index)
   if self.currentChar > 0 then
      local char = self.playerChars[self.currentChar]
      char.selected = false
      char.attacking = false
      char.moving = false
      char.targetTile = {x=char.tileX, y=char.tileY}
   end
end

function Scene:nextChar()
   if self.currentChar > 0 and self.playerChars[self.currentChar].selected then
      return
   end
   local index = self.currentChar % table.getn(self.playerChars) + 1
   self:highlightChar(index)
end

function Scene:previousChar()
   if self.currentChar > 0 and self.playerChars[self.currentChar].selected then
      return
   end
   local index = (self.currentChar - 2) % table.getn(self.playerChars) + 1
   self:highlightChar(index)
end

function Scene:targetTileUp()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar]:targetTileUp()
end

function Scene:targetTileDown()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar]:targetTileDown()
end

function Scene:targetTileLeft()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar]:targetTileLeft()
end

function Scene:targetTileRight()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar]:targetTileRight()
end

function Scene:charSelected()
   return self.currentChar > 0 and self.playerChars[self.currentChar].selected
end

function Scene:charMoving()
   return self.currentChar > 0 and self.playerChars[self.currentChar].moving
end

function Scene:charAttacking()
   return self.currentChar > 0 and self.playerChars[self.currentChar].attacking
end

function Scene:move()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar]:moveToTarget()
end

function Scene:attack()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar]:attackTarget()
end

function Scene:setMoving()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar].moving = true
end

function Scene:setAttacking()
   if not self:charSelected() then
      return
   end
   self.playerChars[self.currentChar].attacking = true
end

function love.keypressed(key, scancode, isRepeat)
   if key=="space" and not isRepeat then
      Scene.currentScene.camera:panTo(2, Scene.currentScene.map.width * Scene.currentScene.map.tilewidth / 2 - Scene.currentScene.camera.width / 2,
                                      Scene.currentScene.map.height * Scene.currentScene.map.tileheight / 2 - Scene.currentScene.camera.height / 2)
   elseif key=="escape" and not isRepeat and Scene.currentScene.currentChar ~= 0 then
      Scene.currentScene:unselectChar(Scene.currentScene.currentChar)
   elseif key=="up" and not isRepeat and Scene.currentScene.currentChar ~= 0 then
      Scene.currentScene:targetTileUp()
   elseif key=="down" and not isRepeat and Scene.currentScene.currentChar ~= 0 then
      Scene.currentScene:targetTileDown()
   elseif key=="left" and not isRepeat then
      if Scene.currentScene:charSelected() then
         Scene.currentScene:targetTileLeft()
      else
         Scene.currentScene:previousChar()
      end
   elseif key=="right" and not isRepeat then
      if Scene.currentScene:charSelected() then
         Scene.currentScene:targetTileRight()
      else
         Scene.currentScene:nextChar()
      end
   elseif key=="a" and not isRepeat then
      if Scene.currentScene:charMoving() or Scene.currentScene:charAttacking() then
         return
      end
      if not Scene.currentScene:charSelected() then
         Scene.currentScene:selectChar(Scene.currentScene.currentChar)
      end
      Scene.currentScene:setAttacking()
   elseif key=="m" and not isRepeat then
      if Scene.currentScene:charMoving() or Scene.currentScene:charAttacking() then
         return
      end
      if not Scene.currentScene:charSelected() then
         Scene.currentScene:selectChar(Scene.currentScene.currentChar)
      end
      Scene.currentScene:setMoving()
   elseif key=="return" and not isRepeat then
      if Scene.currentScene:charMoving() then
         Scene.currentScene:move();
      end
      if Scene.currentScene:charAttacking() then
         Scene.currentScene:attack();
      end
   end
end



return Scene
