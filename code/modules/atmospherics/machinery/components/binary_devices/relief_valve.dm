/obj/machinery/atmospherics/binary/relief_valve
	icon = 'icons/obj/atmospherics/components/binary/passive_gate.dmi'
	icon_state = "map_off"
	level = 1

	name = "relief valve"
	desc = "A one-way safety valve that opens when the pressure rises beyond its setting."

	interact_offline = TRUE

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL|CONNECT_TYPE_SCRUBBER|CONNECT_TYPE_SUPPLY
	build_icon_state = "passivegate"

	identifier = "AGR"
	uncreated_component_parts = null // Does not need power components; does not come with radio stuff, have to install it manually.

	frame_type = /obj/item/pipe
	construct_state = /decl/machine_construction/default/panel_closed/item_chassis
	base_type = /obj/machinery/atmospherics/binary/relief_valve
	var/starting_volume

	var/opened = FALSE
	var/open_pressure = MAX_TANK_PRESSURE
	var/close_pressure = MAX_TANK_PRESSURE*0.75

/obj/machinery/atmospherics/binary/relief_valve/Initialize()
	. = ..()
	if(starting_volume)
		air1.volume = starting_volume
		air2.volume = starting_volume
	else
		air1.volume = ATMOS_DEFAULT_VOLUME_PUMP * 2.5
		air2.volume = ATMOS_DEFAULT_VOLUME_PUMP * 2.5

/obj/machinery/atmospherics/binary/relief_valve/on_update_icon()
	icon_state = (opened)? "on" : "off"
	build_device_underlays(FALSE)

/obj/machinery/atmospherics/binary/relief_valve/hide(var/i)
	update_icon()

/obj/machinery/atmospherics/binary/relief_valve/Process()
	. = ..()

	if(air1.pressure > open_pressure)
		open()
	else if(close_pressure > air1.pressure)
		close()

	if(opened)
		pump_gas_passive(src, air1, air2)

/obj/machinery/atmospherics/binary/relief_valve/proc/open()
	if(opened)
		return
	opened = TRUE
	update_icon()

/obj/machinery/atmospherics/binary/relief_valve/proc/close()
	if(!opened)
		return
	opened = FALSE
	update_icon()