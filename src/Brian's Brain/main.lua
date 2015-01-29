local map
local temp_map
local cell_color = {127, 210, 255}
local bg_color = {0, 0, 0}
local SIZE = 75		--Size of the array of values
local RECT_SIZE = 10		--Size of rectangles in pixels
local FPS = 60
local SIMULATION_SPEED = 10
local frames = 0
local paused = false
local prev_frame_x
local prev_frame_y
local canvas

function love.load()
	min_dt = 1/FPS
	next_time = love.timer.getTime()

	--Initialize random map
	math.randomseed(os.time())

	cell_color = {math.random() * 255, math.random() * 255, math.random() * 255}

	map = {}
	temp_map = {}
	for i = 0, SIZE do
		map[i] = {}
		temp_map[i] = {}
		for j = 0, SIZE do
			map[i][j] = 0
			temp_map[i][j] = 0
		end
	end

	prev_frame_x = 0
	prev_frame_y = 0

	love.window.setTitle("Game Of Life")
	love.window.setMode(RECT_SIZE * SIZE, RECT_SIZE * SIZE, {resizable = false, vsync = false, fullscreen = false})
	love.graphics.setBackgroundColor(bg_color)
	love.graphics.setColor(cell_color)

	canvas = love.graphics.newCanvas()
	blurred_canvas = love.graphics.newCanvas()
	blur = love.graphics.newShader('blur.frag')
	blur:send('radius', 3)
	blur:send('width', love.window.getWidth())
	blur:send('height', love.window.getHeight())
	love.graphics.setBlendMode('premultiplied')

	love.mouse.setVisible(false)
end

function love.update(dt)
	frames = frames + 1
	next_time = next_time + min_dt

	if not paused and frames % SIMULATION_SPEED == 0 then
		for i = 0, SIZE do
			for j = 0, SIZE do
				if map[i][j] == 2 then
					temp_map[i][j] = 1
				elseif map[i][j] == 1 then
					temp_map[i][j] = 0
				else
					if  count_alive(i, j) == 2 then
						temp_map[i][j] = 2
					end
	 			end
			end
		end

		--Transfer temp_map to map
		for i = 0, SIZE do
			for j = 0, SIZE do
				map[i][j] = temp_map[i][j]
			end
		end
	end

	if love.mouse.isDown ('l') then
		map[math.floor(love.mouse.getX() / RECT_SIZE)][math.floor(love.mouse.getY() / RECT_SIZE)] = 2
		temp_map[math.floor(love.mouse.getX() / RECT_SIZE)][math.floor(love.mouse.getY() / RECT_SIZE)] = 2
	elseif love.mouse.isDown ('r') then
		map[math.floor(love.mouse.getX() / RECT_SIZE)][math.floor(love.mouse.getY() / RECT_SIZE)] = 0
		temp_map[math.floor(love.mouse.getX() / RECT_SIZE)][math.floor(love.mouse.getY() / RECT_SIZE)] = 0
	end

	prev_frame_x = math.floor(love.mouse.getX() / RECT_SIZE)
	prev_frame_y = math.floor(love.mouse.getY() / RECT_SIZE)
end

function count_alive(i, j)
	local count = 0
	if i < SIZE and map[i + 1][j] == 2 then
		count = count + 1
	end
	if i > 0 and map[i - 1][j] == 2 then
		count = count + 1
	end
	if j < SIZE and map[i][j + 1] == 2 then
		count = count + 1
	end
	if j > 0 and map[i][j - 1] == 2 then
		count = count + 1
	end
	if i < SIZE and j < SIZE and map[i + 1][j + 1] == 2 then
		count = count + 1
	end
	if i < SIZE and j > 0 and map[i + 1][j - 1] == 2 then
		count = count + 1
	end
	if i > 0 and j < SIZE and map[i - 1][j + 1] == 2 then
		count = count + 1
	end
	if i > 0 and j > 0 and map[i - 1][j - 1] == 2 then
		count = count + 1
	end

	return count
end

function generate_random_map ()
	for i = 0, SIZE do
		for j = 0, SIZE do
			if math.random() > 0.85 then
				map[i][j] = 2
			end
		end
	end
end

function love.draw()
	canvas:clear()
	blurred_canvas:clear()
	love.graphics.setCanvas(canvas)
	for i = 0, SIZE do
		for j = 0, SIZE do
			if map[i][j] == 2 then
				love.graphics.rectangle("fill", i * RECT_SIZE, j * RECT_SIZE, RECT_SIZE, RECT_SIZE)
			end
		end
	end

	love.graphics.rectangle("line", prev_frame_x * RECT_SIZE, prev_frame_y * RECT_SIZE, RECT_SIZE, RECT_SIZE)

	love.graphics.setCanvas(blurred_canvas)
	love.graphics.setShader(blur)
	love.graphics.draw(canvas, 0, 0)
	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0)	
	love.graphics.draw(blurred_canvas, 0, 0)

	--Delay if we finished drawing this frame faster than desired FPS
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "r" then
		generate_random_map()
	elseif key == 'c' then
		for i = 0, SIZE do
			for j = 0, SIZE do
				map[i][j] = 0
				temp_map[i][j] = 0
			end
		end
	elseif key == '.' then
		if SIMULATION_SPEED > 1 then
			SIMULATION_SPEED  = SIMULATION_SPEED - 1
		end
	elseif key == ',' then
		SIMULATION_SPEED = SIMULATION_SPEED + 1
	elseif key == ' ' then
		paused = not paused
	end
end