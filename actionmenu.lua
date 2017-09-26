local Object = require "libs/classic/classic"

ActionMenu = Object:extend()

function ActionMenu:new(character, width, height, tileWidth, tileHeight)
   self.tileWidth = tileWidth
   self.tileHeight = tileHeight
   self.width = width * tileWidth
   self.height = height * tileHeight

   self.x = character.x
   self.y = character.y - self.height

   self.line = 1

   self.character = character
end

function ActionMenu:move(x, y)
   self.x = x
   self.y = y - self.height
end

function ActionMenu:select(line)
   self.line = line
end

function ActionMenu:menuDown()
   local line = self.line
   line = line % 4 + 1
   if (line == 1 and self.character.moved) or (line == 2 and self.character.attacked) then
      line = line % 4 + 1
   end
   self.line = line
end

function ActionMenu:menuUp()
   local line = self.line
   line = (line - 2) % 4 + 1
   if (line == 1 and self.character.moved) or (line == 2 and self.character.attacked) then
      line = (line - 2) % 4 + 1
   end
   self.line = line
end

function ActionMenu:drawLine(line, text, ox, oy)
   local r, g, b, a = love.graphics.getColor()

   love.graphics.setColor(173, 173, 173, 80)

   if line == self.line then
      love.graphics.setColor(179, 211, 173, 200)
   elseif (line == 1 and self.character.moved) or (line == 2 and self.character.attacked) then
      love.graphics.setColor(75, 75, 75, 200)
   end

   love.graphics.rectangle('fill', self.x - ox, self.y + (line - 1) * self.tileHeight  - oy,
                           self.width, self.tileHeight,
                           self.width / 8, self.height / 8)

   love.graphics.rectangle('line', self.x - ox, self.y + (line - 1) * self.tileHeight - oy,
                           self.width, self.tileHeight,
                           self.width / 8, self.height / 8)

   love.graphics.setColor(0, 0, 0, 255)
   if (line == 1 and self.character.moved) or (line == 2 and self.character.attacked) then
      love.graphics.setColor(75, 75, 75, 200)
   end
   if self.menuItemFont == nil then
      self.menuItemFont = assets.fonts.dpcomic(assets.config.fonts.actionMenuItemHeight *
                                               settings:screenScaleFactor())

   end
   local oldFont = love.graphics.getFont()

   love.graphics.setFont(self.menuItemFont)
   love.graphics.printf(text, self.x - ox,
                        self.y + (line - 1) * self.tileHeight + self.tileHeight / 2 - self.menuItemFont:getHeight() / 2 - oy,
                        self.width, 'center')

   love.graphics.setFont(oldFont)
   love.graphics.setColor(r, g, b, a)
end

function ActionMenu:draw(ox, oy)
   if not self.character.selected or self.character:acting() then
      return
   end

   local r, g, b, a = love.graphics.getColor()
   -- menu window --
   love.graphics.setColor(173, 173, 173, 80)
   love.graphics.rectangle('fill', self.x - ox, self.y - oy,
                           self.width, self.height,
                           self.width / 8, self.height / 8)
   love.graphics.rectangle('line', self.x - ox, self.y - oy,
                           self.width, self.height,
                           self.width / 8, self.height / 8)

   -- menu items --
   self:drawLine(1, "Mover", ox, oy)
   self:drawLine(2, "Atacar", ox, oy)
   self:drawLine(3, "Terminar", ox, oy)
   self:drawLine(4, "Cancelar", ox, oy)

   love.graphics.setColor(r, g, b, a)
end

return ActionMenu
