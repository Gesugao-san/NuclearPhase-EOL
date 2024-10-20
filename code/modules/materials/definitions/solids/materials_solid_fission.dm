/decl/material/solid/metal/uranium
	name = "uranium 235"
	codex_name = "elemental uranium"
	uid = "solid_uranium"
	lore_text = "A silvery-white metallic chemical element in the actinide series, weakly radioactive. Commonly used as fuel in fission reactors."
	mechanics_text = "Uranium can be used as fuel in fission reactors."
	taste_description = "the inside of a reactor"
	flags = MAT_FLAG_FISSIBLE
	radioactivity = 0.8
	icon_base = 'icons/turf/walls/stone.dmi'
	wall_flags = 0
	table_icon_base = "stone"
	icon_reinf = 'icons/turf/walls/reinforced_stone.dmi'
	color = "#aee90d"
	weight = MAT_VALUE_VERY_HEAVY
	stack_origin_tech = "{'materials':5}"
	reflectiveness = MAT_VALUE_MATTE
	value = 1.5
	default_solid_form = /obj/item/stack/material/puck
	exoplanet_rarity = MAT_RARITY_UNCOMMON

	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 10,
			INTERACTION_ABSORPTION = 99,
			INTERACTION_FISSION = 583
		),
		"fast" = list(
			INTERACTION_SCATTER = 4,
			INTERACTION_ABSORPTION = 0.09,
			INTERACTION_FISSION = 1
		)
	)
	fission_products = list(
		/decl/material/solid/metal/depleted_uranium = 0.3,
		/decl/material/solid/metal/nuclear_waste/transuranic = 0.6,
		/decl/material/solid/metal/nuclear_waste/actinides = 0.05,
		/decl/material/gas/xenon = 0.05
	)
	absorption_products = list(
		/decl/material/solid/metal/neptunium = 1
	)
	neutron_production = 1000
	neutron_absorption = 60
	moderation_target = 3000
	fission_heat = 35000
	fission_energy = 21080100000.0
	fission_neutrons = 2.45

/decl/material/solid/metal/depleted_uranium
	name = "uranium 238"
	uid = "solid_depleted_uranium"
	lore_text = "Uranium that does not posess a significant amount of radioactive isotopes. Extremely dense, and can be enriched to produce more fission fuel."
	mechanics_text = "Depleted uranium can be enriched in fission reactors for use as fuel."
	taste_description = "the outside of a reactor"
	flags = MAT_FLAG_FISSIBLE
	radioactivity = 0.12
	icon_base = 'icons/turf/walls/stone.dmi'
	table_icon_base = "stone"
	icon_reinf = 'icons/turf/walls/reinforced_stone.dmi'
	color = "#dae90d"
	value = 1.5
	exoplanet_rarity = MAT_RARITY_UNCOMMON

	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 9,
			INTERACTION_ABSORPTION = 2,
			INTERACTION_FISSION = 0.00002
		),
		"fast" = list(
			INTERACTION_SCATTER = 5,
			INTERACTION_ABSORPTION = 0.07,
			INTERACTION_FISSION = 0.3
		)
	)
	absorption_products = list(
		/decl/material/solid/metal/plutonium = 0.8
	)
	fission_products = list(
		/decl/material/solid/metal/plutonium = 0.8,
		/decl/material/solid/metal/radium = 0.1,
		/decl/material/gas/xenon = 0.05
	)
	fission_heat = 35000
	fission_energy = 81080100000.0
	fission_neutrons = 0.001
	neutron_absorption = 950
	neutron_production = 900


/decl/material/solid/metal/neptunium // Np-237.
	name = "neptunium"
	uid = "solid_neptunium"
	lore_text = "A byproduct of uranium undergoing beta decay. Extremely radioactive, can be used as fission fuel, with difficulty."
	mechanics_text = "Neptunium can be used as fuel in fission reactors at high neutron energies."
	taste_description = "lemon juice and hot concrete."
	flags = MAT_FLAG_FISSIBLE
	radioactivity = 17
	icon_base = 'icons/turf/walls/stone.dmi'
	table_icon_base = "stone"
	icon_reinf = 'icons/turf/walls/reinforced_stone.dmi'
	color = "#3c6075"
	value = 0.5
	exoplanet_rarity = MAT_RARITY_UNCOMMON
	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 9,
			INTERACTION_ABSORPTION = 0.07,
			INTERACTION_FISSION = 0.00002
		),
		"fast" = list(
			INTERACTION_SCATTER = 3,
			INTERACTION_ABSORPTION = 0.14,
			INTERACTION_FISSION = 348
		)
	)
	fission_energy = 13917914000.0
	fission_neutrons = 1.5
	neutron_cross_section = 4 // Difficult to use as fuel.
	fission_products = list(
		/decl/material/solid/metal/plutonium = 1
	)

