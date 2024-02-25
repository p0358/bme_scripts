function main()
{
	if ( GetCinematicMode() && IsCaptureMode() )
		HardpointDialogOverride()

	RegisterConversation( "matchIntro", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Blurb_1_Militia_Lead", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Blurb_2_Militia_Lead", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Blurb_3_Militia_Lead", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Blurb_4_Militia_Lead", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Blurb_1_IMC_Lead", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Blurb_2_IMC_Lead", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Blurb_3_IMC_Lead", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Blurb_4_IMC_Lead", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "MilitiaWin", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "IMCWin", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "epilogue_mid_militia_win", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "epilogue_mid_imc_win", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "post_epilogue_win", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "post_epilogue_loss", VO_PRIORITY_GAMESTATE )

	//AI Chatter
	RegisterConversation( "boneyard_grunt_chatter", VO_PRIORITY_AI_CHATTER_LOW )
	RegisterConversation( "boneyard_grunt_chatter_after_pulse", VO_PRIORITY_AI_CHATTER_LOW )

	if ( IsServer() )
		return

	RegisterSignal( "StopCustomVDU" )

	Globalize( FirstPulseVDUThread )
	Globalize( FirstBlurbIMCLeadVDUThread )
	Globalize( SecondPulseVDUThread )
	Globalize( ForcedPulseIMCLeadVDUThread )
	Globalize( ThirdPulseVDUThread )
	Globalize( ThirdPulseIMCVDUThread )


	BoneyardAIChatter()
	BoneyardDialog()
}

