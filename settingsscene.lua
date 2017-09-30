require "assets"
require "settings"

local Object = require 'libs/classic/classic'

SettingsScene = Object:extend()

function SettingsScene:new()
   self.items = settings:currentSettings()
   table.insert(self.items, {"Voltar"})
   self.line = 1
end

function SettingsScene:init()
   self.buttonOnImage = love.graphics.newImage('assets/images/button_on.png')
   self.buttonOffImage = love.graphics.newImage('assets/images/button_off.png')
   self.background = love.graphics.newImage('assets/images/bg_menu.png')
end

function SettingsScene:update(dt)
end

function SettingsScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local bgScaleX = love.graphics.getWidth() / self.background:getWidth()
   local bgScaleY = love.graphics.getHeight() / self.background:getHeight()
   love.graphics.draw(self.background, 0, 0, 0, bgScaleX, bgScaleY)

   fontHeight = assets.config.fonts.menuItemHeight * settings:screenScaleFactor()
   menuFont = assets.fonts.pressstartregular(fontHeight)
   menuWidth = love.graphics.getWidth() * 0.4
   menuItemHeight = fontHeight * 2
   menuHeight = menuItemHeight * #self.items
   x = love.graphics.getWidth() / 2 - menuWidth / 2
   y = love.graphics.getHeight() / 2 - menuHeight / 2
   buttonScaleX = menuWidth / self.buttonOnImage:getWidth()
   buttonScaleY = menuItemHeight / self.buttonOnImage:getHeight()

   for i, setting in pairs(self.items) do
      love.graphics.setColor(r, g, b, a)
      local button = nil
      if i == self.line then
         button = self.buttonOnImage
      else
         button = self.buttonOffImage
      end

      love.graphics.draw(button, x, y + (i - 1) * menuItemHeight, 0, buttonScaleX, buttonScaleY)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.setFont(menuFont)
      love.graphics.printf(settings:toString(setting), x,
                        y + (i - 1) * menuItemHeight + menuItemHeight / 2 - fontHeight / 2,
                        menuWidth, 'center')

   end

   love.graphics.setFont(oldFont)
   love.graphics.setColor(r, g, b, a)
end

function SettingsScene:keyPressed(key, scancode, isRepeat)
   if key=="up" and not isRepeat then
      self.line = (self.line - 2) % #self.items + 1
   elseif key=="down" and not isRepeat then
      self.line = self.line % #self.items + 1
   elseif key=="escape" and not isRepeat then
      sceneManager:setCurrent("menu")
   elseif key=="return" and not isRepeat then
      if self.items[self.line][1] == "Voltar" then -- XXX this is ugly, I know
         sceneManager:setCurrent("menu")
      end
   elseif key=="left" and not isRepeat then
      settings:previousSetting(self.line)
   elseif key=="right" and not isRepeat then
      settings:nextSetting(self.line)
   end
end

return SettingsScene
