/obj/effect/crystal_growth //stepping barefoot will be PUNISHED
	name = "crystal growth"
	desc = "These crystals are terrifying in their perfect placement patterns."
	layer = CATWALK_LAYER
	color = COLOR_SREC
	anchored = 1
	icon = 'icons/turf/mining_decals.dmi'
	icon_state = "crystal"
	var/transmissibility = 1

/obj/effect/crystal_growth/Process()
	try_expand()

/obj/effect/crystal_growth/Initialize()
	. = ..()
	set_light(1, 1, COLOR_SREC_ACTIVE)
	var/area/A = get_area(loc)
	A.background_radiation += 2.1
	START_PROCESSING(SSblob, src)

/obj/effect/crystal_growth/Destroy()
	SSmaterials.create_object(/decl/material/solid/static_crystal, get_turf(src), 3, /obj/item/stack/material/gemstone)
	. = ..()
	var/area/A = get_area(loc)
	A.background_radiation -= 2.1
	STOP_PROCESSING(SSblob, src)

/obj/effect/crystal_growth/meat
	desc = "These crystals are terrifying in their perfect placement patterns. There are pieces of flesh lodged inbetween individual shards..."
	color = COLOR_SREC_ACTIVE
	transmissibility = 3

/obj/effect/crystal_growth/attackby(obj/item/I, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(src)
	visible_message(SPAN_WARNING("[user] attacks \the [src] with \the [I]!"))
	playsound(src, "glasscrack", 50, 1)
	if(I.force > 10 && prob(I.force))
		visible_message(SPAN_DANGER("[src] gets shredded to pieces!"))
		qdel(src)
	. = ..()

/obj/effect/crystal_growth/proc/expand(var/turf/T)
	if(!istype(T, /turf/simulated/floor))
		return

	for(var/obj/machinery/door/D in T) // There can be several - and some of them can be open, locate() is not suitable
		if(D.density)
			return

	var/obj/machinery/camera/CA = locate() in T
	if(CA)
		CA.take_damage(30)
		return

	new /obj/effect/crystal_growth(T)

/obj/effect/crystal_growth/proc/try_expand()
	set waitfor = FALSE
	sleep(4)
	var/pushDir = pick(global.cardinal)
	var/turf/T = get_step(src, pushDir)
	var/obj/effect/crystal_growth/C = (locate() in T)
	if(!C)
		expand(T)
		return

/obj/effect/crystal_growth/explosion_act(severity)
	. = ..()
	if(prob(severity * 0.5))
		qdel(src)

/obj/effect/crystal_growth/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/M = AM

		if(M.buckled) //wheelchairs, office chairs, rollerbeds
			return

		playsound(src.loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.siemens_coefficient<0.5 || (H.species.species_flags & (SPECIES_FLAG_NO_EMBED|SPECIES_FLAG_NO_MINOR_CUT))) //Thick skin.
				return

			var/obj/item/shoes = H.get_equipped_item(slot_shoes_str)
			var/obj/item/suit = H.get_equipped_item(slot_wear_suit_str)
			if(suit && (suit.body_parts_covered & SLOT_FEET))
				H.srec_dose += transmissibility * suit.permeability_coefficient
				return
			else if(shoes)
				H.srec_dose += transmissibility * shoes.permeability_coefficient
				return

			to_chat(M, SPAN_DANGER("You step on \the [src]! There is some strange tingling in your feet..."))

			var/list/check = list(BP_L_FOOT, BP_R_FOOT)
			while(check.len)
				var/picked = pick(check)
				var/obj/item/organ/external/affecting = GET_EXTERNAL_ORGAN(H, picked)
				if(affecting)
					if(BP_IS_PROSTHETIC(affecting))
						return
					affecting.take_external_damage(7, 0)
					if(H.srec_dose < 100)
						H.srec_dose += rand(30, 70)
					H.updatehealth()
					if(affecting.can_feel_pain())
						SET_STATUS_MAX(H, STAT_WEAK, 3)
					return
				check -= picked
			return

/obj/item/projectile/bullet/pellet/fragment/crystal
	damage = 3
	irradiate = 500
	eyeblur = 1

/obj/item/projectile/bullet/pellet/fragment/crystal/on_hit(atom/target, blocked)
	if(!blocked)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			if(H.srec_dose < 100)
				H.srec_dose += rand(20, 70)
			else
				H.srec_dose *= 1.05
			SET_STATUS_MAX(H, STAT_WEAK, 3)
	. = ..()

/obj/effect/crystal_wall
	name = "crystal wall"
	desc = "A seemingly fragile obstacle of crystalline origin."
	density = 1
	opacity = 1
	anchored = 1
	mouse_opacity = 2
	alpha = 200
	layer = ABOVE_HUMAN_LAYER
	var/min_shatter_dam = 10
	var/shatter_prob = 15
	icon = 'icons/turf/mining_decals.dmi'
	icon_state = "crystal_wall"
	color = COLOR_SREC

/obj/effect/crystal_wall/New(loc, ...)
	. = ..()
	set_light(2, 1, COLOR_SREC_ALPHA)
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.stat == DEAD)
			continue
		L.apply_damage(rand(15, 30), BRUTE, used_weapon = "sharp crystals")
		L.forceMove(src)

/obj/effect/crystal_wall/Destroy()
	SSmaterials.create_object(/decl/material/solid/static_crystal, loc, 7, /obj/item/stack/material/gemstone)
	for(var/obj/item/I in contents)
		I.forceMove(loc)
	for(var/mob/M in contents)
		M.forceMove(loc)
	. = ..()

/obj/effect/crystal_wall/proc/shatter()
	playsound(src, "glasscrack", 50, 1)
	fragmentate(get_turf(src), fragtypes = list(/obj/item/projectile/bullet/pellet/fragment/crystal))

/obj/effect/crystal_wall/attackby(obj/item/I, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(src)
	if(I.sharp && prob(5))
		to_chat(user, SPAN_WARNING("Your [I] gets stuck in \the [src]!"))
		user.drop_from_inventory(I, src)
		return
	visible_message(SPAN_WARNING("[user] attacks \the [src] with \the [I]!"))
	playsound(src, "glasscrack", 50, 1)
	if(I.force > min_shatter_dam && prob(shatter_prob))
		if(prob(20))
			shatter()
		visible_message(SPAN_DANGER("[src] gets shredded to pieces!"))
		qdel(src)
	. = ..()

/obj/effect/crystal_wall/bullet_act(obj/item/projectile/P, def_zone)
	. = ..()
	if(istype(P, /obj/item/projectile/bullet/pellet/fragment/crystal))
		return
	if(prob(10))
		shatter()
	if(prob(shatter_prob))
		playsound(src, "glasscrack", 50, 1)
		visible_message(SPAN_DANGER("[src] gets shredded to pieces!"))
		qdel(src)