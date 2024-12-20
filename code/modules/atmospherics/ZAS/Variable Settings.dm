var/global/vs_control/vsc = new

/vs_control
	var/fire_consuption_rate = 0.1
	var/fire_consuption_rate_NAME = "Fire - Air Consumption Ratio"
	var/fire_consuption_rate_DESC = "Ratio of air removed and combusted per tick."
	var/fluid_fire_consuption_rate = 0.03

	var/fire_firelevel_multiplier = 25
	var/fire_firelevel_multiplier_NAME = "Fire - Firelevel Constant"
	var/fire_firelevel_multiplier_DESC = "Multiplied by the equation for firelevel, affects mainly the extingiushing of fires."

	var/IgnitionLevel = 0.5
	var/IgnitionLevel_DESC = "Determines point at which fire can ignite"

	var/airflow_lightest_pressure = 20
	var/airflow_lightest_pressure_NAME = "Airflow - Small Movement Threshold %"
	var/airflow_lightest_pressure_DESC = "Percent of 1 Atm. at which items with the small weight classes will move."

	var/airflow_light_pressure = 35
	var/airflow_light_pressure_NAME = "Airflow - Medium Movement Threshold %"
	var/airflow_light_pressure_DESC = "Percent of 1 Atm. at which items with the medium weight classes will move."

	var/airflow_medium_pressure = 50
	var/airflow_medium_pressure_NAME = "Airflow - Heavy Movement Threshold %"
	var/airflow_medium_pressure_DESC = "Percent of 1 Atm. at which items with the largest weight classes will move."

	var/airflow_heavy_pressure = 85
	var/airflow_heavy_pressure_NAME = "Airflow - Mob Movement Threshold %"
	var/airflow_heavy_pressure_DESC = "Percent of 1 Atm. at which mobs will move."

	var/airflow_dense_pressure = 150
	var/airflow_dense_pressure_NAME = "Airflow - Dense Movement Threshold %"
	var/airflow_dense_pressure_DESC = "Percent of 1 Atm. at which items with canisters and closets will move."

	var/airflow_stun_pressure = 180
	var/airflow_stun_pressure_NAME = "Airflow - Mob Stunning Threshold %"
	var/airflow_stun_pressure_DESC = "Percent of 1 Atm. at which mobs will be stunned by airflow."

	var/airflow_stun_cooldown = 60
	var/airflow_stun_cooldown_NAME = "Aiflow Stunning - Cooldown"
	var/airflow_stun_cooldown_DESC = "How long, in tenths of a second, to wait before stunning them again."

	var/airflow_stun = 1
	var/airflow_stun_NAME = "Airflow Impact - Stunning"
	var/airflow_stun_DESC = "How much a mob is stunned when hit by an object."

	var/airflow_damage = 7
	var/airflow_damage_NAME = "Airflow Impact - Damage"
	var/airflow_damage_DESC = "Damage from airflow impacts."

	var/airflow_speed_decay = 1
	var/airflow_speed_decay_NAME = "Airflow Speed Decay"
	var/airflow_speed_decay_DESC = "How rapidly the speed gained from airflow decays."

	var/airflow_delay = 10
	var/airflow_delay_NAME = "Airflow Retrigger Delay"
	var/airflow_delay_DESC = "Time in deciseconds before things can be moved by airflow again."

	var/airflow_mob_slowdown = 1
	var/airflow_mob_slowdown_NAME = "Airflow Slowdown"
	var/airflow_mob_slowdown_DESC = "Time in tenths of a second to add as a delay to each movement by a mob if they are fighting the pull of the airflow."

	var/connection_insulation = 0
	var/connection_insulation_NAME = "Connections - Insulation"
	var/connection_insulation_DESC = "Boolean, should doors forbid heat transfer?"

	var/connection_temperature_delta = 10
	var/connection_temperature_delta_NAME = "Connections - Temperature Difference"
	var/connection_temperature_delta_DESC = "The smallest temperature difference which will cause heat to travel through doors."


/vs_control/var/list/settings = list()
/vs_control/var/list/bitflags = list("1","2","4","8","16","32","64","128","256","512","1024")
/vs_control/var/contaminant_control/contaminant_control = new()

