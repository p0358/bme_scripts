#base "vgui_fullscreen.res"
vgui_fullscreen_pilot.res
{
	Screen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				852
		tall				480
		visible				1
		//image				HUD/white
		image				HUD/screen_grid_overlay
		scaleImage			1
		drawColor			"0 0 0 0"

		zpos				1
	}

	SafeArea
	{
		ControlName		ImagePanel
		wide			730
		tall			400
		visible			1
		scaleImage		1
		fillColor		"255 0 0 0"
		drawColor		"0 0 0 0"
		image			HUD/white

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				2
	}

	RodeoAlertIcon
	{
		ControlName			ImagePanel
		xpos				-180
		ypos				-160
		wide				48
		tall				48
		visible				0
		image				HUD/rodeo_icon_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	RodeoAlertLabel
	{
		ControlName			Label
		xpos				5
		ypos				0
		wide				300
		tall				20
		visible				0
		font				HudFontMed
		labelText			"Some guy is on your Titan!"
		textAlignment		west

		pin_to_sibling				RodeoAlertIcon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	AntiRodeoHint
	{
		ControlName		Label
		xpos			0
		ypos			-40
		wide			100
		tall			24
		visible			0
		font			HudFontMed
		labelText		"#HUD_TITAN_DISEMBARK"
		auto_wide_tocontents 1
		textAlignment	center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	SafeAreaCenter
	{
		ControlName		ImagePanel
		wide			730
		tall			420
		visible			1
		scaleImage		1
		fillColor		"0 0 255 0"
		drawColor		"0 0 255 0"
		image			HUD/white

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Minimap
	{
		ControlName			CMapOverview

		xpos				0
		ypos				-20
		wide				120
		tall				94
		visible				1
		scaleImage			1
		zpos				8

		// CMapOverview specific
		displayDistScalar			1
		circular					0
		clampToEdgeScale			0.88	// the point where they start to clamp
		hostileFiringFadeOut 		4.0	// how long it takes to fade back to normal/out after attacking/double-jumping
		hostileFiringColor			"255 21 0 255"
		cloakedPlayerFadeOut		1
		localPlayerIcon				"vgui/HUD/compass_icon_you"
		localPlayerIconScale		0.1
		mapTextureAlpha				0.7
		pingIconMaxScale			0.12
		heightArrowFriendlyIcon		"vgui/HUD/threathud_arrow_neutral"
		heightArrowEnemyIcon		"vgui/HUD/threathud_arrow_neutral"
		heightArrowNeutralIcon		"vgui/HUD/threathud_arrow_neutral"
		heightArrowDistanceThres	170
		heightArrowRatioThres		0.15
		heightArrowIconScale		0.025

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	MinimapCoop
	{
		ControlName			CMapOverview

		xpos				0
		ypos				-20
		wide				120
		tall				94
		visible				0
		scaleImage			1
		zpos				8

		// CMapOverview specific
		displayDistScalar			1
		circular					0
		clampToEdgeScale			0.88	// the point where they start to clamp
		hostileFiringFadeOut 		0.0	// how long it takes to fade back to normal/out after attacking/double-jumping
		hostileFiringColor			"255 255 255 255"
		cloakedPlayerFadeOut		1
		localPlayerIcon				"vgui/HUD/compass_icon_you"
		localPlayerIconScale		0.0606//0.1 * 0.606
		mapTextureAlpha				0.7
		pingIconMaxScale			0.085 //0.12
		heightArrowFriendlyIcon		"vgui/HUD/threathud_arrow_neutral"
		heightArrowEnemyIcon		"vgui/HUD/threathud_arrow_neutral"
		heightArrowNeutralIcon		"vgui/HUD/threathud_arrow_neutral"
		heightArrowDistanceThres	170
		heightArrowRatioThres		0.15
		heightArrowIconScale		0.015//0.025 * 0.606

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	EMPScreenFX
	{
		ControlName		ImagePanel
		wide			%200
		tall			%200
		visible			0
		scaleImage		1
		image			HUD/pilot_flashbang_overlay
		drawColor		"255 255 255 64"

		zpos			-1000
	}

	TitanBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-10
		wide				176
		tall				22
		visible				0
		bg_image			HUD/titan_build_bar_bg
		fg_image			HUD/titan_build_bar
		change_image		HUD/titan_build_bar_change
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 255"
		SegmentSize			176
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		ChangeStyle			1
		ChangeTime			0.5
		ChangeDir			1
		//ChangeColor			"255 128 64 255"

		zpos 200

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	TitanBarLabel
	{
		ControlName			Label
		xpos				0
		ypos				6
		wide				176
		tall				22
		visible				0
		font				HudFontSmall
		labelText			"BUILDING TITAN"
		textAlignment		center
		fgcolor_override	"160 160 160 255"
		auto_wide_tocontents	1

		zpos				201

		pin_to_sibling				TitanBar
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	TitanBarEarnedLabelAnchor
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			0
		tall			0
		//image			HUD/flare_fat
		visible			1
		scaleImage		1
		drawColor		"0 0 0 0"
	}

	TitanBarEarnedLabel
	{
		ControlName			Label
		//xpos				82
		//ypos				82
		xpos				-42
		ypos				42
		wide				100
		tall				44
		visible				0
		font				HudFontSmall
		labelText			"-5 sec"
		textAlignment		center
		fgcolor_override	"255 255 255 255"
		auto_wide_tocontents	1

		zpos				201

		pin_to_sibling				TitanBarEarnedLabelAnchor
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	TitanBarEarnedIcon
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			22
		tall			22
		visible			0
		scaleImage		1
		drawColor		"255 255 255 255"
		image			HUD/titan_stance_icon_drop

		pin_to_sibling				TitanBarEarnedLabel
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	TitanBarLeftIcon
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			176
		tall			22
		visible			0
		scaleImage		1
		drawColor		"255 255 255 255"
		image			HUD/titan_build_bar_wrench

		pin_to_sibling				TitanBar
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	TitanBarLeftRight
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			176
		tall			22
		visible			0
		scaleImage		1
		drawColor		"255 255 255 255"
		image			HUD/titan_build_bar_titan

		pin_to_sibling				TitanBar
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_CockpitScreen
	{
		ControlName		ImagePanel
		image			HUD/vdu_hud_monitor

		xpos				-60
		ypos				-67
		wide				120
		tall				94
		visible				0
		scaleImage			1
		zpos				8

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		8
		pin_to_sibling_corner		1
	}

	VDU_CockpitScreen_widescreen
	{
		ControlName		ImagePanel
		image			HUD/vdu_hud_monitor_widescreen

		xpos				-60
		ypos				-67
		wide				120
		tall				94
		visible				0
		scaleImage			1
		zpos				8

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		8
		pin_to_sibling_corner		1
	}

	VDU_CockpitStatic
	{
		ControlName		ImagePanel
		image			HUD/vgui_vdu_static

		xpos				-60
		ypos				-67
		wide				120
		tall				94
		visible				0
		scaleImage			1
		zpos				12

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		8
		pin_to_sibling_corner		1
	}

	VDU_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				166
		tall				166
		visible				0
		image				HUD/minimap_bg
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				4

		pin_to_sibling				VDU_CockpitScreen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_FG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				166
		tall				166
		visible				0
		image				HUD/vdu_shape
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				16

		pin_to_sibling				VDU_CockpitScreen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_FG_widescreen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				166
		tall				166
		visible				0
		image				HUD/vdu_shape_widescreen
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				16

		pin_to_sibling				VDU_CockpitScreen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	EyeOverlay
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				1024
		tall				576
		visible				0
		image				HUD/eye_overlay_hud
		scaleImage			1
		drawColor			"255 255 255 16"

		zpos				1

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	AntiTitanHint
	{
		ControlName		Label
		xpos			0
		ypos			-40
		wide			100
		tall			24
		visible			0
		font			HudFontMed
		labelText		"#HUD_PRESS_FOR_ANTI_TITAN_WEAPON"
		auto_wide_tocontents 1
		textAlignment	center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

//	BurnCard
//	{
//		ControlName			CNestedPanel
//		xpos				0
//		ypos				150
//		wide				180
//		tall				200
//		visible				1
//		controlSettingsFile	"resource/UI/HudBurnCard.res"
//
//		pin_to_sibling				VDU_CockpitScreen
//		pin_corner_to_sibling		8
//		pin_to_sibling_corner		8
//
//	}
}
