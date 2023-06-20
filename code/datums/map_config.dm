//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config
	// Metadata
	var/config_filename = "maps/LV624.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1

	// Config actually from the JSON - default values
	var/map_name = "LV624"
	var/map_path = "map_files/LV624"
	var/map_file = "LV624.dmm"

	var/short_name

	var/traits = null
	var/space_empty_levels = 1
	var/list/environment_traits = list()
	var/list/gamemodes = list()

	var/list/map_day_night_modificator = list()
	var/list/custom_day_night_colors = list()
	var/custom_time_length = list()

	var/camouflage_type = "classic"

	var/allow_custom_shuttles = TRUE
	var/shuttles = list()

	var/announce_text = ""

	var/squads_max_num = 4

	var/weather_holder

	var/list/survivor_types
	var/list/survivor_types_by_variant

	var/list/synth_survivor_types
	var/list/synth_survivor_types_by_variant

	var/list/CO_survivor_types

	var/survivor_message = "You are a survivor of the attack on the colony. You worked or lived in the archaeology colony, and managed to avoid the alien attacks... until now."

	var/force_mode

	var/perf_mode

	var/disable_ship_map = FALSE

	var/list/monkey_types = list(/mob/living/carbon/human/monkey)

	var/list/xvx_hives = list(FACTION_XENOMORPH_ALPHA = 0, FACTION_XENOMORPH_BRAVO = 0)

	var/list/weather = list()

	var/vote_cycle = 1

	var/nightmare_path

/datum/map_config/New()
	survivor_types = list(
		/datum/equipment_preset/survivor/scientist,
		/datum/equipment_preset/survivor/doctor,
		/datum/equipment_preset/survivor/chef,
		/datum/equipment_preset/survivor/chaplain,
		/datum/equipment_preset/survivor/miner,
		/datum/equipment_preset/survivor/colonial_marshal,
		/datum/equipment_preset/survivor/engineer,
	)

	synth_survivor_types = list(
		/datum/equipment_preset/synth/survivor/medical_synth,
		/datum/equipment_preset/synth/survivor/emt_synth,
		/datum/equipment_preset/synth/survivor/scientist_synth,
		/datum/equipment_preset/synth/survivor/engineer_synth,
		/datum/equipment_preset/synth/survivor/janitor_synth,
		/datum/equipment_preset/synth/survivor/chef_synth,
		/datum/equipment_preset/synth/survivor/teacher_synth,
		/datum/equipment_preset/synth/survivor/bartender_synth,
		/datum/equipment_preset/synth/survivor/detective_synth,
		/datum/equipment_preset/synth/survivor/cmb_synth,
		/datum/equipment_preset/synth/survivor/security_synth,
		/datum/equipment_preset/synth/survivor/protection_synth,
		/datum/equipment_preset/synth/survivor/corporate_synth,
		/datum/equipment_preset/synth/survivor/radiation_synth,
	)

