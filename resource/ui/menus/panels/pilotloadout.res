"resource/ui/menus/panels/pilotloadout.res"
{
	ImgPilotCharacter
	{
		ControlName				ImagePanel
		InheritProperties		PilotBodyImage
		classname				"PilotBodyImage HideWhenLocked"
		ypos					40
		xpos 					-182
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgPilotSpecialTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		xpos					207
		ypos 					75
		image 					"../ui/menu/loadouts/loadout_ability_title_background"
	}
	LblPilotSpecialTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSpecialTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#SPECIAL_ABILITY"
	}


	ImgPilotSpecialBG
	{
		ControlName				ImagePanel
		InheritProperties		AbilityBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSpecialTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotSpecialIcon
	{
		ControlName				ImagePanel
		InheritProperties		AbilityIcon
		classname				"PilotSpecialIcon HideWhenLocked"
		xpos 					0
		ypos 					-4
		pin_to_sibling			ImgPilotSpecialBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblPilotSpecialName
	{
		ControlName				Label
		InheritProperties		AbilityName
		classname				"PilotSpecialName HideWhenLocked"
		pin_to_sibling			ImgPilotSpecialIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					2
	}
	LblPilotSpecialDesc
	{
		ControlName				Label
		InheritProperties		AbilityDesc
		classname				"PilotSpecialDesc HideWhenLocked"
		pin_to_sibling			ImgPilotSpecialIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					-13
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgPilotOrdnanceTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSpecialBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		image 					"../ui/menu/loadouts/loadout_ability_title_background"
	}
	LblPilotOrdnanceTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotOrdnanceTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#ORDNANCE"
	}


	ImgPilotOrdnanceBG
	{
		ControlName				ImagePanel
		InheritProperties		AbilityBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotOrdnanceTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotOrdnanceIcon
	{
		ControlName				ImagePanel
		InheritProperties		AbilityIcon
		classname				"PilotOrdnanceIcon HideWhenLocked"
		xpos 					0
		ypos 					-4
		pin_to_sibling			ImgPilotOrdnanceBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblPilotOrdnanceName
	{
		ControlName				Label
		InheritProperties		AbilityName
		classname				"PilotOrdnanceName HideWhenLocked"
		pin_to_sibling			ImgPilotOrdnanceIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					2
	}
	LblPilotOrdnanceDesc
	{
		ControlName				Label
		InheritProperties		AbilityDesc
		classname				"PilotOrdnanceDesc HideWhenLocked"
		pin_to_sibling			ImgPilotOrdnanceIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					-13
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgPilotPrimaryTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		xpos					4
		ypos					0
		image 					"../ui/menu/loadouts/loadout_weapon_title_background"

		pin_to_sibling			ImgPilotSpecialTitleBG
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0

	}
	LblPilotPrimaryTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotPrimaryTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#PRIMARY_WEAPON"
	}

	// BackgroundTest
	// {
	// 	ControlName				ImagePanel
	// 	xpos					0
	// 	ypos					0
	// 	wide					f0
	// 	tall					f0
	// 	image 					"../ui/temp"
	// 	visible					1
	// 	scaleImage				1
	// }

	ImgPilotPrimaryBG
	{
		ControlName				ImagePanel
		InheritProperties		PilotWeaponBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotPrimaryTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotPrimaryImage
	{
		ControlName				ImagePanel
		InheritProperties		WeaponImage
		classname				"PilotPrimaryImage HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos 					-5
	}
	LblPilotPrimaryName
	{
		ControlName				Label
		InheritProperties		WeaponName
		classname				"PilotPrimaryName HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos					2
		ypos 					-4
	}
	LblPilotPrimaryDesc
	{
		ControlName				Label
		InheritProperties		WeaponDesc
		classname 				"PilotPrimaryDesc HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos 					1
		ypos 					10
	}


	ImgPilotPrimaryAttachmentIcon
	{
		ControlName				ImagePanel
		InheritProperties		WeaponModIcon
		classname				"PilotPrimaryAttachmentIcon HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryBG
		pin_corner_to_sibling	2
		pin_to_sibling_corner	2
	}
	LblPilotPrimaryAttachmentName
	{
		ControlName				Label
		InheritProperties		ItemPropertyValue
		classname				"PilotPrimaryAttachmentName HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryAttachmentIcon
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
		xpos					4
		ypos					0
	}


	ImgPilotPrimaryModIcon
	{
		ControlName				ImagePanel
		InheritProperties		WeaponModIcon
		classname				"PilotPrimaryModIcon HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryBG
		pin_corner_to_sibling	2
		pin_to_sibling_corner	2
		xpos 					-106
	}
	LblPilotPrimaryModName
	{
		ControlName				Label
		InheritProperties		ItemPropertyValue
		classname				"PilotPrimaryModName HideWhenLocked"
		pin_to_sibling			ImgPilotPrimaryModIcon
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
		xpos					4
		ypos					0
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgPilotSecondaryTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotPrimaryBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					2
		image 					"../ui/menu/loadouts/loadout_weapon_title_background"
	}
	LblPilotSecondaryTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSecondaryTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#ANTI_TITAN_WEAPON"
	}


	ImgPilotSecondaryBG
	{
		ControlName				ImagePanel
		InheritProperties		PilotATWeaponBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSecondaryTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotSecondaryImage
	{
		ControlName				ImagePanel
		InheritProperties		WeaponImage
		classname				"PilotSecondaryImage HideWhenLocked"
		pin_to_sibling			ImgPilotSecondaryBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos 					-5
	}
	LblPilotSecondaryName
	{
		ControlName				Label
		InheritProperties		WeaponName
		classname				"PilotSecondaryName HideWhenLocked"
		pin_to_sibling			ImgPilotSecondaryImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos					2
		ypos 					-1
	}
	LblPilotSecondaryDesc
	{
		ControlName				Label
		InheritProperties		WeaponDesc
		classname 				"PilotSecondaryDesc HideWhenLocked"
		pin_to_sibling			ImgPilotSecondaryImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos 					1
		ypos 					12
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgPilotSidearmTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSecondaryBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					2
		image 					"../ui/menu/loadouts/loadout_weapon_title_background"
	}
	LblPilotSidearmTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSidearmTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#SIDEARM"
	}


	ImgPilotSidearmBG
	{
		ControlName				ImagePanel
		InheritProperties		SidearmBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotSidearmTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotSidearmImage
	{
		ControlName				ImagePanel
		InheritProperties		WeaponImage
		classname				"PilotSidearmImage HideWhenLocked"
		pin_to_sibling			ImgPilotSidearmBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos 					-5
	}
	LblPilotSidearmName
	{
		ControlName				Label
		InheritProperties		WeaponName
		classname				"PilotSidearmName HideWhenLocked"
		pin_to_sibling			ImgPilotSidearmImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos					2
		ypos					-1
	}
	LblPilotSidearmDesc
	{
		ControlName				Label
		InheritProperties		WeaponDesc
		classname 				"PilotSidearmDesc HideWhenLocked"
		pin_to_sibling			ImgPilotSidearmImage
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos 					1
		ypos 					12
	}

	ImgPilotSidearmModIcon
	{
		ControlName				ImagePanel
		InheritProperties		WeaponModIcon
		classname				"PilotSidearmModIcon HideWhenLocked"
		pin_to_sibling			ImgPilotSidearmBG
		pin_corner_to_sibling	2
		pin_to_sibling_corner	2
		xpos 					-106
	}
	LblPilotSidearmModName
	{
		ControlName				Label
		InheritProperties		ItemPropertyValue
		classname				"PilotSidearmModName HideWhenLocked"
		pin_to_sibling			ImgPilotSidearmModIcon
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
		xpos					4
		ypos					0
	}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ImgPilotPassivesTitleBG
	{
		ControlName				ImagePanel
		InheritProperties		LoadoutItemTitleBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotOrdnanceBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					2
		image 					"../ui/menu/loadouts/loadout_passive_title_background"
	}
	LblPilotPassivesTitle
	{
		ControlName				Label
		InheritProperties		LoadoutItemTitle
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotPassivesTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos					-3
		labelText				"#PASSIVES_NAME"
	}


	ImgPilotPassive1BG
	{
		ControlName				ImagePanel
		InheritProperties		PassiveBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotPassivesTitleBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotPassive1Icon
	{
		ControlName				ImagePanel
		InheritProperties		PassiveImage
		classname				"PilotPassive1Icon HideWhenLocked"
		xpos 					0
		ypos 					-4
		pin_to_sibling			ImgPilotPassive1BG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblPilotPassive1Name
	{
		ControlName				Label
		InheritProperties		PassiveName
		classname				"PilotPassive1Name HideWhenLocked"
		pin_to_sibling			ImgPilotPassive1Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					2
	}
	LblPilotPassive1Desc
	{
		ControlName				Label
		InheritProperties		PassiveDesc
		classname				"PilotPassive1Desc HideWhenLocked"
		pin_to_sibling			ImgPilotPassive1Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					-13
	}


	ImgPilotPassive2BG
	{
		ControlName				ImagePanel
		InheritProperties		PassiveBG
		classname				HideWhenLocked
		pin_to_sibling			ImgPilotPassive1BG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ImgPilotPassive2Icon
	{
		ControlName				ImagePanel
		InheritProperties		PassiveImage
		classname				"PilotPassive2Icon HideWhenLocked"
		xpos 					0
		ypos 					-4
		pin_to_sibling			ImgPilotPassive2BG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	LblPilotPassive2Name
	{
		ControlName				Label
		InheritProperties		PassiveName
		classname				"PilotPassive2Name HideWhenLocked"
		pin_to_sibling			ImgPilotPassive2Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					2
	}
	LblPilotPassive2Desc
	{
		ControlName				Label
		InheritProperties		PassiveDesc
		classname				"PilotPassive2Desc HideWhenLocked"
		pin_to_sibling			ImgPilotPassive2Icon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		xpos					8
		ypos					-13
	}
}