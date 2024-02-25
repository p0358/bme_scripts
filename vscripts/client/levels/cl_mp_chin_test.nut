function main()
{
	level.bishJumpOffRef <- null
	level.macWalkStraightfRef <- null
	level.macWalkFightRef <- null
	level.macWalkFight2Ref <- null
}

function EntitiesDidLoad()
{
	local targets = GetClientEntArrayBySignifier( "info_target" )

	printt("targets.len() : " + targets.len())

	local customRef
	local animRef

	foreach ( target in targets )
	{
		/*if ( target.GetName() == "vdu_info_1" )
		{
			customRef = target
			continue
		}*/

		if ( target.GetName() == "vdu_info_anim_ref" )
		{
			level.bishJumpOffRef = target
			continue
		}

		if ( target.GetName() == "vdu_info_walk" )
		{
			level.macWalkStraightfRef = target
			continue
		}

		if ( target.GetName() == "vdu_info_fight" )
		{
			level.macWalkFightRef = target
			continue
		}

		if ( target.GetName() == "vdu_info_fight2" )
		{
			level.macWalkFight2Ref = target
			continue
		}

	}


}