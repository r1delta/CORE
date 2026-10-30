"resource/ui/menus/panels/titanloadout.res"
{
	ImgTitanChassis
	{
		ControlName				ImagePanel
		InheritProperties		TitanChassisImage
		classname				"TitanChassisImage HideWhenLocked"
		ypos					40
		xpos 					-360
	}

	ImgTitanChassisInfoBG
	{
		ControlName				ImagePanel
		classname				HideWhenLocked
		xpos					-90
		ypos					-46
		zpos					10
		wide					270
		tall					46
		image 					"../ui/menu/edit_loadout/chassis_info_back"
		visible					1
		scaleImage				1
		pin_to_sibling			ImgTitanChassis
		pin_corner_to_sibling	2
		pin_to_sibling_corner	2
	}
	LblTitanChassisName
	{
		ControlName				Label
		classname				"TitanChassisName HideWhenLocked"
		xpos					-6
		ypos 					0
		zpos					11
		wide 					254
		tall 					30
		visible					1
		font					LoadoutChassisNameFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		labelText				"CHASSIS NAME"
		pin_to_sibling			ImgTitanChassisInfoBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblTitanChassisCore
	{
		ControlName				Label
		classname				"TitanCoreName HideWhenLocked"
		xpos					-55
		ypos 					0
		zpos					11
		wide 					215
		tall 					22
		visible					1
		font					LoadoutChassisCoreFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		labelText				"CORE NAME"
		pin_to_sibling			ImgTitanChassisInfoBG
		pin_corner_to_sibling	2
		pin_to_sibling_corner	2
	}
	ImgTitanDecalBG
	{
		ControlName				ImagePanel
		classname				HideWhenLocked
		xpos					0
		ypos					0
		zpos					10
		wide					46
		tall					46
		image 					"../ui/menu/titanDecal_menu/decalBackForLoadoutMenu"
		visible					1
		scaleImage				1
		pin_to_sibling			ImgTitanChassisInfoBG
		pin_corner_to_sibling	5
		pin_to_sibling_corner	7
	}
	ImgTitanDecalImage
	{
		ControlName				ImagePanel
		classname				"TitanDecalImage HideWhenLocked"
		xpos					0
		ypos					0
		zpos					11
		wide					40
		tall					40
		image 					""
		visible					1
		scaleImage				1
		pin_to_sibling			ImgTitanDecalBG
		pin_corner_to_sibling	8
		pin_to_sibling_corner	8
	}


	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgTitanPrimaryTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		ypos					76
		image 					"../ui/menu/loadouts/loadout_weapon_title_background"
	}
	LblTitanPrimaryTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanPrimaryTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#WEAPON"
	}

	ImgTitanPrimaryBG
	{
		ControlName				ImagePanel
		InheritProperties		TitanWeaponBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanPrimaryTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgTitanPrimaryImage
	{
		ControlName				ImagePanel
		InheritProperties		WeaponImage
		classname				"TitanPrimaryImage HideWhenLocked"
		pin_to_sibling			ImgTitanPrimaryBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos 					-5
	}
	LblTitanPrimaryName
	{
		ControlName				Label
		InheritProperties		WeaponName
		classname 				"TitanPrimaryName HideWhenLocked"
		pin_to_sibling			ImgTitanPrimaryImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos 					2
		ypos 					-4
	}
	LblTitanPrimaryDesc
	{
		ControlName				Label
		InheritProperties		WeaponDesc
		classname 				"TitanPrimaryDesc HideWhenLocked"
		pin_to_sibling			ImgTitanPrimaryImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos 					1
		ypos 					10
	}

	ImgTitanPrimaryModIcon
	{
		ControlName				ImagePanel
		InheritProperties		WeaponModIcon
		classname				"TitanPrimaryModIcon HideWhenLocked"
		pin_to_sibling			ImgTitanPrimaryBG
		pin_corner_to_sibling	2
		pin_to_sibling_corner	2
	}
	LblTitanPrimaryModName
	{
		ControlName				Label
		InheritProperties		ItemPropertyValue
		classname				"TitanPrimaryModName HideWhenLocked"
		pin_to_sibling			ImgTitanPrimaryModIcon
		wide 					160
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					4
		ypos					0
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgTitanSpecialTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanPrimaryBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					2
		image 					"../ui/menu/loadouts/loadout_ability_title_background"
	}
	ImgTitanSpecialBG
	{
		ControlName				ImagePanel
		InheritProperties		AbilityBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanSpecialTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}

	ImgTitanOrdnanceTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanSpecialBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		image 					"../ui/menu/loadouts/loadout_ability_title_background"
	}
	ImgTitanOrdnanceBG
	{
		ControlName				ImagePanel
		InheritProperties		AbilityBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanOrdnanceTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}

	ImgTitanPassivesTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanOrdnanceBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					2
		image 					"../ui/menu/loadouts/loadout_passive_title_background"
	}

	ImgTitanPassive1BG
	{
		ControlName				ImagePanel
		InheritProperties		PassiveBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanPassivesTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgTitanPassive2BG
	{
		ControlName				ImagePanel
		InheritProperties		PassiveBG
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanPassive1BG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}




	LblTitanSpecialTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanSpecialTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#SPECIAL_ABILITY"
	}
	LblTitanOrdnanceTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanOrdnanceTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#ORDNANCE"
	}
	LblTitanPassivesTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgTitanPassivesTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#PASSIVES_NAME"
	}




	ImgTitanSpecialIcon
	{
		ControlName				ImagePanel
		InheritProperties		AbilityIcon
		classname				"TitanSpecialIcon HideWhenLocked"
		xpos 					0
		ypos 					-4
		pin_to_sibling			ImgTitanSpecialBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblTitanSpecialName
	{
		ControlName				Label
		InheritProperties		AbilityName
		classname				"TitanSpecialName HideWhenLocked"
		pin_to_sibling			ImgTitanSpecialIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos 					8
		ypos 					2
	}
	LblTitanSpecialDesc
	{
		ControlName				Label
		InheritProperties		AbilityDesc
		classname				"TitanSpecialDesc HideWhenLocked"
		pin_to_sibling			ImgTitanSpecialIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos 					8
		ypos 					-13
	}
	ImgTitanOrdnanceIcon
	{
		ControlName				ImagePanel
		InheritProperties		AbilityIcon
		classname				"TitanOrdnanceIcon HideWhenLocked"
		xpos 					0
		ypos 					-4
		pin_to_sibling			ImgTitanOrdnanceBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblTitanOrdnanceName
	{
		ControlName				Label
		InheritProperties		AbilityName
		classname				"TitanOrdnanceName HideWhenLocked"
		pin_to_sibling			ImgTitanOrdnanceIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos 					8
		ypos 					2
	}
	LblTitanOrdnanceDesc
	{
		ControlName				Label
		InheritProperties		AbilityDesc
		classname				"TitanOrdnanceDesc HideWhenLocked"
		pin_to_sibling			ImgTitanOrdnanceIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos 					8
		ypos 					-13
	}


	// Passive 1
	ImgTitanPassive1Icon
	{
		ControlName				ImagePanel
		InheritProperties		PassiveImage
		classname				"TitanPassive1Icon HideWhenLocked"
		xpos					0
		ypos					-4
		pin_to_sibling			ImgTitanPassive1BG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblTitanPassive1Name
	{
		ControlName				Label
		InheritProperties		PassiveName
		classname				"TitanPassive1Name HideWhenLocked"
		pin_to_sibling			ImgTitanPassive1Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					2
	}
	LblTitanPassive1Desc
	{
		ControlName				Label
		InheritProperties		PassiveDesc
		classname				"TitanPassive1Desc HideWhenLocked"
		pin_to_sibling			ImgTitanPassive1Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					-13
	}

	// Passive 2
	ImgTitanPassive2Icon
	{
		ControlName				ImagePanel
		InheritProperties		PassiveImage
		classname				"TitanPassive2Icon HideWhenLocked"
		xpos					0
		ypos					-4
		pin_to_sibling			ImgTitanPassive2BG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblTitanPassive2Name
	{
		ControlName				Label
		InheritProperties		PassiveName
		classname				"TitanPassive2Name HideWhenLocked"
		pin_to_sibling			ImgTitanPassive2Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					2
	}
	LblTitanPassive2Desc
	{
		ControlName				Label
		InheritProperties		PassiveDesc
		classname				"TitanPassive2Desc HideWhenLocked"
		pin_to_sibling			ImgTitanPassive2Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					9
		ypos					-13
	}

	ButtonTooltip
	{
		ControlName				CNestedPanel
		classname				ButtonTooltip
		InheritProperties		ButtonTooltip
		controlSettingsFile		"resource/UI/menus/button_locked_tooltip.res"
	}

	ImgTitanOSVoiceHeaderBG
	{
		ControlName				ImagePanel
		classname				HideWhenLocked
		image 					"../ui/menu/loadouts/loadout_ability_title_background_voice"
		pin_to_sibling			ImgTitanPrimaryTitleBG
		pin_corner_to_sibling	5
		pin_to_sibling_corner	7
		xpos                    4
		ypos					0
		zpos					4
		scaleImage				1
		wide					114
		tall					14
	}

	LblTitanOSVoiceHeader
	{
		ControlName				Label
		classname				"TitanOSVoiceHeader HideWhenLocked"
		xpos					-3
		ypos 					0
		InheritProperties		LoadoutItemTitle
		labelText				"#TITAN_OS_VOICE_HEADER"
		pin_to_sibling			ImgTitanOSVoiceHeaderBG
		pin_corner_to_sibling	5
		pin_to_sibling_corner	5
	}

	LblTitanOSVoiceImage
	{
		ControlName				ImagePanel
		classname				"TitanOSVoiceImage HideWhenLocked"
		xpos					15
		ypos					5
		zpos					11
		wide					40
		tall					40
		image 					""
		visible					1
		scaleImage				1
		pin_to_sibling			ImgTitanOSVoiceHeaderBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	6
	}

}