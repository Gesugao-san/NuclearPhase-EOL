/obj/machinery/processor/cutter
	name = "laser cutter"
	desc = "A high-power laser cutting machine. Works for pizza too!"
	icon = 'icons/obj/machines/processing_64x64.dmi'
	icon_state = "cutter_off"
	root_icon_state = "cutter"
	bound_width = 64
	bound_height = 64
	active_power_usage = 25000
	max_items = 1
	has_tank_slot = TRUE
	initial_tank_path = /obj/item/tank/xenon
	processing_class = PROCESSING_CLASS_CUTTER