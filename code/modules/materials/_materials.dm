var/global/list/materials_by_gas_symbol = list()

/obj/effect/gas_overlay
	name = "gas"
	desc = "You shouldn't be clicking this."
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "generic"
	layer = FIRE_LAYER
	appearance_flags = RESET_COLOR
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	var/decl/material/material

INITIALIZE_IMMEDIATE(/obj/effect/gas_overlay)

/obj/effect/gas_overlay/proc/update_alpha_animation(var/new_alpha)
	animate(src, alpha = new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0.8 * new_alpha, time = 10, easing = SINE_EASING | EASE_OUT, loop = -1)
	animate(alpha = new_alpha, time = 10, easing = SINE_EASING | EASE_IN, loop = -1)

/obj/effect/gas_overlay/Initialize(mapload, gas)
	. = ..()
	material = GET_DECL(gas)
	if(!istype(material))
		return INITIALIZE_HINT_QDEL
	if(material.gas_tile_overlay)
		icon_state = material.gas_tile_overlay
	color = material.color

/*
	MATERIAL DATUMS
	This data is used by various parts of the game for basic physical properties and behaviors
	of the metals/materials used for constructing many objects. Each var is commented and should be pretty
	self-explanatory but the various object types may have their own documentation.

	PATHS THAT USE DATUMS
		turf/simulated/wall
		obj/item
		obj/structure/barricade
		obj/structure/table

	VALID ICONS
		WALLS
			stone
			metal
			solid
			cult
		DOORS
			stone
			metal
			plastic
			wood
*/

//Returns the material the object is made of, if applicable.
//Will we ever need to return more than one value here? Or should we just return the "dominant" material.
/obj/proc/get_material()
	return

//mostly for convenience
/obj/proc/get_material_type()
	var/decl/material/mat = get_material()
	. = mat && mat.type

