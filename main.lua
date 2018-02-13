-- Has to be initialized before love.load because enemies_controller:spawnEnemy() runs before love.load
love.graphics.setDefaultFilter('nearest', 'nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.imageRed = love.graphics.newImage('enemy_red.png')
enemies_controller.imageGreen = love.graphics.newImage('enemy_green.png')
enemies_controller.imageBlue = love.graphics.newImage('enemy_blue.png')
enemies_controller.imageWhite = love.graphics.newImage('enemy_white.png')
enemies_controller.imageYellow = love.graphics.newImage('enemy_yellow.png')
particle_systems = {}
particle_systems.list = {}
particle_systems.img = love.graphics.newImage('particle.png')
enemies_controller.explode_sound = love.audio.newSource('explosion_enemy.mp3')
score = 0

function particle_systems:spawn(x, y)
	local ps = {}
	ps.x = x
	ps.y = y
	ps.ps = love.graphics.newParticleSystem(particle_systems.img, 32)
	ps.ps:setParticleLifetime(2,4)
	ps.ps:setEmissionRate(5)
	ps.ps:setSizeVariation(1)
	ps.ps:setLinearAcceleration(-20, -20, 20, 20)
	ps.ps:setColors(100, 255, 100, 255, 0, 255, 0, 255)
	table.insert(particle_systems.list, ps)
end


function particle_systems:draw()
	for _, v in pairs(particle_systems.list) do
		love.graphics.draw(v.ps, v.x, v.y)
	end
end


function particle_systems:update(dt)
	for _, v in pairs(particle_systems.list) do
		v.ps:update(dt)
	end
end


function particle_systems:cleanup()

end


function whatIsNext()
	-- Alien fires bullets
	-- Play explosion when alien and player is hit and game over
	-- Scores - each color alien worth n pts.  Show pts.
	-- Add bunkers to hide behind. Alien bullets destroy part of it
	-- Add start with key instructions page
	-- Package and add nice header
end


function checkCollisions(enemies, bullets)
	for i, e in ipairs(enemies) do
		for _, b in pairs(bullets)do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				particle_systems:spawn(e.x, e.y)
				love.audio.play(enemies_controller.explode_sound)
				table.remove(enemies, i)
				-- Increment the point counter.
				score = score + 10
				-- Remove the bullet so it only hits one alien.
				table.remove(player.bullets)
			end
		end
	end
end


function enemies_controller:spawnEnemy(color, x, y)
	enemy = {}
	enemy.x = x + 80
	enemy.y = y
	enemy.width = 60
	enemy.height = 60
	enemy.bullets = {}
	enemy.fire_cooldown = 20
	enemy.speed = .45
	enemy.hz_speed = 1.3
	table.insert(self.enemies, enemy)
	enemy.color = color
end


function enemy:fire()
	if self.fire_cooldown <= 0 then
		self.fire_cooldown = 20
		bullet = {}
		bullet.x = self.x + 41
		bullet.y = self.y
		table.insert(self.bullets, bullet)
	end
end


function love.load()
	-- Load soundtrack and loop
	music = love.audio.newSource('underattack.mp3')
	music:setLooping(true)
	love.audio.play(music)

	game_over = false
	game_win = false
	-- Player stuff
	player = {}
	player.x = 0
	player.y = 560
	player.bullets = {}
	player.fire_cooldown = 20
	player.speed = 5
	player.image = love.graphics.newImage('player.png')
	player.fire_sound = love.audio.newSource('lazer.wav')
	player.explode_sound = love.audio.newSource('explosion_player.mp3')

	player.fire = function()
		if player.fire_cooldown <= 0 then
			love.audio.play(player.fire_sound)
			player.fire_cooldown = 20
			bullet = {}
			bullet.x = player.x + 29.5
			bullet.y = player.y
			table.insert(player.bullets, bullet)
		end
	end

	for i=0, 7 do
		enemies_controller:spawnEnemy(enemies_controller.imageRed, i * 80, 0)
		enemies_controller:spawnEnemy(enemies_controller.imageBlue, i * 80, 60)
		enemies_controller:spawnEnemy(enemies_controller.imageGreen, i * 80, 120)
		enemies_controller:spawnEnemy(enemies_controller.imageWhite, i * 80, 180)
		enemies_controller:spawnEnemy(enemies_controller.imageYellow, i * 80, 240)
	end
end


function love.update(dt)
	-- Only allows the player to fire every 20 ticks
	player.fire_cooldown = player.fire_cooldown - 1

	-- Keyboard controls
	if love.keyboard.isDown('right') then
		-- If player is at pixel 800 the left side of player just went off screen
		-- this makes it look like it rolled back to the left side
		if player.x >= 780 then
			player.x = 0
		else
			player.x = player.x + player.speed
		end
	elseif love.keyboard.isDown('left') then
		-- This rolls player to the right side if they went off left edge
		if player.x <= -60 then
			player.x = 799
		else
			player.x = player.x - player.speed
		end
	end

	if love.keyboard.isDown('space') then
		player.fire()
	end

	if love.keyboard.isDown('q') then
		love.event.quit()
	end

	-- The # checks if the table: enemies_controller.enemies is empty
	if #enemies_controller.enemies == 0 then
		game_win = true
	end

	-- Enemy movement
	for _, e in pairs(enemies_controller.enemies) do
		-- If they hit the bottom edge of screen, game over.
		if e.y >= love.graphics.getHeight() / 1.1 then
			game_over = true
		end

		e.y = e.y + 1 * enemy.speed
	end

	-- Delete bullets from the buffer after they exit off of the screen.
	for i, b in ipairs(player.bullets) do
		if b.y < -10 then
			table.remove(player.bullets)
			-- table.remove(player.bullets, i)
		end
		b.y = b.y - 10
	end

	checkCollisions(enemies_controller.enemies, player.bullets)
end


function love.draw()
	-- Show Score
	love.graphics.setNewFont(10)
	love.graphics.setColor(50, 50, 255)
	love.graphics.print('Score: ' .. score, 720, 5)

	love.graphics.setNewFont(90)
	if game_over then
		love.audio.stop(music)
		love.audio.play(player.explode_sound)
		love.graphics.setColor(255, 50, 50)
		love.graphics.print('You Lost!', 180, 20)
		return
	elseif game_win then
		love.graphics.setColor(99, 255, 32)
		love.graphics.print('You Won!', 190, 20)
	end

	-- Draw the player
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(player.image, player.x, player.y, 0, .5)

	-- Draw enemies
	for _, e in pairs(enemies_controller.enemies) do
		love.graphics.draw(e.color, e.x, e.y, 0, .5)
	end

	-- Draw the bullets
	love.graphics.setColor(255, 255, 255)
	for _,b in pairs(player.bullets) do
		love.graphics.rectangle('fill', b.x, b.y, 2, 10)
	end
end
