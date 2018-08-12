-- Jeff Wofford's LD42 entry


-- SETUP
sprite_size( 8 )

local isTouchDown = false
local mousex = -1
local mousey = -1

-- UTILITY

local debugMessages = {}

function trace( message )
	table.insert( debugMessages, message )
end

function length( x, y )
	return math.sqrt( x * x + y * y )
end


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

local legAnimations = {
	{ idle = { sheet_pixels_to_sprite( 0,  80 ) },
	  run =  { sheet_pixels_to_sprite( 16, 80 ),
			   sheet_pixels_to_sprite( 32, 80 ),
			   sheet_pixels_to_sprite( 48, 80 ), 
			   sheet_pixels_to_sprite( 32, 80 ),}, },

	{ idle = { sheet_pixels_to_sprite( 0,  96 ) },
	  run =  { sheet_pixels_to_sprite( 16, 96 ),
			   sheet_pixels_to_sprite( 32, 96 ),
			   sheet_pixels_to_sprite( 48, 96 ), 
			   sheet_pixels_to_sprite( 32, 96 ), }, },
}

local facePoses = {
	{ sheet_pixels_to_sprite( 64, 80 ),
	  sheet_pixels_to_sprite( 72, 80 ),
	  sheet_pixels_to_sprite( 80, 80 ),
	  sheet_pixels_to_sprite( 88, 80 ), },

	{ sheet_pixels_to_sprite( 64, 96 ),
	  sheet_pixels_to_sprite( 72, 96 ),
	  sheet_pixels_to_sprite( 80, 96 ),
	  sheet_pixels_to_sprite( 88, 96 ), },

}

local pieceConfigurations = {
	{ 	sprite = sheet_pixels_to_sprite( 0, 96 ),
		wid = 2, hgt = 2,
		legAnimIndex = 1,
		faceAnimIndex = 1,
		faceOffsetX = 4,
		faceOffsetY = 4,
		legOffsetX = 0 },
}

local pieceFamilies = {
	{	color = 0xffb9ca00
	},
	{	color = 0xff0090ff
	},
	{	color = 0xffff0072
	},
	{	color = 0xff00ff8a
	},
}

function createPiece( which, family )
	local config = pieceConfigurations[ which ]
	assert( family )
	assert( config )

	local piece = {
		config = config,
		family = family,
		x = 0,
		y = 0,
		velx = 2,
		vely = 0,
		animFrame = 0,
	}

	return piece
end

function pieceBounds( piece )
	-- TODO
end

function pieceIdle( piece )
	return pieceSpeed( piece ) < 0.1
end

function pieceMovingRight( piece )
	return piece.velx > 0
end

function pieceFacePose( piece )
	-- TODO
	return 1
end

function pieceSpeed( piece )
	return length( piece.velx, piece.vely )
end

function updateAI( piece )
	-- TODO

	local power = 0.1

	if btn( 0 ) then impulse( piece, -power, 0 ) end
	if btn( 1 ) then impulse( piece, power, 0 ) end
	if btn( 2 ) then impulse( piece, 0, -power ) end
	if btn( 3 ) then impulse( piece, 0, power ) end
end

function impulse( piece, accx, accy )
	piece.velx = piece.velx + accx
	piece.vely = piece.vely + accy
end

function updateDynamics( piece )
	local drag = 0.05
	impulse( piece, piece.velx * -drag, piece.vely * -drag )

	piece.x = piece.x + piece.velx
	piece.y = piece.y + piece.vely
end

function updateAnim( piece )
	-- TODO
	local speed = pieceSpeed( piece )
	piece.animFrame = piece.animFrame + speed * 0.3
end

function updatePiece( piece )
	updateAI( piece )

	updateDynamics( piece )

	updateAnim( piece )
end