// Material definition and procs follow.
/decl/material

	abstract_type = /decl/material

	var/name               // Prettier name for display.
	var/codex_name         // Override for the codex article name.
	var/adjective_name
	var/solid_name
	var/gas_name
	var/liquid_name
	var/use_name
	var/wall_name = "wall" // Name given to walls of this material
	var/flags = 0          // Various status modifiers.
	var/hidden_from_codex
	var/lore_text
	var/mechanics_text
	var/antag_text
	var/drug_category
	var/default_solid_form = /obj/item/stack/material/sheet

	var/affect_blood_on_ingest = TRUE

	var/narcosis = 0 // Not a great word for it. Constant for causing mild confusion when ingested.
	var/toxicity = 0 // Organ damage from ingestion.
	var/toxicity_targets_organ // Bypass liver/kidneys when ingested, harm this organ directly (using BP_FOO defines).

	// Shards/tables/structures
	var/shard_type = SHARD_SHRAPNEL       // Path of debris object.
	var/shard_icon                        // Related to above.
	var/shard_can_repair = 1              // Can shards be turned into sheets with a welder?
	var/list/recipes                      // Holder for all recipes usable with a sheet of this material.
	var/list/strut_recipes                // Holder for all the recipes you can build with the struct stack type.
	var/destruction_desc = "breaks apart" // Fancy string for barricades/tables/objects exploding.

	// Icons
	var/icon_base = 'icons/turf/walls/solid.dmi'
	var/icon_base_natural = 'icons/turf/walls/natural.dmi'
	var/icon_reinf = 'icons/turf/walls/reinforced_metal.dmi'
	var/wall_flags = 0
	var/list/wall_blend_icons = list() // Which wall icon types walls of this material type will consider blending with. Assoc list (icon path = TRUE/FALSE)
	var/use_reinf_state = "full"

	var/door_icon_base = "metal"                         // Door base icon tag. See header.
	var/table_icon_base = "metal"
	var/table_icon_reinforced = "reinf_metal"

	var/list/stack_origin_tech = @'{"materials":1}' // Research level for stacks.

	// Attributes
	/// How rare is this material generally?
	var/exoplanet_rarity = MAT_RARITY_MUNDANE
	/// Delay in ticks when cutting through this wall.
	var/cut_delay = 0

	// Physics properties
	/// mSv/mol, radiation passively emitted by the material.
	var/radioactivity = 0
	/// K, point at which the material catches on fire.
	var/ignition_point
	/// K, point that material will become a gas.
	var/boiling_point = 3000
	/// K, point that material will become a liquid.
	var/melting_point = 700
	/// J/mol, enthalpy of vaporization
	var/latent_heat = 7000
	/// J/mol, enthalpy of fusion (solid into liquid). Calculates itself, don't set unless you have an exact value for a specific material.
	var/fusion_enthalpy
	/// kg/mol, molar mass of the element
	var/molar_mass = 0.06
	var/gas_molar_mass //placeholder, to be removed
	/// ml/mol, multiply moles by this to get mL. Divide mL by this to get moles.
	var/molar_volume
	/// j/mol*k, how much joules we need to heat up one mol of material by one degree
	var/gas_specific_heat = 20
	/// J/mol
	var/combustion_energy = 0
	var/combustion_activation_energy = 75300
	var/list/combustion_products // Associative list of Oxidizer = Result
	var/oxidizer_to_fuel_ratio = 1 // How much moles of oxidizer is consumed per mole of consumed fuel.
	var/oxidizer_power = 0 // The power of this material as an oxidizer, arbitrary, 1-10
	/// kg/m3
	var/liquid_density = 1000
	var/solid_density = 1000

	/// Brute damage to a wall is divided by this value if the wall is reinforced by this material.
	var/brute_armor = 2
	/// Same as above, but for Burn damage type. If blank brute_armor's value is used.
	var/burn_armor
	/// General-use HP value for products.
	var/integrity = 150
	/// Is the material transparent? 0.5< makes transparent walls/doors.
	var/opacity = 1
	/// Only used by walls currently.
	var/explosion_resistance = 700
	/// Objects with this var add CONDUCTS to flags on spawn.
	var/conductive = 1
	/// Does this material glow?
	var/luminescence
	/// Used for checking if a material can function as a wall support.
	var/wall_support_value = 30
	/// Ore generation constant for rare materials.
	var/sparse_material_weight
	/// Ore generation constant for common materials.
	var/rich_material_weight
	/// How transparent can fluids be?
	var/min_fluid_opacity = FLUID_MIN_ALPHA
	/// How opaque can fluids be?
	var/max_fluid_opacity = FLUID_MAX_ALPHA
	/// Point at which the fluid will proc turf interaction logic. Workaround for mops being ruined forever by 1u of anything else being added.
	var/turf_touch_threshold = FLUID_QDEL_POINT

	// Damage values.
	var/hardness = MAT_VALUE_HARD            // Used for edge damage in weapons.
	var/reflectiveness = MAT_VALUE_DULL

	var/weight = MAT_VALUE_NORMAL             // Determines blunt damage/throwforce for weapons.

	// Noise when someone is faceplanted onto a table made of this material.
	var/tableslam_noise = 'sound/weapons/tablehit1.ogg'
	// Noise made when a simple door made of this material opens or closes.
	var/dooropen_noise = 'sound/effects/stonedoor_openclose.ogg'
	// Noise made when you hit structure made of this material.
	var/hitsound = 'sound/weapons/genhit.ogg'
	// Wallrot crumble message.
	var/rotting_touch_message = "crumbles under your touch"
	// Modifies skill checks when constructing with this material.
	var/construction_difficulty = MAT_VALUE_EASY_DIY
	// Determines what is used to remove or dismantle this material.
	var/removed_by_welder

	// Mining behavior.
	var/ore_name
	var/ore_desc
	var/ore_smelts_to
	var/ore_compresses_to
	var/ore_result_amount
	var/ore_spread_chance
	var/ore_scan_icon
	var/ore_icon_overlay
	var/ore_type_value
	var/ore_data_value

	var/value = 1

	// Xenoarch behavior.
	var/xarch_source_mineral = /decl/material/solid/metal/iron

	// Gas behavior.
	var/gas_overlay_limit
	var/gas_symbol_html
	var/gas_symbol
	var/gas_flags = 0
	var/gas_tile_overlay = "generic"
	var/gas_condensation_point = null
	var/gas_metabolically_inert = FALSE // If false, material will move into the bloodstream when breathed.
	// Armor values generated from properties
	var/list/basic_armor
	var/armor_degradation_speed

	// Copied reagent values. Todo: integrate.
	var/taste_description = "old rotten bandaids"
	var/taste_mult = 1 //how this taste compares to others. Higher values means it is more noticable
	var/metabolism = REM // Ratio of reagents removed per tick. 0.01 means 1% of the reagent volume will be metabolized
	var/ingest_met = 0
	var/touch_met = 0
	var/overdose = 0
	var/scannable = 0 // Shows up on health analyzers.
	var/color = COLOR_BEIGE
	var/color_weight = 1
	var/fire_color = FIRE_COLOR_DEFAULT
	var/fire_alpha = 200 //how visible is the fire
	var/cocktail_ingredient
	var/defoliant
	var/fruit_descriptor // String added to fruit desc if this chemical is present.

	var/dirtiness = DIRTINESS_NEUTRAL // How dirty turfs are after being exposed to this material. Negative values cause a cleaning/sterilizing effect.
	var/solvent_power = MAT_SOLVENT_NONE
	var/solvent_melt_dose = 0
	var/solvent_max_damage  = 0
	var/slipperiness = 0
	var/euphoriant // If set, ingesting/injecting this material will cause the rainbow high overlay/behavior.

	var/glass_icon = DRINK_ICON_DEFAULT
	var/glass_name = "something"
	var/glass_desc = "It's a glass of... what, exactly?"
	var/list/glass_special = null // null equivalent to list()

	// Matter state data.
	var/dissolve_message = "dissolves in"
	var/dissolve_sound = 'sound/effects/bubbles.ogg'
	var/dissolves_in = MAT_SOLVENT_STRONG
	var/list/dissolves_into	// Used with the grinder and a solvent to extract other materials.

	var/chilling_point
	var/chilling_message = "crackles and freezes!"
	var/chilling_sound = list('sound/chemistry/freeze/freeze1.mp3', 'sound/chemistry/freeze/freeze2.mp3', 'sound/chemistry/freeze/freeze3.mp3', 'sound/chemistry/freeze/freeze4.mp3')
	var/list/chilling_products
	var/bypass_cooling_products_for_root_type

	var/list/electrolysis_products
	var/electrolysis_difficulty = 1

	var/reactivity_coefficient = 0.25 //explosions, chemical reactions, etc

	var/heating_point
	var/heating_temperature_product = 0
	var/heating_message = "boils!"
	var/heating_sound = 'sound/effects/bubbles.ogg'
	var/list/heating_products
	var/bypass_heating_products_for_root_type
	var/fuel_value = 0
	var/combustion_chamber_fuel_value = 0 //thermal joules per mole burned
	var/burn_product
	var/list/vapor_products // If splashed, releases these gasses in these proportions. // TODO add to unit test after solvent PR is merged

	var/scent //refer to _scent.dm
	var/scent_intensity = /decl/scent_intensity/normal
	var/scent_descriptor = SCENT_DESC_SMELL
	var/scent_range = 1

	var/list/neutron_interactions // Associative List of nuclear cross section for "fast" and "slow" neutrons.

	var/neutron_cross_section	  // How broad the neutron interaction curve is, independent of temperature. Materials that are harder to react with will have lower values.
	var/list/decl/material/absorption_products		  // Transmutes into these reagents following neutron absorption and/or subsequent beta decay. Generally forms heavier reagents.
	var/list/decl/material/fission_products		  // Transmutes into these reagents following fission. Forms lighter reagents, and a lot of heat.
	var/neutron_production = 0		  // How many neutrons are created per unit per fission event.
	var/neutron_absorption = 1		  // Chance of one mole of that material absorbing a neutron-mole
	var/fission_heat = 0			  // How much thermal energy per unit per fission event this material releases.
	var/fission_energy = 0			  // Energy of neutrons released by fission.
	var/fission_neutrons = 0 		  // Amount of neutrons released by fission
	var/moderation_target		  // The 'target' neutron energy value that the fission environment shifts towards after a moderation event.
								  // Neutron moderators can only slow down neutrons.

	var/sound_manipulate          //Default sound something like a material stack made of this material does when picked up
	var/sound_dropped             //Default sound something like a material stack made of this material does when hitting the ground or placed down

