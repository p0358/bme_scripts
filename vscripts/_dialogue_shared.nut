const MIN_TIME_BETWEEN_SAME_CONVERSATION = 10.0 // time between the same conversation
const AI_CONVERSATION_RANGE_SQR = 20250000
const AI_CONVERSATION_RANGE = 4500 // should match above

const AI_FRIENDLY_CHATTER_RANGE_SQR = 4410000
const AI_FRIENDLY_CHATTER_RANGE = 2100 // should match above

function main()
{
	level.Conversations <- {}
	level.actorsABCD <- [ 1, 1, 1, 1 ]

	convIndex <- 0
	level.ConvToIndex <- {}
	level.IndexToConv <- {}

	level.scenes <- {}

	Globalize( RegisterConversation )

	Globalize( IsForcedDialogueOnly )
	IncludeFile( "_dialogue_schedule_shared" )

	level.vduModels <- {
		sarah			= SARAH_MODEL,
		mac				= MAC_MODEL,
		barker			= BARKER_MODEL,
		grunt			= TEAM_MILITIA_GRUNT_MDL,
		grunt_at		= TEAM_MILITIA_ROCKET_GRUNT_MDL,
		militia_captain = TEAM_MILITIA_CAPTAIN_MDL
		bish			= BISH_MODEL,
		graves			= GRAVES_MODEL,
		spyglass		= SPYGLASS_MODEL
		blisk			= BLISK_MODEL,
		imc2            = TEAM_IMC_GRUNT_MDL //Called IMC2 for legacy reasons... really might as well just delete it if not needed
		imc_captain     = TEAM_IMC_CAPTAIN_MDL
	}

	if ( IsClient() )
	{
		IncludeFile( "client/_dialogue_schedule_client" )
	}
	else
	{
		IncludeFile( "mp/_dialogue_schedule_server" )
	}

	if ( IsMultiplayer() )
		IncludeFile( "game_state_dialog" )
}

function RegisterConversation( conversation, priority )
{
	convIndex++
	if ( IsServer() )
		level.ConvToIndex[ conversation ] <- convIndex
	else
	{
		local convTable = { conv = conversation, prio = priority }
		level.IndexToConv[ convIndex ] <- convTable
	}

	level.Conversations[conversation] <- {}
	level.Conversations[conversation]["neutral"] <- []
	level.Conversations[conversation][TEAM_MILITIA] <- []
	level.Conversations[conversation][TEAM_IMC] <- []
	level.Conversations[conversation].scene <- {}
	level.Conversations[conversation].scene["neutral"] <- null
	level.Conversations[conversation].scene[TEAM_MILITIA] <- null
	level.Conversations[conversation].scene[TEAM_IMC] <- null
	level.Conversations[conversation].priority <- priority
}

function GetConversationName( index )
{
	Assert( index in level.IndexToConv )
	return level.IndexToConv[ index ].conv
}
Globalize( GetConversationName )


function Dispatch( team, alias )
{
	switch ( team )
	{
		case TEAM_IMC:
			return "diag_imc_dispatch_" + alias

		case TEAM_MILITIA:
			return "diag_mcor_dispatch_" + alias
	}

	Assert( 0, "Unknown team " + team )
}
Globalize( Dispatch )

function Voices( team, baseAlias, voiceAvailability )
{
	switch ( team )
	{
		case TEAM_IMC:
			return AI_Dialogue_AliasAllVoices( "diag_imc_grunt", "_" + baseAlias, voiceAvailability, true )

		case TEAM_MILITIA:
			return AI_Dialogue_AliasAllVoices( "diag_mcor_grunt", "_" + baseAlias, voiceAvailability, true )
	}

	Assert( 0, "Unknown team " + team )
}
Globalize( Voices )


function AI_Dialogue_AliasAllVoices( aliasPreVoice, aliasPostVoice, voiceAvailability, hasDry = true )
{
	Assert( !Flag( "EntitiesDidLoad" ) ) // you must set up your aliases at map init so they can be precached

	// voiceAvailability is an array, hopefully [true,true,true], that specifies which voices exist for this sound.
	// this lets us hack around missing voices that were not recorded.

	Assert( voiceAvailability.len() == VOICE_COUNT )

	local firstAvailableVoiceIndex = -1
	foreach( voiceIndex, available in voiceAvailability )
	{
		if ( available )
		{
			firstAvailableVoiceIndex = voiceIndex
			break
		}
	}
	Assert( firstAvailableVoiceIndex >= 0 )

	local res = []
	for ( local voiceIndex = 0; voiceIndex < VOICE_COUNT; voiceIndex++ )
	{
		local useIndex = voiceIndex
		if ( !voiceAvailability[ useIndex ] )
			useIndex = firstAvailableVoiceIndex

		local radioAlias = aliasPreVoice + (useIndex + 1) + aliasPostVoice

		res.append( radioAlias )
	}
	return res
}

function IsForcedDialogueOnly( player )
{
	if ( level.nv.forcedDialogueOnly )
		return true

	return player.GetForcedDialogueOnly()
}

function ShouldPlaySquadConversation( player, conversationType, allowedTime, org, rangeSqr )
{
	if ( !IsValid( player ) || IsForcedDialogueOnly( player ) )
	{
		//printt( "ForcedDialogueOnly, not playing AI Conversation:"  + conversationType )
		return false
	}


	if ( conversationType in player.s.lastAIConversationTime )
	{
		if ( player.s.lastAIConversationTime[ conversationType ] > allowedTime )
			return false
	}

	return DistanceSqr( player.GetOrigin(), org ) <= rangeSqr
}
Globalize( ShouldPlaySquadConversation )