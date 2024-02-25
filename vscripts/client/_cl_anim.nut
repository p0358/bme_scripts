function main()
{
	Globalize( AddClientEventHandling )
}

function AddClientEventHandling( entity )
{
	if ( !("OnClientAnimEvent" in entity.GetScriptScope() ) )
		entity.GetScriptScope().OnClientAnimEvent <- HandleClientAnimEvent
}
RegisterFunctionDesc( "AddClientEventHandling", "Makes a client entity handle client anim events" )


// anim teleport
function PlayAnimTeleport( guy, animation_name, reference = null, optionalTag = null, initialTime = -1.0 )
{
	if ( type( guy ) == "array" || type( guy ) == "table" )
	{
		Assert( reference, "NO reference" )
		local firstEnt = null
		foreach ( ent in guy )
		{
			if ( !firstEnt )
				firstEnt = ent

			TeleportToAnimStart( ent, animation_name, reference, optionalTag )
			__PlayAnim( ent, animation_name, reference, optionalTag, 0 )
			if ( initialTime > 0.0 )
				guy.Anim_SetInitialTime( initialTime )
		}

		firstEnt.clWaittillAnimDone()
	}
	else
	{
		if ( !reference )
			reference = guy

		TeleportToAnimStart( guy, animation_name, reference, optionalTag )
		__PlayAnim( guy, animation_name, reference, optionalTag, 0 )
		if ( initialTime > 0.0 )
			guy.Anim_SetInitialTime( initialTime )
		guy.clWaittillAnimDone()
	}
}

// play the anim
function PlayAnim( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, initialTime = -1.0 )
{
	if ( type( guy ) == "array" )
	{
		foreach ( ent in guy )
		{
			__PlayAnim( ent, animation_name, reference, optionalTag, blendTime )
			if ( initialTime > 0.0 )
				guy.Anim_SetInitialTime( initialTime )
		}

		guy[0].clWaittillAnimDone()
	}
	else
	{
		__PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
		if ( initialTime > 0.0 )
			guy.Anim_SetInitialTime( initialTime )
		guy.clWaittillAnimDone()
	}
}

function GetAnim( guy, animation )
{
	if ( !( "anims" in guy.s ) )
		return animation

	if ( !( animation in guy.s.anims ) )
		return animation

	return guy.s.anims[ animation ]
}

function HasAnim( guy, animation )
{
	if ( !( "anims" in guy.s ) )
		return false

	return animation in guy.s.anims
}

function SetAnim( guy, name, animation )
{
	if ( !( "anims" in guy.s ) )
		guy.s.anims <- {}

	Assert( !( name in guy.s.anims ), guy + " already has set anim " + name )

	guy.s.anims[ name ] <- animation
}

function GetAnimStartInfo( ent, animAlias, animref )
{
	local animData = GetAnim( ent, animAlias )
	local animStartInfo = ent.Anim_GetStartForRefPoint( animData, animref.GetOrigin(), animref.GetAngles() )

	return animStartInfo
}

function GetRefPosition( reference )
{
	Assert( reference.HasKey( "model" ) && reference.kv.model != "", "Tried to play an anim relative to " + reference + " but it has no model/ref attachment." )

	local position = {}
	local attach_id
	attach_id = reference.LookupAttachment( "REF" )

	if ( attach_id )
	{
		position.origin <- reference.GetAttachmentOrigin( attach_id )
		position.angles <- reference.GetAttachmentAngles( attach_id )
	}

	return position
}

