require "assets"

local Object = require 'libs/classic/classic'

MenuScene = Object:extend()

function MenuScene:new()
   self.items = {
      "Jogar",
      "Configurações",
      "Sobre",
      "Sair",
   }
   self.line = 1
   self.titleFont = assets.fonts.dpcomic(self.fontHeight)
   self.menuBackground = {0, 255, 255, 64}
   self.menuBorder = {0, 255, 255, 100}
   self.selected = {179, 211, 173, 200}
end

function MenuScene:update(dt)
end

function MenuScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local fontHeight = assets.config.fonts.titleHeight * settings:screenScaleFactor()
   local menuWidth = love.graphics.getWidth() * 0.4
   local menuItemHeight = fontHeight * 2
   local menuHeight = menuItemHeight * #self.items
   local x = love.graphics.getWidth() / 2 - menuWidth / 2
   local y = love.graphics.getHeight() / 2 - menuHeight / 2

   for i, option in pairs(self.items) do
      if i == self.line then
         love.graphics.setColor(unpack(self.selected))
      else
         love.graphics.setColor(unpack(self.menuBackground))
      end

      love.graphics.rectangle('fill', x, y + (i - 1) * menuItemHeight,
                           menuWidth, menuItemHeight,
                           menuWidth / 10, menuWidth / 10)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.printf(option, x,
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

function MenuScene:itemSelected(item)
   if item == 1 then
      sceneManager:setCurrent("intro")
   elseif item == 2 then
      sceneManager:setCurrent("settings")
   elseif item == 3 then
   elseif item == 4 then
      love.event.quit(0)
   end
end

function MenuScene:keyPressed(key, scancode,  isRepeat)
   if key=="up" and not isRepeat then
      self.line = (self.line - 2) % #self.items + 1
   elseif key=="down" and not isRepeat then
      self.line = self.line % #self.items + 1
   elseif key=="return" and not isRepeat then
      self:itemSelected(self.line)
   end
end

return MenuScene
