if ( !("turntableDynPropModel" in getroottable()) )
	::turntableDynPropModel <- "models/humans/hero/bish/bish_static.mdl"

if ( !("turntableDynPropModel2" in getroottable()) )
	::turntableDynPropModel2 <- null

if ( !("turntableDynPropModel3" in getroottable()) )
	::turntableDynPropModel3 <- null

if ( !("turntableDynPropModel4" in getroottable()) )
	::turntableDynPropModel4 <- null

if ( !("turntableDynPropModel5" in getroottable()) )
	::turntableDynPropModel5 <- null
	
//  MODEL VIEWING TURNTABLE

//get all rotating things
//ui to control


ttArray <- []
ttUIController <- null
ttFreezeController <- null

ttStickMoveActive <- false

ttControlsState <- 0 // 0 = off, 1 = on

	PrecacheModel( turntableDynPropModel )

	if ( turntableDynPropModel2 && turntableDynPropModel2 != "" )
		PrecacheModel( turntableDynPropModel2 )

	if ( turntableDynPropModel3 && turntableDynPropModel3 != "" )
		PrecacheModel( turntableDynPropModel3 )

	if ( turntableDynPropModel4 && turntableDynPropModel4 != "" )
		PrecacheModel( turntableDynPropModel4 )

	if ( turntableDynPropModel5 && turntableDynPropModel5 != "" )
		PrecacheModel( turntableDynPropModel5 )

RegisterSignal( "TT_stop" )

RegisterSignal( "TT_RotateStop" )

function OnPostSpawn()
{
	Assert( GetEntArray( self.GetName() ).len() == 1, "You have more then one game_ui named " + self.GetName() + ". You should only have one" )

	ttArray = GetEntArray( "rotating_turntable*" )
	Assert( ttArray.len() > 0, "You don't have any func_rotatings named rotating_turntable - you need one!" )
	
	foreach ( tt in ttArray )
	{		
		tt.kv.rendermode = 10
		
		tt.s.prop <- null
		
		local prop_dynamic_override = CreateEntity( "script_mover" )
		prop_dynamic_override.SetOrigin( tt.GetOrigin() + Vector( 0, 0, 16 ) )
		//prop_dynamic_override.SetParent( tt.GetName() )
		
		local ttPostFix = tt.GetName().slice( ("rotating_turntable").len() )
		
		if ( ttPostFix[0] == '_' )
		{
			prop_dynamic_override.kv.model = turntableDynPropModel
			printt( "MODEL", prop_dynamic_override.kv.model )
		}
		else if ( ttPostFix[0] == '2' && turntableDynPropModel2 )
			prop_dynamic_override.kv.model = turntableDynPropModel2
		else if ( ttPostFix[0] == '3' && turntableDynPropModel3 )
			prop_dynamic_override.kv.model = turntableDynPropModel3
		else if ( ttPostFix[0] == '4' && turntableDynPropModel4 )
			prop_dynamic_override.kv.model = turntableDynPropModel4
		else if ( ttPostFix[0] == '5' && turntableDynPropModel5 )
			prop_dynamic_override.kv.model = turntableDynPropModel5
				
		if ( prop_dynamic_override.kv.model == "" )
		{
			prop_dynamic_override.Destroy()
			continue
		}
		
		prop_dynamic_override.kv.spawnflags = 0
		prop_dynamic_override.kv.fadedist = -1
		prop_dynamic_override.kv.rendercolor = "255 255 255"
		prop_dynamic_override.kv.renderamt = 255
		prop_dynamic_override.kv.solid = 6
		prop_dynamic_override.kv.CollisionGroup = 21	// COLLISION_GROUP_BLOCK_WEAPONS

		prop_dynamic_override.kv.MinAnimTime = 5
		prop_dynamic_override.kv.MaxAnimTime = 10
		prop_dynamic_override.kv.SpawnAsPhysicsMover = false
		DispatchSpawn( prop_dynamic_override, false )
		
		prop_dynamic_override.s.wSS <- prop_dynamic_override.GetWorldSpaceCenter()
		prop_dynamic_override.s.wSS.x = prop_dynamic_override.GetOrigin().x
		prop_dynamic_override.s.wSS.y = prop_dynamic_override.GetOrigin().y
		prop_dynamic_override.s.rotAngle <- prop_dynamic_override.GetOrigin() - prop_dynamic_override.s.wSS
		prop_dynamic_override.s.zOffset <- 0
		
		tt.s.prop = prop_dynamic_override
	}
	
	ttUIController = CreateEntity( "game_ui" )
	ttUIController.SetName( UniqueString() )
	ttUIController.kv.spawnflags = 64//no gunz
	ttUIController.kv.FieldOfView = -1.0
	
	ttUIController.AddOutput( "PressedOffhand1", self.GetName(), "CallScriptFunction", "RotateTTRight" ) 
	ttUIController.AddOutput( "UnpressedOffhand1", self.GetName(), "CallScriptFunction", "RotateTTStop" ) 	
	ttUIController.AddOutput( "PressedOffhand2", self.GetName(), "CallScriptFunction", "RotateTTLeft" ) 
	ttUIController.AddOutput( "UnpressedOffhand2", self.GetName(), "CallScriptFunction", "RotateTTStop" ) 	

	ttUIController.AddOutput( "PressedAttack", self.GetName(), "CallScriptFunction", "TTStickMove" ) 
	ttUIController.AddOutput( "UnpressedAttack", self.GetName(), "CallScriptFunction", "TTStickMoveStop" )
	
	ttUIController.AddOutput( "PressedSpeed", self.GetName(), "CallScriptFunction", "ResetProp" )

	DispatchSpawn( ttUIController, false )

	ttFreezeController = CreateEntity( "game_ui" )
	ttFreezeController.SetName( UniqueString() )
	ttFreezeController.kv.spawnflags = 32
	ttFreezeController.kv.FieldOfView = -1.0

	DispatchSpawn( ttFreezeController, false )

	self.AddOutput( "PressedWeaponCycle", self.GetName(), "CallScriptFunction", "reload_my_mats" )
	self.AddOutput( "PressedUseAndReload", self.GetName(), "CallScriptFunction", "ReloadModels" )
	self.AddOutput( "PressedJump", self.GetName(), "CallScriptFunction", "Noclip_me" )
	self.Fire( "Activate", "!player", 1 )

	self.Fire( "CallScriptFunction", "ToggleTTControls", 1 )
	
	AddClientCommandCallback( "ModelView", ClientCommand_ModelView )


	thread StickMoveThread()
}

