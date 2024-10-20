/datum/fabricator_recipe/organ
	category = "Prosthetic Organs"
	path = /obj/item/organ/internal/stomach
	fabricator_types = list(FABRICATOR_CLASS_MEDICAL)
	resources = list(
		/decl/material/solid/plastic = MATTER_AMOUNT_SECONDARY,
		/decl/material/solid/silicon = MATTER_AMOUNT_TRACE,
		/decl/material/solid/lithium = MATTER_AMOUNT_TRACE
	)

/datum/fabricator_recipe/organ/get_product_name()
	. = "prosthetic organ ([..()])"

/datum/fabricator_recipe/organ/build(turf/location, datum/fabricator_build_order/order)
	. = ..()
	var/species = order.get_data("species", global.using_map.default_species)
	for(var/obj/item/organ/internal/I in .)
		I.set_species(species)
		apply_robotize()
		I.status |= ORGAN_CUT_AWAY

/datum/fabricator_recipe/organ/proc/apply_robotize(obj/item/organ/I)
	I.robotize()

/datum/fabricator_recipe/organ/heart
	path = /obj/item/organ/internal/heart

/datum/fabricator_recipe/organ/liver
	path = /obj/item/organ/internal/liver

/datum/fabricator_recipe/organ/kidneys
	path = /obj/item/organ/internal/kidneys

/datum/fabricator_recipe/organ/lungs
	path = /obj/item/organ/internal/lungs

/datum/fabricator_recipe/organ/eyes
	path = /obj/item/organ/internal/eyes


/datum/fabricator_recipe/organ/hydraulic
	category = "Basic Hydraulic Limbs"
	path = null

/datum/fabricator_recipe/organ/hydraulic/get_product_name()
	. = "hydraulic ([..()])"

/datum/fabricator_recipe/organ/hydraulic/apply_robotize(obj/item/organ/I)
	I.robotize(/decl/prosthetics_manufacturer/basic_hydraulic)

/datum/fabricator_recipe/organ/hydraulic/large
	resources = list(
		/decl/material/solid/plastic = MATTER_AMOUNT_PRIMARY*3,
		/decl/material/solid/metal/steel = MATTER_AMOUNT_PRIMARY,
		/decl/material/solid/metal/copper = MATTER_AMOUNT_SECONDARY,
		/decl/material/solid/silicon = MATTER_AMOUNT_TRACE
	)

/datum/fabricator_recipe/organ/hydraulic/small
	resources = list(
		/decl/material/solid/plastic = MATTER_AMOUNT_PRIMARY,
		/decl/material/solid/metal/steel = MATTER_AMOUNT_SECONDARY,
		/decl/material/solid/metal/copper = MATTER_AMOUNT_TRACE,
		/decl/material/solid/silicon = MATTER_AMOUNT_TRACE
	)

/datum/fabricator_recipe/organ/hydraulic/large/r_leg
	path = /obj/item/organ/external/leg/right

/datum/fabricator_recipe/organ/hydraulic/large/l_leg
	path = /obj/item/organ/external/leg

/datum/fabricator_recipe/organ/hydraulic/large/r_arm
	path = /obj/item/organ/external/arm/right

/datum/fabricator_recipe/organ/hydraulic/large/l_arm
	path = /obj/item/organ/external/arm

/datum/fabricator_recipe/organ/hydraulic/small/r_foot
	path = /obj/item/organ/external/foot/right

/datum/fabricator_recipe/organ/hydraulic/small/l_foot
	path = /obj/item/organ/external/foot

/datum/fabricator_recipe/organ/hydraulic/small/r_hand
	path = /obj/item/organ/external/hand/right

/datum/fabricator_recipe/organ/hydraulic/small/l_hand
	path = /obj/item/organ/external/hand