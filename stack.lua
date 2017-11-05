local Object = require "libs/classic/classic"

Stack = Object:extend()

function Stack:new()
   self.elements = {}
end

function Stack:push(item)
   table.insert(self.elements, item)
end

function Stack:pop()
   return table.remove(self.elements, #self.elements)
end

function Stack:peek()
   return self.elements[#self.elements]
end

function Stack:size()
   return #self.elements
end

function Stack:clear()
   self.elements = {}
end

function Stack:print()
   for i=#self.elements,1,-1 do
      print(self.elements[i])
   end
end

return Stack
