/decl/medical_symptom
	var/examine_message //when someone examines you
	var/self_examine_message //when you examine yourself
	var/periodical_message //when the system decides to alert you of the boo boo
	var/time = 1

/decl/medical_symptom/proc/can_go_away(mob/living/carbon/human/victim)
	if(time > 60)
		return TRUE
	return FALSE

/decl/medical_symptom/proc/go_away(mob/living/carbon/human/victim)
	victim.symptoms -= src
	qdel(src)

/decl/medical_symptom/proc/apply_pain(mob/living/carbon/human/victim)
	return 0

/decl/medical_symptom/headache
	self_examine_message = "Your head hurts."
	periodical_message = "Your head throbs in a pulsating headache."

/decl/medical_symptom/headache/can_go_away(mob/living/carbon/human/victim)
	if(victim.syspressure < 130 && time > 300)
		return TRUE
	return FALSE

/decl/medical_symptom/headache/apply_pain(mob/living/carbon/human/victim)
	var/obj/item/organ/external/affected = GET_EXTERNAL_ORGAN(victim, BP_HEAD)
	affected.add_pain(min(victim.syspressure * 0.1, 20))



/mob/living/carbon/human/proc/add_symptom(decl/medical_symptom/symptom)
	symptoms |= symptom