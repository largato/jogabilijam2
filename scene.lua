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
   self.camera:panTo(2, self:currentChar().x - self.camera.width / 2,
                     self:currentChar().y - self.camera.height / 2)
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
   self.camera:panTo(2, self:currentChar().x - self.camera.width / 2,
                     self:currentChar().y - self.camera.height / 2)
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

function Scene:select()
   if self.playerCharIndex == 0 then
      return
   end
   self:currentChar().selected = true
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

function Scene:charActing()
   return self:currentChar():acting()
end

function Scene:menuUp()
   if not self:charSelected() then
      return
   end
   self:currentChar():menuUp()
end

function Scene:menuDown()
   if not self:charSelected() then
      return
   end
   self:currentChar():menuDown()
end

function Scene:keyPressed(key, scancode,  isRepeat)
   if key=="escape" and not isRepeat and self.playerCharIndex ~= 0 then
      self:unselectChar(self.playerCharIndex)
   elseif key=="up" and not isRepeat and self.playerCharIndex ~= 0 then
      if self:charActing() then
         self:targetTileUp()
      else
         self:menuUp();
      end
   elseif key=="down" and not isRepeat and self.playerCharIndex ~= 0 then
      if self:charActing() then
         self:targetTileDown()
      else
         self:menuDown();
      end
   elseif key=="left" and not isRepeat then
      if self:charSelected() then
         self:targetTileLeft()
      else
         self:previousChar()
      end
   elseif key=="right" and not isRepeat then
      if self:charSelected() then
         self:targetTileRight()
      else
         self:nextChar()
      end
   elseif key=="return" and not isRepeat and self.playerCharIndex ~= 0 then
      if not self:charSelected() then
         self:select();
      elseif self:charSelected() and not self:charActing() then
         local action = self:currentChar():action()
         if action == 1 then
            self:currentChar().moving = true
         elseif action == 2 then
            self:currentChar().attacking = true
         elseif action == 3 then
            self:skip()
         elseif action == 4 then
            self:unselectChar()
         end
      elseif self:charMoving() then
         self:move();
      elseif self:charAttacking() then
         self:attack();
      end
   end
end

function love.keypressed(key, scancode, isRepeat)
   Scene.currentScene:keyPressed(key, scancode, isRepeat)
end

return Scene