///////////////////////////////////////////////////////////////////
function BoneyardDialog()
{
	local convRef

	/***************************************/
	/***********  TEAM MILITIA  ************/
	/***************************************/

	// INTRO
	// Barker:	All dropships - prepare for the last jump in 5, 4, 3, 2, 1, mark!
	// Barker:	You know, Mac, the tower here hasn’t worked in 20 years! You sure about this?
	// MAC:		It’s our best chance to figure out how to shut these towers down!  Pilots! Take the hardpoints, and get Bish connected to the IMC network! Ready up!
	convRef = AddConversation( "matchIntro", TEAM_MILITIA )
	AddRadio( convRef, "diag_matchIntro_BY301_01_01_mcor_barker" )
	AddRadio( convRef, "dropship_warpin" )
	// Additional lines played from inside intro animations

	// BLURB #1 - Militia lead
	// BISH:	Tapped in, downloading operational history and running a systems analysis…we’re at 25%. Got some damaged circuits, but everything was still fully operational up until 20 years ago.
	// PULSE VDU
	// SARAH:	What was that? Pulse wave just rolled through. Effects are fading.
	// MAC:		You do that Bish?
	// BISH:	Yeah, the power circuits are kinda sketchy, but I had to see if they still worked. Lemme see if I can do it again in a bit.
	convRef = AddConversation( "Blurb_1_Militia_Lead", TEAM_MILITIA )
	AddRadio( convRef,						"diag_story25Mil_BY303_01a_01_mcor_bish", -4 )
	AddCustomVDUFunction( convRef,	FirstPulseVDU )
	AddWait( convRef, 8.5 )
	AddVDURadio( convRef, "sarah",	null,	"diag_story25Mil_BY303_02_01_mcor_sarah" )
	AddVDUHide( convRef )
	AddVDURadio( convRef, "mac",			"diag_story25Mil_BY303_03_01_mcor_macal" )
	AddVDURadio( convRef, "bish",			"diag_story25Mil_BY303_04a_01_mcor_bish" )

	// BLURB #2 - Militia lead - optional
	// BISH:	Ok, good news, I’m at 35% on my scan of the tower. I’m gonna fire off a pulse to check my data, standby.
	// PULSE
	// BISH:	Great, we’re on track guys, but we have a ways to go. Keep me patched into those hardpoints!
	convRef = AddConversation( "Blurb_2_Militia_Lead", TEAM_MILITIA )
	AddRadio( convRef,				"diag_story35Mil_BY321_01_01_mcor_bish", -3 )
	AddCustomVDUFunction( convRef,	FirstPulseVDU )
	AddWait( convRef, 8 )
	AddVDURadio( convRef, "bish",	"diag_story35Mil_BY321_02_01_mcor_bish" )

	// BLURB #3 - Militia lead
	// BISH:	Ok, tower systems analysis is at 50%! I’m gonna trigger another pulse. Reverb profiling should help us reverse engineer the pulse wave’s signature.
	// MAC:		Bish, what are you talking about?
	// SARAH:	Like measuring acoustics in a concert hall, Mac. You never played an instrument?
	// MAC:		Nope. Just Titans.
	// PULSE VDU
	convRef = AddConversation( "Blurb_3_Militia_Lead", TEAM_MILITIA )
	AddRadio( convRef,				"diag_story50Mil_BY304_01a_01_mcor_bish" )
	AddWait( convRef, 0.5 )
	AddCustomVDUFunction( convRef,	SecondPulseVDU )
	AddVDURadio( convRef, "mac",	"diag_story50Mil_BY304_02a_01_mcor_macal" )
	AddWait( convRef, 10 )	// VDU will close early

	// BLURB #4 - Militia lead
	// BISH:	Ok guys, we’re at 80% on my tower analysis. I’m configuring a patch to measure the pulses. Here comes another one.
	// PULSE VDU flowing into flyer VDU
	// SARAH:	The Leviathans and Flyers retreat with each pulse, Bish. An on/off switch would be killer.
	// BISH:	Like an icepick to the forehead. I’m gonna try to bring it to full power one last time to confirm my findings.
	convRef = AddConversation( "Blurb_4_Militia_Lead", TEAM_MILITIA )
	AddRadio( convRef,						"diag_story75Mil_BY305_01a_01_mcor_bish", -3 )
	AddCustomVDUFunction( convRef,	ThirdPulseVDU )
	AddWait( convRef, 7 )
	AddVDURadio( convRef, "sarah",			"diag_story75Mil_BY305_02_01_mcor_sarah" )
	AddVDURadio( convRef, "bish",	null,	"diag_story75Mil_BY305_03_01_mcor_bish" )

	// BLURB #1 - IMC lead
	// VDU of tower followed by the hardpoints
	// BISH:	Mac, we got a problem - the IMC are overloading the tower’s reactor through the hardpoints, and it’s interfering with my access to the tower’s systems.
	// MAC:		Got it Bish. Pilot, the IMC are trying to scuttle the base. Get control of the hardpoints, so Bish can complete his analysis of the tower. Let’s step it up!
	convRef = AddConversation( "Blurb_1_IMC_Lead", TEAM_MILITIA )
	AddCustomVDUFunction( convRef,	FirstBlurbIMCLeadVDU )
	AddVDURadio( convRef, "bish",	"diag_story25imc_BY320_01_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_story25imc_BY320_02_01_mcor_macal" )
	AddWait( convRef, 5 )	// VDU will close early

	// BLURB #2 - IMC lead - optional
	// BISH:	Mac, I’m gonna try to send a pulse through the tower and record the data. Here goes nothing…
	// PULSE - then cycle through the hardpoints on the VDU
	// MAC:		You get anything from that, Bish?
	// BISH:	Better than nothing, but the scan is going slow - IMC activity at the hardpoints is messing with the signal.
	// MAC:		You heard him, Pilot. Let’s help him out. Take those hardpoints!
	convRef = AddConversation( "Blurb_2_IMC_Lead", TEAM_MILITIA )
	AddRadio( convRef,				"diag_story35imc_BY323_01_01_mcor_bish", -3 )
	AddCustomVDUFunction( convRef,	ForcedPulseIMCLeadVDU )
	AddWait( convRef, 6 )
	AddVDURadio( convRef, "mac",	"diag_story35imc_BY323_02_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_story35imc_BY323_03_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_story35imc_BY323_04_01_mcor_macal" )
	AddWait( convRef, 2 ) 	// VDU will close early

	// BLURB #3 - IMC lead
	// BISH:	Uh, Mac, pressure in the tower’s reactor core is about halfway to critical. They’re drawin’ a lotta juice from the system and it’s slow going on my end. Can we do something about this, like now?
	// MAC:		Team, we need to buy Bish more time to analyze the tower. Get control of the hardpoints A-SAP!
	convRef = AddConversation( "Blurb_3_IMC_Lead", TEAM_MILITIA )
	AddVDURadio( convRef, "bish",			"diag_story50imc_BY326_01_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	null,	"diag_story50imc_BY326_02_01_mcor_macal" )

	// BLURB #4 - IMC lead
	// BISH:	Mac, it’s going to be hard to find a weakness in the tower without more data. But the tower’s reactor pressure is still going up, and all the interference is slowing me down!
	// MAC:		Pilots, capture and hold those hardpoints! We’re cuttin’ it close out there - let’s get Bish what he needs!
	convRef = AddConversation( "Blurb_4_IMC_Lead", TEAM_MILITIA )
	AddRadio( convRef,						"diag_story75imc_BY328_01_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	null,	"diag_story75imc_BY328_02_01_mcor_macal" )

	// Militia WIN
	// BISH:	Mac, I’ve got all the data! I’m gonna pulse the tower one more time to make sure the numbers work out.
	convRef = AddConversation( "MilitiaWin", TEAM_MILITIA )
	AddRadio( convRef,				"diag_milWinAnnc_BY309_01_01_mcor_bish", -2 )
	AddCustomVDUFunction( convRef,	ForthPulseVDUMilitia )

	// IMC WIN
	// SARAH:	All units, we have to scrub the mission - I’m detecting a massive power spike in the core; it’s about to go critical!
	// SARAH:	Pilots, they’re scuttling the base! Stay clear of any interiors! Detonation in 3…2…1…mark!
	convRef = AddConversation( "IMCWin", TEAM_MILITIA )
	AddVDURadio( convRef, "sarah",			"diag_imcWinAnnc_BY314_01_01_mcor_sarah" )
	AddWait( convRef, 2.5 )	// time so that countdown stops when the base explodes
	AddVDURadio( convRef, "sarah",	null,	"diag_milLoseAnnc_BY314_02a_01_mcor_sarah" )

	// MID EPILOGUE - Militia WIN
	// MAC:		Bish, did you get everything you needed?
	// BISH:	Hell yeah, Mac. This is exactly what I’ve been looking for. Building a bypass for these towers should be child’s play.
	// SARAH:	All right Pilots, we’ve won and the IMC are trying to retreat. Take ‘em out. Good hunting.
	convRef = AddConversation( "epilogue_mid_militia_win", TEAM_MILITIA )
	AddVDURadio( convRef, "mac",	"diag_epMid_milWin_BY311_01_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_epMid_milWin_BY311_02_01_mcor_bish" )
	AddVDURadio( convRef, "sarah",	"diag_epMid_milWin_BY311_03_01_mcor_sarah" )

	// MID EPILOGUE - IMC WIN
	// SARAH:	Well I hope we got something useful…all pilots head for the evac point. Move.
	// MAC:		Bish, tell me it wasn’t a complete loss…
	// BISH:	Well…we got a lot of data, but it’s gonna take a while to sift through it all.
	// MAC:		We’ll make it work, Bish. We always do.
	convRef = AddConversation( "epilogue_mid_imc_win", TEAM_MILITIA )
	AddVDURadio( convRef, "sarah",	"diag_epMid_milLose_BY316_01_01_mcor_sarah" )
	AddVDURadio( convRef, "mac",	"diag_epMid_milLose_BY316_02_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_epMid_milLose_BY316_03_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_epMid_milLose_BY316_04_01_mcor_macal" )

	// POST EPILOGUE - Militia WIN
	// SARAH:	Mac, how the hell did the IMC know we were gonna be here?
	// MAC:		Graves and I ran war games fifteen years ago. How we’d fight if we were on the other side…
	// BISH:	Great. Who won the most?
	// MAC:		It was even.. This war’s gonna be the tiebreaker.
	convRef = AddConversation( "post_epilogue_win", TEAM_MILITIA )
	AddVDURadio( convRef, "sarah",	"diag_epPostMil_BY317_01_01_mcor_sarah" )
	AddVDURadio( convRef, "mac",	"diag_epPostMil_BY317_02_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_epPostMil_BY317_03_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_epPostMil_BY317_04_01_mcor_macal" )

	// POST EPILOGUE - IMC WIN
	// SAME AS ABOVE
	convRef = AddConversation( "post_epilogue_loss", TEAM_MILITIA )
	AddVDURadio( convRef, "sarah",	"diag_epPostMil_BY317_01_01_mcor_sarah" )
	AddVDURadio( convRef, "mac",	"diag_epPostMil_BY317_02_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_epPostMil_BY317_03_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_epPostMil_BY317_04_01_mcor_macal" )








	/***************************************/
	/*************  TEAM IMC  **************/
	/***************************************/

	// INTRO
	// BLISK:	Pilots, we got word the Militia are trying to reverse engineer our repulsor technology!
	// BLISK:	The old tower here was our prototype! Became the key advantage in colonizing worlds with hostile indigenous creatures. Our objective is to scuttle this facility before the Militia learns too much about the tower.
	// BLISK:	Patch me into the hardpoints, and we’ll overload the core! That should do the trick. Ready up!
	convRef = AddConversation( "matchIntro", TEAM_IMC )
	AddVDURadio( convRef, "blisk",		"diag_matchIntro_BY302_01_01_imc_blisk" )
	// Additional lines played from inside intro animation

	// BLURB #1 - Militia lead
	// SPYGLASS:	Sir, I’ve detected a power surge in the repulsor tower. Someone is
	// PULSE
	// BLISK:		Whoa! Tower just pulsed, Spyglass. She ain’t supposed to do that.
	// SPYGLASS:	Possible Militia interference. Standby, performing analysis of the tower’s system.
	convRef = AddConversation( "Blurb_1_Militia_Lead", TEAM_IMC )
	AddCustomVDUFunction( convRef,	FirstPulseVDU )
	AddWait( convRef, 4.0 )
	AddRadio( convRef,						"diag_story25Mil_BY306_01_01_imc_spygl" )
	AddWait( convRef, 2 )
	AddCustomVDUFunction( convRef,	StopCustomVDU )
	AddVDURadio( convRef, "blisk",	null,	"diag_story25Mil_BY306_02_01_imc_blisk" )
	AddVDUHide( convRef )
	AddVDURadio( convRef, "spyglass",		"diag_story25Mil_BY306_03_01_imc_spygl" )

	// BLURB #2 - Militia lead - optional
	// SPYGLASS:	All units, I am detecting a power surge at the tower. Brace for heavy interference.
	// PULSE
	// BLISK:		Spyglass! Find out what caused that pulse - I don’t like surprises!
	convRef = AddConversation( "Blurb_2_Militia_Lead", TEAM_IMC )
	AddCustomVDUFunction( convRef,	FirstPulseVDU )
	AddWait( convRef, 2 )
	AddVDURadio( convRef, "spyglass",	"diag_story35Mil_BY322_01_01_imc_spygl" )
	AddWait( convRef, 3 )
	AddVDURadio( convRef, "blisk",		"diag_story35Mil_BY322_02_01_imc_blisk" )

	// BLURB #3 - Militia lead
	// BLISK:		There she blows! You figured that out yet, Spyglass?
	// SPYGLASS:	The Militia are causing the pulses intentionally, to analyze the tower’s vulnerabilities. Whoever is behind this strategy is surprisingly clever for a human.
	// BLISK:		Yeah, well if you can detect when the next one’s coming, a little heads-up would be nice.
	convRef = AddConversation( "Blurb_3_Militia_Lead", TEAM_IMC )
	AddCustomVDUFunction( convRef,	SecondPulseVDU )
	AddWait( convRef, 9 )
	AddVDURadio( convRef, "blisk",		"diag_story50Mil_BY307_02_01_imc_blisk" )
	AddVDURadio( convRef, "spyglass",	"diag_story50Mil_BY307_03_01_imc_spygl" )
	AddVDURadio( convRef, "blisk",		"diag_story50Mil_BY307_04_01_imc_blisk" )

	// BLURB #4 - Militia lead
	// SPYGLASS: 	Sergeant Blisk, Militia power rerouting detected. This is your…
	// PULSE
	// SPYGLASS:	…Warning.  The Militia analysis of the tower is progressing faster than we can overload the core.
	// BLISK:		Pilots, get those hardpoints under control! Let’s turn it around! Blisk out.
	convRef = AddConversation( "Blurb_4_Militia_Lead", TEAM_IMC )
	AddCustomVDUFunction( convRef,	ThirdPulseIMCVDU )
	AddWait( convRef, 3.85 )
	AddVDURadio( convRef, "spyglass",		"diag_story75Mil_BY308_01_01_imc_spygl" )
	AddVDURadio( convRef, "spyglass",		"diag_story75Mil_BY308_02_01_imc_spygl" )
	AddVDURadio( convRef, "blisk",	null,	"diag_story75Mil_BY308_03_01_imc_blisk" )

	// BLURB #1 - IMC lead
	// SPYGLASS:	Reactor core overload is at 25%. Signal intercepts indicate that we currently hold the advantage over the Militia.
	// BLISK:		Good work Pilots! The sooner we scuttle this base, the less time they’ll have to analyze the tower.
	convRef = AddConversation( "Blurb_1_IMC_Lead", TEAM_IMC )
	AddVDURadio( convRef, "spyglass",	"diag_story25imc_BY319_01_01_imc_spygl" )
	AddVDURadio( convRef, "blisk",		"diag_story25imc_BY319_02_01_imc_blisk" )

	// BLURB #2 - IMC lead - optional
	// SPYGLASS:	All units, despite our control of the situation, I am detecting a power surge at the tower. Brace for heavy interference.
	// PULSE
	// BLISK:		Spyglass! Find out what’s causing it. Those pulses might interfere with the core overload if they continue.
	convRef = AddConversation( "Blurb_2_IMC_Lead", TEAM_IMC )
	AddRadio( convRef,				"diag_story35imc_BY324_01_01_imc_spygl", -6.5 )
	AddCustomVDUFunction( convRef,	FirstPulseVDU )
	AddWait( convRef, 10.5 )
	AddVDURadio( convRef, "blisk",	"diag_story35imc_BY324_02_01_imc_blisk" )

	// BLURB #3 - IMC lead
	// SPYGLASS:	Reactor core overload is at 50%. Signal intercepts indicate that we currently hold the upper hand.
	// BLISK:		Pilots, we’re doing well - pressure in the tower’s reactor core is rising. Stay in control of the hardpoints.
	convRef = AddConversation( "Blurb_3_IMC_Lead", TEAM_IMC )
	AddVDURadio( convRef, "spyglass",			"diag_story50imc_BY325_01_01_imc_spygl" )
	AddVDURadio( convRef, "blisk",		null,	"diag_story50imc_BY325_02_01_imc_blisk" )

	// BLURB #4 - IMC lead
	// SPYGLASS:	RReactor core overload nearing 75%
	// BLISK:		That’s good news, Pilots. Reactor pressure is climbing and we’re on track to scuttling the entire base. Stay in control of the hardpoints.
	convRef = AddConversation( "Blurb_4_IMC_Lead", TEAM_IMC )
	AddVDURadio( convRef, "spyglass",	"diag_story75imc_BY327_01_01_imc_spygl" )
	AddVDURadio( convRef, "blisk",		"diag_story75imc_BY327_02_01_imc_blisk" )

	// IMC WIN
	// BLISK:		Good work Pilots! We’ve routed enough power to the facility’s reactor core! It’s about to go critical!
	// SPYGLASS:	All ground forces, move clear of the buildings. Core detonation in 3…2…1…mark.
	convRef = AddConversation( "IMCWin", TEAM_IMC )
	AddVDURadio( convRef, "blisk",				"diag_epMid_imcWin_BY313_01_01_imc_blisk" )
	AddWait( convRef, 1.0 ) // When spyglass new line gets put in it will probably end up back at 1.0
	AddVDURadio( convRef, "spyglass",	null,	"diag_epMid_imcWin_BY313_02a_01_imc_spygl" )

	// Militia WIN
	// SPYGLASS:	Sergeant Blisk, we have been defeated. Communications intercepts indicate that the Militia have completed their analysis of the repulsor tower.
	convRef = AddConversation( "MilitiaWin", TEAM_IMC )
	AddRadio( convRef,				"diag_imcLoseAnnc_BY310_01_01_imc_spygl", -6.1 )
	AddCustomVDUFunction( convRef,	ForthPulseVDUMilitia )

	// MID EPILOGUE - Militia WIN
	// BLISK:		All Pilots, you heard the tin can - head for the evac point. Mission terminated.
	// SPYGLASS:	Vice Admiral Graves, I believe the Militia has enough data on the repulsor tower to formulate a means of exploiting its weaknesses. Your orders, sir.
	// GRAVES:		Spyglass, Notify IMC Airbase Sierra, They're about to come under attack.
	convRef = AddConversation( "epilogue_mid_militia_win", TEAM_IMC )
	AddVDURadio( convRef, "blisk",		"diag_epMid_imcLose_BY312_01_01_imc_blisk" )
	AddVDURadio( convRef, "spyglass",	"diag_epMid_imcLose_BY312_02_01_imc_spygl" )
	AddVDURadio( convRef, "graves",		"diag_epMid_imcLose_BY312_03a_01_imc_graves" )

	// MID EPILOGUE - IMC WIN
	// SPYGLASS:	Militia forces are attempting to escape. Pursue and destroy them.
	// SPYGLASS:	Vice Admiral Graves, my analysis of the base archive indicates that despite our best efforts, the Militia may have obtained enough data to find a weakness in the repulsor towers.
	// GRAVES:		Spyglass, Notify IMC Airbase Sierra, They're about to come under attack.
	convRef = AddConversation( "epilogue_mid_imc_win", TEAM_IMC )
	AddVDURadio( convRef, "spyglass",	"diag_epMid_imcWin_BY315_01_01_imc_spygl" )
	AddVDURadio( convRef, "spyglass",	"diag_epMid_imcWin_BY315_02_01_imc_spygl" )
	AddVDURadio( convRef, "graves",		"diag_epMid_imcLose_BY312_03a_01_imc_graves" )

	// POST EPILOGUE - IMC WIN
	// BLISK:	How the hell did you know MacAllan would come here for the tower, sir?
	// GRAVES:	He told me, Blisk. We ran the simulations fifteen years ago. How we’d fight if we were on the other side.
	// BLISK:	Then what’s next?
	// GRAVES:	All the plans end in the same place - set a course for the Demeter system.
	convRef = AddConversation( "post_epilogue_win", TEAM_IMC )
	AddVDURadio( convRef, "blisk",		"diag_epPostImc_BY318_01_01_imc_blisk" )
	AddVDURadio( convRef, "graves",		"diag_epPostImc_BY318_02_01_imc_graves" )
	AddVDURadio( convRef, "blisk",		"diag_epPostImc_BY318_03_01_imc_blisk" )
	AddVDURadio( convRef, "graves",		"diag_epPostImc_BY318_04a_01_imc_graves" )

	// POST EPILOGUE - Militia WIN
	// SAME AS ABOVE
	convRef = AddConversation( "post_epilogue_loss", TEAM_IMC )
	AddVDURadio( convRef, "blisk",		"diag_epPostImc_BY318_01_01_imc_blisk" )
	AddVDURadio( convRef, "graves",		"diag_epPostImc_BY318_02_01_imc_graves" )
	AddVDURadio( convRef, "blisk",		"diag_epPostImc_BY318_03_01_imc_blisk" )
	AddVDURadio( convRef, "graves",		"diag_epPostImc_BY318_04a_01_imc_graves" )
}

function StopCustomVDU( player )
{
	player.Signal( "StopCustomVDU" )
}

function FirstPulseVDU( player )
{
	thread FirstPulseVDUThread( player )
}

function FirstPulseVDUThread( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local org1 = Vector( -1945, -2258, 3628 )
	local org2 = Vector( -1612, -2678, 1190 )

	local ang1 = Vector( 31, 80, 0 )
	local ang2 = Vector( -34, 46, 0 )
	local ang3 = Vector( -5, 68, 0 )

	local fov1 = 55
	local fov2 = 35
	local fov3 = 50

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	wait 1
	thread ZoomCameraOverTime( player, fov1, fov2, 5, 2, 3 )
	thread RotateCameraOverTime( player, ang1, ang2, 5, 1, 4 )
	wait 6

	thread ZoomCameraOverTime( player, fov2, fov3, 5, 0, 3 )
	thread RotateCameraOverTime( player, ang2, ang3, 7, 2, 2 )
	thread MoveCameraOverTime( player, org1, org2, 7, 2, 2 )

	wait 7
}

function FirstBlurbIMCLeadVDU( player )
{
	thread FirstBlurbIMCLeadVDUThread( player )
}

function FirstBlurbIMCLeadVDUThread( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )

				HideVDU()
			}
		}
	)

	level.camera.SetFogEnable( true )

	local org1 = Vector( -1280, -3137, 618 )
	local fov1 = 50
	local ang1a = Vector( -6, 81, 0 )
	local ang1b = Vector( -43, 62, 0 )

	local org2 = Vector( -691, 1913, 771 )
	local ang2 = Vector( 38, 1, 0 )
	local fov2 = 70

	local org3 = Vector( -687, -2260, -171 )
	local ang3 = Vector( 16, 42, 0 )
	local fov3 = 80

	local org4 = Vector( -3762, -1515, 104 )
	local ang4 = Vector( 19, 50, 0 )
	local fov4 = 80

	level.camera.SetOrigin( org1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetAngles( ang1a )
	thread RotateCameraOverTime( player, ang1a, ang1b, 6, 1, 5 )

	wait 8

	level.camera.SetOrigin( org2 )
	level.camera.SetAngles( ang2 )
	level.camera.SetFOV( fov2 )

	wait 2.5

	level.camera.SetOrigin( org3 )
	level.camera.SetAngles( ang3 )
	level.camera.SetFOV( fov3 )

	wait 2.5

	level.camera.SetOrigin( org4 )
	level.camera.SetAngles( ang4 )
	level.camera.SetFOV( fov4 )

	wait 2.5
}

