//=========================================================
//	_template_registry
//  
//=========================================================
const maxTemplates = 16 // must match value in code

__templateRegistry <- {}

// --------------------------------------------------------
// Spawns the named entity at the specified origin
// --------------------------------------------------------
function SpawnFromTemplateOld( entityName, origin = null )
{
	if ( !(entityName in __templateRegistry ) )
	{
		printl( "SpawnFromTemplateOld: template entity named " + entityName + " not found!" )
		return;
	}

	// Get the point_template associated with this entity name and spawn the entity
	local pointTemplate = __templateRegistry[entityName]
	local entity = pointTemplate.GetScriptScope().SpawnEntityAtOrigin( entityName, origin )
	
	return entity
}

// --------------------------------------------------------
function __RegisterTemplate( owner, entityName )
{
	Assert( owner.GetClassname() == "point_template" )
	Assert( !(entityName in __templateRegistry ) )
	
	__templateRegistry[entityName] <- owner
}

// --------------------------------------------------------
function __RegisterTemplates( owner )
{
	for ( local i = 1; i <= maxTemplates; i++ )
	{
		local keyName = "Template"

		if ( i < 10 )
			keyName += ("0" + i)
		else
			keyName += i
		
		local templateName = self.GetValueForKey( keyName )
		
		if ( templateName.len() == 0 )
			continue;
			
		__RegisterTemplate( owner, templateName )
	}
}

