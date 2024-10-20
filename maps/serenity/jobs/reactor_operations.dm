/datum/job/reactor_operations
	abstract_type = /datum/job/reactor_operations
	department_types = list(/decl/department/reactor_operations)
	total_positions = 1
	spawn_positions = 1
	supervisors = "administration"
	selection_color = "#adaf14"
	guestbanned = 1
	allowed_branches = list(
		/datum/mil_branch/civ
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
		)
	min_skill = list(
		SKILL_LITERACY    = SKILL_ADEPT,
		SKILL_CONSTRUCTION = SKILL_ADEPT,
		SKILL_ELECTRICAL = SKILL_ADEPT,
		SKILL_ATMOS = SKILL_ADEPT,
		SKILL_DEVICES = SKILL_ADEPT,
		SKILL_ENGINES = SKILL_ADEPT,
		SKILL_FITNESS  = SKILL_BASIC,
	    SKILL_STRENGTH = SKILL_BASIC
	)
	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MAX,
	    SKILL_ELECTRICAL   = SKILL_MAX,
	    SKILL_ATMOS        = SKILL_MAX,
	    SKILL_ENGINES      = SKILL_MAX,
		SKILL_COMPUTER  = SKILL_MAX,
		SKILL_DEVICES  = SKILL_MAX
	)
	skill_points = 34
	access = list(
		access_eva,
		access_engine,
		access_engine_equip,
		access_tech_storage,
		access_maint_tunnels,
		access_external_airlocks,
		access_construction,
		access_atmospherics,
		access_emergency_storage
	)
	minimal_access = list(
		access_eva,
		access_engine,
		access_engine_equip,
		access_tech_storage,
		access_maint_tunnels,
		access_external_airlocks,
		access_construction,
		access_atmospherics,
		access_emergency_storage
	)

/datum/job/reactor_operations/rod
	title = "Reactor Operations Director"
	head_position = 1
	supervisors = "the CEO"
	selection_color = "#d5d82d"
	outfit_type = /decl/hierarchy/outfit/job/rod
	access = list(
		access_engine,
		access_engine_equip,
		access_tech_storage,
		access_maint_tunnels,
		access_heads,
		access_teleporter,
		access_external_airlocks,
		access_atmospherics,
		access_emergency_storage,
		access_eva,
		access_bridge,
		access_construction,
		access_sec_doors,
		access_ce,
		access_RC_announce,
		access_keycard_auth,
		access_tcomsat,
		access_ai_upload
	)
	minimal_access = list(
		access_engine,
		access_engine_equip,
		access_tech_storage,
		access_maint_tunnels,
		access_heads,
		access_teleporter,
		access_external_airlocks,
		access_atmospherics,
		access_emergency_storage,
		access_eva,
		access_bridge,
		access_construction,
		access_sec_doors,
		access_ce,
		access_RC_announce,
		access_keycard_auth,
		access_tcomsat,
		access_ai_upload
	)
	skill_points = 43
	required_whitelists = list(/decl/whitelist/command_executive, /decl/whitelist/engineering_high)

/datum/job/reactor_operations/road
	title = "Reactor Operations Assistant Director"
	head_position = 1
	supervisors = "the Reactor Operations Director"
	selection_color = "#d5d82d"
	outfit_type = /decl/hierarchy/outfit/job/rod/assistant
	access = list(
		access_engine,
		access_engine_equip,
		access_tech_storage,
		access_maint_tunnels,
		access_heads,
		access_teleporter,
		access_external_airlocks,
		access_atmospherics,
		access_emergency_storage,
		access_eva,
		access_bridge,
		access_construction,
		access_sec_doors,
		access_ce,
		access_RC_announce,
		access_keycard_auth,
		access_tcomsat,
		access_ai_upload
	)
	minimal_access = list(
		access_engine,
		access_engine_equip,
		access_tech_storage,
		access_maint_tunnels,
		access_heads,
		access_teleporter,
		access_external_airlocks,
		access_atmospherics,
		access_emergency_storage,
		access_eva,
		access_bridge,
		access_construction,
		access_sec_doors,
		access_ce,
		access_RC_announce,
		access_keycard_auth,
		access_tcomsat,
		access_ai_upload
	)
	skill_points = 40
	required_whitelists = list(/decl/whitelist/engineering_high)

/datum/job/reactor_operations/rce
	title = "Reactor Chief Engineer"
	head_position = 1
	supervisors = "the Reactor Operations Director or their assistant"
	selection_color = "#c8ca2a"
	outfit_type = /decl/hierarchy/outfit/job/engineering/chief_engineer
	skill_points = 43
	required_whitelists = list(/decl/whitelist/engineering_high)

/datum/job/reactor_operations/rmd
	title = "Reactor Maintenance Director"
	head_position = 1
	supervisors = "the Reactor Operations Director or their assistant"
	selection_color = "#c8ca2a"
	outfit_type = /decl/hierarchy/outfit/job/engineering/rmd
	skill_points = 40
	required_whitelists = list(/decl/whitelist/engineering_low)

/datum/job/reactor_operations/ros
	title = "Reactor Operations Specialist"
	total_positions = 10
	spawn_positions = 10
	supervisors = "the Reactor Chief Engineer"
	outfit_type = /decl/hierarchy/outfit/job/engineering/ros
	skill_points = 38
	required_whitelists = list(/decl/whitelist/engineering_low)