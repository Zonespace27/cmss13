SUBSYSTEM_DEF(moba)
	name = "Heroes of the League of Xenomorphs 2"
	wait = 2 SECONDS
	flags = SS_KEEP_TIMING
	priority = SS_PRIORITY_MOBA

	var/list/datum/moba_controller/controllers = list()
	var/list/datum/moba_controller/controller_id_dict = list()

	var/list/datum/moba_controller/current_run

	var/list/datum/moba_player/players_in_queue = list()
	COOLDOWN_DECLARE(matchmaking_cooldown)

	var/current_highest_map_id = 1

	// Add a list of unused maps here using /datum/unused_moba_map
	var/list/datum/unused_moba_map/unused_maps = list()

	var/list/datum/moba_item/items = list()
	var/list/datum/moba_item/item_dict = list()

	/// I'd like to avoid any weirdness so I have this
	var/currently_creating_map = FALSE

/datum/controller/subsystem/moba/Initialize() //random zonenote add sudden death for when the game round ends
	for(var/caste_path in subtypesof(/datum/moba_caste))
		var/datum/moba_caste/caste = new caste_path
		GLOB.moba_castes[caste.equivalent_caste_path] = caste
		GLOB.moba_castes_name[caste.name] = caste
	for(var/item_path as anything in subtypesof(/datum/moba_item))
		var/datum/moba_item/item = new item_path
		items += item
		item_dict[item_path] = item
	for(var/datum/moba_item/item as anything in items)
		item.set_total_gold_cost()
		item.set_description()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/moba/stat_entry(msg)
	msg = "M:[length(controllers)]|Q:[length(players_in_queue)]"
	return ..()

/datum/controller/subsystem/moba/fire(resumed = FALSE)
	if(!resumed)
		current_run = controllers.Copy()

	while(length(current_run))
		var/datum/moba_controller/controller = current_run[length(current_run)]
		current_run.len--

		if(!controller || QDELETED(controller))
			continue

		controller.handle_tick()

		if(MC_TICK_CHECK)
			return



	#if defined(MOBA_TESTING)
	if(length(players_in_queue))
		var/datum/moba_player/player = players_in_queue[1]
		make_game(list(new /datum/moba_queue_player(player, player.queue_slots[1].position, player.queue_slots[1].caste)), list())
	#elif defined(MOBA_MP_TESTING)
	if(length(players_in_queue) >= 2)
		var/datum/moba_player/player1 = players_in_queue[1]
		var/datum/moba_player/player2 = players_in_queue[2]
		make_game(list(new /datum/moba_queue_player(player1, player1.queue_slots[1].position, player1.queue_slots[1].caste)), list(new /datum/moba_queue_player(player2, player2.queue_slots[1].position, player2.queue_slots[1].caste)))
	#else
	if(COOLDOWN_FINISHED(src, matchmaking_cooldown) && (length(players_in_queue) >= MOBA_TOTAL_PLAYERS) && !SSticker.mode.round_finished && !currently_creating_map) // We can actually make a match
		do_matchmaking()
	#endif

/datum/controller/subsystem/moba/proc/add_to_queue(datum/moba_player/player)
	players_in_queue |= player
	RegisterSignal(player, COMSIG_PARENT_QDELETING, PROC_REF(on_queued_client_delete))

/datum/controller/subsystem/moba/proc/remove_from_queue(datum/moba_player/player)
	players_in_queue -= player
	UnregisterSignal(player, COMSIG_PARENT_QDELETING)