/proc/load_map_config(filename, default, delete_after, error_if_missing = TRUE)
	var/datum/map_config/config = new
	if(default)
		return config
	if(!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		config = new /datum/map_config
	if(delete_after)
		fdel(filename)
	return config


/proc/load_map_configs(list/maptypes, default, delete_after, error_if_missing = TRUE)
	var/list/configs = list()

	for(var/i in maptypes)
		var/filename
		if(CONFIG_GET(flag/ephemeral_map_mode) && i == GROUND_MAP)
			filename = CONFIG_GET(string/ephemeral_ground_map)
		else filename = MAP_TO_FILENAME[i]
		var/datum/map_config/config = new
		if(default)
			configs[i] = config
			continue
		if(!config.LoadConfig(filename, error_if_missing, i))
			qdel(config)
			config = new /datum/map_config
		if(delete_after)
			fdel(filename)
		configs[i] = config
	return configs

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing, maptype)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = file2text(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]

	short_name = json["short_name"]

	map_file = json["map_file"]
	// "map_file": "BoxStation.dmm"
	if(istext(map_file))
		if(!fexists("maps/[map_path]/[map_file]"))
			log_world("Map file ([map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if(islist(map_file))
		for (var/file in map_file)
			if(!fexists("maps/[map_path]/[file]"))
				log_world("Map file ([file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	if(islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if("shuttles" in json)
		log_world("map_config shuttles is not a list!")
		return

	if(islist(json["survivor_types"]))
		survivor_types = json["survivor_types"]
	else if("survivor_types" in json)
		log_world("map_config survivor_types is not a list!")
		return

	var/list/pathed_survivor_types = list()
	for(var/surv_type in survivor_types)
		var/survivor_typepath = surv_type
		if(!ispath(survivor_typepath))
			survivor_typepath = text2path(surv_type)
			if(!ispath(survivor_typepath))
				log_world("[surv_type] isn't a proper typepath, removing from survivor_types list")
				continue
		pathed_survivor_types += survivor_typepath
	survivor_types = pathed_survivor_types.Copy()

	survivor_types_by_variant = list()
	for(var/surv_type in survivor_types)
		var/datum/equipment_preset/survivor/surv_equipment = surv_type
		var/survivor_variant = initial(surv_equipment.survivor_variant)
		if(!survivor_types_by_variant[survivor_variant]) survivor_types_by_variant[survivor_variant] = list()
		survivor_types_by_variant[survivor_variant] += surv_type

	if(islist(json["synth_survivor_types"]))
		synth_survivor_types = json["synth_survivor_types"]
	else if ("synth_survivor_types" in json)
		log_world("map_config synth_survivor_types is not a list!")
		return

	var/list/pathed_synth_survivor_types = list()
	for(var/synth_surv_type in synth_survivor_types)
		var/synth_survivor_typepath = synth_surv_type
		if(!ispath(synth_survivor_typepath))
			synth_survivor_typepath = text2path(synth_surv_type)
			if(!ispath(synth_survivor_typepath))
				log_world("[synth_surv_type] isn't a proper typepath, removing from synth_survivor_types list")
				continue
		pathed_synth_survivor_types += synth_survivor_typepath
	synth_survivor_types = pathed_synth_survivor_types.Copy()

	synth_survivor_types_by_variant = list()
	for(var/surv_type in synth_survivor_types)
		var/datum/equipment_preset/synth/survivor/surv_equipment = surv_type
		var/survivor_variant = initial(surv_equipment.survivor_variant)
		if(!synth_survivor_types_by_variant[survivor_variant]) synth_survivor_types_by_variant[survivor_variant] = list()
		synth_survivor_types_by_variant[survivor_variant] += surv_type

	if(islist(json["CO_survivor_types"]))
		CO_survivor_types = json["CO_survivor_types"]
	else if ("CO_survivor_types" in json)
		log_world("map_config CO_survivor_types is not a list!")
		return

	var/list/pathed_CO_survivor_types = list()
	for(var/CO_surv_type in CO_survivor_types)
		var/CO_survivor_typepath = CO_surv_type
		if(!ispath(CO_survivor_typepath))
			CO_survivor_typepath = text2path(CO_surv_type)
			if(!ispath(CO_survivor_typepath))
				log_world("[CO_surv_type] isn't a proper typepath, removing from CO_survivor_types list")
				continue
		pathed_CO_survivor_types += CO_survivor_typepath
	CO_survivor_types = pathed_CO_survivor_types.Copy()

	if(islist(json["monkey_types"]))
		monkey_types = list()
		for(var/monkey in json["monkey_types"])
			switch(monkey)
				if("farwa")
					monkey_types += /mob/living/carbon/human/farwa
				if("monkey")
					monkey_types += /mob/living/carbon/human/monkey
				if("neaera")
					monkey_types += /mob/living/carbon/human/neaera
				if("stok")
					monkey_types += /mob/living/carbon/human/stok
				if("yiren")
					monkey_types += /mob/living/carbon/human/yiren
				else
					log_world("map_config monkey_types has invalid name!")
					return
	else if("monkey_types" in json)
		log_world("map_config monkey_types is not a list!")
		return

	if(islist(json["xvx_hives"]))
		xvx_hives = json["xvx_hives"]
	else if(!isnull(json["xvx_hives"]))
		log_world("map_config xvx_hives is not a list!")
		return

	if(islist(json["traits"]))
		var/list/traits_to_set = json["traits"]
		for(var/list/traits_set in traits_to_set)
			if(traits_set["Zlevels"])
				var/potential_zlevels = traits_set["Zlevels"]
				traits_set.Cut(1, 2)
				for(var/i=0;i<potential_zlevels;i++)
					traits += list(traits_set)
			else
				traits += list(traits_set)
	else if(!isnull(json["traits"]))
		log_world("map_config traits is not a list!")
		return

	var/temp = json["space_empty_levels"]
	if(isnum(temp))
		space_empty_levels = temp
	else if(!isnull(temp))
		log_world("map_config space_empty_levels is not a number!")
		return

	temp = json["squads"]
	if(isnum(temp))
		squads_max_num = temp
	else if(!isnull(temp))
		log_world("map_config squads_max_num is not a number!")
		return

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

	if(json["camouflage"])
		camouflage_type = json["camouflage"]

	if(json["survivor_message"])
		survivor_message = json["survivor_message"]

	if(json["force_mode"])
		force_mode = json["force_mode"]

	if(json["disable_ship_map"])
		disable_ship_map = json["disable_ship_map"]

	if(json["perf_mode"])
		perf_mode = json["perf_mode"]

	if(json["vote_cycle"])
		vote_cycle = json["vote_cycle"]

	if(json["announce_text"])
		announce_text = json["announce_text"]

	if(islist(json["weather"]))
		weather = json["weather"]
	else if(!isnull(json["weather"]))
		log_world("map_config weather is not a list!")
		return

	if(json["nightmare_path"])
		nightmare_path = json["nightmare_path"]

	if(islist(json["environment_traits"]))
		environment_traits = json["environment_traits"]
	else if(!isnull(json["environment_traits"]))
		log_world("map_config environment_traits is not a list!")
		return

	var/list/gamemode_names = list()
	for(var/t in subtypesof(/datum/game_mode))
		var/datum/game_mode/G = t
		gamemode_names += initial(G.config_tag)

	if(islist(json["gamemodes"]))
		for(var/g in json["gamemodes"])
			if(!(g in gamemode_names))
				log_world("map_config has an invalid gamemode name!")
				return
			if(g == MODE_NAME_EXTENDED) // always allow extended
				continue
			gamemodes += g
		gamemodes += MODE_NAME_EXTENDED
	else if(!isnull(json["gamemodes"]))
		log_world("map_config gamemodes is not a list!")
		return
	else
		for(var/a in subtypesof(/datum/game_mode))
			var/datum/game_mode/G = a
			gamemodes += initial(G.config_tag)

	if(islist(json["map_day_night_modificator"]))
		if(!islist(json["map_day_night_modificator"]))
			log_world("map_config custom day/night modificator is not a list!")
			return
		map_day_night_modificator = json["map_day_night_modificator"]

	if(islist(json["custom_day_night_colors"]))
		if(!islist(json["custom_day_night_colors"]))
			log_world("map_config custom day/night colors is not a list!")
			return
		custom_day_night_colors = json["custom_day_night_colors"]

	if(json["custom_time_length"])
		custom_time_length = json["custom_time_length"]
	else
		custom_time_length = 24 HOURS

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if(istext(map_file))
		return list("maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "maps/[map_path]/[file]"


/datum/map_config/proc/MakeNextMap(maptype = GROUND_MAP)
	if(CONFIG_GET(flag/ephemeral_map_mode))
		message_admins("NOTICE: Running in ephemeral mode - map change request ignored")
		return TRUE
	if(maptype == GROUND_MAP)
		return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
	else if(maptype == SHIP_MAP)
		return config_filename == "data/next_ship.json" || fcopy(config_filename, "data/next_ship.json")
