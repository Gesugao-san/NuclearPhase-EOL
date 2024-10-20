/proc/get_analysis_header(patient_name, patient_age, patient_gender, performer_name, analysis_name)
	var/responsible_individual_name = "Sarah Jefferson" // the name of current lab director
	var/text = "\
	<h1><b>WEHS <font color=\"blue\">DIAGNOSTICS LAB</font></b></h1>\
      <h2>Worlds Established Healthcare System</h2>\
      <small>WEHS Headquarters, HW31, New Tokyo, 3rd sector</small><br>\
      <hr><br>\
      <table>\
        <tr><td><b>[patient_name]</b></td><td>|</td><td><b>Performed At:</b></td><td>|</td><td><b>Performed On:</b> [worldtime2stationtime(world.time)]</td></tr>\
        <tr><td>Age: [patient_age] Years</td><td>|</td><td>ESS \"Serenity\", HW37, 3rd sector</td></bd><td>|</td></tr>\
        <tr><td>Sex: [patient_gender]</td><td>|</td><td><b>Performed By:</b> [performer_name]</td><td>|</td></tr>\
        <tr><td>Patient ID: 1111</td><td>|</td><td>Ref. By:<b> [responsible_individual_name]</b></td><td>|</td></tr>\
      </table>\
      <hr>\
      <h2>[analysis_name]</h2>\
      <hr>"
	return text

/proc/get_blood_analysis_row()
	return "<tr><td width=\"200\">Name</td><td width=\"50\">Value</td><td width=\"50\" >Unit</td><td width=\"70\">Normal Values</td></tr>"

/proc/get_blood_analysis_line(name, value, unit, normal_values)
	return "<tr><td>[name]</td><td>[value]</td><td>[unit]</td><td>[normal_values]</td></tr>"

/decl/blood_analysis
	var/name
	var/description
	var/time = 5 SECONDS

/decl/blood_analysis/proc/return_analysis(mob/living/carbon/human/H, blood_data)
	return ""

/decl/blood_analysis/biochemistry
	name = "Full Biochemical Blood Test"

/decl/blood_analysis/biochemistry/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/value_table = list()
	var/list/chem_data = blood_data["trace_chem"]

	var/patient_name = "UNKNOWN"
	var/patient_age = "UNKNOWN"
	var/patient_gender = "UNKNOWN"
	var/performer_name = "UNKNOWN"
	var/weakref/W = blood_data["donor"]
	var/mob/living/carbon/human/donor = W.resolve()
	if(donor)
		patient_name = donor.real_name
		patient_age = donor.get_age()
		patient_gender = capitalize(donor.gender)

	var/obj/item/organ/internal/heart/heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	var/obj/item/organ/internal/liver/liver = GET_INTERNAL_ORGAN(H, BP_LIVER)
	var/obj/item/organ/internal/kidneys/kidneys = GET_INTERNAL_ORGAN(H, BP_KIDNEYS)
	value_table += get_blood_analysis_line("Erythrocytes", round((rand(444, 500)*0.01)*H.get_blood_volume_hemo(), 0.01), "10*12/l", "4.44-5.61")
	value_table += get_blood_analysis_line("Potassium", round(0.3 + chem_data[/decl/material/solid/potassium], 0.1), "mg/ml", "1-3")
	value_table += get_blood_analysis_line("Proteins", round(rand(90, 110)*0.1, 0.1), "mcg/ml", "9-11")
	value_table += get_blood_analysis_line("pH", round(rand(735, 745) * 0.01, 0.01), "", "7.35-7.45")
	value_table += get_blood_analysis_line("Hematocrit", round(rand(400, 494) * 0.1, 0.01), "%", "40.0-49.4")
	value_table += get_blood_analysis_line("Troponin-T", rand(0, 5)*0.01 + round(heart.damage * 0.3, 0.01), "mcg/ml", "0-0.04")
	value_table += get_blood_analysis_line("Bilirubin", rand(171, 205)*0.01 + round(liver.damage * 0.6, 0.01), "mcg/ml", "1.71-20.5")
	value_table += get_blood_analysis_line("ACR", rand(0, 29) + round(kidneys.damage * 1.3, 0.01), "mcg/ml", "0-33")
	value_table += get_blood_analysis_line("Lymphocytes", round((rand(17, 25)*0.001)*H.immunity, 0.01), "10*9/l", "0.85-3.00")
	value_table += get_blood_analysis_line("SREC", round(H.srec_dose, 0.01), "mcg/ml", "0-40.0")

	var/joined_table = jointext(list(get_analysis_header(patient_name, patient_age, patient_gender, performer_name, name), "<table>", get_blood_analysis_row(), jointext(value_table, ""), "<\table>"), "")
	return joined_table

