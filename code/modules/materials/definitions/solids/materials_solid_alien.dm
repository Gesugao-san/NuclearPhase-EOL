/decl/material/solid/metal/aliumium
	name = "alien alloy"
	uid = "solid_alien"
	icon_base = 'icons/turf/walls/metal.dmi'
	wall_flags = PAINT_PAINTABLE
	door_icon_base = "metal"
	icon_reinf = 'icons/turf/walls/reinforced_metal.dmi'
	hitsound = 'sound/weapons/smash.ogg'
	construction_difficulty = MAT_VALUE_VERY_HARD_DIY
	hidden_from_codex = TRUE
	value = 2.5
	default_solid_form = /obj/item/stack/material/cubes
	exoplanet_rarity = MAT_RARITY_EXOTIC

/decl/material/solid/metal/aliumium/Initialize()
	icon_base = 'icons/turf/walls/metal.dmi'
	wall_flags = PAINT_PAINTABLE
	color = rgb(rand(10,150),rand(10,150),rand(10,150))
	explosion_resistance = rand(25,40)
	brute_armor = rand(10,20)
	burn_armor = rand(10,20)
	hardness = rand(15,100)
	reflectiveness = rand(15,100)
	integrity = rand(200,400)
	melting_point = rand(400,11000)
	. = ..()

/decl/material/solid/metal/aliumium/place_dismantled_girder(var/turf/target, var/decl/material/reinf_material)
	return

/decl/material/solid/static_crystal
	name = "SREC"
	uid = "polycrystal"
	lore_text = "An agressive silicon lifeform crystal. Due to its electrostatic properties it's able to contain antimatter relatively safely. It doesn't contain any right now."
	default_solid_form = /obj/item/stack/material/gemstone
	narcosis = 0.15
	toxicity = 1.5
	radioactivity = 50
	chilling_point = 190
	chilling_message = "crumples into a very fine dust."
	chilling_products = list(
		/decl/material/solid/static_crystal/inhibited = 0.81,
		/decl/material/solid/silicon = 0.19
	)
	shard_type = SHARD_SHARD
	shard_can_repair = 0
	flags = MAT_FLAG_BRITTLE
	opacity = 0.3
	integrity = 50
	destruction_desc = "shatters"
	weight = MAT_VALUE_VERY_LIGHT
	hardness = MAT_VALUE_VERY_HARD
	reflectiveness = MAT_VALUE_VERY_SHINY
	color = COLOR_SREC

/decl/material/solid/static_crystal/affect_blood(mob/living/carbon/human/M, removed, datum/reagents/holder)
	. = ..()
	M.srec_dose += removed*1.3

/decl/material/solid/static_crystal/inhibited
	name = "inhibited SREC"
	uid = "inhibited_polycrystal"
	codex_name = "inhibited SREC"
	lore_text = "An agressive silicon lifeform crystal, having now lost its spreading abilities."
	toxicity = 0
	radioactivity = 0
	chilling_point = null
	chilling_message = null
	chilling_products = null

/decl/material/solid/static_crystal/antimatter
	name = "SREC-A"
	uid = "antimatter_polycrystal"
	combustion_energy = 810801000
	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 0.1,
			INTERACTION_ABSORPTION = 0.1,
			INTERACTION_FISSION = 5000
		),
		"fast" = list(
			INTERACTION_SCATTER = 0.1,
			INTERACTION_ABSORPTION = 0.1,
			INTERACTION_FISSION = 10000
		)
	)
	fission_energy = 810801000
	fission_products = list(
		/decl/material/solid/static_crystal = 0.1
	)
	fission_neutrons = 250
	radioactivity = 500
	gas_flags = XGM_GAS_FUEL|XGM_GAS_OXIDIZER
	fuel_value = 10
	ignition_point = TCMB
	molar_mass = 0.004 //twice that of hydrogen
	color = COLOR_SREC_ALPHA