function ForcedPulseIMCLeadVDU( player )
{
	thread ForcedPulseIMCLeadVDUThread( player )
}

function ForcedPulseIMCLeadVDUThread( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )

				HideVDU()
			}
		}
	)

	level.camera.SetFogEnable( true )

	local org1 = Vector( -1280, -3137, 618 )
	local fov1 = 50
	local ang1a = Vector( -6, 81, 0 )
	local ang1b = Vector( -43, 62, 0 )

	local org2 = Vector( -691, 1913, 771 )
	local ang2 = Vector( 38, 1, 0 )
	local fov2 = 70

	local org3 = Vector( -687, -2260, -171 )
	local ang3 = Vector( 16, 42, 0 )
	local fov3 = 80

	local org4 = Vector( -3762, -1515, 104 )
	local ang4 = Vector( 19, 50, 0 )
	local fov4 = 80

	level.camera.SetOrigin( org1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetAngles( ang1a )
	thread RotateCameraOverTime( player, ang1a, ang1b, 6, 1, 5 )

	wait 8

	level.camera.SetOrigin( org2 )
	level.camera.SetAngles( ang2 )
	level.camera.SetFOV( fov2 )

	wait 2.5

	level.camera.SetOrigin( org3 )
	level.camera.SetAngles( ang3 )
	level.camera.SetFOV( fov3 )

	wait 2.5

	level.camera.SetOrigin( org4 )
	level.camera.SetAngles( ang4 )
	level.camera.SetFOV( fov4 )

	wait 2.5
}

