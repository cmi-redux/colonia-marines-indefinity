/obj/docking_port/mobile/crashable
	name = "crashable shuttle"

	/// Whether or not this shuttle is crash landing
	var/crash_land = FALSE
	/// Whether fires occur aboard the shuttle when crashing
	var/fires_on_crash = FALSE
	/// The % chance of the escape pod crashing into the groundmap before lifeboats leaving
	var/early_crash_land_chance = 75
	/// The % chance of the escape pod crashing into the groundmap
	var/crash_land_chance = 25
	/// How many people can be in the escape pod before it crashes
	var/max_capacity = 0
	/// How many people survived
	var/survivors = 0

	var/launched = FALSE
	var/evac_set = FALSE

/obj/docking_port/mobile/crashable/enterTransit()
	. = ..()

	if(!crash_land)
		return

	notify_ghosts(header = "Crashing shuttle!", message = "<b>[name]</b> has catastrophically failed and is crashing at <b>[get_area(destination)]</b>.", source = destination)

	for(var/area/shuttle_area as anything in shuttle_areas)
		shuttle_area.flags_alarm_state |= ALARM_WARNING_FIRE
		shuttle_area.updateicon()
		for(var/mob/evac_mob in shuttle_area)
			if(evac_mob.client)
				playsound_client(evac_mob.client, 'sound/effects/bomb_fall.ogg', vol = 50)

	for(var/turf/found_turf as anything in destination.return_turfs())
		if(istype(found_turf, /turf/closed))
			found_turf.ChangeTurf(/turf/open/floor)

	for(var/mob/current_mob as anything in get_mobs_in_z_level_range(destination.return_center_turf(), 18))
		var/relative_dir = get_dir(current_mob, destination.return_center_turf())
		var/final_dir = dir2text(relative_dir)
		to_chat(current_mob, SPAN_HIGHDANGER("You hear something crashing down from above [final_dir ? "to the [final_dir]" : "nearby"]!"))

	if(fires_on_crash)
		handle_fires()

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(cell_explosion), destination.return_center_turf(), length(destination.return_turfs()) * 2, 25, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, create_cause_data("crashing shuttle")), 1.5 SECONDS)

/obj/docking_port/mobile/crashable/on_prearrival()
	. = ..()

	if(!crash_land)
		return

	movement_force = list("KNOCKDOWN" = 0, "THROW" = 5)

	for(var/area/shuttle_area in shuttle_areas)
		for(var/mob/evac_mob in shuttle_area)
			shake_camera(evac_mob, 20, 2)
			if(evac_mob.client)
				playsound_client(evac_mob.client, get_sfx("bigboom"), vol = 50)

/// Called when the shuttle is launched and checks for crash and creates a crash point
/obj/docking_port/mobile/crashable/proc/evac_launch()
	if(mode == SHUTTLE_CRASHED)
		return FALSE

	if(launched)
		return FALSE

	if(crash_check())
		create_crash_point()

	close_doors()
	var/occupant_count = 0
	var/list/cryos = list()
	for(var/area/interior_area in shuttle_areas)
		for(var/mob/living/occupant in interior_area)
			occupant_count++
		for(var/obj/structure/machinery/cryopod/evacuation/cryotube in interior_area)
			cryos += list(cryotube)

	launched = TRUE
	if(occupant_count > max_capacity)
		playsound(src,'sound/effects/escape_pod_warmup.ogg', 50, 1)
		sleep(31)
		sleep(25)
		mode = SHUTTLE_CRASHED
		for(var/obj/structure/machinery/cryopod/evacuation/cryotube in cryos)
			cryotube.go_out()
		overcap_launch_attempt()
		return FALSE

	set_mode(SHUTTLE_IGNITING)
	on_ignition()
	setTimer(ignitionTime)

/obj/docking_port/mobile/crashable/proc/overcap_launch_attempt()
	open_doors()

/// Returns whether or not the shuttle will crash after being sent
/obj/docking_port/mobile/crashable/proc/crash_check()
	if(prob((SSevacuation.evac_status >= EVACUATION_STATUS_IN_PROGRESS ? crash_land_chance : early_crash_land_chance)))
		return TRUE
	return FALSE

/// Sets up a valid crash point, fails after 10 tries
/obj/docking_port/mobile/crashable/proc/create_crash_point()
	for(var/i = 1 to 10)
		var/list/all_ground_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND)
		var/ground_z_level = all_ground_levels[1]

		var/list/area/potential_areas = SSmapping.areas_in_z["[ground_z_level]"]

		var/area/area_picked = pick(potential_areas)

		var/list/potential_turfs = list()

		for(var/turf/turf_in_area in area_picked)
			potential_turfs += turf_in_area

		if(!length(potential_turfs))
			continue

		var/turf/turf_picked = pick(potential_turfs)

		var/obj/docking_port/stationary/crashable/temp_crashable_port = new(turf_picked)
		temp_crashable_port.width = width
		temp_crashable_port.height = height
		temp_crashable_port.id = id

		if(!check_crash_point(temp_crashable_port))
			qdel(temp_crashable_port)
			continue

		destination = temp_crashable_port
		break

	if(destination)
		crash_land = TRUE

/// Forces the shuttle to crash, admin called
/obj/docking_port/mobile/crashable/proc/force_crash()
	create_crash_point()
	set_mode(SHUTTLE_IGNITING)
	on_ignition()
	setTimer(ignitionTime)

/// Sets up and handles fires/explosions on crashing shuttles
/obj/docking_port/mobile/crashable/proc/handle_fires()
	var/list/turf/total_turfs = list()
	for(var/area/shuttle_area as anything in shuttle_areas)
		for(var/turf/cycled_turf in shuttle_area)
			total_turfs += cycled_turf

	for(var/i = 1 to (length(total_turfs) / 40))
		var/turf/position = pick(total_turfs)
		new /obj/effect/warning/explosive(position, 3 SECONDS)
		playsound(position, 'sound/effects/pipe_hissing.ogg', vol = 40)
		addtimer(CALLBACK(src, PROC_REF(kablooie), position), 3 SECONDS)

/// Actually blows up the fire/explosion on crashing shuttles, used for effect delay
/obj/docking_port/mobile/crashable/proc/kablooie(turf/position)
	var/new_cause_data = create_cause_data("crashing shuttle fire")
	var/list/exploding_types = list(/obj/item/explosive/grenade/high_explosive/bursting_pipe, /obj/item/explosive/grenade/incendiary/bursting_pipe)
	for(var/path in exploding_types)
		var/obj/item/explosive/grenade/exploder = new path(position)
		exploder.cause_data = new_cause_data
		exploder.prime()

/// Handles opening the doors for the specific shuttle type upon arriving at the crash point
/obj/docking_port/mobile/crashable/proc/open_doors()
	return

/obj/docking_port/mobile/crashable/proc/close_doors()
	return

/obj/docking_port/stationary/crashable
	name = "Crashable Dock"

/obj/docking_port/stationary/crashable/on_arrival(obj/docking_port/mobile/arriving_shuttle)
	. = ..()

	if(istype(arriving_shuttle, /obj/docking_port/mobile/crashable))
		var/obj/docking_port/mobile/crashable/crashing_shuttle = arriving_shuttle
		crashing_shuttle.open_doors()

	for(var/area/shuttle_area in arriving_shuttle.shuttle_areas)
		shuttle_area.remove_base_lighting()

		shuttle_area.flags_alarm_state &= ~ALARM_WARNING_FIRE
		shuttle_area.updateicon()
