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
   self.playerCharIndex = 0
   self:nextChar()
   self.turn = 1
   self.team = "Player"

   local scaleFactor = love.graphics.getWidth()/1280
   self.titleFont = love.graphics.newFont('assets/fonts/dpcomic.ttf', 36*scaleFactor)
   self.charNameFont = love.graphics.newFont('assets/fonts/dpcomic.ttf', 26*scaleFactor)
   self.menuItemFont = love.graphics.newFont('assets/fonts/dpcomic.ttf', 20*scaleFactor)
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
   --self.map:resize(c.width, c.height)
   self.map:draw(-c.x, -c.y, c.scaleX, c.scaleY)
   manager:draw(0,0)
   self:drawHUD(c.x, c.y)
   c:unset()
end

function Scene:drawHUD(ox, oy)
   -- Store original graphical settings --
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   -- Turn/phase information --
   local turnInfo = "Turn "..self.turn.." - "..self.team.." phase"
   local tunInfoX = love.graphics.getWidth() - self.titleFont:getWidth(turnInfo) - 10
   love.graphics.setFont(self.titleFont)
   love.graphics.setColor(255, 0, 0, 255)
   love.graphics.printf(turnInfo, ox+tunInfoX, oy+10, love.graphics.getWidth(), 'left')

   -- Selected character sheet --
   local charSheetX = ox + love.graphics.getWidth() * 0.02
   local charSheetY = oy + love.graphics.getHeight() * 0.75
   local charSheetWidth = love.graphics.getWidth() * 0.25
   local charSheetHeight = love.graphics.getHeight() * 0.23
   local charPicX = charSheetX + (charSheetWidth * 0.05)
   local charPicY = charSheetY + (charSheetHeight * 0.2)
   local charPicWidth = charSheetWidth * 0.4
   local charPicHeight = charSheetHeight * 0.75
   local charNameX = charSheetX + (charSheetWidth * 0.05)
   local charNameY = charSheetY + (charSheetHeight * 0.02)
   local charAttrWidth = (charSheetWidth - charPicWidth) * 0.8
   local charAttrX = charNameX + charPicWidth + (charSheetWidth * 0.02)
   local charHPY = charNameY + (charSheetHeight * 0.2)
   local charMPY = charHPY + (charSheetHeight * 0.2)
   local charName = "character name" -- todo: get from manager?
   local charHP = "48/57" -- todo: get from manager?
   local charMP = "13/21" -- todo: get from manager?
   love.graphics.setColor(0, 0, 255, 128)
   love.graphics.rectangle('fill', charSheetX, charSheetY, charSheetWidth, charSheetHeight)
   love.graphics.setColor(255, 0, 0, 255)
   love.graphics.rectangle('fill', charPicX, charPicY, charPicWidth, charPicHeight)
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.setFont(self.charNameFont)
   love.graphics.printf(charName, charNameX, charNameY, charSheetWidth, 'center')
   love.graphics.setFont(self.menuItemFont)
   love.graphics.printf("HP", charAttrX, charHPY, charAttrWidth, 'left')
   love.graphics.printf(charHP, charAttrX, charHPY, charAttrWidth, 'right')
   love.graphics.printf("MP", charAttrX, charMPY, charAttrWidth, 'left')
   love.graphics.printf(charMP, charAttrX, charMPY, charAttrWidth, 'right')

   -- Restore original graphical settings --
   love.graphics.setFont(oldFont)
   love.graphics.setColor(r, g, b, a)
end

function Scene:update(dt)
   self.camera:update(dt)
   self.map:update(dt)
   manager:update(dt)
end

function Scene:highlightChar(index)
   if self.playerCharIndex == index then
      return
   end

   if self.playerCharIndex > 0 then
      self:currentChar().highlighted = false
   end

   self.playerChars[index].highlighted = true
   self.playerCharIndex = index
end

function Scene:selectChar(index)
   if self.playerCharIndex > 0 then
      self:currentChar().selected = true
   end
end

function Scene:unselectChar(index)
   if self.playerCharIndex > 0 then
      local char = self:currentChar()
      char.selected = false
      char.attacking = false
      char.moving = false
      char.targetTile = {x=char.tileX, y=char.tileY}
   end
