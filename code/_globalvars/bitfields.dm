GLOBAL_LIST_INIT(bitfields, generate_bitfields())

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable

	/// An associative list of the readable flag and its true value
	var/list/flags

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

DEFINE_BITFIELD(rights, list(
	"BUILDMODE" = R_BUILDMODE,
	"ADMIN" = R_ADMIN,
	"BAN" = R_BAN,
	"SERVER" = R_SERVER,
	"DEBUG" = R_DEBUG,
	"POSSESS" = R_POSSESS,
	"PERMISSIONS" = R_PERMISSIONS,
	"STEALTH" = R_STEALTH,
	"COLOR" = R_COLOR,
	"VAREDIT" = R_VAREDIT,
	"SOUNDS" = R_SOUNDS,
	"SPAWN" = R_SPAWN,
	"MOD" = R_MOD,
	"MENTOR" = R_MENTOR,
	"HOST" = R_HOST,
	"PROFILER" = R_PROFILER,
	"NOLOCK" = R_NOLOCK,
	"EVENT" = R_EVENT,
))

DEFINE_BITFIELD(appearance_flags, list(
	"KEEP_APART" = KEEP_APART,
	"KEEP_TOGETHER" = KEEP_TOGETHER,
	"LONG_GLIDE" = LONG_GLIDE,
	"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
	"PIXEL_SCALE" = PIXEL_SCALE,
	"PLANE_MASTER" = PLANE_MASTER,
	"RESET_ALPHA" = RESET_ALPHA,
	"RESET_COLOR" = RESET_COLOR,
	"RESET_TRANSFORM" = RESET_TRANSFORM,
	"TILE_BOUND" = TILE_BOUND,
	"PASS_MOUSE" = PASS_MOUSE,
	"TILE_MOVER" = TILE_MOVER,
))

DEFINE_BITFIELD(flags_gun_lever_action, list(
	"USES_STREAKS" = USES_STREAKS,
	"DANGEROUS_TO_ONEHAND_LEVER" = DANGEROUS_TO_ONEHAND_LEVER,
	"MOVES_WHEN_LEVERING" = MOVES_WHEN_LEVERING,
))

// chem_effect_flags
DEFINE_BITFIELD(chem_effect_flags, list(
	"CHEM_EFFECT_RESIST_FRACTURE" = CHEM_EFFECT_RESIST_FRACTURE,
	"CHEM_EFFECT_RESIST_NEURO" = CHEM_EFFECT_RESIST_NEURO,
	"CHEM_EFFECT_HYPER_THROTTLE" = CHEM_EFFECT_HYPER_THROTTLE,
	"CHEM_EFFECT_ORGAN_STASIS" = CHEM_EFFECT_ORGAN_STASIS,
	"CHEM_EFFECT_NO_BLEEDING" = CHEM_EFFECT_NO_BLEEDING,
))

DEFINE_BITFIELD(flags_ammo_behaviour, list(
	"AMMO_EXPLOSIVE" = AMMO_EXPLOSIVE,
	"AMMO_ACIDIC" = AMMO_ACIDIC,
	"AMMO_XENO" = AMMO_XENO,
	"AMMO_LASER" = AMMO_LASER,
	"AMMO_ENERGY" = AMMO_ENERGY,
	"AMMO_ROCKET" = AMMO_ROCKET,
	"AMMO_SNIPER" = AMMO_SNIPER,
	"AMMO_ANTISTRUCT" = AMMO_ANTISTRUCT,
	"AMMO_SKIPS_ALIENS" = AMMO_SKIPS_ALIENS,
	"AMMO_IGNORE_ARMOR" = AMMO_IGNORE_ARMOR,
	"AMMO_IGNORE_RESIST" = AMMO_IGNORE_RESIST,
	"AMMO_BALLISTIC" = AMMO_BALLISTIC,
	"AMMO_IGNORE_COVER" = AMMO_IGNORE_COVER,
	"AMMO_STOPPED_BY_COVER" = AMMO_STOPPED_BY_COVER,
	"AMMO_SPECIAL_EMBED" = AMMO_SPECIAL_EMBED,
	"AMMO_STRIKES_SURFACE" = AMMO_STRIKES_SURFACE,
	"AMMO_HITS_TARGET_TURF" = AMMO_HITS_TARGET_TURF,
	"AMMO_ALWAYS_FF" = AMMO_ALWAYS_FF,
	"AMMO_NO_DEFLECT" = AMMO_NO_DEFLECT,
	"AMMO_MP" = AMMO_MP,
	"AMMO_FLAME" = AMMO_FLAME,
	"AMMO_LEAVE_TURF" = AMMO_LEAVE_TURF,
))

DEFINE_BITFIELD(projectile_flags, list(
	"PROJECTILE_SHRAPNEL" = PROJECTILE_SHRAPNEL,
	"PROJECTILE_BULLSEYE" = PROJECTILE_BULLSEYE,
))

DEFINE_BITFIELD(flags_magazine, list(
	"AMMUNITION_REFILLABLE" = AMMUNITION_REFILLABLE,
	"AMMUNITION_HANDFUL" = AMMUNITION_HANDFUL,
	"AMMUNITION_HANDFUL_BOX" = AMMUNITION_HANDFUL_BOX,
	"AMMUNITION_HIDE_AMMO" = AMMUNITION_HIDE_AMMO,
	"AMMUNITION_CANNOT_REMOVE_BULLETS" = AMMUNITION_CANNOT_REMOVE_BULLETS,
	"AMMUNITION_SLAP_TRANSFER" = AMMUNITION_SLAP_TRANSFER,
))

DEFINE_BITFIELD(disabilities, list(
	"NEARSIGHTED" = NEARSIGHTED,
	"EPILEPSY" = EPILEPSY,
	"COUGHING" = COUGHING,
	"TOURETTES" = TOURETTES,
	"NERVOUS" = NERVOUS,
	"OPIATE_RECEPTOR_DEFICIENCY" = OPIATE_RECEPTOR_DEFICIENCY,
))