// Placeholders for light tiles and rglass.
/decl/material/proc/reinforce(var/mob/user, var/obj/item/stack/material/used_stack, var/obj/item/stack/material/target_stack, var/use_sheets = 1)
	if(!used_stack.can_use(use_sheets))
		to_chat(user, SPAN_WARNING("You need need at least one [used_stack.singular_name] to reinforce [target_stack]."))
		return

	var/decl/material/reinf_mat = used_stack.material
	if(reinf_mat.integrity <= integrity || reinf_mat.is_brittle())
		to_chat(user, SPAN_WARNING("The [reinf_mat.solid_name] is too structurally weak to reinforce the [name]."))
		return

	if(!target_stack.can_use(use_sheets))
		to_chat(user, SPAN_WARNING("You need need at least [use_sheets] [use_sheets == 1 ? target_stack.singular_name : target_stack.plural_name] for reinforcement with [used_stack]."))
		return

	to_chat(user, SPAN_NOTICE("You reinforce the [target_stack] with [reinf_mat.solid_name]."))
	used_stack.use(use_sheets)
	var/obj/item/stack/material/S = target_stack.split(1)
	S.reinf_material = reinf_mat
	S.update_strings()
	S.update_icon()
	if(!QDELETED(target_stack))
		S.dropInto(get_turf(target_stack))
	else if(user)
		S.dropInto(get_turf(user))
	else
		S.dropInto(get_turf(used_stack))
	S.add_to_stacks(user, TRUE)

