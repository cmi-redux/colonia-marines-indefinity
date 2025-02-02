/datum/soundOutput
	var/client/owner
	var/scape_cooldown = INITIAL_SOUNDSCAPE_COOLDOWN //This value is changed when entering an area. Time it takes for a soundscape sound to be triggered
	var/list/soundscape_playlist = list() //Updated on changing areas
	var/ambience = null //The file currently being played as ambience
	var/status_flags = 0 //For things like ear deafness, psychodelic effects, and other things that change how all sounds behave
	var/list/echo

/datum/soundOutput/New(client/C)
	if(!C)
		qdel(src)
		return
	owner = C
	. = ..()

/datum/soundOutput/proc/process_sound(datum/sound_template/T)
	var/sound/S = sound(T.file, T.wait, T.repeat)
	S.volume = owner.volume_preferences[T.volume_cat] * T.volume
	if(T.channel == 0)
		S.channel = get_free_channel()
	else
		S.channel = T.channel
	S.frequency = T.frequency
	S.falloff = T.falloff
	S.status = T.status
	S.echo = T.echo
	if(T.x && T.y && T.z)
		var/turf/owner_turf = get_turf(owner.mob)
		if(owner_turf)
			// We're in an interior and sound came from outside
			if(SSinterior.in_interior(owner_turf) && owner_turf.z != T.z)
				var/datum/interior/interior = SSinterior.get_interior_by_coords(owner_turf.x, owner_turf.y, owner_turf.z)
				if(interior && interior.exterior)
					var/turf/candidate = get_turf(interior.exterior)
					if(candidate.z != T.z)
						return
					S.falloff /= 2
					owner_turf = candidate

			S.x = T.x - owner_turf.x
			var/dy = (T.z - owner_turf.z) * ZSOUND_DISTANCE_PER_Z
			S.y = (dy < 0) ? dy - 1 : dy + 1
			S.z = T.y - owner_turf.y
			var/area/A = owner_turf.loc
			S.environment = A.sound_environment

			S.echo[ECHO_DIRECT] = abs(T.z - owner_turf.z) * ZSOUND_DRYLOSS_PER_Z

		S.y += T.y_s_offset
		S.x += T.x_s_offset

	if(owner.mob.ear_deaf > 0)
		S.status |= SOUND_MUTE

	if(owner.mob.sound_environment_override != SOUND_ENVIRONMENT_NONE)
		S.environment = owner.mob.sound_environment_override

	sound_to(owner,S)

/datum/soundOutput/proc/update_ambience(area/target_area, ambience_override, force_update = FALSE)
	var/status_flags = SOUND_STREAM
	var/target_ambience = ambience_override

	if(!(owner.prefs.toggles_sound & SOUND_AMBIENCE))
		if(!force_update)
			return
		status_flags |= SOUND_MUTE

	// Autodetect mode
	if(!target_area && !target_ambience)
		target_area = get_area(owner.mob)
		if(!target_area)
			return
	if(!target_ambience)
		target_ambience = target_area.get_sound_ambience(owner)
	if(target_area)
		soundscape_playlist = target_area.soundscape_playlist
		if(target_area.background_planet_sounds)
			if(SSsunlighting.current_step_datum.position_number > 3 && SSsunlighting.current_step_datum.position_number < 10)
				soundscape_playlist += SCAPE_PL_BACKGROUND_SOUNDS_DAY_SUMMER
//			else
//				soundscape_playlist += SCAPE_PL_BACKGROUND_SOUNDS_NIGHT_SUMMER

	var/sound/S = sound(null, 1, 0, SOUND_CHANNEL_AMBIENCE)
	var/list/echo_list = new(18)
	if(ambience == target_ambience)
		if(!force_update)
			return
		status_flags |= SOUND_UPDATE
	else
		S.file = target_ambience
		ambience = target_ambience


	S.volume = 100 * owner.volume_preferences[VOLUME_AMB]
	S.status = status_flags

	if(target_area)
		S.environment = target_area.sound_environment
	echo_list[ECHO_ROOM] = get_muffle(target_area, SSmapping.get_turf_above(get_turf(owner.mob)))
	if(!echo_list[ECHO_ROOM])
		S.volume = 0
	S.echo = echo_list
	sound_to(owner, S)


/datum/soundOutput/proc/update_soundscape()
	scape_cooldown--
	if(scape_cooldown <= 0)
		if(soundscape_playlist.len)
			var/sound/S = sound()
			S.file = pick(soundscape_playlist)
			S.volume = 100 * owner.volume_preferences[VOLUME_AMB]
			S.x = pick(1,-1)
			S.z = pick(1,-1)
			S.y = 1
			S.channel = SOUND_CHANNEL_SOUNDSCAPE
			sound_to(owner, S)
		var/area/A = get_area(owner.mob)
		if(A)
			scape_cooldown = pick(A.soundscape_interval, A.soundscape_interval + 1, A.soundscape_interval -1)
		else
			scape_cooldown = INITIAL_SOUNDSCAPE_COOLDOWN

/datum/soundOutput/proc/apply_status()
	var/sound/S = sound()
	if(status_flags & EAR_DEAF_MUTE)
		S.status = SOUND_MUTE | SOUND_UPDATE
		sound_to(owner, S)
	else
		S.status = SOUND_UPDATE
		sound_to(owner, S)

/client/proc/adjust_volume_prefs(volume_key, prompt = "", channel_update = 0)
	volume_preferences[volume_key] = (tgui_input_number(src, prompt, "Volume", volume_preferences[volume_key]*100)) / 100
	if(volume_preferences[volume_key] > 1)
		volume_preferences[volume_key] = 1
	if(volume_preferences[volume_key] < 0)
		volume_preferences[volume_key] = 0
	if(channel_update)
		var/sound/S = sound()
		S.channel = channel_update
		S.volume = 100 * volume_preferences[volume_key]
		S.status = SOUND_UPDATE
		sound_to(src, S)

/client/verb/adjust_volume_sfx()
	set name = "Adjust Volume SFX"
	set category = "Preferences.Sound"
	adjust_volume_prefs(VOLUME_SFX, "Set the volume for sound effects", 0)

/client/verb/adjust_volume_ambience()
	set name = "Adjust Volume Ambience"
	set category = "Preferences.Sound"
	adjust_volume_prefs(VOLUME_AMB, "Set the volume for ambience and soundscapes", 0)
	soundOutput.update_ambience(null, null, TRUE)

/client/verb/adjust_volume_admin_music()
	set name = "Adjust Volume Admin MIDIs"
	set category = "Preferences.Sound"
	adjust_volume_prefs(VOLUME_ADM, "Set the volume for admin MIDIs", SOUND_CHANNEL_ADMIN_MIDI)

/client/verb/adjust_volume_lobby_music()
	set name = "Adjust Volume LobbyMusic"
	set category = "Preferences.Sound"
	adjust_volume_prefs(VOLUME_LOBBY, "Set the volume for Lobby Music", SOUND_CHANNEL_LOBBY)
