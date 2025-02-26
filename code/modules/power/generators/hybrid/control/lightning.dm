/obj/machinery/reactor_button/rswitch/lighting
	cooldown = 50
	icon_state = "switch2-off"
	off_icon_state = "switch2-off"
	on_icon_state = "switch2-on"

/obj/machinery/reactor_button/rswitch/lighting/do_action()
	. = ..()
	var/current_spawn_time = 0
	for(var/obj/machinery/light/L in reactor_floodlights)
		if(L.uid == id)
			current_spawn_time += 5
			spawn(current_spawn_time)
				L.on = state
				L.update_icon()
				if(state == 1)
					playsound(L.loc, 'sound/machines/floodlight.ogg', 50, 1, 30, 10)

/obj/machinery/reactor_button/rswitch/lighting/superstructure
	name = "FL-MAIN"
	id = "superstructure"

/obj/machinery/reactor_button/rswitch/lighting/auxillary
	name = "FL-AUX"
	id = "auxillary"

/obj/machinery/reactor_button/rswitch/lighting/perimeter
	name = "FL-PERIMETER"
	id = "perimeter"

/obj/machinery/reactor_button/rswitch/lighting/purge_tunnel
	name = "FL-PURGE"
	id = "purge"

/obj/machinery/reactor_button/rswitch/lighting/access
	name = "FL-ACCESS"
	id = "access"

/obj/machinery/reactor_button/rswitch/lighting/interior
	name = "FL-INTERIOR"
	id = "interior"