/decl/prosthetics_manufacturer/wooden
	name = "Wooden - Basic"
	desc = "A crude wooden prosthetic."
	icon = 'icons/mob/species/cyberlimbs/wooden.dmi'
	modifier_string = "wooden"
	hardiness = 0.75
	manual_dexterity = DEXTERITY_SIMPLE_MACHINES
	movement_slowdown = 1
	is_robotic = FALSE
	modular_prosthetic_tier = MODULAR_BODYPART_PROSTHETIC

DEFINE_ROBOLIMB_MODEL_ASPECTS(/decl/prosthetics_manufacturer/wooden, pirate, 0)

/decl/prosthetics_manufacturer/basic_hydraulic
	name = "Hydraulic - Basic"
	desc = "A basic mechanised metal prosthetic. Prone to failures."
	modifier_string = "hydraulic"
	hardiness = 1.15
	lifting_boost_coefficient = 0.7
	movement_slowdown = 0.5
	manual_dexterity = DEXTERITY_TOUCHSCREENS
	modular_prosthetic_tier = MODULAR_BODYPART_PROSTHETIC

DEFINE_ROBOLIMB_MODEL_ASPECTS(/decl/prosthetics_manufacturer/basic_hydraulic, hydraulic_basic, 1)

/decl/prosthetics_manufacturer/advanced_hydraulic
	name = "Hydraulic - Advanced"
	desc = "A significantly more advanced model of prosthethics, this one does not hinder movement."
	modifier_string = "hydraulic"
	hardiness = 1.25
	lifting_boost_coefficient = 1.4
	movement_slowdown = 0
	manual_dexterity = DEXTERITY_WEAPONS
	modular_prosthetic_tier = MODULAR_BODYPART_PROSTHETIC
	can_eat = 1

DEFINE_ROBOLIMB_MODEL_ASPECTS(/decl/prosthetics_manufacturer/advanced_hydraulic, hydraulic_advanced, 3)

/decl/prosthetics_manufacturer/basic_biomech
	name = "Biomechanical - Basic"
	desc = "A very fragile but powerful and dextrous prosthetic."
	modifier_string = "biomech"
	hardiness = 0.85
	lifting_boost_coefficient = 1.1
	movement_slowdown = 0
	manual_dexterity = DEXTERITY_COMPLEX_TOOLS
	modular_prosthetic_tier = MODULAR_BODYPART_PROSTHETIC
	can_eat = 1

DEFINE_ROBOLIMB_MODEL_ASPECTS(/decl/prosthetics_manufacturer/basic_biomech, biomech_basic, 4)

/decl/prosthetics_manufacturer/advanced_biomech
	name = "Biomechanical - Advanced"
	desc = "An advanced prosthetic capable of extremely precise movement."
	modifier_string = "" //sneaky
	hardiness = 1.35
	lifting_boost_coefficient = 1.3
	movement_slowdown = -1.5
	manual_dexterity = DEXTERITY_FULL
	modular_prosthetic_tier = MODULAR_BODYPART_CYBERNETIC
	can_feel_pain = TRUE
	can_eat = 1

/decl/prosthetics_manufacturer/advanced_biomech/get_base_icon(mob/living/carbon/human/owner, masked)
	if(owner.gender == MALE)
		if(!masked)
			return 'icons/mob/species/cyberlimbs/biomech_male.dmi'
		return 'icons/mob/species/human/body_male.dmi'
	else
		if(!masked)
			return 'icons/mob/species/cyberlimbs/biomech_female.dmi'
		return 'icons/mob/species/human/body_female.dmi'

/decl/prosthetics_manufacturer/exo_biomech
	name = "Exomechanical - Advanced"
	modifier_string = "exomech"
	hardiness = 1.75
	lifting_boost_coefficient = 2.4
	movement_slowdown = -2
	manual_dexterity = DEXTERITY_FULL
	modular_prosthetic_tier = MODULAR_BODYPART_CYBERNETIC
	can_feel_pain = TRUE
	can_eat = 1