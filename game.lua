
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" );
physics.start();
physics.setGravity( 0, 45 );

-- Configure image sheet
local sheetOptions =
{
	frames =
	{
		{ -- 1) bar 1 ( short bar )
			x = 0,
			y = 0,
			width = 100,
			height = 300
		},
		{ -- 2) bar 2 ( medium bar )
			x = 0,
			y = 0,
			width = 100,
			height = 500
		},
		{ -- 3) bar 3 ( long bar )
			x = 0,
			y = 0,
			width = 100,
			height = 700
		}
	}
}

-- Configuring the test square
local sOptionsSquare =
{
	frames =
	{
		{ -- 1.) The hitbox for each slot
			x = 0;
			y = 0;
			width = 100;
			height = 200;
		}
	}
}

local objectSheet = graphics.newImageSheet( "bars.png", sheetOptions );

local squareSheet = graphics.newImageSheet( "blankHitbox.png", sOptionsSquare );


-- Initialize variables
local score = 0;
local pause = true;
local died = false;

local gameLoopTimer;
local scoreText;
local startText;
local gameLoopTimer;
local obstacleTable = {};
local hitboxTable = {};

local flapper;

local backGroup;
local mainGroup;
local uiGroup;

-- Possibly add sound variables here later


-- Updates the text
local function updateText ()
		scoreText.text = "" .. score;
end

-- Before the game starts
local function beforeStart ()

end

-- Creates the obstacle
local function createObstacle ()
	-- Determines the obstacle
	local obstacleType = math.random( 3 );

	local topBar;
	local bottomBar;

	-- Adds the hitbox for each slot
	local hitbox = display.newImageRect( mainGroup, squareSheet, 1, 10, 180 );
	table.insert( hitboxTable, hitbox );

	if ( obstacleType == 1 ) then
		-- Upper slot
		topBar = display.newImageRect( mainGroup, objectSheet, 1, 100, 300 );
		bottomBar = display.newImageRect( mainGroup, objectSheet, 3, 100, 700 );
		-- Top slot edge: 225 pixels down
		topBar.y = 75;
		bottomBar.y = display.contentHeight - 175;
		hitbox.y = 360;
	elseif ( obstacleType == 2 ) then
		-- Middle slot
		topBar = display.newImageRect( mainGroup, objectSheet, 2, 100, 500 );
		bottomBar = display.newImageRect( mainGroup, objectSheet, 2, 100, 500 );
		-- Top slot edge: 375 pixels down
		topBar.y = 125;
		bottomBar.y = display.contentHeight - 125;
		hitbox.y = 510;
	elseif ( obstacleType == 3 ) then
		-- Bottom slot
		topBar = display.newImageRect( mainGroup, objectSheet, 3, 100, 700 );
		bottomBar = display.newImageRect( mainGroup, objectSheet, 1, 100, 300 );
		topBar.y = 175;
		bottomBar.y = display.contentHeight - 75;
		hitbox.y = display.contentHeight - 360;
	end

	table.insert( obstacleTable, topBar );
	table.insert( obstacleTable, bottomBar );

	physics.addBody(topBar, "kinematic");
	physics.addBody(bottomBar, "kinematic");
	physics.addBody(hitbox, "kinematic");

	topBar.myName = "bar";
	bottomBar.myName = "bar";
	hitbox.myName = "hitbox";

	topBar.x = display.contentWidth + 50;
	bottomBar.x = display.contentWidth + 50;
	hitbox.x = display.contentWidth + 70;

	bottomBar:setLinearVelocity( -280, 0 , bottomBar.x, bottomBar.y );
	topBar:setLinearVelocity( -280, 0 , topBar.x, topBar.y );
	hitbox:setLinearVelocity( -280, 0 , hitbox.x, hitbox.y );
end

local function tapFlap ()
	-- Makes the game start after the first touch
	if ( pause ) then
		display.remove( startText );
		physics.start();
		pause = false;
	end
	flapper:setLinearVelocity( 0, -400, flapper.x, flapper.y );
end


local function changeScene()
	-- Remove scene
	composer.removeScene( "game" );
	-- Redirect to scoreboard
	composer.gotoScene( "endScreen", { time=1000, effect="slideRight" } );
end

