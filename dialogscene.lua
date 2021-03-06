require 'assets'

local Object = require 'libs/classic/classic'
local flux = require 'libs/flux/flux'

DialogScene = Object:extend()

function DialogScene:new(dialogName, nextScene)
   self.characters = {}
   self.nextScene = nextScene
   self:parseScript(dialogName)
end

function DialogScene:init()
   local scaleFactor = settings:screenScaleFactor()
   self.titleFont = assets.fonts.pressstartregular(assets.config.fonts.charNameHeight * scaleFactor)
   self.textFont = assets.fonts.pressstartregular(assets.config.fonts.dialogTextHeight * scaleFactor)
   self.dialogBox = love.graphics.newImage('assets/images/dialog_box.png')
   self.absentLeftX = -love.graphics.getWidth() / 2
   self.absentRightX = love.graphics.getWidth() * 1.5
   self.leftX = self.absentLeftX
   self.rightX = self.absentRightX

   self.currentInstruction = 1
end

function DialogScene:parseScript(dialogName)
   local fileName = "assets/scripts/dialogs/"..dialogName:lower()..".dialog"
   local content, _ = love.filesystem.read(fileName)
   local lines = content:split('\n')
   for i, line in ipairs(lines) do
      local values = line:split(':')
      if values[1] == 'chars' then
         local chars = values[2]:split(',')
         for i, c in ipairs(chars) do
            local charName = c:gsub("%s+", "")
            self.characters[charName] = Character.loadCharFromScript(charName)
         end
      elseif values[1] == 'background' then
         local imgFile = values[2]:gsub("%s+", "")
         self.background = love.graphics.newImage(imgFile)
      elseif values[1] == 'start' then
         self.instructions = {}
      elseif values[1] == 'end' then
         return
      else
         table.insert(self.instructions, values[1])
      end
   end
end

function DialogScene:nextInstruction()
   self.currentDialogText = nil
   local inst = self.instructions[self.currentInstruction]
   if inst ~= nil then
      self:parseInstruction(inst)
      self.currentInstruction = self.currentInstruction + 1
   else
      sceneManager:popAndPushScene(self.nextScene)
   end
end

function DialogScene:parseInstruction(inst)
   local parts = inst:split(' ')
   local command = parts[1]:gsub("%s+", "")
   local char = parts[2]:gsub("%s+", "")

   if command == 'enter' then
      local side = parts[3]:gsub("%s+", "")
      if side == 'left' then
         self.leftChar = self.characters[char]
         flux.to(self, 0.5, { leftX = 0 })
      else
         self.rightChar = self.characters[char]
         local scaleX = (love.graphics.getHeight() * 0.7) / self.rightChar.portrait:getHeight()
         flux.to(self, 0.5, { rightX = love.graphics.getWidth() - (self.rightChar.portrait:getWidth()*scaleX) })
      end
   elseif command == 'say' then
      self.currentDialogChar = self.characters[char]
      local text = ""
      for i=3,#parts do
         text = text .. parts[i] .. " "
      end
      self.currentDialogText = text
   elseif command == 'exit' then
      if self.leftChar == self.characters[char] then
         flux.to(self, 0.5, { leftX = self.absentLeftX })
         --self.leftChar = nil
      elseif self.rightChar == self.characters[char] then
         flux.to(self, 0.5, { rightX = self.absentRightX })
         --self.rightChar = nil
      end
   else
      print("ERROR: Unknown instruction "..inst)
   end
end

function DialogScene:update(dt)
   flux.update(dt)
   if self.canProceed then
      self:nextInstruction()
      self.canProceed = false
   end
end

function DialogScene:draw()
   -- store previous graphic settings --
   local r, g, b, a = love.graphics.getColor()
   local originalFont = love.graphics.getFont()
   -- background --
   local bgXScale = love.graphics.getWidth()/self.background:getWidth()
   local bgYScale = love.graphics.getHeight()/self.background:getHeight()
   love.graphics.draw(self.background, 0, 0, 0, bgXScale, bgYScale)
   -- left character --
   if self.leftChar ~= nil then
      local scaleY = (love.graphics.getHeight() * 0.7) / self.leftChar.portrait:getHeight()
      local scaleX = scaleY
      local y = love.graphics.getHeight() * 0.3
      love.graphics.draw(self.leftChar.portrait, self.leftX, y, 0, scaleX, scaleY)
   end
   -- right character --
   if self.rightChar ~= nil then
      local scaleY = (love.graphics.getHeight() * 0.7) / self.rightChar.portrait:getHeight()
      local scaleX = scaleY
      local x = self.rightX
      local y = love.graphics.getHeight() * 0.3
      love.graphics.draw(self.rightChar.portrait, x, y, 0, scaleX, scaleY)
   end
   -- dialog box and content --
   if self.currentDialogText ~= nil then
      local x = love.graphics.getWidth() * 0.1
      local y = love.graphics.getHeight() * 0.7
      local w = (love.graphics.getWidth() * 0.8) / self.dialogBox:getWidth()
      local h = love.graphics.getHeight() * 0.3 / self.dialogBox:getHeight()
      love.graphics.draw(self.dialogBox, x, y, 0, w, h)

      x = love.graphics.getWidth() * 0.15
      y = love.graphics.getHeight() * 0.75
      w = love.graphics.getWidth() - (2 * x)

      love.graphics.setFont(self.titleFont)
      love.graphics.setColor(32, 138, 215, 255)
      love.graphics.printf(self.currentDialogChar.name, x, y, w, 'left')

      y = love.graphics.getHeight() * 0.8
      love.graphics.setFont(self.textFont)
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.printf(self.currentDialogText, x, y, w, 'left')
   end
   -- restore previous graphic settings --
   love.graphics.setColor(r, g, b, a)
   love.graphics.setFont(originalFont)
end

function DialogScene:keyPressed(key, scancode, isRepeat)
   if (not isRepeat) then
      self.canProceed = true
   end
end

return DialogScene
