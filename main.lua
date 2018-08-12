-- Jeff Wofford's LD42 entry


-- SETUP
sprite_size( 8 )

local isTouchDown = false
local mousex = -1
local mousey = -1

-- UTILITY

function clamp( x, minimum, maximum )
	return math.min( maximum, math.max( x, minimum ))
end

function round( x, divisor )
	return x // divisor * divisor
end

function quantize( x )
	return round( x + 4, 8 )
end

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
		x = 0,
		y = 0,
		wid = wid,
		hgt = hgt,
		cells = createRoomCells( wid, hgt )
	}

	assert( room and room.cells )

	return room
end

function roomActualSize( room )
	local maxRow = 0
	local maxCol = 0
	for row = 1, room.hgt do
		for col = 1, room.wid do
			local cell = roomCell( room, col, row )
			if cell.empty then
				maxRow = math.max( maxRow, row )
				maxCol = math.max( maxCol, col )
			end
		end
	end

	return maxCol, maxRow
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
		if y + j - 1 >= room.hgt then break end

		for i = 1, wid do
			if x + i - 1 >= room.wid then break end 
		
			local cell = roomCell( room, x+i-1, y+j-1 )
			cell.empty = true
			cell.sprite = CELL_EMPTY
		end
	end

	roomBeautify( room )
end

function mergeRooms( into, with )
	assert( into )
	assert( with )

	local cellOffsetX = with.x // 8
	local cellOffsetY = with.y // 8

	for j = 1, with.hgt do
		for i = 1, with.wid do

			local intoCell = roomCell( into, i + cellOffsetX, j + cellOffsetY )
			local withCell = roomCell( with, i, j )

			if intoCell and withCell then
				intoCell.empty = intoCell.empty or withCell.empty
				intoCell.sprite = intoCell.empty and CELL_EMPTY or 0
			end
		end
	end

	roomBeautify( into )
end

