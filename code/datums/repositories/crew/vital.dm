/* Vital */
/crew_sensor_modifier/vital/process_crew_data(var/mob/living/carbon/human/H, var/obj/item/clothing/under/C, var/turf/pos, var/list/crew_data)
	crew_data["true_pulse"] = 0
	crew_data["pulse"] = "N/A"
	crew_data["pulse_span"] = "neutral"
	if(!H.isSynthetic() && H.should_have_organ(BP_HEART))
		var/obj/item/organ/internal/heart/O = H.get_organ(BP_HEART, /obj/item/organ/internal/heart)
		if (!O || !BP_IS_PROSTHETIC(O)) // Don't make medical freak out over prosthetic hearts
			crew_data["true_pulse"] = H.pulse()
			crew_data["pulse"] = round(H.get_pulse(GETPULSE_TOOL), 1)
			switch(crew_data["true_pulse"])
				if(PULSE_NONE to PULSE_SLOW)
					crew_data["pulse_span"] = "bad"
				if(PULSE_SLOW to PULSE_NORM)
					crew_data["pulse_span"] = "average"
				if(PULSE_NORM to PULSE_FAST)
					crew_data["pulse_span"] = "good"
				if(PULSE_FAST to PULSE_2FAST)
					crew_data["pulse_span"] = "highlight"
				if(PULSE_2FAST to PULSE_THREADY)
					crew_data["pulse_span"] = "average"
				if(PULSE_THREADY to INFINITY)
					crew_data["pulse_span"] = "bad"
	crew_data["charge"] = "N/A"
	crew_data["charge_span"] = "N/A"
	if(H.isSynthetic())
		var/obj/item/organ/internal/cell/cell = H.get_organ(BP_CELL, /obj/item/organ/internal/cell)
		if(cell)
			crew_data["charge"] = cell.percent()
			if(cell.percent() <= 10)
				crew_data["charge_span"] = "bad"
			else
				crew_data["charge_span"] = "good"
		else
			crew_data["charge"] = "No cell"
			crew_data["charge_span"] = "bad"

	crew_data["pressure"] = "N/A"
	crew_data["true_oxygenation"] = -1
	crew_data["oxygenation"] = ""
	crew_data["oxygenation_span"] = ""
	if(!H.isSynthetic() && H.should_have_organ(BP_HEART))
		crew_data["pressure"] = H.get_blood_pressure()
		crew_data["true_oxygenation"] = H.get_blood_oxygenation()
		switch (crew_data["true_oxygenation"])
			if(BLOOD_VOLUME_SAFE to 105)
				crew_data["oxygenation"] = "normal"
				crew_data["oxygenation_span"] = "good"
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				crew_data["oxygenation"] = "low"
				crew_data["oxygenation_span"] = "average"
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				crew_data["oxygenation"] = "very low"
				crew_data["oxygenation_span"] = "bad"
			if(-(INFINITY) to BLOOD_VOLUME_BAD)
				crew_data["oxygenation"] = "extremely low"
				crew_data["oxygenation_span"] = "bad"

	crew_data["bodytemp"] = round(H.bodytemperature - T0C, 0.1)
	return ..()

/crew_sensor_modifier/vital/proc/set_healthy(var/list/crew_data)
	crew_data["alert"] = FALSE
	if(crew_data["true_pulse"] != -1)
		crew_data["true_pulse"] = PULSE_NORM
		crew_data["pulse"] = rand(60, 90)
		crew_data["pulse_span"] = "good"

	if(isnum(crew_data["charge"]))
		crew_data["charge"] = rand(10,66)
		crew_data["charge_span"] = "good"

	if(crew_data["true_oxygenation"] != -1)
		crew_data["pressure"] = "[FLOOR(120+rand(-5,5))]/[FLOOR(80+rand(-5,5))]"
		crew_data["true_oxygenation"] = 100
		crew_data["oxygenation"] = "normal"
		crew_data["oxygenation_span"] = "good"

/crew_sensor_modifier/vital/proc/set_dead(var/list/crew_data)
	crew_data["alert"] = TRUE
	if(crew_data["true_pulse"] != -1)
		crew_data["true_pulse"] = PULSE_NONE
		crew_data["pulse"] = 0
		crew_data["pulse_span"] = "bad"

	if(isnum(crew_data["charge"]))
		crew_data["charge"] = 0
		crew_data["charge_span"] = "bad"

	if(crew_data["true_oxygenation"] != -1)
		crew_data["pressure"] = "[FLOOR((120+rand(-5,5))*0.25)]/[FLOOR((80+rand(-5,5))*0.25)]"
		crew_data["true_oxygenation"] = 25
		crew_data["oxygenation"] = "extremely low"
		crew_data["oxygenation_span"] = "bad"

/* Jamming */
/crew_sensor_modifier/vital/jamming
	priority = 5

/crew_sensor_modifier/vital/jamming/healthy/process_crew_data(var/mob/living/carbon/human/H, var/obj/item/clothing/under/C, var/turf/pos, var/list/crew_data)
	. = ..()
	set_healthy(crew_data)
	return MOD_SUIT_SENSORS_HANDLED

/crew_sensor_modifier/vital/jamming/dead/process_crew_data(var/mob/living/carbon/human/H, var/obj/item/clothing/under/C, var/turf/pos, var/list/crew_data)
	. = ..()
	set_dead(crew_data)
	return MOD_SUIT_SENSORS_HANDLED

/* Random */
/crew_sensor_modifier/vital/jamming/random
	var/error_prob = 25

/crew_sensor_modifier/vital/jamming/random/moderate
	error_prob = 50

/crew_sensor_modifier/vital/jamming/random/major
	error_prob = 100

/crew_sensor_modifier/vital/jamming/random/process_crew_data(var/mob/living/carbon/human/H, var/obj/item/clothing/under/C, var/turf/pos, var/list/crew_data)
	. = ..()
	if(prob(error_prob))
		pick(set_healthy(crew_data), set_dead(crew_data))