DEFINE_BITFIELD(toggles_chat, list(
	"OOC" = CHAT_OOC,
	"DEAD" = CHAT_DEAD,
	"GHOSTEARS" = CHAT_GHOSTEARS,
	"GHOSTSIGHT" = CHAT_GHOSTSIGHT,
	"PRAYER" = CHAT_PRAYER,
	"RADIO" = CHAT_RADIO,
	"ATTACKLOGS" = CHAT_ATTACKLOGS,
	"DEBUGLOGS" = CHAT_DEBUGLOGS,
	"LOOC" = CHAT_LOOC,
	"GHOSTRADIO" = CHAT_GHOSTRADIO,
	"TYPING" = SHOW_TYPING,
	"FFATTACKLOGS" = CHAT_FFATTACKLOGS,
	"GHOSTHIVEMIND" = CHAT_GHOSTHIVEMIND,
	"NICHELOGS" = CHAT_NICHELOGS,
))

DEFINE_BITFIELD(toggles_ghost, list(
	"HEALTH_SCAN" = GHOST_HEALTH_SCAN,
))

DEFINE_BITFIELD(toggles_flashing, list(
	"ROUNDSTART" = FLASH_ROUNDSTART,
	"ROUNDEND" = FLASH_ROUNDEND,
	"CORPSEREVIVE" = FLASH_CORPSEREVIVE,
	"ADMINPM" = FLASH_ADMINPM,
	"UNNEST" = FLASH_UNNEST,
	"POOLSPAWN" = FLASH_POOLSPAWN,
))

DEFINE_BITFIELD(toggles_langchat, list(
	"EMOTES" = LANGCHAT_SEE_EMOTES,
))

DEFINE_BITFIELD(toggles_ert, list(
	"LEADER" = PLAY_LEADER,
	"MEDIC" = PLAY_MEDIC,
	"ENGINEER" = PLAY_ENGINEER,
	"HEAVY" = PLAY_HEAVY,
	"SMARTGUNNER" = PLAY_SMARTGUNNER,
	"SYNTH" = PLAY_SYNTH,
	"MISC" = PLAY_MISC,
))

DEFINE_BITFIELD(toggles_admin, list(
	"ADMIN_TABS" = SPLIT_ADMIN_TABS,
))

DEFINE_BITFIELD(flags_alarm_state, list(
	"WARNING_FIRE" = ALARM_WARNING_FIRE,
	"WARNING_ATMOS" = ALARM_WARNING_ATMOS,
	"WARNING_EVAC" = ALARM_WARNING_EVAC,
	"WARNING_READY" = ALARM_WARNING_READY,
	"WARNING_DOWN" = ALARM_WARNING_DOWN,
	"LOCKDOWN" = ALARM_LOCKDOWN,
))

DEFINE_BITFIELD(perf_flags, list(
	"LAZYSS" = PERF_TOGGLE_LAZYSS,
	"NOBLOODPRINTS" = PERF_TOGGLE_NOBLOODPRINTS,
	"ATTACKLOGS" = PERF_TOGGLE_ATTACKLOGS,
	"SHUTTLES" = PERF_TOGGLE_SHUTTLES,
	"DEFCON" = PERF_TOGGLE_DEFCON,
))

DEFINE_BITFIELD(blood_flags, list(
	"BODY" = BLOOD_BODY,
	"HANDS" = BLOOD_HANDS,
	"FEET" = BLOOD_FEET,
))

DEFINE_BITFIELD(chem_effect_flags, list(
	"RESIST_FRACTURE" = CHEM_EFFECT_RESIST_FRACTURE,
	"RESIST_NEURO" = CHEM_EFFECT_RESIST_NEURO,
	"HYPER_THROTTLE" = CHEM_EFFECT_HYPER_THROTTLE,
	"ORGAN_STASIS" = CHEM_EFFECT_ORGAN_STASIS,
))

DEFINE_BITFIELD(flags_reagent, list(
	"TYPE_MEDICAL" = REAGENT_TYPE_MEDICAL,
	"SCANNABLE" = REAGENT_SCANNABLE,
	"NOT_INGESTIBLE" = REAGENT_NOT_INGESTIBLE,
	"CANNOT_OVERDOSE" = REAGENT_CANNOT_OVERDOSE,
	"TYPE_STIMULANT" = REAGENT_TYPE_STIMULANT,
	"NO_GENERATION" = REAGENT_NO_GENERATION,
))

DEFINE_BITFIELD(protection, list(
	"ENTRY_LOCKED" = CONFIG_ENTRY_LOCKED,
	"ENTRY_HIDDEN" = CONFIG_ENTRY_HIDDEN,
))

DEFINE_BITFIELD(flags_atom, list(
	"NOINTERACT" = NOINTERACT,
	"FPRINT" = FPRINT,
	"CONDUCT" = CONDUCT,
	"ON_BORDER" = ON_BORDER,
	"NOBLOODY" = NOBLOODY,
	"DIRLOCK" = DIRLOCK,
	"NOREACT" = NOREACT,
	"OPENCONTAINER" = OPENCONTAINER,
	"RELAY_CLICK" = RELAY_CLICK,
	"ITEM_UNCATCHABLE" = ITEM_UNCATCHABLE,
	"NO_NAME_OVERRIDE" = NO_NAME_OVERRIDE,
	"NO_SNOW_TYPE" = NO_SNOW_TYPE,
	"INVULNERABLE" = INVULNERABLE,
	"CAN_BE_SYRINGED" = CAN_BE_SYRINGED,
	"CAN_BE_DISPENSED_INTO" = CAN_BE_DISPENSED_INTO,
	"INITIALIZED" = INITIALIZED,
	"ATOM_DECORATED" = ATOM_DECORATED,
	"USES_HEARING" = USES_HEARING,
	"OVERLAY_QUEUED" = OVERLAY_QUEUED,
))

DEFINE_BITFIELD(flags_item, list(
	"NODROP" = NODROP,
	"NOBLUDGEON" = NOBLUDGEON,
	"NOSHIELD" = NOSHIELD,
	"DELONDROP" = DELONDROP,
	"TWOHANDED" = TWOHANDED,
	"WIELDED" = WIELDED,
	"ITEM_ABSTRACT" = ITEM_ABSTRACT,
	"ITEM_PREDATOR" = ITEM_PREDATOR,
	"MOB_LOCK_ON_EQUIP" = MOB_LOCK_ON_EQUIP,
	"NO_CRYO_STORE" = NO_CRYO_STORE,
	"ITEM_OVERRIDE_NORTHFACE" = ITEM_OVERRIDE_NORTHFACE,
	"CAN_DIG_SHRAPNEL" = CAN_DIG_SHRAPNEL,
	"ANIMATED_SURGICAL_TOOL" = ANIMATED_SURGICAL_TOOL,
	"NOTABLEMERGE" = NOTABLEMERGE,
))