function createPlayerPlaceableRoom()
	local room = createRoom( 5, 5 )
	
	-- paint a random rect in the room.
	local desiredArea = math.random( 1, 15 )
	local wid = math.random( 1, math.min( 5, desiredArea ))
	local hgt = clamp( desiredArea // wid, 1, 5 )
	local x = 1 -- math.random( 1, 5 )
	local y = 1 -- math.random( 1, 5 )
	roomPaintEmptyRect( room, x, y, wid, hgt );

	-- TODO more interesting randomization

	-- TODO positioning
	local roomWid, roomHgt = roomActualSize( room )
	room.x = -4 + (5-roomWid)*8/2
	room.y = -4 + (5-roomHgt)*8/2


	return room
end

function createWorld( wid, hgt, startingRoomWid, startingRoomHgt )
	local world = {
		cell_width = wid,
		cell_height = hgt,
		focusX = wid//2*8,
		focusY = hgt//2*8,
		room = createRoom( wid, hgt ),
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

function worldViewOffset( world )
	return world.focusX - screen_wid()//2, world.focusY - screen_hgt()//2
end

function worldQuantizeObjectFromUI( world, object )
	local worldOffsetX, worldOffsetY = worldViewOffset( world )
	
	object.x = quantize( object.x + worldOffsetX )
	object.y = quantize( object.y + worldOffsetY )
end

function worldAddRoom( world, newRoom )
	mergeRooms( world.room, newRoom )
end

local world = createWorld( 32, 32, 8, 6 )
local placeableRoom = createPlayerPlaceableRoom()


local worldAtDragStartX = nil
local worldAtDragStartY = nil
local worldDragStartX = nil
local worldDragStartY = nil
function worldBeginTouch( x, y )
	worldDragStartX, worldDragStartY = x, y
	worldAtDragStartX, worldAtDragStartY = world.focusX, world.focusY
end 

function worldMoveTouch( x, y )
		local worldwid = world.cell_width*8
		local worldhgt = world.cell_height*8

	local excessX = ( worldwid - screen_wid() ) // 2
	local excessY = ( worldhgt - screen_hgt() ) // 2

	if excessX > 0 then
		world.focusX = worldAtDragStartX - ( x - worldDragStartX )
		world.focusX = clamp( world.focusX, worldwid//2 - excessX, worldwid//2 + excessX )
	end


	if excessY > 0 then
		world.focusY = worldAtDragStartY - ( y - worldDragStartY )
		world.focusY = clamp( world.focusY, worldhgt//2 - excessY, worldhgt//2 + excessY )
	end

end 

function worldEndTouch( x, y )
	worldDragStartX = nil
	worldDragStartY = nil
end 

-- UPDATE

function update()
	updateInput()

	-- TODO
end

-- DRAWRING

function drawCell( cell, x, y )
	spr( cell.sprite, x, y )
end

function drawRoom( room )
	for y = 1, room.hgt do
		for x = 1, room.wid do
			local cell = roomCell( room, x, y )
			if cell.sprite ~= 0 then
				drawCell( cell, x*8 + room.x, y*8 + room.y )
			end
		end
	end
end

function moveCameraForWorldFocusPoint( world )
	local worldOffsetX, worldOffsetY = worldViewOffset( world )

	camera( worldOffsetX, worldOffsetY )
end

function drawWorld( world )

	moveCameraForWorldFocusPoint( world )

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
		drawRoom( world.room )

	end

	function drawCharacters()
		-- TODO
	end

	drawLowerEnvironment()
	drawCharacters()

	camera( 0, 0 )
end

local debugMessages = {}

function trace( message )
	table.insert( debugMessages, message )
end

function drawDebug()
	-- print( tostring( mousex ) .. ',' .. tostring( mousey ) .. '::' .. tostring( placeableRoom ))
	print( tostring( world.focusX ) .. ',' .. tostring( world.focusY ))


	for i,message in ipairs( debugMessages ) do
		print( message )
	end

	while #debugMessages > 10 do
		table.remove( debugMessages, 1 )
	end

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

	drawRoom( placeableRoom )

	drawUpperUI()

	drawDebug()
end

function draw()
	cls( 0xff000000 )

	drawWorld( world )

	drawUI()
end


local roomAtDragStartX = nil
local roomAtDragStartY = nil
local dragStartX = nil
local dragStartY = nil
function beginTouchPlacementRoom( x, y )
	roomAtDragStartX = placeableRoom.x
	roomAtDragStartY = placeableRoom.y
	dragStartX = x
	dragStartY = y
end

function movePlacementRoom( x, y )
	placeableRoom.x = roomAtDragStartX - ( dragStartX - x )
	placeableRoom.y = roomAtDragStartY - ( dragStartY - y )
end

function dropPlacementRoom( x, y )

	if x <= 60 and y <= 60 then
		-- abort
		placeableRoom.x = roomAtDragStartX
		placeableRoom.y = roomAtDragStartY
	else

		worldQuantizeObjectFromUI( world, placeableRoom )

		worldAddRoom( world, placeableRoom )

		placeableRoom = createPlayerPlaceableRoom()
	end

	roomAtDragStartX = nil
	roomAtDragStartY = nil
	dragStartX = nil
	dragStartY = nil
end

function beginTouch( x, y )
	-- trace( 'begin touch' )
	isTouchDown = true

	-- What is it touching?

	-- -- room area?
	if x <= 44 and y <= 44 then
		beginTouchPlacementRoom( x, y )
	else
		worldBeginTouch( x, y )
	end
end

function moveTouch( x, y )
	-- trace( 'move touch' )
	isTouchDown = true
	
	if dragStartX then
		movePlacementRoom( x, y )
	else
		worldMoveTouch( x, y )
	end
end

function releaseTouch( x, y )
	-- trace( 'release touch' )
	
	if dragStartX then
		dropPlacementRoom( x, y )
	else
		worldEndTouch( x, y )
	end
	
	isTouchDown = false
end

function updateInput()
	mousex = touchupx()
	mousey = touchupy()
	if mousex >= 0 then
		releaseTouch( mousex, mousey )
	else
		mousex = touchx()
		mousey = touchy()
		if mousex >= 0 then

			if isTouchDown then
				moveTouch( mousex, mousey )
			else
				beginTouch( mousex, mousey )
			end
		end
	end
end