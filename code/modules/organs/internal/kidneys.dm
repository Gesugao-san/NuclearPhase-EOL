/obj/item/organ/internal/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	prosthetic_icon = "kidneys-prosthetic"
	gender = PLURAL
	organ_tag = BP_KIDNEYS
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 10
	oxygen_consumption = 0.6
	oxygen_deprivation_tick = 0.2

/obj/item/organ/internal/kidneys/Process()
	..()

	if(!owner)
		return

	var/health_coefficient = 1 - (damage / max_damage)

	if(owner.get_blood_perfusion() < 0.8)
		var/pressure_difference = 100 - owner.meanpressure
		var/secretion_efficiency_coeff = max(0.01, health_coefficient - (oxygen_deprivation / 100))
		if(pressure_difference > 0)
			owner.bloodstr.add_reagent_max(/decl/material/liquid/adrenaline, pressure_difference * 0.004 * secretion_efficiency_coeff, pressure_difference * 0.0013)
			owner.bloodstr.add_reagent_max(/decl/material/liquid/noradrenaline, pressure_difference * 0.002 * secretion_efficiency_coeff, pressure_difference * 0.007)
		return

	if(is_bruised() || is_broken())
		reagents.add_reagent_max(/decl/material/solid/potassium, damage * 0.01, 10)
		return

	owner.adjustToxLoss(-1 * health_coefficient)
	reagents.remove_reagent(/decl/material/solid/potassium, 0.5 * health_coefficient)

/obj/item/organ/internal/kidneys/scan(advanced)
	if(advanced)
		switch(damage/max_damage)
			if(0 to 0.1)
				return "No renal abnormalities. Both kidneys are functioning optimally with normal filtration rates, maintaining fluid and electrolyte balance."
			if(0.1 to 0.4)
				return "Mild renal impairment. Localized damage to nephrons or renal tissue, leading to slightly reduced filtration efficiency. Possible mild fluid retention or electrolyte imbalance."
			if(0.4 to 0.8)
				return "Severe renal damage. Significant loss of functional nephrons, resulting in reduced filtration capacity and accumulation of waste products."
			if(0.8 to 1)
				return "Critical renal failure. Extensive and irreversible damage to both kidneys, with minimal to no filtration of waste products. Dialysis or kidney transplantation required to sustain life."
	else
		if(damage > max_damage * 0.5)
			return "Severe renal damage."
		else
			return "No major renal damage."