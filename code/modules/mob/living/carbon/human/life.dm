//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!
#define HUMAN_MAX_OXYLOSS 1 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 5 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 12 //Amount of damage applied when your body temperature passes the 1000K point

#define COLD_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 9 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

#define RADIATION_SPEED_COEFFICIENT 0.025

/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/co2_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/temperature_alert = 0
	var/heartbeat = 0
	var/stamina = 100

/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return

	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	// update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	..()

	if(life_tick%30==15)
		hud_updateflag = 1022

	voice = GetVoice()

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !InStasis())
		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Organs and blood
		handle_nutrition()
		handle_bleeding()
		process_hemodynamics()
		consume_oxygen(3.13) //skeletal muscle+soft tissues
		handle_organs()
		stabilize_body_temperature() //Body temperature adjusts itself (self-regulation)

		handle_symptoms()
		handle_shock()
		handle_lust()
		handle_pain()

	if(!handle_some_updates())
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Update our name based on whether our face is obscured/disfigured
	SetName(get_visible_name())

/mob/living/carbon/human/get_stamina()
	return oxygen_amount / max_oxygen_capacity * 100

/mob/living/carbon/human/adjust_stamina(var/amt)
	add_oxygen(amt)

/mob/living/carbon/human/proc/handle_symptoms()
	if(!length(symptoms))
		return
	var/all_alert_messages = list()
	for(var/symptom in symptoms)
		var/decl/medical_symptom/sympt = GET_DECL(symptom)
		sympt.time += 2
		if(sympt.can_go_away(src))
			sympt.go_away(src)
			continue
		if(sympt.periodical_message)
			all_alert_messages += sympt.periodical_message
		sympt.apply_pain(src)
	if(next_symptom_message < world.time && length(all_alert_messages))
		next_symptom_message = world.time + 300
		to_chat(src, SPAN_WARNING(pick(all_alert_messages)))

/mob/living/carbon/human/proc/handle_stamina()
	return

/mob/living/carbon/human/set_stat(var/new_stat)
	var/old_stat = stat
	. = ..()
	if(stat)
		retrieve_from_limb()
		update_skin(1)
	if(client && client.is_afk())
		if(old_stat == UNCONSCIOUS && stat == CONSCIOUS)
			playsound_local(null, 'sound/effects/bells.ogg', 100, is_global=TRUE)

/mob/living/carbon/human/proc/handle_some_updates()
	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return 0
	return 1

/mob/living/carbon/human/breathe()
	var/species_organ = species.breathing_organ

	if(species_organ)
		var/active_breaths = 0
		var/obj/item/organ/internal/lungs/L = get_organ(species_organ, /obj/item/organ/internal/lungs)
		if(L)
			active_breaths = L.active_breathing
		. = ..(active_breaths)

// Calculate how vulnerable the human is to the current pressure.
// Returns 0 (equals 0 %) if sealed in an undamaged suit that's rated for the pressure, 1 if unprotected (equals 100%).
// Suitdamage can modifiy this in 10% steps.
/mob/living/carbon/human/proc/get_pressure_weakness(pressure)

	var/pressure_adjustment_coefficient = 0
	var/list/zones = list(SLOT_HEAD, SLOT_UPPER_BODY, SLOT_LOWER_BODY, SLOT_LEGS, SLOT_FEET, SLOT_ARMS, SLOT_HANDS)
	for(var/zone in zones)
		var/list/covers = get_covering_equipped_items(zone)
		var/zone_exposure = 1
		for(var/obj/item/clothing/C in covers)
			zone_exposure = min(zone_exposure, C.get_pressure_weakness(pressure,zone))
		if(zone_exposure >= 1)
			return 1
		pressure_adjustment_coefficient = max(pressure_adjustment_coefficient, zone_exposure)
	pressure_adjustment_coefficient = Clamp(pressure_adjustment_coefficient, 0, 1) // So it isn't less than 0 or larger than 1.

	return pressure_adjustment_coefficient