-- End of game
local function endGame()

	-- Remove the onCollision eventListener as it's only going to be called once
	Runtime:removeEventListener( "collision", onCollision );

	-- Removes remaining hitboxes
	for i = #hitboxTable, 1, -1 do
		local thisHitbox = hitboxTable[i];
		display.remove( thisHitbox );
		table.remove( hitboxTable, i );
	end

	-- Pops the flapper off
	flapper:setLinearVelocity( 100, -600, flapper.x, flapper.y );
	flapper:applyTorque( 100, 100 );

	-- Remove eventlisteners and timers
	Runtime:removeEventListener( "tap", tapFlap );

	-- Save the score
	composer.setVariable( "finalScore", score );
end

local function removeObstacles ()
	if( #obstacleTable == 0 and died ) then
		timer.cancel( gameLoopTimer );
		physics.pause();
		--display.remove( flapper ); -- creates an error when flapper first goes out of bounds and then collides
		changeScene();
	end
end

-- Loops the game
local function gameLoop ()
	if ( not pause ) then
		if ( not died ) then
			if ( ( flapper.y > display.contentHeight + 100 ) or ( flapper.y < - 100 ) ) then
				Runtime:removeEventListener( "collision", onCollision );
				died = true;
				endGame();
			end
		end

		if ( not died ) then
			-- Creates the obstacle
				createObstacle();
		end

		-- Remove the obstacles that have passed the display
		for i = #obstacleTable, 1, -1 do
			local thisObstacle = obstacleTable[i];

			if ( thisObstacle.x < -50 ) then
				display.remove( thisObstacle );
				table.remove( obstacleTable, i );
			end
		end

		-- Checks if all the obstacles have been removed
		removeObstacles();
	end

	-- Add audio here for the point-increment
end


local function onCollision ( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1;
		local obj2 = event.object2;

		if ( ( obj1.myName == "bar" and obj2.myName == "flapper" ) or
					( obj1.myName == "flapper" and obj2.myName == "bar" ) )
		then
			-- Remove the onCollision eventListener as it's only going to be called once
			Runtime:removeEventListener( "collision", onCollision );
			died = true;
			endGame();
		end

		if ( obj1.myName == "hitbox" and obj2.myName == "flapper" ) or
				( obj1.myName == "flapper" and obj2.myName == "hitbox" )
		then
			score = score + 1;
			updateText();
			-- Remove the hitbox
			if ( obj1.myName == "hitbox" ) then
				display.remove( obj1 );
				table.remove( hitboxTable, 1 );
			end

			if ( obj2.myName == "hitbox" ) then
				display.remove( obj2 );
				table.remove( hitboxTable, 1 );
			end
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause();

	-- Set up display
	backGroup = display.newGroup(); -- Display group for the background image
	sceneGroup:insert( backGroup ); -- Insert into the scene's view group

	mainGroup = display.newGroup(); -- Display group for the main objects
	sceneGroup:insert( mainGroup ); -- Insert into the scene's view group

	uiGroup = display.newGroup(); -- Display group for the score
	sceneGroup:insert( uiGroup ); -- Insert into the scene's view group

	-- Load the background
	local background = display.newImageRect( backGroup, "flapBackground.png", 800, 1400 );
	background.x = display.contentCenterX;
	background.y = display.contentCenterY;

	-- Display score text
	scoreText = display.newText( uiGroup, "" .. 0, display.contentCenterX, 160, native.systemFont, 140 );
	scoreText:setTextColor( 0, 0, 0 );

	-- Creating the flapper
	flapper = display.newImageRect( mainGroup, "flapper.png", 100, 100);
	flapper.x = display.contentCenterX - 100;
	flapper.y = display.contentCenterY;
	physics.addBody( flapper, { radius=40, isSensor=true } );
	flapper.myName = "flapper";

	Runtime:addEventListener( "tap", tapFlap );
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then

		-- Code here runs when the scene is entirely on screen
		physics.pause();
		pause = true;
		died = false;

		startText = display.newText( uiGroup, "PRESS ANYWHERE TO START", display.contentCenterX,
									display.contentCenterY-150, native.systemFont, 30 );
		startText:setTextColor( 0, 0, 0 );

		gameLoopTimer = timer.performWithDelay( 1300, gameLoop, 0 );
		Runtime:addEventListener( "collision", onCollision );
		-- Is used in create() aswell
		--physics.addBody( flapper, { radius=40, isSensor=true } );
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "game" );
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