function SecondPulseVDU( player )
{
	thread SecondPulseVDUThread( player )
}

function SecondPulseVDUThread( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local org1 = Vector( 24, 3493, 1664 )
	local org2 = Vector( -225, -307, 6110 )
	local org3 = Vector( 4044, 573, 5194 )

	local ang1 = Vector( -62, -56, 0 )	// fov 35
	local ang2 = Vector( 40, 62, 0 )
	local ang3 = Vector( 27, 170, 0 )

	local fov1 = 35
	local fov2 = 70
	local fov3 = 35

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	thread MoveCameraOverTime( player, org1, org2, 8, 2, 5 )
	wait 1.25
	thread RotateCameraOverTime( player, ang1, ang2, 5, 1.75, 3.25 )
	wait 2.25
	thread ZoomCameraOverTime( player, fov1, fov2, 4.5, 2, 1 )
	wait 4.5
	thread MoveCameraOverTime( player, org2, org3, 8, 5, 3 )
	thread RotateCameraOverTime( player, ang2, ang3, 8, 4, 4 )
	thread ZoomCameraOverTime( player, fov2, fov3, 8, 5, 3 )
	wait 4
}

function ThirdPulseVDU( player )
{
	thread ThirdPulseVDUThread( player )
}

function ThirdPulseVDUThread( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local org1 = Vector( -1391, -2407, 707 )

	local ang1 = Vector( -25, 83, 0 )
	local ang2 = Vector( -41, 54, 0 )
	local ang3 = Vector( -17, 71, 0 )
	local ang4 = Vector( -23, 124, 0 )

	local fov1 = 60

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	thread RotateCameraOverTime( player, ang1, ang2, 4, 2, 2 )
	wait 5
	thread RotateCameraOverTime( player, ang2, ang3, 3, 1, 2 )
	wait 3
	thread RotateCameraOverTime( player, ang3, ang4, 7, 2, 4 )
	wait 7
}

