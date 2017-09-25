require "entitymanager"
require "stringhelper"
require "scenemanager"

local Map = require "libs/Simple-Tiled-Implementation/sti"
local Camera = require "camera"
local Scene = require "scene"
local EndScene = require "endscene"
local MenuScene = require "menuscene"
local DialogScene = require 'dialogscene'

local debugMode = true
local width = 1280
local height = 720

function love.load()
   love.window.setMode(width, height)

   local map = Map("assets/maps/green_valley.lua")
   sceneManager:add("menu", MenuScene())
   sceneManager:add("intro", DialogScene('intro', map))
   sceneManager:add("battle", Scene(Camera(width, height), map))
   sceneManager:add("PlayerWon", EndScene("Jogador"))
   sceneManager:add("EnemyWon", EndScene("Inimigo"))
   sceneManager:setCurrent("menu")
end

function love.update(dt)
   if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
   end
   sceneManager:update(dt)
end

function love.draw()
   sceneManager:draw()
   if debugMode then
      drawDebugInfo()
   end
end

function love.keypressed(key, scancode, isRepeat)
   sceneManager:keyPressed(key, scancode, isRepeat)
end

function drawDebugInfo()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