/decl/blood_analysis/blood
	name = "Blood Type Analysis"

/decl/blood_analysis/blood/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/text = ""
	//var/list/chem_data = blood_data["trace_chem"]
	text += "<center><b>Analysis #[rand(1, 999)]</b></center><br>"
	text += "<center><i>Blood Type Analysis</i></center><br>"
	text += "Blood Type: [blood_data["blood_type"]]<br>"
	text += "DNA String: [blood_data["blood_DNA"]]<br>"
	return jointext(text, "<br>")

/obj/machinery/blood_analysis
	name = "blood analyser"
	desc = "Analyzes centrifuged blood. Needs a vial in it to work."
	icon = 'icons/obj/machines/blood_analyzer.dmi'
	icon_state = "idle"
	idle_power_usage = 50
	active_power_usage = 2100
	core_skill = SKILL_MEDICAL
	var/obj/item/chems/glass/beaker/vial/inserted_vial
	var/running = FALSE

/obj/machinery/blood_analysis/on_update_icon()
	if(running)
		icon_state = "running"
		return
	else
		icon_state = "idle"

/obj/machinery/blood_analysis/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/chems/glass/beaker/vial))
		if(inserted_vial)
			return
		inserted_vial = I
		user.drop_from_inventory(I, src)
		visible_message(SPAN_NOTICE("[user] inserts a vial into the blood analyzer."))
		return
	. = ..()

/obj/machinery/blood_analysis/proc/start(decl/blood_analysis/chosen_analysis)
	running = TRUE
	update_icon()
	spawn((35 - REAGENT_VOLUME(inserted_vial.reagents, /decl/material/liquid/separated_blood)) SECONDS)
		visible_message(SPAN_NOTICE("The blood analyzer finishes running."))
		running = FALSE
		var/list/blood_data = inserted_vial.reagents.reagent_data[/decl/material/liquid/separated_blood]
		var/weakref/W = LAZYACCESS(blood_data, "donor")
		if(!W)
			return
		var/mob/living/carbon/human/H = W.resolve()
		new /obj/item/paper(get_turf(src), chosen_analysis.return_analysis(H, blood_data), "Analysis Results for [H.real_name]")
		inserted_vial.reagents.remove_any(inserted_vial.reagents.maximum_volume)
		update_icon()

/obj/machinery/blood_analysis/physical_attack_hand(user)
	. = ..()
	try_handle_interactions(user, get_alt_interactions(user))

/obj/machinery/blood_analysis/get_alt_interactions(mob/user)
	. = ..()
	LAZYADD(., /decl/interaction_handler/blood_analysis_remove_vial)
	if(!running)
		LAZYADD(., /decl/interaction_handler/blood_analysis_start)

/decl/interaction_handler/blood_analysis_start
	name = "Start"
	expected_target_type = /obj/machinery/blood_analysis

/decl/interaction_handler/blood_analysis_start/invoked(obj/machinery/blood_analysis/target, mob/user)
	if(!do_after(user, 5, target))
		return
	if(!target.powered(EQUIP))
		return
	if(!target.inserted_vial.reagents.total_volume)
		return
	var/list/possible_analysis_decls = list()
	for(var/cur_analysis in subtypesof(/decl/blood_analysis))
		var/decl/blood_analysis/actual_decl = GET_DECL(cur_analysis)
		possible_analysis_decls["[actual_decl.name]"] = actual_decl
	var/choice = input(user, "Choose an analysis to perform.", "Analysis choice") as null|anything in possible_analysis_decls
	var/chosen_one = possible_analysis_decls[choice]
	if(!chosen_one)
		return
	target.start(chosen_one)
	target.visible_message(SPAN_NOTICE("[user] turns on the blood analyzer."))

