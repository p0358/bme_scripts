class cScoreEvent
{
	name = null
	int = null
	pointValue = 0
	pointValueIcon = null
	splashText = ""
	conversation = null
	priority = 0
	stackingDisplay = false
	eventType = scoreEventType.DEFAULT
	timeDelay = null
	xpType = null
	appendTargetName = false
	xpMultiplierApplies = null

	constructor( name )
	{
		Assert( !( name in level.scoreEventsByName ), name + " already exists as a score event" )
		this.int = level.scoreEventsByName.len()
		level.scoreEventsByName[ name ] <- this
		level.scoreEventsByIndex[ this.int ] <- this
		this.name = name
		this.splashText = name
		this.timeDelay = 0.5
		xpMultiplierApplies = true
	}

	function GetName()
	{
		return name
	}

	function GetInt()
	{
		return int
	}

	function SetXPMultiplierApplies( value )
	{
		xpMultiplierApplies = value
	}

	function GetXPMultiplierApplies()
	{
		return xpMultiplierApplies
	}

	function SetPointValue( value )
	{
		pointValue = value
	}

	function GetPointValue()
	{
		return pointValue
	}

	function SetPointValueIcon( icon )
	{
		pointValueIcon = icon
	}

	function GetPointValueIcon()
	{
		return pointValueIcon
	}

	function HasPointValueIcon()
	{
		return ( pointValueIcon != null )
	}

	function SetSplashText( text )
	{
		splashText = text
	}

	function SetXPType( type )
	{
		Assert( type >= 0 && type < XP_TYPE._NUM_TYPES )
		xpType = type
	}

	function GetSplashText()
	{
		return splashText
	}

	function GetXPType()
	{
		return xpType
	}

	function SetType( value )
	{
		eventType = value
	}

	function GetType()
	{
		return eventType
	}

	function SetConversation( value, value2 )
	{
		conversation = value
		priority = value2
	}

	function GetConversation()
	{
		return conversation
	}

	function GetPriority()
	{
		return priority
	}

	function HasConversation()
	{
		return conversation != null
	}

	function SetShouldStackDisplay( bool )
	{
		if ( bool )
			Assert( appendTargetName == false )
		stackingDisplay = bool
	}

	function GetShouldStackDisplay()
	{
		return stackingDisplay
	}

	function SetSplashTextAppendTargetName( bool )
	{
		if ( appendTargetName )
			Assert( stackingDisplay == false )
		appendTargetName = bool
	}


	function GetSplashTextAppendTargetName()
	{
		return appendTargetName
	}

	function GetTimeDelay()
	{
		return timeDelay
	}

	function SetTimeDelay( value )
	{
		timeDelay = value
	}

	function SetScoreSplashColors( table )
	{
		level.scoreCustomColors[ this ] <- table
	}
}

