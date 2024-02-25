RegisterSignal("FlareStart")

class HUDSplashLine
{
	name 					= null
	duration 				= null
	fadeOutDuration 		= null
	fadeDelay 				= null
	scrollOffset 			= null
	scrollDuration 			= null
	masterGroup 			= null
	hudGroups 				= null
	stackCount				= null
	textGroupStrings		= null
	textGroupStringsVar1	= null
	textGroupBrackets		= null
	textGroupColors			= null
	iconElems 				= null
	iconUsage 				= null
	iconMaterials 			= null
	flareElems				= null
	startTime				= null
	iconSizes 				= null
	typeWriterDuration 		= null
	elemOffsetsX 			= null
	formatted				= null
	formattingType			= null
	scale					= null

	function constructor( _name )
	{
		name = _name

		this.duration 				= 2.0
		this.fadeOutDuration 		= 0
		this.fadeDelay 				= 2.0
		this.scrollOffset 			= 20
		this.scrollDuration 		= 0.1
		this.typeWriterDuration 	= 0
		this.hudGroups 				= {}
		this.textGroupStrings 		= {}
		this.textGroupStringsVar1	= {}
		this.textGroupBrackets		= {}
		this.textGroupColors 		= {}
		this.flareElems				= {}
		this.iconElems 				= {}
		this.iconUsage 				= {}
		this.iconMaterials 			= {}
		this.iconSizes 				= {}
		this.elemOffsetsX 			= {}
		this.formatted				= false
		this.formattingType			= "none"
		this.scale = 1.0
		this.startTime = 0.0
		this.stackCount = 1
	}

	function SetScale( _scale )
	{
		scale = _scale
	}

	function SetDuration( _duration, _fadeDuration = 0 )
	{
		duration = _duration
		fadeOutDuration = _fadeDuration
		fadeDelay = duration - fadeOutDuration
	}

	function SetScroll( offset, duration )
	{
		offset *= GetContentScaleFactor()[1]
		scrollOffset = offset
		scrollDuration = duration
	}

	function SetTypeDuration( duration )
	{
		typeWriterDuration = duration
	}

	function SetMasterGroup( hudGroup )
	{
		masterGroup = hudGroup
	}

	function AddSplashGroup( groupIndex, hudGroup )
	{
		Assert( !( groupIndex in this.hudGroups ) )

		this.hudGroups[ groupIndex ] <- hudGroup
		this.textGroupStrings[ groupIndex ] <- ""
		this.textGroupStringsVar1[ groupIndex ] <- ""
		this.textGroupBrackets[ groupIndex ] <- false
		this.textGroupColors[ groupIndex ] <- OBITUARY_COLOR_DEFAULT
		this.iconElems[ groupIndex ] <- null
		this.flareElems[ groupIndex ] <- null
		this.iconUsage[ groupIndex ] <- false
		this.iconMaterials[ groupIndex ] <- null
		this.iconSizes[ groupIndex ] <- null
	}

	function SetTextForGroup( groupIndex, text, arg1 = null )
	{
		Assert( groupIndex in textGroupStrings )
		textGroupStrings[ groupIndex ] = text//.toupper()
		if ( arg1 )
			textGroupStringsVar1[ groupIndex ] = arg1
		textGroupBrackets[ groupIndex ] = false
	}

	function SetColorForGroup( groupIndex, color )
	{
		Assert( groupIndex in textGroupStrings )
		Assert( groupIndex in textGroupColors )

		textGroupColors[ groupIndex ] = color
	}

	function AddIconElem( groupIndex, elem )
	{
		Assert( groupIndex in textGroupStrings )
		iconElems[ groupIndex ] = elem
	}

	function SetIconMaterial( groupIndex, material, iconSize, bool )
	{
		Assert( iconElems[ groupIndex ] != null )
		iconUsage[ groupIndex ] = bool
		iconMaterials[ groupIndex ] = material
		iconSizes[ groupIndex ] = iconSize
	}

