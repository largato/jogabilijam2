require "assets"
require "settings"

local Object = require 'libs/classic/classic'

SettingsScene = Object:extend()

function SettingsScene:new()
   self.items = settings:currentSettings()
   table.insert(self.items, {"Voltar"})
   self.line = 1
   self.fontHeight = assets.config.fonts.titleHeight * assets.config.screen.scaleFactor
   self.titleFont = assets.fonts.dpcomic(self.fontHeight)
   self.menuBackground = {0, 255, 255, 64}
   self.menuBorder = {0, 255, 255, 100}
   self.selected = {179, 211, 173, 200}
   self.menuWidth = love.graphics.getWidth() * 0.4
   self.menuItemHeight = self.fontHeight * 2
   self.menuHeight = self.menuItemHeight * #self.items
   self.x = love.graphics.getWidth() / 2 - self.menuWidth / 2
   self.y = love.graphics.getHeight() / 2 - self.menuHeight / 2
end

function SettingsScene:update(dt)
end

function SettingsScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   for i, setting in pairs(self.items) do
      if i == self.line then
         love.graphics.setColor(unpack(self.selected))
      else
         love.graphics.setColor(unpack(self.menuBackground))
      end

      love.graphics.rectangle('fill', self.x, self.y + (i - 1) * self.menuItemHeight,
                           self.menuWidth, self.menuItemHeight,
                           self.menuWidth / 10, self.menuWidth / 10)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.printf(settings:toString(setting), self.x,
                        self.y + (i - 1) * self.menuItemHeight + self.menuItemHeight / 2 - self.titleFont:getHeight() / 2,
                        self.menuWidth, 'center')

      love.graphics.setColor(unpack(self.menuBorder))

      love.graphics.rectangle('line', self.x, self.y + (i - 1) * self.menuItemHeight,
                           self.menuWidth, self.menuItemHeight,
                           self.menuWidth / 10, self.menuWidth / 10)
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
