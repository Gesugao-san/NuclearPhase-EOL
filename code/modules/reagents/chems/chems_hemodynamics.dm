/decl/material/liquid/adrenaline
	name = "adrenaline"
	lore_text = "Adrenaline is a hormone that was used as a drug to treat cardiac arrest and other cardiac dysrhythmias resulting in diminished or absent cardiac output."
	mechanics_text = "Increases BPM. Makes resuscitations easier."
	taste_description = "rush"
	color = "#76319e"
	scannable = 1
	overdose = 20
	metabolism = 0.1
	value = 1.5
	uid = "chem_adrenaline"

/decl/material/liquid/adrenaline/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder) //UNCONFIRMED VALUES
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	var/volume = REAGENT_VOLUME(holder, type)
	heart.bpm_modifiers[name] = volume * 30
	heart.cardiac_output_modifiers[name] = volume + (volume / 10)
	if(volume < overdose)
		heart.stability_modifiers[name] = volume * 3
	else
		heart.stability_modifiers[name] = !(volume * 3)
	if(volume > 5)
		ADJ_STATUS(H, STAT_JITTER, 5)

/decl/material/liquid/noradrenaline
	name = "noradrenaline"
	lore_text = "Noradrenaline is a hormone responsible for blood pressure modulation. It was widely used as an injectable drug for the treatment of critically low blood pressure."
	mechanics_text = "Increases BP. Can wake people up."
	taste_description = "sobriety"
	color = "#1e3c7e"
	scannable = 1
	overdose = 20
	metabolism = 0.05
	value = 1.5
	uid = "chem_noradrenaline"

/decl/material/liquid/noradrenaline/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder) //UNCONFIRMED VALUES
	var/volume = REAGENT_VOLUME(holder, type)
	H.add_chemical_effect(CE_PRESSURE, volume * 10)
	if(volume > 2)
		ADJ_STATUS(H, STAT_ASLEEP, !(volume * 10))

/decl/material/liquid/atropine
	name = "atropine"
	lore_text = "Atropine is an extremely potent tachycardic."
	mechanics_text = "Strongly increases BPM."
	taste_description = "rush"
	color = "#ce3f2c"
	scannable = 1
	overdose = 5
	metabolism = 0.05
	value = 1.5
	uid = "chem_atropine"

/decl/material/liquid/atropine/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder) //UNCONFIRMED VALUES
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	var/volume = REAGENT_VOLUME(holder, type)
	heart.bpm_modifiers[name] = volume * 60

/decl/material/liquid/nitroglycerin
	name = "nitroglycerin"
	mechanics_text = "Reduces cardiac output, decreases heart ischemia"
	taste_description = "oil"
	color = "#ceb02c"
	scannable = 1
	overdose = 20
	metabolism = 0.05
	value = 1.5
	uid = "chem_nitroglycerin"

/decl/material/liquid/nitroglycerin/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	var/volume = REAGENT_VOLUME(holder, type)
	heart.cardiac_output_modifiers[name] = 1 - volume * 0.01
	heart.oxygen_deprivation = max(0, heart.oxygen_deprivation - volume * 0.2)

/decl/material/solid/betapace
	name = "betapace"
	mechanics_text = "Decreases pulse, increases heart stability"
	taste_description = "burning"
	color = "#353535"
	scannable = 1
	overdose = 15
	metabolism = 0.05
	value = 1.5
	uid = "chem_betapace"

/decl/material/solid/betapace/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	var/volume = REAGENT_VOLUME(holder, type)
	heart.bpm_modifiers[name] = !(volume * 2)
	heart.stability_modifiers[name] = volume * 7

/decl/material/liquid/dronedarone
	name = "dronedarone"
	mechanics_text = "Increases heart stability"
	taste_description = "comfort"
	color = "#321f35"
	scannable = 1
	overdose = 10
	metabolism = 0.05
	value = 1.5
	uid = "chem_dronedarone"

/decl/material/liquid/dronedarone/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	var/volume = REAGENT_VOLUME(holder, type)
	heart.stability_modifiers[name] = volume * 10