DEFINE_BITFIELD(flags_inv_hide, list(
	"HIDEGLOVES" = HIDEGLOVES,
	"HIDESUITSTORAGE" = HIDESUITSTORAGE,
	"HIDEJUMPSUIT" = HIDEJUMPSUIT,
	"HIDESHOES" = HIDESHOES,
	"HIDEMASK" = HIDEMASK,
	"HIDEEARS" = HIDEEARS,
	"HIDEEYES" = HIDEEYES,
	"HIDELOWHAIR" = HIDELOWHAIR,
	"HIDETOPHAIR" = HIDETOPHAIR,
	"HIDEALLHAIR" = HIDEALLHAIR,
	"HIDETAIL" = HIDETAIL,
	"HIDEFACE" = HIDEFACE,
))

DEFINE_BITFIELD(flags_inventory, list(
	"CANTSTRIP" = CANTSTRIP,
	"NOSLIPPING" = NOSLIPPING,
	"COVEREYES" = COVEREYES,
	"COVERMOUTH" = COVERMOUTH,
	"ALLOWINTERNALS" = ALLOWINTERNALS,
	"ALLOWREBREATH" = ALLOWREBREATH,
	"BLOCKGASEFFECT" = BLOCKGASEFFECT,
	"ALLOWCPR" = ALLOWCPR,
	"FULL_DECAP_PROTECTION" = FULL_DECAP_PROTECTION,
	"BLOCKSHARPOBJ" = BLOCKSHARPOBJ,
	"NOPRESSUREDMAGE" = NOPRESSUREDMAGE,
	"BLOCK_KNOCKDOWN" = BLOCK_KNOCKDOWN,
	"SMARTGUN_HARNESS" = SMARTGUN_HARNESS,
))

DEFINE_BITFIELD(flags_jumpsuit, list(
	"SLEEVE_ROLLABLE" = UNIFORM_SLEEVE_ROLLABLE,
	"SLEEVE_ROLLED" = UNIFORM_SLEEVE_ROLLED,
	"SLEEVE_CUTTABLE" = UNIFORM_SLEEVE_CUTTABLE,
	"SLEEVE_CUT" = UNIFORM_SLEEVE_CUT,
	"JACKET_REMOVABLE" = UNIFORM_JACKET_REMOVABLE,
	"JACKET_REMOVED" = UNIFORM_JACKET_REMOVED,
	"DO_NOT_HIDE_ACCESSORIES" = UNIFORM_DO_NOT_HIDE_ACCESSORIES,
))

DEFINE_BITFIELD(flags_marine_helmet, list(
	"SQUAD_OVERLAY" = HELMET_SQUAD_OVERLAY,
	"GARB_OVERLAY" = HELMET_GARB_OVERLAY,
	"DAMAGE_OVERLAY" = HELMET_DAMAGE_OVERLAY,
	"IS_DAMAGED" = HELMET_IS_DAMAGED,
))

DEFINE_BITFIELD(flags_marine_hat, list(
	"GARB_OVERLAY" = HAT_GARB_OVERLAY,
	"CAN_FLIP" = HAT_CAN_FLIP,
	"FLIPPED" = HAT_FLIPPED,
))

DEFINE_BITFIELD(valid_equip_slots, list(
	"SLOT_OCLOTHING" = SLOT_OCLOTHING,
	"SLOT_ICLOTHING" = SLOT_ICLOTHING,
	"SLOT_HANDS" = SLOT_HANDS,
	"SLOT_EYES" = SLOT_EYES,
	"SLOT_EAR" = SLOT_EAR,
	"SLOT_FACE" = SLOT_FACE,
	"SLOT_HEAD" = SLOT_HEAD,
	"SLOT_FEET" = SLOT_FEET,
	"SLOT_ID" = SLOT_ID,
	"SLOT_WAIST" = SLOT_WAIST,
	"SLOT_BACK" = SLOT_BACK,
	"SLOT_STORE" = SLOT_STORE,
	"SLOT_NO_STORE" = SLOT_NO_STORE,
	"SLOT_LEGS" = SLOT_LEGS,
	"SLOT_ACCESSORY" = SLOT_ACCESSORY,
	"SLOT_SUIT_STORE" = SLOT_SUIT_STORE,
	"SLOT_BLOCK_SUIT_STORE" = SLOT_BLOCK_SUIT_STORE,
))

#define BODYPARTS list(\
	"FLAG_HEAD" = BODY_FLAG_HEAD,\
	"FLAG_FACE" = BODY_FLAG_FACE,\
	"FLAG_EYES" = BODY_FLAG_EYES,\
	"FLAG_CHEST" = BODY_FLAG_CHEST,\
	"FLAG_GROIN" = BODY_FLAG_GROIN,\
	"FLAG_LEG_LEFT" = BODY_FLAG_LEG_LEFT,\
	"FLAG_LEG_RIGHT" = BODY_FLAG_LEG_RIGHT,\
	"FLAG_FOOT_LEFT" = BODY_FLAG_FOOT_LEFT,\
	"FLAG_FOOT_RIGHT" = BODY_FLAG_FOOT_RIGHT,\
	"FLAG_ARM_LEFT" = BODY_FLAG_ARM_LEFT,\
	"FLAG_ARM_RIGHT" = BODY_FLAG_ARM_RIGHT,\
	"FLAG_HAND_LEFT" = BODY_FLAG_HAND_LEFT,\
	"FLAG_HAND_RIGHT" = BODY_FLAG_HAND_RIGHT,\
)

DEFINE_BITFIELD(flags_armor_protection, BODYPARTS)

DEFINE_BITFIELD(flags_cold_protection, BODYPARTS)

DEFINE_BITFIELD(flags_heat_protection, BODYPARTS)

DEFINE_BITFIELD(body_part, BODYPARTS)

