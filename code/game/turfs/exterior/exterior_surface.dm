/turf/exterior/surface
	name = "surface"
	icon = 'icons/turf/exterior/snow.dmi'
	icon_edge_layer = EXT_EDGE_SNOW
	footstep_type = /decl/footsteps/snow
	possible_states = 13
	color = "#bdb3c2"
	dirt_color = "#4c454e"
	var/datum/map/mapowner = null

/turf/exterior/surface/explosion_act(severity)
	return

/turf/exterior/surface/get_air_graphic()
	return mapowner.exterior_atmosphere?.graphic

/turf/exterior/surface/Initialize(mapload, no_update_icon)
	mapowner = global.using_map

	if(possible_states > 0)
		icon_state = "[rand(0, possible_states)]"

	if(!istype(mapowner))
		owner = null
	else
		//Must be done here, as light data is not fully carried over by ChangeTurf (but overlays are).
		if(mapowner.planetary_area && istype(loc, world.area))
			ChangeArea(src, mapowner.planetary_area)

	//. = ..(mapload)	// second param is our own, don't pass to children
	setup_environmental_lighting()

	var/air_graphic = get_air_graphic()
	if(length(air_graphic))
		add_vis_contents(src, air_graphic)

	if (no_update_icon)
		return

	if (mapload)	// If this is a mapload, then our neighbors will be updating their own icons too -- doing it for them is rude.
		update_icon()
	else
		for (var/turf/T in RANGE_TURFS(src, 1))
			if (T == src)
				continue
			if (TICK_CHECK)	// not CHECK_TICK -- only queue if the server is overloaded
				T.queue_icon_update()
			else
				T.update_icon()

	. = ..(mapload, no_update_icon, should_override = TRUE)

/turf/exterior/surface/setup_environmental_lighting(var/ncolor = COLOR_COLD_SURFACE)
	if (is_outside())
		surface_turfs += src
		if (mapowner)
			set_ambient_light(ncolor, mapowner.lightlevel)
			return
	else if (ambient_light)
		clear_ambient_light()

/turf/exterior/surface/return_air()
	return mapowner.exterior_atmosphere

/turf/exterior/surface/proc/switch_cracks(var/remove_cracks = FALSE) //i shat myself
	if(remove_cracks)
		overlays.Cut()
		return
	if(prob(15))
		overlays += image('icons/turf/snow.dmi', "cracks", dir = pick(cardinal))
	else
		spawn(50)
			if(prob(15))
				overlays += image('icons/turf/snow.dmi', "cracks", dir = pick(cardinal))

/turf/exterior/surface/lake
	name = "condensed gas"
	icon = 'icons/turf/exterior/water.dmi'
	color = COLOR_PALE_PURPLE_GRAY
	icon_has_corners = TRUE
	icon_edge_layer = EXT_EDGE_WATER
	movement_delay = 2
	possible_states = 0
	footstep_type = /decl/footsteps/water

/turf/exterior/surface/lake/Entered(mob/living/carbon/C)
	..()
	if(!ismob(C) && !isitem(C))
		return
	playsound(src, 'sound/chemistry/bufferadd.ogg', 30)
	new /obj/effect/effect/smoke/bad/evaporation(src)
	if(!iscarbon(C))
		return
	playsound(src, 'sound/effects/watersplash.ogg', 40)
	C.set_status(STAT_BLURRY, 5)
	SET_STATUS_MAX(C, STAT_WEAK, 2)
	var/temp_adj = 0
	var/thermal_protection = max(0, C.get_cold_protection(mapowner.exterior_atmosphere.temperature) - 0.5) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
	if(thermal_protection < 1)
		temp_adj = (1-thermal_protection) * ((mapowner.exterior_atmosphere.temperature - C.bodytemperature) / BODYTEMP_COLD_DIVISOR)	//this will be negative
	C.bodytemperature += between(-100, temp_adj, 500)

/turf/exterior/surface/lake/is_flooded(lying_mob, absolute)
	. = absolute ? ..() : lying_mob

/turf/simulated/open/exterior
	name = "canyon"
	desc = "Looks very deep..."
	var/datum/map/mapowner = null

/turf/simulated/open/exterior/return_air()
	return mapowner.exterior_atmosphere

/turf/simulated/open/exterior/Initialize()
	..()
	mapowner = global.using_map
	setup_environmental_lighting()

/turf/simulated/open/exterior/proc/setup_environmental_lighting(var/ncolor = COLOR_COLD_SURFACE)
	if (is_outside())
		surface_turfs += src
		if (mapowner)
			set_ambient_light(ncolor, mapowner.lightlevel)
			return
	else if (ambient_light)
		clear_ambient_light()

/turf/simulated/open/exterior/proc/switch_cracks()
	return

/obj/effect/fake_fluid
	name = "liquid gas"
	icon = 'icons/effects/liquids.dmi'
	icon_state = "mid_still"
	anchored = 1
	simulated = 0
	opacity = 0
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	layer = FLY_LAYER
	alpha = 135
	color = "#72d3eb"

//TODO: More advanced drowning effects
/obj/effect/fake_fluid/Crossed(O)
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		H.dust()