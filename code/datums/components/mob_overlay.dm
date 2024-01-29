///The alpha mask used on mobs submerged in liquid turfs
#define MOB_LIQUID_TURF_MASK "mob_liquid_turf_mask"
///The height of the mask itself in the icon state. Changes to the icon requires a change to this define
#define MOB_LIQUID_TURF_MASK_HEIGHT 32
///mob_overlay_effect component. adds and removes
/datum/element/mob_overlay_effect
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/y_offset = 0
	var/mask_y_offset = 0
	var/effect_alpha = 0

/datum/element/mob_overlay_effect/Attach(datum/target, _y_offset, _mask_y_offset, _effect_alpha)
	. = ..()
	y_offset = _y_offset
	mask_y_offset = _mask_y_offset
	effect_alpha = _effect_alpha

	RegisterSignal(get_turf(target), COMSIG_ATOM_EXIT, TYPE_PROC_REF(/datum/element/mob_overlay_effect, on_exit), override = TRUE)
	RegisterSignal(get_turf(target), COMSIG_ATOM_ENTERED, TYPE_PROC_REF(/datum/element/mob_overlay_effect, on_enter), override = TRUE)

/datum/element/mob_overlay_effect/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(get_turf(source), COMSIG_ATOM_EXIT)
	UnregisterSignal(get_turf(source), COMSIG_ATOM_ENTERED)

/datum/element/mob_overlay_effect/proc/on_exit(datum/source, datum/target)
	var/mob/mob = target
	var/icon/mob_icon = icon(mob.icon)
	if(mob.get_filter(MOB_LIQUID_TURF_MASK))
		animate(mob.get_filter(MOB_LIQUID_TURF_MASK), y = ((64 - mob_icon.Height()) * 0.5) - MOB_LIQUID_TURF_MASK_HEIGHT, time = mob.next_move_slowdown)
	animate(mob, pixel_y = mob.pixel_y + y_offset, time = mob.next_move_slowdown, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(mob, TYPE_PROC_REF(/atom, remove_filter), MOB_LIQUID_TURF_MASK), mob.next_move_slowdown)

/datum/element/mob_overlay_effect/proc/on_enter(datum/source, datum/target)
	var/mob/arrived_mob = target
	var/icon/mob_icon = icon(arrived_mob.icon)
	var/height_to_use = (64 - mob_icon.Height()) * 0.5 //gives us the right height based on carbon's icon height relative to the 64 high alpha mask

	if(arrived_mob.get_filter(MOB_LIQUID_TURF_MASK))
		animate(arrived_mob.get_filter(MOB_LIQUID_TURF_MASK), y = ((64 - mob_icon.Height()) * 0.5) - (MOB_LIQUID_TURF_MASK_HEIGHT - mask_y_offset), time = arrived_mob.next_move_slowdown)
		animate(arrived_mob, pixel_y = arrived_mob.pixel_y - y_offset, time = arrived_mob.next_move_slowdown, flags = ANIMATION_PARALLEL)
	else
		//The mask is spawned below the mob, then the animate() raises it up, giving the illusion of dropping into water, combining with the animate to actual drop the pixel_y into the water
		if(effect_alpha)
			arrived_mob.add_filter(MOB_LIQUID_TURF_MASK, 1, alpha_mask_filter(0, height_to_use - MOB_LIQUID_TURF_MASK_HEIGHT, icon('icons/effects/icon_cutter.dmi', "icon_cutter"), null, MASK_INVERSE))
			animate(arrived_mob.get_filter(MOB_LIQUID_TURF_MASK), y = height_to_use - (MOB_LIQUID_TURF_MASK_HEIGHT - mask_y_offset), time = arrived_mob.next_move_slowdown)
		animate(arrived_mob, pixel_y = arrived_mob.pixel_y - y_offset, time = arrived_mob.next_move_slowdown, flags = ANIMATION_PARALLEL)