function ClientCommand_ModelView( player, command )
{
	switch ( command )
	{
		case "up":
			TranslateTTUp( player )
			break
		case "up_stop":
			TranslateTTUpStop( player )
			break
		case "down":
			TranslateTTDown( player )
			break
		case "down_stop":
			TranslateTTDownStop( player )
			break
	}
	
	return true
}

function ResetProp()
{
	printt( "reset" )
	foreach ( tt in ttArray )
	{
		local prop = tt.s.prop
		
		if ( !prop )
			continue
	
		tt.s.prop.s.zOffset = 0
		prop.SetAngles( tt.GetAngles() )
		prop.SetOrigin( tt.GetOrigin() + Vector( 0, 0, 16 ) )
	}
}

function StickMoveThread()
{
	local player = GetPlayer()
	
	while ( !player )
	{
		player = GetPlayer()
		wait 0
	}
	
	while ( 1 )
	{
		if ( ttStickMoveActive )
		{
			local yDir = GetInput_YAxis( player )
			local xDir = GetInput_XAxis( player )

			foreach ( index, tt in ttArray )
			{
				local prop = tt.s.prop
				
				if ( !prop )
					continue

				local angles = prop.GetAngles()
				local newAngles = angles
	
				if ( fabs( yDir ) + fabs( xDir ) < 0.05 )
					continue
	
				if ( fabs( yDir ) > fabs( xDir ) )
				{
					//newAngles.x += 5 * yDir
					newAngles = newAngles.AnglesCompose( Vector( yDir * 10, 0, 0 ) )
				}
				else
				{
					//newAngles.y += 5 * xDir
					newAngles = newAngles.AnglesCompose( Vector( 0, xDir * 15, 0 ) )
				}
					
				prop.NonPhysicsRotateTo( newAngles, 0.06666, 0, 0 )
				
				local newOrigin = prop.s.wSS + prop.s.rotAngle.RotateAngles( newAngles )
				newOrigin.z += prop.s.zOffset	
				prop.NonPhysicsMoveTo( newOrigin, 0.06666, 0, 0 )
			}
		}
		
		wait 0.03333
	}
}