function drawPiece( piece )
	spr( piece.config.sprite, piece.x, piece.y, piece.config.wid, piece.config.hgt, nil, nil, piece.family.color )

	-- face
	local faceSprite = facePoses[ 1 ][ 1 ]
	spr( faceSprite, piece.x + piece.config.faceOffsetX,
					 piece.y + piece.config.faceOffsetY, 
					 nil, nil,
					 false )

	-- legs
	local legAnims = legAnimations[ piece.config.legAnimIndex ]
	local legAnim = pieceIdle( piece ) and legAnims.idle or legAnims.run
	local legSprite = legAnim[ math.floor( piece.animFrame ) % #legAnim + 1 ]

	spr( legSprite, piece.x + piece.config.legOffsetX,
					piece.y + 8,
					2, 1,
					not pieceMovingRight( piece ), false )
end


function createRoomCell()
	return { empty = false, sprite = 0, shadowSprites = {} }
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

local cellSpriteForNeighbors = {	-- NESW
	['XXXX'] = sheet_pixels_to_sprite( 160, 88 ),

	[' XXX'] = sheet_pixels_to_sprite( 160, 96 ),
	['X XX'] = sheet_pixels_to_sprite( 152, 88 ),
	['XX X'] = sheet_pixels_to_sprite( 160, 80 ),
	['XXX '] = sheet_pixels_to_sprite( 168, 88 ),

	['XX  '] = sheet_pixels_to_sprite( 144, 80 ),
	[' XX '] = sheet_pixels_to_sprite( 144, 96 ),
	['  XX'] = sheet_pixels_to_sprite( 128, 96 ),
	['X  X'] = sheet_pixels_to_sprite( 128, 80 ),

	['X X '] = sheet_pixels_to_sprite( 152, 80 ),
	[' X X'] = sheet_pixels_to_sprite( 168, 80 ),

	['X   '] = sheet_pixels_to_sprite( 136, 80 ),
	[' X  '] = sheet_pixels_to_sprite( 144, 88 ),
	['  X '] = sheet_pixels_to_sprite( 136, 96 ),
	['   X'] = sheet_pixels_to_sprite( 128, 88 ),

	['    '] = sheet_pixels_to_sprite( 136, 88 ),
}

function cellNeighborString( room, x, y )
	function charForNeighbor( i, j )
		local neighbor = roomCell( room, x + i, y + j )
		local neighborChar = 'X'
		if neighbor ~= nil then
			neighborChar = neighbor.empty and ' ' or 'X'
		end

		return neighborChar
	end

	local neighborString = ''
	neighborString = neighborString .. charForNeighbor(  0, -1 )
	neighborString = neighborString .. charForNeighbor(  1,  0 )
	neighborString = neighborString .. charForNeighbor(  0,  1 )
	neighborString = neighborString .. charForNeighbor( -1,  0 )
	return neighborString
end

function roomBeautify( room )
	function fixupCellSprites( room )
		function beautifyCell( room, x, y )
			local cell = roomCell( room, x, y )
			if cell.empty then
				local str = cellNeighborString( room, x, y )
				cell.sprite = cellSpriteForNeighbors[ str ] or CELL_EMPTY
			end
		end

		for y = 1, room.hgt do
			for x = 1, room.wid do
				beautifyCell( room, x, y )
			end
		end
	end

	function addCellShadows( room )
		function fixupCellShadows( room, x, y )
			local cell = roomCell( room, x, y )
			if not cell.empty then
				return
			end

			local str = cellNeighborString( room, x, y )
			cell.shadowSprites = {}

			if str:sub(1,1) == 'X' and str:sub(4,4) == 'X' then
					table.insert( cell.shadowSprites, sheet_pixels_to_sprite( 224, 104 ))
			else
				if str:sub(1,1) == 'X' then
					table.insert( cell.shadowSprites, sheet_pixels_to_sprite( 224, 88 ))
				end
				if str:sub(2,2) == 'X' then
					table.insert( cell.shadowSprites, sheet_pixels_to_sprite( 200, 88 ))
				end
				if str:sub(3,3) == 'X' then
					table.insert( cell.shadowSprites, sheet_pixels_to_sprite( 224, 80 ))
				end
				if str:sub(4,4) == 'X' then
					table.insert( cell.shadowSprites, sheet_pixels_to_sprite( 208, 88 ))
				end
			end
			-- trace( str .. ' ' .. tostring( #cell.shadowSprites ))
		end

		for y = 1, room.hgt do
			for x = 1, room.wid do
				fixupCellShadows( room, x, y )
			end
		end
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
		pieces = {},
	}

	assert( world and world.room and world.room.cells )

	roomPaintEmptyRect( 
		world.room, 
		wid // 2 - startingRoomWid//2, 
		hgt // 2 - startingRoomHgt//2, 
		startingRoomWid, 
		startingRoomHgt )

	-- todo
	local piece = createPiece( 1, pieceFamilies[ 1 ] )
	piece.x = wid//2*8
	piece.y = hgt//2*8
	table.insert( world.pieces, piece )

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

function updateWorld( world )
	for _, piece in pairs( world.pieces ) do
		updatePiece( piece )
	end
end

-- UPDATE

function update()
	updateInput()

	updateWorld( world )
end

-- DRAWRING

function drawCell( cell, x, y )
	spr( cell.sprite, x, y )

	for _, sprite in pairs( cell.shadowSprites ) do
		spr( sprite, x, y )
	end
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
		for _, piece in pairs( world.pieces ) do
			drawPiece( piece )
		end
	end

	drawLowerEnvironment()
	drawCharacters()

	camera( 0, 0 )
end

function drawDebug()
	-- print( tostring( mousex ) .. ',' .. tostring( mousey ) .. '::' .. tostring( placeableRoom ))
	-- print( tostring( world.focusX ) .. ',' .. tostring( world.focusY ))

	print( tostring( #world.pieces ))

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