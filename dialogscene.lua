require 'assets'

local Object = require 'libs/classic/classic'

DialogScene = Object:extend()

function DialogScene:new(dialogName, nextSceneName)
   self.characters = {}
   self.nextScene = nextSceneName
   self.currentInstruction = 1
   self:parseScript(dialogName)

   local scaleFactor = settings:screenScaleFactor()
   self.titleFont = assets.fonts.pressstartregular(assets.config.fonts.titleHeight * scaleFactor)
   self.textFont = assets.fonts.pressstartregular(assets.config.fonts.dialogTextHeight * scaleFactor)
end

function DialogScene:init()
end

function DialogScene:parseScript(dialogName)
   local script = io.open("assets/scripts/dialogs/"..dialogName:lower()..".dialog", "r"):read("*all")
   local lines = script:split('\n')
   for num, content in ipairs(lines) do
      local values = content:split(':')
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
   local inst = self.instructions[self.currentInstruction]
   if inst ~= nil then
      self:parseInstruction(inst)
      self.currentInstruction = self.currentInstruction + 1
   else
      sceneManager:setCurrent(self.nextScene)
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
      else
         self.rightChar = self.characters[char]
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
         self.leftChar = nil
      elseif self.rightChar == self.characters[char] then
         self.rightChar = nil
      end
   else
      print(inst)
   end
end

function DialogScene:update(dt)
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
      local x = 0
      local y = love.graphics.getHeight() * 0.3
      local scaleY = (love.graphics.getHeight() * 0.7) / self.leftChar.portrait:getHeight()
      local scaleX = scaleY
      love.graphics.draw(self.leftChar.portrait, x, y, 0, scaleX, scaleY)
   end
   -- right character --
   if self.rightChar ~= nil then
      local scaleY = (love.graphics.getHeight() * 0.7) / self.rightChar.portrait:getHeight()
      local scaleX = scaleY
      local x = love.graphics.getWidth() - (self.rightChar.portrait:getWidth()*scaleX)
      local y = (love.graphics.getHeight() * 0.3) * scaleY
      love.graphics.draw(self.rightChar.portrait, x, y, 0, scaleX, scaleY)
   end
   -- dialog box and content --
   if self.currentDialogText ~= nil then
      local x = love.graphics.getWidth() * 0.1
      local y = love.graphics.getHeight() * 0.7
      local w = love.graphics.getWidth() * 0.8
      local h = love.graphics.getHeight() * 0.3
      love.graphics.setColor(72, 178, 255, 255)
      love.graphics.rectangle('fill', x, y, w, h)

      x = love.graphics.getWidth() * 0.15
      y = love.graphics.getHeight() * 0.75
      w = love.graphics.getWidth() - (2 * x)

      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setFont(self.titleFont)
      love.graphics.printf(self.currentDialogChar.name, x, y, w, 'left')

      y = love.graphics.getHeight() * 0.8
      love.graphics.setFont(self.textFont)
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
