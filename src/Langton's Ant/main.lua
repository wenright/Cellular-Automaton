local map
local ant_x
local ant_y
local dir
local cell_color = {102, 200, 10}
local ant_color = {255, 255, 255}
local bg_color = {0, 0, 0}
local SIZE = 35				--Size of the array of true/false values. white = false, black = true
local RECT_SIZE = 20		--Size of rectangles in pixels
local FPS = 5
local frames = 0
local paused = false
local canvas

function love.load()
	min_dt = 1/FPS
	next_time = love.timer.getTime()

	math.randomseed(os.time())

	map = {}
	for i = 0, SIZE do
		map[i] = {}
		for j = 0, SIZE do
			map[i][j] = false
		end
	end

	ant_x = math.floor(SIZE / 2)
	ant_y = math.floor(SIZE / 2)
	-- 0 = down, 1 = left, 2 = up, 3 = right
	dir = 0

	love.window.setTitle("Langton's Ant")
	love.window.setMode(RECT_SIZE * SIZE, RECT_SIZE * SIZE, {resizable = false, vsync = false, fullscreen = false})
	love.graphics.setBackgroundColor(bg_color)
	love.graphics.setColor(cell_color)

	canvas = love.graphics.newCanvas()

	vertical_blurred_canvas = love.graphics.newCanvas()
	vertical_blur = love.graphics.newShader('vertical_blur.frag')
	vertical_blur:send('r', 5)
	vertical_blur:send('h', love.window.getHeight())

	horizontal_blurred_canvas = love.graphics.newCanvas()
	horizontal_blur = love.graphics.newShader('horizontal_blur.frag')
	horizontal_blur:send('r', 5)
	horizontal_blur:send('w', love.window.getWidth())

	love.graphics.setBlendMode('screen')
	love.mouse.setVisible(false)
end

function love.update(dt)
	next_time = next_time + min_dt

	if not paused then
		if map[ant_x][ant_y] then
			--Black square
			--turn left 90, flip square
			map[ant_x][ant_y] = false
			dir = (dir - 1) % 4
		else
			--white square
			--turn right 90, flip square
			map[ant_x][ant_y] = true
			dir = (dir + 1) % 4

		end

		if dir == 0 and ant_y + 1 < SIZE then
			ant_y = ant_y + 1
		elseif dir == 1 and ant_x + 1 < SIZE then
			ant_x = ant_x + 1
		elseif dir == 2 and ant_y - 1 >= 0 then
			ant_y = ant_y - 1
		elseif dir == 3 and ant_x - 1 >= 0 then
			ant_x = ant_x - 1
		else
			--Flip ant if it gets stuck against a wall
			dir = (dir - 1) % 4
		end
	end
end

function love.draw()
	canvas:clear()
	vertical_blurred_canvas:clear()
	horizontal_blurred_canvas:clear()
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(cell_color)
	for i = 0, SIZE do
		for j = 0, SIZE do
			if map[i][j] == true and (i ~= ant_x or j ~= ant_y ) then
				love.graphics.rectangle("fill", i * RECT_SIZE, j * RECT_SIZE, RECT_SIZE, RECT_SIZE)
			end
		end
	end

	love.graphics.setColor(ant_color)
	love.graphics.rectangle('fill', ant_x * RECT_SIZE, ant_y * RECT_SIZE, RECT_SIZE, RECT_SIZE)

	love.graphics.setColor(255, 255, 255)

	love.graphics.setCanvas(horizontal_blurred_canvas)
	love.graphics.setShader(horizontal_blur)
	love.graphics.draw(canvas, 0, 0)

	love.graphics.setCanvas(vertical_blurred_canvas)
	love.graphics.setShader(vertical_blur)
	love.graphics.draw(horizontal_blurred_canvas, 0, 0)

	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0)	
	love.graphics.draw(vertical_blurred_canvas, 0, 0)

	--Delay if we finished drawing this frame faster than desired FPS
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == 'c' then
		for i = 0, SIZE do
			for j = 0, SIZE do
				map[i][j] = false
			end
		end
	elseif key == 'r' then
		for i = 0, SIZE do
			for j = 0, SIZE do
				map[i][j] = false
			end
		end

		ant_x = math.floor(SIZE / 2)
		ant_y = math.floor(SIZE / 2)
	elseif key == 'f' then
		dir = (dir - 2) % 4
	elseif key == ',' then
		if FPS > 1.25 then
			FPS = FPS / 2
			min_dt = 1/FPS
		end
	elseif key == '.' then
		FPS = FPS * 2
		min_dt = 1/FPS
	elseif key == ' ' then
		paused = not paused
	end
end