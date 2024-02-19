/decl/material/liquid/adrenaline
	name = "adrenaline"
	lore_text = "Adrenaline is a hormone that was used as a drug to treat cardiac arrest and other cardiac dysrhythmias resulting in diminished or absent cardiac output."
	mechanics_text = "Increases BPM. Makes resuscitations easier."
	taste_description = "rush"
	metabolism = REM * 2
	color = "#76319e"
	scannable = 1
	overdose = 4
	value = 1.5
	uid = "chem_adrenaline"
	drug_category = DRUG_CATEGORY_RESUSCITATION

/decl/material/liquid/adrenaline/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	H.add_chemical_effect(CE_BREATHLOSS, removed * 1100)
	heart.bpm_modifiers[name] = removed * 3900
	heart.cardiac_output_modifiers[name] = 1 + removed * 5.7
	if(removed < 0.003)
		H.add_chemical_effect(CE_PRESSURE, removed * -700)
	else
		H.add_chemical_effect(CE_PRESSURE, removed * 400)
	heart.stability_modifiers[name] = removed * 3000

/decl/material/liquid/adrenaline/affect_overdose(var/mob/living/carbon/human/H, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	heart.stability_modifiers["[name] overdose"] = -950

/decl/material/liquid/noradrenaline
	name = "noradrenaline"
	lore_text = "Noradrenaline is a hormone responsible for blood pressure modulation. It was widely used as an injectable drug for the treatment of critically low blood pressure."
	mechanics_text = "Increases BP. Can wake people up."
	taste_description = "sobriety"
	metabolism = REM * 2
	color = "#1e3c7e"
	scannable = 1
	overdose = 12
	value = 1.5
	uid = "chem_noradrenaline"
	drug_category = DRUG_CATEGORY_RESUSCITATION

/decl/material/liquid/noradrenaline/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder) //UNCONFIRMED VALUES
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	H.add_chemical_effect(CE_PRESSURE, removed * 1550)
	heart.cardiac_output_modifiers[name] = 1 + removed * 0.3
	heart.bpm_modifiers[name] = removed * 200
	if(removed > 0.008)
		ADJ_STATUS(H, STAT_ASLEEP, removed * -10)

/decl/material/liquid/atropine
	name = "atropine"
	lore_text = "Atropine is an extremely potent tachycardic."
	mechanics_text = "Rapidly increases BPM."
	taste_description = "rush"
	color = "#ce3f2c"
	scannable = 1
	overdose = 5
	metabolism = 0.05
	value = 1.5
	uid = "chem_atropine"
	drug_category = DRUG_CATEGORY_RESUSCITATION

/decl/material/liquid/atropine/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder) //UNCONFIRMED VALUES
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	heart.bpm_modifiers[name] = removed * 4000

/decl/material/liquid/dopamine
	name = "dopamine"
	lore_text = "Dopamine is a naturally occuring nervous system stimulant."
	mechanics_text = "Increases cardiac output."
	color = "#cea82c"
	scannable = 1
	overdose = 8
	metabolism = REM * 2
	uid = "chem_dopamine"
	drug_category = DRUG_CATEGORY_RESUSCITATION

/decl/material/liquid/dopamine/affect_blood(var/mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	heart.cardiac_output_modifiers[name] = 1 + removed * 3

/decl/material/liquid/nitroglycerin
	name = "nitroglycerin"
	mechanics_text = "Reduces cardiac output, decreases heart ischemia"
	taste_description = "oil"
	color = "#ceb02c"
	scannable = 1
	overdose = 15
	metabolism = 0.05
	value = 1.5
	uid = "chem_nitroglycerin"
	drug_category = DRUG_CATEGORY_RESUSCITATION

/decl/material/liquid/nitroglycerin/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	heart.cardiac_output_modifiers[name] = 1 - removed * 3
	heart.oxygen_deprivation = max(0, heart.oxygen_deprivation - removed * 2)

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
	drug_category = DRUG_CATEGORY_CARDIAC

/decl/material/solid/betapace/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	heart.bpm_modifiers[name] = removed * -20
	heart.stability_modifiers[name] = removed * 700

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
	drug_category = DRUG_CATEGORY_CARDIAC

/decl/material/liquid/dronedarone/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	heart.stability_modifiers[name] = removed * 1000

/decl/material/liquid/heparin
	name = "heparin"
	mechanics_text = "Prevents blood clots"
	color = "#d6d6d6"
	scannable = 1
	overdose = 10
	metabolism = 0.01
	value = 1.5
	uid = "chem_heparin"
	drug_category = DRUG_CATEGORY_MISC

/decl/material/liquid/heparin/affect_blood(var/mob/living/carbon/human/H, var/removed, var/datum/reagents/holder) //UNCONFIRMED VALUES
	H.add_chemical_effect(CE_BLOOD_THINNING, removed)

/decl/material/liquid/adenosine
	name = "adenosine"
	color = "#d6d6d6"
	scannable = 1
	overdose = 10
	metabolism = 0.9
	value = 1.5
	uid = "adenosine"
	drug_category = DRUG_CATEGORY_CARDIAC

/decl/material/liquid/adenosine/affect_blood(mob/living/carbon/human/H, removed, datum/reagents/holder)
	if(removed > 2)
		var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
		heart.bpm_modifiers[name] = -140
		for(var/decl/arrythmia/A in heart.arrythmias)
			if(!A.can_be_shocked && prob(90))
				heart.arrythmias.Remove(A)