/// I'm not bothering with MMR or whatever the hell
/// Pure randomness, this is where boys become men
/datum/controller/subsystem/moba/proc/do_matchmaking()
	var/list/already_taken_castes_team1 = list()
	var/list/already_taken_castes_team2 = list()
	var/list/team1_players = list()
	var/list/team2_players = list()
	var/list/team1_needed_roles = list(
		MOBA_LANE_TOP,
		MOBA_LANE_JUNGLE,
		MOBA_LANE_SUPPORT,
		MOBA_LANE_BOT,
	)
	var/list/team2_needed_roles = list(
		MOBA_LANE_TOP,
		MOBA_LANE_JUNGLE,
		MOBA_LANE_SUPPORT,
		MOBA_LANE_BOT,
	)

	var/list/randomized_queue = shuffle(players_in_queue.Copy())
	mm_loop:
		for(var/i in 1 to 3)
			for(var/datum/moba_player/player as anything in randomized_queue)
				if((player in team1_players) || (player in team2_players))
					continue

				if((player.queue_slots[i].position in team1_needed_roles) && !(player.queue_slots[i].caste in already_taken_castes_team1))
					team1_needed_roles -= player.queue_slots[i].position
					already_taken_castes_team1 += player.queue_slots[i].caste
					team1_players += new /datum/moba_queue_player(player, player.queue_slots[i].position, player.queue_slots[i].caste)
					randomized_queue -= player
				else if((player.queue_slots[i].position in team2_needed_roles) && !(player.queue_slots[i].caste in already_taken_castes_team2))
					team2_needed_roles -= player.queue_slots[i].position
					already_taken_castes_team2 += player.queue_slots[i].caste
					team2_players += new /datum/moba_queue_player(player, player.queue_slots[i].position, player.queue_slots[i].caste)
					randomized_queue -= player

				if(length(team1_players) == MOBA_PLAYERS_PER_TEAM && length(team2_players) == MOBA_PLAYERS_PER_TEAM)
					break mm_loop

	if(length(team1_players) == MOBA_PLAYERS_PER_TEAM && length(team2_players) == MOBA_PLAYERS_PER_TEAM)
		make_game(team1_players, team2_players)
		currently_creating_map = FALSE
	else
		COOLDOWN_START(src, matchmaking_cooldown, 5 SECONDS)
		// We redo this check every 5s until we either drop below 8 in queue or finally make a game
		// Should eventually add something that autofills people if there's enough in queue but missing players for a given lane

/datum/controller/subsystem/moba/proc/make_game(list/team1_players, list/team2_players)
	currently_creating_map = TRUE

	for(var/datum/moba_queue_player/player as anything in (team1_players + team2_players))
		remove_from_queue(player.player)
		to_chat(player.player.tied_client, SPAN_BOLDNOTICE("Your game is now being created."))
		ADD_TRAIT(player.player.tied_client.mob, TRAIT_MOBA_PARTICIPANT, TRAIT_SOURCE_INHERENT) // We add this to observers so we can make sure they can't mess with their MOBA prefs and other stuff
		for(var/datum/tgui/ui as anything in player.player.tied_client.mob.tgui_open_uis)
			if(!istype(ui.src_object, /datum/moba_join_panel))
				continue

			ui.close()

	var/datum/unused_moba_map/found_map
	if(length(unused_maps))
		found_map = unused_maps[1]
		unused_maps -= found_map

	var/datum/moba_controller/new_controller
	if(found_map)
		new_controller = new(team1_players, team2_players, found_map.map_id)
		controllers += new_controller
		controller_id_dict["[found_map.map_id]"] = new_controller
	else
		new_controller = new(team1_players, team2_players, current_highest_map_id)
		controllers += new_controller
		controller_id_dict["[current_highest_map_id]"] = new_controller
		current_highest_map_id++

	if(found_map)
		new_controller.handle_map_reuse_init(found_map)
		if(!new_controller.load_in_players())
			for(var/datum/moba_queue_player/player as anything in (team1_players + team2_players))
				remove_from_queue(player.player)
				to_chat(player.player.tied_client, SPAN_BOLDNOTICE("Someone disconnected while the game was loading. Your game has been aborted."))
				REMOVE_TRAIT(player.player.tied_client?.mob, TRAIT_MOBA_PARTICIPANT, TRAIT_SOURCE_INHERENT)
			SSmoba.unused_maps += new /datum/unused_moba_map(new_controller)
			qdel(new_controller)
			return

	else
		var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(/datum/map_template/moba_map::width, /datum/map_template/moba_map::height, 1)
		if(!reservation)
			return // zonenote add error message

		CHECK_TICK

		var/datum/map_template/moba_map/template = new
		template.load(reservation.bottom_left_turfs[1], FALSE, TRUE)
		new_controller.handle_map_init(reservation.bottom_left_turfs[1])
		if(!new_controller.load_in_players())
			for(var/datum/moba_queue_player/player as anything in (team1_players + team2_players))
				remove_from_queue(player.player)
				to_chat(player.player.tied_client, SPAN_BOLDNOTICE("Someone disconnected while the game was loading. Your game has been aborted."))
				REMOVE_TRAIT(player.player.tied_client?.mob, TRAIT_MOBA_PARTICIPANT, TRAIT_SOURCE_INHERENT)
			SSmoba.unused_maps += new /datum/unused_moba_map(new_controller)
			qdel(new_controller)
			return

/datum/controller/subsystem/moba/proc/get_moba_controller(map_id)
	RETURN_TYPE(/datum/moba_controller)
	if(!map_id)
		return

	return controller_id_dict["[map_id]"]

/datum/controller/subsystem/moba/proc/on_queued_client_delete(datum/moba_player/source)
	SIGNAL_HANDLER

	remove_from_queue(source)