	function SetFlareEffectElem( groupIndex, elem )
	{
		Assert( groupIndex in textGroupStrings )
		flareElems[ groupIndex ] = elem
	}
	
	function SetStartTime( time )
	{
		startTime = time		
	}

	function SetStackCount( count )
	{
		stackCount = count		
	}
	
	function GetStackCount()
	{
		return stackCount	
	}
	
	function Scroll( numLines )
	{
		local OffsetY = scrollOffset * numLines
		foreach( index, hudGroup in hudGroups )
		{
			local OffsetX = 0
			if ( index in this.elemOffsetsX )
				OffsetX += this.elemOffsetsX[ index ]

			local newX = hudGroup.GetX() + OffsetX
			local newY = hudGroup.GetBaseY() + OffsetY

			hudGroup.MoveOverTime( newX, newY, scrollDuration )

			if ( iconElems[ index ] != null )
				iconElems[ index ].OffsetYOverTime( OffsetY, scrollDuration )
		}
	}

	function SetBracketsForGroup( groupIndex, bracketed )
	{
		Assert( groupIndex in textGroupBrackets )
		Assert( bracketed == true || bracketed == false )
		textGroupBrackets[ groupIndex ] = bracketed
	}

	function DisplayCenter( leftElem, centerElem, rightElem )
	{
		this.elemOffsetsX = {}
		this.formatted = true
		this.formattingType = "center"

		Display( leftElem, centerElem, rightElem )
	}

	function DisplayLeft( leftElem, centerElem, rightElem )
	{
		this.elemOffsetsX = {}
		this.formatted = true
		this.formattingType = "left"

		Display( leftElem, centerElem, rightElem )
	}

	function DisplayRight( leftElem, centerElem, rightElem )
	{
		this.elemOffsetsX = {}
		this.formatted = true
		this.formattingType = "right"

		Display( leftElem, centerElem, rightElem )
	}