/vs_control/New()
	. = ..()
	settings = vars.Copy()

	var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
	for(var/V in D.vars)
		settings -= V

	for(var/V in settings)
		if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC") || findtextEx(V,"_METHOD"))
			settings -= V

	settings -= "settings"
	settings -= "bitflags"
	settings -= "contaminant_control"

/vs_control/proc/ChangeSettingsDialog(mob/user,list/L)
	//var/which = input(user,"Choose a setting:") in L
	var/dat = ""
	for(var/ch in L)
		if(findtextEx(ch,"_RANDOM") || findtextEx(ch,"_DESC") || findtextEx(ch,"_METHOD") || findtextEx(ch,"_NAME")) continue
		var/vw
		var/vw_desc = "No Description."
		var/vw_name = ch
		if(ch in contaminant_control.settings)
			vw = contaminant_control.vars[ch]
			if("[ch]_DESC" in contaminant_control.vars) vw_desc = contaminant_control.vars["[ch]_DESC"]
			if("[ch]_NAME" in contaminant_control.vars) vw_name = contaminant_control.vars["[ch]_NAME"]
		else
			vw = vars[ch]
			if("[ch]_DESC" in vars) vw_desc = vars["[ch]_DESC"]
			if("[ch]_NAME" in vars) vw_name = vars["[ch]_NAME"]
		dat += "<b>[vw_name] = [vw]</b> <A href='?src=\ref[src];changevar=[ch]'>\[Change\]</A><br>"
		dat += "<i>[vw_desc]</i><br><br>"
	show_browser(user, dat, "window=settings")

/vs_control/Topic(href,href_list)
	if("changevar" in href_list)
		ChangeSetting(usr,href_list["changevar"])

/vs_control/proc/ChangeSetting(mob/user,ch)
	var/vw
	var/how = "Text"
	var/display_description = ch
	if(ch in contaminant_control.settings)
		vw = contaminant_control.vars[ch]
		if("[ch]_NAME" in contaminant_control.vars)
			display_description = contaminant_control.vars["[ch]_NAME"]
		if("[ch]_METHOD" in contaminant_control.vars)
			how = contaminant_control.vars["[ch]_METHOD"]
		else
			if(isnum(vw))
				how = "Numeric"
			else
				how = "Text"
	else
		vw = vars[ch]
		if("[ch]_NAME" in vars)
			display_description = vars["[ch]_NAME"]
		if("[ch]_METHOD" in vars)
			how = vars["[ch]_METHOD"]
		else
			if(isnum(vw))
				how = "Numeric"
			else
				how = "Text"
	var/newvar = vw
	switch(how)
		if("Numeric")
			newvar = input(user,"Enter a number:","Settings",newvar) as num
		if("Bit Flag")
			var/flag = input(user,"Toggle which bit?","Settings") in bitflags
			flag = text2num(flag)
			if(newvar & flag)
				newvar &= ~flag
			else
				newvar |= flag
		if("Toggle")
			newvar = !newvar
		if("Text")
			newvar = input(user,"Enter a string:","Settings",newvar) as text
		if("Long Text")
			newvar = input(user,"Enter text:","Settings",newvar) as message
	vw = newvar
	if(ch in contaminant_control.settings)
		contaminant_control.vars[ch] = vw
	else
		vars[ch] = vw
	if(how == "Toggle")
		newvar = (newvar?"ON":"OFF")
	to_world("<span class='notice'><b>[key_name(user)] changed the setting [display_description] to [newvar].</b></span>")
	if(ch in contaminant_control.settings)
		ChangeSettingsDialog(user,contaminant_control.settings)
	else
		ChangeSettingsDialog(user,settings)

/vs_control/proc/RandomizeWithProbability()
	for(var/V in settings)
		var/newvalue
		if("[V]_RANDOM" in vars)
			if(isnum(vars["[V]_RANDOM"]))
				newvalue = prob(vars["[V]_RANDOM"])
			else if(istext(vars["[V]_RANDOM"]))
				newvalue = roll(vars["[V]_RANDOM"])
			else
				newvalue = vars[V]
		V = newvalue