// Make sure we have a use name and shard icon even if they aren't explicitly set.
/decl/material/Initialize()
	. = ..()
	if(!gas_molar_mass)
		gas_molar_mass = molar_mass
	molar_volume = molar_mass / liquid_density * 1000000
	if(!fusion_enthalpy) // Approximate it if we don't have an exact value
		fusion_enthalpy = latent_heat * 0.0325
	if(!use_name)
		use_name = name
	if(!liquid_name)
		liquid_name = name
	if(!solid_name)
		solid_name = name
	if(!gas_name)
		gas_name = name
	if(!adjective_name)
		adjective_name = name
	if(!shard_icon)
		shard_icon = shard_type
	if(!burn_armor)
		burn_armor = brute_armor
	if(!gas_symbol)
		gas_symbol = "[name]_[sequential_id(abstract_type)]"
	if(!gas_symbol_html)
		gas_symbol_html = gas_symbol
	if(!uid)
		uid = name
	global.materials_by_gas_symbol[gas_symbol] = type
	generate_armor_values()

	var/list/cocktails = decls_repository.get_decls_of_subtype(/decl/cocktail)
	for(var/ctype in cocktails)
		var/decl/cocktail/cocktail = cocktails[ctype]
		if(type in cocktail.ratios)
			cocktail_ingredient = TRUE
			break

// Return the matter comprising this material.
/decl/material/proc/get_matter()
	var/list/temp_matter = list()
	temp_matter[type] = SHEET_MATERIAL_AMOUNT
	return temp_matter

// Weapons handle applying a divisor for this value locally.
/decl/material/proc/get_blunt_damage()
	return weight //todo

// As above.
/decl/material/proc/get_edge_damage()
	return hardness //todo

/decl/material/proc/get_attack_cooldown()
	if(weight <= MAT_VALUE_LIGHT)
		return FAST_WEAPON_COOLDOWN
	if(weight >= MAT_VALUE_HEAVY)
		return SLOW_WEAPON_COOLDOWN
	return DEFAULT_WEAPON_COOLDOWN

// Snowflakey, only checked for alien doors at the moment.
/decl/material/proc/can_open_material_door(var/mob/living/user)
	return 1

// Currently used for weapons and objects made of uranium to irradiate things.
/decl/material/proc/products_need_process()
	return (radioactivity>0) //todo

//#define MAT_PHASE_DEBUG

#ifdef MAT_PHASE_DEBUG
var/decl/material/boil_mat = null
/proc/set_boil_mat(mat_type)
	boil_mat = GET_DECL(mat_type)
/proc/mat_boil_temp(pressure)
	if(!boil_mat)
		return "NO BOIL MAT. Set one through set_boil_mat()"
	to_world("******MAT PHASE DEBUG******")
	to_world("Material was: [boil_mat.name]")
	to_world("---------------------------")
	to_world("Default boiling point: [boil_mat.boiling_point]K")
	to_world("Pressure: [pressure]kPa")
	to_world("Latent heat: [boil_mat.latent_heat]J/mol")
	to_world("---------------------------")
	to_world("Pressure Boiling point: [boil_mat.get_boiling_temp(pressure)]K")
	to_world("---------------------------")
#endif

//Clausius–Clapeyron relation
/decl/material/proc/get_boiling_temp(var/pressure = ONE_ATMOSPHERE)
	if(!pressure)
		pressure = 0.00001
	return ((1/boiling_point) - ((R_IDEAL_GAS_EQUATION*log(pressure/ONE_ATMOSPHERE)) / latent_heat))**-1

// Returns the phase of the matterial at the given temperature and pressure
/decl/material/proc/phase_at_temperature(var/temperature = T20C, var/pressure = ONE_ATMOSPHERE)
	//#TODO: implement plasma temperature and do pressure checks
	if(temperature >= get_boiling_temp(pressure))
		return MAT_PHASE_GAS
	else if(temperature >= melting_point)
		return MAT_PHASE_LIQUID
	return MAT_PHASE_SOLID

// Returns the phase of matter this material is a standard temperature and pressure (20c at one atmosphere)
/decl/material/proc/phase_at_stp()
	return phase_at_temperature(T20C, ONE_ATMOSPHERE)

// Used by walls when qdel()ing to avoid neighbor merging.
/decl/material/placeholder
	name = "placeholder"
	uid = "mat_placeholder"
	hidden_from_codex = TRUE
	exoplanet_rarity = MAT_RARITY_NOWHERE

