// 768x768
vgui_sniper.res
{
	Screen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				768
		tall				768
		visible				1
//		image				"hud/obituary_headshot"
		scaleImage			1
//		drawColor			"0 0 0 255"
//		fgcolor_override	"0 0 0 128"

		zpos				1
	}

	HitConfirmBG
	{
		ControlName			ImagePanel
		xpos				128
		ypos				148
		wide				128
		tall				128
		visible				1
		image				HUD/hit_confirm_bg
		scaleImage			1
		drawColor			"255 255 255 64"

		zpos				1

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	HitConfirmHead
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				128
		visible				0
		image				HUD/hit_confirm_head
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1

		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	HitConfirmTorso
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				128
		visible				0
		image				HUD/hit_confirm_torso
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1

		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	HitConfirmArmLeft
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				128
		visible				0
		image				HUD/hit_confirm_arm_left
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1

		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	HitConfirmArmRight
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				128
		visible				0
		image				HUD/hit_confirm_arm_right
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1

		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	HitConfirmLegLeft
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				128
		visible				0
		image				HUD/hit_confirm_leg_left
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1

		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	HitConfirmLegRight
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				128
		visible				0
		image				HUD/hit_confirm_leg_right
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1

		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	ConfidenceLabel
	{
		ControlName		Label
		xpos			0
		ypos			8
		wide			256
		tall			20
		visible			1
		font			HudFontMed
		labelText		""
		textAlignment	center
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		fgcolor_override 	"255 255 255 255"

		zpos						5
		pin_to_sibling				HitConfirmBG
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6
	}
}

