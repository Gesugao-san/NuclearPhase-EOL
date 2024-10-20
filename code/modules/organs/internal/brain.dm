/obj/item/organ/internal/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	organ_tag = BP_BRAIN
	parent_organ = BP_HEAD
	vital = 1
	icon_state = "brain2"
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1
	throw_speed = 3
	throw_range = 5
	origin_tech = @'{"biotech":3}'
	attack_verb = list("attacked", "slapped", "whacked")
	relative_size = 85
	damage_reduction = 0
	scale_max_damage_to_species_health = FALSE

	var/can_use_mmi = TRUE
	var/mob/living/carbon/brain/brainmob = null
	var/const/damage_threshold_count = 10
	var/damage_threshold_value
	var/healed_threshold = 1
	var/oxygen_reserve = 6
	oxygen_consumption = 1.53
	max_damage = 160
	min_broken_damage = 90
	min_bruised_damage = 30
	oxygen_deprivation_tick = 1

/obj/item/organ/internal/brain/getToxLoss()
	return 0

/obj/item/organ/internal/brain/oxygen_starve(amount)
	. = ..()
	if(oxygen_deprivation > 20)
		var/mob/living/carbon/human/H = owner
		H.send_to_limb()

/obj/item/organ/internal/brain/set_species(species_name)
	. = ..()
	if(species)
		set_max_damage(species.total_health)
	else
		set_max_damage(200)

/obj/item/organ/internal/brain/set_max_damage(var/ndamage)
	..()
	damage_threshold_value = round(max_damage / damage_threshold_count)

/obj/item/organ/internal/brain/Destroy()
	QDEL_NULL(brainmob)
	. = ..()

/obj/item/organ/internal/brain/proc/transfer_identity(var/mob/living/carbon/H, var/is_death = 0)
	if(is_death)
		H.ghostize(0)
		return

	if(!brainmob)
		brainmob = new(src)
		brainmob.SetName(H.real_name)
		brainmob.real_name = H.real_name
		brainmob.dna = H.dna.Clone()
		brainmob.timeofhostdeath = H.timeofdeath

	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just \a [initial(src.name)].</span>")
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/brain/examine(mob/user)
	. = ..()
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		to_chat(user, "You can feel the small spark of life still left in this one.")
	else
		to_chat(user, "This one seems particularly lifeless. Perhaps it will regain some of its luster later..")

/obj/item/organ/internal/brain/on_remove_effects()
	if(istype(owner))
		transfer_identity(owner, 1)
	return ..()

/obj/item/organ/internal/brain/on_add_effects()
	if(brainmob)
		if(brainmob.mind)
			if(owner.key)
				owner.ghostize()
			brainmob.mind.transfer_to(owner)
		else
			owner.key = brainmob.key
	return ..()

/obj/item/organ/internal/brain/can_recover()
	return ~status & ORGAN_DEAD

/obj/item/organ/internal/brain/proc/get_current_damage_threshold()
	return round(damage / damage_threshold_value)

/obj/item/organ/internal/brain/proc/past_damage_threshold(var/threshold)
	return (get_current_damage_threshold() > threshold)

/obj/item/organ/internal/brain/proc/handle_severe_brain_damage()
	set waitfor = FALSE
	healed_threshold = 0
	to_chat(owner, "<span class = 'notice' font size='10'><B>Where am I...?</B></span>")
	sleep(5 SECONDS)
	if(!owner)
		return
	to_chat(owner, "<span class = 'notice' font size='10'><B>What's going on...?</B></span>")
	sleep(10 SECONDS)
	if(!owner)
		return
	to_chat(owner, "<span class = 'notice' font size='10'><B>What happened...?</B></span>")
	alert(owner, "You have taken massive brain damage! You will not be able to remember the events leading up to your injury.", "Brain Damaged")

/obj/item/organ/internal/brain/Process()
	if(owner)
		if(damage > max_damage / 2 && healed_threshold)
			handle_severe_brain_damage()

		if(damage < (max_damage / 4))
			healed_threshold = 1

		handle_disabilities()
		handle_damage_effects()

		// Brain damage from low oxygenation or lack of blood.
		if(owner.should_have_organ(BP_HEART))
			var/can_heal = damage && damage < max_damage && (damage % damage_threshold_value || GET_CHEMICAL_EFFECT(owner, CE_BRAIN_REGEN) || (!past_damage_threshold(3) && GET_CHEMICAL_EFFECT(owner, CE_STABLE)))
			switch(owner.get_blood_perfusion())
				if(0.9 to 1)
					if(can_heal)
						damage = max(damage-1, 0)
				if(0.7 to 0.9)
					owner.set_status(STAT_CONFUSE, 20)
				if(0.5 to 0.7)
					owner.set_status(STAT_CONFUSE, 20)
					owner.set_status(STAT_WEAK, 20)
					if(prob(1))
						to_chat(owner, "<span class='warning'>You feel [pick("dizzy","woozy","faint")]...</span>")
				if(0 to 0.5)
					SET_STATUS_MAX(owner, STAT_PARA, 3)
	..()

