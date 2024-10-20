/obj/item/thermometer
	name = "digital thermometer"
	desc = "A simple digital infrared thermometer. Contact distance: 2 meters."
	icon = 'icons/obj/items/device/thermometer.dmi'
	icon_state = "white"
	material = /decl/material/solid/plastic

/obj/item/thermometer/attack(atom/target, mob/user, proximity_flag, click_parameters)
	var/message = ""

	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		message = "[H]'s body temperature is: [round(H.bodytemperature - T0C, 0.1)]C|[round(H.bodytemperature, 0.1)]K."
	else if(istype(target, /obj/machinery/atmospherics/unary))
		var/obj/machinery/atmospherics/unary/U = target
		message = "[U]'s hull temperature is: [round(U.air_contents.temperature - T0C)]C|[round(U.air_contents.temperature)]K."
	else if(istype(target, /obj/item))
		var/obj/item/I = target
		message = "[I]\s temperature is: [round(I.temperature - T0C)]C|[round(I.temperature)]K."
	if(message)
		user.visible_message(SPAN_NOTICE("[user] scans \the [target] with \the [src]."))
		to_chat(user, SPAN_NOTICE(message))
		return 1
	. = ..()