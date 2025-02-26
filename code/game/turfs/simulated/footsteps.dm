/proc/get_footstep(var/footstep_type, var/mob/caller)
	. = caller && caller.get_footstep(footstep_type)
	if(!.)
		var/decl/footsteps/FS = GET_DECL(footstep_type)
		. = pick(FS.footstep_sounds)

/turf/get_footstep_sound(var/mob/caller)
	for(var/obj/structure/S in contents)
		if(S.footstep_type)
			return get_footstep(S.footstep_type, caller)

	if(check_fluid_depth(10000) && !is_flooded(TRUE))
		return get_footstep(/decl/footsteps/water, caller)

	if(iscarbon(caller))
		var/mob/living/carbon/C = caller
		if(C.msuit)
			return get_footstep(/decl/footsteps/exosuit, caller)

	if(footstep_type)
		return get_footstep(footstep_type, caller)

	if(is_plating())
		return get_footstep(/decl/footsteps/plating, caller)

/turf/simulated/floor/get_footstep_sound(var/mob/caller)
	. = ..()
	if(!.)
		if(!flooring || !flooring.footstep_type)
			return get_footstep(/decl/footsteps/blank, caller)
		else
			return get_footstep(flooring.footstep_type, caller)

/turf/Entered(var/mob/living/carbon/human/H)
	..()
	if(istype(H))
		H.handle_footsteps()
		H.step_count++

/mob/living/carbon/human/proc/has_footsteps()
	if(species.silent_steps || buckled || lying || throwing)
		return //people flying, lying down or sitting do not step

	var/obj/item/shoes = get_equipped_item(slot_shoes_str)
	if(shoes && (shoes.item_flags & ITEM_FLAG_SILENT))
		return // quiet shoes

	if(!has_organ(BP_L_FOOT) && !has_organ(BP_R_FOOT))
		return //no feet no footsteps

	return TRUE

/mob/living/carbon/human/proc/handle_footsteps()
	if(!has_footsteps())
		return

	// every other turf makes a sound
	if((step_count % 2) && !MOVING_DELIBERATELY(src))
		return

	// don't need to step as often when you hop around
	if((step_count % 3) && !has_gravity())
		return

	var/turf/T = get_turf(src)
	if(T)
		var/footsound = T.get_footstep_sound(src)
		if(footsound)
			var/range = 13
			var/volume = 100
			if(MOVING_DELIBERATELY(src))
				volume -= 45
				range -= 0.333
			if(!get_equipped_item(slot_shoes_str))
				volume -= 60
				range -= 0.333
			playsound(T, footsound, volume, 1, range)