DEFINE_BITFIELD(storage_flags, list(
	"ALLOW_EMPTY" = STORAGE_ALLOW_EMPTY,
	"QUICK_EMPTY" = STORAGE_QUICK_EMPTY,
	"QUICK_GATHER" = STORAGE_QUICK_GATHER,
	"ALLOW_DRAWING_METHOD_TOGGLE" = STORAGE_ALLOW_DRAWING_METHOD_TOGGLE,
	"USING_DRAWING_METHOD" = STORAGE_USING_DRAWING_METHOD,
	"USING_FIFO_DRAWING" = STORAGE_USING_FIFO_DRAWING,
	"CLICK_EMPTY" = STORAGE_CLICK_EMPTY,
	"CLICK_GATHER" = STORAGE_CLICK_GATHER,
	"SHOW_FULLNESS" = STORAGE_SHOW_FULLNESS,
	"CONTENT_NUM_DISPLAY" = STORAGE_CONTENT_NUM_DISPLAY,
	"GATHER_SIMULTAENOUSLY" = STORAGE_GATHER_SIMULTAENOUSLY,
	"ALLOW_QUICKDRAW" = STORAGE_ALLOW_QUICKDRAW,
))

DEFINE_BITFIELD(ignite_flags, list(
	"FAILED" = IGNITE_FAILED,
	"ON_FIRE" = IGNITE_ON_FIRE,
	"IGNITED" = IGNITE_IGNITED,
))

DEFINE_BITFIELD(datum_flags, list(
	"USE_TAG" = DF_USE_TAG,
	"VAR_EDITED" = DF_VAR_EDITED,
	"ISPROCESSING" = DF_ISPROCESSING,
))

DEFINE_BITFIELD(flags_gun_features, list(
	"GUN_CAN_POINTBLANK" = GUN_CAN_POINTBLANK,
	"GUN_TRIGGER_SAFETY" = GUN_TRIGGER_SAFETY,
	"GUN_UNUSUAL_DESIGN" = GUN_UNUSUAL_DESIGN,
	"GUN_SILENCED" = GUN_SILENCED,
	"GUN_AUTOMATIC" = GUN_AUTOMATIC,
	"GUN_INTERNAL_MAG" = GUN_INTERNAL_MAG,
	"GUN_AUTO_EJECTOR" = GUN_AUTO_EJECTOR,
	"GUN_AMMO_COUNTER" = GUN_AMMO_COUNTER,
	"GUN_BURST_FIRING" = GUN_BURST_FIRING,
	"GUN_FLASHLIGHT_ON" = GUN_FLASHLIGHT_ON,
	"GUN_WY_RESTRICTED" = GUN_WY_RESTRICTED,
	"GUN_CO_RESTRICTED" = GUN_CO_RESTRICTED,
	"GUN_SPECIALIST" = GUN_SPECIALIST,
	"GUN_WIELDED_FIRING_ONLY" = GUN_WIELDED_FIRING_ONLY,
	"GUN_HAS_FULL_AUTO" = GUN_HAS_FULL_AUTO,
	"GUN_FULL_AUTO_ON" = GUN_FULL_AUTO_ON,
	"GUN_ONE_HAND_WIELDED" = GUN_ONE_HAND_WIELDED,
	"GUN_ANTIQUE" = GUN_ANTIQUE,
	"GUN_RECOIL_BUILDUP" = GUN_RECOIL_BUILDUP,
	"GUN_SUPPORT_PLATFORM" = GUN_SUPPORT_PLATFORM,
	"GUN_FULL_AUTO_ONLY" = GUN_FULL_AUTO_ONLY,
	"GUN_NO_DESCRIPTION" = GUN_NO_DESCRIPTION,
))

DEFINE_BITFIELD(flags_mounted_gun_features, list(
	"MOUNTING" = GUN_MOUNTING,
	"MOUNTED" = GUN_MOUNTED,
	"CAN_OVERRIDE_MOUNTED" = GUN_CAN_OVERRIDE_MOUNTED,
))

DEFINE_BITFIELD(status, list(
	"ORGANIC" = LIMB_ORGANIC,
	"ROBOT" = LIMB_ROBOT,
	"SYNTHSKIN" = LIMB_SYNTHSKIN,
	"BROKEN" = LIMB_BROKEN,
	"DESTROYED" = LIMB_DESTROYED,
	"SPLINTED" = LIMB_SPLINTED,
	"MUTATED" = LIMB_MUTATED,
	"AMPUTATED" = LIMB_AMPUTATED,
	"SPLINTED_INDESTRUCTIBLE" = LIMB_SPLINTED_INDESTRUCTIBLE,
	"UNCALIBRATED_PROSTHETIC" = LIMB_UNCALIBRATED_PROSTHETIC,
))

DEFINE_BITFIELD(salved, list(
	"BANDAGED" = WOUND_BANDAGED,
	"SUTURED" = WOUND_SUTURED,
))

DEFINE_BITFIELD(added_sutures, list(
	"SUTURED" = SUTURED,
	"SUTURED_FULLY" = SUTURED_FULLY,
))

DEFINE_BITFIELD(flags_area, list(
	"AREA_AVOID_BIOSCAN" = AREA_AVOID_BIOSCAN,
	"AREA_NOTUNNEL" = AREA_NOTUNNEL,
	"AREA_ALLOW_XENO_JOIN" = AREA_ALLOW_XENO_JOIN,
	"AREA_CONTAINMENT" = AREA_CONTAINMENT,
	"AREA_RECOVER_CORPSES" = AREA_RECOVER_CORPSES,
	"AREA_RECOVER_ITEMS" = AREA_RECOVER_ITEMS,
	"AREA_RECOVER_FULTON_ITEMS" = AREA_RECOVER_FULTON_ITEMS,
	"ARES_UNWEEDABLE" = AREA_UNWEEDABLE,
))

DEFINE_BITFIELD(initial_sound_flags, list(
	"FRONT_CLOSE_ONLY" = FRONT_CLOSE_ONLY,
	"SIMPLE_U_ONLY" = SIMPLE_U_ONLY,
	"HALF_U" = HALF_U,
	"NO_FRONT_CLOSE" = NO_FRONT_CLOSE,
	"SIMPLIFY_UO" = SIMPLIFY_UO,
	"NO_E_ONG" = NO_E_ONG,
	"DENTAL_ALV" = DENTAL_ALV,
	"NONDENTAL_ALV" = NONDENTAL_ALV,
	"NO_SYLLABIC_I" = NO_SYLLABIC_I,
	"ZERO_INITIAL" = ZERO_INITIAL,
))

