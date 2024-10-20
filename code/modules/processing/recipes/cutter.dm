/decl/processing_recipe/cutter
	processing_type = PROCESSING_CLASS_CUTTER
	abstract_type = /decl/processing_recipe/cutter

/decl/processing_recipe/cutter/slice_food
	name = "Slice Food"
	strict_item_type = FALSE
	required_items = list(/obj/item/chems/food/sliceable)

/decl/processing_recipe/cutter/slice_food/produce_result(obj/machinery/processor/parent)
	for(var/obj/item/chems/food/sliceable/I in parent.stored_items)
		for(var/count in 1 to I.slices_num)
			parent.add_item(new I.slice_path)