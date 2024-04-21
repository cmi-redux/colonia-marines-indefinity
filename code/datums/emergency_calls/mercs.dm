


//Randomly-equipped mercenaries. May be friendly or hostile to the USCM, hostile to xenos.
/datum/emergency_call/mercs
	name = "Freelancers (Squad)"
	mob_max = 8
	probability = 20


/datum/emergency_call/mercs/New()
	. = ..()
	hostility = pick(75;FALSE,25;TRUE)
	arrival_message = "[MAIN_SHIP_NAME], this is Freelancer shuttle [pick(alphabet_lowercase)][pick(alphabet_lowercase)]-[rand(1, 99)] responding to your distress call. Prepare for boarding."
	if(hostility)
		objectives = "Ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way. Do what your Captain says. Ensure your survival at all costs."
	else
		objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."

/datum/emergency_call/mercs/friendly //if admins want to specifically call in friendly ones
	name = "Friendly Freelancers (Squad)"
	mob_max = 8
	probability = 1

/datum/emergency_call/mercs/friendly/New()
	. = ..()
	hostility = FALSE
	arrival_message = "[MAIN_SHIP_NAME], this is Freelancer shuttle [pick(alphabet_lowercase)][pick(alphabet_lowercase)]-[rand(1, 99)] responding to your distress call. Prepare for boarding."
	objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."

/datum/emergency_call/mercs/hostile //ditto
	name = "Hostile Freelancers (Squad)"
	mob_max = 8
	probability = 1

/datum/emergency_call/mercs/hostile/New()
	. = ..()
	hostility = TRUE
	arrival_message = "[MAIN_SHIP_NAME], this is Freelancer shuttle [pick(alphabet_lowercase)][pick(alphabet_lowercase)]-[rand(1, 99)] responding to your distress call. Prepare for boarding."
	objectives = "Ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way. Do what your Captain says. Ensure your survival at all costs."

/datum/emergency_call/mercs/print_backstory(mob/living/carbon/human/new_human)
	to_chat(new_human, SPAN_BOLD("You started off in the Neroid Sector as a colonist seeking work at one of the established colonies."))
	to_chat(new_human, SPAN_BOLD("The withdrawl of United American forces in the early 2180s, the system fell into disarray."))
	to_chat(new_human, SPAN_BOLD("Taking up arms as a mercenary, the Freelancers have become a powerful force of order in the system."))
	to_chat(new_human, SPAN_BOLD("While they are motivated primarily by money, many colonists see the Freelancers as the main forces of order in the Neroid Sector."))
	if(hostility)
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("Despite this, you have been tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.")))
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.")))
	else
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..")))
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("Ensure they are not destroyed.</b>")))

/datum/emergency_call/mercs/create_member(datum/mind/mind, turf/override_spawn_loc)
	var/turf/spawn_loc = override_spawn_loc ? override_spawn_loc : get_spawn_point()

	if(!istype(spawn_loc))
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/new_human = new(spawn_loc)
	new_human.name = new_human.real_name
	mind.transfer_to(new_human, TRUE)
	GLOB.ert_mobs += new_human
	new_human.job = "Mercenary"

	if(!leader && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_LEADER) && check_timelock(new_human.client, JOB_SQUAD_LEADER, time_required_for_job))
		leader = new_human
		arm_equipment(new_human, /datum/equipment_preset/other/freelancer/leader, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are the Freelancer leader!"))
	else if(medics < max_medics && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_MEDIC) && check_timelock(new_human.client, JOB_SQUAD_MEDIC, time_required_for_job))
		medics++
		arm_equipment(new_human, /datum/equipment_preset/other/freelancer/medic, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Freelancer Medic!"))
	else
		arm_equipment(new_human, /datum/equipment_preset/other/freelancer/standard, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are a Freelancer Mercenary!"))
	print_backstory(new_human)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), new_human, SPAN_BOLD("Objectives: [objectives]")), 1 SECONDS)

/datum/emergency_call/mercs/platoon
	name = "Freelancers (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 1
	max_medics = 3

/datum/emergency_call/heavy_mercs
	name = "Elite Mercenaries (Random Alignment)"
	mob_min = 4
	mob_max = 8
	probability = 1
	max_medics = 1
	max_engineers = 1
	max_heavies = 1