// Generic material product (sheets, bricks, etc). Used ALL THE TIME.
// May return an instance list, a single instance, or nothing if there is no instance produced.
/decl/material/proc/create_object(var/atom/target, var/amount = 1, var/object_type, var/reinf_type)

	if(!object_type)
		object_type = default_solid_form

	if(!ispath(object_type, /atom/movable))
		CRASH("Non-movable path '[object_type || "NULL"]' supplied to [type] create_object()")

	if(ispath(object_type, /obj/item/stack))
		var/obj/item/stack/stack_type = object_type
		var/divisor = initial(stack_type.max_amount)
		while(amount >= divisor)
			LAZYADD(., new object_type(target, divisor, type, reinf_type))
			amount -= divisor
		if(amount >= 1)
			LAZYADD(., new object_type(target, amount, type, reinf_type))
	else
		for(var/i = 1 to amount)
			var/atom/movable/placed = new object_type(target, type, reinf_type)
			if(istype(placed))
				LAZYADD(., placed)

	if(istype(target) && LAZYLEN(.))
		for(var/atom/movable/placed in .)
			placed.dropInto(target)

// Places a girder object when a wall is dismantled, also applies reinforced material.
/decl/material/proc/place_dismantled_girder(var/turf/target, var/decl/material/reinf_material)
	return create_object(target, 1, /obj/structure/girder, ispath(reinf_material) ? reinf_material : reinf_material?.type)

// General wall debris product placement.
// Not particularly necessary aside from snowflakey cult girders.
/decl/material/proc/place_dismantled_product(var/turf/target, var/is_devastated, var/amount = 2, var/drop_type)
	amount = is_devastated ? FLOOR(amount * 0.5) : amount
	if(amount > 0)
		return create_object(target, amount, object_type = drop_type)

// As above.
/decl/material/proc/place_shard(var/turf/target)
	if(shard_type)
		return create_object(target, 1, /obj/item/shard)

/**Places downa as many shards as needed for the given amount of matter units. Returns a list of all the cuttings. */
/decl/material/proc/place_cuttings(var/turf/target, var/matter_units)
	//STUB: Waiting on papwerork PR

// Used by walls and weapons to determine if they break or not.
/decl/material/proc/is_brittle()
	return !!(flags & MAT_FLAG_BRITTLE)

/decl/material/proc/combustion_effect(var/turf/T, var/temperature)
	return

// Dumb overlay to apply over wall sprite for cheap texture effect
/decl/material/proc/get_wall_texture()
	return

/decl/material/proc/on_leaving_metabolism(var/atom/parent, var/metabolism_class)
	return

#define ACID_MELT_DOSE 10
/decl/material/proc/touch_obj(var/obj/O, var/amount, var/datum/reagents/holder) // Acid melting, cleaner cleaning, etc

	if(solvent_power >= MAT_SOLVENT_MILD)
		if(istype(O, /obj/item/paper))
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			to_chat(usr, SPAN_NOTICE("The solution dissolves the ink on the paper."))
		else if(istype(O, /obj/item/book) && REAGENT_VOLUME(holder, type) >= 5)
			if(istype(O, /obj/item/book/tome))
				to_chat(usr, SPAN_WARNING("The solution does nothing. Whatever this is, it isn't normal ink."))
			else
				var/obj/item/book/affectedbook = O
				affectedbook.dat = null
				to_chat(usr, SPAN_NOTICE("The solution dissolves the ink on the book."))

	if(solvent_power >= MAT_SOLVENT_STRONG && (istype(O, /obj/item) || istype(O, /obj/effect/vine)) && (REAGENT_VOLUME(holder, type) > solvent_melt_dose))
		O.visible_message(SPAN_DANGER("\The [O] dissolves!"))
		O.handle_melting()
		holder?.remove_reagent(type, solvent_melt_dose)
	else if(defoliant && istype(O, /obj/effect/vine))
		qdel(O)

#define FLAMMABLE_LIQUID_DIVISOR 7
// This doesn't apply to skin contact - this is for, e.g. extinguishers and sprays. The difference is that reagent is not directly on the mob's skin - it might just be on their clothing.
/decl/material/proc/touch_mob(var/mob/living/M, var/amount, var/datum/reagents/holder)
	if(fuel_value && amount && istype(M))
		M.fire_stacks += FLOOR((amount * fuel_value)/FLAMMABLE_LIQUID_DIVISOR)
	if(!iscarbon(M))
		return
	var/obj/item/suit = M.get_equipped_item(slot_wear_suit_str)
	if(suit)
		if(suit.permeability_coefficient)
			affect_touch(M, amount * suit.permeability_coefficient, holder)
	else
		affect_touch(M, amount, holder)
#undef FLAMMABLE_LIQUID_DIVISOR

