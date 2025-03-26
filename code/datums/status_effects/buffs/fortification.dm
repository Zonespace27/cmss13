/datum/status_effect/fortification
	id = "fortification"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 0 // handled in the proc below
	var/shield_amount = 0
	var/shield_duration = 4 SECONDS

/datum/status_effect/fortification/on_creation(mob/living/carbon/xenomorph/xeno)
	. = ..()
	if(!.)
		return

	var/list/player_list = list()
	SEND_SIGNAL(xeno, COMSIG_MOBA_GET_PLAYER_DATUM, player_list)

	var/datum/moba_player/player = player_list[1]
	switch(player.level)
		if(1 to 4)
			src.duration = 12 SECONDS + shield_duration
		if(5 to 8)
			src.duration = 11 SECONDS + shield_duration
		else
			src.duration = 10 SECONDS + shield_duration

	var/list/bonus_hp_list = list()
	SEND_SIGNAL(xeno, COMSIG_MOBA_GET_BONUS_HP, bonus_hp_list)

	// configure shield amt function here
	src.shield_amount = 45 + (player.level * 15) + (bonus_hp_list[1] * 0.2)
	src.shield_amount *= 1 + (xeno.armor_deflection / 50)

/datum/status_effect/fortification/on_apply()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.add_xeno_shield(shield_amount, XENO_SHIELD_SOURCE_SHIELD_PILLAR, decay_amount_per_second = 0, add_shield_on = TRUE, duration = shield_duration, max_shield = INFINITY) // >:3
	xeno.flick_heal_overlay(1 SECONDS, "#ffa800")
	xeno.xeno_jitter(15)