function ThirdPulseIMCVDU( player )
{
	thread ThirdPulseIMCVDUThread( player )
}

function ThirdPulseIMCVDUThread( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local org1 = Vector( 2096, -800, 1396 )
	local org2 = Vector( 2082, -510, 874 )

	local ang1 = Vector( 3, 150, 0 )
	local ang2 = Vector( -64, 100, 0 )
	local ang3 = Vector( -15, 120, 0 )

	local fov1 = 60
	local fov2 = 45
	local fov3 = 60

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	thread RotateCameraOverTime( player, ang1, ang2, 8, 3, 3 )
	thread ZoomCameraOverTime( player, fov1, fov2, 8, 3, 3 )
	wait 8
	thread RotateCameraOverTime( player, ang2, ang3, 10, 1, 5 )
	thread ZoomCameraOverTime( player, fov2, fov3, 6, 3, 3 )
	thread MoveCameraOverTime( player, org1, org2, 4, 2, 2 )
	wait 10
}

function ForthPulseVDUMilitia( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopCustomVDU" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local org1 = Vector( -5892, -291, 2762 )
	local org2 = Vector( -1989, -2914, 1594 )
	local org3 = Vector( -30, -3774, 1537 )

	local ang1 = Vector( 26, 0, 0 )
	local ang2 = Vector( -38, 53, 0 )
	local ang3 = Vector( -6, 88, 0 )

	local fov1 = 70
	local fov2 = 40
	local fov3 = 60

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	thread MoveCameraOverTime( player, org1, org2, 8, 1, 3 )
	thread RotateCameraOverTime( player, ang1, ang2, 8, 1, 3 )
	wait 2
	thread ZoomCameraOverTime( player, fov1, fov2, 6, 3, 3 )
	wait 6
	thread ZoomCameraOverTime( player, fov2, fov3, 4, 2, 2 )
	thread MoveCameraOverTime( player, org2, org3, 7, 3, 3 )
	thread RotateCameraOverTime( player, ang2, ang3, 7, 3, 3 )
	wait 7
}