/obj/item/organ/internal/brain/take_internal_damage(var/damage, var/silent)
	set waitfor = 0
	..()
	if(damage >= 25) //This probably won't be triggered by oxyloss or mercury. Probably.
		var/damage_secondary = damage * 0.20
		owner.flash_eyes()
		SET_STATUS_MAX(owner, STAT_BLURRY, damage_secondary)
		SET_STATUS_MAX(owner, STAT_CONFUSE, damage_secondary * 2)
		SET_STATUS_MAX(owner, STAT_PARA, damage_secondary)
		SET_STATUS_MAX(owner, STAT_WEAK, round(damage, 1))
		if(prob(30))
			addtimer(CALLBACK(src, PROC_REF(brain_damage_callback), damage), rand(6, 20) SECONDS, TIMER_UNIQUE)

/obj/item/organ/internal/brain/proc/brain_damage_callback(var/damage) //Confuse them as a somewhat uncommon aftershock. Side note: Only here so a spawn isn't used. Also, for the sake of a unique timer.
	if(!QDELETED(owner))
		to_chat(owner, SPAN_NOTICE(FONT_HUGE("<B>I can't remember which way is forward...</B>")))
		ADJ_STATUS(owner, STAT_CONFUSE, damage)

/obj/item/organ/internal/brain/proc/handle_disabilities()
	if(owner.stat)
		return
	if((owner.disabilities & EPILEPSY) && prob(1))
		owner.seizure()
	else if((owner.disabilities & TOURETTES) && prob(10))
		SET_STATUS_MAX(owner, STAT_STUN, 10)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		ADJ_STATUS(owner, STAT_JITTER, 100)
	else if((owner.disabilities & NERVOUS) && prob(10))
		SET_STATUS_MAX(owner, STAT_STUTTER, 10)

/obj/item/organ/internal/brain/proc/handle_damage_effects()
	if(owner.stat)
		return
	if(damage > 0 && prob(1))
		owner.custom_pain("Your head feels numb and painful.",150)
	if(is_bruised() && prob(1) && !HAS_STATUS(owner, STAT_BLURRY))
		to_chat(owner, "<span class='warning'>It becomes hard to see for some reason.</span>")
		owner.set_status(STAT_BLURRY, 10)
	var/held = owner.get_active_hand()
	if(damage >= 0.5*max_damage && prob(1) && held)
		to_chat(owner, "<span class='danger'>Your hand won't respond properly, and you drop what you are holding!</span>")
		owner.unEquip(held)
	if(damage >= 0.6*max_damage)
		SET_STATUS_MAX(owner, STAT_SLUR, 2)
	if(is_broken())
		if(!owner.lying)
			to_chat(owner, "<span class='danger'>You black out!</span>")
		SET_STATUS_MAX(owner, STAT_PARA, 10)

/obj/item/organ/internal/brain/surgical_fix(mob/user)
	var/blood_volume = owner.get_blood_oxygenation()
	if(blood_volume < BLOOD_VOLUME_SURVIVE)
		to_chat(user, "<span class='danger'>Parts of [src] didn't survive the procedure due to lack of air supply!</span>")
		set_max_damage(FLOOR(max_damage - 0.25*damage))
	heal_damage(damage)

/obj/item/organ/internal/brain/get_scarring_level()
	. = (species.total_health - max_damage)/species.total_health

/obj/item/organ/internal/brain/get_mechanical_assisted_descriptor()
	return "machine-interface [name]"

/obj/item/organ/internal/brain/scan(advanced)
	if(advanced)
		switch(damage/max_damage)
			if(0 to 0.1)
				return "No abnormal findings. Brain structures are intact, with normal function and perfusion. No evidence of trauma, ischemia, or lesions."
			if(0.1 to 0.4)
				return "Mild cerebral injury. Localized areas of neuronal loss and tissue atrophy observed. Cognitive and motor functions may be moderately impaired depending on the affected region."
			if(0.4 to 0.8)
				return "Severe cerebral injury. Widespread neuronal death, with significant atrophy and tissue damage. Major deficits in cognition, motor control, and sensory processing are likely."
			if(0.8 to 1)
				return "Critical cerebral injury. Extensive and irreversible damage across most brain regions. Minimal to no higher brain functions remaining, with probable loss of consciousness and vital autonomic functions."
	else
		if(damage > max_damage * 0.5)
			return "Severe cerebral injury."
		else
			return "No major cerebral damage."