DEFINE_BITFIELD(final_syllable_sound_flags, list(
	"GROUP_FULL" = U_GROUP_FULL,
	"UMLAUT" = U_UMLAUT,
	"UMLAUT_RARE" = U_UMLAUT_RARE,
))

DEFINE_BITFIELD(flags_tacmap, list(
	"INVISIBLY_OV" = TCMP_INVISIBLY_OV,
	"INTERACTIVE_MENU" = TCMP_INTERACTIVE_MENU,
	"ADDITIONAL_OVERLAYS" = TCMP_ADDITIONAL_OVERLAYS,
	"CUSTOM_COLOR" = TCMP_CUSTOM_COLOR,
	"VIBISLY_TO_EVRYONE" = TCMP_VIBISLY_TO_EVRYONE,
))

DEFINE_BITFIELD(droppod_flags, list(
	"DROPPED" = DROPPOD_DROPPED,
	"DROPPING" = DROPPOD_DROPPING,
	"OPEN" = DROPPOD_OPEN,
	"STRIPPED" = DROPPOD_STRIPPED,
	"RETURNING" = DROPPOD_RETURNING,
))

DEFINE_BITFIELD(interrupt_flags, list(
	"NONE" = INTERRUPT_NONE,
	"DIFF_LOC" = INTERRUPT_DIFF_LOC,
	"DIFF_TURF" = INTERRUPT_DIFF_TURF,
	"UNCONSCIOUS" = INTERRUPT_UNCONSCIOUS,
	"KNOCKED_DOWN" = INTERRUPT_KNOCKED_DOWN,
	"STUNNED" = INTERRUPT_STUNNED,
	"NEEDHAND" = INTERRUPT_NEEDHAND,
	"RESIST" = INTERRUPT_RESIST,
	"DIFF_SELECT_ZONE" = INTERRUPT_DIFF_SELECT_ZONE,
	"OUT_OF_RANGE" = INTERRUPT_OUT_OF_RANGE,
	"DIFF_INTENT" = INTERRUPT_DIFF_INTENT,
	"LCLICK" = INTERRUPT_LCLICK,
	"RCLICK" = INTERRUPT_RCLICK,
	"SHIFTCLICK" = INTERRUPT_SHIFTCLICK,
	"ALTCLICK" = INTERRUPT_ALTCLICK,
	"CTRLCLICK" = INTERRUPT_CTRLCLICK,
	"MIDDLECLICK" = INTERRUPT_MIDDLECLICK,
	"DAZED" = INTERRUPT_DAZED,
	"EMOTE" = INTERRUPT_EMOTE,
	"CHANGED_LYING" = INTERRUPT_CHANGED_LYING,
))

DEFINE_BITFIELD(sdisabilities, list(
	"BLIND" = DISABILITY_BLIND,
	"MUTE" = DISABILITY_MUTE,
	"DEAF" = DISABILITY_DEAF,
))

DEFINE_BITFIELD(flags_morale, list(
	"FLAG_NO_AUTO_CAP" = MORALE_FLAG_NO_AUTO_CAP,
	"FLAG_NO_SELF_CAP" = MORALE_FLAG_NO_SELF_CAP,
))

DEFINE_BITFIELD(status_flags, list(
	"CANSTUN" = CANSTUN,
	"CANKNOCKDOWN" = CANKNOCKDOWN,
	"CANKNOCKOUT" = CANKNOCKOUT,
	"CANPUSH" = CANPUSH,
	"LEAPING" = LEAPING,
	"PASSEMOTES" = PASSEMOTES,
	"GODMODE" = GODMODE,
	"FAKEDEATH" = FAKEDEATH,
	"DISFIGURED" = DISFIGURED,
	"XENO_HOST" = XENO_HOST,
	"IMMOBILE_ACTION" = IMMOBILE_ACTION,
	"PERMANENTLY_DEAD" = PERMANENTLY_DEAD,
	"CANDAZE" = CANDAZE,
	"CANSLOW" = CANSLOW,
	"NO_PERMANENT_DAMAGE" = NO_PERMANENT_DAMAGE,
))

DEFINE_BITFIELD(mob_flags, list(
	"KNOWS_TECHNOLOGY" = KNOWS_TECHNOLOGY,
	"SQUEEZE_UNDER_VEHICLES" = SQUEEZE_UNDER_VEHICLES,
	"EASY_SURGERY" = EASY_SURGERY,
	"SURGERY_MODE_ON" = SURGERY_MODE_ON,
	"MUTINEER" = MUTINEER,
	"GIVING" = GIVING,
	"NOBIOSCAN" = NOBIOSCAN,
))

DEFINE_BITFIELD(species_flags, list(
	"NO_BLOOD" = NO_BLOOD,
	"NO_BREATHE" = NO_BREATHE,
	"NO_CLONE_LOSS" = NO_CLONE_LOSS,
	"NO_SLIP" = NO_SLIP,
	"NO_POISON" = NO_POISON,
	"NO_CHEM_METABOLIZATION" = NO_CHEM_METABOLIZATION,
	"HAS_SKIN_TONE" = HAS_SKIN_TONE,
	"HAS_SKIN_COLOR" = HAS_SKIN_COLOR,
	"HAS_LIPS" = HAS_LIPS,
	"HAS_UNDERWEAR" = HAS_UNDERWEAR,
	"IS_WHITELISTED" = IS_WHITELISTED,
	"IS_SYNTHETIC" = IS_SYNTHETIC,
	"NO_NEURO" = NO_NEURO,
	"SPECIAL_BONEBREAK" = SPECIAL_BONEBREAK,
	"NO_SHRAPNEL" = NO_SHRAPNEL,
	"HAS_HARDCRIT" = HAS_HARDCRIT,
))

