require "entitymanager"

local Object = require 'libs/classic/classic'
local SampleChar = require "samplechar"
local Behavior = require "libs/knife/knife/behavior"

Scene = Object:extend()
Scene.currentScene = nil

function Scene:new(camera, map)
   self.map = map
   self.camera = camera

   for k, object in pairs(map.objects) do
      local parts = object.name:split("-")
      local charType = parts[1]
      local charName = parts[2]
      local char = SampleChar(map, object.layer, object.x, object.y, 96, charType, charName, 50, 30)
      manager:add(char)
   end

   self.playerChars = manager:getByType("Player")
   self.cpuChars = manager:getByType("CPU")
   self.charIndex = 0
   self.turn = 1
   self.team = "Player"

   local scaleFactor = love.graphics.getWidth()/1280
   self.titleFont = love.graphics.newFont('assets/fonts/dpcomic.ttf', 36*scaleFactor)
   self.charNameFont = love.graphics.newFont('assets/fonts/dpcomic.ttf', 26*scaleFactor)
   self.menuItemFont = love.graphics.newFont('assets/fonts/dpcomic.ttf', 20*scaleFactor)

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
   local turnInfo = "Turno "..self.turn.." - "..self.team
   local tunInfoX = love.graphics.getWidth() - self.titleFont:getWidth(turnInfo) - 10
   love.graphics.setFont(self.titleFont)
   love.graphics.setColor(255, 0, 0, 255)
   love.graphics.printf(turnInfo, ox+tunInfoX, oy+10, love.graphics.getWidth(), 'left')

   -- Selected character sheet --
   if self:charSelected() then
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
      local charName = self:char().name
      local charHP = self:char().HP.."/"..self:char().originalHP
      local charMP = self:char().MP.."/"..self:char().originalMP

      love.graphics.setColor(0, 0, 255, 128)
      love.graphics.rectangle('fill', charSheetX, charSheetY, charSheetWidth, charSheetHeight)
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.rectangle('fill', charPicX, charPicY, charPicWidth, charPicHeight)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setFont(self.charNameFont)
      love.graphics.printf(charName, charNameX, charNameY, charSheetWidth, 'center')
      love.graphics.setFont(self.menuItemFont)
      love.graphics.printf("Vida", charAttrX, charHPY, charAttrWidth, 'left')
      love.graphics.printf(charHP, charAttrX, charHPY, charAttrWidth, 'right')
      love.graphics.printf("Fuleiragem", charAttrX, charMPY, charAttrWidth, 'left')
      love.graphics.printf(charMP, charAttrX, charMPY, charAttrWidth, 'right')
   end
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
   if self.charIndex == index then
      return
   end

   if self.charIndex > 0 then
      self:char().highlighted = false
   end

   self:char(index).highlighted = true
   self.charIndex = index
end

function Scene:selectChar(index)
   if self.charIndex > 0 then
      self:char().selected = true
   end
end

function Scene:unselectChar(index)
   if self.charIndex > 0 then
      local char = self:char()
      char.selected = false
      char.attacking = false
      char.moving = false
      char.targetTile = {x=char.tileX, y=char.tileY}
   end
end

function Scene:nextChar()
   if (self:char() and self:char().selected) or self:turnEnded() then
      return
   end

   local index = self.charIndex
   repeat
      index = index % table.getn(self:currentTeam()) + 1
   until not self:char(index):turnDone()
   self:highlightChar(index)
   self.camera:panTo(1, self:char().x - self.camera.width / 2,
                     self:char().y - self.camera.height / 2)
end

function Scene:previousChar()
   if (self:char() and self:char().selected) or self:turnEnded() then
      return
   end

   local index = self.charIndex
   repeat
      index = (index - 2) % table.getn(self:currentTeam()) + 1
   until not self:char(index):turnDone()
   self:highlightChar(index)
   self.camera:panTo(1, self:char().x - self.camera.width / 2,
                     self:char().y - self.camera.height / 2)
end

function Scene:targetTileUp()
   if not self:charSelected() then
      return
   end
   self:char():targetTileUp()
end

function Scene:targetTileDown()
   if not self:charSelected() then
      return
   end
   self:char():targetTileDown()
end

function Scene:targetTileLeft()
   if not self:charSelected() then
      return
   end
   self:char():targetTileLeft()
end

function Scene:targetTileRight()
   if not self:charSelected() then
      return
   end
   self:char():targetTileRight()
end

function Scene:charSelected()
   return self:char() and self:char().selected
end

function Scene:charMoving()
   return self:char() and self:char().moving
end

function Scene:charAttacking()
   return self:char() and self:char().attacking
end

function Scene:move()
   if not self:charSelected() then
      return
   end
   self:char():moveToTarget()
   if self:char():turnDone() then
      self:skip()
   end
end

function Scene:select()
   if self.charIndex == 0 then
      return
   end
   self:char().selected = true
end

function Scene:attack()
   if not self:charSelected() then
      return
   end
   self:char():attackTarget()
   if self:char():turnDone() then
      self:skip()
   end
end

function Scene:currentTeam()
   local chars = self.playerChars
   if self.team == "Enemy" then
      chars = self.cpuChars
   end
   return chars
end

function Scene:turnEnded()
   for i, char in ipairs(self:currentTeam()) do
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
   if not self:char() then
      return
   end
   self:char():skip()
   if self:turnEnded() then
      self:nextTeam()
   else
      self:nextChar()
   end
end

function Scene:char(index)
   if self.team == "Player" then
      return self.playerChars[index or self.charIndex]
   else
      return self.cpuChars[index or self.charIndex]
   end
end

function Scene:charActing()
   return self:char():acting()
end

function Scene:menuUp()
   if not self:charSelected() then
      return
   end
   self:char():menuUp()
end

function Scene:menuDown()
   if not self:charSelected() then
      return
   end
   self:char():menuDown()
end

function Scene:keyPressed(key, scancode,  isRepeat)
   if key=="escape" and not isRepeat and self.charIndex ~= 0 then
      self:unselectChar(self.charIndex)
   elseif key=="up" and not isRepeat and self.charIndex ~= 0 then
      if self:charActing() then
         self:targetTileUp()
      else
         self:menuUp();
      end
   elseif key=="down" and not isRepeat and self.charIndex ~= 0 then
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
   elseif key=="return" and not isRepeat and self.charIndex ~= 0 then
      if not self:charSelected() then
         self:select();
      elseif self:charSelected() and not self:charActing() then
         local action = self:char():action()
         if action == 1 then
            self:char().moving = true
         elseif action == 2 then
            self:char().attacking = true
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
