//An objective to open a safe
/datum/cm_objective/crack_safe
	var/obj/structure/safe/target
	var/area/initial_area
	value = OBJECTIVE_HIGH_VALUE
	objective_flags = OBJECTIVE_DEAD_END
	controller = FACTION_MARINE
	number_of_clues_to_generate = 2

/datum/cm_objective/crack_safe/New(faction_to_get, obj/structure/safe/safe)
	target = safe
	initial_area = get_area(target)


	RegisterSignal(safe, COMSIG_SAFE_OPENED, PROC_REF(on_safe_open))
	RegisterSignal(safe, COMSIG_PARENT_QDELETING, PROC_REF(on_safe_open))
	. = ..()

/datum/cm_objective/crack_safe/post_round_start()
	SSfactions.statistics["miscellaneous_total_instances"]++

/datum/cm_objective/crack_safe/Destroy()
	target = null
	initial_area = null
	return ..()

/datum/cm_objective/crack_safe/get_clue()
	return SPAN_DANGER("Crack open a safe in <u>[initial_area]</u>, the combination lock is <b>[target.tumbler_1_open]|[target.tumbler_2_open]</b>")

/datum/cm_objective/crack_safe/get_related_label()
	return "Safe"

/datum/cm_objective/crack_safe/get_tgui_data()
	var/list/clue = list()

	clue["text"] = "Crack open the safe"
	clue["key_text"] = ", combination lock is "
	clue["key"] = "[target.tumbler_1_open]|[target.tumbler_2_open]"
	clue["location"] = initial_area.name

	return clue

/datum/cm_objective/crack_safe/complete()
	objective_state = OBJECTIVE_COMPLETE
	SSfactions.statistics["miscellaneous_completed"]++
	SSfactions.statistics["miscellaneous_total_points_earned"] += value

/datum/cm_objective/crack_safe/proc/on_safe_open(obj/structure/safe)
	SIGNAL_HANDLER

	if(objective_state != OBJECTIVE_COMPLETE)
		UnregisterSignal(safe, COMSIG_SAFE_OPENED)
		complete()