DEFINE_BITFIELD(flags_round_type, list(
	"INFESTATION" = MODE_INFESTATION,
	"PREDATOR" = MODE_PREDATOR,
	"NO_LATEJOIN" = MODE_NO_LATEJOIN,
	"HAS_FINISHED" = MODE_HAS_FINISHED,
	"FOG_ACTIVATED" = MODE_FOG_ACTIVATED,
	"INFECTION" = MODE_INFECTION,
	"HUMAN_ANTAGS" = MODE_HUMAN_ANTAGS,
	"NO_SPAWN" = MODE_NO_SPAWN,
	"XVX" = MODE_XVX,
	"NEW_SPAWN" = MODE_NEW_SPAWN,
	"DS_LANDED" = MODE_DS_LANDED,
	"BASIC_RT" = MODE_BASIC_RT,
	"RANDOM_HIVE" = MODE_RANDOM_HIVE,
	"HVH_BALANCE" = MODE_HVH_BALANCE,
	"NO_SHIP_MAP" = MODE_NO_SHIP_MAP,
	"HARDCORE" = MODE_HARDCORE,
))

DEFINE_BITFIELD(toggleable_flags, list(
	"NO_SNIPER_SENTRY" = MODE_NO_SNIPER_SENTRY,
	"NO_ATTACK_DEAD" = MODE_NO_ATTACK_DEAD,
	"NO_STRIPDRAG_ENEMY" = MODE_NO_STRIPDRAG_ENEMY,
	"STRIP_NONUNIFORM_ENEMY" = MODE_STRIP_NONUNIFORM_ENEMY,
	"STRONG_DEFIBS" = MODE_STRONG_DEFIBS,
	"BLOOD_OPTIMIZATION" = MODE_BLOOD_OPTIMIZATION,
	"NO_COMBAT_CAS" = MODE_NO_COMBAT_CAS,
	"LZ_PROTECTION" = MODE_LZ_PROTECTION,
	"MODE_SHIPSIDE_SD" = MODE_SHIPSIDE_SD,
	"MODE_DISPOSABLE_MOBS" = MODE_DISPOSABLE_MOBS,
	"MODE_BYPASS_JOE" = MODE_BYPASS_JOE,
))

DEFINE_BITFIELD(toggle_prefs, list(
	"IGNORE_SELF" = TOGGLE_IGNORE_SELF,
	"HELP_INTENT_SAFETY" = TOGGLE_HELP_INTENT_SAFETY,
	"MIDDLE_MOUSE_CLICK" = TOGGLE_MIDDLE_MOUSE_CLICK,
	"DIRECTIONAL_ATTACK" = TOGGLE_DIRECTIONAL_ATTACK,
	"AUTO_EJECT_MAGAZINE_OFF" = TOGGLE_AUTO_EJECT_MAGAZINE_OFF,
	"AUTO_EJECT_MAGAZINE_TO_HAND" = TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND,
	"EJECT_MAGAZINE_TO_HAND" = TOGGLE_EJECT_MAGAZINE_TO_HAND,
	"AUTOMATIC_PUNCTUATIONDD" = TOGGLE_AUTOMATIC_PUNCTUATION,
	"COMBAT_CLICKDRAG_OVERRIDE" = TOGGLE_COMBAT_CLICKDRAG_OVERRIDE,
	"ALTERNATING_DUAL_WIELD" = TOGGLE_ALTERNATING_DUAL_WIELD,
	"GUN_AMMO_COUNTER" = TOGGLE_GUN_AMMO_COUNTER,
	"FULLSCREEN" = TOGGLE_FULLSCREEN,
	"MEMBER_PUBLIC" = TOGGLE_MEMBER_PUBLIC,
	"OOC_FLAG" = TOGGLE_OOC_FLAG,
	"MIDDLE_MOUSE_SWAP_HANDS" = TOGGLE_MIDDLE_MOUSE_SWAP_HANDS,
	"AMBIENT_OCCLUSION" = TOGGLE_AMBIENT_OCCLUSION,
))

DEFINE_BITFIELD(whitelist_flags, list(
	"YAUTJA" = WHITELIST_YAUTJA,
	"YAUTJA_LEGACY" = WHITELIST_YAUTJA_LEGACY,
	"YAUTJA_COUNCIL" = WHITELIST_YAUTJA_COUNCIL,
	"YAUTJA_COUNCIL_LEGACY" = WHITELIST_YAUTJA_COUNCIL_LEGACY,
	"YAUTJA_LEADER" = WHITELIST_YAUTJA_LEADER,
	"COMMANDER" = WHITELIST_COMMANDER,
	"COMMANDER_COUNCIL" = WHITELIST_COMMANDER_COUNCIL,
	"COMMANDER_COUNCIL_LEGACY" = WHITELIST_COMMANDER_COUNCIL_LEGACY,
	"COMMANDER_LEADER" = WHITELIST_COMMANDER_LEADER,
	"SYNTHETIC" = WHITELIST_SYNTHETIC,
	"SYNTHETIC_COUNCIL" = WHITELIST_SYNTHETIC_COUNCIL,
	"SYNTHETIC_COUNCIL_LEGACY" = WHITELIST_SYNTHETIC_COUNCIL_LEGACY,
	"SYNTHETIC_LEADER" = WHITELIST_SYNTHETIC_LEADER,
	"MENTOR" = WHITELIST_MENTOR,
))

DEFINE_BITFIELD(objective_state, list(
	"INACTIVE" = OBJECTIVE_INACTIVE,
	"ACTIVE" = OBJECTIVE_ACTIVE,
	"WORKING" = OBJECTIVE_IN_PROGRESS,
	"COMPLETE" = OBJECTIVE_COMPLETE,
	"FAILED" = OBJECTIVE_FAILED,
))

DEFINE_BITFIELD(objective_flags, list(
	"DO_NOT_TREE" = OBJECTIVE_DO_NOT_TREE,
	"DEAD_END" = OBJECTIVE_DEAD_END,
	"START_PROCESSING_ON_DISCOVERY" = OBJECTIVE_START_PROCESSING_ON_DISCOVERY,
	"DISPLAY_AT_END" = OBJECTIVE_DISPLAY_AT_END,
	"OBSERVABLE" = OBJECTIVE_OBSERVABLE,
))

