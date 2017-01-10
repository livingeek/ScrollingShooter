--TODO: Allow for multiple key inputs
--TODO: Allow for diagonal movement
--TODO: Lock keyboard so I don't change spaces
--TODO: Add explosions
--TODO: background Image (maybe scrolling?)
--DONE: Display score on death.
--DONE: stop enemy spawn on death.
--DONE: stop firing after death.
--TODO: Fix spawning of enemies off screen
--TODO: Store high score.  (Bonus store through multiple games)
--TODO: Allow enemies to shoot background
--DONE: Add sound effects
--DONE: Improve sound effects (allow playing over each other)
require 'slam'


-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

isAlive = true
score = 0

debug = true
player = { x = 200, y = 710, speed = 300, img = nil}
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
--Enemy variables
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Image Storage
bulletImg = nil
enemyImg = nil
explosionSound = nil
firingSound = nil

--Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies

function love.load(arg)
  player.img = love.graphics.newImage('assets/plane.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
  enemyImg = love.graphics.newImage('assets/enemy.png')
  explosionSound = love.audio.newSource('assets/audio/explosion.wav', 'static')
  firingSound = love.audio.newSource('assets/audio/shoot.wav', 'static')


  --we now have an asset ready to be used inside love
end

function love.update(dt)
  if not isAlive and love.keyboard.isDown('r') then
    -- remove all our bullets and enemies from screen
    bullets = {}
    enemies = {}

    -- reset timers
    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    -- move player back to default position
    player.x = 50
    player.y = 710

    -- reset our game state
    score = 0
    isAlive = true
  end

  -- I always start with an easy way to exit the game
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left','a') then
    if player.x > 0 then
      player.x = player.x - (player.speed*dt)
    end
  elseif love.keyboard.isDown('right','d') then
    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed*dt)
    end
  elseif love.keyboard.isDown('up','w') then
    if player.y > 580 then
      player.y = player.y - (player.speed*dt)
    end
  elseif love.keyboard.isDown('down','s') then
    if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
      player.y = player.y + (player.speed*dt)
    end
  end
  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end
  if love.keyboard.isDown(' ', 'space', 'rctrl', 'lctrl', 'ctrl') and canShoot and isAlive then
    -- Create some bullets
    newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
    table.insert(bullets, newBullet)
    local firing = firingSound:play()
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  --update the positions of bullets
  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)

    if bullet.y < 0 then -- remove bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end
  --Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 and isAlive then
    createEnemyTimer = createEnemyTimerMax

    --Create an enemy
    randomNumber = math.random(10, love.graphics.getWidth() - 10)
    newEnemy = { x = randomNumber, y = -10, img = enemyImg }
    table.insert(enemies, newEnemy)
  end
  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (200 * dt)

    if enemy.y > 850 then -- removes when they pass off the screen
      table.remove(enemies, i)
    end
  end
  -- run our collision detection
  -- Since there will be fewer enemes on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        --TODO: this would be a good place to replace image, and add attribute for removal after x time.
        table.remove(enemies, i)
        local explosion = explosionSound:play()
        score = score + 1
      end
    end

    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) then
      table.remove(enemies, i)
      local explosion = explosionSound:play()
      isAlive = false
    end
  end
end

function love.draw(dt)
  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("SCORE: " .. tostring(score), 400, 10)
  else
    love.graphics.print("Your Score: " .. tostring(score), love.graphics:getWidth()/2-40, love.graphics:getHeight()/2-25)
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
end
