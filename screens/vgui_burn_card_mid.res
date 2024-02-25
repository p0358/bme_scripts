vgui_burn_card_mid.res
{
	BurnCardMid_background
	{
		ControlName			ImagePanel

		wide				71
		tall				97
		visible				1

		xpos				20
		ypos				7

		image				burncards/burncard_mid_common_hover

		scaleImage			1
		//drawColor			"255 55 55 55"
	}

	BurnCardMid_Reminder
	{
		ControlName			ImagePanel
		//image				burncards/burncard_art_62
		image 				../ui/menu/items/non_items/burn_card_slot_3
		visible				0
		enable				1
		scaleImage			1
		xpos				0
		ypos				0
		zpos				998

		wide				100
		tall				116

		pin_to_sibling				BurnCardMid_background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	BurnCardMid_SelectImage
	{
		ControlName			ImagePanel
		xpos				0
		ypos				10
		zpos				50

		wide				65 // 72 // 69
		tall				41 // 41
		visible				1

		image				burncards/burncard_mid_icon_template

		scaleImage			1
		drawColor		"255 255 255 255"
		pin_to_sibling				BurnCardMid_background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	BurnCardMid_star
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-6
		zpos				125

		wide				32
		tall				32

		image				HUD/instamission_star_on

		scaleImage			1
		visible				0
		drawColor			"255 255 255 255"

		pin_to_sibling				BurnCardMid_background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4

		//wide				200
		//tall				160
	}

	BurnCardMid_title
	{
		ControlName			Label
		xpos				0
		//ypos				-48
		ypos				-6

		visible				1
		zpos				126
		wide				60
		tall				30
		labelText			"TITLE"
		allCaps				1
		font				RespawnSelectTitleSmall
		centerwrap			1
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				BurnCardMid_background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	BurnCardMid_slotText
	{
		ControlName			Label
		xpos				0
		ypos				0

		visible				1
		zpos				126
		wide				50
		tall				50
		labelText			"SLOT TEXT"
		allCaps				1
		font				RespawnSlotText
		centerwrap			1
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				BurnCardMid_background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	BurnCardMid_BottomText
	{
		ControlName			Label
		xpos				0
		//ypos				-48
		ypos				17

		visible				0
		zpos				126
		wide				75
		tall				20
		labelText			"some text"
		allCaps				1
		font				RespawnSelectCountSmall
		textAlignment		center
		fgcolor_override 	"255 205 35 255"

		pin_to_sibling				BurnCardMid_SelectImage
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}


	BurnCardMid_LabelOpenSlot
	{
		ControlName			Label
		xpos				0
		ypos				0
		visible				0
		zpos				240

		wide				60
		tall				80
		labelText			"SLOT OPEN"
		font				RespawnSelectTitle
		centerwrap			1
		allCaps				1
		//drawColor			"0 255 255 255"
		fgcolor_override 	"10 10 10 255" // 204 234 255 255"

		pin_to_sibling				BurnCardMid_background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}
}