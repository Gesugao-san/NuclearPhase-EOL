/decl/aspect/perk
	aspect_flags = ASPECTS_PHYSICAL

/decl/aspect/perk/positive
	category = "Perks - Positive"
	aspect_cost = 1

/decl/aspect/perk/negative
	category = "Perks - Negative"
	aspect_cost = -1

/decl/aspect/perk/neutral
	category = "Perks - Neutral"
	aspect_cost = 0


/decl/aspect/perk/negative/heliophobia
	name = "Heliophobia"
	desc = "You fear light."

/decl/aspect/perk/neutral/astraphobia
	name = "Astraphobia"
	desc = "You fear bad weather. And space."

/decl/aspect/perk/neutral/astraphobia/apply(mob/living/carbon/human/holder)
	. = ..()
	holder.add_mood(/datum/mood/astraphobia)

/decl/aspect/perk/negative/gourmand
	name = "Gourmand"
	desc = "You love food. You crave food. Food."

/decl/aspect/perk/negative/hydro_homie
	name = "Hydro Homie"
	desc = "You can't live without water."

/decl/aspect/perk/positive/believer
	name = "Believer"
	desc = "Your prayers are more likely to be answered. Holy water heals you a little."
	aspect_cost = 2

/decl/aspect/perk/negative/asthmatic
	name = "Asthmatic"
	desc = "Your lungs are weak. You ocasionally have asthmatic attacks."
	aspect_cost = -3

/decl/aspect/perk/negative/smoke_intolerance
	name = "Smoke Intolerance"
	desc = "You absolutely hate when people smoke."
	aspect_cost = -2

/decl/aspect/perk/negative/addiction
	name = "Random Addiction"
	desc = "You are addicted to something."

/decl/aspect/perk/negative/addiction/nicotine
	name = "Nicotine Addiction"
	desc = "You are addicted to nicotine."

/decl/aspect/perk/negative/addiction/caffeine
	name = "Caffeine Addiction"
	desc = "You are addicted to caffeine."

/decl/aspect/perk/negative/addiction/opioid
	name = "Opioid Addiction"
	desc = "You are addicted to opioids."
	aspect_cost = -2

/decl/aspect/perk/neutral/engineer_master
	name = "Master Engineer"
	desc = "You are very vocal about your skill with machinery."

/decl/aspect/perk/negative/heart_problem
	name = "Weak Heart"
	desc = "Your heart is weak."
	aspect_cost = -2

/decl/aspect/perk/negative/heart_problem/apply(mob/living/carbon/human/holder)
	. = ..()
	var/obj/item/organ/internal/heart/cur_heart = GET_INTERNAL_ORGAN(holder, BP_HEART)
	cur_heart.damage = cur_heart.max_damage * 0.1

/decl/aspect/perk/negative/heart_failure
	name = "Heart Failure"
	desc = "Your heart is barely functioning. You might need a transplant or intense treatment. You carry Amiodarone pills with you at all times."
	aspect_cost = -5

/decl/aspect/perk/negative/heart_failure/apply(mob/living/carbon/human/holder)
	. = ..()
	var/obj/item/organ/internal/heart/cur_heart = GET_INTERNAL_ORGAN(holder, BP_HEART)
	cur_heart.damage = cur_heart.max_damage * 0.3

/decl/aspect/perk/negative/kidney_failure
	name = "Kidney Failure"
	desc = "Your kidneys are nonfunctional. You need periodic dialysis(every 2 hours) and are more susceptible to toxins."
	aspect_cost = -5

/decl/aspect/perk/negative/kidney_failure/apply(mob/living/carbon/human/holder)
	. = ..()
	var/obj/item/organ/internal/kidneys = GET_INTERNAL_ORGAN(holder, BP_KIDNEYS)
	kidneys.die()

/decl/aspect/perk/negative/srec_infection
	name = "SREC Infection"
	desc = "An infection by Self-Replicating Electrotrophic Crystals. \
			These silicon-like crystals use electricity for metabolism. The disease progression to the lethal stage may take dozens of years, \
			but any electrical shocks strongly exacerbate it. Your infection is benign and relatively harmless(<80mcg/ml)."
	incompatible_with = list(/decl/aspect/perk/negative/srec_infection/medium)
	aspect_cost = -3

/decl/aspect/perk/negative/srec_infection/apply(mob/living/carbon/human/holder)
	. = ..()
	holder.srec_dose = rand(40, 80)

/decl/aspect/perk/negative/srec_infection/medium
	name = "Developed SREC Infection"
	desc = "An infection by Self-Replicating Electrotrophic Crystals. \
			These silicon-like crystals use electricity for metabolism. Your infection has already developed symptoms, a few electric shocks \
			will likely put an end to you."
	incompatible_with = list(/decl/aspect/perk/negative/srec_infection)
	aspect_cost = -8
	var/list/organ_damage_weights = list(
		BP_LIVER =   60,
		BP_BRAIN =   50,
		BP_EYES =    40,
		BP_KIDNEYS = 30
	)

/decl/aspect/perk/negative/srec_infection/medium/apply(mob/living/carbon/human/holder)
	. = ..()
	holder.srec_dose = rand(120, 160)
	for(var/i=1;i<=3;i++)
		var/obj/item/organ/internal/I = GET_INTERNAL_ORGAN(holder, pickweight(organ_damage_weights))
		I.damage += I.max_damage * 0.1