/decl/material/solid/metal/plutonium
	name = "plutonium"
	uid = "solid_plutonium"
	lore_text = "A mundane silver-grey metal that is highly fissible. Often used as fuel in nuclear fission reactors and weapons."
	mechanics_text = "Plutonium can be used as fuel in fission reactors."
	taste_description = "nuclear fallout"
	flags = MAT_FLAG_FISSIBLE
	radioactivity = 8
	icon_base = 'icons/turf/walls/stone.dmi'
	table_icon_base = "stone"
	icon_reinf = 'icons/turf/walls/reinforced_stone.dmi'
	color = "#c9beb2"
	value = 3
	exoplanet_rarity = MAT_RARITY_UNCOMMON

	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 8,
			INTERACTION_ABSORPTION = 269,
			INTERACTION_FISSION = 748
		),
		"fast" = list(
			INTERACTION_SCATTER = 5,
			INTERACTION_ABSORPTION = 0.05,
			INTERACTION_FISSION = 2
		)
	)
	fission_products = list(
		/decl/material/solid/metal/nuclear_waste/high_level = 0.85,
		/decl/material/solid/metal/nuclear_waste/actinides = 0.05,
		/decl/material/gas/xenon = 0.1
	)
	neutron_production = 1200
	neutron_absorption = 30
	fission_heat = 60000
	fission_energy = 83917914000.0
	fission_neutrons = 3

/decl/material/solid/metal/plutonium/affect_blood(mob/living/carbon/human/M, removed, datum/reagents/holder)
	. = ..()
	var/volume = REAGENT_VOLUME(holder, type)
	M.apply_damage(2 * volume, IRRADIATE)

// Do not use this type.
/decl/material/solid/metal/nuclear_waste
	name = "nuclear waste"
	uid = "nuclear_waste"
	lore_text = "A crazy mix of hundreds of isotopes of unreactive nuclear fuel. Extremely radioactive, yet almost useless in reactors."
	mechanics_text = "Nuclear waste can be processed into various exotic chemicals."
	taste_description = "heavy metal"
	color = "#bb771e"
	value = 0.5
	exoplanet_rarity = MAT_RARITY_NOWHERE // Don't spawn this in plants.
	icon_base = 'icons/turf/walls/natural.dmi' // So we can have corium
	table_icon_base = "stone"
	icon_reinf = 'icons/turf/walls/reinforced_stone.dmi'
	dissolves_into = list(
		/decl/material/solid/metal/radium = 0.5,
		/decl/material/solid/lithium = 0.5
	)

// Rich with plutonium and americium, burns quickly in fusion conditions
/decl/material/solid/metal/nuclear_waste/transuranic
	name = "transuranic nuclear waste"
	uid = "nuclear_waste_tu"
	radioactivity = 37
	fission_neutrons = 0.2
	fission_energy = 51080100000.0
	color = "#d8881e"
	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 5,
			INTERACTION_ABSORPTION = 2,
			INTERACTION_FISSION = 0.00002
		),
		"fast" = list(
			INTERACTION_SCATTER = 5,
			INTERACTION_ABSORPTION = 0.13,
			INTERACTION_FISSION = 0.15
		)
	)
	fission_products = list(
		/decl/material/solid/metal/nuclear_waste/high_level = 0.8
	)

// Rich with long lived isotopes that burn slowly in fusion conditions
/decl/material/solid/metal/nuclear_waste/high_level
	name = "high level nuclear waste"
	uid = "nuclear_waste_hl"
	radioactivity = 42
	fission_neutrons = 0.01
	fission_energy = 15080100000.0
	color = "#704d1f"
	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 3,
			INTERACTION_ABSORPTION = 4,
			INTERACTION_FISSION = 0.00001
		),
		"fast" = list(
			INTERACTION_SCATTER = 3,
			INTERACTION_ABSORPTION = 0.17,
			INTERACTION_FISSION = 0.04
		)
	)
	fission_products = list(
		/decl/material/solid/metal/nuclear_waste/actinides = 0.8
	)

// A collection of extremely long half-life isotopes. Can only be completely burned off in a particle accelerator.
// Bring the nuclear caskets
/decl/material/solid/metal/nuclear_waste/actinides
	name = "nuclear actinides"
	uid = "nuclear_waste_act"
	radioactivity = 11
	color = "#4b371e"
	neutron_interactions = list(
		"slow" = list(
			INTERACTION_SCATTER = 1.2,
			INTERACTION_ABSORPTION = 7
		),
		"fast" = list(
			INTERACTION_SCATTER = 1.2,
			INTERACTION_ABSORPTION = 0.26
		)
	)

/decl/material/solid/metal/nuclear_waste/affect_blood(mob/living/carbon/human/M, removed, datum/reagents/holder)
	. = ..()
	var/volume = REAGENT_VOLUME(holder, type)
	if(!M.bloodstr.has_reagent(/decl/material/liquid/potassium_iodide, 0.1))
		M.apply_damage(1.5 * volume, IRRADIATE)
	else
		M.apply_damage(0.1 * volume, IRRADIATE)

// Made when actinides are heated up in presence of silicon.
/decl/material/solid/metal/nuclear_waste/actinides/vitrified
	name = "vitrified nuclear waste"
	lore_text = "High-actinide nuclear waste that has been made into a glass."
	radioactivity = 0.6
	color = "#2c2823"