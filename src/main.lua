local map
local temp_map
local cell_color = {127, 210, 255}
local bg_color = {0, 0, 0}
local SIZE = 100		--Size of the array of true/false values
local RECT_SIZE = 5		--Size of rectangles in pixels
local LUCK = 0.55		--The probability of a cell starting out as alive
local FPS = 15

function love.load()
	--Initialize map
	map = {}
	temp_map = {}
	for i = 0, SIZE do
		map[i] = {}
		temp_map[i] = {}
		for j = 0, SIZE do
			map[i][j] = math.random() > LUCK and true or false
		end
	end

	love.window.setTitle("Game Of Life")
	love.window.setMode(RECT_SIZE * SIZE, RECT_SIZE * SIZE, {resizable = false, vsync = true})
	love.graphics.setBackgroundColor(bg_color)
	love.graphics.setColor(cell_color)
end

function love.update(dt)
	for i = 0, SIZE do
		for j = 0, SIZE do
			if map[i][j] == true then
				count = count_alive(i, j)

				--Any live cell with fewer than two live neighbours dies, as if caused by under-population.
				if count < 2 then
					temp_map[i][j] = false

				--Any live cell with more than three live neighbours dies, as if by overcrowding.
				elseif count > 3 then
					temp_map[i][j] = false
				end

				--Any live cell with two or three live neighbours lives on to the next generation.
			else
				--Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
				if  count_alive(i, j) == 3 then
					temp_map[i][j] = true
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

	--Cap framerate so simulation doesn't run super fast
	if dt < 1/FPS*2 then
		love.timer.sleep(1/FPS*2 - dt)
	end
end

function count_alive(i, j)
	count = 0
	if i < SIZE and map[i + 1][j] == true then
		count = count + 1
	end
	if i > 0 and map[i - 1][j] == true then
		count = count + 1
	end
	if j < SIZE and map[i][j + 1] == true then
		count = count + 1
	end
	if j > 0 and map[i][j - 1] == true then
		count = count + 1
	end
	if i < SIZE and j < SIZE and map[i + 1][j + 1] == true then
		count = count + 1
	end
	if i < SIZE and j > 0 and map[i + 1][j - 1] == true then
		count = count + 1
	end
	if i > 0 and j < SIZE and map[i - 1][j + 1] == true then
		count = count + 1
	end
	if i > 0 and j > 0 and map[i - 1][j - 1] == true then
		count = count + 1
	end

	return count
end

function love.draw()
	for i = 0, SIZE do
		for j = 0, SIZE do
			if map[i][j] == true then
				love.graphics.rectangle("fill", i * RECT_SIZE, j * RECT_SIZE, RECT_SIZE, RECT_SIZE)
			end
		end
	end
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "r" then
		love.load()
	end
end