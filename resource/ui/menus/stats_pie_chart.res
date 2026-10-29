"Resource/UI/menus/stats_pie_chart.res"
{
	BarBG
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					300
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	Bar0
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					306
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	Bar1
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					305
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	Bar2
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					304
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	Bar3
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					303
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	Bar4
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					302
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	Bar5
	{
		ControlName				CHudProgressBar
		xpos					0
		ypos					0
		zpos					301
		wide					119
		tall					119
		visible					1
		fg_image				"../ui/menu/personal_stats/ps_pie_fill"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		1
	}

	BarFG
	{
		ControlName				ImagePanel
		xpos					0
		ypos					0
		zpos					310
		wide					120
		tall					120
		visible					1
		image					"../ui/menu/personal_stats/ps_pie_frame"
		scaleImage 				1
	}

	Title
	{
		ControlName					Label
		xpos						120
		ypos						5
		zpos						200
		wide						180
		tall						12
		visible						1
		font						StatsProgressBarTitle
		labelText					"Pie Chart Name"
		allcaps						1
		textAlignment				west
		fgcolor_override 			"51 39 39 255"
		//bgcolor_override 			"0 255 0 100"
	}

	BarColorGuide0
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						0
		zpos						200
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon"
		visible						0
		scaleImage					1

		pin_to_sibling				Title
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarColorGuideFrame0
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						0
		zpos						201
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon_frame"
		visible						0
		scaleImage					1

		pin_to_sibling				Title
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarName0
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						200
		wide						160
		tall						16
		visible						0
		font						StatsPieChartLabel
		labelText					"Bar 0 Name"
		allcaps						0
		textAlignment				west
		fgcolor_override 			"51 39 39 255"

		pin_to_sibling				BarColorGuide0
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	BarColorGuide1
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						200
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarColorGuideFrame1
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						201
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon_frame"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarName1
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						200
		wide						160
		tall						16
		visible						0
		font						StatsPieChartLabel
		labelText					"Bar 1 Name"
		allcaps						0
		textAlignment				west
		fgcolor_override 			"51 39 39 255"

		pin_to_sibling				BarColorGuide1
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	BarColorGuide2
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						200
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarColorGuideFrame2
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						201
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon_frame"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarName2
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						200
		wide						160
		tall						16
		visible						0
		font						StatsPieChartLabel
		labelText					"Bar 2 Name"
		allcaps						0
		textAlignment				west
		fgcolor_override 			"51 39 39 255"

		pin_to_sibling				BarColorGuide2
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	BarColorGuide3
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						200
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarColorGuideFrame3
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						201
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon_frame"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarName3
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						200
		wide						160
		tall						16
		visible						0
		font						StatsPieChartLabel
		labelText					"Bar 3 Name"
		allcaps						0
		textAlignment				west
		fgcolor_override 			"51 39 39 255"

		pin_to_sibling				BarColorGuide3
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	BarColorGuide4
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						200
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarColorGuideFrame4
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						201
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon_frame"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarName4
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						200
		wide						160
		tall						16
		visible						0
		font						StatsPieChartLabel
		labelText					"Bar 4 Name"
		allcaps						0
		textAlignment				west
		fgcolor_override 			"51 39 39 255"

		pin_to_sibling				BarColorGuide4
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	BarColorGuide5
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						200
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarColorGuideFrame5
	{
		ControlName					ImagePanel
		xpos 						0
		ypos						-5
		zpos						201
		wide 						20
		tall 						20
		image 						"../ui/menu/personal_stats/ps_pie_icon_frame"
		visible						0
		scaleImage					1

		pin_to_sibling				BarColorGuide4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarName5
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						200
		wide						160
		tall						16
		visible						0
		font						StatsPieChartLabel
		labelText					"Bar 5 Name"
		allcaps						0
		textAlignment				west
		fgcolor_override 			"51 39 39 255"

		pin_to_sibling				BarColorGuide5
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

}