///////////////////////////////////////////////////////////////////
function HardpointDialogOverride()
{
	// overrides the default lines for capture point mode when in cinematic mode

	local dialogAliases = level.dialogAliases

	// this clears the VDU whitelist
	level.whiteList[ TEAM_MILITIA ] = {}
	level.whiteList[ TEAM_IMC ] = {}


	/***************************************/
	/***********  TEAM MILITIA  ************/
	/***************************************/

	// lost all hardpoint - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_lost_all"] = ["diag_hp_LostAll_BY104_01_01_mcor_Bish", "diag_hp_LostAll_BY106_01_01_mcor_Bish", "diag_hp_LostAll_BY105_01_01_mcor_Bish" ]

	// Starting cap from enemy controlled - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_a"] = ["diag_hp_PatchedIn_BY107_01_01_mcor_Bish", "diag_hp_PatchedInA_BY108_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_b"] = ["diag_hp_PatchedIn_BY107_01_01_mcor_Bish", "diag_hp_PatchedInB_BY109_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_c"] = ["diag_hp_PatchedIn_BY107_01_01_mcor_Bish", "diag_hp_PatchedInC_BY110_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_25"] = ["diag_hp_NeutProg_MIL25_BY111_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_50"] = ["diag_hp_NeutProg_MIL50_BY112_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_75"] = ["diag_hp_NeutProg_MIL75_BY113_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_100"] = ["null_temp"] // not used

	// Continuing cap after neutralizing hardpoint - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_a"] = ["diag_hp_NeutralizedA_BY115_01_01_mcor_Bish", "diag_hp_Neutralized_BY114_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_b"] = ["diag_hp_NeutralizedB_BY116_01_01_mcor_Bish", "diag_hp_Neutralized_BY114_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_c"] = ["diag_hp_NeutralizedC_BY117_01_01_mcor_Bish", "diag_hp_Neutralized_BY114_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_25"] = ["diag_hp_CapProg_MIL25_BY121_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_50"] = ["diag_hp_CapProg_MIL50_BY122_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_75"] = ["diag_hp_CapProg_MIL75_BY123_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_100"] =["null_temp"] // not used

	// Starting cap from neutral - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_a"] = ["diag_hp_NeutralizedA_BY118_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_b"] = ["diag_hp_NeutralizedB_BY119_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_c"] = ["diag_hp_NeutralizedC_BY120_01_01_mcor_Bish"]

	// Capturing 1 of 3 - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_ac"] = "diag_hp_CapB_NeedAC_BY124_01_01_mcor_Bish"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_bc"] = "diag_hp_CapA_NeedBC_BY125_01_01_mcor_Bish"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_ab"] = "diag_hp_CapC_NeedAB_BY126_01_01_mcor_Bish"

	// Capturing 2 of 3 - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_b"] = ["diag_hp_CapB_NeedA_BY127_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_c"] = ["diag_hp_CapC_NeedA_BY128_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_a"] = ["diag_hp_CapA_NeedB_BY129_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_c"] = ["diag_hp_CapC_NeedB_BY130_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_a"] = ["diag_hp_CapA_NeedC_BY131_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_b"] = ["diag_hp_CapB_NeedC_BY132_01_01_mcor_Bish"]
	// dummy lines for the registering to work // not good
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_a"] = ["null_temp"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_b"] = ["null_temp"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_c"] = ["null_temp"]
	// alt lines
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_one"] = ["diag_hp_Cap2_Need1_BY133_01_01_mcor_Bish"]

	// Capturing 3 of 3 - DONE
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_a"] = ["diag_hp_CapAll_BY134_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_b"] = ["diag_hp_CapAll_BY135_01_01_mcor_Bish"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_c"] = ["diag_hp_CapAll_BY136_01_01_mcor_Bish"]

