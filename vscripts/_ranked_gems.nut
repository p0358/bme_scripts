function main()
{
	Globalize( GetGemsForRank )
	Globalize( GetMinGemsForRank )
	Globalize( GetPlayerPerformanceGoals )
	Globalize( GetPreviousPlayerPerformanceGoals )
	Globalize( GetGemsToRank )
	Globalize( GetMaxGems )
	Globalize( GetPerformanceReqForGem )
	Globalize( GetMaxGemsForRank )
	Globalize( GetMaxGemsPerMatch )

	file.gemsPerRank <- CreateGemsPerRank()
	file.rankFromGemCount <- CreateRankFromGemCount()
	file.gemGoals <- FillGoalsForGems()
}

function GetGemsToRank( gems )
{
	if ( gems >= file.rankFromGemCount.len() )
		return file.rankFromGemCount.top()
	return file.rankFromGemCount[ gems ]
}

function GetGemsForRank( rank )
{
	if ( rank >= file.gemsPerRank.len() )
		return file.gemsPerRank.top().count

	return file.gemsPerRank[ rank ].count
}

function GetMinGemsForRank( rank )
{
	if ( rank >= file.gemsPerRank.len() )
		return file.gemsPerRank.top().min

	return file.gemsPerRank[ rank ].min
}

function GetMaxGemsForRank( rank )
{
	if ( rank >= file.gemsPerRank.len() )
		return file.gemsPerRank.top().max

	return file.gemsPerRank[ rank ].max
}

function CreateGemsPerRank()
{
	// create file.gemsPerRank, the number of gems required for each rank, indexed by rank.
	local gemsPerRank = []

	// bronze
	local count = 5
	local min = 0
	for ( local i = 0; i < 5; i++ )
	{
		gemsPerRank.append( { count = count, min = min, max = min + count } )
		min += count
	}

	// silver
	local count = 6
	for ( local i = 0; i < 5; i++ )
	{
		gemsPerRank.append( { count = count, min = min, max = min + count } )
		min += count
	}

	// gold
	local count = 6
	for ( local i = 0; i < 5; i++ )
	{
		gemsPerRank.append( { count = count, min = min, max = min + count } )
		min += count
	}

	// plat, diamond
	local count = 5
	for ( local i = gemsPerRank.len(); i <= MAX_RANK; i++ )
	{
		gemsPerRank.append( { count = count, min = min, max = min + count } )
		min += count
	}

	return gemsPerRank
}

function CreateRankFromGemCount()
{
	// create file.rankFromGemCount. Indexed by number of gems, returns rank for that gem count.
	local gemsToRank = []

	for ( local i = 0; i < file.gemsPerRank.len(); i++ )
	{
		local gems = file.gemsPerRank[i]
		for ( local p = 0; p < gems.count; p++ )
		{
			gemsToRank.append( i )
		}
	}

	return gemsToRank
}

function GetMaxGemsPerMatch()
{
	return 5
}

function FillGoalsForGems()
{
	// create file.gemGoals, an array of performance goals indexed by gem count
	local gemGoals = []

	local allGemMapping = GetGemGoalGraphs()
	local total = 0
	local max = GetMaxGems()
	local lastMax = 0
	local lastGemMap = null

	local gemMapIndex = 0

	for ( ;; )
	{
		local gemMap = allGemMapping[ gemMapIndex ]
		if ( total >= max )
			break

		if ( total >= gemMap.max )
		{
			lastGemMap = gemMap
			lastMax = gemMap.max
			gemMapIndex++
			if ( gemMapIndex >= allGemMapping.len() )
				break

			continue
		}

		local goals = []
		foreach ( index, map in gemMap.mapping )
		{
			local goal = Graph( total, lastMax, gemMap.max, lastGemMap.mapping[index], map )
			if ( goal >= 1.0 )
				break
			goal = SkillToPerformance( goal ).tointeger()
			if ( goals.len() && goal == goals.top() )
				break

			goals.append( goal )
		}

		gemGoals.append( goals )
		total++
	}

	return gemGoals
}

function GetPlayerPerformanceGoals( player = null )
{
	return GetPerformanceReqForGem( GetPlayerTotalCompletedGems( player ) )
}

function GetPreviousPlayerPerformanceGoals( player = null )
{
	return GetPerformanceReqForGem( GetPreviousPlayerTotalCompletedGems( player ) )
}


