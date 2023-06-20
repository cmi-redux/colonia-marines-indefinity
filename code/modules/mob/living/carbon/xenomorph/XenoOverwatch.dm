// File that holds everything related to Xeno overwatch.
// The action for watching another Xeno (Queen still has some shitty leftovers, but it's mostly been cleaned out)
/datum/action/xeno_action/watch_xeno
	name = "Watch Xenomorph"
	action_icon_state = "watch_xeno"
	plasma_cost = 0
	macro_path = /datum/action/xeno_action/verb/verb_watch_xeno

/datum/action/xeno_action/watch_xeno/can_use_action()
	if(!owner)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(!istype(X))
		return FALSE
	if(X.is_mob_incapacitated() || X.buckled || X.burrow)
		return FALSE
	else
		return TRUE

/datum/action/xeno_action/watch_xeno/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!X.check_state(TRUE))
		return FALSE

	var/isQueen = FALSE
	if(X.caste_type == XENO_CASTE_QUEEN)
		isQueen = TRUE

	if(!X.faction.living_xeno_queen && !X.faction.allow_no_queen_actions)
		to_chat(X, SPAN_WARNING("There is no Queen. You are alone."))
		return

	// We are already overwatching something
	if(X.observed_xeno)
		if(isQueen)
			var/mob/living/carbon/xenomorph/old_xeno = X.observed_xeno
			X.overwatch(X.observed_xeno, TRUE)
			if(old_xeno)
				old_xeno.hud_set_queen_overwatch()
		else
			X.overwatch(X.observed_xeno, TRUE)
		return

	var/list/possible_xenos = list()
	for(var/mob/living/carbon/xenomorph/T in GLOB.living_xeno_list)
		if(T != X && !is_admin_level(T.z) && X.faction == T.faction) // Can't overwatch yourself, Xenos in Thunderdome, or Xenos in other hives
			possible_xenos += T

	var/mob/living/carbon/xenomorph/selected_xeno = tgui_input_list(X, "Target", "Watch which xenomorph?", possible_xenos, theme="hive_status")

	if(!selected_xeno || QDELETED(selected_xeno) || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || is_admin_level(selected_xeno.z) || !X.check_state(TRUE))
		X.overwatch(X.observed_xeno, TRUE) // Cancel OW
	else if(!isQueen) // Regular Xeno OW vs Queen
		X.overwatch(selected_xeno)
	else // We are a queen
		var/mob/living/carbon/xenomorph/old_xeno = X.observed_xeno
		X.overwatch(selected_xeno, FALSE)
		if(old_xeno)
			old_xeno.hud_set_queen_overwatch()

	if(selected_xeno && !QDELETED(selected_xeno))
		selected_xeno.hud_set_queen_overwatch()

// Generic Xeno overwatch proc, very simple for now. If you want it to cancel the overwatch, hand in TRUE in the second var.
// Third var is only for custom event handlers for OW hud indicators, currently only used for the Queen icon
// If you use it, be sure to manually specify the second var, even if its the default value.
/mob/living/carbon/xenomorph/proc/overwatch(mob/living/carbon/xenomorph/targetXeno, stop_overwatch = FALSE)
	if(stop_overwatch)
		var/mob/living/carbon/xenomorph/old_xeno = observed_xeno
		observed_xeno = null

		SEND_SIGNAL(src, COMSIG_XENO_STOP_OVERWATCH, old_xeno)
		UnregisterSignal(src, COMSIG_MOB_MOVE_OR_LOOK)

		if(old_xeno)
			to_chat(src, SPAN_XENOWARNING("You stop watching [old_xeno]."))
			UnregisterSignal(old_xeno, COMSIG_PARENT_QDELETING)
			if(!QDELETED(old_xeno))
				old_xeno.hud_set_queen_overwatch()
	else
		if(!faction)
			return

		if(!faction.living_xeno_queen && !faction.allow_no_queen_actions)
			to_chat(src, SPAN_WARNING("There is no Queen. You are alone."))
			return

		if(targetXeno == src)
			to_chat(src, SPAN_XENOWARNING("You can't watch yourself!"))
			return

		if(targetXeno.interference)
			to_chat(src, SPAN_XENOWARNING("Your target's psychic connection is cut off!"))
			return

		if(observed_xeno && targetXeno && observed_xeno == targetXeno)
			if(istype(targetXeno, /obj/effect/alien/resin/marker))
				to_chat(src, SPAN_XENOWARNING("You are already watching that mark!"))
				return
			to_chat(src, SPAN_XENOWARNING("You are already watching that sister!"))
			return

		if(caste_type != XENO_CASTE_QUEEN && is_zoomed)
			zoom_out()

		if(observed_xeno)
			var/mob/living/carbon/xenomorph/old_xeno = observed_xeno
			observed_xeno = null

			SEND_SIGNAL(src, COMSIG_XENO_STOP_OVERWATCH_XENO, old_xeno)
			old_xeno.hud_set_queen_overwatch()
			UnregisterSignal(src, COMSIG_MOB_MOVE_OR_LOOK)
			UnregisterSignal(old_xeno, COMSIG_PARENT_QDELETING)

		observed_xeno = targetXeno

		observed_xeno.hud_set_queen_overwatch()
		SEND_SIGNAL(src, COMSIG_XENO_OVERWATCH_XENO, observed_xeno)
		RegisterSignal(src, COMSIG_MOB_MOVE_OR_LOOK, PROC_REF(overwatch_handle_mob_move_or_look))
		RegisterSignal(observed_xeno, COMSIG_PARENT_QDELETING, PROC_REF(overwatch_handle_deletion))

	src.reset_view()