/datum/emergency_call/heavy_mercs/New()
	. = ..()
	hostility = pick(75;FALSE,25;TRUE)
	arrival_message = "[MAIN_SHIP_NAME], this is Elite Freelancer shuttle [pick(alphabet_lowercase)][pick(alphabet_lowercase)]-[rand(1, 99)] responding to your distress call. Prepare for boarding."
	if(hostility)
		objectives = "Ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way. Do what your Captain says. Ensure your survival at all costs."
	else
		objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."

/datum/emergency_call/heavy_mercs/hostile
	name = "Elite Mercenaries (HOSTILE to USCM)"

/datum/emergency_call/heavy_mercs/hostile/New()
	. = ..()
	hostility = TRUE
	arrival_message = "[MAIN_SHIP_NAME], this is Elite Freelancer shuttle [pick(alphabet_lowercase)][pick(alphabet_lowercase)]-[rand(1, 99)] responding to your distress call. Prepare for boarding."
	objectives = "Ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way. Do what your Captain says. Ensure your survival at all costs."

/datum/emergency_call/heavy_mercs/friendly
	name = "Elite Mercenaries (Friendly)"

/datum/emergency_call/heavy_mercs/friendly/New()
	. = ..()
	hostility = FALSE
	arrival_message = "[MAIN_SHIP_NAME], this is Elite Freelancer shuttle [pick(alphabet_lowercase)][pick(alphabet_lowercase)]-[rand(1, 99)] responding to your distress call. Prepare for boarding."
	objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."

/datum/emergency_call/heavy_mercs/print_backstory(mob/living/carbon/human/new_human)
	to_chat(new_human, SPAN_BOLD("You started off in the Neroid Sector as an experienced miner seeking work at one of the established colonies."))
	to_chat(new_human, SPAN_BOLD("The withdrawl of United American forces in the early 2180s, the system fell into disarray."))
	to_chat(new_human, SPAN_BOLD("Taking up arms as a mercenary, the Freelancers have become a powerful force of order in the system."))
	to_chat(new_human, SPAN_BOLD("While they are motivated primarily by money, many colonists see the Freelancers as the main forces of order in the Neroid Sector."))
	if(hostility)
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("Despite this, you have been specially tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.")))
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.")))
	else
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..")))
		to_chat(new_human, SPAN_NOTICE(SPAN_BOLD("Ensure they are not destroyed.</b>")))

/datum/emergency_call/heavy_mercs/create_member(datum/mind/mind, turf/override_spawn_loc)
	var/turf/spawn_loc = override_spawn_loc ? override_spawn_loc : get_spawn_point()

	if(!istype(spawn_loc))
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/new_human = new(spawn_loc)
	new_human.name = new_human.real_name
	mind.transfer_to(new_human, TRUE)
	GLOB.ert_mobs += new_human
	new_human.job = "Mercenary"

	if(!leader && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_LEADER) && check_timelock(new_human.client, JOB_SQUAD_LEADER, time_required_for_job))    //First one spawned is always the leader.
		leader = new_human
		arm_equipment(new_human, /datum/equipment_preset/other/elite_merc/leader, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are the Elite Mercenary leader!"))
	else if(medics < max_medics && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_MEDIC) && check_timelock(new_human.client, JOB_SQUAD_MEDIC, time_required_for_job))
		medics++
		arm_equipment(new_human, /datum/equipment_preset/other/elite_merc/medic, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are an Elite Mercenary Medic!"))
	else if(engineers < max_engineers && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_ENGINEER) && check_timelock(new_human.client, JOB_SQUAD_ENGI, time_required_for_job))
		engineers++
		arm_equipment(new_human, /datum/equipment_preset/other/elite_merc/engineer, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are an Elite Mercenary Engineer!"))
	else if(heavies < max_heavies && HAS_FLAG(new_human.client.prefs.toggles_ert, PLAY_SMARTGUNNER) && check_timelock(new_human.client, JOB_SQUAD_SMARTGUN, time_required_for_job))
		heavies++
		arm_equipment(new_human, /datum/equipment_preset/other/elite_merc/heavy, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are an Elite Mercenary Specialist!"))
	else
		arm_equipment(new_human, /datum/equipment_preset/other/elite_merc/standard, TRUE, TRUE)
		to_chat(new_human, SPAN_ROLE_HEADER("You are an Elite Mercenary!"))
	print_backstory(new_human)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), new_human, SPAN_BOLD("Objectives: [objectives]")), 1 SECONDS)