// play the anim
function __PlayAnim( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
{
	Assert( IsValid_ThisFrame( guy ), "Invalid ent " + guy + " sent to PlayAnim" )
	local animation = GetAnim( guy, animation_name )

	//guy.SetNextThinkNow()	<- SetNextThinkNow() doesn't exist on the client

	if ( reference )
	{
		if ( reference == guy )
		{
			local position = GetRefPosition( reference )
			local origin = position.origin
			local angles = position.angles

			guy.Anim_PlayWithRefPoint( animation, origin, angles, blendTime )

			return
		}

		if ( optionalTag )
		{
			if ( typeof( reference ) == "Vector" )
			{
				Assert( typeof( optionalTag ) == "Vector", "Expected angles but got " + optionalTag )

				guy.Anim_PlayWithRefPoint( animation, reference, optionalTag, blendTime )

				return
			}

			Assert( typeof( optionalTag == "string" ), "Passed invalid optional tag " + optionalTag )

			if ( guy.clGetParent() == reference )
			{
				guy.Anim_Play( animation )
			}
			else
			{
				local attachIndex = reference.LookupAttachment( optionalTag )
				local origin = reference.GetAttachmentOrigin( attachIndex )
				local angles = reference.GetAttachmentAngles( attachIndex )

				//local animStartPos = guy.Anim_GetStartForRefEntity( animation, reference, optionalTag )
				//local origin = animStartPos.origin
				//local angles = animStartPos.angles

				guy.Anim_PlayWithRefPoint( animation, origin, angles, blendTime )
			}
			return
		}
	}
	else
	{
		Assert( optionalTag == null, "Reference was null, but optionalTag was not. Did you mean to set the tag?" )
	}

	if ( reference != null && guy.clGetParent() == reference )
	{
		guy.Anim_Play( animation )

		return
	}

    if ( !reference )
	    reference = guy

    local origin = reference.GetOrigin()
    local angles = reference.GetAngles()

	guy.Anim_PlayWithRefPoint( animation, origin, angles, blendTime )
}

function TeleportToAnimStart( guy, animation_name, reference, optionalTag = null )
{
	return //<- need code feature because Anim_GetStartForRefEntity doesn't exist on client

	Assert( reference, "NO reference" )
	local animation = GetAnim( guy, animation_name )
	local animStartPos

	if ( optionalTag )
	{
		// this command doesnt exist yet
		animStartPos = guy.Anim_GetStartForRefEntity( animation, reference, optionalTag )
	}
	else
	{
		//printt( "Reference is " + reference )
		//printt( "guy is " + guy )
		//printt( "animation is " + animation )
		local origin = reference.GetOrigin()
		local angles = reference.GetAngles()
		animStartPos = guy.Anim_GetStartForRefPoint( animation, origin, angles )
	}
	Assert( animStartPos, "No animStartPos for " + animation + " on " + guy )

	// hack! shouldn't need to do this
	ClampToWorldspace( animStartPos.origin )

	guy.SetOrigin( animStartPos.origin )
	guy.SetAngles( animStartPos.angles )
}

// when this entity animates and hits an AE_CL_VSCRIPT_CALLBACK event, he will
// call the function registered to the given name
function AddAnimEvent( entity, eventName, callbackFunc, optionalVar = null )
{
	Assert( !(entity instanceof C_WeaponX), "Cannot add anim events on C_WeaponX" )

	if ( optionalVar != null )
	{
		AssertParameters( callbackFunc, 2, "entity, optionalVar" )
	}
	else
	{
		AssertParameters( callbackFunc, 1, "entity" )
	}

	AddClientEventHandling( entity )

	if ( !( "clientAnimEvents" in entity.s ) )
	{
		entity.s.clientAnimEvents <- {}
		entity.s.clientAnimEvents_optionalVars <- {}
	}
	else
	{
		Assert( !( eventName in entity.s.clientAnimEvents ), "Already created anim event " + eventName )
	}

	entity.s.clientAnimEvents[ eventName ] <- callbackFunc.bindenv( this )

	if ( optionalVar != null )
		entity.s.clientAnimEvents_optionalVars[ eventName ] <- optionalVar
}


function DeleteAnimEvent( entity, eventName, callbackFunc )
{
	Assert( eventName in entity.s.clientAnimEvents, "Entity does not have anim event " + eventName )
	local oldName = FunctionToString( entity.s.clientAnimEvents[ eventName ] )
	local newName = FunctionToString( callbackFunc )
	Assert( oldName == newName, "Anim event " + eventName + " was not " + oldName )

	delete entity.s.clientAnimEvents[ eventName ]

	if ( eventName in entity.s.clientAnimEvents_optionalVars )
		delete entity.s.clientAnimEvents_optionalVars[eventName]
}

function HasAnimEvent( entity, eventName )
{
	if ( !( "clientAnimEvents" in entity.s ) )
		return false
	return ( eventName in entity.s.clientAnimEvents )
}

function HandleClientAnimEvent( eventName )
{
	if ( "clientAnimEvents" in self.s && eventName in self.s.clientAnimEvents )
	{
		if ( eventName in self.s.clientAnimEvents_optionalVars )
			self.s.clientAnimEvents[ eventName ]( self, self.s.clientAnimEvents_optionalVars[eventName] )
		else
			self.s.clientAnimEvents[ eventName ]( self )

		return
	}

	if ( eventName.find( ":" ) != null )
	{
		local tokens = split( eventName, ":" )

		local eventName = tokens[0]

		switch ( eventName )
		{
			case "signal":
				self.Signal( tokens[1] )
				break

			case "level_signal":
				level.ent.Signal( tokens[1] )
				break

			case "pet_titan_1p_sound":
				Assert( tokens.len() == 2 )
				Assert( self.IsTitan() )
				local player = GetLocalViewPlayer()
				if ( self.GetBossPlayerName() == player.GetPlayerName()  )
				{
					//printt( "local player is boss player!" )
					//printt( "Emit sound: " + tokens[1] + " on " + self )
					EmitSoundOnEntity( self, tokens[ 1 ] )
				}
				break

			case "pet_titan_3p_sound":
				Assert( tokens.len() == 2 )
				Assert( self.IsTitan() )
				local player = GetLocalViewPlayer()
				if ( self.GetBossPlayerName() != player.GetPlayerName()  )
				{
					//printt( "local player is not boss player!" )
					//printt( "Emit sound: " + tokens[1] + " on " + self )
					EmitSoundOnEntity( self, tokens[ 1 ] )

				}
				break


		}
		return
	}

	switch ( eventName )
	{
		case "hide_cockpit":
		{
			local player = GetLocalViewPlayer()
			local proxy = player.GetFirstPersonProxy()
			if ( IsValid( proxy ) && proxy == self )
				player.GetCockpit().Hide()
			break
		}

		//Best to do it like this instead of using the signalling functionality above
		//since the above functionality is for signalling the animating entity,
		//i.e. the prop dynamic animating instead of the player seeing the animation
		case "close_vdu":
		{
			local player = GetLocalViewPlayer()
			player.Signal( "ConversationOver" )
			break
		}

		case "vdu_static_light":
		{
			SetVDUStatic( STATIC_LIGHT )
			break
		}

		case "vdu_static_heavy":
		{
			SetVDUStatic( STATIC_HEAVY )
			break
		}

		case "vdu_static_off":
		{
			ClearVDUStatic()
			break
		}

		case "screen_blackout" :
		{
			printt("We got screen blackout event!")
			break
		}

		case "vdu_close" :
		{
			HideVDU()
			break
		}
	}
	return
}