//	this would make the conversation "hardpoint_lost_all" play a VDU animation instead of just radio.
//	level.whiteList[TEAM_MILITIA][ "hardpoint_lost_all" ] <- "anim_name"

	/***************************************/
	/*************  TEAM IMC  **************/
	/***************************************/

	// lost all hardpoint - DONE
	dialogAliases[TEAM_IMC]["hardpoint_lost_all"] = ["diag_hp_LostAll_BY150_01_01_imc_Blisk", "diag_hp_LostAll_BY151_01_01_imc_Blisk", "diag_hp_LostAll_BY152_01_01_imc_Blisk" ]

	// Starting cap from enemy controlled - DONE
	dialogAliases[TEAM_IMC]["hardpoint_status_0_a"] = ["diag_hp_PatchedInA_BY154_01_01_imc_Blisk", "diag_hp_PatchedIn_BY153_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_0_b"] = ["diag_hp_PatchedInB_BY155_01_01_imc_Blisk", "diag_hp_PatchedIn_BY153_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_0_c"] = ["diag_hp_PatchedInC_BY156_01_01_imc_Blisk", "diag_hp_PatchedIn_BY153_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_25"] = ["diag_hp_NeutProg_IMC25_BY157_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_50"] = ["diag_hp_NeutProg_IMC50_BY158_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_75"] = ["diag_hp_NeutProg_IMC75_BY159_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_100"] = ["null_temp"] // not used

	// Continuing cap after neutralizing hardpoint - DONE
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_a"] = ["diag_hp_NeutralizedA_BY161_01_01_imc_Blisk", "diag_hp_Neutralized_BY160_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_b"] = ["diag_hp_NeutralizedB_BY162_01_01_imc_Blisk", "diag_hp_Neutralized_BY160_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_c"] = ["diag_hp_NeutralizedC_BY163_01_01_imc_Blisk", "diag_hp_Neutralized_BY160_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_25"] = ["diag_hp_CapProg_IMC25_BY167_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_50"] = ["diag_hp_CapProg_IMC50_BY168_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_75"] = ["diag_hp_CapProg_IMC75_BY169_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_100"] =["null_temp"] // not used

	// Starting cap from neutral - DONE
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_a"] = ["diag_hp_NeutralizedA_BY164_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_b"] = ["diag_hp_NeutralizedB_BY165_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_c"] = ["diag_hp_NeutralizedC_BY166_01_01_imc_Blisk"]

	// Capturing 1 of 3 - DONE
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_ac"] = ["diag_hp_CapB_NeedAC_BY170_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_bc"] = ["diag_hp_CapA_NeedBC_BY171_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_ab"] = ["diag_hp_CapC_NeedAB_BY172_01_01_imc_Blisk"]

	// Capturing 2 of 3 - DONE
		dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_b"] = ["diag_hp_CapB_NeedA_BY173_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_c"] = ["diag_hp_CapC_NeedA_BY174_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_a"] = ["diag_hp_CapA_NeedB_BY175_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_c"] = ["diag_hp_CapC_NeedB_BY176_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_a"] = ["diag_hp_CapA_NeedC_BY177_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_b"] = ["diag_hp_CapB_NeedC_BY178_01_01_imc_Blisk"]
	// dummy lines for the registering to work // not good
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_a"] = ["null_temp"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_b"] = ["null_temp"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_c"] = ["null_temp"]
	// alt lines
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_one"] = ["diag_hp_Cap2_Need1_BY179_01_01_imc_Blisk"]

	// Capturing 3 of 3 - DONE
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_a"] = ["diag_hp_CapAll_BY180_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_b"] = ["diag_hp_CapAll_BY181_01_01_imc_Blisk"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_c"] = ["diag_hp_CapAll_BY182_01_01_imc_Blisk"]

//	this would make the conversation "hardpoint_lost_all" play a VDU animation instead of just radio.
//	level.whiteList[TEAM_IMC][ "hardpoint_lost_all" ] <- "anim_name"

}

function BoneyardAIChatter()
{
	BoneyradAddAIConversations( TEAM_MILITIA, level.actorsABCD )
	BoneyradAddAIConversations( TEAM_IMC, level.actorsABCD )
}

function BoneyradAddAIConversations( team, actors )
{
	//Boneyard specific lines
	Assert ( GetMapName() == "mp_boneyard" )
	local conversation = "boneyard_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_12_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	//gs_BY_comment3L_02 doesn't exist

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )


	//*******************************//
	//*******************************//
	//*******************************//
	local conversation = "boneyard_grunt_chatter_after_pulse"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_BY_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_BY_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

}