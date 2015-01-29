local map
local ant_x
local ant_y
local dir
local cell_color = {50, 100, 255}
local ant_color = {255, 20, 78}
local bg_color = {0, 0, 0}
local SIZE = 70		--Size of the array of true/false values. white = false, black = true
local RECT_SIZE = 10		--Size of rectangles in pixels
local FPS = 90
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

	map = {}
	for i = 0, SIZE do
		map[i] = {}
		for j = 0, SIZE do
			map[i][j] = false
		end
	end

	ant_x = math.floor(SIZE / 2)
	ant_y = math.floor(SIZE / 2)
	-- 0 = up, 1 = right, 2 = down, 3 = left
	dir = 0

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
	love.graphics.setBlendMode('screen')

	love.mouse.setVisible(false)
end

function love.update(dt)
	frames = frames + 1
	next_time = next_time + min_dt

	if not paused and frames % SIMULATION_SPEED == 0 then
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

		if dir == 0 then
			if ant_y + 1 <= SIZE then
				ant_y = ant_y + 1
			end
		elseif dir == 1 then
			if ant_x + 1 <= SIZE then
				ant_x = ant_x + 1
			end
		elseif dir == 2 then
			if ant_y - 1 >= 0 then
				ant_y = ant_y - 1
			end
		else
			if ant_x - 1 >= 0 then
				ant_x = ant_x - 1
			end
		end
	end

	prev_frame_x = math.floor(love.mouse.getX() / RECT_SIZE)
	prev_frame_y = math.floor(love.mouse.getY() / RECT_SIZE)
end

function love.draw()
	canvas:clear()
	blurred_canvas:clear()
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(cell_color)
	for i = 0, SIZE do
		for j = 0, SIZE do
			if map[i][j] == true then
				love.graphics.rectangle("fill", i * RECT_SIZE, j * RECT_SIZE, RECT_SIZE, RECT_SIZE)
			end
		end
	end

	love.graphics.rectangle("line", prev_frame_x * RECT_SIZE, prev_frame_y * RECT_SIZE, RECT_SIZE, RECT_SIZE)

	love.graphics.setColor(ant_color)
	love.graphics.rectangle('fill', ant_x * RECT_SIZE, ant_y * RECT_SIZE, RECT_SIZE, RECT_SIZE)

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
	elseif key == 'c' then
		for i = 0, SIZE do
			for j = 0, SIZE do
				map[i][j] = false
				temp_map[i][j] = false
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