/decl/material/proc/touch_turf(var/turf/T, var/amount, var/datum/reagents/holder) // Cleaner cleaning, lube lubbing, etc, all go here

	if(REAGENT_VOLUME(holder, type) < turf_touch_threshold)
		return

	if(istype(T, /turf/simulated))
		var/turf/simulated/wall/W = T
		if(defoliant)
			for(var/obj/effect/overlay/wallrot/E in W)
				W.visible_message(SPAN_NOTICE("\The [E] is completely dissolved by the solution!"))
				qdel(E)
		if(slipperiness != 0)
			if(slipperiness < 0)
				W.unwet_floor(TRUE)
			else
				W.wet_floor(slipperiness)

	if(length(vapor_products))
		var/volume = REAGENT_VOLUME(holder, type)
		var/temperature = holder?.my_atom?.temperature || T20C
		for(var/vapor in vapor_products)
			T.assume_gas(vapor, (volume * vapor_products[vapor]), temperature)
		holder.remove_reagent(type, volume)

/decl/material/proc/on_mob_life(var/mob/living/M, var/metabolism_class, var/datum/reagents/holder) // Currently, on_mob_life is called on carbons. Any interaction with non-carbon mobs (lube) will need to be done in touch_mob.
	if(QDELETED(src))
		return // Something else removed us.
	if(!istype(M))
		return
	if(!(flags & AFFECTS_DEAD) && M.stat == DEAD && (world.time - M.timeofdeath > 150))
		return
	if(overdose && (metabolism_class != CHEM_TOUCH))
		var/overdose_threshold = overdose * (flags & IGNORE_MOB_SIZE? 1 : MOB_SIZE_MEDIUM/M.mob_size)
		if(REAGENT_VOLUME(holder, type) > overdose_threshold)
			affect_overdose(M, holder)

	//determine the metabolism rate
	var/removed = (REAGENT_VOLUME(holder, type) * metabolism) + 0.00001
	if(ingest_met && (metabolism_class == CHEM_INGEST))
		removed = ingest_met
	if(touch_met && (metabolism_class == CHEM_TOUCH))
		removed = touch_met
	removed = M.get_adjusted_metabolism(removed)

	var/dose = LAZYACCESS(M.chem_doses, type) + removed
	LAZYSET(M.chem_doses, type, dose)
	switch(metabolism_class)
		if(CHEM_INJECT)
			affect_blood(M, removed, holder)
		if(CHEM_INGEST)
			affect_ingest(M, removed, holder)
		if(CHEM_TOUCH)
			affect_touch(M, removed, holder)
	holder.remove_reagent(type, removed)

