Coop_TeamScoreEventNotification.res
{
	Coop_TeamScoreEventNotification_Anchor
	{
		ControlName					Label
		xpos						0
		ypos						0
		wide						%100
		tall						%100
		visible						0
		proportionalToParent		1
	}
	Coop_TeamScoreEventNotification_BG
	{
		ControlName			ImagePanel
		zpos				1012
		wide				200
		tall				16
		image				"hud/coop/wave_callout_strip"
		visible				0
		enable				1
		scaleImage			1

		pin_to_sibling				Coop_TeamScoreEventNotification_Anchor
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Coop_TeamScoreEventNotification_FG
	{
		ControlName			ImagePanel
		zpos				1012
		wide				200
		tall				17
		image				"hud/coop/wave_callout_strip_lines"
		visible				0
		enable				1
		scaleImage			1

		pin_to_sibling				Coop_TeamScoreEventNotification_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Coop_TeamScoreEventNotification_EventValue
	{
		ControlName			Label
		zpos				1014
		xpos 				-12
		wide 				36
		tall				16
		visible				0
		font				HudFontSmall
		labelText			"+200"
		allcaps				1
		textAlignment		east
		fgcolor_override 	"230 230 230 255"
		//bgcolor_override 	"0 255 255 128"

		pin_to_sibling				Coop_TeamScoreEventNotification_BG
		pin_corner_to_sibling		5
		pin_to_sibling_corner		5
	}

	Coop_TeamScoreEventNotification_EventName
	{
		ControlName			Label
		zpos				1014
		xpos 				-32
		wide 				110
		tall				16
		visible				0
		font				HudFontSmall
		labelText			"HARVESTER HEALTH"
		allcaps				1
		textAlignment		west
		fgcolor_override 	"230 230 230 255"
		//bgcolor_override 	"0 255 0 128"

		pin_to_sibling				Coop_TeamScoreEventNotification_BG
		pin_corner_to_sibling		5
		pin_to_sibling_corner		5
	}

	Coop_TeamScoreEventNotification_Icon
	{
		ControlName			ImagePanel
		zpos				1014
		xpos 				-10
		wide				12
		tall				12
		visible				0
		image				white
		scaleImage			1

		pin_to_sibling				Coop_TeamScoreEventNotification_BG
		pin_corner_to_sibling		5
		pin_to_sibling_corner		5
	}

	Coop_TeamScoreEventNotification_Flare
	{
		ControlName			ImagePanel
		zpos				1012
		wide				200
		tall				16
		image				"hud/coop/score_notification_flare"
		visible				0
		enable				1
		scaleImage			1

		pin_to_sibling				Coop_TeamScoreEventNotification_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}
}