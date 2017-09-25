require "assets"
require "settings"

local Object = require 'libs/classic/classic'

SettingsScene = Object:extend()

function SettingsScene:new()
   self.items = settings:currentSettings()
   table.insert(self.items, {"Voltar"})
   self.line = 1
   self.titleFont = assets.fonts.dpcomic(self.fontHeight)
   self.menuBackground = {0, 255, 255, 64}
   self.menuBorder = {0, 255, 255, 100}
   self.selected = {179, 211, 173, 200}
end

function SettingsScene:update(dt)
end

function SettingsScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local fontHeight = assets.config.fonts.titleHeight * settings:screenScaleFactor()
   local menuWidth = love.graphics.getWidth() * 0.4
   local menuItemHeight = fontHeight * 2
   local menuHeight = menuItemHeight * #self.items
   local x = love.graphics.getWidth() / 2 - menuWidth / 2
   local y = love.graphics.getHeight() / 2 - menuHeight / 2

   for i, setting in pairs(self.items) do
      if i == self.line then
         love.graphics.setColor(unpack(self.selected))
      else
         love.graphics.setColor(unpack(self.menuBackground))
      end

      love.graphics.rectangle('fill', x, y + (i - 1) * menuItemHeight,
                           menuWidth, menuItemHeight,
                           menuWidth / 10, menuWidth / 10)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.printf(settings:toString(setting), x,
                        y + (i - 1) * menuItemHeight + menuItemHeight / 2 - self.titleFont:getHeight() / 2,
                        menuWidth, 'center')

      love.graphics.setColor(unpack(self.menuBorder))

      love.graphics.rectangle('line', x, y + (i - 1) * menuItemHeight,
                           menuWidth, menuItemHeight,
                           menuWidth / 10, menuWidth / 10)
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
