require "assets"
require "soundmanager"

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
end

function MenuScene:init()
   self.fontHeight = assets.config.fonts.menuItemHeight * settings:screenScaleFactor()
   self.menuFont = assets.fonts.pressstartregular(self.fontHeight)
   self.menuWidth = love.graphics.getWidth() * 0.4
   self.menuItemHeight = self.fontHeight * 2
   self.menuHeight = self.menuItemHeight * #self.items
   self.x = love.graphics.getWidth() / 2 - self.menuWidth / 2
   self.y = love.graphics.getHeight() / 2 - self.menuHeight / 2
   self.background = love.graphics.newImage('assets/images/bg_menu.png')
   self.buttonOnImage = love.graphics.newImage('assets/images/button_on.png')
   self.buttonOffImage = love.graphics.newImage('assets/images/button_off.png')
   self.buttonScaleX = self.menuWidth / self.buttonOnImage:getWidth()
   self.buttonScaleY = self.menuItemHeight / self.buttonOnImage:getHeight()
end

function MenuScene:update(dt)
end

function MenuScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local bgScaleX = love.graphics.getWidth() / self.background:getWidth()
   local bgScaleY = love.graphics.getHeight() / self.background:getHeight()
   love.graphics.draw(self.background, 0, 0, 0, bgScaleX, bgScaleY)

   for i, option in pairs(self.items) do
      love.graphics.setColor(r, g, b, a)
      local button = nil
      if i == self.line then
         button = self.buttonOnImage
      else
         button = self.buttonOffImage
      end

      love.graphics.draw(button, self.x, self.y + (i - 1) * self.menuItemHeight, 0, self.buttonScaleX, self.buttonScaleY)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.setFont(self.menuFont)
      love.graphics.printf(option, self.x,
                        self.y + (i - 1) * self.menuItemHeight + self.menuItemHeight / 2 - self.fontHeight / 2,
                        self.menuWidth, 'center')

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
      sceneManager:setCurrent("credits")
   elseif item == 4 then
      love.event.quit(0)
   end
end

function MenuScene:keyPressed(key, scancode,  isRepeat)
   if key=="up" and not isRepeat then
      self.line = (self.line - 2) % #self.items + 1
      soundManager:stop("menuselect")
      soundManager:play("menuselect")
   elseif key=="down" and not isRepeat then
      self.line = self.line % #self.items + 1
      soundManager:stop("menuselect")
      soundManager:play("menuselect")
   elseif key=="return" and not isRepeat then
      self:itemSelected(self.line)
      soundManager:play("accept")
   end
end

return MenuScene
