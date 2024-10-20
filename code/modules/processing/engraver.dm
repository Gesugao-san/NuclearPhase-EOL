/obj/machinery/processor/engraver
	name = "laser engraver"
	desc = "A high-power laser engraving machine."
	icon = 'icons/obj/machines/processing_64x64.dmi'
	icon_state = "engraver_off"
	root_icon_state = "engraver"
	bound_width = 64
	bound_height = 64
	active_power_usage = 15000
	max_items = 1
	has_tank_slot = TRUE
	initial_tank_path = /obj/item/tank/xenon
	processing_class = PROCESSING_CLASS_CUTTER
	reagent_container_volume = 5000