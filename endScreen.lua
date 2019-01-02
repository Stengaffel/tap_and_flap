
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize varables
local json = require( "json" );

local filePath = system.pathForFile( "score.json", system.DocumentsDirectory );

local score = composer.getVariable( "finalScore" );
local scoreText;
local highScore;
local highScoreText;
local comment;
local commentSize = 40;
local commentText;

-- Display groups
local backGroup;
local mainGroup;


local function tryAgain()
	composer.gotoScene( "game", { time=500, effect="slideRight" })
end


local function loadScore()

	local file = io.open( filePath, "r" );
	if file then
		local content = file:read( "*a" );
		io.close( file );
		highScore = json.decode( content );
	end

	if ( highScore == nil ) then
		highScore = 0;
	end
end


local function saveScore()

	local file = io.open( filePath, "w" );
	 if file then
		 file:write( json.encode( highScore ) );
		 io.close( file );
	 end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Load the previous highscore
	loadScore();

	-- Reset the variable
	composer.setVariable( "finalScore", 0 );

	-- Set up the display groups
	backGroup = display.newGroup(); -- Display group for the background
	sceneGroup:insert( backGroup ); -- Insert into the scene's view group

	mainGroup = display.newGroup();
	sceneGroup:insert( mainGroup );

	local background = display.newImageRect( backGroup, "flapBackground.png", 800, 1400 );
	background.x = display.contentCenterX;
	background.y = display.contentCenterY;

	local scoreBoard = display.newImageRect( mainGroup, "scoreBoard.png", 500, 400 );
	scoreBoard.x = display.contentCenterX;
	scoreBoard.y = display.contentCenterY;

	scoreText = display.newText( mainGroup, "Score: " .. score, scoreBoard.x-80, scoreBoard.y-40, native.systemFont, 40 );
	scoreText:setTextColor( 0, 0, 0 );
	scoreText.anchorY = 0;
	scoreText.anchorX = 0;

	if ( score > highScore ) then
		highScore = score;
		saveScore();

		local highSign = display.newText( mainGroup, "NEW HIGH SCORE !", scoreBoard.x, scoreBoard.y-135, native.systemFont, 40 );
		highSign:setTextColor( 1, 0, 0 );
	end

	highScoreText = display.newText( mainGroup, "High Score: " .. highScore, scoreBoard.x-80, scoreBoard.y-50, native.systemFont, 40 );
	highScoreText:setTextColor( 0, 0, 0 );
	highScoreText.anchorY = 1;
	highScoreText.anchorX = 0;

	local flapper = display.newImageRect( mainGroup, "flapper.png", 100, 100 );
	flapper.x = scoreBoard.x-100
	flapper.y = scoreBoard.y-50;
	flapper.anchorX = 1;

	-- Determines the comment based on score
	if ( score < 3 ) then
		comment = "Alright";
	elseif ( score < 9 ) then
		comment = "Getting better!"
	elseif ( score < 19 ) then
		comment = "Good!";
	elseif ( score < 49 ) then
		comment = "Great!";
	elseif ( score < 99 ) then
		comment = "Awesome!"
	elseif ( ( score > 99 ) and ( score < 150) ) then
		comment = "Åh helvete!";
	elseif ( score > 149) then
		comment = "Trodde ingen skulle komma så här långt, haha!";
		commentSize = 20;
	end

	local commentText = display.newText( mainGroup, comment, scoreBoard.x,
				scoreBoard.y+100, native.systemFont, commentSize );
	commentText:setTextColor( 0.2, 0, 1 );

	local tryButton = display.newText( sceneGroup, "Try Again", scoreBoard.x, scoreBoard.y+350, native.systemFont, 50 );
	tryButton:addEventListener( "tap", tryAgain );
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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

		composer.removeScene( "endScreen" );
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