DEFINE_BITFIELD(flags_can_pass_all, list(
	"PASS_THROUGH" = PASS_THROUGH,
	"PASS_AROUND" = PASS_AROUND,
	"PASS_OVER_THROW_ITEM" = PASS_OVER_THROW_ITEM,
	"PASS_OVER_THROW_MOB" = PASS_OVER_THROW_MOB,
	"PASS_OVER_FIRE" = PASS_OVER_FIRE,
	"PASS_OVER_ACID_SPRAY" = PASS_OVER_ACID_SPRAY,
	"PASS_UNDER" = PASS_UNDER,
	"PASS_GLASS" = PASS_GLASS,
	"PASS_MOB_IS_XENO" = PASS_MOB_IS_XENO,
	"PASS_MOB_IS_HUMAN" = PASS_MOB_IS_HUMAN,
	"PASS_MOB_IS_OTHER" = PASS_MOB_IS_OTHER,
	"PASS_MOB_THRU_XENO" = PASS_MOB_THRU_XENO,
	"PASS_MOB_THRU_HUMAN" = PASS_MOB_THRU_HUMAN,
	"PASS_MOB_THRU_OTHER" = PASS_MOB_THRU_OTHER,
	"PASS_TYPE_CRAWLER" = PASS_TYPE_CRAWLER,
	"PASS_HIGH_OVER_ONLY" = PASS_HIGH_OVER_ONLY,
	"PASS_BUILDING_ONLY" = PASS_BUILDING_ONLY,
	"PASS_CRUSHER_CHARGE" = PASS_CRUSHER_CHARGE,
))

DEFINE_BITFIELD(flags_pass, list(
	"PASS_THROUGH" = PASS_THROUGH,
	"PASS_AROUND" = PASS_AROUND,
	"PASS_OVER_THROW_ITEM" = PASS_OVER_THROW_ITEM,
	"PASS_OVER_THROW_MOB" = PASS_OVER_THROW_MOB,
	"PASS_OVER_FIRE" = PASS_OVER_FIRE,
	"PASS_OVER_ACID_SPRAY" = PASS_OVER_ACID_SPRAY,
	"PASS_UNDER" = PASS_UNDER,
	"PASS_GLASS" = PASS_GLASS,
	"PASS_MOB_IS_XENO" = PASS_MOB_IS_XENO,
	"PASS_MOB_IS_HUMAN" = PASS_MOB_IS_HUMAN,
	"PASS_MOB_IS_OTHER" = PASS_MOB_IS_OTHER,
	"PASS_MOB_THRU_XENO" = PASS_MOB_THRU_XENO,
	"PASS_MOB_THRU_HUMAN" = PASS_MOB_THRU_HUMAN,
	"PASS_MOB_THRU_OTHER" = PASS_MOB_THRU_OTHER,
	"PASS_TYPE_CRAWLER" = PASS_TYPE_CRAWLER,
	"PASS_HIGH_OVER_ONLY" = PASS_HIGH_OVER_ONLY,
	"PASS_BUILDING_ONLY" = PASS_BUILDING_ONLY,
	"PASS_CRUSHER_CHARGE" = PASS_CRUSHER_CHARGE,
))

DEFINE_BITFIELD(flags_fall, list(
	"INTERCEPTED" = FALL_INTERCEPTED,
	"NO_MESSAGE" = FALL_NO_MESSAGE,
	"STOP_INTERCEPTING" = FALL_STOP_INTERCEPTING,
	"RETAIN_PULL" = FALL_RETAIN_PULL,
))

DEFINE_BITFIELD(z_move_flags, list(
	"CHECK_PULLING" = ZMOVE_CHECK_PULLING,
	"CHECK_PULLEDBY" = ZMOVE_CHECK_PULLEDBY,
	"FALL_CHECKS" = ZMOVE_FALL_CHECKS,
	"CAN_FLY_CHECKS" = ZMOVE_CAN_FLY_CHECKS,
	"INCAPACITATED_CHECKS" = ZMOVE_INCAPACITATED_CHECKS,
	"IGNORE_OBSTACLES" = ZMOVE_IGNORE_OBSTACLES,
	"FEEDBACK" = ZMOVE_FEEDBACK,
	"ALLOW_BUCKLED" = ZMOVE_ALLOW_BUCKLED,
	"VENTCRAWLING" = ZMOVE_VENTCRAWLING,
	"INCLUDE_PULLED" = ZMOVE_INCLUDE_PULLED,
	"ALLOW_ANCHORED" = ZMOVE_ALLOW_ANCHORED,
))
DEFINE_BITFIELD(nightmare_flags, list(
	"TASKFLAG_DISABLED" = NIGHTMARE_TASKFLAG_DISABLED,
	"TASKFLAG_ONESHOT" = NIGHTMARE_TASKFLAG_ONESHOT,
))

DEFINE_BITFIELD(stack_flags, list(
	"RESULT_REQUIRES_SNOW" = RESULT_REQUIRES_SNOW,
))

DEFINE_BITFIELD(flags_obj, list(
	"ORGANIC" = OBJ_ORGANIC,
	"NO_HELMET_BAND" = OBJ_NO_HELMET_BAND,
	"IS_HELMET_GARB" = OBJ_IS_HELMET_GARB,
	"BLOCK_Z_OUT_DOWN" = OBJ_BLOCK_Z_OUT_DOWN,
	"BLOCK_Z_OUT_UP" = OBJ_BLOCK_Z_OUT_UP,
	"BLOCK_Z_IN_DOWN" = OBJ_BLOCK_Z_IN_DOWN,
	"BLOCK_Z_IN_UP" = OBJ_BLOCK_Z_IN_UP,
))

DEFINE_BITFIELD(shuttle_flags, list(
	"GAMEMODE_IMMUNE" = GAMEMODE_IMMUNE,
))

DEFINE_BITFIELD(docking_flags, list(
	"BLOCKED" = DOCKING_BLOCKED,
	"IMMOBILIZED" = DOCKING_IMMOBILIZED,
	"AREA_EMPTY" = DOCKING_AREA_EMPTY,
	"NULL_DESTINATION" = DOCKING_NULL_DESTINATION,
	"NULL_SOURCE" = DOCKING_NULL_SOURCE,
))

