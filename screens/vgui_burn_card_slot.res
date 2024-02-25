vgui_burn_card_slot.res
{	
	PreviewCard_background
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				125

		wide				227
		tall				316


		image				burncards/burncard_mid_blank

		scaleImage			1
		drawColor			"255 255 255 255"
	}
	
	PreviewCard_outline
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				250

		wide				227
		tall				316
		visible				0

		image				burncards/burncard_large_outline_highlight

		scaleImage			1
		drawColor			"255 255 255 255"
	}

	PreviewCard_title
	{
		ControlName			Label
		xpos				0
		ypos				7

		visible				1
		zpos				135
		wide				240
		tall				48
		labelText			"Active slot"
		allCaps				1
		font				BurnCardSlotText
		fgcolor_override 	"204 234 255 255"
		textAlignment		center

		pin_to_sibling				PreviewCard_topbottom_brackets
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	PreviewCard_slot
	{
		ControlName			Label
		xpos				0
		ypos				7

		visible				1
		zpos				135
		wide				180
		tall				300
		labelText			"PICK A CARD"
		allCaps				1
		font				BurnCardSlotText
		fgcolor_override 	"0 0 0 205"
		textAlignment		center
		centerwrap			1

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}
}