end

function Scene:nextChar()
   if (self.playerCharIndex > 0 and self:currentChar().selected) or self:turnEnded() then
      return
   end

   local index = self.playerCharIndex
   repeat
      index = index % table.getn(self.playerChars) + 1
   until not self.playerChars[index]:turnDone()
   self:highlightChar(index)
end

function Scene:previousChar()
   if (self.playerCharIndex > 0 and self:currentChar().selected) or self:turnEnded() then
      return
   end

   local index = self.playerCharIndex
   repeat
      index = (index - 2) % table.getn(self.playerChars) + 1
   until not self.playerChars[index]:turnDone()
   self:highlightChar(index)
end

function Scene:targetTileUp()
   if not self:charSelected() then
      return
   end
   self:currentChar():targetTileUp()
end

function Scene:targetTileDown()
   if not self:charSelected() then
      return
   end
   self:currentChar():targetTileDown()
end

function Scene:targetTileLeft()
   if not self:charSelected() then
      return
   end
   self:currentChar():targetTileLeft()
end

function Scene:targetTileRight()
   if not self:charSelected() then
      return
   end
   self:currentChar():targetTileRight()
end

function Scene:charSelected()
   return self.playerCharIndex > 0 and self:currentChar().selected
end

function Scene:charMoving()
   return self.playerCharIndex > 0 and self:currentChar().moving
end

function Scene:charAttacking()
   return self.playerCharIndex > 0 and self:currentChar().attacking
end

function Scene:move()
   if not self:charSelected() then
      return
   end
   self:currentChar():moveToTarget()
   if self:currentChar():turnDone() then
      self:skip()
   end
end

function Scene:attack()
   if not self:charSelected() then
      return
   end
   self:currentChar():attackTarget()
   if self:currentChar():turnDone() then
      self:skip()
   end
end

function Scene:setMoving()
   if not self:charSelected() or self:currentChar().moved  then
      return
   end
   self:currentChar().moving = true
end

function Scene:setAttacking()
   if not self:charSelected() or self:currentChar().attacked then
      return
   end
   self:currentChar().attacking = true
end

function Scene:turnEnded()
   for i, char in ipairs(self.playerChars) do
      if not char:turnDone() then
         return false
      end
   end
   return true
end

function Scene:nextTeam()
   if self.team == "Player" then
      self.team = "Enemy"
   else
      self.team = "Player"
   end
end

function Scene:skip()
   if self.playerCharIndex == 0 then
      return
   end
   self:currentChar():skip()
   if self:turnEnded() then
      self:nextTeam()
   else
      self:nextChar()
   end
end

function Scene:currentChar()
   return self.playerChars[self.playerCharIndex]
end

function love.keypressed(key, scancode, isRepeat)
   if key=="space" and not isRepeat then
      Scene.currentScene.camera:panTo(2, Scene.currentScene.map.width * Scene.currentScene.map.tilewidth / 2 - Scene.currentScene.camera.width / 2,
                                      Scene.currentScene.map.height * Scene.currentScene.map.tileheight / 2 - Scene.currentScene.camera.height / 2)
   elseif key=="escape" and not isRepeat and Scene.currentScene.playerCharIndex ~= 0 then
      Scene.currentScene:unselectChar(Scene.currentScene.playerCharIndex)
   elseif key=="s" and not isRepeat and Scene.currentScene.playerCharIndex ~= 0 then
      Scene.currentScene:skip()
   elseif key=="up" and not isRepeat and Scene.currentScene.playerCharIndex ~= 0 then
      Scene.currentScene:targetTileUp()
   elseif key=="down" and not isRepeat and Scene.currentScene.playerCharIndex ~= 0 then
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
         Scene.currentScene:selectChar(Scene.currentScene.playerCharIndex)
      end
      Scene.currentScene:setAttacking()
   elseif key=="m" and not isRepeat then
      if Scene.currentScene:charMoving() or Scene.currentScene:charAttacking() then
         return
      end
      if not Scene.currentScene:charSelected() then
         Scene.currentScene:selectChar(Scene.currentScene.playerCharIndex)
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
