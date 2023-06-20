/datum/action/ghost
	name = "Ghost"
	action_icon_state = "ghost"

/datum/action/ghost/action_activate()
	if(!owner.client)
		return

	var/mob/living/activator = owner

	activator.do_ghost()

/datum/action/ghost/give_to(mob/L)
	. = ..()

	RegisterSignal(L, COMSIG_MOB_STAT_SET_ALIVE, PROC_REF(remove_ghost))

/// signal handler to remove the ghost button when someone's not so dead
/datum/action/ghost/proc/remove_ghost(mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(remove_from), user)

/datum/action/join_ert
	name = "Join ERT"
	action_icon_state = "join_ert"
	listen_signal = COMSIG_KB_OBSERVER_JOIN_ERT

/datum/action/join_ert/New(Target, override_icon_state)
	. = ..()
	RegisterSignal(Target, COMSIG_ERT_SETUP, PROC_REF(cleanup))

/datum/action/join_ert/proc/cleanup()
	SIGNAL_HANDLER
	qdel(src)

/datum/action/join_ert/action_activate()
	if(!owner.client)
		return

	var/mob/dead/observer/activator = owner
	activator.do_join_response_team()

/datum/action/join_predator
	name = "Join the Hunt"
	action_icon_state = "join_pred"
	listen_signal = COMSIG_KB_OBSERVER_JOIN_PREDATOR

/datum/action/join_predator/action_activate()
	var/mob/dead/observer/activator = owner
	activator.join_as_yautja()

/datum/action/observer_action/view_faction_status
	name = "View Faction Status"
	action_icon_state = "view_faction_status"

/datum/action/observer_action/view_faction_status/action_activate()
	var/list/datum/faction/factions = list()
	for(var/faction_to_get in FACTION_LIST_ALL)
		var/datum/faction/faction_to_set = GLOB.faction_datum[faction_to_get]
		if(!length(faction_to_set.totalMobs))
			continue
		LAZYSET(factions, faction_to_set.name, faction_to_set)

	var/choice = tgui_input_list(owner, "Please choose faction status menu will to be show.", "Faction Selection", factions)
	if(!choice)
		return FALSE

	factions[choice].tgui_interact(owner)

/datum/action/observer_action/join_xeno
	name = "Join as Xeno"
	action_icon_state = "join_xeno"
	listen_signal = COMSIG_KB_OBSERVER_JOIN_XENO

/datum/action/observer_action/join_xeno/action_activate()
	if(!owner.client)
		return

	if(SSticker.current_state < GAME_STATE_PLAYING || !SSticker.mode)
		owner.balloon_alert(owner, "game must start!")
		return

	if(SSticker.mode.check_xeno_late_join(owner))
		SSticker.mode.attempt_to_join_as_xeno(owner)

/datum/keybinding/observer
	category = CATEGORY_OBSERVER
	weight = WEIGHT_DEAD

/datum/keybinding/observer/can_use(client/user)
	return isobserver(user?.mob)

/datum/keybinding/observer/join_as_xeno
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "join_as_xeno"
	full_name = "Join as Xeno"
	keybind_signal = COMSIG_KB_OBSERVER_JOIN_XENO

/datum/keybinding/observer/join_ert
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "join_ert"
	full_name = "Join ERT"
	keybind_signal = COMSIG_KB_OBSERVER_JOIN_ERT

/datum/keybinding/observer/join_pred
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "join_pred"
	full_name = "Join the Hunt"
	keybind_signal = COMSIG_KB_OBSERVER_JOIN_PREDATOR
