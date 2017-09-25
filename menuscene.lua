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
   self.menuBackground = {0, 255, 255, 64}
   self.menuBorder = {0, 255, 255, 100}
   self.selected = {179, 211, 173, 200}
end

function MenuScene:init()
   self.fontHeight = assets.config.fonts.menuItemHeight * settings:screenScaleFactor()
   self.menuFont = assets.fonts.pressstartregular(self.fontHeight * settings:screenScaleFactor())
   self.fontHeight = assets.config.fonts.menuItemHeight * settings:screenScaleFactor()
   self.menuWidth = love.graphics.getWidth() * 0.4
   self.menuItemHeight = self.fontHeight * 2
   self.menuHeight = self.menuItemHeight * #self.items
   self.x = love.graphics.getWidth() / 2 - self.menuWidth / 2
   self.y = love.graphics.getHeight() / 2 - self.menuHeight / 2
end

function MenuScene:update(dt)
end

function MenuScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   for i, option in pairs(self.items) do
      if i == self.line then
         love.graphics.setColor(unpack(self.selected))
      else
         love.graphics.setColor(unpack(self.menuBackground))
      end

      love.graphics.rectangle('fill', self.x, self.y + (i - 1) * self.menuItemHeight,
                           self.menuWidth, self.menuItemHeight,
                           self.menuWidth / 10, self.menuWidth / 10)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.setFont(self.menuFont)
      love.graphics.printf(option, self.x,
                        self.y + (i - 1) * self.menuItemHeight + self.menuItemHeight / 2 - self.fontHeight / 2,
                        self.menuWidth, 'center')

      love.graphics.setColor(unpack(self.menuBorder))

      love.graphics.rectangle('line', self.x, self.y + (i - 1) * self.menuItemHeight,
                           self.menuWidth, self.menuItemHeight,
                           self.menuWidth / 10, self.menuWidth / 10)
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
