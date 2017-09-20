require "entitymanager"
require "stringhelper"

local Map = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local Scene = require "scene"
local SampleChar = require "samplechar"

local currentScene = nil
local debugMode = true

function love.load()
   love.window.setMode(800, 600)

   local map = Map("assets/maps/green_valley.lua")
   currentScene = Scene(Camera(800, 600), map)

   for k, object in pairs(map.objects) do
      if string.starts(object.name, "Player") then
         -- TODO: Get hero name. Format: "Player-name"
         manager:add(SampleChar(object.x, object.y, 96))
      end
      if string.starts(object.name, "CPU") then
         -- TODO: Get CPU controlled character name. Format: "CPU-name"
         manager:add(SampleChar(object.x, object.y, 96))
      end
   end
end

function love.update(dt)
   currentScene:update(dt)
end

function love.draw()
   currentScene:draw()
   if debugMode then
      drawDebugInfo()
   end
end

function love.keypressed(key, scancode, isRepeat)
   if key=="l" and not isRepeat then
      currentScene.camera:zoomOut()
   elseif key=="k" and not isRepeat then
      currentScene.camera:zoomIn()
   elseif key=="space" and not isRepeat then
      currentScene.camera:panTo(2, currentScene.map.width * currentScene.map.tilewidth / 2 - currentScene.camera.width / 2,
                                   currentScene.map.height * currentScene.map.tileheight / 2 - currentScene.camera.height / 2)
   end
end

function drawDebugInfo()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
