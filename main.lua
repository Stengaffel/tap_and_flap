-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" );

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar );

-- Seed the random number generator
math.randomseed( os.time() );

-- Go to game screen
composer.gotoScene( "game" );

-- Reserve channel 1 for background music
audio.reserveChannels( 1 );
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel=1 } );
