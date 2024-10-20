//If we intercept it return true else return false
/atom/proc/RelayMouseDrag(atom/src_object, atom/over_object, src_location, over_location, src_control, over_control, params, var/mob/user)
	return FALSE

/mob/proc/OnMouseDrag(atom/src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	if(istype(loc, /atom))
		var/atom/A = loc
		if(A.RelayMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, src))
			return

	if(a_intent == I_HELP)
		return TRUE

	var/obj/item/gun/gun = get_active_hand()
	if(istype(over_object) && (isturf(over_object) || isturf(over_object.loc)) && !incapacitated() && istype(gun))
		gun.set_autofire(over_object, src)

	if(!Adjacent(over_object) ||!canClick() || !ismob(over_object))
		return TRUE
	if(!prob(10 * get_skill_value(SKILL_COMBAT)))
		return TRUE
	if(over_object == src && get_skill_value(SKILL_COMBAT) > SKILL_BASIC) //can't cut yourself if skilled enough
		return TRUE
	var/mob/victim = over_object
	var/obj/item/W = get_active_hand()
	if(W)
		W.resolve_attackby(victim, src, params)
	else
		setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		UnarmedAttack(victim, 1)

/mob/proc/OnMouseDown(atom/object, location, control, params)
	var/obj/item/gun/gun = get_active_hand()
	if(a_intent == I_HURT && istype(object) && (isturf(object) || isturf(object.loc)) && !incapacitated() && istype(gun))
		gun.set_autofire(object, src)

/mob/proc/OnMouseUp(atom/object, location, control, params)
	var/obj/item/gun/gun = get_active_hand()
	if(istype(gun))
		gun.clear_autofire()