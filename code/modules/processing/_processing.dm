// This is a machine that crafts using items and reagents.

/obj/machinery/processor
	density = 1
	anchored = 1
	idle_power_usage = 100
	active_power_usage = 2000
	clicksound = "keyboard"
	clickvol = 30
	uncreated_component_parts = null
	stat_immune = 0
	base_type =       /obj/machinery/processor
	construct_state = /decl/machine_construction/default/panel_closed
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

	var/root_icon_state

	var/sound_id
	var/datum/sound_token/sound_token
	var/working_sound = 'sound/machines/fabricator_loop.ogg'

	// Items storage
	var/max_items = 1
	var/list/stored_items = list() // length up to max_items

	// Reagents storage
	var/reagent_container_volume // in milliliters, if a container exists

	// Gas storage
	var/obj/item/tank/connected_tank // a reference to the tank, if it exists
	var/initial_tank_path
	var/has_tank_slot = FALSE

	// Recipes
	var/processing_class = PROCESSING_CLASS_ASSEMBLER
	var/list/possible_recipes = list() // A list of recipes compiled using processing_class
	var/decl/processing_recipe/current_recipe
	var/operating = FALSE // Are we busy with something?
	var/recipe_time = 0 // How much time did we already spend processing, in seconds

/obj/machinery/processor/Initialize()
	. = ..()
	sound_id = "[working_sound]"
	if(reagent_container_volume)
		create_reagents(reagent_container_volume)
	if(initial_tank_path)
		connected_tank = new initial_tank_path
	update_recipe_cache()

/obj/machinery/processor/on_update_icon()
	if(!is_functioning())
		icon_state = "[root_icon_state]_off"
		return
	if(operating)
		icon_state = "[root_icon_state]_processing"
		return
	icon_state = "[root_icon_state]_on"

/obj/machinery/processor/attackby(obj/item/I, mob/user)
	if(operating)
		to_chat(user, SPAN_NOTICE("\The [src] is busy."))
		return TRUE
	if(istype(I, /obj/item/tank))
		if(!has_tank_slot)
			to_chat(user, SPAN_NOTICE("\The [src] doesn't support gas tank installation."))
			return TRUE
		if(connected_tank)
			to_chat(user, SPAN_NOTICE("There is already a gas tank in \the [src]."))
			return TRUE
		connected_tank = I
		I.forceMove(src)
		return TRUE
	if(reagent_container_volume && istype(I, /obj/item/chems))
		var/obj/item/chems/C = I
		C.standard_pour_into(user, src)
		return TRUE
	if(length(stored_items) >= max_items)
		to_chat(user, SPAN_NOTICE("\The [src] is already at max capacity."))
		return TRUE
	else
		add_item(I)
		I.forceMove(src)
	. = ..()

/obj/machinery/processor/proc/update_recipe_cache()
	possible_recipes = list()
	for(var/recipe_path in decls_repository.get_decls(subtypesof(/decl/processing_recipe)))
		var/decl/processing_recipe/recipe = GET_DECL(recipe_path)
		if(recipe.processing_type == processing_class && !(recipe.abstract_type == recipe.type))
			possible_recipes += recipe

/obj/machinery/processor/proc/is_functioning()
	. = use_power != POWER_USE_OFF && !(stat & NOPOWER) && !(stat & BROKEN)

/obj/machinery/processor/proc/start_processing(decl/processing_recipe/selected_recipe, mob/user)
	if(!operating && is_functioning())
		if(!selected_recipe.can_happen(src))
			to_chat(user, SPAN_NOTICE("Prerequisites for the selected operation not met. The recipe needs:"))
			for(var/item_path in selected_recipe.required_items)
				var/obj/item/I = GET_DECL(item_path)
				to_chat(user, SPAN_NOTICE(I.name))
			for(var/reagent_path in selected_recipe.required_reagents)
				var/decl/material/mat = GET_DECL(reagent_path)
				to_chat(user, "[selected_recipe.required_reagents[reagent_path]]ml [SPAN_NOTICE(mat.name)]")
			for(var/gas_path in selected_recipe.required_gas)
				var/decl/material/mat = GET_DECL(gas_path)
				to_chat(user, "[floor(selected_recipe.required_gas[gas_path] * mat.molar_volume)]ml [SPAN_NOTICE(mat.name)]")
			return
		operating = TRUE
		current_recipe = selected_recipe
		update_use_power(POWER_USE_ACTIVE)
		sound_token = play_looping_sound(src, sound_id, working_sound, volume = 30)

/obj/machinery/processor/proc/stop_processing()
	if(operating)
		operating = FALSE
		update_use_power(POWER_USE_IDLE)
		QDEL_NULL(sound_token)

/obj/machinery/processor/proc/add_item(obj/item/I)
	stored_items += I

/obj/machinery/processor/proc/remove_item(obj/item/I)
	stored_items -= I
	qdel(I)

/obj/machinery/processor/proc/eject_item(obj/item/I, destination)
	stored_items -= I
	I.forceMove(destination)

/obj/machinery/processor/proc/remove_reagent(reagent_type, reagent_amount)
	reagents.remove_reagent(reagent_type, reagent_amount)

/obj/machinery/processor/proc/remove_gas(gas_type, gas_moles)
	if(connected_tank)
		connected_tank.air_contents.adjust_gas(gas_type, gas_moles * -1)

/obj/machinery/processor/proc/remove_item_by_type(item_type, strict = TRUE)
	for(var/obj/item/I in stored_items)
		if(strict)
			if(I.type == item_type)
				remove_item(I)
		else
			if(istype(I, item_type))
				remove_item(I)

/obj/machinery/processor/Process()
	if(!operating)
		return
	recipe_time += 2
	if(recipe_time >= current_recipe.recipe_time)
		stop_processing()
		current_recipe.finish_processing(src)
		recipe_time = 0
		current_recipe = null

/obj/machinery/processor/physical_attack_hand(mob/living/carbon/human/user)
	. = ..()
	try_handle_interactions(user, get_alt_interactions(user))

/obj/machinery/processor/get_alt_interactions(mob/user)
	. = ..()
	LAZYADD(., /decl/interaction_handler/remove_items)
	LAZYADD(., /decl/interaction_handler/choose_recipe)

/decl/interaction_handler/remove_items
	name = "Remove Items"
	icon = 'icons/hud/radial.dmi'
	icon_state = "radial_pickup"
	expected_target_type = /obj/machinery/processor

/decl/interaction_handler/remove_items/invoked(obj/machinery/processor/target, mob/user)
	if(target.operating)
		to_chat(user, SPAN_NOTICE("\The [target] is busy."))
		return TRUE
	if(!length(target.stored_items))
		to_chat(user, SPAN_NOTICE("\The [target] is empty."))
		return TRUE
	for(var/obj/item/I in target.stored_items)
		target.eject_item(I, user.loc)
		user.put_in_hands(I)

/decl/interaction_handler/choose_recipe
	name = "Choose Operation"
	icon = 'icons/hud/radial.dmi'
	icon_state = "radial_use"
	expected_target_type = /obj/machinery/processor

/decl/interaction_handler/choose_recipe/invoked(obj/machinery/processor/target, mob/user)
	if(target.operating)
		to_chat(user, SPAN_NOTICE("\The [target] is busy."))
		return TRUE
	if(!length(target.stored_items))
		to_chat(user, SPAN_NOTICE("\The [target] is empty."))
		return TRUE
	var/decl/processing_recipe/chosen_recipe = tgui_input_list(user, "Select an operation", "Operation selection", target.possible_recipes)
	if(!chosen_recipe)
		return
	target.start_processing(chosen_recipe, user)