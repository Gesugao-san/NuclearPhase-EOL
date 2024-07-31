/obj
	layer = OBJ_LAYER
	animate_movement = 2

	var/obj_flags
	var/list/req_access
	var/list/matter //Used to store information about the contents of the object.
	var/w_class // Size of the object.
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	var/throwforce = 1
	var/sharp = 0		// whether this object cuts
	var/edge = 0		// whether this object is more likely to dismember
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/damtype = BRUTE
	var/armor_penetration = 0
	var/anchor_fall = FALSE
	var/holographic = 0 //if the obj is a holographic object spawned by the holodeck
	var/tmp/directional_offset ///JSON list of directions to x,y offsets to be applied to the object depending on its direction EX: @'{"NORTH":{"x":12,"y":5}, "EAST":{"x":10,"y":50}}'

	var/start_dirty = FALSE	// Shall we add dirt to the object at initialization
	var/start_old = FALSE //Shall we add random malfunctions at init
	var/dirt_sprites_amount = 0

/obj/proc/start_ambience()
	return
/obj/proc/stop_ambience()
	return

/obj/Cross(O, var/mustcheck=FALSE) // fuck that shit im out
	if(mustcheck)
		return ..()
	return TRUE

/obj/hitby(atom/movable/AM, var/datum/thrownthing/TT)
	..()
	if(!anchored)
		step(src, AM.last_move)

/obj/proc/create_matter()
	if(length(matter))
		for(var/mat in matter)
			matter[mat] = round(matter[mat] * get_matter_amount_modifier())
	UNSETEMPTY(matter)

/obj/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/proc/get_matter_amount_modifier()
	. = CEILING(w_class * BASE_OBJECT_MATTER_MULTPLIER)

/obj/item/proc/is_used_on(obj/O, mob/user)
	return

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src) | usr
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				if(CanUseTopic(M, DefaultTopicState()) > STATUS_CLOSE)
					is_in_use = 1
					interact(M)
				else
					M.unset_machine()
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				if(CanUseTopic(M, DefaultTopicState()) > STATUS_CLOSE)
					is_in_use = 1
					interact(M)
				else
					M.unset_machine()
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/attack_ghost(mob/user)
	ui_interact(user)
	..()

/obj/proc/interact(mob/user)
	return

/mob/proc/unset_machine()
	src.machine = null

/mob/proc/set_machine(var/obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(var/hide)
	set_invisibility(hide ? INVISIBILITY_MAXIMUM : initial(invisibility))

/obj/proc/hides_under_flooring()
	return level == 1

/obj/proc/hear_talk(mob/M, text, verb, decl/language/speaking)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.show_message(rendered, 2)
		*/
	return

/obj/proc/see_emote(mob/M, text, var/emote_type)
	return

/obj/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	return

/obj/proc/damage_flags()
	. = 0
	if(has_edge(src))
		. |= DAM_EDGE
	if(is_sharp(src))
		. |= DAM_SHARP
		if(damtype == BURN)
			. |= DAM_LASER

/obj/attackby(obj/item/O, mob/user)
	if(obj_flags & OBJ_FLAG_ANCHORABLE)
		if(IS_WRENCH(O))
			wrench_floor_bolts(user)
			update_icon()
			return
	return ..()

/obj/proc/wrench_floor_bolts(mob/user, delay=20)
	playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
	if(anchored)
		user.visible_message("\The [user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
	else
		user.visible_message("\The [user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")
	if(do_after(user, delay, src))
		if(!src) return
		to_chat(user, "<span class='notice'>You [anchored? "un" : ""]secured \the [src]!</span>")
		anchored = !anchored
	return 1

/obj/attack_hand(mob/user)
	if(Adjacent(user))
		add_fingerprint(user)
	..()

/obj/is_fluid_pushable(var/amt)
	return ..() && w_class <= round(amt/200)

/obj/proc/can_embed()
	return is_sharp(src)

/obj/examine(mob/user)
	. = ..()
	if((obj_flags & OBJ_FLAG_ROTATABLE))
		to_chat(user, SPAN_SUBTLE("\The [src] can be rotated with alt-click."))
	if((obj_flags & OBJ_FLAG_ANCHORABLE))
		to_chat(user, SPAN_SUBTLE("\The [src] can be anchored or unanchored with a wrench."))

/obj/proc/rotate(mob/user)
	if(!CanPhysicallyInteract(user))
		to_chat(user, SPAN_NOTICE("You can't interact with \the [src] right now!"))
		return

	if(anchored)
		to_chat(user, SPAN_NOTICE("\The [src] is secured to the floor!"))
		return

	set_dir(turn(dir, 90))
	update_icon()

//For things to apply special effects after damaging an organ, called by organ's take_damage
/obj/proc/after_wounding(obj/item/organ/external/organ, datum/wound)
	return

/obj/can_be_injected_by(var/atom/injector)
	. = ATOM_IS_OPEN_CONTAINER(src) && ..()

/obj/get_mass()
	return min(2**(w_class-1), 100)

/obj/get_object_size()
	return w_class

/obj/get_mob()
	return buckled_mob

/obj/get_alt_interactions(var/mob/user)
	. = ..()
	LAZYADD(., /decl/interaction_handler/rotate)

/obj/proc/append_some_dirt(var/q = dirt_sprites_amount)
	if(dirt_sprites_amount)
		var/dirt_state
		for(var/i = q, i>0, i--)
			dirt_state = "[icon_state]_dirt[rand(1,q)]"
			if(dirt_state in icon_states(icon))
				add_overlay(icon(icon, dirt_state))
				return
	else
		color = pick("#996633", "#663300", "#666666")
		if(light_color)
			light_color = BlendRGB(light_color, color, 0.5)

/decl/interaction_handler/rotate
	name = "Rotate"
	expected_target_type = /obj

/decl/interaction_handler/rotate/is_possible(atom/target, mob/user, obj/item/prop)
	. = ..()
	if(.)
		var/obj/O = target
		. = !!(O.obj_flags & OBJ_FLAG_ROTATABLE)

/decl/interaction_handler/rotate/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/O = target
	O.rotate(user)

/obj/handle_melting(list/meltable_materials)
	. = ..()
	if(QDELETED(src))
		return
	if(reagents?.total_volume)
		reagents.trans_to(loc, reagents.total_volume)
	dump_contents()
	return place_melted_product(meltable_materials)

/obj/proc/place_melted_product(list/meltable_materials)
	. = new /obj/effect/decal/cleanable/molten_item(src)
	qdel(src)

/obj/proc/fail_roundstart()
	return