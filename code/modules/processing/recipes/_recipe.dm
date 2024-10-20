/decl/processing_recipe
	var/name

	// Required items for the recipe
	var/strict_item_type = TRUE // are we using strict typechecking
	var/list/required_items
	var/list/required_reagents // in milliliters
	var/list/required_gas // in moles

	var/item_result_type

	var/processing_type = PROCESSING_CLASS_ASSEMBLER
	var/recipe_time = 5

	abstract_type = /decl/processing_recipe

/decl/processing_recipe/proc/can_happen(obj/machinery/processor/parent)
	for(var/required_item_type in required_items)
		var/found_item = FALSE
		for(var/obj/item/I in parent.stored_items)
			if(istype(I, required_item_type))
				found_item = TRUE
				break
		if(!found_item)
			return FALSE
	if(required_reagents)
		for(var/required_reagent_type in required_reagents)
			if(!(required_reagent_type in parent.reagents.reagent_volumes))
				return FALSE
			if(required_reagents[required_reagent_type] > parent.reagents.reagent_volumes[required_reagent_type])
				return FALSE
	if(required_gas)
		if(!parent.connected_tank)
			return FALSE
		for(var/required_gas_type in required_gas)
			if(!(required_gas_type in parent.connected_tank.air_contents.gas))
				return FALSE
			if(required_gas[required_gas_type] > parent.connected_tank.air_contents.gas[required_gas_type])
				return FALSE
	return TRUE

/decl/processing_recipe/proc/finish_processing(obj/machinery/processor/parent)
	produce_result(parent)
	consume_materials(parent)

/decl/processing_recipe/proc/consume_materials(obj/machinery/processor/parent)
	for(var/consumed_item_type in required_items)
		parent.remove_item_by_type(consumed_item_type, strict_item_type)
	if(required_reagents)
		for(var/consumed_reagent_type in required_reagents)
			parent.remove_reagent(consumed_reagent_type, required_reagents[consumed_reagent_type])
	if(required_gas)
		for(var/consumed_gas_type in required_gas)
			parent.remove_gas(consumed_gas_type, required_gas[consumed_gas_type])

/decl/processing_recipe/proc/produce_result(obj/machinery/processor/parent)
	parent.add_item(new item_result_type)