DEFINE_BITFIELD(timer_flags, list(
	"UNIQUE" = TIMER_UNIQUE,
	"OVERRIDE" = TIMER_OVERRIDE,
	"CLIENT_TIME" = TIMER_CLIENT_TIME,
	"STOPPABLE" = TIMER_STOPPABLE,
	"NO_HASH_WAIT" = TIMER_NO_HASH_WAIT,
	"LOOP" = TIMER_LOOP,
))

DEFINE_BITFIELD(gen_flags_turf, list(
	"DEFER_CHANGE" = CHANGETURF_DEFER_CHANGE,
	"IGNORE_AIR" = CHANGETURF_IGNORE_AIR,
	"FORCEOP" = CHANGETURF_FORCEOP,
	"SKIP" = CHANGETURF_SKIP,
))

DEFINE_BITFIELD(turf_flags, list(
	"DEBRISED" = TURF_DEBRISED,
	"WEATHER" = TURF_WEATHER,
	"MULTIZ" = TURF_MULTIZ,
	"TRENCHING" = TURF_TRENCHING,
	"TRENCH" = TURF_TRENCH,
	"ORGANIC" = TURF_ORGANIC,
	"NOJAUNT" = TURF_NOJAUNT,
	"TURF_UNUSED_RESERVATION" = TURF_UNUSED_RESERVATION,
	"CAN_BE_DIRTY" = TURF_CAN_BE_DIRTY,
))

DEFINE_BITFIELD(tool_flags, list(
	"REMOVE_CROWBAR" = REMOVE_CROWBAR,
	"BREAK_CROWBAR" = BREAK_CROWBAR,
	"REMOVE_SCREWDRIVER" = REMOVE_SCREWDRIVER,
))

DEFINE_BITFIELD(vehicle_flags, list(
	"TOGGLE_SHIFT_CLICK_GUNNER" = VEHICLE_TOGGLE_SHIFT_CLICK_GUNNER,
	"CLASS_WEAK" = VEHICLE_CLASS_WEAK,
	"CLASS_LIGHT" = VEHICLE_CLASS_LIGHT,
	"CLASS_MEDIIUM" = VEHICLE_CLASS_MEDIUM,
	"CLASS_HEAVY" = VEHICLE_CLASS_HEAVY,
))
	//heavy class armor (tank)
DEFINE_BITFIELD(buy_flags, list(
	"UNIFORM" = VENDOR_CAN_BUY_UNIFORM,
	"SHOES" = VENDOR_CAN_BUY_SHOES,
	"HELMET" = VENDOR_CAN_BUY_HELMET,
	"ARMOR" = VENDOR_CAN_BUY_ARMOR,
	"GLOVES" = VENDOR_CAN_BUY_GLOVES,
	"EAR" = VENDOR_CAN_BUY_EAR,
	"BACKPACK" = VENDOR_CAN_BUY_BACKPACK,
	"POUCH" = VENDOR_CAN_BUY_POUCH,
	"BELT" = VENDOR_CAN_BUY_BELT,
	"GLASSES" = VENDOR_CAN_BUY_GLASSES,
	"MASK" = VENDOR_CAN_BUY_MASK,
	"ESSENTIALS" = VENDOR_CAN_BUY_ESSENTIALS,
	"SECONDARY" = VENDOR_CAN_BUY_SECONDARY,
	"ATTACHMENT" = VENDOR_CAN_BUY_ATTACHMENT,
	"MRE" = VENDOR_CAN_BUY_MRE,
	"ACCESSORY" = VENDOR_CAN_BUY_ACCESSORY,
	"COMBAT_SHOES" = VENDOR_CAN_BUY_COMBAT_SHOES,
	"COMBAT_HELMET" = VENDOR_CAN_BUY_COMBAT_HELMET,
	"COMBAT_ARMOR" = VENDOR_CAN_BUY_COMBAT_ARMOR,
	"KIT" = VENDOR_CAN_BUY_KIT,
))

DEFINE_BITFIELD(type_used_points, list(
	"BASE_POINTS" = USING_BASE_POINTS,
	"SNOWFLAKE_POINTS" = USING_SNOWFLAKE_POINTS,
	"AMMUNITION_POINTS" = USING_AMMUNITION_POINTS,
))

DEFINE_BITFIELD(available_categories, list(
	"INTEGRAL_AVAILABLE" = VEHICLE_INTEGRAL_AVAILABLE,
	"PRIMARY_AVAILABLE" = VEHICLE_PRIMARY_AVAILABLE,
	"SECONDARY_AVAILABLE" = VEHICLE_SECONDARY_AVAILABLE,
	"SUPPORT_AVAILABLE" = VEHICLE_SUPPORT_AVAILABLE,
	"ARMOR_AVAILABLE" = VEHICLE_ARMOR_AVAILABLE,
	"TREADS_AVAILABLE" = VEHICLE_TREADS_AVAILABLE,
))

DEFINE_BITFIELD(fire_immunity, list(
	"NO_DAMAGE" = FIRE_IMMUNITY_NO_DAMAGE,
	"NO_IGNITE" = FIRE_IMMUNITY_NO_IGNITE,
	"XENO_FRENZY" = FIRE_IMMUNITY_XENO_FRENZY,
))

DEFINE_BITFIELD(sight, list(
	"BLIND" = BLIND,
	"SEE_BLACKNESS" = SEE_BLACKNESS,
	"SEE_INFRA" = SEE_INFRA,
	"SEE_MOBS" = SEE_MOBS,
	"SEE_OBJS" = SEE_OBJS,
	"SEE_PIXELS" = SEE_PIXELS,
	"SEE_SELF" = SEE_SELF,
	"SEE_THRU" = SEE_THRU,
	"SEE_TURFS" = SEE_TURFS,
))

DEFINE_BITFIELD(vision_flags, list(
	"VIS_HIDE" = VIS_HIDE,
	"VIS_INHERIT_DIR" = VIS_INHERIT_DIR,
	"VIS_INHERIT_ICON" = VIS_INHERIT_ICON,
	"VIS_INHERIT_ICON_STATE" = VIS_INHERIT_ICON_STATE,
	"VIS_INHERIT_ID" = VIS_INHERIT_ID,
	"VIS_INHERIT_LAYER" = VIS_INHERIT_LAYER,
	"VIS_INHERIT_PLANE" = VIS_INHERIT_PLANE,
	"VIS_UNDERLAY" = VIS_UNDERLAY,
))
