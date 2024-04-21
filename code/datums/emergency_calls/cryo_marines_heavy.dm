
/*
 *   Heavy DEFCON ERT (with full equipment)
 */

/datum/emergency_call/cryo_squad_equipped
	name = "Marine Cryo Reinforcements (Full Equipment) (Squad)"
	mob_max = 15
	mob_min = 1
	probability = 0
	objectives = "Assist the USCM forces"
	max_heavies = 4
	max_medics = 2
	name_of_spawn = /obj/effect/landmark/ert_spawns/distress_cryo
	shuttle_id = ""

	var/leaders = 0

/datum/emergency_call/cryo_squad_equipped/spawn_candidates(announce, override_spawn_loc, announce_dispatch_message)
	var/datum/squad/marine/cryo/cryo_squad = SSticker.role_authority.squads_by_type[/datum/squad/marine/cryo]
	leaders = cryo_squad.num_leaders
	. = ..()
	if(length(members))
		shipwide_ai_announcement("Successfully deployed [length(members)] Foxtrot marines.")

/datum/emergency_call/cryo_squad_equipped/create_member(datum/mind/mind, turf/override_spawn_loc)
	set waitfor = FALSE
	if(SSmapping.configs[GROUND_MAP].map_name == MAP_WHISKEY_OUTPOST)
		name_of_spawn = /obj/effect/landmark/ert_spawns/distress_wo
	var/turf/spawn_loc = override_spawn_loc ? override_spawn_loc : get_spawn_point()

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/new_human = new(spawn_loc)
	mind.transfer_to(new_human, TRUE)
	GLOB.ert_mobs += new_human

	sleep(5)
	var/datum/squad/marine/cryo/cryo_squad = SSticker.role_authority.squads_by_type[/datum/squad/marine/cryo]
	if(leaders < cryo_squad.max_leaders && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_LEADER) && check_timelock(new_human.client, JOB_SQUAD_LEADER, time_required_for_job))
		leader = new_human
		leaders++
		arm_equipment(new_human, /datum/equipment_preset/uscm/leader_equipped/cryo, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Squad Leader in the USCM"))
		to_chat(new_human, SPAN_ROLE_BODY("Your squad is here to assist in the defence of the [SSmapping.configs[GROUND_MAP].map_name]."))
	else if (heavies < max_heavies && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_HEAVY) && check_timelock(new_human.client, JOB_SQUAD_SPECIALIST, time_required_for_job))
		heavies++
		arm_equipment(new_human, /datum/equipment_preset/uscm/specialist_equipped/cryo, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Weapons Specialist in the USCM"))
		to_chat(new_human, SPAN_ROLE_BODY("Your squad is here to assist in the defence of the [SSmapping.configs[GROUND_MAP].map_name]."))
	else if(smartgunners < max_smartgunners && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_SMARTGUNNER) && check_timelock(new_human.client, JOB_SQUAD_SMARTGUN, time_required_for_job))
		smartgunners++
		arm_equipment(new_human, /datum/equipment_preset/uscm/smartgunner_equipped/cryo, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Smartgunner in the USCM"))
		to_chat(new_human, SPAN_ROLE_BODY("Your squad is here to assist in the defence of the [SSmapping.configs[GROUND_MAP].map_name]."))
	else if(engineers < max_engineers && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_ENGINEER) && check_timelock(new_human.client, JOB_SQUAD_ENGI, time_required_for_job))
		engineers++
		arm_equipment(new_human, /datum/equipment_preset/uscm/engineer_equipped/cryo, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are an Engineer in the USCM"))
		to_chat(new_human, SPAN_ROLE_BODY("Your squad is here to assist in the defence of the [SSmapping.configs[GROUND_MAP].map_name]."))
	else if (medics < max_medics && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_MEDIC) && check_timelock(new_human.client, JOB_SQUAD_MEDIC, time_required_for_job))
		medics++
		arm_equipment(new_human, /datum/equipment_preset/uscm/medic_equipped/cryo, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Hospital Corpsman in the USCM"))
		to_chat(new_human, SPAN_ROLE_BODY("Your squad is here to assist in the defence of the [SSmapping.configs[GROUND_MAP].map_name]."))
	else
		arm_equipment(new_human, /datum/equipment_preset/uscm/private_equipped/cryo, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Rifleman in the USCM"))
		to_chat(new_human, SPAN_ROLE_BODY("Your squad is here to assist in the defence of the [SSmapping.configs[GROUND_MAP].map_name]."))

	sleep(10)
	to_chat(new_human, SPAN_BOLD("Objectives: [objectives]"))


/datum/emergency_call/cryo_squad_equipped/platoon
	name = "Marine Cryo Reinforcements (Full Equipment) (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
	max_heavies = 8