	function Display( leftElem = null, centerElem = null, rightElem = null )
	{
		// Reset all elems back to base position
		if ( !this.formatted )
			this.elemOffsetsX = {}
		this.formatted = false

		local allElems = masterGroup.GetElements()
		foreach( elem in allElems )
		{
			elem.ReturnToBasePos()
			//elem.ReturnToBaseSize()
			elem.ReturnToBaseColor()
			elem.Hide()
		}

		foreach( index, hudGroup in hudGroups )
		{
			Assert( index in textGroupStrings )
			Assert( index in textGroupColors )

			// If we want to display an icon with this group then reset the image info
			// too, and offset the position of the group to make room for the icon
			if ( iconUsage[ index ] )
			{
				Assert( iconMaterials[ index ] != null )
				Assert( iconSizes[ index ] != null )

				local OffsetX = iconSizes[ index ]
				hudGroup.OffsetX( OffsetX )

				iconElems[ index ].SetImage( iconMaterials[ index ] )
				iconElems[ index ].Show()
				iconElems[ index ].FadeOverTime( 255, 0.1 )

				// store all the offsets so when they scroll they can maintain it
				this.elemOffsetsX[ index ] <- OffsetX
			}

			// update the color for this group
			local color = StringToColors( textGroupColors[ index ] )
			local hudGroupElems = hudGroup.GetElements()
			local i = 0
			foreach( elem in hudGroupElems )
			{
				elem.SetColor( color.r, color.g, color.b, color.a )
			}

			// show the text for this group

			if ( textGroupBrackets[ index ] )
			{
				//hudGroup.SetTextTypeWriter( "#OBIT_BRACKETED_STRING", textGroupStrings[ index ], typeWriterDuration )
				hudGroup.SetText( "#OBIT_BRACKETED_STRING", textGroupStrings[ index ] )
				//hudGroup.SetText( textGroupStrings[ index ] )
			}
			else
			{
				//hudGroup.SetTextTypeWriter( textGroupStrings[ index ], typeWriterDuration )
				hudGroup.SetText( textGroupStrings[ index ], textGroupStringsVar1[ index ] )
			}
		}

		// space between words
		local wordSpacing = 2 * GetContentScaleFactor()[0]
		local widthRight
		local widthCenter
		local widthLeft

		if ( this.formattingType != "none" )
		{
			Assert( leftElem )
			Assert( centerElem )
			Assert( rightElem )

			widthLeft = hudGroups[ leftElem ].GetTextWidth().tofloat()
			widthCenter = hudGroups[ centerElem ].GetTextWidth().tofloat()
			widthRight = hudGroups[ rightElem ].GetTextWidth().tofloat()

			widthLeft *= scale
			widthCenter *= scale
			widthRight *= scale

			wordSpacing *= scale / 2
		}

		if ( this.formattingType == "center" )
		{
			hudGroups[ leftElem ].OffsetX( -( widthCenter * 0.5 ) - wordSpacing )
			hudGroups[ rightElem ].OffsetX( ( widthCenter * 0.5 ) + wordSpacing )
		}
		else if ( this.formattingType == "left" )
		{
			hudGroups[ centerElem ].OffsetX( widthLeft + wordSpacing )
			hudGroups[ rightElem ].OffsetX( widthLeft + widthCenter + ( wordSpacing * 2.0 ) )
		}
		else if ( this.formattingType == "right" )
		{
			hudGroups[ centerElem ].OffsetX( -widthRight - wordSpacing )
			hudGroups[ leftElem ].OffsetX( -widthRight - widthCenter - ( wordSpacing * 2.0 ) )
		}

		// Flares
		foreach( index, hudGroup in hudGroups )
		{
			if ( this.flareElems[index] == null )
				continue

			local textWidth = hudGroup.GetTextWidth()
			this.flareElems[index].ReturnToBaseSize()
			this.flareElems[index].SetBaseSize( textWidth.tofloat() * 3.0, this.flareElems[index].GetHeight() )
			this.flareElems[index].SetBasePos( ( hudGroup.GetWidth() / 2.0 ) - ( textWidth / 2.0 ), 0 )
			thread DoFlare( this.flareElems[index] )
		}

		// Show it and fade it out
		foreach( index, hudGroup in hudGroups )
			hudGroup.Show()

		masterGroup.FadeOverTimeDelayed( 0, fadeOutDuration, fadeDelay )
	}
	
	function UpdateTextDisplay()
	{
		foreach( index, hudGroup in hudGroups )
		{
			Assert( index in textGroupStrings )
			Assert( index in textGroupColors )

			if ( textGroupBrackets[ index ] )
				hudGroup.SetText( "#OBIT_BRACKETED_STRING", textGroupStrings[ index ], textGroupStringsVar1[ index ]  )
			else
				hudGroup.SetText( textGroupStrings[ index ], textGroupStringsVar1[ index ] )
			
			local color = StringToColors( textGroupColors[ index ] )
			hudGroup.SetColor( color.r, color.g, color.b, color.a )
				
			if( this.flareElems[index] != null )
				this.flareElems[index].Hide()

			local updatedDuration = max( 0, duration + startTime - Time()  )
			local updatedFadeOutDuration = min( fadeOutDuration, updatedDuration )
			local updatedFadeDelay = updatedDuration - updatedFadeOutDuration
						
			hudGroup.FadeOverTimeDelayed( 0, updatedFadeOutDuration, updatedFadeDelay )
		}
	}

	function DoFlare( flare )
	{
		Signal( flare, "FlareStart" )
		EndSignal( flare, "FlareStart" )

		flare.SetAlpha( 200 )
		flare.SetScale( 1.3, 1.3 )
		flare.Show()
		wait 0.25

		// normal size and brightness
		flare.ScaleOverTime( 0.25, 0.25, 1.0 )
		flare.FadeOverTime( 0, 0.5 )
	}
}