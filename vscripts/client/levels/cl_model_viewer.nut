function main()
{	
	RegisterButtonPressedCallback( BUTTON_DPAD_UP, TranslateTTUp )
	RegisterButtonReleasedCallback( BUTTON_DPAD_UP, TranslateTTUpStop )
	RegisterButtonPressedCallback( BUTTON_DPAD_DOWN, TranslateTTDown )
	RegisterButtonReleasedCallback( BUTTON_DPAD_DOWN, TranslateTTDownStop )
}

function TranslateTTUp      ( player )
{
	player.ClientCommand( "ModelView up" )
}
   
function TranslateTTUpStop  ( player )  
{
	player.ClientCommand( "ModelView up_stop" )
}

function TranslateTTDown    ( player )
{
	player.ClientCommand( "ModelView down" )
}

function TranslateTTDownStop( player )
{
	player.ClientCommand( "ModelView down_stop" )
}