function TTStickMove()
{

	ttStickMoveActive = true

	ttFreezeController.Fire( "Activate", "!player", 0 )
}

function TTStickMoveStop()
{
	ttStickMoveActive = false

	ttFreezeController.Fire( "Deactivate", "!player", 0 )
}

function RotateTTRight()
{
	foreach ( tt in ttArray )
	{
		if ( tt.s.prop )
			thread RotateTTThread( tt, 10 )
	}
}

function RotateTTStop()
{
	foreach ( tt in ttArray )
	{
		tt.Signal( "TT_RotateStop" )
		if ( tt.s.prop )
			tt.s.prop.SetAngles( tt.s.prop.GetAngles() )
	}
}

function RotateTTLeft()
{
	foreach ( tt in ttArray )
	{
		if ( tt.s.prop )
			thread RotateTTThread( tt, -10 )
	}
}

function RotateTTThread( tt, degrees )
{
	tt.Signal( "TT_RotateStop" )
	tt.EndSignal( "TT_RotateStop" )

	local prop = tt.s.prop

	while( true )
	{
		local angles = prop.GetAngles()
		local newAngles = angles.AnglesCompose( Vector( 0, degrees, 0 ) )

		prop.NonPhysicsRotateTo( newAngles, 0.06666, 0, 0 )

		wait 0.03333
	}
}

function TranslateTTUp( player )
{
	foreach ( tt in ttArray )
	{
		if ( tt.s.prop )
			thread TranslateTTUpThread( tt )
	}
}

function TranslateTTUpThread( tt )
{
	tt.Signal( "TT_stop" )
	tt.EndSignal( "TT_stop" )

	while( true )
	{
		tt.s.prop.SetOrigin( tt.s.prop.GetOrigin() + Vector( 0,0,1 ) )
		tt.s.prop.s.zOffset += 1
		wait 0.01
	}
}

function TranslateTTUpStop( player )
{
	foreach ( tt in ttArray )
	{
		tt.Signal( "TT_stop" )
	}
}

function TranslateTTDown( player )
{
	foreach ( tt in ttArray )
	{
		if ( tt.s.prop )
			thread TranslateTTDownThread( tt )
	}
}

function TranslateTTDownThread( tt )
{
	tt.Signal( "TT_stop" )
	tt.EndSignal( "TT_stop" )

	while( true )
	{
		tt.s.prop.SetOrigin( tt.s.prop.GetOrigin() + Vector( 0,0,-1 ) )
		tt.s.prop.s.zOffset -= 1
		wait 0.01
	}
}

function TranslateTTDownStop( player )
{
	foreach ( tt in ttArray )
	{
		tt.Signal( "TT_stop" )
	}
}

//API_Hammer: ToggleTTControls
function ToggleTTControls()
{
	if ( ttControlsState == 0 )
	{
		printl ( "Turntable control is ON" )
		ttUIController.Fire( "Activate", "!player" )
		ttControlsState = 1
	}
	else
	{
				printl ( "Turntable control is OFF" )
		ttUIController.Fire( "Deactivate" )
		ttControlsState = 0
	}
}

function ReloadModels()
{
	printl( "MODEL_UPDATED!" )
	_cc.Fire( "Command", "r_flushlod", 1 ) 
}

function Noclip_me()
{
	_cc.Fire( "Command", "noclip", 0 ) 
	
}

function reload_my_mats()
{
	printl( "MATERIALS_UPDATED!" )
	_cc.Fire( "Command", "mat_reloadallmaterials", 0 ) 
	
}