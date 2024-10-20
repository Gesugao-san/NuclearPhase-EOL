/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Hydrogen
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon = 'icons/obj/items/tanks/tank_blue.dmi'
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	starting_pressure = list(/decl/material/gas/oxygen = 6*ONE_ATMOSPHERE)
	volume = 8
	weight = 2.5

/obj/item/tank/oxygen/yellow
	desc = "A tank of oxygen. This one is yellow."
	icon = 'icons/obj/items/tanks/tank_yellow.dmi'

/obj/item/tank/oxygen/modulated //Will use liquid oxygen and heat it up as needed
	name = "cryogenic oxygen tank"
	volume = 20
	weight = 5

/obj/item/tank/oxygen/empty
	starting_pressure = list()

/*
 * Air
 */
/obj/item/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon = 'icons/obj/items/tanks/tank_blue.dmi'
	starting_pressure = list(/decl/material/gas/oxygen = 6*ONE_ATMOSPHERE*O2STANDARD, /decl/material/gas/nitrogen = 6*ONE_ATMOSPHERE*N2STANDARD)
	volume = 8

/*
 * Hydrogen
 */
/obj/item/tank/hydrogen
	name = "hydrogen tank"
	desc = "Contains hydrogen. Warning: flammable."
	icon = 'icons/obj/items/tanks/tank_greyscaled.dmi'
	color = "#412e87"
	gauge_icon = null
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = null
	starting_pressure = list(/decl/material/gas/hydrogen = 3*ONE_ATMOSPHERE)
	weight = 4

/obj/item/tank/hydrogen/empty
	starting_pressure = list()

/obj/item/tank/xenon
	name = "xenon tank"
	desc = "Contains xenon, an inert gas used in lasers."
	icon = 'icons/obj/items/tanks/tank_greyscaled.dmi'
	color = "#7f2e87"
	gauge_icon = null
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = null
	starting_pressure = list(/decl/material/gas/xenon = 3*ONE_ATMOSPHERE)
	weight = 4

/obj/item/tank/propfuel
	name = "rocket fuel tank"
	desc = "Contains highly flammable rocket fuel."
	icon = 'icons/obj/items/tanks/tank_greyscaled.dmi'
	color = "#dd6f07"
	gauge_icon = null
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = null
	starting_pressure = list(/decl/material/gas/hydrogen = 5*ONE_ATMOSPHERE*0.33, /decl/material/gas/oxygen = 5*ONE_ATMOSPHERE*0.67)
	weight = 4

/obj/item/tank/waste
	name = "waste tank"
	desc = "Contains biological waste and scrubbed CO2."
	icon = 'icons/obj/items/tanks/tank_greyscaled.dmi'
	color = "#472e17"
	gauge_icon = null
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = null
	starting_pressure = list(/decl/material/gas/carbon_dioxide = 2.5*ONE_ATMOSPHERE)
	weight = 2

/obj/item/tank/firefighting
	name = "LCO2 tank"
	desc = "Contains liquid carbon dioxide for firefighting."
	icon = 'icons/obj/items/tanks/tank_greyscaled.dmi'
	color = "#1d1d1d"
	gauge_icon = null
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = null
	starting_pressure = list(/decl/material/gas/helium = 0.3*ONE_ATMOSPHERE, /decl/material/gas/carbon_dioxide = 500*ONE_ATMOSPHERE)
	starting_temperature = 145
	weight = 3
	volume = 15

/obj/item/tank/high_temp_waste
	name = "HT-HE waste tank"
	desc = "This tank can withstand high pressures and temperatures and is useful for storing generator exhaust gas."
	icon = 'icons/obj/items/tanks/tank_greyscaled.dmi'
	color = "#472e17"
	gauge_icon = null
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = null
	weight = 6

/*
 * Emergency Oxygen
 */
/obj/item/tank/emergency
	name = "emergency tank"
	icon = 'icons/obj/items/tanks/tank_emergency.dmi'
	gauge_icon = "indicator_emergency"
	gauge_cap = 4
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_LOWER_BODY
	w_class = ITEM_SIZE_SMALL
	force = 5
	attack_cooldown = DEFAULT_WEAPON_COOLDOWN
	melee_accuracy_bonus = -10
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 0.4 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)
	weight = 0.5

/obj/item/tank/emergency/oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon = 'icons/obj/items/tanks/tank_emergency.dmi'
	gauge_icon = "indicator_emergency"
	starting_pressure = list(/decl/material/gas/oxygen = 10*ONE_ATMOSPHERE)

/obj/item/tank/emergency/oxygen/medical
	name = "medical oxygen tank"
	icon = 'icons/obj/items/tanks/tank_emergency_medical.dmi'
	volume = 5
	distribute_pressure = ONE_ATMOSPHERE

/obj/item/tank/emergency/oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon = 'icons/obj/items/tanks/tank_emergency_engineer.dmi'
	volume = 2
	weight = 0.7

/obj/item/tank/emergency/oxygen/double
	name = "double emergency oxygen tank"
	icon = 'icons/obj/items/tanks/tank_emergency_double.dmi'
	gauge_icon = "indicator_emergency_double"
	volume = 3
	w_class = ITEM_SIZE_NORMAL
	weight = 1

/obj/item/tank/emergency/oxygen/double/red	//firefighting tank, fits on belt, back or suitslot
	name = "self contained breathing apparatus"
	desc = "A self contained breathing apparatus, well known as SCBA. Generally filled with oxygen."
	icon = 'icons/obj/items/tanks/tank_scuba.dmi'
	slot_flags = SLOT_LOWER_BODY | SLOT_BACK
	weight = 4
	volume = 6

/*
 * Nitrogen
 */
/obj/item/tank/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon = 'icons/obj/items/tanks/tank_red.dmi'
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	starting_pressure = list(/decl/material/gas/nitrogen = 10*ONE_ATMOSPHERE)
	volume = 8