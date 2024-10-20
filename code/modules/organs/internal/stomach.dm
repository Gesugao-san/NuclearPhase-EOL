/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "Gross. This is hard to stomach."
	icon_state = "stomach"
	organ_tag = BP_STOMACH
	parent_organ = BP_GROIN
	var/stomach_capacity
	var/datum/reagents/metabolism/ingested
	var/next_cramp = 0
	oxygen_consumption = 0.4

/obj/item/organ/internal/stomach/Destroy()
	QDEL_NULL(ingested)
	. = ..()

/obj/item/organ/internal/stomach/set_species(species_name)
	if(species?.gluttonous)
		verbs -= /obj/item/organ/internal/stomach/proc/throw_up
	. = ..()
	if(species.gluttonous)
		verbs |= /obj/item/organ/internal/stomach/proc/throw_up

/obj/item/organ/internal/stomach/setup_reagents()
	. = ..()
	if(!ingested)
		ingested = new/datum/reagents/metabolism(4000, (owner || src), CHEM_INGEST)
	if(!ingested.my_atom)
		ingested.my_atom = src

/obj/item/organ/internal/stomach/do_uninstall(in_place, detach, ignore_children)
	. = ..()
	if(ingested) //Don't bother if we're destroying
		ingested.my_atom = src
		ingested.parent = null

/obj/item/organ/internal/stomach/do_install()
	. = ..()
	ingested.my_atom = owner
	ingested.parent = owner

/obj/item/organ/internal/stomach/proc/can_eat_atom(var/atom/movable/food)
	return !isnull(get_devour_time(food))

/obj/item/organ/internal/stomach/proc/is_full(var/atom/movable/food)
	var/total = FLOOR(ingested.total_volume / 10)
	for(var/a in contents + food)
		if(ismob(a))
			var/mob/M = a
			total += M.mob_size
		else if(isobj(a))
			var/obj/item/I = a
			total += I.get_storage_cost()
		else
			continue
		if(total > species.stomach_capacity)
			return TRUE
	return FALSE

/obj/item/organ/internal/stomach/proc/get_devour_time(var/atom/movable/food)
	if(iscarbon(food) || isanimal(food))
		var/mob/living/L = food
		if((species.gluttonous & GLUT_TINY) && (L.mob_size <= MOB_SIZE_TINY) && !ishuman(food)) // Anything MOB_SIZE_TINY or smaller
			return DEVOUR_SLOW
		else if((species.gluttonous & GLUT_SMALLER) && owner.mob_size > L.mob_size) // Anything we're larger than
			return DEVOUR_SLOW
		else if(species.gluttonous & GLUT_ANYTHING) // Eat anything ever
			return DEVOUR_FAST
	else if(istype(food, /obj/item) && !istype(food, /obj/item/holder)) //Don't eat holders. They are special.
		var/obj/item/I = food
		var/cost = I.get_storage_cost()
		if(cost < ITEM_SIZE_NO_CONTAINER)
			if((species.gluttonous & GLUT_ITEM_TINY) && cost < 4)
				return DEVOUR_SLOW
			else if((species.gluttonous & GLUT_ITEM_NORMAL) && cost <= 4)
				return DEVOUR_SLOW
			else if(species.gluttonous & GLUT_ITEM_ANYTHING)
				return DEVOUR_FAST


/obj/item/organ/internal/stomach/proc/throw_up()
	set name = "Empty Stomach"
	set category = "IC"
	set src in usr
	if(usr == owner && owner && !owner.incapacitated())
		owner.vomit(deliberate = TRUE)

/obj/item/organ/internal/stomach/return_air()
	return null

// This call needs to be split out to make sure that all the ingested things are metabolised
// before the process call is made on any of the other organs
/obj/item/organ/internal/stomach/proc/metabolize()
	if(is_usable())
		ingested.metabolize()

#define STOMACH_VOLUME 4000

/obj/item/organ/internal/stomach/Process()
	..()

	if(owner)
		var/functioning = is_usable()
		if(germ_level > INFECTION_LEVEL_ONE || damage >= min_bruised_damage && prob((damage / max_damage) * 100))
			functioning = FALSE

		if(functioning)
			for(var/mob/living/M in contents)
				if(M.stat == DEAD)
					qdel(M)
					continue

				M.adjustBruteLoss(3)
				M.adjustFireLoss(3)
				M.adjustToxLoss(3)

				var/digestion_product = M.get_digestion_product()
				if(digestion_product)
					ingested.add_reagent(digestion_product, rand(1,3))

		else if(world.time >= next_cramp)
			next_cramp = world.time + rand(200,800)
			owner.custom_pain("Your stomach cramps agonizingly!",150)
			owner.vomit()

		var/alcohol_volume = REAGENT_VOLUME(ingested, /decl/material/liquid/ethanol)

		var/alcohol_threshold_met = alcohol_volume > STOMACH_VOLUME / 2
		if(alcohol_threshold_met && (owner.disabilities & EPILEPSY) && prob(20))
			owner.seizure()

		// Alcohol counts as double volume for the purposes of vomit probability
		var/effective_volume = ingested.total_volume + alcohol_volume

		// Just over the limit, the probability will be low. It rises a lot such that at double ingested it's 64% chance.
		var/vomit_probability = (effective_volume / STOMACH_VOLUME) ** 6
		if(prob(vomit_probability))
			owner.vomit()

#undef STOMACH_VOLUME

/obj/item/organ/internal/stomach/scan(advanced)
	if(advanced)
		switch(damage/max_damage)
			if(0 to 0.1)
				return "No gastrointestinal abnormalities. Stomach function is normal, with efficient digestion and gastric motility. Mucosal lining and acid production are within healthy ranges."
			if(0.1 to 0.4)
				return "Mild gastric injury. Localized erosion or ulceration of the gastric mucosa, leading to occasional discomfort or indigestion. Gastric acid production may be slightly increased or decreased."
			if(0.4 to 0.8)
				return "Severe gastric injury. Significant loss of mucosal integrity, with widespread ulceration and reduced gastric motility."
			if(0.8 to 1)
				return "Critical gastric failure. Extensive damage to the stomach lining, with perforation or necrosis of tissue."
	else
		if(damage > max_damage * 0.5)
			return "Severe gastric injury."
		else
			return "No major gastric damage."