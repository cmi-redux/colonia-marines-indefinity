/datum/job/civilian/liaison
	title = JOB_CORPORATE_LIAISON
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Wey-Yu corporate office"
	selection_class = "job_cl"
	gear_preset = /datum/equipment_preset/uscm_ship/liaison
	entry_message_body = "As a <a href='%WIKIURL%'>representative of Weyland-Yutani Corporation</a>, your job requires you to stay in character at all times. You are not required to follow military orders; however, you cannot give military orders. Your primary job is to observe and report back your findings to Weyland-Yutani. Follow regular game rules unless told otherwise by your superiors. Use your office fax machine to communicate with corporate headquarters or to acquire new directives. You may not receive anything back, and this is normal."
	var/mob/living/carbon/human/active_liaison

/datum/job/civilian/liaison/generate_entry_conditions(mob/living/liaison, whitelist_status)
	. = ..()
	active_liaison = liaison
	RegisterSignal(liaison, COMSIG_PARENT_QDELETING, PROC_REF(cleanup_active_liaison))

/datum/job/civilian/liaison/proc/cleanup_active_liaison(mob/liaison)
	SIGNAL_HANDLER
	active_liaison = null

/datum/job/civilian/liaison/get_latejoin_turf(mob/living/carbon/human/H)
	return get_turf(pick(GLOB.spawns_by_job[type]))

/obj/effect/landmark/start/liaison
	name = JOB_CORPORATE_LIAISON
	icon_state = "cl_spawn"
	job = /datum/job/civilian/liaison

AddTimelock(/datum/job/civilian/liaison, list(
	JOB_HUMAN_ROLES = 10 HOURS,
))

/datum/job/civilian/liaison/upp
	title = JOB_UPP_CORPORATE_LIAISON
	gear_preset = /datum/equipment_preset/upp/liaison

/obj/effect/landmark/start/liaison/upp
	name = JOB_UPP_CORPORATE_LIAISON
	job = /datum/job/civilian/liaison/upp