/decl/interaction_handler/blood_analysis_remove_vial
	name = "Remove a Vial"
	expected_target_type = /obj/machinery/blood_analysis

/decl/interaction_handler/blood_analysis_remove_vial/invoked(obj/machinery/blood_analysis/target, mob/user)
	if(!target.inserted_vial)
		to_chat(user, SPAN_NOTICE("There are no vial in the blood analyzer."))
		return
	if(target.running)
		return
	var/obj/item/chems/glass/beaker/vial/cur_vial = target.inserted_vial
	user.put_in_hands(cur_vial)
	target.inserted_vial = null
	target.visible_message(SPAN_NOTICE("[user] removes a vial from the blood analyzer."))



/decl/scanner_analysis
	var/name
	var/description
	var/time = 3 SECONDS
	abstract_type = /decl/scanner_analysis

/decl/scanner_analysis/proc/after_analysis(obj/machinery/M) //for sounds, etc
	return

//should return a fail message if not
/decl/scanner_analysis/proc/can_conduct(mob/living/carbon/human/H)
	return TRUE

/decl/scanner_analysis/proc/return_analysis(mob/living/carbon/human/H)
	var/can_conduct = can_conduct()
	if(can_conduct != TRUE)
		return can_conduct //returns the fail message
	else
		return TRUE


/decl/scanner_analysis/ultrasound
	abstract_type = /decl/scanner_analysis/ultrasound

/decl/scanner_analysis/ultrasound/proc/check_clothing()
	return TRUE

/decl/scanner_analysis/ultrasound/can_conduct(mob/living/carbon/human/H)
	if(!check_clothing())
		return "Scanned body parts are obstructed by clothing."
	return TRUE

/decl/scanner_analysis/ultrasound/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/resulting_data = list()

	if(H.get_blood_perfusion() < 0.9)
		if(H.get_blood_perfusion() < 0.7)
			resulting_data += "Tissue perfusion is extremely poor.<br>"
		else
			resulting_data += "Tissue perfusion is slightly reduced.<br>"

	if(H.get_blood_oxygenation() < 0.7)
		resulting_data += "Tissue is starved of oxygen.<br>"

	return jointext(resulting_data, "<br>")

/decl/scanner_analysis/ultrasound/fast
	name = "EFAST Ultrasound"
	description = "A generic ultrasound scan for assessing trauma."

/decl/scanner_analysis/ultrasound/fast/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/resulting_data = list()

	if(H.systemic_oxygen_saturation < 0.9)
		if(H.systemic_oxygen_saturation < 0.7)
			resulting_data += "Tissue perfusion is extremely poor.<br>"
		else
			resulting_data += "Tissue perfusion is slightly reduced.<br>"
	else
		resulting_data += "Tissue perfusion is normal.<br>"

	if(H.get_blood_oxygenation() < 0.7)
		resulting_data += "Tissue is starved of oxygen.<br>"

	var/obj/item/organ/internal/lungs/L = GET_INTERNAL_ORGAN(H, BP_LUNGS)
	if(L && L.ruptured)
		resulting_data += "Traumatic pneumothorax.<br>"
	else
		resulting_data += "No pneumothorax.<br>"

	resulting_data += "<hr>"

	for(var/obj/item/organ/internal/I in H.get_internal_organs())
		resulting_data += "<b>[I.name]</b><br>[I.scan(FALSE)]<br>"

	resulting_data += "<hr>"

	for(var/obj/item/organ/external/E in H.get_external_organs())
		if(E.status & ORGAN_ARTERY_CUT)
			resulting_data += "[capitalize(E.artery_name)] bleeding in \the [E.name].<br>"

	resulting_data += "<hr>"
	if(H.srec_dose > 80)
		switch(H.srec_dose)
			if(80 to 140)
				resulting_data += "SREC infection present.<br>"
			if(140 to 200)
				resulting_data += "Developed SREC infection present.<br>"
			if(200 to INFINITY)
				resulting_data += "Major SREC infection clusters present!<br>"
	else
		resulting_data += "No visible SREC infection detected.<br>"

	var/joined_table = jointext(list(get_analysis_header(H.real_name, H.get_age(), capitalize(H.gender), "UNKNOWN", name), jointext(resulting_data, "")), "")
	return joined_table

