local Map = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local Scene = require "scene"
local SampleChar = require "samplechar"
local EntityManager = require "entitymanager"

local scene

manager = EntityManager()

function love.load()
   love.window.setMode(800, 600)

   local map = Map("assets/maps/green_valley.lua")
   local camera = Camera:new()
   camera:setSize(800, 600)

   scene = Scene:new()
   scene:setCamera(camera)
   scene:setMap(map)

   local player
   for k, object in pairs(map.objects) do
      if object.name == "Player" then
         player = object
         break
      end
   end

   manager:add(SampleChar(player.x, player.y, 96))
   manager:add(SampleChar(player.x + 64, player.y, 96))
   manager:add(SampleChar(player.x, player.y + 64, 96))
   manager:add(SampleChar(player.x + 64, player.y + 64, 96))

   local enemy1 = SampleChar(player.x + 96, player.y + 64, 96)
   local enemy2 = SampleChar(player.x + 96, player.y + 96, 96)
   enemy1.type = "Enemy"
   enemy2.type = "Enemy"

   manager:add(enemy1)
   manager:add(enemy2)

   manager:remove(enemy2)

   print("Enemies:")
   for entity in pairs(manager:getByType("Enemy")) do
      print(entity, entity.type)
   end

   print("All entities:")
   for entity in pairs(manager:getEntities()) do
      print(entity, entity.type)
   end
end

function love.update(dt)
   scene:update(dt)
   manager:update(dt)
end

function love.draw()
   scene:draw()
   manager:draw(-scene.camera.x, -scene.camera.y)
end

function love.keypressed(key, scancode, isRepeat)
   if key=="l" and not isRepeat then
      scene.camera:zoomOut()
   elseif key=="k" and not isRepeat then
      scene.camera:zoomIn()
   elseif key=="space" and not isRepeat then
      scene.camera:panTo(2, 1200, 1200)
   end
end
