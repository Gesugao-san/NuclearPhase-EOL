/datum/job/site_operations
	abstract_type = /datum/job/site_operations
	department_types = list(/decl/department/site_operations)
	total_positions = 1
	spawn_positions = 1
	supervisors = "administration"
	selection_color = "#86263e"
	guestbanned = 1
	allowed_branches = list(
		/datum/mil_branch/civ
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
		)
	min_skill = list(
		SKILL_LITERACY    = SKILL_ADEPT
	)
	skill_points = 34

/datum/job/site_operations/faid
	title = "Facility AI Director"
	head_position = 1
	supervisors = "the Chief Operations Officer and Chief Security Officer"
	selection_color = "#a52041"
	outfit_type = /decl/hierarchy/outfit/job/faid
	skill_points = 38
	required_whitelists = list(/decl/whitelist/security_management, /decl/whitelist/engineering_low)

/datum/job/site_operations/ca
	title = "Chief Architect"
	head_position = 1
	supervisors = "the Chief Operations Officer and Reactor Operations Director"
	selection_color = "#a52041"
	outfit_type = /decl/hierarchy/outfit/job/engineering/chief_engineer
	skill_points = 35

/datum/job/site_operations/ss
	title = "Safety Supervisor"
	head_position = 1
	supervisors = "the Chief Operations Officer"
	selection_color = "#a52041"
	outfit_type = /decl/hierarchy/outfit/job/sdd
	skill_points = 35
	min_skill = list(
		SKILL_LITERACY = SKILL_ADEPT,
		SKILL_CONSTRUCTION = SKILL_BASIC,
	)
	required_whitelists = list(/decl/whitelist/command_executive)

/datum/job/site_operations/sme
	title = "Site Maintenance Engineer"
	total_positions = 10
	spawn_positions = 10
	supervisors = "the Chief Architect, Laboratory Operations Director and Reactor Maintenance Director"
	outfit_type = /decl/hierarchy/outfit/job/engineering/engineer
	access = list(
		access_eva,
		access_tech_storage,
		access_maint_tunnels,
		access_external_airlocks,
		access_construction,
		access_emergency_storage
	)
	minimal_access = list(
		access_eva,
		access_tech_storage,
		access_maint_tunnels,
		access_external_airlocks,
		access_construction,
		access_emergency_storage
	)
	skill_points = 35
	min_skill = list(
		SKILL_LITERACY = SKILL_ADEPT,
		SKILL_CONSTRUCTION = SKILL_ADEPT,
		SKILL_DEVICES = SKILL_ADEPT,
		SKILL_FITNESS  = SKILL_BASIC,
	    SKILL_STRENGTH = SKILL_BASIC,
		SKILL_ELECTRICAL = SKILL_BASIC,
		SKILL_ATMOS = SKILL_BASIC
	)

/datum/job/site_operations/janitor
	title = "Sanitation Specialist"
	total_positions = 2
	spawn_positions = 2
	access = list(
		access_janitor,
		access_maint_tunnels,
		access_engine,
		access_research,
		access_sec_doors,
		access_medical
	)
	minimal_access = list(
		access_janitor,
		access_maint_tunnels,
		access_engine,
		access_research,
		access_sec_doors,
		access_medical
	)
	alt_titles = list(
		"Custodian",
		"Janitor",
		"Sanitation Technician"
	)
	outfit_type = /decl/hierarchy/outfit/job/service/janitor
	allowed_branches = list(
		/datum/mil_branch/civ
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
		)
	min_skill = list(
		SKILL_LITERACY = SKILL_ADEPT
	)
	event_categories = list(ASSIGNMENT_JANITOR)
	skill_points = 22
	only_for_whitelisted = FALSE

/datum/job/site_operations/chef
	title = "Provision Specialist"
	total_positions = 2
	spawn_positions = 2
	access = list(
		access_hydroponics,
		access_bar,
		access_kitchen
	)
	minimal_access = list(access_kitchen)
	alt_titles = list("Cook")
	outfit_type = /decl/hierarchy/outfit/job/service/chef
	allowed_branches = list(
		/datum/mil_branch/civ
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
		)
	min_skill = list(
		SKILL_LITERACY  = SKILL_ADEPT,
		SKILL_COOKING   = SKILL_ADEPT,
	    SKILL_BOTANY    = SKILL_BASIC,
	    SKILL_CHEMISTRY = SKILL_BASIC
	)
	skill_points = 27

/datum/job/site_operations/logistician
	title = "Logistics Officer"
	total_positions = 3
	spawn_positions = 3
	access = list(
		access_cargo
	)
	alt_titles = list("Logistician", "Logistics Specialist", "Logistics Coordinator")
	outfit_type = /decl/hierarchy/outfit/job/service/chef
	allowed_branches = list(
		/datum/mil_branch/civ
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
		)
	min_skill = list(
		SKILL_LITERACY  = SKILL_ADEPT,
		SKILL_FINANCE   = SKILL_ADEPT,
	    SKILL_STRENGTH = SKILL_BASIC,
		SKILL_FITNESS = SKILL_BASIC,
		SKILL_DEVICES = SKILL_BASIC
	)
	skill_points = 27