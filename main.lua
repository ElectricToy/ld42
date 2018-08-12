-- Jeff Wofford's LD42 entry


-- SETUP
sprite_size( 8 )

-- UTILITY

function sheet_pixels_to_sprite( x, y )
	return ( y // 8 ) * (256//8) + ( x // 8 )
end

local CELL_EMPTY = sheet_pixels_to_sprite( 136, 88 )		-- 369

-- CLASSES

function createRoomCell()
	return { empty = false, sprite = 0 }
end

function ndx( wid, x, y )
	return ( y - 1 ) * wid + x
end

function createRoom( wid, hgt )
	function createRoomCells( wid, hgt )
		local cells = {}
		for row = 1, hgt do
			for col = 1, wid do
				cells[ ndx( wid, col, row ) ] = createRoomCell()
			end
		end

		return cells
	end

	local room = {
		wid = wid,
		hgt = hgt,
		cells = createRoomCells( wid, hgt )
	}

	assert( room and room.cells )

	return room
end

function roomCell( room, x, y )
	assert( room and room.cells )
	local index = ndx( room.wid, x, y )
	return room.cells[ index ] -- TODO
end

function roomBeautify( room )
	function fixupCellSprites( room )
		-- TODO
	end

	function addCellShadows( room )
		-- TODO
	end

	fixupCellSprites( room )
	addCellShadows( room )
	
end

function roomPaintEmptyRect( room, x, y, wid, hgt )
	for j = 1, hgt do
		for i = 1, wid do
			local cell = roomCell( room, x+i, y+j )
			cell.empty = true
			cell.sprite = CELL_EMPTY
		end
	end

	roomBeautify( room )
end

function createWorld( wid, hgt, startingRoomWid, startingRoomHgt )
	local world = {
		cell_width = wid,
		cell_height = hgt,
		focusX = wid//2*8,
		focusY = hgt//2*8,
		room = createRoom( wid, hgt )
	}

	assert( world and world.room and world.room.cells )

	roomPaintEmptyRect( 
		world.room, 
		wid // 2 - startingRoomWid//2, 
		hgt // 2 - startingRoomHgt//2, 
		startingRoomWid, 
		startingRoomHgt )

	return world
end

local world = createWorld( 32, 32, 8, 6 )

-- UPDATE

function update()
end

-- DRAWRING

function drawCell( cell, tileX, tileY )
	spr( cell.sprite, tileX*8, tileY*8 )
end

function drawRoom( room, tileOffsetX, tileOffsetY )
	for y = 1, room.hgt do
		for x = 1, room.wid do
			local cell = roomCell( room, x, y )
			if cell.sprite ~= 0 then
				drawCell( cell, x-1, y-1 )
			end
		end
	end
end

function moveCameraForWorldFocusPoint( focusX, focusY )
	camera( world.focusX - screen_wid()//2, world.focusY - screen_hgt()//2 )
end

function drawWorld( world )

	moveCameraForWorldFocusPoint( world.focusX, world.focusY )

	function drawLowerEnvironment()
		function drawFloor()
			local floorSprite = sheet_pixels_to_sprite( 128, 104 )
			for row = 1, world.cell_height//4 do
				local y = (row-1) * 8*4
				for col = 1, world.cell_width//4 do
					spr( floorSprite, (col-1) * 8*4, y, 4, 4 )
				end
			end
		end

		drawFloor()
		drawRoom( world.room, 0, 0 )

	end

	function drawCharacters()
	end

	drawLowerEnvironment()
	drawCharacters()

	camera( 0, 0 )
end

function drawUI()

	function drawBaseUI()
		spr( 0, 0, 0, 240//8, 7 )
	end

	function drawUpperUI()
		spr( 224, 100, 0 )
		spr( 225, 11, 40, 5, 2 )
	end

	drawBaseUI()
	drawUpperUI()

end

function draw()
	cls( 0xff000000 )

	drawWorld( world )

	drawUI()
end