// Calculate how much of the enviroment pressure-difference affects the human.
/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	var/pressure_difference

	// First get the absolute pressure difference.
	if(pressure < ONE_ATMOSPHERE) // We are in an underpressure.
		pressure_difference = ONE_ATMOSPHERE - pressure

	else //We are in an overpressure or standard atmosphere.
		pressure_difference = pressure - ONE_ATMOSPHERE

	if(pressure_difference < 5) // If the difference is small, don't bother calculating the fraction.
		pressure_difference = 0

	else
		// Otherwise calculate how much of that absolute pressure difference affects us, can be 0 to 1 (equals 0% to 100%).
		// This is our relative difference.
		pressure_difference *= get_pressure_weakness(pressure)

	// The difference is always positive to avoid extra calculations.
	// Apply the relative difference on a standard atmosphere to get the final result.
	// The return value will be the adjusted_pressure of the human that is the basis of pressure warnings and damage.
	if(pressure < ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE - pressure_difference
	else
		return ONE_ATMOSPHERE + pressure_difference

/mob/living/carbon/human/handle_impaired_vision()
	..()
	//Vision
	var/obj/item/organ/vision
	if(species.vision_organ)
		vision = GET_INTERNAL_ORGAN(src, species.vision_organ)

	if(!species.vision_organ) // Presumably if a species has no vision organs, they see via some other means.
		set_status(STAT_BLIND, 0)
		blinded =    0
		set_status(STAT_BLURRY, 0)
	else if(!vision || (vision && !vision.is_usable()))   // Vision organs cut out or broken? Permablind.
		set_status(STAT_BLIND, 1)
		blinded =    1
		set_status(STAT_BLURRY, 1)
	else
		//blindness
		if(!(sdisabilities & BLINDED))
			if(equipment_tint_total >= TINT_BLIND)	// Covered eyes, heal faster
				ADJ_STATUS(src, STAT_BLURRY, -1)

/mob/living/carbon/human/handle_disabilities()
	..()
	if(stat != DEAD)
		if ((disabilities & COUGHING) && prob(5) && GET_STATUS(src, STAT_PARA) <= 1)
			drop_held_items()
			spawn(0)
				emote("cough")

//Our radiation dose is defined in sieverts.
//1000mSv is the minimum for all effects.
//1000-2000mSv causes very rare vomiting, slight headache, low immunity, fatigue and weakness.
//2000-6000mSv causes rare vomiting, moderate headache, slight fever, slight brain damage, low immunity, internal bleeding and infections
//6000-8000mSv causes vomiting, severe headache, severe fever, moderate brain damage, immunity loss, internal bleeding, infections, disorientation, hypotension, rare arrythmias
//8000-30000mSv causes heavy vomiting, debilitating headache, very severe fever, severe brain damage, immunity loss, infections, internal bleeding, severe hypotension
//>30000mSv causes all of the above, except with frequent seizures, tremor, ataxia, sleepiness and death within a hour.
//100000mSv is death in a matter of minutes. We'll just shut down the heart, cause extreme bleeding and hypotension with added brain damage
/mob/living/carbon/human/handle_mutations_and_radiation()
	if(getFireLoss())
		if((MUTATION_COLD_RESISTANCE in mutations) || (prob(1)))
			heal_organ_damage(0,1)

	// DNA2 - Gene processing.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			gene.OnMobLife(src)

	if(srec_dose)
		handle_srec()

	if(!radiation)
		if(species.appearance_flags & RADIATION_GLOWS)
			set_light(0)
	else
		if(species.appearance_flags & RADIATION_GLOWS)
			set_light(max(1,min(10,radiation/10)), max(1,min(20,radiation/20)), species.get_flesh_colour(src))
		// END DOGSHIT SNOWFLAKE

		//TODO: Headache
		switch(radiation)
			if(1000 to 2000)
				if(prob(0.1))
					vomit()
				adjust_immunity(-0.3)
				to_chat_cooldown(src, SPAN_WARNING("You feel [pick("weak", "tired")]..."), "radweak", rand(2 MINUTES, 5 MINUTES))
			if(2000 to 6000)
				if(prob(1))
					vomit()
					adjustToxLoss(1)
				bodytemperature += rand(1.3, 1.4)
				var/obj/item/organ/internal/brain/cur_brain = GET_INTERNAL_ORGAN(src, BP_BRAIN)
				cur_brain.take_internal_damage(0.01)
				adjust_immunity(-0.5)
				to_chat_cooldown(src, SPAN_WARNING("You feel quite [pick("weak", "tired")]..."), "radweak", rand(2 MINUTES, 5 MINUTES))
			if(6000 to 8000)
				if(prob(2))
					vomit()
					adjustToxLoss(1.5)
				var/obj/item/organ/internal/heart/cur_heart = GET_INTERNAL_ORGAN(src, BP_HEART)
				if(prob(1))
					take_organ_damage(0, 2, 1)
					cur_heart.instability += 40
				add_chemical_effect(CE_PRESSURE, rand(-8, -11))
				bodytemperature += rand(2.6, 2.7)
				var/obj/item/organ/internal/brain/cur_brain = GET_INTERNAL_ORGAN(src, BP_BRAIN)
				cur_brain.take_internal_damage(0.03)
				adjust_immunity(-1)
				to_chat_cooldown(src, SPAN_WARNING("You feel very [pick("weak", "tired")]..."), "radweak", rand(2 MINUTES, 5 MINUTES))
			if(8000 to INFINITY)
				if(prob(5))
					vomit()
					adjustToxLoss(5)
				var/obj/item/organ/internal/heart/cur_heart = GET_INTERNAL_ORGAN(src, BP_HEART)
				if(prob(3))
					take_organ_damage(0, 5, 1)
					cur_heart.instability += 60
				add_chemical_effect(CE_PRESSURE, rand(-11, -17))
				bodytemperature += rand(3.4, 3.5)
				var/obj/item/organ/internal/brain/cur_brain = GET_INTERNAL_ORGAN(src, BP_BRAIN)
				cur_brain.take_internal_damage(0.05)
				adjust_immunity(-10)
				to_chat_cooldown(src, SPAN_DANGER("You feel extremely [pick("weak", "tired")]..."), "radweak", rand(2 MINUTES, 5 MINUTES))
				if(radiation > 30000)
					add_chemical_effect(CE_GLOWINGEYES, 1)
					take_overall_damage(0, 3, used_weapon = "Radiation Burns")
					if(prob(1))
						seizure()
				if(radiation > 100000) //exitus letalis
					cur_heart.instability += 1000
					cur_brain.take_internal_damage(1)

// An infection by Self-Replicating Electrotrophic Crystals.
// These silicon-like crystals use electricity for metabolism.
// The disease progression to the lethal stage may take dozens of years, but any electrical shocks strongly exacerbate it.
// SREC prevents microperfusion in capillary vessels, disrupting the delivery of oxygen to vital parts of the body.
// In very high doses it disrupts biochemistry, causing widespread tissue damage with septic shock.

// Our SREC dose is defined in mcg/ml.
// Infections below below 80 mcg/ml are considered benign and won't show any symptoms.
// 80-120 mcg/ml shows disrupted microperfusion: weakened vision, occasional tickling in the extremities and slight skin paleness.
// 120-140 mcg/ml presents weakness, the eyes lose color, outer limbs get reduced pain sensation. No appetite.
// 140-160 mcg/ml is where flu-like symptoms appear as the immune system responds to hypoperfusion in outer tissues. Heighetened body temp and weakness.
// 160-180 mcg/ml. The immune system is totally inhibited. The eyes develop a greenish tinge and partial paralysis of outer limbs may occur.
// 180-200 mcg/ml. The dose can be much higher, but this is where things likely end. The slightest electric shock can cause a total circulatory collapse.
// >200 mcg/ml. Survival is extremely unlikely without medication as organ failure begins to set in.
// From this point, medication is mandatory for survival. Symptoms don't really change, just their intensity.
// >700 mcg/ml. Late stage of infection. Limbs crystallize.
/mob/living/carbon/human/proc/handle_srec()
	var/inhibition_factor = GET_CHEMICAL_EFFECT(src, CE_SREC) + 1
	if(srec_dose > 160 && inhibition_factor < 1.1) //Replicate
		srec_dose *= 1.001

	if(srec_dose > 80)
		var/obj/item/organ/internal/heart/cur_heart = GET_INTERNAL_ORGAN(src, BP_HEART)
		var/dose_sqrt = sqrt(srec_dose) / inhibition_factor
		cur_heart.cardiac_output_modifiers["SREC"] = 1 - (dose_sqrt * 0.003 / inhibition_factor)
		cur_heart.stability_modifiers["SREC"] = -1.25 * (dose_sqrt / inhibition_factor)
		if(client)
			change_skin_tone(round(client.prefs.skin_tone * 1 - dose_sqrt * 0.003))
		to_chat_cooldown(src, SPAN_INFO("Your skin tickles.."), "srectickle", rand(2 MINUTES, 5 MINUTES * inhibition_factor))
	else
		return
	if(srec_dose > 120)
		if(srec_dose < 160)
			change_eye_color(COLOR_GRAY)
		adjustHalLoss(-150)
		add_chemical_effect(CE_PAINKILLER, 150)
		adjust_stamina(srec_dose * -0.05 / inhibition_factor)
		to_chat_cooldown(src, SPAN_WARNING("You feel weak."), "srecweak", rand(4 MINUTES, 10 MINUTES * inhibition_factor))
	else
		return
	if(srec_dose > 140)
		if(prob(sqrt(srec_dose) * 0.1 / inhibition_factor))
			emote("cough")
		bodytemperature += rand(1.3, 1.4) / inhibition_factor
		adjust_immunity(-1 / inhibition_factor)
		add_chemical_effect(CE_PAINKILLER, 300)
		if(srec_dose < 160)
			to_chat_cooldown(src, SPAN_WARNING("You feel very sick."), "srecsick", rand(4 MINUTES, 10 MINUTES * inhibition_factor))
	else
		return
	if(srec_dose > 160)
		adjust_immunity(-10 / inhibition_factor)
		change_eye_color(COLOR_GREEN_GRAY)
		adjustHalLoss(-400)
		add_chemical_effect(CE_PAINKILLER, 400)
		to_chat_cooldown(src, SPAN_DANGER(pick("Tiny crystals crawl under your skin.", "You feel something churning up inside.")), "srecsick", rand(4 MINUTES, 10 MINUTES * inhibition_factor))
	if(srec_dose > 700)
		var/list/limbs = get_external_organs()
		var/list/shuffled_limbs = LAZYLEN(limbs) ? shuffle(limbs.Copy()) : null
		for(var/obj/item/organ/external/E in shuffled_limbs)
			if(BP_IS_PROSTHETIC(E))
				continue

			if(BP_IS_CRYSTAL(E))
				if((E.brute_dam + E.burn_dam) > 0)
					if(prob(35))
						to_chat(src, SPAN_NOTICE("You feel a crawling sensation as fresh crystal grows over your [E.name]."))
					E.heal_damage(rand(5,8), rand(5,8))
					break
				if(BP_IS_BRITTLE(E))
					E.status &= ~ORGAN_BRITTLE
					break
			else if(E.organ_tag != BP_CHEST && E.organ_tag != BP_GROIN && prob(15))
				to_chat(src, SPAN_DANGER("Your [E.name] is being lacerated from within!"))
				if(E.can_feel_pain())
					emote("scream")
				if(prob(25))
					for(var/i = 1 to rand(3,5))
						new /obj/item/shard(get_turf(E), /decl/material/solid/static_crystal)
					E.dismember(0, DISMEMBER_METHOD_BLUNT)
				else
					E.take_external_damage(rand(20,30), 0)
					BP_SET_CRYSTAL(E)
					E.status |= ORGAN_BRITTLE
				break
	if(srec_dose > 1000) //we explodeee
		var/turf/T = get_turf(src)
		gib()
		new /obj/effect/crystal_growth/meat(T)
		new /obj/effect/crystal_wall(T)

/mob/living/carbon/human/handle_chemical_smoke(var/datum/gas_mixture/environment)
	for(var/slot in global.standard_headgear_slots)
		var/obj/item/gear = get_equipped_item(slot)
		if(istype(gear) && (gear.item_flags & ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT))
			return
	..()

/mob/living/carbon/human/handle_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return
	var/species_organ = species.breathing_organ
	if(!species_organ)
		return

	var/obj/item/organ/internal/lungs/L = get_organ(species_organ, /obj/item/organ/internal/lungs)
	if(!L || nervous_system_failure())
		failed_last_breath = 1
	else
		failed_last_breath = L.handle_breath(breath) //if breath is null or vacuum, the lungs will handle it for us
	return !failed_last_breath

#define DEFAULT_HUMAN_INSULATION_COEF 0.2
#define BURN_DAMAGE_FACTOR (1 - DEFAULT_HUMAN_INSULATION_COEF)
#define BURN_DAMAGE_INSULATION_DIVISOR 300 // this much burn damage will cause us to completely lose skin insulation
/mob/living/carbon/human/proc/get_insulation_coef()
	return min(MAX_TEMPERATURE_COEFFICIENT, DEFAULT_HUMAN_INSULATION_COEF + (getFireLoss() / BURN_DAMAGE_INSULATION_DIVISOR * BURN_DAMAGE_FACTOR))

#undef DEFAULT_HUMAN_INSULATION_COEF
#undef BURN_DAMAGE_FACTOR
#undef BURN_DAMAGE_INSULATION_DIVISOR

/mob/living/carbon/human/proc/get_adjusted_environment_temp(datum/gas_mixture/environment)
	var/body_covered_coef = 0 // coefficient representing the percentage of body covered with clothing
	var/clothing_count = 0
	var/clothing_temp_sum = 0
	var/protection_bitflag = 0
	for(var/slot in global.standard_clothing_slots)
		var/obj/item/clothing/C = get_equipped_item(slot)
		if(istype(C))
			clothing_count++
			clothing_temp_sum += C.temperature
			protection_bitflag |= C.cold_protection
			if(C.accessories.len)
				for(var/obj/item/clothing/accessory/A in C.accessories)
					protection_bitflag |= A.cold_protection
	body_covered_coef = get_thermal_protection(protection_bitflag)

	if(!body_covered_coef || !clothing_count)
		return environment.temperature

	var/average_clothing_temperature = clothing_temp_sum / clothing_count
	return Interpolate(environment.temperature, average_clothing_temperature, body_covered_coef)

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)

	..()

	if(!environment || (MUTATION_SPACERES in mutations))
		return

	//Stuff like water absorbtion happens here.
	species.handle_environment_special(src)

	//Moved pressure calculations here for use in skip-processing check.
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)

	//Check for contaminants before anything else because we don't want to skip it.
	for(var/g in environment.gas)
		var/decl/material/mat = GET_DECL(g)
		if((mat.gas_flags & XGM_GAS_CONTAMINANT) && environment.gas[g] > mat.gas_overlay_limit + 1)
			handle_contaminants()
			break

	if(isspaceturf(src.loc)) //being in a closet will interfere with radiation, may not make sense but we don't model radiation for atoms in general so it will have to do for now.
		//Don't bother if the temperature drop is less than 0.1 anyways. Hopefully BYOND is smart enough to turn this constant expression into a constant
		if(bodytemperature > (0.1 * HUMAN_HEAT_CAPACITY/(HUMAN_EXPOSED_SURFACE_AREA*STEFAN_BOLTZMANN_CONSTANT))**(1/4) + COSMIC_RADIATION_TEMPERATURE)

			//Thermal radiation into space
			var/heat_gain = get_thermal_radiation(bodytemperature, HUMAN_EXPOSED_SURFACE_AREA, 0.5, SPACE_HEAT_TRANSFER_COEFFICIENT)

			var/temperature_gain = heat_gain/HUMAN_HEAT_CAPACITY
			bodytemperature += temperature_gain //temperature_gain will often be negative

	var/relative_density = (environment.total_moles/environment.volume) / (MOLES_CELLSTANDARD/CELL_VOLUME)
	if(relative_density > 0.02) //don't bother if we are in vacuum or near-vacuum
		var/loc_temp = environment.temperature

		if(adjusted_pressure < species.warning_high_pressure && adjusted_pressure > species.warning_low_pressure && abs(loc_temp - bodytemperature) < 20 && bodytemperature < species.heat_level_1 && bodytemperature > species.cold_level_1 && species.body_temperature)
			pressure_alert = 0
			return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

		//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection (convection)
		var/temp_diff = get_adjusted_environment_temp(environment) - bodytemperature
		bodytemperature += get_insulation_coef() * temp_diff

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature >= getSpeciesOrSynthTemp(HEAT_LEVEL_1))
		//Body temperature is too hot.
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)	return 1	//godmode
		var/burn_dam = (bodytemperature - species.heat_level_1) * 0.03
		take_overall_damage(burn=burn_dam, used_weapon = "High Body Temperature", armor_pen = 200)
		fire_alert = max(fire_alert, 2)

	else if(bodytemperature <= getSpeciesOrSynthTemp(COLD_LEVEL_1))
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)	return 1	//godmode

		var/burn_dam = (species.heat_level_1 - bodytemperature) * 0.02
		take_overall_damage(burn=burn_dam, used_weapon = "Low Body Temperature", armor_pen = 200)
		var/obj/item/organ/external/victim = pick(internal_organs)
		victim.germ_level += burn_dam
		fire_alert = max(fire_alert, 1)

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!
	if(status_flags & GODMODE)	return 1	//godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		var/pressure_damage = min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
		take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure", armor_pen = 15)
		pressure_alert = 2
	else if(adjusted_pressure >= species.warning_high_pressure)
		pressure_alert = 1
	else if(adjusted_pressure >= species.warning_low_pressure)
		pressure_alert = 0
	else if(adjusted_pressure >= species.hazard_low_pressure)
		pressure_alert = -1
	else
		var/list/obj/item/organ/external/parts = get_damageable_organs()
		for(var/obj/item/organ/external/O in parts)
			if(QDELETED(O) || !(O.owner == src))
				continue
			if(O.damage + (LOW_PRESSURE_DAMAGE) < O.min_broken_damage) //vacuum does not break bones
				O.take_external_damage(brute = LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
		pressure_alert = -2
		overlay_fullscreen("brute", /obj/screen/fullscreen/brute, 6)
	vacuum_message_spam_cooldown -= 1
	if(pressure_alert && vacuum_message_spam_cooldown < 0)
		vacuum_message_spam_cooldown = 30
		var/pressure_message = ""
		switch(pressure_alert)
			if(-2)
				pressure_message = "<span class=bigdanger>Your vision becomes crimson red, you're in a vacuum!</span>"
			if(-1)
				pressure_message = "<span class=danger>You feel the air getting thinner!</span>"
		to_chat(src, pressure_message)
	return

/mob/living/carbon/human/proc/stabilize_body_temperature()
	// We produce heat naturally.
	if (species.passive_temp_gain)
		bodytemperature += species.passive_temp_gain

	// Robolimbs cause overheating too.
	if(robolimb_count)
		bodytemperature += round(robolimb_count/2)

	if (species.body_temperature == null || isSynthetic())
		return //this species doesn't have metabolic thermoregulation

	var/body_temperature_difference = species.body_temperature - bodytemperature

	if (abs(body_temperature_difference) < 0.5)
		return //fuck this precision

	if (on_fire)
		return //too busy for pesky metabolic regulation

	if(bodytemperature < species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
		var/nut_remove = 10 * DEFAULT_HUNGER_FACTOR
		if(nutrition >= nut_remove) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
			adjust_nutrition(-nut_remove)
			bodytemperature += max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
	else if(species.cold_level_1 <= bodytemperature && bodytemperature <= species.heat_level_1)
		bodytemperature += body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
	else if(bodytemperature > species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		var/hyd_remove = 10 * DEFAULT_THIRST_FACTOR
		if(hydration >= hyd_remove)
			adjust_hydration(-hyd_remove)
			bodytemperature += min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)

	//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, SLOT_UPPER_BODY, SLOT_LOWER_BODY, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	. = 0
	//Handle normal clothing
	for(var/slot in global.standard_clothing_slots)
		var/obj/item/clothing/C = get_equipped_item(slot)
		if(istype(C))
			if(C.max_heat_protection_temperature && C.max_heat_protection_temperature >= temperature)
				. |= C.heat_protection
			if(C.accessories.len)
				for(var/obj/item/clothing/accessory/A in C.accessories)
					if(A.max_heat_protection_temperature && A.max_heat_protection_temperature >= temperature)
						. |= A.heat_protection

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	. = 0
	//Handle normal clothing
	for(var/slot in global.standard_clothing_slots)
		var/obj/item/clothing/C = get_equipped_item(slot)
		if(istype(C))
			if(C.min_cold_protection_temperature && C.min_cold_protection_temperature <= temperature)
				. |= C.cold_protection
			if(C.accessories.len)
				for(var/obj/item/clothing/accessory/A in C.accessories)
					if(A.min_cold_protection_temperature && A.min_cold_protection_temperature <= temperature)
						. |= A.cold_protection


/mob/living/carbon/human/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = get_heat_protection_flags(temperature)
	return get_thermal_protection(thermal_protection_flags)

/mob/living/carbon/human/get_cold_protection(temperature)
	if(MUTATION_COLD_RESISTANCE in mutations)
		return 1 //Fully protected from the cold.

	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)
	return get_thermal_protection(thermal_protection_flags)

/mob/living/carbon/human/proc/get_thermal_protection(var/flags)
	.=0
	if(flags)
		if(flags & SLOT_HEAD)
			. += THERMAL_PROTECTION_HEAD
		if(flags & SLOT_UPPER_BODY)
			. += THERMAL_PROTECTION_UPPER_TORSO
		if(flags & SLOT_LOWER_BODY)
			. += THERMAL_PROTECTION_LOWER_TORSO
		if(flags & SLOT_LEG_LEFT)
			. += THERMAL_PROTECTION_LEG_LEFT
		if(flags & SLOT_LEG_RIGHT)
			. += THERMAL_PROTECTION_LEG_RIGHT
		if(flags & SLOT_FOOT_LEFT)
			. += THERMAL_PROTECTION_FOOT_LEFT
		if(flags & SLOT_FOOT_RIGHT)
			. += THERMAL_PROTECTION_FOOT_RIGHT
		if(flags & SLOT_ARM_LEFT)
			. += THERMAL_PROTECTION_ARM_LEFT
		if(flags & SLOT_ARM_RIGHT)
			. += THERMAL_PROTECTION_ARM_RIGHT
		if(flags & SLOT_HAND_LEFT)
			. += THERMAL_PROTECTION_HAND_LEFT
		if(flags & SLOT_HAND_RIGHT)
			. += THERMAL_PROTECTION_HAND_RIGHT
	return min(1,.)

/mob/living/carbon/human/apply_chemical_effects()
	. = ..()
	if(has_chemical_effect(CE_GLOWINGEYES, 1))
		update_eyes()
		return TRUE

// Check if we should die.
/mob/living/carbon/human/proc/handle_death_check()
	if(should_have_organ(BP_BRAIN))
		var/obj/item/organ/internal/brain = GET_INTERNAL_ORGAN(src, BP_BRAIN)
		if(!brain || (brain.status & ORGAN_DEAD))
			return TRUE
	return species.handle_death_check(src)

/mob/living/carbon/human/handle_regular_status_updates()
	if(!handle_some_updates())
		return 0

	if(status_flags & GODMODE)	return 0

	//SSD check, if a logged player is awake put them back to sleep!
	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		set_status(STAT_SILENCE, 0)
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()	//TODO

		if(handle_death_check())
			death()
			blinded = 1
			set_status(STAT_SILENCE, 0)
			return 1

		if(hallucination_power)
			handle_hallucinations()

		if(get_shock() >= 1000)
			if(!stat)
				to_chat(src, "<span class='warning'>[species.halloss_message_self]</span>")
				src.visible_message("<B>[src]</B> [species.halloss_message]")
			SET_STATUS_MAX(src, STAT_PARA, 10)

		if(HAS_STATUS(src, STAT_PARA) ||HAS_STATUS(src, STAT_ASLEEP))
			blinded = 1
			set_stat(UNCONSCIOUS)
			animate_tail_reset()
			adjustHalLoss(-3)

			if(prob(2) && is_asystole() && isSynthetic())
				visible_message("<b>[src]</b> [pick("emits low pitched whirr","beeps urgently")].")
		//CONSCIOUS
		else
			set_stat(CONSCIOUS)

		// Check everything else.

		//Periodically double-check embedded_flag
		if(embedded_flag && !(life_tick % 10))
			if(!embedded_needs_process())
				embedded_flag = 0

		if(syspressure > 140)
			add_symptom(/decl/medical_symptom/headache)

		//Resting
		var/status_relief_modifier = resting * 5 + meditating
		if(HAS_STATUS(src, STAT_DIZZY))
			ADJ_STATUS(src, STAT_DIZZY, -3 * status_relief_modifier)
		if(HAS_STATUS(src, STAT_JITTER))
			ADJ_STATUS(src, STAT_JITTER, -3 * status_relief_modifier)
		adjustHalLoss(-1 * status_relief_modifier)

		if(HAS_STATUS(src, STAT_DROWSY))
			SET_STATUS_MAX(src, STAT_BLURRY, 2)
			var/sleepy = GET_STATUS(src, STAT_DROWSY)
			if(sleepy > 10)
				var/zzzchance = min(5, 5*sleepy/30)
				if((prob(zzzchance) || sleepy >= 60))
					if(stat == CONSCIOUS)
						to_chat(src, "<span class='notice'>You are about to fall asleep...</span>")
					SET_STATUS_MAX(src, STAT_ASLEEP, 5)

		// If you're dirty, your gloves will become dirty, too.
		var/obj/item/gloves = get_equipped_item(slot_gloves_str)
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

		if(vsc.contaminant_control.CONTAMINATION_LOSS)
			var/total_contamination= 0
			for(var/obj/item/I in src)
				if(I.contaminated)
					total_contamination += vsc.contaminant_control.CONTAMINATION_LOSS
			adjustToxLoss(total_contamination)

		// nutrition decrease
		if(nutrition > 0)
			adjust_nutrition(-species.hunger_factor)
		if(hydration > 0)
			adjust_hydration(-species.thirst_factor)

		if(stasis_value > 1 && GET_STATUS(src, STAT_DROWSY) < stasis_value * 4)
			ADJ_STATUS(src, STAT_DROWSY, min(stasis_value, 3))
			if(!stat && prob(1))
				to_chat(src, "<span class='notice'>You feel slow and sluggish...</span>")

		var/obj/item/organ/internal/heart/H = GET_INTERNAL_ORGAN(src, BP_HEART)
		if(H && stat == CONSCIOUS)
			if(length(H.arrythmias) || H.pulse > PULSE_2FAST)
				to_chat_cooldown(src, SPAN_DANGER("Your heart [pick("flutters", "hurts", "pounds")]!"), "palpitations", 30 SECONDS)

	return 1

/mob/living/carbon/human/handle_regular_hud_updates()
	if(hud_updateflag) // update our mob's hud overlays, AKA what others see flaoting above our head
		handle_hud_list()

	// now handle what we see on our screen

	if(!..())
		return

	if(stat != DEAD)
		if(stat == UNCONSCIOUS)
			//Critical damage passage overlay
			var/severity = 0
			var/obj/item/organ/internal/brain/B = GET_INTERNAL_ORGAN(src, BP_BRAIN)
			switch(B.oxygen_deprivation)
				if(0 to 2)				severity = 1
				if(2 to 4)				severity = 2
				if(4 to 6)				severity = 3
				if(6 to 8)				severity = 4
				if(8 to 10)				severity = 5
				if(10 to 12)			severity = 6
				if(12 to 14)			severity = 7
				if(14 to 16)			severity = 8
				if(16 to 18)			severity = 9
				if(18 to 20)			severity = 10
			overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
		else
			clear_fullscreen("crit")
			//Oxygen damage overlay
			var/blood_perfusion = get_blood_perfusion()
			if(blood_perfusion < 0.8 || srec_dose > 80)
				var/severity = 0
				switch(blood_perfusion)
					if(0.8 to 0.92)		severity = 1
					if(0.7 to 0.8)		severity = 2
					if(0.65 to 0.7)		severity = 3
					if(0.6 to 0.65)		severity = 4
					if(0.55 to 0.6)		severity = 5
					if(0.5 to 0.55)		severity = 6
					if(0 to 0.5)		severity = 7
				if(srec_dose > 80)
					severity += 1
					if(srec_dose > 160)
						severity += 1
				severity = min(severity, 7)
				overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
				if(REAGENT_VOLUME(bloodstr, /decl/material/liquid/adrenaline) > 0.1) //we are JACKED on adrenaline
					if(blood_perfusion < 0.9)
						add_client_color(/datum/client_color/oxygendeprivation_oversat)
					else
						remove_client_color(/datum/client_color/oxygendeprivation_oversat)
				else
					if(blood_perfusion < 0.7)
						add_client_color(/datum/client_color/oxygendeprivation_desat)
			else
				clear_fullscreen("oxy")
				remove_client_color(/datum/client_color/oxygendeprivation_oversat)
				remove_client_color(/datum/client_color/oxygendeprivation_desat)

		if(REAGENT_VOLUME(bloodstr, /decl/material/liquid/adrenaline) > 0.1)
			overlay_fullscreen("adrenalnoise",/obj/screen/fullscreen/noise/adrenal)
		else
			clear_fullscreen("adrenalnoise")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp + (get_shock() * 0.1)
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(10 to 40)		severity = 1
				if(40 to 70)		severity = 2
				if(70 to 100)		severity = 3
				if(100 to 150)		severity = 4
				if(150 to 250)		severity = 5
				if(250 to INFINITY)	severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

		if(healths)

			var/mutable_appearance/healths_ma = new(healths)
			healths_ma.icon_state = "blank"
			healths_ma.overlays = null

			if(has_chemical_effect(CE_PAINKILLER, 100))
				healths_ma.icon_state = "health_numb"
			else
				// Generate a by-limb health display.
				var/no_damage = 1
				var/trauma_val = 0 // Used in calculating softcrit/hardcrit indicators.
				if(can_feel_pain())
					trauma_val = max(shock_stage,get_shock())/700
				// Collect and apply the images all at once to avoid appearance churn.
				var/list/health_images = list()
				for(var/obj/item/organ/external/E in get_external_organs())
					if(no_damage && (E.brute_dam || E.burn_dam))
						no_damage = 0
					health_images += E.get_damage_hud_image()

				// Apply a fire overlay if we're burning.
				if(on_fire)
					health_images += image('icons/hud/screen1_health.dmi',"burning")

				// Show a general pain/crit indicator if needed.
				if(is_asystole())
					health_images += image('icons/hud/screen1_health.dmi',"hardcrit")
				else if(trauma_val)
					if(can_feel_pain())
						if(trauma_val > 0.7)
							health_images += image('icons/hud/screen1_health.dmi',"softcrit")
						if(trauma_val >= 1)
							health_images += image('icons/hud/screen1_health.dmi',"hardcrit")
				else if(no_damage)
					health_images += image('icons/hud/screen1_health.dmi',"fullhealth")
				healths_ma.overlays += health_images
			healths.appearance = healths_ma

		if(nutrition_icon)
			switch(nutrition)
				if(300 to INFINITY)				nutrition_icon.icon_state = "nutrition0"
				if(250 to 300)					nutrition_icon.icon_state = "nutrition1"
				if(200 to 250)					nutrition_icon.icon_state = "nutrition2"
				if(150 to 200)					nutrition_icon.icon_state = "nutrition3"
				else							nutrition_icon.icon_state = "nutrition4"

		if(hydration_icon)
			switch(hydration)
				if(300 to INFINITY)				hydration_icon.icon_state = "hydration0"
				if(200 to 300)					hydration_icon.icon_state = "hydration1"
				if(150 to 200)					hydration_icon.icon_state = "hydration2"
				if(100 to 150)					hydration_icon.icon_state = "hydration3"
				else							hydration_icon.icon_state = "hydration4"

		if(isSynthetic())
			var/obj/item/organ/internal/cell/C = get_organ(BP_CELL, /obj/item/organ/internal/cell)
			if(C)
				var/chargeNum = Clamp(CEILING(C.percent()/25), 0, 4)	//0-100 maps to 0-4, but give it a paranoid clamp just in case.
				cells.icon_state = "charge[chargeNum]"
			else
				cells.icon_state = "charge-empty"

		if(pressure)
			pressure.icon_state = "pressure[pressure_alert]"
		if(toxin)
			toxin.icon_state = "tox[toxins_alert ? "1" : "0"]"
		if(oxygen)
			oxygen.icon_state = "oxy[oxygen_alert ? "1" : "0"]"
		if(fire)
			fire.icon_state = "fire[fire_alert ? fire_alert : 0]"

		if(bodytemp)
			if (!species)
				switch(bodytemperature) //309.8 optimal body temp
					if(42 CELSIUS to INFINITY)				bodytemp.icon_state = "temp4"
					if(40 CELSIUS to 42 CELSIUS)			bodytemp.icon_state = "temp3"
					if(39 CELSIUS to 40 CELSIUS)			bodytemp.icon_state = "temp2"
					if(37.5 CELSIUS to 39 CELSIUS)			bodytemp.icon_state = "temp1"
					if(36 CELSIUS to 37.5 CELSIUS)			bodytemp.icon_state = "temp0"
					if(35 CELSIUS to 36 CELSIUS)			bodytemp.icon_state = "temp-1"
					if(34 CELSIUS to 35 CELSIUS)			bodytemp.icon_state = "temp-2"
					if(32 CELSIUS to 34 CELSIUS)			bodytemp.icon_state = "temp-3"
					else									bodytemp.icon_state = "temp-4"
			else
				//TODO: precalculate all of this stuff when the species datum is created
				var/base_temperature = species.body_temperature
				if(base_temperature == null) //some species don't have a set metabolic temperature
					base_temperature = (getSpeciesOrSynthTemp(HEAT_LEVEL_1) + getSpeciesOrSynthTemp(COLD_LEVEL_1))/2

				var/temp_step = 1.5
				if (bodytemperature >= base_temperature)
					if (bodytemperature >= getSpeciesOrSynthTemp(HEAT_LEVEL_1))
						bodytemp.icon_state = "temp4"
					else if (bodytemperature >= base_temperature + temp_step*3)
						bodytemp.icon_state = "temp3"
					else if (bodytemperature >= base_temperature + temp_step*2)
						bodytemp.icon_state = "temp2"
					else if (bodytemperature >= base_temperature + temp_step*1)
						bodytemp.icon_state = "temp1"
					else
						bodytemp.icon_state = "temp0"

				else if (bodytemperature < base_temperature)
					if (bodytemperature <= getSpeciesOrSynthTemp(COLD_LEVEL_1))
						bodytemp.icon_state = "temp-4"
					else if (bodytemperature <= base_temperature - temp_step*3)
						bodytemp.icon_state = "temp-3"
					else if (bodytemperature <= base_temperature - temp_step*2)
						bodytemp.icon_state = "temp-2"
					else if (bodytemperature <= base_temperature - temp_step*1)
						bodytemp.icon_state = "temp-1"
					else
						bodytemp.icon_state = "temp0"
	return 1

/mob/living/carbon/human/handle_random_events()
	// Puke if toxloss is too high
	var/vomit_score = 0
	for(var/tag in list(BP_LIVER,BP_KIDNEYS))
		var/obj/item/organ/internal/I = GET_INTERNAL_ORGAN(src, tag)
		if(I)
			vomit_score += I.damage
		else if (should_have_organ(tag))
			vomit_score += 45
	var/toxloss = getToxLoss()
	if(toxloss > 100)
		vomit_score += 0.15 * toxloss
	if(has_chemical_effect(CE_ALCOHOL_TOXIC, 1))
		vomit_score += 10 * GET_CHEMICAL_EFFECT(src, CE_ALCOHOL_TOXIC)
	if(has_chemical_effect(CE_ALCOHOL, 1))
		vomit_score += 10
	if(stat != DEAD && vomit_score > 25 && prob(10))
		vomit(vomit_score, vomit_score/25)

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/T = loc
		if(T.get_lumcount() <= LIGHTING_SOFT_THRESHOLD)
			playsound_local(src,pick(global.scarySounds),50, 1, -1)

	var/area/A = get_area(src)
	if(client && world.time >= client.played + A.ambience_cooldown)
		A.play_ambience(src)
	if(stat == UNCONSCIOUS && world.time - l_move_time < 5 && prob(10))
		to_chat(src,"<span class='notice'>You feel like you're [pick("moving","flying","floating","falling","hovering")].</span>")

/mob/living/carbon/human/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()

/mob/living/carbon/human/proc/handle_shock()
	if(!can_feel_pain() || (status_flags & GODMODE))
		shock_stage = 0
		return

	var/traumatic_shock = get_shock() * 0.1
	if(traumatic_shock >= max(30, 0.8*shock_stage))
		shock_stage += 1
	else if (!is_asystole())
		shock_stage = min(shock_stage, 160)
		var/recovery = 1
		if(traumatic_shock < 0.5 * shock_stage) //lower shock faster if pain is gone completely
			recovery += 2
		if(traumatic_shock < 0.25 * shock_stage)
			recovery += 5
		shock_stage = max(shock_stage - recovery, 0)
		return
	if(stat) return 0

	if(shock_stage == 10)
		// Please be very careful when calling custom_pain() from within code that relies on pain/trauma values. There's the
		// possibility of a feedback loop from custom_pain() being called with a positive power, incrementing pain on a limb,
		// which triggers this proc, which calls custom_pain(), etc. Make sure you call it with nohalloss = TRUE in these cases!
		custom_pain("[pick("It hurts so much", "You really need some painkillers", "Dear god, the pain")]!", 150, nohalloss = TRUE)

	var/obj/item/organ/internal/heart/H = get_organ(BP_HEART)
	if(shock_stage >= 30)
		if(shock_stage == 30)
			var/decl/pronouns/G = get_pronouns()
			visible_message("<b>\The [src]</b> is having trouble keeping [G.his] eyes open.")
		if(prob(30))
			SET_STATUS_MAX(src, STAT_BLURRY, 2)
			SET_STATUS_MAX(src, STAT_STUTTER, 5)
		H.bpm_modifiers["shock"] += 10
		add_chemical_effect(CE_PRESSURE, 10)

	if (shock_stage >= 60)
		if(shock_stage == 60) visible_message("<b>[src]</b>'s body becomes limp.")
		if (prob(2))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", 250, nohalloss = TRUE)
			SET_STATUS_MAX(src, STAT_WEAK, 3)
		H.bpm_modifiers["shock"] += 10
		H.stability_modifiers["shock"] -= 20
		add_chemical_effect(CE_PRESSURE, 10)

	if(shock_stage >= 80)
		if (prob(5))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", 450, nohalloss = TRUE)
			SET_STATUS_MAX(src, STAT_WEAK, 5)
		H.bpm_modifiers["shock"] += 10
		H.stability_modifiers["shock"] -= 20
		add_chemical_effect(CE_PRESSURE, 10)

	if(shock_stage >= 120)
		if(!HAS_STATUS(src, STAT_PARA) && prob(2))
			custom_pain("[pick("You black out", "You feel like you could die any moment now", "You're about to lose consciousness")]!", 750, nohalloss = TRUE)
			SET_STATUS_MAX(src, STAT_PARA, 5)
		H.bpm_modifiers["shock"] += 10
		H.stability_modifiers["shock"] -= 30
		add_chemical_effect(CE_PRESSURE, 10)

	if(shock_stage == 150)
		visible_message("<b>[src]</b> can no longer stand, collapsing!")

	if(shock_stage >= 150)
		SET_STATUS_MAX(src, STAT_WEAK, 5)

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/


/mob/living/carbon/human/proc/handle_hud_list()
	if (BITTEST(hud_updateflag, HEALTH_HUD) && hud_list[HEALTH_HUD])
		var/image/holder = hud_list[HEALTH_HUD]
		if(stat == DEAD)
			holder.icon_state = "0" 	// X_X
		else if(is_asystole())
			holder.icon_state = "flatline"
		else
			holder.icon_state = "[pulse()]"
		hud_list[HEALTH_HUD] = holder

	if (BITTEST(hud_updateflag, LIFE_HUD) && hud_list[LIFE_HUD])
		var/image/holder = hud_list[LIFE_HUD]
		if(stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"
		hud_list[LIFE_HUD] = holder

	if (BITTEST(hud_updateflag, STATUS_HUD) && hud_list[STATUS_HUD] && hud_list[STATUS_HUD_OOC])
		var/image/holder = hud_list[STATUS_HUD]
		if(stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

		var/image/holder2 = hud_list[STATUS_HUD_OOC]
		if(stat == DEAD)
			holder2.icon_state = "huddead"
		else
			holder2.icon_state = "hudhealthy"

		hud_list[STATUS_HUD] = holder
		hud_list[STATUS_HUD_OOC] = holder2

	if (BITTEST(hud_updateflag, ID_HUD) && hud_list[ID_HUD])
		var/image/holder = hud_list[ID_HUD]
		holder.icon_state = "hudunknown"

		var/obj/item/id = get_equipped_item(slot_wear_id_str)
		if(id)
			var/obj/item/card/id/I = id.GetIdCard()
			if(I)
				var/datum/job/J = SSjobs.get_by_title(I.GetJobName())
				if(J)
					holder.icon_state = J.hud_icon

		hud_list[ID_HUD] = holder

	if (BITTEST(hud_updateflag, WANTED_HUD) && hud_list[WANTED_HUD])
		var/image/holder = hud_list[WANTED_HUD]
		holder.icon_state = "hudblank"
		var/perpname = name
		var/obj/item/id = get_equipped_item(slot_wear_id_str)
		if(id)
			var/obj/item/card/id/I = id.GetIdCard()
			if(I)
				perpname = I.registered_name

		var/datum/computer_file/report/crew_record/E = get_crewmember_record(perpname)
		if(E)
			switch(E.get_criminalStatus())
				if("Arrest")
					holder.icon_state = "hudwanted"
				if("Incarcerated")
					holder.icon_state = "hudprisoner"
				if("Parolled")
					holder.icon_state = "hudparolled"
				if("Released")
					holder.icon_state = "hudreleased"
		hud_list[WANTED_HUD] = holder

	if (  BITTEST(hud_updateflag, IMPLOYAL_HUD) \
	   || BITTEST(hud_updateflag,  IMPCHEM_HUD) \
	   || BITTEST(hud_updateflag, IMPTRACK_HUD))

		var/image/holder1 = hud_list[IMPTRACK_HUD]
		var/image/holder2 = hud_list[IMPLOYAL_HUD]
		var/image/holder3 = hud_list[IMPCHEM_HUD]

		holder1.icon_state = "hudblank"
		holder2.icon_state = "hudblank"
		holder3.icon_state = "hudblank"

		for(var/obj/item/implant/I in src)
			if(I.implanted)
				if(istype(I,/obj/item/implant/tracking))
					holder1.icon_state = "hud_imp_tracking"
				if(istype(I,/obj/item/implant/loyalty))
					holder2.icon_state = "hud_imp_loyal"
				if(istype(I,/obj/item/implant/chem))
					holder3.icon_state = "hud_imp_chem"

		hud_list[IMPTRACK_HUD] = holder1
		hud_list[IMPLOYAL_HUD] = holder2
		hud_list[IMPCHEM_HUD]  = holder3

	if (BITTEST(hud_updateflag, SPECIALROLE_HUD))
		var/image/holder = hud_list[SPECIALROLE_HUD]
		holder.icon_state = "hudblank"
		if(mind && mind.assigned_special_role)
			var/special_role = mind.get_special_role_name()
			if(special_role && global.hud_icon_reference[special_role])
				holder.icon_state = global.hud_icon_reference[special_role]
			else
				holder.icon_state = "hudsyndicate"
			hud_list[SPECIALROLE_HUD] = holder
	hud_updateflag = 0

/mob/living/carbon/human/handle_fire()
	if(..())
		return

	var/burn_temperature = fire_burn_temperature()
	var/thermal_protection = get_heat_protection(burn_temperature)

	if (thermal_protection < 1 && bodytemperature < burn_temperature)
		bodytemperature += round(BODYTEMP_HEATING_MAX*(1-thermal_protection), 1)

	var/species_heat_mod = 1

	var/protected_limbs = get_heat_protection_flags(burn_temperature)


	if(species)
		if(burn_temperature < species.heat_level_2)
			species_heat_mod = 0.5
		else if(burn_temperature < species.heat_level_3)
			species_heat_mod = 0.75

	burn_temperature -= species.heat_level_1

	if(burn_temperature < 1)
		return

	for(var/obj/item/organ/external/E in get_external_organs())
		if(!(E.body_part & protected_limbs) && prob(20))
			E.take_external_damage(burn = round(species_heat_mod * log(10, (burn_temperature + 10)), 0.1), used_weapon = "fire")

/mob/living/carbon/human/rejuvenate()
	reset_blood()
	full_prosthetic = null
	shock_stage = 0
	..()
	UpdateAppearance()
	bpm = initial(bpm)
	syspressure = initial(syspressure)
	dyspressure = initial(dyspressure)
	meanpressure = initial(meanpressure)
	mcv = initial(mcv)
	oxygen_amount = normal_oxygen_capacity
	symptoms.Cut()

/mob/living/carbon/human/reset_view(atom/A)
	..()
	if(machine_visual && machine_visual != A)
		machine_visual.remove_visual(src)
	if(eyeobj)
		eyeobj.remove_visual(src)

/mob/living/carbon/human/handle_vision()
	if(client)
		var/datum/global_hud/global_hud = get_global_hud()
		client.screen.Remove(global_hud.nvg, global_hud.thermal, global_hud.meson, global_hud.science)
	if(machine)
		var/viewflags = machine.check_eye(src)
		if(viewflags < 0)
			reset_view(null, 0)
		else if(viewflags)
			set_sight(sight|viewflags)
	if(eyeobj && eyeobj.owner != src)
		reset_view(null)
	if((mRemote in mutations) && remoteview_target && remoteview_target.stat != CONSCIOUS)
		remoteview_target = null
		reset_view(null, 0)

	update_equipment_vision()
	species.handle_vision(src)

/mob/living/carbon/human/update_living_sight()
	..()
	if(GET_CHEMICAL_EFFECT(src, CE_THIRDEYE) || (MUTATION_XRAY in mutations))
		set_sight(sight|SEE_TURFS|SEE_MOBS|SEE_OBJS)
