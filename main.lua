require "entitymanager"
require "stringhelper"

local Map = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local Scene = require "scene"

local debugMode = true
local width = 1920
local height = 1080

function love.load()
   love.window.setMode(width, height)

   local map = Map("assets/maps/green_valley.lua")
   Scene.currentScene = Scene(Camera(width, height), map)
end

function love.update(dt)
   if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
   end
   Scene.currentScene:update(dt)
end

function love.draw()
   Scene.currentScene:draw()
   if debugMode then
      drawDebugInfo()
   end
end

function drawDebugInfo()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