/decl/material/proc/affect_blood(var/mob/living/M, var/removed, var/datum/reagents/holder)
	if(radioactivity)
		M.apply_damage(radioactivity * removed, IRRADIATE, armor_pen = 100)

	if(toxicity)
		M.add_chemical_effect(CE_TOXIN, toxicity)
		var/dam = (toxicity * removed)
		if(toxicity_targets_organ && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/I = GET_INTERNAL_ORGAN(H, toxicity_targets_organ)
			if(I)
				var/can_damage = I.max_damage - I.damage
				if(can_damage > 0)
					if(dam > can_damage)
						I.take_internal_damage(can_damage, silent=TRUE)
						dam -= can_damage
					else
						I.take_internal_damage(dam, silent=TRUE)
						dam = 0
		if(dam > 0)
			M.adjustToxLoss(toxicity_targets_organ ? (dam * 0.75) : dam)

	if(solvent_power >= MAT_SOLVENT_STRONG)
		M.take_organ_damage(0, removed * solvent_power, override_droplimb = DISMEMBER_METHOD_ACID)

	if(narcosis)
		if(prob(10))
			M.SelfMove(pick(global.cardinal))
		if(prob(narcosis))
			M.emote(pick("twitch", "drool", "moan"))

	if(euphoriant)
		SET_STATUS_MAX(M, STAT_DRUGGY, euphoriant)

/decl/material/proc/affect_ingest(var/mob/living/M, var/removed, var/datum/reagents/holder)
	if(affect_blood_on_ingest)
		affect_blood(M, removed * 0.5, holder)

/decl/material/proc/affect_touch(var/mob/living/M, var/removed, var/datum/reagents/holder)

	if(!istype(M))
		return

	if(radioactivity)
		M.apply_damage((radioactivity / 2) * removed, IRRADIATE)

	if(dirtiness <= DIRTINESS_STERILE)
		if(M.germ_level < INFECTION_LEVEL_TWO) // rest and antibiotics is required to cure serious infections
			M.germ_level -= min(removed*20, M.germ_level)
		for(var/obj/item/I in M.contents)
			I.was_bloodied = null
		M.was_bloodied = null

	if(dirtiness <= DIRTINESS_CLEAN)
		for(var/obj/item/thing in M.get_held_items())
			thing.clean_blood()
		var/obj/item/mask = M.get_equipped_item(slot_wear_mask_str)
		if(mask)
			mask.clean_blood()
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/head = H.get_equipped_item(slot_head_str)
			if(head)
				head.clean_blood()
			var/obj/item/suit = H.get_equipped_item(slot_wear_suit_str)
			if(suit)
				suit.clean_blood()
			else
				var/obj/item/uniform = H.get_equipped_item(slot_w_uniform_str)
				if(uniform)
					uniform.clean_blood()

			var/obj/item/shoes = H.get_equipped_item(slot_shoes_str)
			if(shoes)
				shoes.clean_blood()
			else
				H.clean_blood(1)
				return
		M.clean_blood()

	switch(solvent_power)
		if(MAT_SOLVENT_MODERATE to MAT_SOLVENT_STRONG-0.1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/to_affect = pick(BP_L_FOOT, BP_R_FOOT)
				var/obj/item/organ/external/affecting = GET_EXTERNAL_ORGAN(H, to_affect)
				H.add_symptom(/decl/medical_symptom/irritation, to_affect)
				to_chat(H, SPAN_WARNING("Your [affecting.name] starts to hurt from the liquid!"))
		if(MAT_SOLVENT_STRONG to INFINITY)
			if(removed >= solvent_melt_dose)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					for(var/slot in global.standard_headgear_slots)
						var/obj/item/thing = H.get_equipped_item(slot)
						if(!istype(thing))
							continue
						if(thing.unacidable || !H.unEquip(thing))
							to_chat(H, SPAN_NOTICE("Your [thing] protects you from the acid."))
							holder.remove_reagent(type, REAGENT_VOLUME(holder, type))
							return
						to_chat(H, SPAN_DANGER("Your [thing] dissolves!"))
						qdel(thing)
						removed -= solvent_melt_dose
						if(removed <= 0)
							return

					if(!H.unacidable)
						var/screamed
						for(var/obj/item/organ/external/affecting in H.get_external_organs())
							if(!screamed && prob(15) && affecting.can_feel_pain())
								screamed = TRUE
								H.emote("agony")
							affecting.status |= ORGAN_DISFIGURED

			if(!M.unacidable)
				M.take_organ_damage(0, min(removed * solvent_power * ((removed < solvent_melt_dose) ? 0.1 : 0.2), solvent_max_damage), override_droplimb = DISMEMBER_METHOD_ACID)

/decl/material/proc/affect_overdose(var/mob/living/M, var/datum/reagents/holder) // Overdose effect. Doesn't happen instantly.
	M.add_chemical_effect(CE_TOXIN, 1)
	M.adjustToxLoss(1.4)

/decl/material/proc/initialize_data(var/newdata) // Called when the reagent is created.
	if(newdata)
		. = newdata

/decl/material/proc/mix_data(var/datum/reagents/reagents, var/list/newdata, var/amount)
	. = REAGENT_DATA(reagents, type)

#define EXPLOSION_ENERGY_COEFFICIENT 0.00001 //explosion power per joule of combustion energy
#define DEFLAG_ENERGY_COEFFICIENT 0.0001
/decl/material/proc/explosion_act(obj/item/chems/holder, severity)
	SHOULD_CALL_PARENT(TRUE)
	. = TRUE
	if(!combustion_energy)
		return
	var/turf/T = get_turf(holder)
	var/datum/gas_mixture/environment = T.return_air()
	var/datum/gas_mixture/products = new
	var/volume = REAGENT_VOLUME(holder?.reagents, type)
	var/gas_moles = volume / molar_volume
	var/oxidizer_moles = environment.get_by_flag(XGM_GAS_OXIDIZER)
	if(gas_flags & XGM_GAS_OXIDIZER) //we can oxidize ourselves
		oxidizer_moles += gas_moles
	var/actually_combusted = min(gas_moles, oxidizer_moles)
	var/total_energy = actually_combusted * combustion_energy
	if(burn_product)
		products.adjust_gas(burn_product, gas_moles*0.05, FALSE)
	products.adjust_gas(type, gas_moles*0.95, FALSE)
	environment.merge(products)
	holder.reagents.remove_reagent(type, volume)
	environment.remove_by_flag(XGM_GAS_OXIDIZER, actually_combusted)
	environment.add_thermal_energy(0.05 * total_energy)
	if(phase_at_temperature(environment.temperature, environment.return_pressure()) == MAT_PHASE_SOLID) //detonation
		cell_explosion(T, total_energy * EXPLOSION_ENERGY_COEFFICIENT)
	else
		deflagration(T, total_energy * DEFLAG_ENERGY_COEFFICIENT, shock_color = fire_color)

#undef EXPLOSION_ENERGY_COEFFICIENT
#undef DEFLAG_ENERGY_COEFFICIENT

/decl/material/proc/get_value()
	. = value

/decl/material/proc/get_presentation_name(var/obj/item/prop)
	. = glass_name || liquid_name
	if(prop?.reagents?.total_volume)
		. = build_presentation_name_from_reagents(prop, .)

/decl/material/proc/build_presentation_name_from_reagents(var/obj/item/prop, var/supplied)
	. = supplied

	if(cocktail_ingredient)
		for(var/decl/cocktail/cocktail in SSmaterials.get_cocktails_by_primary_ingredient(type))
			if(cocktail.matches(prop))
				return cocktail.get_presentation_name(prop)

	if(prop.reagents.has_reagent(/decl/material/solid/ice))
		. = "iced [.]"

/decl/material/proc/neutron_interact(var/neutron_energy, var/total_interacted_units, var/total_units)
	. = list() // Returns associative list of interaction -> interacted units
	if(!length(neutron_interactions))
		return
	for(var/interaction in neutron_interactions)
		var/ideal_energy = neutron_interactions[interaction]
		var/interacted_units_ratio = (Clamp(-((((neutron_energy-ideal_energy)**2)/(neutron_cross_section*1000)) - 100), 0, 100))/100
		var/interacted_units = round(interacted_units_ratio*total_interacted_units, 0.001)

		if(interacted_units > 0)
			.[interaction] = interacted_units
			total_interacted_units -= interacted_units
		if(total_interacted_units <= 0)
			return


// Nuclear Interactions
// For the sake of simplicity, everything neutron-related is calculated in moles. So moles instead of atoms.
// That means that 1 neutron is equivalent to 1 mole amount of neutrons.

// Should returns a list with the following:
// slow_neutrons_changed
// fast_neutrons_changed
// thermal_energy_released

#define SLOW_NEUTRON_ENERGY 96485 //for absorption

/decl/material/proc/handle_nuclear_fission(datum/gas_mixture/container, slow_neutrons=0, fast_neutrons=0)
	if(!neutron_interactions)
		return null

	var/list/slow_list = neutron_interactions["slow"]
	var/energy_delta = 0

	for(var/reaction_type in slow_list)
		switch(reaction_type)
			if(INTERACTION_SCATTER)
				var/scattered_neutrons = get_nuclear_reaction_rate(container, INTERACTION_SCATTER, slow_neutrons, fast_neutrons)
				scattered_neutrons = min(fast_neutrons, scattered_neutrons)
				fast_neutrons -= scattered_neutrons
				slow_neutrons += scattered_neutrons
			if(INTERACTION_ABSORPTION)
				var/absorbed_neutrons = get_nuclear_reaction_rate(container, INTERACTION_ABSORPTION, slow_neutrons, fast_neutrons)
				absorbed_neutrons = min(fast_neutrons + slow_neutrons, absorbed_neutrons, container.gas[src.type])
				fast_neutrons -= absorbed_neutrons * 0.5
				slow_neutrons -= absorbed_neutrons * 0.5
				energy_delta += absorbed_neutrons * SLOW_NEUTRON_ENERGY
				if(absorption_products)
					container.adjust_gas(src.type, absorbed_neutrons * -1, FALSE)
					for(var/abs_type in absorption_products)
						container.adjust_gas(abs_type, absorbed_neutrons * absorption_products[abs_type], FALSE)
			if(INTERACTION_FISSION)
				var/fission_reactions = get_nuclear_reaction_rate(container, INTERACTION_FISSION, slow_neutrons, fast_neutrons)
				fission_reactions = min(container.gas[src.type], fission_reactions)
				if(slow_neutrons > fast_neutrons)
					slow_neutrons -= fission_reactions
				else
					fast_neutrons -= fission_reactions
				container.adjust_gas(src.type, fission_reactions * -1, FALSE)
				for(var/waste_type in fission_products)
					container.adjust_gas(waste_type, fission_reactions*fission_products[waste_type], FALSE)
				fast_neutrons += fission_reactions * fission_neutrons
				energy_delta += fission_reactions * fission_energy

	return list(
		"slow_neutrons_changed" = max(slow_neutrons, 0),
		"fast_neutrons_changed" = max(fast_neutrons, 0),
		"thermal_energy_released" = energy_delta
	)

/decl/material/proc/get_nuclear_reaction_rate(datum/gas_mixture/container, reaction_type, slow_neutrons, fast_neutrons)
	var/interpolation_weight = 0
	if(slow_neutrons)
		interpolation_weight = CLAMP01((fast_neutrons / slow_neutrons) * 0.1)

	var/actual_cross_section = Interpolate(neutron_interactions["slow"][reaction_type], neutron_interactions["fast"][reaction_type], interpolation_weight)

	return ((slow_neutrons + fast_neutrons)/sqrt(container.volume)*2) * actual_cross_section * container.gas[src.type]/container.volume

#undef SLOW_NEUTRON_ENERGY