/vs_control/proc/SetDefault(var/mob/user)
	var/list/setting_choices = list("Contaminants - Standard", "Contaminants - Low Hazard", "Contaminants - High Hazard", "Contaminants - Oh Shit!",\
	"ZAS - Normal", "ZAS - Forgiving", "ZAS - Dangerous", "ZAS - Hellish", "ZAS/Contaminants - Initial")
	var/def = input(user, "Which of these presets should be used?") as null|anything in setting_choices
	if(!def)
		return
	switch(def)
		if("Contaminants - Standard")
			contaminant_control.CLOTH_CONTAMINATION = 1 //If this is on, contaminants do damage by getting into cloth.
			contaminant_control.STRICT_PROTECTION_ONLY = 0
			contaminant_control.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.
			contaminant_control.SKIN_BURNS = 0       //Contaminants have an effect similar to mustard gas on the un-suited.
			contaminant_control.EYE_BURNS = 1 //Contaminants burn the eyes of anyone not wearing eye protection.
			contaminant_control.CONTAMINANT_HALLUCINATION = 0
			contaminant_control.CONTAMINATION_LOSS = 0.02

		if("Contaminants - Low Hazard")
			contaminant_control.CLOTH_CONTAMINATION = 0 //If this is on, contaminants do damage by getting into cloth.
			contaminant_control.STRICT_PROTECTION_ONLY = 0
			contaminant_control.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000
			contaminant_control.SKIN_BURNS = 0       //Contaminants have an effect similar to mustard gas on the un-suited.
			contaminant_control.EYE_BURNS = 1 //Contaminants burn the eyes of anyone not wearing eye protection.
			contaminant_control.CONTAMINANT_HALLUCINATION = 0
			contaminant_control.CONTAMINATION_LOSS = 0.01

		if("Contaminants - High Hazard")
			contaminant_control.CLOTH_CONTAMINATION = 1 //If this is on, contaminants do damage by getting into cloth.
			contaminant_control.STRICT_PROTECTION_ONLY = 0
			contaminant_control.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.
			contaminant_control.SKIN_BURNS = 1       //Contaminants have an effect similar to mustard gas on the un-suited.
			contaminant_control.EYE_BURNS = 1 //Contaminants burn the eyes of anyone not wearing eye protection.
			contaminant_control.CONTAMINANT_HALLUCINATION = 1
			contaminant_control.CONTAMINATION_LOSS = 0.05

		if("Contaminants - Oh Shit!")
			contaminant_control.CLOTH_CONTAMINATION = 1 //If this is on, contaminants do damage by getting into cloth.
			contaminant_control.STRICT_PROTECTION_ONLY = 1
			contaminant_control.GENETIC_CORRUPTION = 5 //Chance of genetic corruption as well as toxic damage, X in 1000.
			contaminant_control.SKIN_BURNS = 1       //Contaminants have an effect similar to mustard gas on the un-suited.
			contaminant_control.EYE_BURNS = 1 //Contaminants burn the eyes of anyone not wearing eye protection.
			contaminant_control.CONTAMINANT_HALLUCINATION = 1
			contaminant_control.CONTAMINATION_LOSS = 0.075

		if("ZAS - Normal")
			airflow_lightest_pressure = 20
			airflow_light_pressure = 35
			airflow_medium_pressure = 50
			airflow_heavy_pressure = 65
			airflow_dense_pressure = 85
			airflow_stun_pressure = 60
			airflow_stun_cooldown = 60
			airflow_stun = 1
			airflow_damage = 3
			airflow_speed_decay = 1.5
			airflow_delay = 30
			airflow_mob_slowdown = 1

		if("ZAS - Forgiving")
			airflow_lightest_pressure = 45
			airflow_light_pressure = 60
			airflow_medium_pressure = 120
			airflow_heavy_pressure = 110
			airflow_dense_pressure = 200
			airflow_stun_pressure = 150
			airflow_stun_cooldown = 90
			airflow_stun = 0.15
			airflow_damage = 0.5
			airflow_speed_decay = 1.5
			airflow_delay = 50
			airflow_mob_slowdown = 0

		if("ZAS - Dangerous")
			airflow_lightest_pressure = 15
			airflow_light_pressure = 30
			airflow_medium_pressure = 45
			airflow_heavy_pressure = 55
			airflow_dense_pressure = 70
			airflow_stun_pressure = 50
			airflow_stun_cooldown = 50
			airflow_stun = 2
			airflow_damage = 4
			airflow_speed_decay = 1.2
			airflow_delay = 25
			airflow_mob_slowdown = 2

		if("ZAS - Hellish")
			airflow_lightest_pressure = 20
			airflow_light_pressure = 30
			airflow_medium_pressure = 40
			airflow_heavy_pressure = 50
			airflow_dense_pressure = 60
			airflow_stun_pressure = 40
			airflow_stun_cooldown = 40
			airflow_stun = 3
			airflow_damage = 5
			airflow_speed_decay = 1
			airflow_delay = 20
			airflow_mob_slowdown = 3
			connection_insulation = 0

		if("ZAS/Contaminants - Initial")
			fire_consuption_rate 			= initial(fire_consuption_rate)
			fire_firelevel_multiplier 		= initial(fire_firelevel_multiplier)
			IgnitionLevel 					= initial(IgnitionLevel)
			airflow_lightest_pressure 		= initial(airflow_lightest_pressure)
			airflow_light_pressure 			= initial(airflow_light_pressure)
			airflow_medium_pressure 		= initial(airflow_medium_pressure)
			airflow_heavy_pressure 			= initial(airflow_heavy_pressure)
			airflow_dense_pressure 			= initial(airflow_dense_pressure)
			airflow_stun_pressure 			= initial(airflow_stun_pressure)
			airflow_stun_cooldown 			= initial(airflow_stun_cooldown)
			airflow_stun 					= initial(airflow_stun)
			airflow_damage 					= initial(airflow_damage)
			airflow_speed_decay 			= initial(airflow_speed_decay)
			airflow_delay 					= initial(airflow_delay)
			airflow_mob_slowdown 			= initial(airflow_mob_slowdown)
			connection_insulation 			= initial(connection_insulation)
			connection_temperature_delta 	= initial(connection_temperature_delta)

			contaminant_control.CONTAMINANT_DMG 					= initial(contaminant_control.CONTAMINANT_DMG)
			contaminant_control.CLOTH_CONTAMINATION 		= initial(contaminant_control.CLOTH_CONTAMINATION)
			contaminant_control.STRICT_PROTECTION_ONLY 			= initial(contaminant_control.STRICT_PROTECTION_ONLY)
			contaminant_control.GENETIC_CORRUPTION 			= initial(contaminant_control.GENETIC_CORRUPTION)
			contaminant_control.SKIN_BURNS 					= initial(contaminant_control.SKIN_BURNS)
			contaminant_control.EYE_BURNS 					= initial(contaminant_control.EYE_BURNS)
			contaminant_control.CONTAMINATION_LOSS 			= initial(contaminant_control.CONTAMINATION_LOSS)
			contaminant_control.CONTAMINANT_HALLUCINATION 		= initial(contaminant_control.CONTAMINANT_HALLUCINATION)
			contaminant_control.N2O_HALLUCINATION 			= initial(contaminant_control.N2O_HALLUCINATION)


	to_world("<span class='notice'><b>[key_name(user)] changed the global contaminant/ZAS settings to \"[def]\"</b></span>")

/contaminant_control/var/list/settings = list()

/contaminant_control/New()
	. = ..()
	settings = vars.Copy()

	var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
	for(var/V in D.vars)
		settings -= V

	for(var/V in settings)
		if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC"))
			settings -= V

	settings -= "settings"

/contaminant_control/proc/Randomize(V)
	var/newvalue
	if("[V]_RANDOM" in vars)
		if(isnum(vars["[V]_RANDOM"]))
			newvalue = prob(vars["[V]_RANDOM"])
		else if(istext(vars["[V]_RANDOM"]))
			var/txt = vars["[V]_RANDOM"]
			if(findtextEx(txt,"PROB"))
				txt = splittext(txt,"/")
				txt[1] = replacetext(txt[1],"PROB","")
				var/p = text2num(txt[1])
				var/r = txt[2]
				if(prob(p))
					newvalue = roll(r)
				else
					newvalue = vars[V]
			else if(findtextEx(txt,"PICK"))
				txt = replacetext(txt,"PICK","")
				txt = splittext(txt,",")
				newvalue = pick(txt)
			else
				newvalue = roll(txt)
		else
			newvalue = vars[V]
		vars[V] = newvalue
