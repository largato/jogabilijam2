local Object = require "libs/classic/classic"

EntityManager = Object:extend()

function EntityManager:new()
   self.entities = {}
   self.entitiesByType = {}
end

function EntityManager:add(entity)
   self.entities[entity] = true

   if self.entitiesByType[entity.type] == nil then
      self.entitiesByType[entity.type] = {}
   end

   table.insert(self.entitiesByType[entity.type], entity)
end

function EntityManager:remove(entity)
   if self.entities[entity] == nil then
      return
   end

   self.entities[entity] = nil
   for i, v in ipairs(self.entitiesByType[entity.type]) do
      if v == entity then
         table.remove(self.entitiesByType[entity.type], i)
         break
      end
   end
end

function EntityManager:getByType(type)
   return self.entitiesByType[type]
end

function EntityManager:getEntities()
   return self.entities
end

function EntityManager:update(dt)
   for entity in pairs(self.entities) do
      entity:update(dt)
   end
end

function EntityManager:draw(ox, oy)
   for entity in pairs(self.entities) do
      entity:draw(ox, oy)
   end
end

manager = EntityManager()