/mob/living/carbon/xenomorph/proc/overwatch_handle_deletion(mob/living/carbon/xenomorph/deleted, forced)
	SIGNAL_HANDLER
	overwatch(deleted, TRUE)

// Called from xeno Life()
// Makes sure that Xeno overwatch is reset when the overwatched Xeno dies.
/mob/living/carbon/xenomorph/proc/handle_overwatch()
	if(observed_xeno && (observed_xeno == DEAD || QDELETED(observed_xeno)))
		overwatch(null, TRUE)

/mob/living/carbon/xenomorph/proc/overwatch_handle_mob_move_or_look(mob/living/carbon/xenomorph/mover, actually_moving, direction, specific_direction)
	SIGNAL_HANDLER

	if(!actually_moving)
		return

	mover.overwatch(mover.observed_xeno, TRUE) // Goodbye overwatch
	UnregisterSignal(mover, COMSIG_MOB_MOVE_OR_LOOK)
	return COMPONENT_OVERRIDE_MOB_MOVE_OR_LOOK

/mob/living/carbon/xenomorph/queen/overwatch_handle_mob_move_or_look(mob/living/carbon/xenomorph/queen/mover, actually_moving, direction, specific_direction)
	if(!actually_moving)
		return

	var/mob/living/carbon/xenomorph/observed_xeno = mover.observed_xeno
	mover.overwatch(observed_xeno, TRUE)
	if(observed_xeno)
		observed_xeno.hud_set_queen_overwatch()
	UnregisterSignal(mover, COMSIG_MOB_MOVE_OR_LOOK)
	return COMPONENT_OVERRIDE_MOB_MOVE_OR_LOOK

// Sets the Xeno's view to its observed target if that target is set. Otherwise, resets the xeno's view to itself.
// Please handle typechecking outside this proc
/mob/living/carbon/xenomorph/reset_view(atom/A)
	. = ..(A)
	if(.)
		return

	if(client)

		// Is our observed xeno configured and are we alive?
		if(observed_xeno && !stat)
			client.perspective = EYE_PERSPECTIVE
			client.eye = observed_xeno

// Handle HREF clicks through hive status and hivemind
/mob/living/carbon/xenomorph/Topic(href, href_list)
	if(href_list[XENO_OVERWATCH_TARGET_HREF])
		if(!check_state(TRUE))
			return

		var/isQueen = (src.caste_type == XENO_CASTE_QUEEN)

		var/mob/living/carbon/xenomorph/xenoTarget = locate(href_list[XENO_OVERWATCH_TARGET_HREF]) in GLOB.living_xeno_list
		var/mob/living/carbon/xenomorph/xenoSrc = locate(href_list[XENO_OVERWATCH_SRC_HREF]) in GLOB.living_xeno_list

		if(!istype(xenoTarget) || xenoTarget.stat == DEAD || is_admin_level(xenoTarget.z))
			return

		if(!istype(xenoSrc) || xenoSrc.stat == DEAD)
			return

		if(!isQueen)
			xenoSrc.overwatch(xenoTarget)
		else
			var/mob/living/carbon/xenomorph/old_xeno = xenoSrc.observed_xeno
			xenoSrc.overwatch(xenoTarget, FALSE)
			if(old_xeno)
				old_xeno.hud_set_queen_overwatch()
			if(xenoTarget && !QDELETED(xenoTarget))
				xenoTarget.hud_set_queen_overwatch()
	if(href_list["overwatch"])
		var/input = href_list["target"]
		var/obj/effect/alien/resin/marker/target = locate(input)
		if(!istype(target, /obj/effect/alien/resin/marker)|| !target.loc)
			to_chat(src, SPAN_XENONOTICE("That resin mark no longer exists."))
			return
		else
			to_chat(src, SPAN_XENONOTICE("You psychically observe the [target.mark_meaning.name] resin mark in [get_area_name(target)]."))
			overwatch(target)
	if(href_list["track"])
		var/input2 = href_list["target"]
		var/obj/effect/alien/resin/marker/target2 = locate(input2)
		if(!istype(target2, /obj/effect/alien/resin/marker) || !target2.loc)
			to_chat(src, SPAN_XENONOTICE("That resin mark no longer exists."))
			return
		else
			start_tracking_resin_mark(target2)
	if(href_list["evolve"])
		Evolve()


	..()

