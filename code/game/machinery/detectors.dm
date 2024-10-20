/obj/machinery/detector
	name = "detector"
	desc = "An advanced detector used to detect various stuff."
	icon = 'icons/obj/machines/detectors.dmi'
	icon_state = "inactive"
	anchored = TRUE
	idle_power_usage = 100

	layer = ABOVE_HUMAN_LAYER

/obj/machinery/detector/Crossed(var/mob/living/M)
	..()

	if((stat & (NOPOWER|BROKEN)))
		return

	if(!istype(M))
		return

	if(should_alarm(M))
		trigger_alarm(M)

/obj/machinery/detector/proc/should_alarm(mob/M)
	return FALSE

/obj/machinery/detector/proc/trigger_alarm(mob/M)
	flick("active", src)
	visible_message("<span class='danger'>\The [src] sends off an alarm!</span>")
	playsound(src, 'sound/effects/alarms/foklaxonb.ogg', 60, 0)

/obj/machinery/detector/radiation_intoxication
	name = "RIA detector"
	desc = "An advanced Radiation-Intoxication-Access detector."

/obj/machinery/detector/radiation_intoxication/should_alarm(mob/M)
	if(HAS_STATUS(M, STAT_DROWSY) || HAS_STATUS(M, STAT_DRUGGY))
		return TRUE

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.radiation > 3000) //that's already a hellish dose
			return TRUE

	return FALSE

// detects open clothing and such
/obj/machinery/detector/radiation_intoxication_uniform
	name = "CRIA detector"
	desc = "An advanced Clothing-Radiation-Intoxication-Access detector."

/obj/machinery/detector/radiation_intoxication_uniform/should_alarm(mob/M)
	if(HAS_STATUS(M, STAT_DROWSY) || HAS_STATUS(M, STAT_DRUGGY))
		return TRUE

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.radiation > 3000) //that's already a hellish dose
			return TRUE

	return FALSE