function GetGemGoalGraphs()
{
	local mappings = []

	//////////////////////////////////////////////////////////////////////
	// bronze
	//////////////////////////////////////////////////////////////////////
	local map = {}
	mappings.append( map )
	map.max <- GetMinGemsForRank( 0 )
	Assert( map.max == 0 )
	map.mapping <- [
	 0.04
	 0.09
	 0.14
	 0.19
	 0.24
	]

	local map = {}
	mappings.append( map )
	map.max <- GetMinGemsForRank( 1 )
	map.mapping <- [
	 0.06
	 0.13
	 0.20
	 0.27
	 0.34
	]

	local map = {}
	mappings.append( map )
	map.max <- GetMaxGemsForRank( 4 )
	map.mapping <- [
	 0.19
	 0.35
	 0.50
	 0.75
	 0.80
	]

	//////////////////////////////////////////////////////////////////////
	// silver
	//////////////////////////////////////////////////////////////////////
	local map = {}
	mappings.append( map )
	map.max <- GetMinGemsForRank( 5 )
	map.mapping <- [
	 0.22
	 0.38
	 0.53
	 0.76
	 0.85
	]

	local map = {}
	mappings.append( map )
	map.max <- GetMaxGemsForRank( 9 )
	map.mapping <- [
	 0.44
	 0.54
	 0.64
	 0.77
	 0.88
	]

	//////////////////////////////////////////////////////////////////////
	// gold
	//////////////////////////////////////////////////////////////////////
	local map = {}
	mappings.append( map )
	map.max <- GetMinGemsForRank( 10 )
	map.mapping <- [
	 0.47
	 0.57
	 0.68
	 0.82
	 0.94
	]

	local map = {}
	mappings.append( map )
	map.max <- GetMaxGemsForRank( 14 )
	map.mapping <- [
	 0.58
	 0.66
	 0.83
	 0.94
	 1.02
	]


	//////////////////////////////////////////////////////////////////////
	// platinum
	//////////////////////////////////////////////////////////////////////
	local map = {}
	mappings.append( map )
	map.max <- GetMinGemsForRank( 15 )
	map.mapping <- [
	 0.61
	 0.86
	 0.95
	 1.02
	 1.08
	]

	local map = {}
	mappings.append( map )
	map.max <- GetMaxGemsForRank( 19 )
	map.mapping <- [
	 0.83
	 0.95
	 1.02
	 1.04
	 1.13
	]

	//////////////////////////////////////////////////////////////////////
	// diamond
	//////////////////////////////////////////////////////////////////////
	local map = {}
	mappings.append( map )
	map.max <- GetMinGemsForRank( 20 )
	map.mapping <- [
	 0.86
	 0.98
	 1.02
	 1.12
	 1.22
	]

	local map = {}
	mappings.append( map )
	map.max <- GetMaxGemsForRank( 24 )
	Assert( map.max == GetMaxGems() )
	map.mapping <- [
	 0.99
	 1.06
	 1.16
	 1.26
	 1.36
	]

	return mappings
}

function GetPerformanceReqForGem( total )
{
	if ( total >= file.gemGoals.len() )
		return file.gemGoals.top()

	return file.gemGoals[ total ]
}

function devperfcheck()
{
	local max = GetMaxGems()
	for ( local i = 0; i < max; i++ )
	{
		local vals = {}
		local reqs = GetPerformanceReqForGem( i )
		print( "Reqs for " + i + ": " )
		foreach ( req in reqs )
		{
			print( format( "%.1f", req ) + " " )

			Assert( !( req in vals ) )
			vals[req] <- true
		}
		print( "\n" )
	}
}
Globalize( devperfcheck )

function GetMaxGems()
{
	return file.rankFromGemCount.len()
//	return PersistenceGetArrayCount( "ranked.gems" )
}


function devnummatches( skill, print = true )
{
	local perf = SkillToPerformance( skill )
	if ( print )
		printt( "Calculating number of matches for performance " + perf )

	local totalGems = 0
	local totalMatches = 0
	local max = GetMaxGems()
	local maxGemsPerMatch = GetMaxGemsPerMatch()
	local matchesPerGrouping = {}
	for ( local i = 1; i <= maxGemsPerMatch; i++ )
	{
		matchesPerGrouping[i] <- 0
	}

	local debug = false // per match info

	for ( ;; )
	{
		if ( debug )
			printt( "Match " + totalMatches )
		local goals = GetPerformanceReqForGem( totalGems )
		local oldTotal = totalGems
		local gemsThisMatch = 0
		for ( local i = 0; i < goals.len(); i++ )
		{
			if ( perf > goals[i] )
			{
				if ( debug )
					printt( "	Goal " + goals[i] )
				totalGems++
				gemsThisMatch++
			}
			else
			{
				if ( debug )
					printt( "	Fail-Goal " + goals[i] )
			}

			if ( totalGems >= max )
				break
		}

		if ( gemsThisMatch > 0 )
			matchesPerGrouping[ gemsThisMatch ]++
		totalMatches++


		if ( debug )
			printt( " " )

		// didn't advance
		if ( oldTotal == totalGems )
			break
		if ( totalGems >= max )
			break
	}

	local rank = GetGemsToRank( totalGems )
	if ( print )
		printt( "Total matches for perf " + perf + ": " + totalMatches + ". Rank " + rank )
	for ( local i = maxGemsPerMatch; i > 0; i-- )
	{
		local num = i
		local grouping = matchesPerGrouping[ num ]
		if ( print )
			printt( "Total matches earned " + num + " gems: " + grouping )
	}

	return rank
}
Globalize( devnummatches )

function devranktotals()
{
	local ranks = {}
	for ( local i = 0.0; i < 1.0; i += 0.01 )
	{
		local rank = devnummatches( i )
		local division = (rank / 5).tointeger()
		if ( !( division in ranks ) )
			ranks[ division ] <- 0

		ranks[ division ]++
	}

	foreach ( rank, count in ranks )
	{
		printt( "Rank " + rank + " count " + count )
	}
}
Globalize( devranktotals )

function devrecalcranks()
{
	file.gemsPerRank <- CreateGemsPerRank()
	file.rankFromGemCount <- CreateRankFromGemCount()
	file.gemGoals <- FillGoalsForGems()
}
Globalize( devrecalcranks )