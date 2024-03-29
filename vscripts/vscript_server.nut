//========== Copyright � 2008, Valve Corporation, All rights reserved. ========
__uniqueStringId <- 0

function UniqueString( string = "" )
{
	return string + "_us" + __uniqueStringId++;
	
//	return DoUniqueString( string.tostring() );
}

function EntFire( target, action, value = null, delay = 0.0, activator = null )
{
	if ( !value )
	{
		value = "";
	}
	
	local caller = null;
	if ( "self" in this )
	{
		caller = self;
		if ( !activator )
		{
			activator = self;
		}
	}
	
	DoEntFire( target.tostring(), action.tostring(), value.tostring(), delay, activator, caller ); 
}

function __ReplaceClosures( script, scope )
{
	if ( !scope )
	{
		scope = getroottable();
	}
	
	local tempParent = { getroottable = function() { return null; } };
	local temp = { runscript = script };
	delegate tempParent : temp;
	
	temp.runscript()
	foreach( key,val in temp )
	{
		if ( typeof(val) == "function" && key != "runscript" )
		{
			printl( "   Replacing " + key );
			scope[key] <- val;
		}
	}
}

/*
UNDONE FOR PORTAL2 BRANCH:
We're not suing the auto-connecting of outputs, always calling ConnectOuput explicitly in our scripts.
The regexp object doesn't save/load properly and causes a crash when used to match after a save/load.
Instead of fixing this, we're disabling the feature. If this class of problem comes up more we might
revisit, otherwise we'll leave if off and broken.

__OutputsPattern <- regexp("^On.*Output$");

function ConnectOutputs( table )
{
	const nCharsToStrip = 6;
	foreach( key, val in table )
	{
		if ( typeof( val ) == "function" && __OutputsPattern.match( key ) )
		{
			//printl(key.slice( 0, nCharsToStrip ) );
			table.self.ConnectOutput( key.slice( 0, key.len() - nCharsToStrip ), key );
		}
	}
}
*/

function IncludeScript( name, scope = null )
{
	if ( scope == null )
	{
		scope = this;
	}
	return ::DoIncludeScript( name, scope );
}

//---------------------------------------------------------
// Text dump this scope's contents to the console.
//---------------------------------------------------------
function __DumpScope( depth, table )
{
	local indent=function( count )
	{
		local i;
		for( i = 0 ; i < count ; i++ )
		{
			print("   ");
		}
	}
	
    foreach(key, value in table)
    {
		indent(depth);
		print( key );
        switch (type(value))
        {
            case "table":
				print("(TABLE)\n");
				indent(depth);
                print("{\n");
                __DumpScope( depth + 1, value);
				indent(depth);
                print("}");
                break;
            case "array":
				print("(ARRAY)\n");
				indent(depth);
                print("[\n")
                __DumpScope( depth + 1, value);
				indent(depth);
                print("]");
                break;
            case "string":
                print(" = \"");
                print(value);
                print("\"");
                break;
            default:
                print(" = ");
                print(value);
                break;
        }
        print("\n");  
	}
}
