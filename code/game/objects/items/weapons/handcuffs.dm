/obj/item/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items/handcuffs.dmi'
	icon_state = ICON_STATE_WORLD
	health = 0
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_LOWER_BODY
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 5
	origin_tech = @'{"materials":1}'
	material = /decl/material/solid/metal/steel
	var/elastic
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes
	var/cuff_sound = 'sound/weapons/handcuffs.ogg'
	var/cuff_type = "handcuffs"
	weight = 0.4

/obj/item/handcuffs/examine(mob/user)
	. = ..()
	if (health)
		var display = health / initial(health) * 100
		if (display > 66)
			return
		to_chat(user, SPAN_WARNING("They look [display < 33 ? "badly ": ""]damaged."))

/obj/item/handcuffs/attack(var/mob/living/carbon/C, var/mob/living/user)

	if(!user.check_dexterity(DEXTERITY_COMPLEX_TOOLS))
		return

	if ((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>Uh ... how do those things work?!</span>")
		place_handcuffs(user, user)
		return

	// only carbons can be cuffed
	if(istype(C))
		if(!C.get_equipped_item(slot_handcuffed_str))
			if (C == user)
				place_handcuffs(user, user)
				return

			//check for an aggressive grab (or robutts)
			if(C.has_danger_grab(user))
				place_handcuffs(C, user)
			else
				to_chat(user, "<span class='danger'>You need to have a firm grip on [C] before you can put \the [src] on!</span>")
		else
			to_chat(user, "<span class='warning'>\The [C] is already handcuffed!</span>")
	else
		..()

/obj/item/handcuffs/proc/place_handcuffs(var/mob/living/carbon/target, var/mob/user)
	playsound(src.loc, cuff_sound, 30, 1, -2)

	var/mob/living/carbon/human/H = target
	if(!istype(H))
		return 0

	if (!H.has_organ_for_slot(slot_handcuffed_str))
		to_chat(user, "<span class='danger'>\The [H] needs at least two wrists before you can cuff them together!</span>")
		return 0

	var/obj/item/gloves = H.get_equipped_item(slot_gloves_str)
	if((gloves && (gloves.item_flags & ITEM_FLAG_NOCUFFS)) && !elastic)
		to_chat(user, "<span class='danger'>\The [src] won't fit around \the [gloves]!</span>")
		return 0

	user.visible_message("<span class='danger'>\The [user] is attempting to put [cuff_type] on \the [H]!</span>")

	if(!do_after(user,30, target))
		return 0

	if(!target.has_danger_grab(user)) // victim may have resisted out of the grab in the meantime
		return 0

	var/obj/item/handcuffs/cuffs = src
	if(dispenser)
		cuffs = new(get_turf(user))
	else if(!user.unEquip(cuffs))
		return 0

	admin_attack_log(user, H, "Attempted to handcuff the victim", "Was target of an attempted handcuff", "attempted to handcuff")
	SSstatistics.add_field_details("handcuffs","H")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*user.get_melee_attack_delay_modifier())
	user.do_attack_animation(H)

	user.visible_message("<span class='danger'>\The [user] has put [cuff_type] on \the [H]!</span>")

	// Apply cuffs.
	target.equip_to_slot(cuffs, slot_handcuffed_str)
	return 1

var/global/last_chew = 0
/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	if (A != src) return ..()
	if (last_chew + 26 > world.time) return

	var/mob/living/carbon/human/H = A
	if (!H.get_equipped_item(slot_handcuffed_str)) return
	if (H.a_intent != I_HURT) return
	if (H.zone_sel.selecting != BP_MOUTH) return
	if (H.get_equipped_item(slot_wear_mask_str)) return
	if (istype(H.get_equipped_item(slot_wear_suit_str), /obj/item/clothing/suit/straight_jacket)) return

	var/obj/item/organ/external/O = GET_EXTERNAL_ORGAN(H, H.get_active_held_item_slot())
	if (!O) return

	var/decl/pronouns/G = H.get_pronouns()
	H.visible_message( \
		SPAN_DANGER("\The [H] chews on [G.his] [O.name]"), \
		SPAN_DANGER("You chew on your [O.name]!"))
	admin_attacker_log(H, "chewed on their [O.name]!")

	O.take_external_damage(3,0, DAM_SHARP|DAM_EDGE ,"teeth marks")

	last_chew = world.time

/obj/item/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon = 'icons/obj/items/handcuffs_cable.dmi'
	breakouttime = 300 //Deciseconds = 30s
	cuff_sound = 'sound/weapons/cablecuff.ogg'
	cuff_type = "cable restraints"
	elastic = 1
	health = 75

/obj/item/handcuffs/cable/red
	color = COLOR_MAROON

/obj/item/handcuffs/cable/yellow
	color = COLOR_AMBER

/obj/item/handcuffs/cable/blue
	color = COLOR_CYAN_BLUE

/obj/item/handcuffs/cable/green
	color = COLOR_GREEN

/obj/item/handcuffs/cable/pink
	color = COLOR_PURPLE

/obj/item/handcuffs/cable/orange
	color = COLOR_ORANGE

/obj/item/handcuffs/cable/cyan
	color = COLOR_SKY_BLUE

/obj/item/handcuffs/cable/white
	color = COLOR_SILVER

/obj/item/handcuffs/cyborg
	dispenser = 1

/obj/item/handcuffs/cable/tape
	name = "tape restraints"
	desc = "DIY!"
	icon_state = "tape_cross"
	item_state = null
	icon = 'icons/obj/bureaucracy.dmi'
	breakouttime = 200
	cuff_type = "duct tape"
	health = 50
