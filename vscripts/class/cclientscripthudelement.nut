CClientHudElement._name <- null // TMP: should be code
CClientHudElement._displayName <- null
CClientHudElement.s <- null
CClientHudElement.childElements <- null
CClientHudElement.classElements <- null
CClientHudElement.loadoutID <- null
CClientHudElement.loadoutIDBeingEdited <- null
CClientHudElement._parentMenu <- null // TMP: should be code
CClientHudElement._panelAlpha <- null
CClientHudElement._type <- null
CClientHudElement._page <- null

function CClientHudElement::constructor()
{
	this.s = {}
	this.childElements = {}
	this.classElements = {}
	this._panelAlpha = 255
	this._type = "default"
}

// TMP: should be code
function CClientHudElement::GetParentMenu()
{
	return this._parentMenu
}

// TMP: should be code
function CClientHudElement::SetParentMenu( parentMenu )
{
	this._parentMenu = parentMenu
}

function CClientHudElement::SetType( elemType )
{
	this._type = elemType
}

function CClientHudElement::GetType()
{
	return this._type
}

function CClientHudElement::HasPages()
{
	if ( this._page != null )
		return true

	return false
}

function CClientHudElement::SetPage( name )
{
	this._page = name
}

function CClientHudElement::GetPage()
{
	return this._page
}

function CClientHudElement::NavigateBack()
{
	if ( this._page == "mods" )
	{
		if ( ItemAttachmentsExist( uiGlobal.parentItemBeingEdited ) )
			ChangePage( "attachments" )
		else
			ChangePage( "weapons" )
	}
	else if ( this._page == "attachments" )
	{
		ChangePage( "weapons" )
	}
	else
		::CloseSubmenu()
}

CClientHudElement.CodeGetName <- CClientHudElement.GetName // TMP: should be code
function CClientHudElement::GetName() // TMP: should be code
{
	if ( this._name == null )
		return CodeGetName()

	return this._name
}

function CClientHudElement::SetName( elemName ) // TMP: should be code
{
	this._name = elemName
}

function CClientHudElement::SetDisplayName( name )
{
	this._displayName = name
}

function CClientHudElement::GetDisplayName()
{
	return this._displayName
}

function CClientHudElement::EndSignal( signalID )
{
	::EndSignal( this, signalID )
}

function CClientHudElement::Signal( signalID, results = null )
{
	::Signal( this, signalID, results )
}

function CClientHudElement::FadePanelOverTime( alpha, duration )
{
	FadePanelOverTimeDelayed( alpha, duration, 0.0 )
}

function CClientHudElement::FadePanelOverTimeDelayed( alpha, duration, delay )
{
	this.RunAnimationCommand( "Alpha", alpha, delay, duration, INTERPOLATOR_LINEAR, 0.0 )
}

CClientHudElement.CodeGetChild <- CClientHudElement.GetChild
function CClientHudElement::GetChild( elemName )
{
	if ( !(elemName in this.childElements) )
		this.childElements[elemName] <- this.CodeGetChild( elemName )

	return this.childElements[elemName]
}