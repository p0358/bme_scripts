//========== Copyright © 2008, Valve Corporation, All rights reserved. ========
__uniqueStringId <- 0

function UniqueString( string = "" )
{
	return string + "_us" + __uniqueStringId++;
//	return DoUniqueString( string.tostring() );
}

function IncludeScript( name, scope = null )
{
	if ( scope == null )
	{
		scope = this;
	}
	return ::DoIncludeScript( name, scope );
}