/decl/scanner_analysis/ultrasound/organ
	name = "Organ Ultrasound"
	description = "An ultrasound scan for diagnosing organ issues."
	time = 10 SECONDS

/decl/scanner_analysis/ultrasound/organ/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/resulting_data = list()

	var/obj/item/organ/internal/lungs/L = GET_INTERNAL_ORGAN(H, BP_LUNGS)
	if(L && L.ruptured)
		resulting_data += "Traumatic pneumothorax.<br>"
	else
		resulting_data += "No pneumothorax.<br>"
	var/obj/item/organ/internal/heart/our_heart = GET_INTERNAL_ORGAN(H, BP_HEART)
	if(our_heart)
		resulting_data += "Heart Stroke Volume: [round(H.get_stroke_volume())]ml CO:([round(our_heart.cardiac_output * 100)]%)"
	var/obj/item/organ/internal/appendix/our_appendix = GET_INTERNAL_ORGAN(H, BP_APPENDIX)
	if(our_appendix)
		switch(our_appendix.inflamed)
			if(1 to 200)
				resulting_data += "Inflammatory appendicitis.<br>"
			if(200 to 600)
				resulting_data += "Acute appendicitis.<br>"
			if(600 to INFINITY)
				resulting_data += "Gangrenous appendicitis.<br>"

	resulting_data += "<hr>"

	if(H.srec_dose > 20)
		resulting_data += "SREC infection present.<br>"
		resulting_data += "Estimate Dose: [round(H.srec_dose + rand(-10, 10))] mcg/ml.<br>"
	else
		resulting_data += "No SREC infection detected.<br>"

	resulting_data += "<hr>"

	for(var/obj/item/organ/internal/I in H.get_internal_organs())
		resulting_data += "<b>[I.name]</b><br>[I.scan(TRUE)]<br>"

	resulting_data += "<hr>"

	for(var/obj/item/organ/external/E in H.get_external_organs())
		if(E.status & ORGAN_ARTERY_CUT)
			resulting_data += "[capitalize(E.artery_name)] bleeding in \the [E.name].<br>"

	var/joined_table = jointext(list(get_analysis_header(H.real_name, H.get_age(), capitalize(H.gender), "UNKNOWN", name), jointext(resulting_data, "")), "")
	return joined_table

/decl/scanner_analysis/xray
	name = "XRay"
	description = "A general XRay scan"

/decl/scanner_analysis/xray/after_analysis(obj/machinery/M)
	playsound(M, 'sound/machines/xray_scan.mp3', 60, 0)

/decl/scanner_analysis/xray/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/resulting_data = list()

	var/obj/item/organ/internal/lungs/L = GET_INTERNAL_ORGAN(H, BP_LUNGS)
	if(L && L.ruptured)
		resulting_data += "Traumatic pneumothorax.<br>"
	else
		resulting_data += "No pneumothorax.<br>"

	resulting_data += "<br>"

	for(var/obj/item/organ/external/E in H.get_external_organs())
		if(E.status & ORGAN_BROKEN)
			resulting_data += "Fracture in \the [E.name].<br>"
		if(E.status & ORGAN_DISLOCATED)
			resulting_data += "Dislocation in \the [E.name].<br>"
		if(E.status & ORGAN_TENDON_CUT)
			resulting_data += "Cut tendon in \the [E.name].<br>"

	var/joined_table = jointext(list(get_analysis_header(H.real_name, H.get_age(), capitalize(H.gender), "UNKNOWN", name), jointext(resulting_data, "")), "")
	return joined_table

/decl/scanner_analysis/radiation
	name = "Radiation Screening"

/decl/scanner_analysis/radiation/proc/check_clothing()
	return TRUE

/decl/scanner_analysis/radiation/return_analysis(mob/living/carbon/human/H, blood_data)
	var/list/resulting_data = list()

	resulting_data += "Estimated radiation dose: [round(H.radiation)]mSv.<br>"

	var/joined_table = jointext(list(get_analysis_header(H.real_name, H.get_age(), capitalize(H.gender), "UNKNOWN", name), jointext(resulting_data, "")), "")
	return joined_table