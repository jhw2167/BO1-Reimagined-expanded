#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{

	//Reimagined-Expanded
	level.zombiemode_using_juggernaut_perk = true;
	level.zombiemode_using_sleightofhand_perk = true;
	level.zombiemode_using_doubletap_perk = true;
	level.zombiemode_using_revive_perk = true;
	level.zombiemode_using_divetonuke_perk = true;
	level.zombiemode_using_marathon_perk = true;
	level.zombiemode_using_deadshot_perk = true;
	level.zombiemode_using_additionalprimaryweapon_perk = true;
	//level.zombiemode_using_electriccherry_perk = true;
	//level.zombiemode_using_vulture_perk = true;
	//level.zombiemode_using_widowswine_perk = true;

	/*
	level.zombiemode_using_chugabud_perk = true;
	
	level.zombiemode_using_bandolier_perk = true;
	level.zombiemode_using_timeslip_perk = true;
	level.zombiemode_using_pack_a_punch = true;
	*/

	level thread place_perk_machines_by_map();
	level thread place_doubletap_machine();

	// Perks-a-cola vending machine use triggers
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	// Pack-A-Punch weapon upgrade machine use triggers
	vending_weapon_upgrade_trigger = GetEntArray("zombie_vending_upgrade", "targetname");
	flag_init("pack_machine_in_use");
	flag_init( "solo_game" );

	if( level.mutators["mutator_noPerks"] )
	{
		for( i = 0; i < vending_triggers.size; i++ )
		{
			vending_triggers[i] disable_trigger();
		}
		for( i = 0; i < vending_weapon_upgrade_trigger.size; i++ )
		{
			vending_weapon_upgrade_trigger[i] disable_trigger();
		}
		return;
	}

	if ( vending_triggers.size < 1 )
	{
		return;
	}

	if ( vending_weapon_upgrade_trigger.size >= 1 )
	{
		array_thread( vending_weapon_upgrade_trigger, ::vending_weapon_upgrade );
	}

	//Perks machine
	//load_fx();
	default_vending_precaching();
	if( !isDefined( level.custom_vending_precaching ) )
	{
		level.custom_vending_precaching = maps\_zombiemode_perks::default_vending_precaching;
	}
	[[ level.custom_vending_precaching ]]();

	if( !isDefined( level.packapunch_timeout ) )
	{
		level.packapunch_timeout = 15;
	}

	set_zombie_var( "zombie_perk_cost",					2000 );
	if( level.mutators["mutator_susceptible"] )
	{
		set_zombie_var( "zombie_perk_juggernaut_health",	80 );
		set_zombie_var( "zombie_perk_juggernaut_health_upgrade",	95 );
	}
	else
	{
		set_zombie_var( "zombie_perk_juggernaut_health",	160 );
		set_zombie_var( "zombie_perk_juggernaut_health_upgrade",	190 );
	}

	array_thread( vending_triggers, ::vending_trigger_think );
	array_thread( vending_triggers, ::electric_perks_dialog );
	//array_thread( vending_triggers, ::bump_trigger_think );
	
	level thread turn_PackAPunch_on();

	if ( isdefined( level.quantum_bomb_register_result_func ) )
	{
		[[level.quantum_bomb_register_result_func]]( "give_nearest_perk", ::quantum_bomb_give_nearest_perk_result, 100, ::quantum_bomb_give_nearest_perk_validation );
	}
	
}



place_doubletap_machine()
{
	switch ( Tolower( GetDvar( #"mapname" ) ) )
	{
	case "zombie_cosmodrome":
		level.zombie_doubletap_machine_origin = (1129.3, 743.9, -321.9);
		level.zombie_doubletap_machine_angles = (0, 180, 0);
		level.zombie_doubletap_machine_clip_origin = level.zombie_doubletap_machine_origin + (0, -10, 0);
		level.zombie_doubletap_machine_clip_angles = (0, 0, 0);

		level.zombie_doubletap_machine_monkey_angles = (0, 270, 0);
		level.zombie_doubletap_machine_monkey_origins = [];
		level.zombie_doubletap_machine_monkey_origins[0] = level.zombie_doubletap_machine_origin + (37.5, 24, 5);
		level.zombie_doubletap_machine_monkey_origins[1] = level.zombie_doubletap_machine_origin + (0, 36, 5);
		level.zombie_doubletap_machine_monkey_origins[2] = level.zombie_doubletap_machine_origin + (-40, 24, 5);
		break;
	}

	if ( !isdefined( level.zombie_doubletap_machine_origin ) )
	{
		return;
	}

	machine = Spawn( "script_model", level.zombie_doubletap_machine_origin );
	machine.angles = level.zombie_doubletap_machine_angles;
	machine setModel( "zombie_vending_doubletap" );
	machine.targetname = "vending_doubletap";

	machine_trigger = Spawn( "trigger_radius_use", level.zombie_doubletap_machine_origin + (0, 0, 30), 0, 20, 70 );
	machine_trigger.targetname = "zombie_vending";
	machine_trigger.target = "vending_doubletap";
	machine_trigger.script_noteworthy = "specialty_rof";

	machine_trigger.script_sound = "mus_perks_doubletap_jingle";
	machine_trigger.script_label = "mus_perks_doubletap_sting";

	if ( isdefined( level.zombie_doubletap_machine_clip_origin ) )
	{
		machine_clip = spawn( "script_model", level.zombie_doubletap_machine_clip_origin );
		machine_clip.angles = level.zombie_doubletap_machine_clip_angles;
		machine_clip setmodel( "collision_geo_64x64x256" );
		machine_clip Hide();
	}

	if ( isdefined( level.zombie_doubletap_machine_monkey_origins ) )
	{
		machine.target = "vending_doubletap_monkey_structs";
		for ( i = 0; i < level.zombie_doubletap_machine_monkey_origins.size; i++ )
		{
			machine_monkey_struct = SpawnStruct();
			machine_monkey_struct.origin = level.zombie_doubletap_machine_monkey_origins[i];
			machine_monkey_struct.angles = level.zombie_doubletap_machine_monkey_angles;
			machine_monkey_struct.script_int = i + 1;
			machine_monkey_struct.script_notetworthy = "cosmo_monkey_doubletap";
			machine_monkey_struct.targetname = "vending_doubletap_monkey_structs";

			if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
			{
				level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
			}

			size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
			level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
		}
	}
}

place_perk_machines_by_map()
{

	switch ( Tolower( GetDvar( #"mapname" ) ) )
	{
	case "zombie_cod5_prototype":
		maps\zombie_cod5_prototype_perk_machines::init();
		break;
	case "zombie_cod5_asylum":
		maps\zombie_cod5_asylum_perk_machines::init();
		break;
	case "zombie_cod5_sumpf":
		maps\zombie_cod5_sumpf_perk_machines::init();
		break;
	case "zombie_cod5_factory":
		maps\zombie_cod5_factory_perk_machines::init();
		break;
	case "zombie_theater":
    	maps\zombie_theater_perk_machines::init();
    	break;
	case "zombie_pentagon":
		maps\zombie_pentagon_perk_machines::init();
		break;
	case "zombie_cosmodrome":
		maps\zombie_cosmodrome_perk_machines::init();
		break;
	case "zombie_coast":
		maps\zombie_coast_perk_machines::init();
		break;
	case "zombie_temple":
		maps\zombie_temple_perk_machines::init();
		break;
	case "zombie_moon":
		maps\zombie_moon_perk_machines::init();
		break;
	
	}

}

add_bump_trigger(perk, origin)
{
	wait_network_frame();
	flag_wait("all_players_connected");
	str_origin = vector_to_string(origin, ",");
	level send_message_to_csc("zombiemode_perks", perk + "|spawn_bump|" + str_origin);
}

remove_bump_trigger(perk)
{
	wait_network_frame();
	flag_wait("all_players_connected");
	level send_message_to_csc("zombiemode_perks", perk + "|delete_bump");
}

load_fx()
{
	//Phd
	level._effect["divetonuke_groundhit"] = LoadFx( "maps/zombie/fx_perk_phd" );

	//Stamina

	//Vulture

	//Cherry


}

//
//	Precaches all machines
//
//	"weapon" - 1st person Bottle when drinking
//	icon - Texture for when perk is active
//	model - Perk Machine on/off versions
//	fx - machine on
//	sound
default_vending_precaching()
{

	PrecacheItem( "zombie_perk_bottle" );
	PreCacheModel( "t6_wpn_zmb_perk_bottle_jugg_world" );

	if( is_true( level.zombiemode_using_juggernaut_perk ) )
	{
		PreCacheShader( "specialty_juggernaut_zombies" );
		PreCacheShader( "specialty_juggernaut_zombies_pro" );
		PreCacheModel( "zombie_vending_jugg" );
		PreCacheModel( "zombie_vending_jugg_on" );
		PreCacheString( &"REIMAGINED_PERK_JUGGERNAUT" );
		level._effect[ "jugger_light" ] = LoadFX( "misc/fx_zombie_cola_jugg_on" );
		level thread turn_jugger_on();
	}
	if( is_true( level.zombiemode_using_sleightofhand_perk ) )
	{
		PreCacheShader( "specialty_fastreload_zombies" );
		PreCacheShader( "specialty_fastreload_zombies_pro" );
		PreCacheModel( "zombie_vending_sleight" );
		PreCacheModel( "zombie_vending_sleight_on" );
		PreCacheString( &"REIMAGINED_PERK_FASTRELOAD" );
		level._effect[ "sleight_light" ] = LoadFX( "misc/fx_zombie_cola_on" );
		level thread turn_sleight_on();
	}
	if( is_true( level.zombiemode_using_doubletap_perk ) )
	{
		PreCacheShader( "specialty_doubletap_zombies" );
		PreCacheShader( "specialty_doubletap_zombies_pro" );
		PreCacheModel( "zombie_vending_doubletap" );
		PreCacheModel( "zombie_vending_doubletap_on" );
		PreCacheString( &"REIMAGINED_PERK_DOUBLETAP" );
		level._effect[ "doubletap_light" ] = LoadFX( "misc/fx_zombie_cola_dtap_on" );
		level thread turn_doubletap_on();
	}
	if( is_true( level.zombiemode_using_revive_perk ) )
	{
		PreCacheShader( "specialty_quickrevive_zombies" );
		PreCacheShader( "specialty_quickrevive_zombies_pro" );
		PreCacheModel( "zombie_vending_revive" );
		PreCacheModel( "zombie_vending_revive_on" );
		PreCacheString( &"REIMAGINED_PERK_QUICKREVIVE" );
		level._effect[ "revive_light" ] = LoadFX( "misc/fx_zombie_cola_revive_on" );
		level._effect[ "revive_light_flicker" ] = LoadFX( "maps/zombie/fx_zmb_cola_revive_flicker" );
		level thread turn_revive_on();
	}
	if( is_true( level.zombiemode_using_divetonuke_perk ) )
	{
		level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;

		PreCacheShader( "specialty_divetonuke_zombies" );
		PreCacheShader( "specialty_divetonuke_zombies_pro" );
		PreCacheModel( "zombie_vending_nuke" );
		PreCacheModel( "zombie_vending_nuke_on" );
		PreCacheString( &"REIMAGINED_PERK_DIVETONUKE" );
		level._effect[ "divetonuke_light" ] = LoadFX( "misc/fx_zombie_cola_dtap_on" );

		set_zombie_var( "zombie_perk_divetonuke_radius", 500 ); // WW (01/12/2011): Issue 74726:DLC 2 - Zombies - Cosmodrome - PHD Flopper - Increase the radius on the explosion (Old: 150)
		set_zombie_var( "zombie_perk_divetonuke_min_damage", 1550 );
		set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );

		level thread turn_divetonuke_on();
	}
	if( is_true( level.zombiemode_using_marathon_perk ) )
	{
		PreCacheShader( "specialty_marathon_zombies" );
		PreCacheShader( "specialty_marathon_zombies_pro" );
		PreCacheModel( "zombie_vending_marathon" );
		PreCacheModel( "zombie_vending_marathon_on" );
		PreCacheString( &"REIMAGINED_PERK_MARATHON" );
		level._effect[ "marathon_light" ] = LoadFX( "misc/fx_zombie_cola_dtap_on" );
		level thread turn_marathon_on();
	}
	if( is_true( level.zombiemode_using_deadshot_perk ) )
	{
		PreCacheShader( "specialty_deadshot_zombies" );
		PreCacheShader( "specialty_deadshot_zombies_pro" );
		PreCacheModel( "zombie_vending_ads" );
		PreCacheModel( "zombie_vending_ads_on" );
		PreCacheString( &"REIMAGINED_PERK_DEADSHOT" );
		level._effect[ "deadshot_light" ] = LoadFX( "misc/fx_zombie_cola_dtap_on" );
		level thread turn_deadshot_on();
	}
	if( is_true( level.zombiemode_using_additionalprimaryweapon_perk ) )
	{
		PreCacheShader( "specialty_mulekick_zombies" );
		PreCacheShader( "specialty_mulekick_zombies_pro" );
		PreCacheModel( "zombie_vending_three_gun" );
		PreCacheModel( "zombie_vending_three_gun_on" );
		PreCacheString( &"REIMAGINED_PERK_MULEKICK" );
		level._effect[ "additionalprimaryweapon_light" ] = LoadFX( "misc/fx_zombie_cola_arsenal_on" );
		level thread turn_additionalprimaryweapon_on();
	}
	if( is_true( level.zombiemode_using_electriccherry_perk ) )
	{
		PreCacheShader( "specialty_cherry_zombies" );
		PreCacheShader( "specialty_cherry_zombies_pro" );
		PreCacheModel( "p6_zm_vending_electric_cherry_off" );
		PreCacheModel( "p6_zm_vending_electric_cherry_on" );
		PreCacheString( &"REIMAGINED_PERK_CHERRY" );
		level._effect[ "electriccherry_light" ] = LoadFX( "misc/fx_zombie_cola_on" );
		level thread turn_electriccherry_on();
	}
	if( is_true( level.zombiemode_using_vulture_perk ) )
	{
		PreCacheShader( "specialty_vulture_zombies" );
		PreCacheShader( "specialty_vulture_zombies_pro" );
		PreCacheModel( "bo2_zombie_vending_vultureaid" );
		PreCacheModel( "bo2_zombie_vending_vultureaid_on" );
		PreCacheString( &"REIMAGINED_PERK_VULTURE" );
		level._effect[ "vulture_light" ] = LoadFX( "misc/fx_zombie_cola_jugg_on" );
		level thread turn_vulture_on();
	}
	if( is_true( level.zombiemode_using_widowswine_perk ) )
	{
		PreCacheShader( "specialty_widowswine_zombies" );
		PreCacheShader( "specialty_widowswine_zombies_pro" );
		PreCacheModel( "bo3_p7_zm_vending_widows_wine_off" );
		PreCacheModel( "bo3_p7_zm_vending_widows_wine_on" );
		PreCacheString( &"REIMAGINED_PERK_WIDOWSWINE" );
		level._effect[ "widow_light" ] = LoadFX( "misc/fx_zombie_cola_jugg_on" );
		//level thread turn_widowswine_on();
	}
	if( is_true( level.zombiemode_using_bandolier_perk ) )
	{
		PreCacheShader( "specialty_bandolier_zombies" );
	}
	if( is_true( level.zombiemode_using_timeslip_perk ) )
	{
		PreCacheShader( "specialty_timeslip_zombies" );
	}

	// Minimap icons
	PrecacheShader( "minimap_icon_juggernog" );
	PrecacheShader( "minimap_icon_revive" );
	PrecacheShader( "minimap_icon_reload" );

}

third_person_weapon_upgrade( current_weapon, origin, angles, packa_rollers, perk_machine, perk_trigger )
{
	perk_trigger endon("pap_force_timeout");

	forward = anglesToForward( angles );
	interact_pos = origin + (forward*-25);
	PlayFx( level._effect["packapunch_fx"], origin+(0,1,-34), forward );

	worldgun = spawn( "script_model", interact_pos );
	worldgun.angles  = self.angles;
	worldgun setModel( GetWeaponModel( current_weapon ) );
	worldgun useweaponhidetags( current_weapon );
	worldgun rotateto( angles+(0,90,0), 0.35, 0, 0 );
	perk_trigger.worldgun = worldgun;

	offsetdw = ( 3, 3, 3 );
	worldgundw = undefined;
	if ( maps\_zombiemode_weapons::weapon_is_dual_wield( current_weapon ) )
	{
		worldgundw = spawn( "script_model", interact_pos + offsetdw );
		worldgundw.angles  = self.angles;

		worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( current_weapon ) );
		worldgundw useweaponhidetags( current_weapon );
		worldgundw rotateto( angles+(0,90,0), 0.35, 0, 0 );
		perk_trigger.worldgundw = worldgundw;
	}

	wait( 0.5 );

	worldgun moveto( origin, 0.5, 0, 0 );
	if ( isdefined( worldgundw ) )
	{
		worldgundw moveto( origin + offsetdw, 0.5, 0, 0 );
	}

	self playsound( "zmb_perks_packa_upgrade" );
	if( isDefined( perk_machine.wait_flag ) )
	{
		perk_machine.wait_flag rotateto( perk_machine.wait_flag.angles+(179, 0, 0), 0.25, 0, 0 );
	}
	wait( 0.35 );

	worldgun delete();
	if ( isdefined( worldgundw ) )
	{
		worldgundw delete();
	}

	wait( 3 );

	self playsound( "zmb_perks_packa_ready" );

	worldgun = spawn( "script_model", origin );
	worldgun.angles  = angles+(0,90,0);
	worldgun setModel( GetWeaponModel( level.zombie_weapons[current_weapon].upgrade_name ) );
	worldgun useweaponhidetags( level.zombie_weapons[current_weapon].upgrade_name );
	worldgun moveto( interact_pos, 0.5, 0, 0 );
	perk_trigger.worldgun = worldgun;

	worldgundw = undefined;
	if ( maps\_zombiemode_weapons::weapon_is_dual_wield( level.zombie_weapons[current_weapon].upgrade_name ) )
	{
		worldgundw = spawn( "script_model", origin + offsetdw );
		worldgundw.angles  = angles+(0,90,0);

		worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( level.zombie_weapons[current_weapon].upgrade_name ) );
		worldgundw useweaponhidetags( level.zombie_weapons[current_weapon].upgrade_name );
		worldgundw moveto( interact_pos + offsetdw, 0.5, 0, 0 );
		perk_trigger.worldgundw = worldgundw;
	}

	if( isDefined( perk_machine.wait_flag ) )
	{
		perk_machine.wait_flag rotateto( perk_machine.wait_flag.angles-(179, 0, 0), 0.25, 0, 0 );
	}

	wait( 0.5 );

	worldgun moveto( origin, level.packapunch_timeout, 0, 0);
	if ( isdefined( worldgundw ) )
	{
		worldgundw moveto( origin + offsetdw, level.packapunch_timeout, 0, 0);
	}

	worldgun.worldgundw = worldgundw;
	perk_trigger.third_person_weapon_complete = true;
	//return worldgun;
}


vending_machine_trigger_think()
{
	self endon("death");

	dist = 128 * 128;

	while(1)
	{
		players = get_players();
		for(i = 0; i < players.size; i++)
		{
			if(DistanceSquared( players[i].origin, self.origin ) < dist)
			{
				current_weapon = players[i] getCurrentWeapon();
				if(current_weapon == "microwavegun_zm")
				{
					current_weapon = "microwavegundw_zm";
				}
				primaryWeapons = players[i] GetWeaponsListPrimaries();
				packInUseByThisPlayer = ( flag("pack_machine_in_use") && IsDefined(self.user) && self.user == players[i] );
				if ( players[i] hacker_active() )
				{
					self SetInvisibleToPlayer( players[i], true );
				}
				else if( !players[i] maps\_zombiemode_weapons::can_buy_weapon() || players[i] maps\_laststand::player_is_in_laststand() || is_true( players[i].intermission ) || players[i] isThrowingGrenade() )
				{
					self SetInvisibleToPlayer( players[i], true );
				}
				else if( is_true(level.pap_moving)) //can't use the pap machine while it's being lowered or raised
				{
					self SetInvisibleToPlayer( players[i], true );
				}
				else if( players[i] isSwitchingWeapons() )
		 		{
		 			self SetInvisibleToPlayer( players[i], true );
		 		}
		 		else if( !packInUseByThisPlayer && flag("pack_machine_in_use") )
		 		{
		 			self SetInvisibleToPlayer( players[i], true );
		 		}
				else if ( !packInUseByThisPlayer && !IsDefined( level.zombie_include_weapons[current_weapon] ) )
				{
					self SetInvisibleToPlayer( players[i], true );
				}
				else if ( !packInUseByThisPlayer && players[i] maps\_zombiemode_weapons::is_weapon_double_upgraded( current_weapon ) )
				{
					self SetInvisibleToPlayer( players[i], true );
				}
				else if ( !packInUseByThisPlayer && vending_2x_blacklist(current_weapon) )
				{
					self SetInvisibleToPlayer( players[i], true );
				}
				else
				{
					self SetInvisibleToPlayer( players[i], false );
				}
			}
		}
		wait(0.05);
	}
}

//
//	Pack-A-Punch Weapon Upgrade
//
vending_weapon_upgrade()
{
	perk_machine = GetEnt( self.target, "targetname" );
	perk_machine_sound = GetEntarray ( "perksacola", "targetname");
	packa_rollers = spawn("script_origin", self.origin);
	packa_timer = spawn("script_origin", self.origin);
	packa_rollers LinkTo( self );
	packa_timer LinkTo( self );

	if( isDefined( perk_machine.target ) )
	{
		perk_machine.wait_flag = GetEnt( perk_machine.target, "targetname" );
	}

	self UseTriggerRequireLookAt();
	self SetHintString( &"ZOMBIE_NEED_POWER" );
	self SetCursorHint( "HINT_NOICON" );

	level waittill("Pack_A_Punch_on");

	self thread vending_machine_trigger_think();

	//self thread maps\_zombiemode_weapons::decide_hide_show_hint();

	perk_machine playloopsound("zmb_perks_packa_loop");

	self thread vending_weapon_upgrade_cost();

	for( ;; )
	{
		self waittill( "trigger", player );

		index = maps\_zombiemode_weapons::get_player_index(player);
		plr = "zmb_vox_plr_" + index + "_";
		current_weapon = player getCurrentWeapon();

		if ( current_weapon == "microwavegun_zm" ) {
			current_weapon = "microwavegundw_zm";
		} else if ( current_weapon == "zombie_doublebarrel_sawed" ) {
			current_weapon = "zombie_doublebarrel";		//No sawed upgraded exists
		}

		if( !player maps\_zombiemode_weapons::can_buy_weapon() ||
			player maps\_laststand::player_is_in_laststand() ||
			is_true( player.intermission ) ||
			player isThrowingGrenade() ||
			player maps\_zombiemode_weapons::is_weapon_double_upgraded( current_weapon ) )
		{
			wait( 0.1 );
			continue;
		}

		if( is_true(level.pap_moving)) //can't use the pap machine while it's being lowered or raised
		{
			continue;
		}

 		if( player isSwitchingWeapons() )
 		{
 			wait(0.1);
 			continue;
 		}

		if ( !IsDefined( level.zombie_include_weapons[current_weapon] ) )
		{
			continue;
		}

		if ( player.score < self.cost )
		{
			//player //iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}
		
		if ( player maps\_zombiemode_weapons::is_weapon_upgraded( current_weapon ) && player.score < self.cost2 )
		{
			//player //iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		if( is_melee_weapon(current_weapon) || is_placeable_mine(current_weapon) )
		{
			primaries = player GetWeaponsListPrimaries();
			if(IsDefined(player.last_held_primary_weapon) && player HasWeapon(player.last_held_primary_weapon))
			{
				player SwitchToWeapon(player.last_held_primary_weapon);
			}
			else if(IsDefined(primaries) && primaries.size > 0)
			{
				player SwitchToWeapon(primaries[0]);
			}
			else if(!is_melee_weapon(current_weapon))
			{
				player SwitchToWeapon("combat_" + self get_player_melee_weapon());
			}
			
 			continue;
		}
		if(vending_2x_blacklist(current_weapon)) {
			continue;
		}
				

		self.user = player;
		flag_set("pack_machine_in_use");

		if( IsSubStr(current_weapon, "upgraded") )
			player maps\_zombiemode_score::minus_to_player_score( self.cost2 ); //Double PaP
		else
			player maps\_zombiemode_score::minus_to_player_score( self.cost );

		sound = "evt_bottle_dispense";
		playsoundatposition(sound, self.origin);

		//TUEY TODO: Move this to a general init string for perk audio later on
		self thread maps\_zombiemode_audio::play_jingle_or_stinger("mus_perks_packa_sting");
		player maps\_zombiemode_audio::create_and_play_dialog( "weapon_pickup", "upgrade_wait" );

		origin = self.origin;
		angles = self.angles;

		if( isDefined(perk_machine))
		{
			origin = perk_machine.origin+(0,0,35);
			angles = perk_machine.angles+(0,90,0);
		}

		self SetHintString("");
		self disable_trigger();

		//iprintln("Call knuckle crack from main thread");
		player thread do_knuckle_crack();

		// Remember what weapon we have.  This is needed to check unique weapon counts.
		self.current_weapon = current_weapon;

		self thread wait_for_third_person_weapon_complete();

		//weaponmodel = player third_person_weapon_upgrade( current_weapon, origin, angles, packa_rollers, perk_machine, self );
		player third_person_weapon_upgrade( current_weapon, origin, angles, packa_rollers, perk_machine, self );

		//self.third_person_weapon_complete will be undefined if the endon in third_person_weapon_upgrade() is notified from the pap trigger
		if(!IsDefined(self.third_person_weapon_complete))
		{
			if ( isdefined( self.worldgun ) )
			{
				self.worldgun Delete();
			}
			if ( isdefined( self.worldgundw ) )
			{
				self.worldgundw Delete();
			}

			self waittill("third_person_weapon_complete");
		}

		self enable_trigger();

		if(IsDefined(self.third_person_weapon_complete))
		{
			self SetHintString( &"ZOMBIE_GET_UPGRADED" );
			// Set pack string invisibile to all other players immediately so the string doesn't show for them for a frame
			players = get_players();
			for(i=0;i<players.size;i++)
			{
				if(players[i] != player)
				{
					self SetInvisibleToPlayer(players[i], true);
				}
			}
			//self setvisibletoplayer( player );

			self thread wait_for_player_to_take( player, current_weapon, packa_timer );
			self thread wait_for_timeout( current_weapon, packa_timer );

			self waittill_either( "pap_timeout", "pap_taken" );

			self.current_weapon = "";

			if ( isdefined( self.worldgun ) )
			{
				self.worldgun Delete();
			}
			if ( isdefined( self.worldgundw ) )
			{
				self.worldgundw Delete();
			}
		}

		self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.cost2 );
		//self setvisibletoall();
		flag_clear("pack_machine_in_use");
		self.user = undefined;
		self.third_person_weapon_complete = undefined;
	}
}
//END VENDING WEAPON UPGRADE

vending_2x_blacklist(weapon) {
	if (	weapon == "microwavegundw_upgraded_zm" ||
			weapon == "tesla_gun_powerup_upgraded_zm" ||
			weapon == "tesla_gun_upgraded_zm" ||
			weapon == "thundergun_upgraded_zm" ||
			weapon == "ray_gun_upgraded_zm" ||
			weapon == "starburst_ray_gun_zm" ||
			weapon == "freezegun_upgraded_zm" ||
			weapon == "shrink_ray_upgraded_zm" || 
			weapon == "sniper_explosive_bolt_upgraded_zm" ||										//scavenger
			(IsSubStr( weapon, "sniper" ) && IsSubStr( weapon, "upgraded" )) ||						///scavenger
			weapon == "humangun_upgraded_zm" ||														//human gun
			( IsSubStr( weapon, "zombie" ) && IsSubStr( weapon, "upgraded" )) ||					//no double pap WaW weapons
			weapon == "m14_upgraded_zm" ||
			weapon == "mpl_upgraded_zm" ||
			weapon == "mp5k_upgraded_zm" ||
			weapon == "mp40_upgraded_zm" ||
			weapon == "ak74u_upgraded_zm" ||
			weapon == "pm63_upgraded_zm" ||
			weapon == "rottweil72_upgraded_zm" ||
			weapon == "m16_gl_upgraded_zm" ||
			weapon == "gl_m16_upgraded_zm" ||
			weapon == "ithaca_upgraded_zm" ||
			weapon == "mk_aug_upgraded_zm" ||
			weapon == "m72_law_zm" || 
			weapon == "china_lake_zm" ||
			weapon == "explosivbe_bolt_upgraded_zm")
			{
				return true;
			}
			
			return false;
}


wait_for_third_person_weapon_complete()
{
	wait 4.35;

	self notify("third_person_weapon_complete");
}

vending_weapon_upgrade_cost()
{
	while ( 1 )
	{
		self.cost = level.VALUE_PAP_COST;
		self.cost2 = level.VALUE_PAP_X2_COST; 
		if(level.expensive_perks) {
			self.cost = level.VALUE_PAP_EXPENSIVE_COST;
			self.cost2 = level.VALUE_PAP_X2_EXPENSIVE_COST;
		}
			
		
		self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.cost2 );

		level waittill( "powerup bonfire sale" );

		self.cost = 1000;
		self.cost2 = self.cost2 / 3;
		self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.cost2 );

		level waittill( "bonfire_sale_off" );
	}
}


//
//
wait_for_player_to_take( player, weapon, packa_timer )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon] ), "wait_for_player_to_take: weapon does not exist" );
	AssertEx( IsDefined( level.zombie_weapons[weapon].upgrade_name ), "wait_for_player_to_take: upgrade_weapon does not exist" );

	upgrade_weapon = level.zombie_weapons[weapon].upgrade_name;

	self endon( "pap_timeout" );
	while( true )
	{
		packa_timer playloopsound( "zmb_perks_packa_ticktock" );
		self waittill( "trigger", trigger_player );
		packa_timer stoploopsound(.05);
		if( trigger_player == player )
		{
			current_weapon = player GetCurrentWeapon();

			/#
			if ( "none" == current_weapon )
			{
				//iprintlnbold( "WEAPON IS NONE, PACKAPUNCH RETRIEVAL DENIED" );
			}
			#/

			primaryWeapons = player GetWeaponsListPrimaries();
			weapon_limit = 2;
			if( player HasPerk( "specialty_additionalprimaryweapon" ) )
		 	{
		 		weapon_limit = 3;
		 	}

			if( ( is_melee_weapon(current_weapon) || is_placeable_mine(current_weapon) ) && primaryWeapons.size >= weapon_limit )
			{
				primaries = player GetWeaponsListPrimaries();
				if(IsDefined(player.last_held_primary_weapon) && player HasWeapon(player.last_held_primary_weapon))
				{
					player SwitchToWeapon(player.last_held_primary_weapon);
				}
				else if(IsDefined(primaries) && primaries.size > 0)
				{
					player SwitchToWeapon(primaries[0]);
				}
				else if(!is_melee_weapon(current_weapon))
				{
					player SwitchToWeapon("combat_" + player get_player_melee_weapon());
				}
				
	 			continue;
			}

			if( is_player_valid( player ) && !player is_drinking() && !is_equipment( current_weapon ) && "syrette_sp" != current_weapon && "none" != current_weapon && !player hacker_active())
			{
				self notify( "pap_taken" );
				player notify( "pap_taken" );
				player.pap_used = true;

				weapon_limit = 2;
				if ( player HasPerk( "specialty_additionalprimaryweapon" ) )
				{
					weapon_limit = 3;
				}

				primaries = player GetWeaponsListPrimaries();
				if( isDefined( primaries ) && primaries.size >= weapon_limit )
				{
					player maps\_zombiemode_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					index = maps\_zombiemode_weapons::get_upgraded_weapon_model_index(upgrade_weapon);

					player GiveWeapon( upgrade_weapon, index, player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					player maps\_zombiemode_weapons::give_max_ammo(upgrade_weapon, 1);
				}

				player SwitchToWeapon( upgrade_weapon );
				player maps\_zombiemode_weapons::play_weapon_vo(upgrade_weapon);
				return;
			}
		}
		wait( 0.05 );
	}
}


//	Waiting for the weapon to be taken
//
wait_for_timeout( weapon, packa_timer )
{
	self endon( "pap_taken" );

	//wait( level.packapunch_timeout );
	self waittill_notify_or_timeout("pap_force_timeout", level.packapunch_timeout);

	self notify( "pap_timeout" );
	packa_timer stoploopsound(.05);
	packa_timer playsound( "zmb_perks_packa_deny" );

	maps\_zombiemode_weapons::unacquire_weapon_toggle( weapon );
}


//	Weapon has been inserted, crack knuckles while waiting
//
do_knuckle_crack()
{
	if(self HasPerk("specialty_fastreload") && !self hasProPerk(level.SPD_PRO))
	{
		self UnSetPerk("specialty_fastswitch");
	}

	gun = self upgrade_knuckle_crack_begin();

	self waittill_any_or_timeout( 1.5, "fake_death", "death", "player_downed", "weapon_change_complete" );

	if( self HasPerk("specialty_fastreload") )
	{
		self SetPerk("specialty_fastswitch");
	}

	self upgrade_knuckle_crack_end( gun );
}


//	Switch to the knuckles
//
upgrade_knuckle_crack_begin()
{
	self increment_is_drinking();

	self AllowLean( false );
	self AllowAds( false );
	self AllowSprint( false );
	self AllowCrouch( true );
	self AllowProne( false );
	self AllowMelee( false );

	if ( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}

	primaries = self GetWeaponsListPrimaries();

	gun = self GetCurrentWeapon();
	weapon = "zombie_knuckle_crack";

	if ( gun != "none" && !is_placeable_mine( gun ) && !is_equipment( gun ) )
	{
		if ( issubstr( gun, "knife_ballistic_" ) )
		{
			self notify( "zmb_lost_knife" );
		}
		self TakeWeapon( gun );
	}
	else
	{
		return;
	}

	self GiveWeapon( weapon );
	self SwitchToWeapon( weapon );

	return gun;
}

//	Anim has ended, now switch back to something
//
upgrade_knuckle_crack_end( gun )
{
	assert( gun != "zombie_perk_bottle_doubletap" );
	assert( gun != "zombie_perk_bottle_jugg" );
	assert( gun != "zombie_perk_bottle_revive" );
	assert( gun != "zombie_perk_bottle_sleight" );
	assert( gun != "zombie_perk_bottle_marathon" );
	assert( gun != "zombie_perk_bottle_nuke" );
	assert( gun != "zombie_perk_bottle_deadshot" );
	assert( gun != "zombie_perk_bottle_additionalprimaryweapon" );
	assert( gun != "syrette_sp" );

	self AllowLean( true );
	self AllowAds( true );
	self AllowSprint( true );
	self AllowProne( true );
	self AllowMelee( true );
	weapon = "zombie_knuckle_crack";

	// TODO: race condition?
	if ( self maps\_laststand::player_is_in_laststand() || is_true( self.intermission ) )
	{
		self TakeWeapon(weapon);
		return;
	}

	self decrement_is_drinking();

	self TakeWeapon(weapon);
	
	primaries = self GetWeaponsListPrimaries();
	if( self is_drinking() )
	{
		return;
	}
	else if( isDefined( primaries ) && primaries.size > 0 )
	{
		self SwitchToWeapon( primaries[0] );
	}
	else
	{
		self SwitchToWeapon( "combat_" + self get_player_melee_weapon() );
	}
}

// PI_CHANGE_BEGIN
//	NOTE:  In the .map, you'll have to make sure that each Pack-A-Punch machine has a unique targetname
turn_PackAPunch_on()
{
	level waittill("Pack_A_Punch_on");

	vending_weapon_upgrade_trigger = GetEntArray("zombie_vending_upgrade", "targetname");
	for(i=0; i<vending_weapon_upgrade_trigger.size; i++ )
	{
		perk = getent(vending_weapon_upgrade_trigger[i].target, "targetname");
		if(isDefined(perk))
		{
			perk thread activate_PackAPunch();
		}
	}
}

activate_PackAPunch()
{
	self setmodel("zombie_vending_packapunch_on");
	self playsound("zmb_perks_power_on");
	self vibrate((0,-100,0), 0.3, 0.4, 3);
	/*
	self.flag = spawn( "script_model", machine GetTagOrigin( "tag_flag" ) );
	self.angles = machine GetTagAngles( "tag_flag" );
	self.flag setModel( "zombie_sign_please_wait" );
	self.flag linkto( machine );
	self.flag.origin = (0, 40, 40);
	self.flag.angles = (0, 0, 0);
	*/
	timer = 0;
	duration = 0.05;

	level notify( "Carpenter_On" );
}
// PI_CHANGE_END



//############################################################################
//		P E R K   M A C H I N E S
//############################################################################

//
//	Threads to turn the machines to their ON state.
//


// Speed Cola / Sleight of Hand
//
turn_sleight_on()
{
	machine = getentarray("vending_sleight", "targetname");

	level waittill("sleight_on");

	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_sleight_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "sleight_light" );
	}

	level notify( "specialty_fastreload_power_on" );
}

// Quick Revive
//
turn_revive_on()
{
	machine = getentarray("vending_revive", "targetname");
	/*machine_model = undefined;
	machine_clip = undefined;

	flag_wait( "all_players_connected" );
	players = GetPlayers();
	if ( players.size == 1 || level.vsteams == "ffa" )
	{
		for( i = 0; i < machine.size; i++ )
		{
			if(IsDefined(machine[i].script_noteworthy) && machine[i].script_noteworthy == "clip")
			{
				machine_clip = machine[i];
			}
			else // then the model
			{
				machine[i] setmodel("zombie_vending_revive_on");
				machine_model = machine[i];
			}
		}
		wait_network_frame();
		if ( isdefined( machine_model ) )
		{
			machine_model thread revive_solo_fx(machine_clip);
		}
	}
	else
	{
		level waittill("revive_on");

		for( i = 0; i < machine.size; i++ )
		{
			if(IsDefined(machine[i].classname) && machine[i].classname == "script_model")
			{
				machine[i] setmodel("zombie_vending_revive_on");
				machine[i] playsound("zmb_perks_power_on");
				machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
				machine[i] thread perk_fx( "revive_light" );
			}
		}

		level notify( "specialty_quickrevive_power_on" );
	}*/

	level waittill("revive_on");

	for( i = 0; i < machine.size; i++ )
	{
		if(IsDefined(machine[i].classname) && machine[i].classname == "script_model")
		{
			machine[i] setmodel("zombie_vending_revive_on");
			machine[i] playsound("zmb_perks_power_on");
			machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
			machine[i] thread perk_fx( "revive_light" );
		}
	}

	level notify( "specialty_quickrevive_power_on" );
}


revive_solo_fx(machine_clip)
{
	flag_init( "solo_revive" );

	self.fx = Spawn( "script_model", self.origin );
	self.fx.angles = self.angles;
	self.fx SetModel( "tag_origin" );
	self.fx LinkTo(self);

	playfxontag( level._effect[ "revive_light" ], self.fx, "tag_origin" );
	playfxontag( level._effect[ "revive_light_flicker" ], self.fx, "tag_origin" );

	flag_wait( "solo_revive" );

	if ( isdefined( level.revive_solo_fx_func ) )
	{
		level thread [[ level.revive_solo_fx_func ]]();
	}

	//DCS: make revive model fly away like a magic box.
	//self playsound("zmb_laugh_child");

	wait(2.0);

	self playsound("zmb_box_move");

	playsoundatposition ("zmb_whoosh", self.origin );
	//playsoundatposition ("zmb_vox_ann_magicbox", self.origin );

	self moveto(self.origin + (0,0,40),3);

	if( isDefined( level.custom_vibrate_func ) )
	{
		[[ level.custom_vibrate_func ]]( self );
	}
	else
	{
	   direction = self.origin;
	   direction = (direction[1], direction[0], 0);

	   if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
	   {
            direction = (direction[0], direction[1] * -1, 0);
       }
       else if(direction[0] < 0)
       {
            direction = (direction[0] * -1, direction[1], 0);
       }

        self Vibrate( direction, 10, 0.5, 5);
	}

	self waittill("movedone");
	PlayFX(level._effect["poltergeist"], self.origin);
	playsoundatposition ("zmb_box_poof", self.origin);

    level clientNotify( "drb" );

	vending_triggers = GetEntArray("zombie_vending", "targetname");

	//remove machine sounds
	for(i = 0; i < vending_triggers.size; i++)
	{
		if(!isdefined(vending_triggers[i].script_noteworthy))
			continue;
		if(vending_triggers[i].script_noteworthy != "specialty_quickrevive")
			continue;
		if(!isdefined(vending_triggers[i].perk_hum_ent))
			continue;

		vending_triggers[i].perk_hum_ent StopLoopSound();
		vending_triggers[i].perk_hum_ent Delete();
		vending_triggers[i].perk_hum_ent = undefined;
	}

	//remove machine trigger
	for(i = 0; i < vending_triggers.size; i++)
	{
		if(!isdefined(vending_triggers[i].script_noteworthy))
			continue;
		if(vending_triggers[i].script_noteworthy != "specialty_quickrevive")
			continue;

		vending_triggers[i] Delete();
	}

	//self setmodel("zombie_vending_revive");
	self.fx Unlink();
	self.fx delete();
	self Delete();

	// DCS: remove the clip.
	machine_clip trigger_off();
	machine_clip ConnectPaths();
	machine_clip Delete();

	//remove bump trigger
	level send_message_to_csc("zombiemode_perks", "specialty_quickrevive|delete_bump");
}

// Jugger-nog / Juggernaut
//
turn_jugger_on()
{
	machine = getentarray("vending_jugg", "targetname");

	level waittill("juggernog_on");

	//Reimagined-Expanded
	level notify("divetonuke_on");
	level notify("marathon_on");
	level notify("doubletap_on");
	level notify("deadshot_on");
	level notify("additionalprimaryweapon_on");
	level notify("electriccherry_on");
	level notify("vultureon");
	level notify("widowswine_on");


	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_jugg_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "jugger_light" );
	}

	level notify( "specialty_armorvest_power_on" );
}

// Double-Tap
//
turn_doubletap_on()
{
	machine = getentarray("vending_doubletap", "targetname");
	level waittill("doubletap_on");

	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_doubletap_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "doubletap_light" );
	}

	level notify( "specialty_rof_power_on" );
}

// Marathon
//
turn_marathon_on()
{
	machine = getentarray("vending_marathon", "targetname");
	level waittill("marathon_on");

	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_marathon_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "marathon_light" );
		machine[i] thread perk_fx( "doubletap_light" );
	}
	level notify( "specialty_endurance_power_on" );
}

// Divetonuke
//
turn_divetonuke_on()
{
	machine = getentarray("vending_divetonuke", "targetname");
	level waittill("divetonuke_on");

	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_nuke_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "divetonuke_light" );
	}
	level notify( "specialty_flakjacket_power_on" );
}

divetonuke_explode( attacker, origin )
{
	// tweakable vars
	//iprintln("divetonuke_explode");
	radius = level.zombie_vars["zombie_perk_divetonuke_radius"];
	min_damage = level.zombie_vars["zombie_perk_divetonuke_min_damage"];
	max_damage = level.zombie_vars["zombie_perk_divetonuke_max_damage"];

	
	//Perkapunch
	if( attacker hasProPerk(level.PHD_PRO) ) //if player has specialty_flakjacket_upgraded,
	{
		//Increase radius and damage significantly
		radius *= level.VALUE_PHD_PRO_RADIUS_SCALE;
		min_damage = level.VALUE_PHD_PRO_DAMAGE / 2;
		max_damage = level.VALUE_PHD_PRO_DAMAGE;

		PlayFx( level._effect["custom_large_explosion"], origin );
		//Also apply hellfire to closest zombies, form _zombiemode_weaponeffects
		//Get all zombies in radius
		zombies = GetAiSpeciesArray( "axis", "all" );
		for( i = 0; i < zombies.size; i++ ) 
		{
			if( maps\_zombiemode::is_boss_zombie( zombies[i].animname ) )
				continue;

			if( checkDist( self.origin, zombies[i].origin, level.VALUE_PHD_PRO_COLLISIONS_RANGE ) ) {
				zombies[i] thread maps\_zombiemode_weapon_effects::bonus_fire_damage(
					 zombies[i] , attacker, 0 , 2 );
			}
		}
		
	} else {
		//iprintln("divetonuke_explode");
		PlayFx( level._effect["divetonuke_groundhit"], origin );
	}

	// radius damage
	attacker.divetonuke_damage = true;
	RadiusDamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	attacker.divetonuke_damage = undefined;

	// play fx
	//PlayFx( level._effect["custom_large_explosion"], origin );

	// play sound
	attacker PlaySound("wpn_grenade_explode");
	//attacker playsound("zmb_phdflop_explo");

	// WW (01/12/11): start clientsided effects - These client flags are defined in _zombiemode.gsc & _zombiemode.csc
	// Used for zombie_dive2nuke_visionset() in _zombiemode.csc
	attacker SetClientFlag( level._ZOMBIE_PLAYER_FLAG_DIVE2NUKE_VISION );
	wait_network_frame();
	wait_network_frame();
	attacker ClearClientFlag( level._ZOMBIE_PLAYER_FLAG_DIVE2NUKE_VISION );
}

// WW (02-02-11): Deadshot
turn_deadshot_on()
{
	machine = getentarray("vending_deadshot", "targetname");
	level waittill("deadshot_on");

	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_ads_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "deadshot_light" );
	}
	level notify( "specialty_deadshot_power_on" );
}

// additionalprimaryweapon
//
turn_additionalprimaryweapon_on()
{
	machine = getentarray("vending_additionalprimaryweapon", "targetname");
//	level waittill("additionalprimaryweapon_on");
	if ( "zombie_cod5_prototype" != level.script && "zombie_cod5_sumpf" != level.script )
	{
		flag_wait( "power_on" );
	}
	wait ( 3 );

	for( i = 0; i < machine.size; i++ )
	{
		machine[i] setmodel("zombie_vending_three_gun_on");
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "additionalprimaryweapon_light" );
	}
	level notify( "specialty_additionalprimaryweapon_power_on" );
}

turn_electriccherry_on()
{
	//init_electric_cherry();
	machine = GetEntArray( "vending_electriccherry", "targetname" );
	level waittill( "electriccherry_on" );
	for( i = 0; i < machine.size; i ++ )
	{
		machine[i] SetModel( "p6_zm_vending_electric_cherry_on" );
		machine[i] Vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
		machine[i] PlaySound( "zmb_perks_power_on" );
		machine[i] thread perk_fx( "electriccherry_light" );
	}
	level notify( "specialty_bulletdamage_power_on" );
}

turn_vulture_on()
{
	//init_vulture();
	machine = GetEntArray( "vending_vulture", "targetname" );
	level waittill( "vulture_on" );
	for( i = 0; i < machine.size; i ++ )
	{
		machine[i] SetModel( "p6_zm_vending_vultureaid_on" );
		machine[i] Vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
		machine[i] PlaySound( "zmb_perks_power_on" );
		machine[i] thread perk_fx( "vulture_light" );
	}
	level notify( "specialty_altmelee_power_on" );
}

turn_widowswine_on()
{
	//init_widows_wine();
	machine = GetEntArray( "vending_widowswine", "targetname" );
	level waittill( "widowswine_on" );
	for( i = 0; i < machine.size; i ++ )
	{
		machine[i] SetModel( "p7_zm_vending_widows_wine_on" );
		machine[i] Vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
		machine[i] PlaySound( "zmb_perks_power_on" );
		machine[i] thread perk_fx( "widow_light" );
	}
	level notify( "specialty_extraammo_power_on" );
}

//
//
perk_fx( fx )
{
	wait(3);
	playfxontag( level._effect[ fx ], self, "tag_origin" );
}




electric_perks_dialog()
{
	//TODO  TEMP Disable Revive in Solo games
	flag_wait( "all_players_connected" );
	players = GetPlayers();
	if ( players.size == 1 )
	{
		return;
	}

	self endon ("warning_dialog");
	level endon("switch_flipped");
	timer =0;
	while(1)
	{
		wait(0.5);
		players = get_players();
		for(i = 0; i < players.size; i++)
		{
			dist = distancesquared(players[i].origin, self.origin );
			if(dist > 70*70)
			{
				timer = 0;
				continue;
			}
			if(dist < 70*70 && timer < 3)
			{
				wait(0.5);
				timer ++;
			}
			if(dist < 70*70 && timer == 3)
			{

				players[i] thread do_player_vo("vox_start", 5);
				wait(3);
				self notify ("warning_dialog");
				/#
				//iprintlnbold("warning_given");
				#/
			}
		}
	}
}


/* convertPerkToShader( perk )
{
	if (perk == "specialty_armorvest_upgrade")
		return "specialty_juggernaut_zombies_pro";
	if (perk == "specialty_quickrevive_upgrade")
		return "specialty_quickrevive_zombies_pro";
	if (perk == "specialty_fastreload_upgrade")
		return "specialty_fastreload_zombies_pro";
	if (perk == "specialty_rof_upgrade")
		return "specialty_doubletap_zombies_pro";
	if (perk == "specialty_endurance_upgrade")
		return "specialty_marathon_zombies_pro";
	if (perk == "specialty_flakjacket_upgrade")
		return "specialty_divetonuke_zombies_pro";
	if (perk == "specialty_deadshot_upgrade")
		return "specialty_deadshot_zombies_pro";
	if (perk == "specialty_additionalprimaryweapon_upgrade")
		return "specialty_mulekick_zombies_pro";
	if (perk == "specialty_bulletdamage_upgraded")
		return "specialty_cherry_zombies_pro";
	if (perk == "specialty_altmelee_upgrade")
		return "specialty_vulture_zombies_pro";
	if (perk == "specialty_extraammo_upgraded")
		return "specialty_widowswine_zombies_pro";
    
return "UNKOWN";
} 

hasProPerk( p )
{ return true; }

addProPerk( p )
{ }
//Self is player
*/

hasProPerk( perk )
{
	if (perk == "specialty_armorvest_upgrade")
		return self.PRO_PERKS[ level.JUG_PRO ];
	if (perk == "specialty_quickrevive_upgrade")
		return self.PRO_PERKS[ level.QRV_PRO ];
	if (perk == "specialty_fastreload_upgrade")
		return self.PRO_PERKS[ level.SPD_PRO ];
	if (perk == "specialty_rof_upgrade")
		return self.PRO_PERKS[ level.DBT_PRO ];
	if (perk == "specialty_endurance_upgrade")
		return self.PRO_PERKS[ level.STM_PRO ];
	if (perk == "specialty_flakjacket_upgrade")
		return self.PRO_PERKS[ level.PHD_PRO ];
	if (perk == "specialty_deadshot_upgrade")
		return self.PRO_PERKS[ level.DST_PRO ];
	if (perk == "specialty_additionalprimaryweapon_upgrade")
		return self.PRO_PERKS[ level.MUL_PRO ];
	if (perk == "specialty_bulletdamage_upgrade")
		return self.PRO_PERKS[ level.ECH_PRO ];
	if (perk == "specialty_altmelee_upgrade")
		return self.PRO_PERKS[ level.VLT_PRO ];
	if (perk == "specialty_extraamo_upgrade")
		return self.PRO_PERKS[ level.WWN_PRO ];

	return false;
}

//player is player
// perk is always _upgrade

addProPerk( perk )
{
	if (perk == "specialty_armorvest_upgrade") {
		self giveArmorVestUpgrade();
		self.PRO_PERKS[ level.JUG_PRO ] = true;
	}
	if (perk == "specialty_quickrevive_upgrade")
		self.PRO_PERKS[ level.QRV_PRO ] = true;
	if (perk == "specialty_fastreload_upgrade") {
		self.PRO_PERKS[ level.SPD_PRO ] = true;
		self giveFastreloadUpgrade();
	}
		
	if (perk == "specialty_rof_upgrade")
		self.PRO_PERKS[ level.DBT_PRO ] = true;
	if (perk == "specialty_endurance_upgrade") {
		self.PRO_PERKS[ level.STM_PRO ] = true;
		self giveStaminaUpgrade();
	}
	if (perk == "specialty_flakjacket_upgrade") {
		self.PRO_PERKS[ level.PHD_PRO ] = true;
		self givePhdUpgrade();
	}
	if (perk == "specialty_deadshot_upgrade")
		self.PRO_PERKS[ level.DST_PRO ] = true;
	if (perk == "specialty_additionalprimaryweapon_upgrade") {
		self.PRO_PERKS[ level.MUL_PRO ] = true;
		self giveAdditionalPrimaryWeaponUpgrade();
	}	
	if (perk == "specialty_bulletdamage_upgrade")
		self.PRO_PERKS[ level.ECH_PRO ] = true;
	if (perk == "specialty_altmelee_upgrade")
		self.PRO_PERKS[ level.VLT_PRO ] = true;
	if (perk == "specialty_extraamo_upgrade")
		self.PRO_PERKS[ level.WWN_PRO ] = true;

	//iprintln( " ADD PRO PERK : " + perk);
}


disableProPerk( perk, time ) 
{
	if( !IsDefined( self ) || !IsDefined( self.PRO_PERKS ) ) {
		//iprintln("disableProPerk: self or self.PRO_PERKS is undefined");
		return;
	}

	if( !self hasProPerk( perk ) ) 
		return;

	self removeProPerk( perk, "DISABLE" );
	self.PRO_PERKS_DISABLED[ perk ] = true;

	wait( time );

	self returnProPerk( perk );
	self.PRO_PERKS_DISABLED[ perk ] = false;
}

returnProPerk( perk )
{
	//here
	len = "_upgrade".size;
	base_perk = GetSubStr( perk, 0, perk.size - len );
	self give_perk( base_perk );
	self give_perk( perk );
}

removeProPerk( perk, removeOrDisableHud )
{
	if( !IsDefined( self ) || !IsDefined( self.PRO_PERKS ) ) {
		//iprintln("removeProPerk: self or self.PRO_PERKS is undefined");
		return;
	}

	if( !IsDefined( removeOrDisableHud) )
		removeOrDisableHud = "REMOVE";

	len = "_upgrade".size;
	base_perk = GetSubStr( perk, 0, perk.size - len );

	if( !self hasProPerk( perk ) ) 
		return;

	//here
	if( self hasProPerk( perk ) )
	{
		//Trigger notify pro perk + "_stop"
		self notify( perk + "_stop" );

		//Remove Pro Perk Shader
		if( removeOrDisableHud == "REMOVE" )
			self perk_hud_destroy( perk );
		else if( removeOrDisableHud == "DISABLE" ) {
			hud  = self.perk_hud[ base_perk ];
			hud FadeOverTime(.5);
			hud.alpha = 0.5;
			self.perk_hud[ base_perk ] = hud;
		}
			
		//Set player pro perk to false
		self.PRO_PERKS[perk] = false;
	}
	//Unset base perk and reset stats by calling perk_think
	
	if (self HasPerk( base_perk ))
	{
		self thread perk_think( base_perk );
		wait(0.1);
		self notify( base_perk + "_stop" );
	}

	self update_perk_hud();
}


/*  #########################################
			GIVE UPGRADED PERKS
	##########################################
*/

giveArmorVestUpgrade()
{
	//Nothing to give
	self thread watch_armorvest_upgrade(level.JUG_PRO + "_stop");
}

giveAdditionalPrimaryWeaponUpgrade() 
{
	//Give player max ammo for all weapons
	level thread maps\_zombiemode_powerups::full_ammo_powerup_implementation( undefined, self, self.entity_num );
}

giveStaminaUpgrade()
{
	self SetClientDvar("ui_show_stamina_ghost_indicator", "1");
	self thread watch_stamina_upgrade(level.STM_PRO + "_stop");
}

giveFastreloadUpgrade()
{
	//some indicator for fast reload complete
	//self SetClientDvar("ui_show_stamina_ghost_indicator", "1");
	self thread watch_fastreload_upgrade(level.SPD_PRO + "_stop");
}

givePhdUpgrade() {
	self thread watch_phd_upgrade(level.PHD_PRO + "_stop");
}


player_print_msg(msg) {
	flag_wait( "all_players_connected" );
	wait(2);
	//iprintln( msg );
}

disableSpeed( wait_time ) {
		wait(wait_time);
		self disableProPerk( level.SPD_PRO, 30 );
}

vending_trigger_think()
{
	self endon("death");

	if(self.script_noteworthy == "specialty_longersprint")
	{
		self.script_noteworthy = "specialty_endurance";
	}

	//self thread turn_cola_off();
	perk = self.script_noteworthy;
	solo = false;
	//iprintln("PRINT PERK" + perk);
	//Reimagined-Expanded babyjugg!
	if ( IsDefined(perk) && perk == "specialty_bulletaccuracy" )
	{
		cost = 500;
		if(level.expensive_perks)
		{
			cost = 1000;
		}

		self SetCursorHint( "HINT_NOICON" );
		self UseTriggerRequireLookAt();
		self SetHintString( &"REIMAGINED_PERK_BABYJUGG", cost );

		for(;;)
		{
			self waittill( "trigger", player );

			index = maps\_zombiemode_weapons::get_player_index(player);

			if (player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
			{
				continue;
			}

			if(player in_revive_trigger())
			{
				continue;
			}

			if( player isThrowingGrenade() )
			{
				wait( 0.1 );
				continue;
			}

			if( player isSwitchingWeapons() )
			{
				wait(0.1);
				continue;
			}

			if( player is_drinking() )
			{
				wait( 0.1 );
				continue;
			}

			//HACK: If current weapon is combat_knife && points is divisble by 1210, give 10000 points
			if( player GetCurrentWeapon() == "combat_knife_zm" && player.score % 1210 == 0 )
			{
				player maps\_zombiemode_score::add_to_player_score( 10000 );
				wait( 0.1 );
				continue;
			}

			
			if ( player.maxHealth >= 140 )
			{
				wait( 0.1 );
				continue;
			}
			

			if ( player.score < cost )
			{
				//player //iprintln( "Not enough points to buy Perk: " + perk );
				wait(0.1);
				self playsound("evt_perk_deny");
				continue;
			}

			sound = "evt_bottle_dispense";
			playsoundatposition(sound, self.origin);
			player maps\_zombiemode_score::minus_to_player_score( cost );

			player playLocalSound("chr_breathing_hurt");
			player thread maps\_gameskill::event_heart_beat( "panicked" , 1 );
			player player_flag_set( "player_has_red_flashing_overlay" );

			level notify ("player_pain");
			
			player waittill( "end_heartbeat_loop" );

			wait (.2);
			player thread maps\_gameskill::event_heart_beat( "none" , 0 );
			player.preMaxHealth = 140;
			//iprintln("player max health: " + player.preMaxHealth);
			if(player.maxHealth < 140)
			{
				player SetMaxHealth( 140 );
			}
			//player SetMaxHealth( 100 );	//just use as trigger for now
			
			//player thread disableSpeed();

			wait( 1 );
			player player_flag_clear("player_has_red_flashing_overlay");

		}

		return;
	}

	//Reimagined-Expanded - Do a no perk run!
	if(level.max_perks == 0) {
		return;
	}

	//player_print_msg( "Setting up perk: " + perk );

	if(level.script != "zombie_cod5_sumpf")
	{
		machine = GetEntArray(self.target, "targetname");
		for(i = 0; i < machine.size; i++)
		{
			if(IsDefined(machine[i].classname) && machine[i].classname == "script_model")
			{
				level thread add_bump_trigger(self.script_noteworthy, machine[i].origin);
			}
		}	
	}

	flag_init( "_start_zm_pistol_rank" );	

	if ( IsDefined(perk) &&
		(perk == "specialty_quickrevive" || perk == "specialty_quickrevive_upgrade") )
	{
		flag_wait( "all_players_connected" );
		players = GetPlayers();
		if ( players.size == 1 )
		{
			flag_set( "solo_game" );
			level.solo_lives_given = 0;
			players[0].lives = 0;
			if(level.gamemode == "survival")
			{
				players[0].lives = 3;
			}
			level maps\_zombiemode::zombiemode_solo_last_stand_pistol();
		}
	}

	flag_set( "_start_zm_pistol_rank" );

	if ( !solo )
	{
		self SetHintString( &"ZOMBIE_NEED_POWER" );
	}

	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();

	cost = level.zombie_vars["zombie_perk_cost"];
	switch( perk )
	{
	case "specialty_armorvest_upgrade":
	case "specialty_armorvest":
		cost = 2500;
		break;

	case "specialty_quickrevive_upgrade":
	case "specialty_quickrevive":
		/*if( solo )
		{
			cost = 500;
		}
		else
		{
			cost = 1500;
		}*/
		cost = 1500;
		break;

	case "specialty_fastreload_upgrade":
	case "specialty_fastreload":
		cost = 3000;
		break;

	case "specialty_rof_upgrade":
	case "specialty_rof":
		cost = 2000;
		break;

	case "specialty_endurance_upgrade":
	case "specialty_endurance":
		cost = 2000;
		break;

	case "specialty_flakjacket_upgrade":
	case "specialty_flakjacket":
		cost = 2000;
		break;

	case "specialty_deadshot_upgrade":
	case "specialty_deadshot":
		cost = 2000; // WW (02-03-11): Setting this low at first so more people buy it and try it (TEMP)
		break;

	case "specialty_additionalprimaryweapon_upgrade":
	case "specialty_additionalprimaryweapon":
		cost = 4000;
		break;

	}

	self.cost = cost;

	if ( !solo || level.script == "zombie_cod5_sumpf" ) //fix for being able to buy Quick Revive on solo on Shi No Numa before the perk-a-cola spawn animation is complete
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}

	if(!IsDefined(level._perkmachinenetworkchoke))
	{
		level._perkmachinenetworkchoke = 0;
	}
	else
	{
		level._perkmachinenetworkchoke ++;
	}

	for(i = 0; i < level._perkmachinenetworkchoke; i ++)
	{
		wait_network_frame();
	}

	//Turn on music timer
	self thread maps\_zombiemode_audio::perks_a_cola_jingle_timer();

	perk_hum = spawn("script_origin", self.origin);
	perk_hum playloopsound("zmb_perks_machine_loop");

	self.perk_hum_ent = perk_hum;

	self thread check_player_has_perk(perk);

	upgrade_perk_cost = level.VALUE_PERK_PUNCH_COST;
	if(level.expensive_perks)
		upgrade_perk_cost = level.VALUE_PERK_PUNCH_EXPENSIVE_COST;

	switch( perk )
	{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
			self SetHintString( &"REIMAGINED_PERK_JUGGERNAUT", cost, upgrade_perk_cost );
			break;

		case "specialty_quickrevive_upgrade":
		case "specialty_quickrevive":
			self SetHintString( &"REIMAGINED_PERK_QUICKREVIVE", cost, upgrade_perk_cost );
			break;

		case "specialty_fastreload_upgrade":
		case "specialty_fastreload":
			self SetHintString( &"REIMAGINED_PERK_FASTRELOAD", cost, upgrade_perk_cost );
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			self SetHintString( &"REIMAGINED_PERK_DOUBLETAP", cost, upgrade_perk_cost );
			break;

		case "specialty_endurance_upgrade":
		case "specialty_endurance":
			self SetHintString( &"REIMAGINED_PERK_MARATHON", cost, upgrade_perk_cost );
			break;

		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			self SetHintString( &"REIMAGINED_PERK_DIVETONUKE", cost, upgrade_perk_cost );
			break;

		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			self SetHintString( &"REIMAGINED_PERK_DEADSHOT", cost, upgrade_perk_cost );
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			self SetHintString( &"REIMAGINED_PERK_MULEKICK", cost, upgrade_perk_cost );
			break;

		case "specialty_bulletaccuracy_upgrade":
		case "specialty_bulletaccuracy":
			self SetHintString( &"REIMAGINED_PERK_CHUGABUD", cost, upgrade_perk_cost );
			break;

		case "specialty_bulletdamage_upgrade":
		case "specialty_bulletdamage":
			self SetHintString( &"REIMAGINED_PERK_CHERRY", cost, upgrade_perk_cost );
			break;

		case "specialty_altmelee_upgrade":
		case "specialty_altmelee":
			self SetHintString( &"REIMAGINED_PERK_VULTURE", cost, upgrade_perk_cost );
			break;

		case "specialty_extraammo_upgrade":
		case "specialty_extraammo":
			self SetHintString( &"REIMAGINED_PERK_WIDOWSWINE", cost, upgrade_perk_cost );
			break;

		case "specialty_stockpile_upgrade":
		case "specialty_stockpile":
			self SetHintString( &"REIMAGINED_PERK_BANDOLIER", cost, upgrade_perk_cost );
			break;

		case "specialty_scavanger_upgrade":
		case "specialty_scavanger":
			self SetHintString( &"REIMAGINED_PERK_TIMESLIP", cost, upgrade_perk_cost );
			break;


	default:
		self SetHintString( perk + " Cost: " + level.zombie_vars["zombie_perk_cost"] );
	}

	CONST_PERK = perk;
	CONST_COST = cost;

	for( ;; )
	{
		self waittill( "trigger", player );

		index = maps\_zombiemode_weapons::get_player_index(player);

		if (player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			continue;
		}

		if(player in_revive_trigger())
		{
			continue;
		}

		if( player isThrowingGrenade() )
		{
			wait( 0.1 );
			continue;
		}

 		if( player isSwitchingWeapons() )
 		{
 			wait(0.1);
 			continue;
 		}

		if( player is_drinking() )
		{
			wait( 0.1 );
			continue;
		}
		
		if( player.PRO_PERKS_DISABLED[ perk + "_upgrade"] )
		{
			wait( 0.1 );
			continue;
		}

		if ( player HasPerk( perk ) )
		{
			cheat = false;

			/#
			if ( GetDvarInt( #"zombie_cheat" ) >= 5 )
			{
				cheat = true;
			}
			#/

			//Reimagined-Expanded perkapunch
			if ( !( player hasProPerk( perk ) ) && player.score > upgrade_perk_cost )
			{
				perk = perk + "_upgrade";
				cost = upgrade_perk_cost;
				player.num_perks--;		//Will be incremented later when perk is perchased, so we pre-decrement!
			} else if ( cheat != true )
			{
				//player //iprintln( "Already using Perk: " + perk );
				self playsound("deny");
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
				continue;
			}
		}

		if ( player.score < cost )
		{
			//player //iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		
		if ( player.num_perks >= level.max_perks && !is_true(player._retain_perks) )
		{
			//player //iprintln( "Too many perks already to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			// COLLIN: do we have a VO that would work for this? if not we'll leave it at just the deny sound
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}
		

		sound = "evt_bottle_dispense";
		playsoundatposition(sound, self.origin);
		player maps\_zombiemode_score::minus_to_player_score( cost );

		if( IsSubStr( perk, "_upgrade" ) ) {
			player give_perk( perk, true );
		} 

		player.perk_purchased = perk;

		//if( player unlocked_perk_upgrade( perk ) )
		//{
		//	perk += "_upgrade";
		//}

		//iprintln( "Bought Perk: " + perk );
		///bottle_dispense
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
			sound = "mus_perks_jugger_sting";
			break;

		case "specialty_quickrevive_upgrade":
		case "specialty_quickrevive":
			sound = "mus_perks_revive_sting";
			break;

		case "specialty_fastreload_upgrade":
		case "specialty_fastreload":
			sound = "mus_perks_speed_sting";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			sound = "mus_perks_doubletap_sting";
			break;

		case "specialty_endurance_upgrade":
		case "specialty_endurance":
			sound = "mus_perks_phd_sting";
			break;

		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			sound = "mus_perks_stamin_sting";
			break;

		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			sound = "mus_perks_jugger_sting"; // WW TODO: Place new deadshot stinger
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			sound = "mus_perks_mulekick_sting";
			break;

		default:
			sound = "mus_perks_jugger_sting";
			break;
		}

		self thread maps\_zombiemode_audio::play_jingle_or_stinger (self.script_label);

		//		self waittill("sound_done");


		// do the drink animation
		if( player HasPerk("specialty_fastreload") && !self hasProPerk(level.SPD_PRO) )
		{
			player UnSetPerk("specialty_fastswitch");
		}
		gun = player perk_give_bottle_begin( perk );
		self thread give_perk_think(player, gun, perk, cost);

		//Reset Perk and Const values for next purchase
		perk = CONST_PERK;
		cost = CONST_COST;
	}
}

give_perk_think(player, gun, perk, cost)
{
	player waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );

	if ( !player maps\_laststand::player_is_in_laststand() && !is_true( player.intermission ) )
	{
		if(player HasPerk("specialty_fastreload"))
		{
			player SetPerk("specialty_fastswitch");
		}
	}

	// restore player controls and movement
	player perk_give_bottle_end( gun, perk );

	// TODO: race condition?
	if ( player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
	{
		return;
	}

	if ( isDefined( level.perk_bought_func ) )
	{
		player [[ level.perk_bought_func ]]( perk );
	}

	player.perk_purchased = undefined;

	//player give_perk( perk, true );

	//player //iprintln( "Bought Perk: " + perk );
	bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type perk",
		player.playername, player.score, level.team_pool[ player.team_num ].score, level.round_number, cost, perk, self.origin );
}

// ww: tracks the player's lives in solo, once a life is used then the revive trigger is moved back in to position
solo_revive_buy_trigger_move( revive_trigger_noteworthy )
{
	self endon( "death" );

	revive_perk_trigger = GetEnt( revive_trigger_noteworthy, "script_noteworthy" );

	revive_perk_trigger trigger_off();

	if( level.solo_lives_given >= 3 )
	{
		if(IsDefined(level._solo_revive_machine_expire_func))
		{
			revive_perk_trigger [[level._solo_revive_machine_expire_func]]();
		}

		return;
	}

	while( self.lives > 0 )
	{
		wait( 0.1 );
	}

	revive_perk_trigger trigger_on();
}

unlocked_perk_upgrade( perk )
{
	ch_ref = string(tablelookup( "mp/challengeTable_zmPerk.csv", 12, perk, 7 ));
	ch_max = int(tablelookup( "mp/challengeTable_zmPerk.csv", 12, perk, 4 ));
	ch_progress = self getdstat( "challengeStats", ch_ref, "challengeProgress" );

	if( ch_progress >= ch_max )
	{
		return true;
	}
	return false;
}

give_perk( perk, bought )
{
	//iprintln( "Giving Perk " + perk );
	//iprintln(" Player " + self.entity_num );

	//Reimagined-Expanded
	if( IsSubStr( perk, "_upgrade" ) )
	{	
		if( self hasProPerk( perk ) ) {
			//iprintln( "Self has pro perk: " + self.entity_num);
			return;
		}

		player = GetPlayers()[ self GetEntityNumber() ];
		player addProPerk( perk );
	} else
	{
		self SetPerk( perk );
	}
	
	self.num_perks++;

	perk_str = perk + "_stop";

	if ( is_true( bought ) )
	{
		//AUDIO: Ayers - Sending Perk Name over to audio common script to play VOX
		self thread maps\_zombiemode_audio::perk_vox( perk );
		//self setblur( 4, 0.1 );
		//wait(0.1);
		//self setblur(0, 0.1);
		//earthquake (0.4, 0.2, self.origin, 100);

		self notify( "perk_bought", perk );
	}

	if(perk == "specialty_quickrevive")
	{
		self SetClientDvar("cg_hudDamageIconTime", 2000);
	}

	if(perk == "specialty_armorvest")
	{
		self.preMaxHealth = self.maxhealth;
		self SetMaxHealth( level.zombie_vars["zombie_perk_juggernaut_health"] );
	}
	else if(perk == "specialty_armorvest_upgrade")
	{
		//Perkapunch
		self SetMaxHealth( level.VALUE_JUGG_PRO_MAX_HEALTH );
		//self.preMaxHealth = self.maxhealth; //Upgraded Jugg is permanent
		//self SetMaxHealth( level.zombie_vars["zombie_perk_juggernaut_health_upgrade"] );
	}

	if(perk == "specialty_fastreload")
	{
		self SetPerk("specialty_fastswitch");
		//self SetPerk("specialty_fastads");
		//self SetPerk("specialty_fastoffhand");
	}

	if(perk == "specialty_endurance")
	{
		self SetPerk("specialty_unlimitedsprint");
	}

	//increase burst fire rate with double tap
	if(perk == "specialty_rof")
	{
		self SetClientDvar("player_burstFireCoolDown", .2 * GetDvarFloat("perk_weapRateMultiplier"));
	} else if(perk == "specialty_rof_upgrade")
	{
		self SetClientDvar("player_burstFireCoolDown", .1 * GetDvarFloat("perk_weapRateMultiplier"));
	}

	// WW (02-03-11): Deadshot csc call
	if( perk == "specialty_deadshot" )
	{
		self SetClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
		//self SetPerk("specialty_fastsprintrecovery");
		//self SetPerk("specialty_stalker");
	}
	else if( perk == "specialty_deadshot_upgrade" )
	{
		self SetClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
	}

	// quick revive in solo gives an extra life
	players = getplayers();
	/*if ( players.size == 1 && perk == "specialty_quickrevive" )
	{
		self.lives = 1;

		level.solo_lives_given++;

		if( level.solo_lives_given >= 3 )
		{
			flag_set( "solo_revive" );
		}

		self thread solo_revive_buy_trigger_move( perk );

		// self disable_trigger();
	}*/

	if(perk == "specialty_additionalprimaryweapon")
	{
		//self SetPerk("specialty_stockpile");
		self SetClientDvar("ui_show_mule_wep_indicator", "1");
		self thread give_back_additional_weapon();
		self thread additional_weapon_indicator(perk, perk_str);
		self thread unsave_additional_weapon_on_bleedout();
	}


	self perk_hud_create( perk );

	//stat tracking
	self.stats["perks"]++;

	//Reimagined-Expanded Dont need to watch for perks lost when they are permanent
	if( !IsSubStr( perk, "_upgrade" ) )
	{
		self thread perk_think( perk );
	}
	
}

give_back_additional_weapon()
{
	self endon("disconnect");

	if(!IsDefined(self.weapon_taken_by_losing_additionalprimaryweapon) || !IsDefined(self.weapon_taken_by_losing_additionalprimaryweapon[0]))
	{
		return;
	}

	// check if we can give back the lost weapon
	can_give_wep = true;
	if( IsDefined( level.limited_weapons )  )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
		for( q = 0; q < keys2.size; q++ )
		{
			if(keys2[q] != self.weapon_taken_by_losing_additionalprimaryweapon[0])
				continue;

			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] maps\_zombiemode_weapons::has_weapon_or_upgrade( keys2[q] ) )
				{
					count++;
				}
			}

			// Check the pack a punch machines to see if they are holding what we're looking for
			for ( k=0; k<pap_triggers.size; k++ )
			{
				if ( IsDefined(pap_triggers[k].current_weapon) && pap_triggers[k].current_weapon == keys2[q] )
				{
					count++;
				}
			}

			// Check the other boxes so we don't offer something currently being offered during a fire sale
			for ( chestIndex = 0; chestIndex < level.chests.size; chestIndex++ )
			{
				if ( IsDefined( level.chests[chestIndex].chest_origin.weapon_string ) && level.chests[chestIndex].chest_origin.weapon_string == keys2[q] )
				{
					count++;
				}
			}

			//check weapon powerup
			if ( isdefined( level.random_weapon_powerups ) )
			{
				for ( powerupIndex = 0; powerupIndex < level.random_weapon_powerups.size; powerupIndex++ )
				{
					if ( IsDefined( level.random_weapon_powerups[powerupIndex] ) && level.random_weapon_powerups[powerupIndex].base_weapon == keys2[q] )
					{
						count++;
					}
				}
			}

			if( count >= level.limited_weapons[keys2[q]] )
			{
				can_give_wep = false;
				break;
			}
		}
	}

	if(!can_give_wep)
	{
		self.weapon_taken_by_losing_additionalprimaryweapon = [];
		return;
	}

	unupgrade_name = self.weapon_taken_by_losing_additionalprimaryweapon[0];
	if(maps\_zombiemode_weapons::is_weapon_upgraded(self.weapon_taken_by_losing_additionalprimaryweapon[0]))
	{
		// removes "_upgraded" from weapon name
		unupgrade_name = GetSubStr(unupgrade_name, 0, unupgrade_name.size - 12) + GetSubStr(unupgrade_name, unupgrade_name.size - 3);
	}

	// cant give wep back if player has the wep or player has upgraded version and we're trying to give them unupgraded version
	if(self HasWeapon(level.zombie_weapons[unupgrade_name].upgrade_name) || (self HasWeapon(unupgrade_name) && !maps\_zombiemode_weapons::is_weapon_upgraded(self.weapon_taken_by_losing_additionalprimaryweapon[0])))
	{
		// give the player the ammo from their mule kick weapon if they have less than their mule kick weapon had
		if(self HasWeapon(self.weapon_taken_by_losing_additionalprimaryweapon[0]))
		{
			if(self GetWeaponAmmoClip(self.weapon_taken_by_losing_additionalprimaryweapon[0]) < self.weapon_taken_by_losing_additionalprimaryweapon[1])
			{
				self SetWeaponAmmoClip(self.weapon_taken_by_losing_additionalprimaryweapon[0], self.weapon_taken_by_losing_additionalprimaryweapon[1]);
			}

			if(self GetWeaponAmmoStock(self.weapon_taken_by_losing_additionalprimaryweapon[0]) < self.weapon_taken_by_losing_additionalprimaryweapon[2])
			{
				self SetWeaponAmmoStock(self.weapon_taken_by_losing_additionalprimaryweapon[0], self.weapon_taken_by_losing_additionalprimaryweapon[2]);
			}

			dual_wield_name = WeaponDualWieldWeaponName( self.weapon_taken_by_losing_additionalprimaryweapon[0] );
			if ( "none" != dual_wield_name )
			{
				if(self GetWeaponAmmoClip(dual_wield_name) < self.weapon_taken_by_losing_additionalprimaryweapon[3])
				{
					self SetWeaponAmmoClip(dual_wield_name, self.weapon_taken_by_losing_additionalprimaryweapon[3]);
				}
			}
		}

		self.weapon_taken_by_losing_additionalprimaryweapon = [];
		return;
	}

	if(self HasWeapon(unupgrade_name))
	{
		self TakeWeapon(unupgrade_name);
	}

	index = maps\_zombiemode_weapons::get_upgraded_weapon_model_index(self.weapon_taken_by_losing_additionalprimaryweapon[0]);

	self GiveWeapon(self.weapon_taken_by_losing_additionalprimaryweapon[0], index, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( self.weapon_taken_by_losing_additionalprimaryweapon[0] ));
	self SetWeaponAmmoClip(self.weapon_taken_by_losing_additionalprimaryweapon[0], self.weapon_taken_by_losing_additionalprimaryweapon[1]);
	self SetWeaponAmmoStock(self.weapon_taken_by_losing_additionalprimaryweapon[0], self.weapon_taken_by_losing_additionalprimaryweapon[2]);
	dual_wield_name = WeaponDualWieldWeaponName( self.weapon_taken_by_losing_additionalprimaryweapon[0] );
	if ( "none" != dual_wield_name )
	{
		self SetWeaponAmmoClip( dual_wield_name, self.weapon_taken_by_losing_additionalprimaryweapon[3] );
	}

	wait_network_frame();

	if(!is_true(self.has_powerup_weapon))
	{
		self SwitchToWeapon(self.weapon_taken_by_losing_additionalprimaryweapon[0]);
	}

	self.weapon_taken_by_losing_additionalprimaryweapon = [];
}

check_player_has_perk(perk)
{
	self endon( "death" );
/#
	if ( GetDvarInt( #"zombie_cheat" ) >= 5 )
	{
		return;
	}
#/

	dist = 128 * 128;
	while(IsDefined(self))
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if(DistanceSquared( players[i].origin, self.origin ) < dist)
			{
				if (players[i] maps\_laststand::player_is_in_laststand() || is_true( players[i].intermission ) )
				{
					self SetInvisibleToPlayer(players[i], true);
				}
				else if(players[i] in_revive_trigger())
				{
					self SetInvisibleToPlayer(players[i], true);
				}
				else if( players[i] isThrowingGrenade() )
				{
					self SetInvisibleToPlayer(players[i], true);
				}
		 		else if( players[i] isSwitchingWeapons() )
		 		{
		 			self SetInvisibleToPlayer(players[i], true);
		 		}
				else if( players[i] is_drinking() )
				{
					self SetInvisibleToPlayer(players[i], true);
				} 
				else if( players[i].PRO_PERKS_DISABLED[ perk + "_upgrade"] ) 
				{
					self SetInvisibleToPlayer(players[i], true);
				}
				else if(!players[i] hasperk(perk) && !(players[i] in_revive_trigger()) && (!players[i] hacker_active()))
				{
					self SetInvisibleToPlayer(players[i], false);
				} 
				else if( !(  players[i] hasProPerk( perk + "_upgrade" ) ) )
				{
					//Reimagined-Expanded Upgraded Perks check
					self SetInvisibleToPlayer(players[i], false);
				}
				else
				{
					self SetInvisibleToPlayer(players[i], true);
				}
			}
		}
		wait(0.05);
	}
}



perk_think( perk )
{
/#
	if ( GetDvarInt( #"zombie_cheat" ) >= 5 )
	{
		if ( IsDefined( self.perk_hud[ perk ] ) )
		{
			return;
		}
	}
#/

	perk_str = perk + "_stop";
	result = self waittill_any_return( "fake_death", "death", "player_downed", perk_str );

	//Reimagined-Expanded perkapunch
	if( self hasProPerk( perk + "_upgrade" ) )
	{
		wait_network_frame();
		self update_perk_hud();
		self waittill( perk + "_stop" );
		for( i=0; i < level.ARRAY_VALID_PRO_PERKS.size; i++) 
		{
			if( level.ARRAY_VALID_PRO_PERKS[i] == perk ) {
				perk = level.ARRAY_VALID_PERKS[i];	//Get base perk name to remove
				break;
			}
		}
	}

	//always notify the perk stop string so we know to end perk specific stuff
	if(result != perk_str)
	{
		self notify(perk_str);
	}

	//iprintln( "Perk Lost: " + perk );
	self UnsetPerk( perk );
	self.num_perks--;

	switch(perk)
	{
		case "specialty_quickrevive":
			self SetClientDvar("cg_hudDamageIconTime", 2500);
			break;

		case "specialty_armorvest":
			self SetMaxHealth( self.preMaxHealth );
			break;

		case "specialty_fastreload":
			self UnsetPerk("specialty_fastswitch");
			//self UnsetPerk("specialty_fastads");
			//self UnsetPerk("specialty_fastoffhand");
			break;

		case "specialty_rof":
			self SetClientDvar("player_burstFireCoolDown", .2);
			break;
		
		case "specialty_endurance":
			self UnsetPerk("specialty_unlimitedsprint");
			break;

		case "specialty_additionalprimaryweapon":
			// only take weapon from here if perk is lost from a way besides downing
			// weapon is not taken properly from here if downed, so called in _zombiemode::player_laststand() instead
			if ( result == perk_str )
			{
				self.weapon_taken_by_losing_additionalprimaryweapon = self maps\_zombiemode::take_additionalprimaryweapon();
			}

			if(self HasPerk("specialty_stockpile"))
			{
				self remove_stockpile_ammo();
			}

			//self UnsetPerk("specialty_stockpile");
			self send_message_to_csc("hud_anim_handler", "hud_mule_wep_out");
			self SetClientDvar("ui_show_mule_wep_indicator", "0");
			break;

		case "specialty_deadshot":
			self ClearClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
			//self UnsetPerk("specialty_fastsprintrecovery");
			//self UnsetPerk("specialty_stalker");
			break;

		case "specialty_deadshot_upgrade":
			self ClearClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
			break;
	}

	//Reimagined-Expanded - don't destroy perk hud if pro perk is only disabled
	if( !self.PRO_PERKS_DISABLED[ perk + "_upgrade" ] )
		self perk_hud_destroy( perk );

	self.perk_purchased = undefined;
	//self //iprintln( "Perk Lost: " + perk );


	if ( IsDefined( level.perk_lost_func ) )
	{
		self [[ level.perk_lost_func ]]( perk );
	}

	self notify( "perk_lost" );
}


perk_hud_create( perk )
{
	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
		self.perk_hud_num = [];
	}

/#
	if ( GetDvarInt( #"zombie_cheat" ) >= 5 )
	{
		if ( IsDefined( self.perk_hud[ perk ] ) )
		{
			return;
		}
	}
#/
	//Protect against duplicate perks when pro perks reenabled
	if( IsDefined( self.perk_hud[ perk + "_upgrade" ] ) ) {
		return;
	}

	shader = "";
	switch( perk )
	{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload_upgrade":
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;

		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
		case "specialty_endurance_upgrade":
		case "specialty_endurance":
			shader = "specialty_marathon_zombies";
			break;

		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "specialty_divetonuke_zombies";
			break;

		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "specialty_deadshot_zombies";
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "specialty_mulekick_zombies";
			break;

		case "specialty_bulletaccuracy_upgrade":
		case "specialty_bulletaccuracy":
			shader = "specialty_chugabud_zombies";
			break;

		case "specialty_bulletdamage_upgrade":
		case "specialty_bulletdamage":
			shader = "specialty_cherry_zombies";
			break;

		case "specialty_altmelee_upgrade":
		case "specialty_altmelee":
			shader = "specialty_vulture_zombies";
			break;

		case "specialty_extraammo_upgrade":
		case "specialty_extraammo":
			shader = "specialty_widowswine_zombies";
			break;

		case "specialty_stockpile_upgrade":
		case "specialty_stockpile":
			shader = "specialty_bandolier_zombies";
			break;

		case "specialty_scavanger_upgrade":
		case "specialty_scavanger":
			shader = "specialty_timeslip_zombies";
			break;
			
		default:
			shader = "";
			break;
	}

	if( IsSubStr(perk , "upgrade") )
	{
		//here
		basePerk = GetSubStr( perk, 0, perk.size - 8); //remove "_upgrade"
		
		if( self.PRO_PERKS_DISABLED[ perk ] ) {	
			//Reenable disabled pro perk
			self.perk_hud[ basePerk ].alpha = 1;
		} else {
			//Set Pro Shader
			shader = shader + "_pro";
			self.perk_hud[ basePerk ] SetShader( shader, 24, 24 );
		}

		return;
	}

	if( self.PRO_PERKS_DISABLED[ perk + "_upgrade"] )
		return;
	
	//iprintln("shader: " + shader);

	hud = create_simple_hud( self );
	hud.foreground = true;
	hud.sort = 1;
	hud.hidewheninmenu = false;
	hud.alignX = "left";
	hud.alignY = "bottom";
	hud.horzAlign = "user_left";
	hud.vertAlign = "user_bottom";
	hud.x = (self.perk_hud.size * 30) + 4;
	hud.y -= 70;
	hud.alpha = 0;
	hud FadeOverTime(.5);
	hud.alpha = 1;
	hud SetShader( shader, 24, 24 );

	self.perk_hud[ perk ] = hud;
	self.perk_hud_num[self.perk_hud_num.size] = perk;

	//self update_perk_hud();
}


perk_hud_destroy( perk )
{
	self.perk_hud_num = array_remove_nokeys(self.perk_hud_num, perk);
	self.perk_hud[ perk ] destroy_hud();
	self.perk_hud[ perk ] = undefined;
}

perk_hud_flash(damage)
{
	self endon( "death" );

	self.flash = 1;
	self ScaleOverTime( 0.05, 32, 32 );
	wait( 0.3 );
	self ScaleOverTime( 0.05, 24, 24 );
	wait( 0.3 );
	self.flash = 0;
}

perk_flash_audio( perk )
{
    alias = undefined;

    switch( perk )
    {
        case "specialty_armorvest":
            alias = "zmb_hud_flash_jugga";
            break;

        case "specialty_quickrevive":
            alias = "zmb_hud_flash_revive";
            break;

        case "specialty_fastreload":
        case "specialty_rof":
            alias = "zmb_hud_flash_speed";
            break;

        case "specialty_endurance":
            alias = "zmb_hud_flash_stamina";
            break;

        case "specialty_flakjacket":
            alias = "zmb_hud_flash_phd";
            break;

        case "specialty_deadshot":
            alias = "zmb_hud_flash_deadshot";
            break;

        case "specialty_additionalprimaryweapon":
            alias = "zmb_hud_flash_additionalprimaryweapon";
            break;
    }

    if( IsDefined( alias ) )
        self PlayLocalSound( alias );
}

perk_hud_start_flash( perk, damage )
{
	if ( self HasPerk( perk ) && isdefined( self.perk_hud ) )
	{
		hud = self.perk_hud[perk];
		if ( isdefined( hud ) )
		{
			if ( !is_true( hud.flash ) )
			{
				hud thread perk_hud_flash(damage);
				self thread perk_flash_audio( perk );
			}
		}
	}
}

perk_hud_stop_flash( perk, taken )
{
	if ( self HasPerk( perk ) && isdefined( self.perk_hud ) )
	{
		hud = self.perk_hud[perk];
		if ( isdefined( hud ) )
		{
			hud.flash = undefined;
			if ( isdefined( taken ) )
			{
				hud notify( "stop_flash_perk" );
			}
		}
	}
}

perk_give_bottle_begin( perk )
{
	self increment_is_drinking();

	self AllowLean( false );
	self AllowAds( false );
	self AllowSprint( false );
	self AllowCrouch( true );
	self AllowProne( false );
	self AllowMelee( false );

	wait( 0.05 );

	if ( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}

	gun = self GetCurrentWeapon();
	weapon = "";
	modelIndex=0;

	switch( perk )
	{
	case "specialty_armorvest_upgrade":
	case "specialty_armorvest":
		weapon = "zombie_perk_bottle_jugg";
		modelIndex = 0;
		break;

	case "specialty_quickrevive_upgrade":
	case "specialty_quickrevive":
		weapon = "zombie_perk_bottle_revive";
		modelIndex = 1;
		break;

	case "specialty_fastreload_upgrade":
	case "specialty_fastreload":
		weapon = "zombie_perk_bottle_sleight";
		modelIndex = 2;
		break;

	case "specialty_rof_upgrade":
	case "specialty_rof":
		weapon = "zombie_perk_bottle_doubletap";
		modelIndex = 3;
		break;

	case "specialty_endurance_upgrade":
	case "specialty_endurance":
		weapon = "zombie_perk_bottle_marathon";
		modelIndex = 4;
		break;

	case "specialty_flakjacket_upgrade":
	case "specialty_flakjacket":
		weapon = "zombie_perk_bottle_nuke";
		modelIndex = 5;
		break;

	case "specialty_deadshot_upgrade":
	case "specialty_deadshot":
		weapon = "zombie_perk_bottle_deadshot";
		modelIndex = 6;
		break;

	case "specialty_additionalprimaryweapon_upgrade":
	case "specialty_additionalprimaryweapon":
		weapon = "zombie_perk_bottle_additionalprimaryweapon";
		modelIndex = 7;
		break;

	case "specialty_bulletdamage": // ww: cherry
	case "specialty_bulletdamage_upgrade":
		weapon = "t6_wpn_zmb_perk_bottle_cherry";
		modelIndex = 8;
		break;

	case "specialty_altmelee": // ww: vulture
	case "specialty_altmelee_upgrade":
		weapon = "t6_wpn_zmb_perk_bottle_vulture";
		modelIndex = 9;
		break;

	case "specialty_extraamo": // ww: wine
	case "specialty_extraamo_upgrade":
		weapon = "bo3_widows_wine_bottle";
		modelIndex = 10;
		break;
	}

	self GiveWeapon( "zombie_perk_bottle", modelIndex );
	//self GiveWeapon( weapon );
	//self SwitchToWeapon( weapon );
	self SwitchToWeapon( "zombie_perk_bottle" );

	//Reimagined-Expanded - bonus fx on upgraded perk
	if( IsSubStr( perk, "_upgrade" ) ) {
		self thread upgrade_perk_fx();
	}

	return gun;
}

upgrade_perk_fx()
{
	weap = self GetCurrentWeapon();

	//model = Spawn( "script_model", self GetTagOrigin( "tag_flash" ) );
	model = Spawn( "script_model", self GetTagOrigin( "j_neck" ) );
	model setModel( "tag_origin" );
	model LinkTo( self, "tag_origin" );
	//model LinkTo( self, "tag_flash" );

	PlayFXOnTag( level._effect["powerup_on_solo"], model, "tag_origin" );
	self waittill( "weapon_change_complete");
	
	model delete();
}

perk_give_bottle_end( gun, perk )
{
	assert( gun != "zombie_perk_bottle_doubletap" );
	assert( gun != "zombie_perk_bottle_jugg" );
	assert( gun != "zombie_perk_bottle_revive" );
	assert( gun != "zombie_perk_bottle_sleight" );
	assert( gun != "zombie_perk_bottle_marathon" );
	assert( gun != "zombie_perk_bottle_nuke" );
	assert( gun != "zombie_perk_bottle_deadshot" );
	assert( gun != "zombie_perk_bottle_additionalprimaryweapon" );
	assert( gun != "syrette_sp" );

	self AllowLean( true );
	self AllowAds( true );
	self AllowSprint( true );
	self AllowProne( true );
	self AllowMelee( true );
	weapon = "";
	switch( perk )
	{
	case "specialty_rof_upgrade":
	case "specialty_rof":
		weapon = "zombie_perk_bottle_doubletap";
		break;

	case "specialty_endurance_upgrade":
	case "specialty_endurance":
		weapon = "zombie_perk_bottle_marathon";
		break;

	case "specialty_flakjacket_upgrade":
	case "specialty_flakjacket":
		weapon = "zombie_perk_bottle_nuke";
		break;

	case "specialty_armorvest_upgrade":
	case "specialty_armorvest":
		weapon = "zombie_perk_bottle_jugg";
		self.jugg_used = true;
		break;

	case "specialty_quickrevive_upgrade":
	case "specialty_quickrevive":
		weapon = "zombie_perk_bottle_revive";
		break;

	case "specialty_fastreload_upgrade":
	case "specialty_fastreload":
		weapon = "zombie_perk_bottle_sleight";
		self.speed_used = true;
		break;

	case "specialty_deadshot_upgrade":
	case "specialty_deadshot":
		weapon = "t6_wpn_zmb_perk_bottle_deadshot";
		break;

	case "specialty_additionalprimaryweapon_upgrade":
	case "specialty_additionalprimaryweapon":
		weapon = "t6_wpn_zmb_perk_bottle_mule_kick";
		break;

	case "specialty_bulletdamage": // ww: cherry
	case "specialty_bulletdamage_upgrade":
		weapon = "t6_wpn_zmb_perk_bottle_cherry";
		break;

	case "specialty_altmelee": // ww: vulture
	case "specialty_altmelee_upgrade":
		weapon = "t6_wpn_zmb_perk_bottle_vulture";
		break;

	case "specialty_extraamo": // ww: wine
	case "specialty_extraamo_upgrade":
		weapon = "bo3_widows_wine_bottle";
		break;
	}

	// TODO: race condition?
	if ( self maps\_laststand::player_is_in_laststand() || is_true( self.intermission ) )
	{
		self TakeWeapon(weapon);
		//self TakeWeapon("zombie_perk_bottle");
		return;
	}

	//iprintln("give perk: " + perk);
	self give_perk(perk, true);

	if(self HasWeapon(gun) && is_placeable_mine(gun) && self GetWeaponAmmoClip(gun) == 0)
	{
		gun = "none";
	}

	//iprintln("taking weapon line 2681: " + weapon);
	self TakeWeapon(weapon);

	if( self is_multiple_drinking() )
	{
		self decrement_is_drinking();
		return;
	}
	else if( gun != "none" && !is_equipment( gun ) && self HasWeapon(gun) )
	{
		self SwitchToWeapon( gun );
		// ww: the knives have no first raise anim so they will never get a "weapon_change_complete" notify
		// meaning it will never leave this funciton and will break buying weapons for the player
		if( is_melee_weapon( gun ) )
		{
			self decrement_is_drinking();
			return;
		}
	}
	else
	{
		// try to switch to first primary weapon
		primaryWeapons = self GetWeaponsListPrimaries();
		if(IsDefined(self.last_held_primary_weapon) && self HasWeapon(self.last_held_primary_weapon))
		{
			self SwitchToWeapon(self.last_held_primary_weapon);
		}
		else if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
		else
		{
			self SwitchToWeapon( "combat_" + self get_player_melee_weapon() );
		}
	}

	self waittill( "weapon_change_complete" );

	if ( !self maps\_laststand::player_is_in_laststand() && !is_true( self.intermission ) )
	{
		self decrement_is_drinking();
	}
}

give_random_perk()
{
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	perks = [];
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[i].script_noteworthy;

		if(perk == "specialty_bulletaccuracy") //babyjugg
			continue;

		if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}

		if ( !self HasPerk( perk ) )
		{
			perks[ perks.size ] = perk;
		}
	}

	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		self give_perk( perks[0] );
	}
}


lose_random_perk()
{
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	perks = [];
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[i].script_noteworthy;

		if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}

		if ( self HasPerk( perk ) )
		{
			perks[ perks.size ] = perk;
		}
	}

	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		perk = perks[0];

		perk_str = perk + "_stop";
		self notify( perk_str );

		/*if ( flag( "solo_game" ) && perk == "specialty_quickrevive" )
		{
			self.lives--;
		}*/
	}
}

update_perk_hud()
{
	if ( isdefined( self.perk_hud ) )
	{
		for ( i = 0; i < self.perk_hud_num.size; i++ )
		{
			self.perk_hud[ self.perk_hud_num[i] ].x = (i * 30) + 4;
		}
	}
}

quantum_bomb_give_nearest_perk_validation( position )
{
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	range_squared = 180 * 180; // 15 feet
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		//dont give perk if perk isnt on
		perk = vending_triggers[i].script_noteworthy;
		if(!flag( "power_on" ) && perk != "specialty_fastreload" && perk != "specialty_armorvest") /*&& (!(flag( "solo_game" ) && perk == "specialty_quickrevive"))*/
		{
			continue;
		}

		if ( DistanceSquared( vending_triggers[i].origin, position ) < range_squared )
		{
			perk = vending_triggers[i].script_noteworthy;
			if ( !self HasPerk( perk ) && ( !isdefined( self.perk_purchased ) || self.perk_purchased != perk) )
			{
				return true;
			}
		}
	}

	return false;
}


quantum_bomb_give_nearest_perk_result( position )
{
	[[level.quantum_bomb_play_mystery_effect_func]]( position );

	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	nearest = 0;
	for ( i = 1; i < vending_triggers.size; i++ )
	{
		if ( DistanceSquared( vending_triggers[i].origin, position ) < DistanceSquared( vending_triggers[nearest].origin, position ) )
		{
			nearest = i;
		}
	}

	players = getplayers();
	perk = vending_triggers[nearest].script_noteworthy;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( player.sessionstate == "spectator" || player maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if ( !player HasPerk( perk ) && ( !isdefined( player.perk_purchased ) || player.perk_purchased != perk) )
		{
			if( player == self )
			{
				self thread maps\_zombiemode_audio::create_and_play_dialog( "kill", "quant_good" );
				player give_perk( perk );
				player [[level.quantum_bomb_play_player_effect_func]]();
			}
		}
	}
}

unsave_additional_weapon_on_bleedout()
{
	self notify("additionalprimaryweapon bought");
	self endon("additionalprimaryweapon bought");
	while(1)
	{
		self waittill("bled_out");
		self.weapon_taken_by_losing_additionalprimaryweapon = [];
	}
}

additional_weapon_indicator(perk, perk_str)
{
	self endon("disconnect");
	self endon(perk_str);

	indicated = false;
	self.weapon_slots = [];

	while(1)
	{
		if(self maps\_laststand::player_is_in_laststand())
		{
			self SetClientDvar("ui_show_mule_wep_indicator", "0");
			self send_message_to_csc("hud_anim_handler", "hud_mule_wep_out");
			self waittill("player_revived");
			self SetClientDvar("ui_show_mule_wep_indicator", "1");
		}

		additional_wep = undefined;

		primary_weapons_that_can_be_taken = [];
		primaryWeapons = self GetWeaponsListPrimaries();
		for ( i = 0; i < primaryWeapons.size; i++ )
		{
			if((primaryWeapons[i] == "tesla_gun_zm" || primaryWeapons[i] == "tesla_gun_upgraded_zm") && IsDefined(self.has_tesla) && self.has_tesla)
			{
				continue;
			}

			if ( maps\_zombiemode_weapons::is_weapon_included( primaryWeapons[i] ) || maps\_zombiemode_weapons::is_weapon_upgraded( primaryWeapons[i] ) )
			{
				primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size] = primaryWeapons[i];
			}
		}

		if(!IsDefined(self.weapon_slots))
		{
			self.weapon_slots = primary_weapons_that_can_be_taken;
		}

		//remove any weps player no longer has
		for(i=0;i<self.weapon_slots.size;i++)
		{
			if(!self HasWeapon(self.weapon_slots[i]))
			{
				self.weapon_slots[i] = "none";
			}
		}

		//add any new weps
		for(j=0;j<primary_weapons_that_can_be_taken.size;j++)
		{
			if(!is_in_array(self.weapon_slots, primary_weapons_that_can_be_taken[j]))
			{
				undefined_wep_slot = false;
				for(i=0;i<self.weapon_slots.size;i++)
				{
					if(self.weapon_slots[i] == "none")
					{
						self.weapon_slots[i] = primary_weapons_that_can_be_taken[j];
						undefined_wep_slot = true;
						break;
					}
				}

				if(!undefined_wep_slot)
				{
					self.weapon_slots[self.weapon_slots.size] = primary_weapons_that_can_be_taken[j];
				}
			}
		}

		//check to see if any weapon slots are empty
		count = 0;
		for(i=0;i<self.weapon_slots.size;i++)
		{
			if(self.weapon_slots[i] != "none")
			{
				count++;
			}
		}

		if ( count >= 3 )
			additional_wep = self.weapon_slots[self.weapon_slots.size - 1];

		current_wep = self GetCurrentWeapon();

		if(IsDefined(additional_wep) && (current_wep == additional_wep || current_wep == WeaponAltWeaponName(additional_wep)))
		{
			self send_message_to_csc("hud_anim_handler", "hud_mule_wep_in");
			wait(1);
			self send_message_to_csc("hud_anim_handler", "hud_mule_wep_out");
		}

		self waittill_any("weapon_change", "weapon_change_complete");
	}
}

move_faster_while_ads(perk_str)
{
	self endon("disconnect");
	self endon(perk_str);

	set = false;
	if(!IsDefined(self.move_speed))
	{
		self.move_speed = 1;
	}
	previous_ads = 0;
	initial_ads = 0;

	while(1)
	{
		current_ads = self PlayerADS();
		//iprintln(current_ads);
		if(current_ads == 0 || previous_ads > current_ads || self.still_reloading) // || self.is_reloading
		{
			if(set)
			{
				set = false;
				self SetMoveSpeedScale(self.move_speed);
			}
		}
		//as current_ads goes from 0 to 1, move_speed_increase should go from 1 to its max value
		//example: if current_ads is .5 and move_speed_increase is 2.5 and self.move_speed is 1, the result should be 1.75
		else
		{
			if(!set)
			{
				set = true;
				initial_ads = previous_ads;
			}
			//only increase move speed during ads if the player was initially not ads, or else they will move faster than intended
			if(current_ads < 1 && initial_ads != 0)
			{
				previous_ads = current_ads;
				wait .001;
				continue;
			}

			wep = self GetCurrentWeapon();
			class = WeaponClass(wep);
			move_speed_increase = 1;
			if(class == "pistol" || class == "smg")
			{
				if(IsSubStr(wep, "ppsh") || IsSubStr(wep, "mp40") || IsSubStr(wep, "ray_gun"))
				{
					move_speed_increase = 2.5;
				}
				else
				{
					move_speed_increase = 1.25;
				}
			}
			else if(class == "spread")
			{
				if(IsSubStr(wep, "ithaca"))
				{
					move_speed_increase = 1.25;
				}
				else
				{
					move_speed_increase = 2.5;
				}
			}
			else if(class == "rocketlauncher" || class == "grenade")
			{
				move_speed_increase = 2;
			}
			else if(class == "mg")
			{
				move_speed_increase = 2.2;
			}
			else if(class == "rifle")
			{
				if(IsSubStr(wep, "sniper_explosive"))
				{
					move_speed_increase = 2.25;
				}
				else if(IsSubStr(wep, "humangun") || IsSubStr(wep, "shrink_ray") || IsSubStr(wep, "microwavegun"))
				{
					move_speed_increase = 2.5;
				}
				else
				{
					move_speed_increase = 2.5;
				}
			}

			//if not fully ads, only increase move speed partially based off how far ads the player is
			if(current_ads < 1)
			{
				move_speed_increase = 1 + ((move_speed_increase - 1) * current_ads);
			}
			self SetMoveSpeedScale(self.move_speed * move_speed_increase);
		}
		previous_ads = current_ads;
		wait .01;
	}
}

remove_stockpile_ammo()
{
	primary_weapons = self GetWeaponsList();
	for(i = 0; i < primary_weapons.size; i++)
	{
		if(self GetWeaponAmmoStock(primary_weapons[i]) > WeaponMaxAmmo(primary_weapons[i]))
		{
			self SetWeaponAmmoStock(primary_weapons[i], WeaponMaxAmmo(primary_weapons[i]));
		}
	}
}

//=========================================================================================================
// QUICKREV PRO
//=========================================================================================================


//Reimagined-Expanded -- Quick Revive pro thread running for each player
// HANDLED IN ZOMBIEMODE


//=========================================================================================================
// JUGG PRO
//=========================================================================================================

watch_armorvest_upgrade(perk_str)
{
	oldHealth = self.preMaxHealth;
	self.preMaxHealth =  level.VALUE_JUGG_PRO_MAX_HEALTH;
	self endon("disconnect");

	self waittill(perk_str);

	self.preMaxHealth = oldHealth;
	self.health = oldHealth;
	self SetMaxHealth( oldHealth );
}


//=========================================================================================================
// STAMINA PRO
//=========================================================================================================


//Reimagined-Expanded -- Stamina Upgraded
watch_stamina_upgrade(perk_str)
{
	self endon("disconnect");
	self endon(perk_str);

	while(1)
	{

		//wait till player sprints
		waittill_return = self waittill_any_return("melee", "damage");

		self waittill_notify_or_timeout("sprint", level.VALUE_STAMINA_PRO_SPRINT_WINDOW );
		if( ! self IsSprinting() )
			continue;
		
		self thread activate_stamina_ghost_mode();

		wait(level.COOLDOWN_STAMINA_PRO_GHOST);
	}

}

	activate_stamina_ghost_mode()
	{
		//give player zombie blood
		totaltime = level.TOTALTIME_STAMINA_PRO_GHOST;
		self.ignoreme = true;
		self VisionSetNaked( "zombie_blood", 0.5 );
		self setMoveSpeedScale( self.moveSpeed + 0.3 );
		self send_message_to_csc("hud_anim_handler", "stamina_ghost_start");
		
		//attacker thread maps\sb_bo2_zombie_blood_powerup::zombie_blood_powerup( attacker, 2);
		//make nearby zombies immune to player collision
		self thread managePlayerZombieCollisions( totaltime ,
		 level.VALUE_STAMINA_PRO_GHOST_RANGE ); //total time, dist

		wait( totaltime - 0.5 );
		self.ignoreme = false;
		
		self setMoveSpeedScale( self.moveSpeed - 0.3 );
		self send_message_to_csc("hud_anim_handler", "stamina_ghost_end");

		if( IsDefined( level.zombie_visionset ) )
			self VisionSetNaked( level.zombie_visionset, 0.5 );
		else
			self VisionSetNaked( "undefined", 0.5 );
	}

	checkDist(a, b, distance )
	{
		return maps\_zombiemode::checkDist( a, b, distance );
	}

	managePlayerZombieCollisions( totaltime, dist )
	{
		//Get all zombies near player
		zombies = maps\_zombiemode::getZombiesInRange( dist );

		for(i=0;i<zombies.size;i++) {
			zombies[i] thread maps\_zombiemode::setZombiePlayerCollisionOff( self, totaltime-0.1, 80 );
		}

		wait( totaltime );
		
		for(i=0;i<zombies.size;i++) {
			zombies[i] SetPlayerCollision( 1 );
		} 

	}	



//=========================================================================================================
// SPEED PRO
//=========================================================================================================


//Reimagined-Expanded -- Speed Upgraded
watch_fastreload_upgrade(perk_str)
{
	self endon("disconnect");
	self endon(perk_str);

	while(1)
	{
		if(self.specialty_fastreload_upgrade)
		{
			//wait till player switches weapons
			self waittill("weapon_switch_complete");
			//iprintln("Observed weapon switch");	

			self thread magicReload();
		}
		wait(0.1);
	}

}

magicReload()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon("weapon_switch");

	//this is the weapon we skip reload
	primary = self getcurrentweapon();
	weapons = self GetWeaponsListPrimaries();
	wait(level.COOLDOWN_SPEED_PRO_RELOAD);
	for(i=0;i<weapons.size;i++)
	{
		clip = self GetWeaponAmmoClip( weapons[i] );
		clipSize = WeaponClipSize(weapons[i]);

		stock = self GetWeaponAmmoStock( weapons[i] );
		diff = clipSize - clip;

		if(stock - diff < 0)
			diff = stock;
		
		if(weapons[i] == primary || diff == 0 || stock == 0)
			continue;

		self SetWeaponAmmoClip(weapons[i], clip + diff);
		self SetWeaponAmmoStock(weapons[i], stock - diff);		
	}

}


//=========================================================================================================
// DEADSHOT PRO
//=========================================================================================================


trigger_deadshot_pro_hitmarker( hitWeakpoint )
{
	if( !IsDefined( level.sound_num ) )
		level.sound_num = 0;

	level.sound_num++;
	level.sound_num = level.sound_num % 5;
	//iprintln("sound_num: " + level.sound_num);
	if( hitWeakpoint ) 
	{
		//play the sound 2 times
		self playlocalsound( "MP_hit_alert" );
		self playlocalsound( "prj_bullet_impact_headshot_helmet_nodie" );	//Working from base base game
		
		self.hud_damagefeedback_death.alpha = 1;
		self.hud_damagefeedback_death fadeOverTime( 1 );
		self.hud_damagefeedback_death.alpha = 0;

	} else {

		//self playlocalsound( "MP_hit_indication" );
		self playlocalsound( "MP_hit_alert" );
		//self playlocalsound( "hitmarker" );

		self.hud_damagefeedback.alpha = 1;
		self.hud_damagefeedback fadeOverTime( 1 );
		self.hud_damagefeedback.alpha = 0;
	}

}



//=========================================================================================================
// PHD PRO
//=========================================================================================================

watch_phd_upgrade(perk_str)
{
	self endon("disconnect");
	self endon(perk_str);

	while(1)
	{
		self waittill("sprint");
		while( self IsSprinting() ) {
			wait_network_frame();
		}

		if( IsDefined( self.divetoprone ) && self.divetoprone == 1) 
		{
			self thread managePlayerZombieCollisions( level.TOTALTIME_PHD_PRO_COLLISIONS ,
			 level.VALUE_PHD_PRO_COLLISIONS_RANGE ); //total time, dist

			 //while( self.divetoprone == 1 ) { wait_network_frame();}
			 wait( 0.75 );

			 if ( IsDefined( level.zombiemode_divetonuke_perk_func ) )
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );
		}

		wait(0.1);
	}

}


/*

//=========================================================================================================
// Electric Cherry
//=========================================================================================================
#using_animtree( "generic_human" );

init_electric_cherry()
{
	level._effect[ "electric_cherry_explode" ] = LoadFX( "sanchez/electric_cherry/cherry_shock_large" );
	level._effect[ "electric_cherry_reload_small" ] = LoadFX( "sanchez/electric_cherry/cherry_shock_large" );
	level._effect[ "electric_cherry_reload_medium" ] = LoadFX( "sanchez/electric_cherry/cherry_shock_large" );
	level._effect[ "electric_cherry_reload_large" ] = LoadFX( "sanchez/electric_cherry/cherry_shock_large" );
	level._effect[ "tesla_shock" ] = LoadFX( "maps/zombie/fx_zombie_tesla_shock" );
	level._effect[ "tesla_shock_secondary" ] = LoadFX( "maps/zombie/fx_zombie_tesla_shock_secondary" );
	//level.custom_laststand_func = ::electric_cherry_laststand;
	set_zombie_var( "tesla_head_gib_chance", 50 );
	//OnPlayerConnect_Callback( ::on_player_spawned );
	level.electric_stun = [];
	level.electric_stun[0] = %ai_zombie_afterlife_stun_a;
	level.electric_stun[1] = %ai_zombie_afterlife_stun_b;
	level.electric_stun[2] = %ai_zombie_afterlife_stun_c;
	level.electric_stun[3] = %ai_zombie_afterlife_stun_d;
	level.electric_stun[4] = %ai_zombie_afterlife_stun_e;
}

/*
on_player_spawned()
{
	while( true )
	{
		self waittill( "spawned_player" );
		self thread init_electric_cherry_reload_fx();
	}
}
/

init_electric_cherry_reload_fx()
{
	wait 1;
	self SetClientFlag( level._ZOMBIE_PLAYER_FLAG_DIVE2NUKE_VISION );
}

/*
electric_cherry_laststand()
{
	VisionSetLastStand( "zombie_last_stand", 1 );
	if( IsDefined( self ) )
	{
		PlayFX( level._effect[ "electric_cherry_explode" ], self.origin );
		self PlaySound( "zmb_cherry_explode" );
		self notify( "electric_cherry_start" );
		wait 0.05;
		a_zombies = GetAISpeciesArray( "axis", "all" );
		a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, 500 );
		for( i = 0; i < a_zombies.size; i ++ )
		{
			if( IsAlive( self ) )
			{
				if( a_zombies[i].health <= 1000 )
				{
					a_zombies[i] thread electric_cherry_death_fx();
					if( IsDefined( self.cherry_kills ) )
					{
						self.cherry_kills ++;
					}
					self maps\_zombiemode_score::add_to_player_score( 40 );
				}
				else
				{
					a_zombies[i] thread electric_cherry_stun();
					a_zombies[i] thread electric_cherry_shock_fx();
				}
				wait 0.1;
				a_zombies[i] DoDamage( 1000, self.origin, self, self );
			}
		}
		self notify( "electric_cherry_end" );
	}
}
/

electric_cherry_death_fx()
{
	self endon( "death" );
	tag = "J_SpineUpper";
	fx = "tesla_shock";
	if( self.isdog )
	{
		tag = "J_Spine1";
	}
	self PlaySound( "zmb_elec_jib_zombie" );
	network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[ fx ], self, tag );
	if( IsDefined( self.tesla_head_gib_func ) && !self.head_gibbed )
	{
		[[ self.tesla_head_gib_func ]]();
	}
}

electric_cherry_shock_fx()
{
	self endon( "death" );
	tag = "J_SpineUpper";
	fx = "tesla_shock_secondary";
	if( self.isdog )
	{
		tag = "J_Spine1";
	}
	self PlaySound( "zmb_elec_jib_zombie" );
	network_safe_play_fx_on_tag( "tesla_shock_fx", 2, level._effect[ fx ], self, tag );
}

electric_cherry_stun()
{
	self endon( "death" );
	self notify( "stun_zombie" );
	self endon( "stun_zombie" );
	if( self.health <= 0 )
	{
		return;
	}
	if( !self.has_legs )
	{
		return;
	}
	if( self.animname != "zombie" )
	{
		return;
	}
	self.forcemovementscriptstate = true;
	self.ignoreall = true;
	for( i = 0; i < 2; i ++ )
	{
		self AnimScripted( "stunned", self.origin, self.angles, random( level.electric_stun ) );
		self animscripts\zombie_shared::DoNoteTracks( "stunned" );
	}
	self.forcemovementscriptstate = false;
	self.ignoreall = true;
	self SetGoalPos( self.origin );
	self thread maps\_zombiemode_spawner::find_flesh();
}

electric_cherry_reload_attack()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "stop_electric_cherry_reload_attack" );
	self.wait_on_reload = [];
	self.consecutive_electric_cherry_attacks = 0;
	while( true )
	{
		self waittill( "reload_start" );
		str_current_weapon = self GetCurrentWeapon();
		if( is_in_array( self.wait_on_reload, str_current_weapon ) )
		{
			continue;
		}
		self.wait_on_reload[ self.wait_on_reload.size ] = str_current_weapon;
		self.consecutive_electric_cherry_attacks ++;
		n_clip_current = self GetWeaponAmmoClip( str_current_weapon );
		n_clip_max = WeaponClipSize( str_current_weapon );
		n_fraction = n_clip_current / n_clip_max;
		perk_radius = linear_map( n_fraction, 1, 0, 32, 128 );
		perk_dmg = linear_map( n_fraction, 1, 0, 1, 1045 );
		self thread check_for_reload_complete( str_current_weapon );
		if( IsDefined( self ) )
		{
			switch( self.consecutive_electric_cherry_attacks )
			{
				case 0:
				case 1:
					n_zombie_limit = undefined;
					break;

				case 2:
					n_zombie_limit = 8;
					break;

				case 3:
					n_zombie_limit = 4;
					break;

				case 4:
					n_zombie_limit = 2;
					break;

				default:
					n_zombie_limit = 0;
					break;
			}
			self thread electric_cherry_cooldown_timer( str_current_weapon );
			if( IsDefined( n_zombie_limit ) && n_zombie_limit == 0 )
			{
				continue;
			}
			self thread electric_cherry_reload_fx( n_fraction );
			self notify( "electric_cherry_start" );
			self PlaySound( "zmb_cherry_explode" );
			a_zombies = GetAISpeciesArray( "axis", "all" );
			a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, perk_radius );
			n_zombies_hit = 0;
			for( i = 0; i < a_zombies.size; i ++ )
			{
				if( IsAlive( self ) && IsAlive( a_zombies[i] ) && a_zombies[i].animName != "bo2_zm_mech" && a_zombies[i].animName != "kf2_scrake" && a_zombies[i].animName != "bo1_simianaut" )
				{
					if( IsDefined( n_zombie_limit ) )
					{
						if( n_zombies_hit < n_zombie_limit )
						{
							n_zombies_hit ++;
						}
						else
						{
							break;
						}
					}
					if( a_zombies[i].health <= perk_dmg )
					{
						a_zombies[i] thread electric_cherry_death_fx();
						if( IsDefined( self.cherry_kills ) )
						{
							self.cherry_kills ++;
						}
						self maps\_zombiemode_score::add_to_player_score( 40 );
					}
					else
					{
						if( !IsDefined( a_zombies[i].is_brutus ) )
						{
							a_zombies[i] thread electric_cherry_stun();
						}
						a_zombies[i] thread electric_cherry_shock_fx();
					}
					wait 0.1;
					a_zombies[i] DoDamage( perk_dmg, self.origin, self, self );
				}
			}
			self notify( "electric_cherry_end" );
		}
	}
}

electric_cherry_cooldown_timer( str_current_weapon )
{
	self notify( "electric_cherry_cooldown_started" );
	self endon( "electric_cherry_cooldown_started" );
	self endon( "death" );
	self endon( "disconnect" );
	n_reload_time = WeaponReloadTime( str_current_weapon );
	if( self HasPerk( "specialty_fastreload" ) )
	{
		n_reload_time *= GetDvarFloat( "perk_weapReloadMultiplier" );
	}
	n_cooldown_time = n_reload_time + 3;
	wait n_cooldown_time;
	self.consecutive_electric_cherry_attacks = 0;
}

check_for_reload_complete( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "player_lost_weapon_" + weapon );
	self thread weapon_replaced_monitor( weapon );
	while( true )
	{
		self waittill( "reload" );
		str_current_weapon = self GetCurrentWeapon();
		if( str_current_weapon == weapon )
		{
			self.wait_on_reload = array_remove_nokeys( self.wait_on_reload, weapon );
			self notify( "weapon_reload_complete_" + weapon );
			return;
		}
	}
}

weapon_replaced_monitor( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_reload_complete_" + weapon );
	while( true )
	{
		self waittill( "weapon_change" );
		primaryweapons = self GetWeaponsListPrimaries();
		if( !is_in_array( primaryweapons, weapon ) )
		{
			self notify( "player_lost_weapon_" + weapon );
			self.wait_on_reload = array_remove_nokeys( self.wait_on_reload, weapon );
			return;
		}
	}
}

electric_cherry_reload_fx( n_fraction )
{
	if( n_fraction >= 0.67 )
	{
		setClientSysState( "levelNotify", "cherry_fx_small_" + self GetEntityNumber() );
	}
	else if( n_fraction >= 0.33 && n_fraction < 0.67 )
	{
		setClientSysState( "levelNotify", "cherry_fx_medium_" + self GetEntityNumber() );
	}
	else
	{
		setClientSysState( "levelNotify", "cherry_fx_large_" + self GetEntityNumber() );
	}
	wait 1;
	setClientSysState( "levelNotify", "cherry_fx_cancel_" + self GetEntityNumber() );
}

electric_cherry_perk_lost()
{
	self notify( "stop_electric_cherry_reload_attack" );
}

*/




//=========================================================================================================
// Vulture Aid
//=========================================================================================================

/*
vulture_player_connect_callback()
{
	self thread end_game_turn_off_vulture_overlay();
	self thread watch_vulture_shader_glow();
}

end_game_turn_off_vulture_overlay()
{
	self endon( "disconnect" );
	level waittill( "end_game" );
	self thread take_vulture_perk();
}

init_vulture()
{
	PreCacheShader( "hud_vulture_aid_stink" );
	PreCacheShader( "hud_vulture_aid_stink_outline" );
	PreCacheModel( "p6_zm_perk_vulture_ammo" );
	PreCacheModel( "p6_zm_perk_vulture_points" );
	level._effect[ "vulture_perk_zombie_stink" ] = LoadFX( "sanchez/vulture/fx_zm_vulture_perk_stink" );
	level._effect[ "vulture_perk_zombie_stink_trail" ] = LoadFX( "sanchez/vulture/fx_zm_vulture_perk_stink_trail" );
	level._effect[ "vulture_perk_bonus_drop" ] = LoadFX( "sanchez/vulture/fx_zombie_powerup_vulture" );
	level._effect[ "vulture_drop_picked_up" ] = LoadFX( "misc/fx_zombie_powerup_grab" );
	level._effect[ "vulture_perk_wallbuy_static" ] = LoadFX( "sanchez/vulture/vulture_wallgun_glow" );
	level._effect[ "vulture_perk_machine_glow_doubletap" ] = LoadFX( "sanchez/vulture/vulture_dtap_glow" );
	level._effect[ "vulture_perk_machine_glow_juggernog" ] = LoadFX( "sanchez/vulture/vulture_jugg_glow" );
	level._effect[ "vulture_perk_machine_glow_revive" ] = LoadFX( "sanchez/vulture/vulture_revive_glow" );
	level._effect[ "vulture_perk_machine_glow_speed" ] = LoadFX( "sanchez/vulture/vulture_speed_glow" );
	level._effect[ "vulture_perk_machine_glow_marathon" ] = LoadFX( "sanchez/vulture/vulture_stamin_glow" );
	level._effect[ "vulture_perk_machine_glow_mule_kick" ] = LoadFX( "sanchez/vulture/vulture_mule_glow" );
	level._effect[ "vulture_perk_machine_glow_pack_a_punch" ] = LoadFX( "sanchez/vulture/vulture_pap_glow" );
	level._effect[ "vulture_perk_machine_glow_vulture" ] = LoadFX( "sanchez/vulture/vulture_aid_glow" );
	level._effect[ "vulture_perk_machine_glow_electric_cherry" ] = LoadFX( "sanchez/vulture/vulture_cherry_glow" );
	level._effect[ "vulture_perk_machine_glow_phd_flopper" ] = LoadFX( "sanchez/vulture/vulture_phd_glow" );
	level._effect[ "vulture_perk_machine_glow_whos_who" ] = LoadFX( "sanchez/vulture/vulture_whoswho_glow" );
	level._effect[ "vulture_perk_machine_glow_widows_wine" ] = LoadFX( "sanchez/vulture/vulture_widows_glow" );
	level._effect[ "vulture_perk_machine_glow_deadshot" ] = LoadFX( "sanchez/vulture/vulture_deadshot_glow" );
	level._effect[ "vulture_perk_mystery_box_glow" ] = LoadFX( "sanchez/vulture/vulture_box_glow" );
	level._effect[ "vulture_perk_powerup_drop" ] = LoadFX( "sanchez/vulture/vulture_powerup_glow" );
	level._effect[ "vulture_perk_zombie_eye_glow" ] = LoadFX( "sanchez/vulture/fx_zombie_eye_vulture" );
	level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_POWERUP_DROP = 12;
	level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_STINK_FX = 13;
	level._ZOMBIE_ACTOR_FLAG_VULTURE_STINK_TRAIL_FX = 3;
	level._ZOMBIE_ACTOR_FLAG_VULTURE_EYE_GLOW = 4;
	level.perk_vulture = SpawnStruct();
	level.perk_vulture.zombie_stink_array = [];
	level.perk_vulture.drop_slots_for_network = 0;
	level.perk_vulture.last_stink_zombie_spawned = 0;
	level.perk_vulture.use_exit_behavior = false;
	maps\_zombiemode_spawner::add_cusom_zombie_spawn_logic( ::vulture_zombie_spawn_func );
	maps\_zombiemode_spawner::register_zombie_death_event_callback( ::zombies_drop_stink_on_death );
	level thread vulture_perk_watch_mystery_box();
	level thread vulture_perk_watch_fire_sale();
	level thread vulture_perk_watch_powerup_drops();
	level.exit_level_func = ::vulture_zombies_find_exit_point;
	level.perk_vulture.invalid_bonus_ammo_weapons = array( "time_bomb_zm", "time_bomb_detonator_zm" );
	if( !IsDefined( level.perk_vulture.func_zombies_find_valid_exit_locations ) )
	{
		level.perk_vulture.func_zombies_find_valid_exit_locations = ::get_valid_exit_points_for_zombie;
	}
	initialize_bonus_entity_pool();
	initialize_stink_entity_pool();
	level thread vulture_perk_watch_waypoints();
	OnPlayerConnect_Callback( ::vulture_player_connect_callback );
}

add_additional_stink_locations_for_zone( str_zone, a_zones )
{
	if( !IsDefined( level.perk_vulture.zones_for_extra_stink_locations ) )
	{
		level.perk_vulture.zones_for_extra_stink_locations = [];
	}
	level.perk_vulture.zones_for_extra_stink_locations[ str_zone ] = a_zones;
}

give_vulture_perk()
{
	if( !IsDefined( self.perk_vulture ) )
	{
		self.perk_vulture = SpawnStruct();
	}
	self.perk_vulture.active = true;
	setClientSysState( "levelNotify", "vulture_active_1", self );
	self thread _vulture_perk_think();
}

take_vulture_perk()
{
	if( IsDefined( self.perk_vulture ) && is_true( self.perk_vulture.active ) )
	{
		self.perk_vulture.active = false;
		if( !self maps\_laststand::player_is_in_laststand() && !is_true( self.ignore_insta_kill ) )
		{
			self.ignoreme = false;
		}
		setClientSysState( "levelNotify", "vulture_active_0", self );
		self.vulture_stink_value = 0;
		self.vulture_glow_alpha = 0;
		self notify( "vulture_perk_lost" );
	}
}

vulture_perk_add_invalid_bonus_ammo_weapon( str_weapon )
{
	level.perk_vulture.invalid_bonus_ammo_weapons[ level.perk_vulture.invalid_bonus_ammo_weapons.size ] = str_weapon;
}

do_vulture_death( player )
{
	if( IsDefined( self ) )
	{
		self thread _do_vulture_death( player );
	}
}

_do_vulture_death( player )
{
	if( should_do_vulture_drop( self.origin ) )
	{
		str_bonus = self get_vulture_drop_type();
		str_identifier = "_" + self GetEntityNumber() + "_" + GetTime();
		self thread vulture_drop_funcs( self.origin, player, str_identifier, str_bonus );
	}
}

vulture_drop_funcs( v_origin, player, str_identifier, str_bonus )
{
	vulture_drop_count_increment();
	switch( str_bonus )
	{
		case "ammo":
			e_temp = player _vulture_drop_model( str_identifier, "p6_zm_perk_vulture_ammo", v_origin, ( 0, 0, 15 ) );
			self thread check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus );
			break;

		case "points":
			e_temp = player _vulture_drop_model( str_identifier, "p6_zm_perk_vulture_points", v_origin, ( 0, 0, 15 ) );
			self thread check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus );
			break;

		case "stink":
			self _drop_zombie_stink( level, str_identifier, str_bonus );
			break;
	}
}

_drop_zombie_stink( player, str_identifier, str_bonus )
{
	self clear_zombie_stink_fx();
	e_temp = player zombie_drops_stink( self, str_identifier );
	e_temp = player _vulture_spawn_fx( str_identifier, self.origin, str_bonus, e_temp );
	clean_up_stink( e_temp );
}

zombie_drops_stink( ai_zombie, str_identifier )
{
	e_temp = ai_zombie.stink_ent;
	if( IsDefined( e_temp ) )
	{
		e_temp thread delay_showing_vulture_ent( self, ai_zombie.origin );
		level.perk_vulture.zombie_stink_array[ level.perk_vulture.zombie_stink_array.size ] = e_temp;
		self delay_notify( str_identifier, 16 );
	}
	return e_temp;
}

delay_showing_vulture_ent( player, v_moveto_pos, str_model, func )
{
	self.drop_time = GetTime();
	wait_network_frame();
	wait_network_frame();
	self.origin = v_moveto_pos;
	wait_network_frame();
	if( IsDefined( str_model ) )
	{
		self SetModel( str_model );
	}
	self Show();
	if( IsPlayer( player ) )
	{
		self SetInvisibleToAll();
		self SetVisibleToPlayer( player );
	}
	if( IsDefined( func ) )
	{
		self [[ func ]]( player );
	}
}

clean_up_stink( e_temp )
{
	e_temp ClearClientFlag( level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_STINK_FX );
	level.perk_vulture.zombie_stink_array = array_remove_nokeys( level.perk_vulture.zombie_stink_array, e_temp );
	wait 4;
	e_temp clear_stink_ent();
}

_delete_vulture_ent( n_delay )
{
	if( !IsDefined( n_delay ) )
	{
		n_delay = 0;
	}
	if( n_delay > 0 )
	{
		self Hide();
		wait n_delay;
	}
	self clear_bonus_ent();
}

_vulture_drop_model( str_identifier, str_model, v_model_origin, v_offset )
{
	if( !IsDefined( v_offset ) )
	{
		v_offset = ( 0, 0, 0 );
	}
	if( !IsDefined( self.perk_vulture_models ) )
	{
		self.perk_vulture_models = [];
	}
	e_temp = get_unused_bonus_ent();
	if( !IsDefined( e_temp ) )
	{
		self notify( str_identifier );
		return;
	}
	e_temp thread delay_showing_vulture_ent( self, v_model_origin + v_offset, str_model, ::set_vulture_drop_fx );
	self.perk_vulture_models[ self.perk_vulture_models.size ] = e_temp;
	e_temp SetInvisibleToAll();
	e_temp SetVisibleToPlayer( self );
	e_temp thread _vulture_drop_model_thread( str_identifier, self );
	return e_temp;
}

set_vulture_drop_fx( player )
{
	self thread play_vulture_perk_bonus_fx( player );
}

_vulture_drop_model_thread( str_identifier, player )
{
	self thread _vulture_model_blink_timeout( player );
	player waittill_any( str_identifier, "death", "disconnect", "vulture_perk_lost" );
	self notify( "stop_powerup_fx" );
	n_delete_delay = 0.1;
	if( IsDefined( self.picked_up ) && self.picked_up )
	{
		self _play_vulture_drop_pickup_fx( player );
		n_delete_delay = 1;
	}
	if( IsDefined( player.perk_vulture_models ) )
	{
		player.perk_vulture_models = array_remove_nokeys( player.perk_vulture_models, self );
		player.perk_vulture_models = remove_undefined_from_array( player.perk_vulture_models );
	}
	self _delete_vulture_ent( n_delete_delay );
}

_vulture_model_blink_timeout( player )
{
	self endon( "death" );
	player endon( "death" );
	player endon( "disconnect" );
	self endon( "stop_vulture_behavior" );
	b_show = true;
	for( i = 0; i < 240; )
	{
		if( i < 120 )
		{
			n_multiplier = 120;
		}
		else if( i < 160 )
		{
			n_multiplier = 10;
		}
		else if( i < 200 )
		{
			n_multiplier = 5;
		}
		else
		{
			n_multiplier = 2;
		}
		if( b_show )
		{
			self Show();
			self SetInvisibleToAll();
			self SetVisibleToPlayer( player );
		}
		else
		{
			self Hide();
		}
		b_show = !b_show;
		i += n_multiplier;
		wait 0.05 * n_multiplier;
	}
}

_vulture_spawn_fx( str_identifier, v_fx_origin, str_bonus, e_temp )
{
	b_delete = false;
	if( !IsDefined( e_temp ) )
	{
		e_temp = get_unused_bonus_ent();
		if( !IsDefined( e_temp ) )
		{
			self notify( str_identifier );
			return;
		}
		b_delete = true;
	}
	e_temp thread delay_showing_vulture_ent( self, v_fx_origin, "tag_origin", ::clientfield_set_vulture_stink_enabled );
	if( IsPlayer( self ) )
	{
		self waittill_any( str_identifier, "death", "disconnect", "vulture_perk_lost" );
	}
	else
	{
		self waittill( str_identifier );
	}
	if( b_delete )
	{
		e_temp _delete_vulture_ent();
	}
	return e_temp;
}

clientfield_set_vulture_stink_enabled( player )
{
	self SetClientFlag( level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_STINK_FX );
}

should_do_vulture_drop( v_death_origin )
{
	b_is_inside_playable_area = check_point_in_active_zone( v_death_origin );
	b_ents_are_available = get_unused_bonus_ent_count() > 0;
	b_network_slots_available = level.perk_vulture.drop_slots_for_network < 5;
	b_passed_roll = RandomInt( 100 ) > 35;
	if( !is_true( self.is_stink_zombie ) )
	{
		return b_is_inside_playable_area && b_ents_are_available && b_network_slots_available && b_passed_roll;
	}
	return true;
}

get_vulture_drop_type()
{
	if( RandomInt( 2 ) )
	{
		str_bonus = "ammo";
	}
	else
	{
		str_bonus = "points";
	}
	if( is_true( self.is_stink_zombie ) )
	{
		str_bonus = "stink";
	}
	return str_bonus;
}

get_vulture_drop_duration( str_bonus )
{
	n_duration = 12;
	if( str_bonus == "stink" )
	{
		n_duration = 16;
	}
	return n_duration;
}

check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus )
{
	if( !IsDefined( e_temp ) )
	{
		return;
	}
	player endon( "death" );
	player endon( "disconnect" );
	e_temp endon( "death" );
	e_temp endon( "stop_vulture_behavior" );
	wait_network_frame();
	n_times_to_check = Int( get_vulture_drop_duration( str_bonus ) / 0.15 );
	b_player_inside_radius = false;
	e_temp.picked_up = false;
	for( i = 0; i < n_times_to_check; i ++ )
	{
		b_player_inside_radius = DistanceSquared( e_temp.origin, player.origin ) < 1024;
		if( b_player_inside_radius )
		{
			e_temp.picked_up = true;
			break;
		}
		wait 0.15;
	}
	player notify( str_identifier );
	if( b_player_inside_radius )
	{
		player give_vulture_bonus( str_bonus );
	}
}

_handle_zombie_stink( b_player_inside_radius )
{
	if( !IsDefined( self.perk_vulture.is_in_zombie_stink ) )
	{
		self.perk_vulture.is_in_zombie_stink = false;
	}
	b_in_stink_last_check = self.perk_vulture.is_in_zombie_stink;
	self.perk_vulture.is_in_zombie_stink = b_player_inside_radius;
	if( self.perk_vulture.is_in_zombie_stink )
	{
		n_current_time = GetTime();
		if( !b_in_stink_last_check )
		{
			self.perk_vulture.stink_time_entered = n_current_time;
			self toggle_stink_overlay( true );
		}
		b_should_ignore_player = false;
		if( IsDefined( self.perk_vulture.stink_time_entered ) )
		{
			b_should_ignore_player = ( ( n_current_time - self.perk_vulture.stink_time_entered ) * 0.001 ) >= 0;
		}
		if( b_should_ignore_player )
		{
			self.ignoreme = true;
		}
		if( get_targetable_player_count() == 0 || !self are_any_players_in_adjacent_zone() )
		{
			if( b_should_ignore_player && !level.perk_vulture.use_exit_behavior )
			{
				level.perk_vulture.use_exit_behavior = true;
				level.default_find_exit_position_override = ::vulture_perk_should_zombies_resume_find_flesh;
				self thread vulture_zombies_find_exit_point();
			}
		}
	}
	else
	{
		if( b_in_stink_last_check )
		{
			self.perk_vulture.stink_time_exit = GetTime();
			self thread _zombies_reacquire_player_after_leaving_stink();
		}
	}
}

get_targetable_player_count()
{
	n_targetable_player_count = 0;
	players = GetPlayers();
	for( i = 0; i < players.size; i ++ )
	{
		player = players[i];
		if( !IsDefined( player.ignoreme ) || !player.ignoreme )
		{
			n_targetable_player_count ++;
		}
	}
	return n_targetable_player_count;
}

are_any_players_in_adjacent_zone()
{
	b_players_in_adjacent_zone = false;
	str_zone = self get_current_zone();
	players = GetPlayers();
	for( i = 0; i < players.size; i ++ )
	{
		player = players[i];
		if( player != self )
		{
			str_zone_compare = player get_current_zone();
			if( is_in_array( level.zones[ str_zone ].adjacent_zones, str_zone_compare ) && IsDefined( level.zones[ str_zone ].adjacent_zones[ str_zone_compare ].is_connected ) && level.zones[ str_zone ].adjacent_zones[ str_zone_compare ].is_connected )
			{
				b_players_in_adjacent_zone = true;
				break;
			}
		}
	}
	return b_players_in_adjacent_zone;
}

toggle_stink_overlay( b_show_overlay )
{
	if( !IsDefined( self.vulture_stink_value ) )
	{
		self.vulture_stink_value = 0;
	}
	if( b_show_overlay )
	{
		self thread _ramp_up_stink_overlay();
	}
	else
	{
		self thread _ramp_down_stink_overlay();
	}
}

_ramp_up_stink_overlay()
{
	self notify( "vulture_perk_stink_ramp_up_done" );
	self endon( "vulture_perk_stink_ramp_up_done" );
	self endon( "disconnect" );
	self endon( "vulture_perk_lost" );
	setClientSysState( "levelNotify", "vulture_stink_sound_1", self );
	while( self.perk_vulture.is_in_zombie_stink )
	{
		self.vulture_stink_value ++;
		if( self.vulture_stink_value > 32 )
		{
			self.vulture_stink_value = 32;
		}
		self.vulture_glow_alpha = self _get_disease_meter_fraction();
		wait 0.25;
	}
}

_get_disease_meter_fraction()
{
	return self.vulture_stink_value / 32;
}

_ramp_down_stink_overlay()
{
	self notify( "vulture_perk_stink_ramp_down_done" );
	self endon( "vulture_perk_stink_ramp_down_done" );
	self endon( "disconnect" );
	self endon( "vulture_perk_lost" );
	setClientSysState( "levelNotify", "vulture_stink_sound_0", self );
	while( !self.perk_vulture.is_in_zombie_stink && self.vulture_stink_value > 0 )
	{
		self.vulture_stink_value -= 2;
		if( self.vulture_stink_value < 0 )
		{
			self.vulture_stink_value = 0;
		}
		self.vulture_glow_alpha = self _get_disease_meter_fraction();
		wait 0.25;
	}
}

_zombies_reacquire_player_after_leaving_stink()
{
	self endon( "disconnect" );
	self notify( "vulture_perk_stop_zombie_reacquire_player" );
	self endon( "vulture_perk_stop_zombie_reacquire_player" );
	self toggle_stink_overlay( false );
	while( self.vulture_stink_value > 0 )
	{
		wait 0.25;
	}
	self.ignoreme = false;
	level.perk_vulture.use_exit_behavior = false;
}

vulture_perk_should_zombies_resume_find_flesh()
{
	b_should_find_flesh = !is_player_in_zombie_stink();
	return b_should_find_flesh;
}

is_player_in_zombie_stink()
{
	a_players = GetPlayers();
	b_player_in_zombie_stink = false;
	for( i = 0; i < a_players.size; i ++ )
	{
		if( IsDefined( a_players[i].perk_vulture ) && is_true( a_players[i].perk_vulture.is_in_zombie_stink ) )
		{
			b_player_in_zombie_stink = true;
			break;
		}
	}
	return b_player_in_zombie_stink;
}

give_vulture_bonus( str_bonus )
{
	switch( str_bonus )
	{
		case "ammo":
			self give_bonus_ammo();
			break;

		case "points":
			self give_bonus_points();
			break;
	}
}

give_bonus_ammo()
{
	str_weapon_current = self GetCurrentWeapon();
	if( str_weapon_current != "none" )
	{
		if( is_valid_ammo_bonus_weapon( str_weapon_current ) )
		{
			n_ammo_count_current = self GetWeaponAmmoStock( str_weapon_current );
			n_ammo_count_max = WeaponMaxAmmo( str_weapon_current );
			n_ammo_refunded = clamp( Int( n_ammo_count_max * RandomFloatRange( 0, 0.025 ) ), 1, n_ammo_count_max );
			b_is_custom_weapon = self handle_custom_weapon_refunds( str_weapon_current );
			if( !b_is_custom_weapon )
			{
				self SetWeaponAmmoStock( str_weapon_current, n_ammo_count_current + n_ammo_refunded );
			}
		}
		self PlaySoundToPlayer( "zmb_vulture_drop_pickup_ammo", self );
	}
}

is_valid_ammo_bonus_weapon( str_weapon )
{
	if( str_weapon == "zombie_perk_bottle_jugg" || str_weapon == "zombie_knuckle_crack" )
	{
		return false;
	}
	if( is_placeable_mine( str_weapon ) || is_equipment( str_weapon ) )
	{
		return false;
	}
	if( is_in_array( level.perk_vulture.invalid_bonus_ammo_weapons, str_weapon ) )
	{
		return false;
	}
	if( maps\_zombiemode::is_weapon_expluded_from_mule_kick_return( str_weapon ) )
	{
		return false;
	}
	return true;
}

_play_vulture_drop_pickup_fx( player )
{
	play_oneshot_fx_to_player( player, "vulture_drop_picked_up", self.origin, self.angles );
	play_oneshot_sound_to_player( player, "zmb_vulture_drop_pickup", self.origin );
}

give_bonus_points( v_fx_origin )
{
	n_multiplier = RandomIntRange( 1, 5 );
	self maps\_zombiemode_score::player_add_points( "thundergun_fling", 5 * n_multiplier );
	self PlaySoundToPlayer( "zmb_vulture_drop_pickup_money", self );
}

_vulture_perk_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "vulture_perk_lost" );
	while( true )
	{
		b_player_in_zombie_stink = false;
		if( !IsDefined( level.perk_vulture.zombie_stink_array ) )
		{
			level.perk_vulture.zombie_stink_array = [];
		}
		if( level.perk_vulture.zombie_stink_array.size > 0 )
		{
			a_close_points = get_array_of_closest( self.origin, level.perk_vulture.zombie_stink_array, undefined, undefined, 300 );
			if( a_close_points.size > 0 )
			{
				b_player_in_zombie_stink = self _is_player_in_zombie_stink( a_close_points );
			}
		}
		self _handle_zombie_stink( b_player_in_zombie_stink );
		wait RandomFloatRange( 0.25, 0.5 );
	}
}

_is_player_in_zombie_stink( a_points )
{
	b_is_in_stink = false;
	for( i = 0; i < a_points.size; i ++ )
	{
		if( DistanceSquared( a_points[i].origin, self.origin ) < 4900 )
		{
			b_is_in_stink = true;
			break;
		}
	}
	return b_is_in_stink;
}

vulture_drop_count_increment()
{
	level.perk_vulture.drop_slots_for_network ++;
	level thread _decrement_network_slots_after_time();
}

_decrement_network_slots_after_time()
{
	wait 0.25;
	level.perk_vulture.drop_slots_for_network --;
}

vulture_zombie_spawn_func()
{
	self endon( "death" );
	self thread add_zombie_eye_glow();
	self waittill( "completed_emerging_into_playable_area" );
	if( self should_zombie_have_stink() )
	{
		self stink_zombie_array_add();
	}
}

add_zombie_eye_glow()
{
	self endon( "death" );
	wait 0.1;
	if( self.animname != "zombie" || is_true( self.is_cloaker_zombie ) )
	{
		return;
	}
	if( IsDefined( self.script_string ) && self.script_string == "riser" )
	{
		self waittill( "risen" );
	}
	self SetClientFlag( level._ZOMBIE_ACTOR_FLAG_VULTURE_EYE_GLOW );
}

zombies_drop_stink_on_death()
{
	self ClearClientFlag( level._ZOMBIE_ACTOR_FLAG_VULTURE_EYE_GLOW );
	if( IsDefined( self.attacker ) && IsPlayer( self.attacker ) && self.attacker HasPerk( "specialty_altmelee" ) )
	{
		self thread do_vulture_death( self.attacker );
	}
	else
	{
		if( is_true( self.is_stink_zombie ) && IsDefined( self.stink_ent ) )
		{
			str_identifier = "_" + self GetEntityNumber() + "_" + GetTime();
			self thread _drop_zombie_stink( level, str_identifier, "stink" );
		}
	}
}

clear_zombie_stink_fx()
{
	self ClearClientFlag( level._ZOMBIE_ACTOR_FLAG_VULTURE_STINK_TRAIL_FX );
}

stink_zombie_array_add()
{
	if( get_unused_stink_ent_count() > 0 )
	{
		self.stink_ent = get_unused_stink_ent();
		if( IsDefined( self.stink_ent ) )
		{
			self.stink_ent.owner = self;
			wait_network_frame();
			wait_network_frame();
			self SetClientFlag( level._ZOMBIE_ACTOR_FLAG_VULTURE_STINK_TRAIL_FX );
			level.perk_vulture.last_stink_zombie_spawned = GetTime();
			self.is_stink_zombie = true;
		}
	}
}

should_zombie_have_stink()
{
	b_is_zombie = self.animname == "zombie";
	b_cooldown_up = ( GetTime() - level.perk_vulture.last_stink_zombie_spawned ) > 12000;
	b_roll_passed = RandomInt( 100 ) > 50;
	b_stink_ent_available = get_unused_stink_ent_count() > 0;
	return b_is_zombie && b_roll_passed && b_cooldown_up && b_stink_ent_available;
}

vulture_perk_watch_mystery_box()
{
	wait_network_frame();
	while( IsDefined( level.chests ) && level.chests.size > 0 && IsDefined( level.chest_index ) )
	{
		level.chests[ level.chest_index ].vulture_waypoint_visible = true;
		flag_wait( "moving_chest_now" );
		level.chests[ level.chest_index ].vulture_waypoint_visible = false;
		flag_waitopen( "moving_chest_now" );
	}
}

vulture_perk_watch_fire_sale()
{
	wait_network_frame();
	while( IsDefined( level.chests ) && level.chests.size > 0 )
	{
		level waittill( "powerup fire sale" );
		for( i = 0; i < level.chests.size; i ++ )
		{
			if( i != level.chest_index )
			{
				level.chests[i].vulture_waypoint_visible = true;
			}
		}
		level waittill( "fire_sale_off" );
		for( i = 0; i < level.chests.size; i ++ )
		{
			if( i != level.chest_index )
			{
				level.chests[i].vulture_waypoint_visible = false;
			}
		}
	}
}

vulture_perk_watch_powerup_drops()
{
	while( true )
	{
		level waittill( "powerup_dropped", m_powerup );
		m_powerup thread _powerup_drop_think();
	}
}

_powerup_drop_think()
{
	e_temp = Spawn( "script_model", self.origin );
	e_temp SetModel( "tag_origin" );
	e_temp SetClientFlag( level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_POWERUP_DROP );
	self waittill_any( "powerup_timedout", "powerup_grabbed", "death" );
	e_temp ClearClientFlag( level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_POWERUP_DROP );
	wait_network_frame();
	wait_network_frame();
	wait_network_frame();
	e_temp Delete();
}

vulture_zombies_find_exit_point()
{
	a_zombies = GetAISpeciesArray( "axis", "all" );
	for( i = 0; i < a_zombies.size; i ++ )
	{
		a_zombies[i] thread zombie_goes_to_exit_location();
	}
}

zombie_goes_to_exit_location()
{
	self endon( "death" );
	if( self.ignoreme )
	{
		while( true )
		{
			b_passed_override = true;
			if( IsDefined( level.default_find_exit_position_override ) )
			{
				b_passed_override = [[ level.default_find_exit_position_override ]]();
			}
			if( !flag( "wait_and_revive" ) && b_passed_override )
			{
				return;
			}
			if( !self.ignoreme )
			{
				break;
			}
			wait_network_frame();
		}
	}
	s_goal = _get_zombie_exit_point();
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	if( IsDefined( s_goal ) )
	{
		self SetGoalPos( s_goal.origin );
	}
	while( true )
	{
		b_passed_override = true;
		if( IsDefined( level.default_find_exit_position_override ) )
		{
			b_passed_override = [[ level.default_find_exit_position_override ]]();
		}
		if( !flag( "wait_and_revive" ) && b_passed_override )
		{
			break;
		}
		else
		{
			wait 0.1;
		}
	}
	self thread maps\_zombiemode_spawner::find_flesh();
}

_get_zombie_exit_point()
{
	player = GetPlayers()[0];
	n_dot_best = 9999999;
	a_exit_points = self [[ level.perk_vulture.func_zombies_find_valid_exit_locations ]]();
	nd_best = undefined;
	for( i = 0; i < a_exit_points.size; i ++ )
	{
		v_to_player = VectorNormalize( player.origin - self.origin );
		v_to_goal = a_exit_points[i].origin - self.origin;
		n_dot = VectorDot( v_to_player, v_to_goal );
		if( n_dot < n_dot_best && DistanceSquared( player.origin, a_exit_points[i].origin ) > 360000 )
		{
			nd_best = a_exit_points[i];
			n_dot_best = n_dot;
		}
	}
	return nd_best;
}

get_valid_exit_points_for_zombie()
{
	a_exit_points = level.enemy_dog_locations;
	if( IsDefined( level.perk_vulture.zones_for_extra_stink_locations ) && level.perk_vulture.zones_for_extra_stink_locations.size > 0 )
	{
		a_zones_with_extra_stink_locations = GetArrayKeys( level.perk_vulture.zones_for_extra_stink_locations );
		for( j = 0; j < level.active_zone_names.size; j ++ )
		{
			zone = level.active_zone_names.size[j];
			if( is_in_array( a_zones_with_extra_stink_locations, zone ) )
			{
				a_zones_temp = level.perk_vulture.zones_for_extra_stink_locations[ zone ];
				for( i = 0; i < a_zones_temp.size; i ++ )
				{
					a_exit_points = array_combine( a_exit_points, get_zone_dog_locations( a_zones_temp[i] ) );
				}
			}
		}
	}
	return a_exit_points;
}

get_zone_dog_locations( str_zone )
{
	a_dog_locations = [];
	if( IsDefined( level.zones[ str_zone ] ) && IsDefined( level.zones[ str_zone ].dog_locations ) )
	{
		a_dog_locations = level.zones[ str_zone ].dog_locations;
	}
	return a_dog_locations;
}

initialize_bonus_entity_pool()
{
	level.perk_vulture.bonus_drop_ent_pool = [];
	for( i = 0; i < 20; i ++ )
	{
		e_temp = Spawn( "script_model", ( 0, 0, 0 ) );
		e_temp SetModel( "tag_origin" );
		e_temp.targetname = "vulture_perk_bonus_pool_ent";
		e_temp.in_use = false;
		level.perk_vulture.bonus_drop_ent_pool[ level.perk_vulture.bonus_drop_ent_pool.size ] = e_temp;
	}
}

get_unused_bonus_ent()
{
	e_found = undefined;
	for( i = 0; i < level.perk_vulture.bonus_drop_ent_pool.size; i ++ )
	{
		if( !level.perk_vulture.bonus_drop_ent_pool[i].in_use )
		{
			e_found = level.perk_vulture.bonus_drop_ent_pool[i];
			e_found.in_use = true;
			break;
		}
	}
	return e_found;
}

get_unused_bonus_ent_count()
{
	n_found = 0;
	for( i = 0; i < level.perk_vulture.bonus_drop_ent_pool.size; i ++ )
	{
		if( !level.perk_vulture.bonus_drop_ent_pool[i].in_use )
		{
			n_found ++;
		}
	}
	return n_found;
}

clear_bonus_ent()
{
	self notify( "stop_vulture_behavior" );
	self notify( "stop_powerup_fx" );
	self.in_use = false;
	self SetModel( "tag_origin" );
	self Hide();
}

initialize_stink_entity_pool()
{
	level.perk_vulture.stink_ent_pool = [];
	for( i = 0; i < 4; i ++ )
	{
		e_temp = Spawn( "script_model", ( 0, 0, 0 ) );
		e_temp SetModel( "tag_origin" );
		e_temp.targetname = "vulture_perk_bonus_pool_ent";
		e_temp.in_use = false;
		level.perk_vulture.stink_ent_pool[ level.perk_vulture.stink_ent_pool.size ] = e_temp;
	}
}

get_unused_stink_ent_count()
{
	n_found = 0;
	for( i = 0; i < level.perk_vulture.stink_ent_pool.size; i ++ )
	{
		if( !level.perk_vulture.stink_ent_pool[i].in_use )
		{
			n_found ++;
			continue;
		}
		else
		{
			if( !IsDefined( level.perk_vulture.stink_ent_pool[i].owner ) && !IsDefined( level.perk_vulture.stink_ent_pool[i].drop_time ) )
			{
				level.perk_vulture.stink_ent_pool[i] clear_stink_ent();
				n_found ++;
			}
		}
	}
	return n_found;
}

get_unused_stink_ent()
{
	e_found = undefined;
	for( i = 0; i < level.perk_vulture.stink_ent_pool.size; i ++ )
	{
		if( !level.perk_vulture.stink_ent_pool[i].in_use )
		{
			e_found = level.perk_vulture.stink_ent_pool[i];
			e_found.in_use = true;
			break;
		}
	}
	return e_found;
}

clear_stink_ent()
{
	self ClearClientFlag( level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_STINK_FX );
	self notify( "stop_vulture_behavior" );
	self.in_use = false;
	self.drop_time = undefined;
	self.owner = undefined;
	self SetModel( "tag_origin" );
	self Hide();
}

handle_custom_weapon_refunds( str_weapon )
{
	b_is_custom_weapon = false;
	if( IsSubStr( str_weapon, "knife_ballistic" ) )
	{
		self _refund_oldest_ballistic_knife( str_weapon );
		b_is_custom_weapon = true;
	}
	return b_is_custom_weapon;
}

_refund_oldest_ballistic_knife( str_weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "vulture_perk_lost" );
	if( IsDefined( self.weaponobjectwatcherarray ) && self.weaponobjectwatcherarray.size > 0 )
	{
		s_found = undefined;
		for( i = 0; i < self.weaponobjectwatcherarray.size; i ++ )
		{
			if( IsDefined( self.weaponobjectwatcherarray[i].weapon ) && self.weaponobjectwatcherarray[i].weapon == str_weapon )
			{
				s_found = self.weaponobjectwatcherarray[i];
				break;
			}
		}
		if( IsDefined( s_found ) )
		{
			if( IsDefined( s_found.objectarray ) && s_found.objectarray.size > 0 )
			{
				e_oldest = undefined;
				for( i = 0; i < s_found.objectarray.size; i ++ )
				{
					if( IsDefined( s_found.objectarray[i] ) )
					{
						if( ( IsDefined( s_found.objectarray[i].retrievabletrigger ) && IsDefined( s_found.objectarray[i].retrievabletrigger.owner ) && s_found.objectarray[i].retrievabletrigger.owner != self ) || !IsDefined( s_found.objectarray[i].birthtime ) )
						{
							continue;
						}
						else
						{
							if( !IsDefined( e_oldest ) )
							{
								e_oldest = s_found.objectarray[i];
							}
							if( s_found.objectarray[i].birthtime < e_oldest.birthtime )
							{
								e_oldest = s_found.objectarray[i];
							}
						}
					}
				}
				if( IsDefined( e_oldest ) )
				{
					self thread maps\_ballistic_knife::pick_up( str_weapon, e_oldest, e_oldest.retrievabletrigger );
				}
			}
		}
	}
}

vulture_perk_watch_waypoints()
{
	setup_perk_machine_fx();
	flag_wait( "all_players_connected" );
	wait 1;
	structs = [];
	weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" );
	weapon_spawns = array_combine( weapon_spawns, GetEntArray( "betty_purchase", "targetname" ) );
	weapon_spawns = array_combine( weapon_spawns, GetEntArray( "tazer_upgrade", "targetname" ) );
	weapon_spawns = array_combine( weapon_spawns, GetEntArray( "bowie_upgrade", "targetname" ) );
	weapon_spawns = array_combine( weapon_spawns, GetEntArray( "claymore_purchase", "targetname" ) );
	weapon_spawns = array_combine( weapon_spawns, GetEntArray( "sickle_upgrade", "targetname" ) );
	weapon_spawns = array_combine( weapon_spawns, GetEntArray( "spikemore_purchase", "targetname" ) );
	for( i = 0; i < weapon_spawns.size; i ++ )
	{
		model = GetEnt( weapon_spawns[i].target, "targetname" );
		struct = SpawnStruct();
		struct.location = weapon_spawns[i] get_waypoint_origin( "wallgun" );
		struct.check_perk = false;
		struct.perk_to_check = undefined;
		struct.is_revive = false;
		struct.is_chest = false;
		struct.chest_to_check = undefined;
		struct.fx_var = "vulture_perk_wallbuy_static";
		struct.ent_num = model GetEntityNumber();
		structs[ structs.size ] = struct;
	}
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	for( i = 0; i < vending_triggers.size; i ++ )
	{
		perk = vending_triggers[i].script_noteworthy;
		struct = SpawnStruct();
		struct.location = vending_triggers[i] get_waypoint_origin( "perk" );
		struct.check_perk = perk != "specialty_altmelee";
		struct.perk_to_check = perk;
		struct.is_revive = perk == "specialty_quickrevive";
		struct.is_chest = false;
		struct.chest_to_check = undefined;
		struct.fx_var = level.perk_vulture.perk_machine_fx[ perk ];
		struct.ent_num = vending_triggers[i] GetEntityNumber();
		structs[ structs.size ] = struct;
	}
	vending_weapon_upgrade_trigger = GetEntArray( "zombie_vending_upgrade", "targetname" );
	for( i = 0; i < vending_weapon_upgrade_trigger.size; i ++ )
	{
		struct = SpawnStruct();
		struct.location = vending_weapon_upgrade_trigger[i] get_waypoint_origin( "packapunch" );
		struct.check_perk = false;
		struct.perk_to_check = "specialty_weapupgrade";
		struct.is_revive = false;
		struct.is_chest = false;
		struct.chest_to_check = undefined;
		struct.fx_var = "vulture_perk_machine_glow_pack_a_punch";
		struct.ent_num = vending_weapon_upgrade_trigger[i] GetEntityNumber();
		structs[ structs.size ] = struct;
	}
	chests = GetEntArray( "treasure_chest_use", "targetname" );
	for( i = 0; i < chests.size; i ++ )
	{
		struct = SpawnStruct();
		struct.location = chests[i] get_waypoint_origin( "mysterybox" );
		struct.check_perk = false;
		struct.perk_to_check = undefined;
		struct.is_revive = false;
		struct.is_chest = true;
		struct.chest_to_check = chests[i];
		struct.fx_var = "vulture_perk_mystery_box_glow";
		struct.ent_num = chests[i] GetEntityNumber();
		structs[ structs.size ] = struct;
	}
	level.perk_vulture.vulture_vision_fx_list = structs;
	while( true )
	{
		for( i = 0; i < structs.size; i ++ )
		{
			struct = structs[i];
			players = GetPlayers();
			for( p = 0; p < players.size; p ++ )
			{
				player = players[p];
				num = player GetEntityNumber();
				is_visible = check_waypoint_visible( player, struct );
				if( !IsDefined( struct.player_visible ) )
				{
					struct.player_visible = [];
				}
				if( IsDefined( player.perk_vulture ) && is_true( player.perk_vulture.active ) && is_visible )
				{
					if( !is_true( struct.player_visible[ num ] ) )
					{
						struct.player_visible[ num ] = true;
						create_loop_fx_to_player( player, struct.ent_num, struct.fx_var, struct.location[ "origin" ], struct.location[ "angles" ] );
					}
				}
				else
				{
					if( is_true( struct.player_visible[ num ] ) )
					{
						struct.player_visible[ num ] = false;
						destroy_loop_fx_to_player( player, struct.ent_num, true );
					}
				}
			}
		}
		wait 0.05;
	}
}

setup_perk_machine_fx()
{
	register_perk_machine_fx( "specialty_armorvest", "vulture_perk_machine_glow_juggernog" );
	register_perk_machine_fx( "specialty_fastreload", "vulture_perk_machine_glow_speed" );
	register_perk_machine_fx( "specialty_rof", "vulture_perk_machine_glow_doubletap" );
	register_perk_machine_fx( "specialty_quickrevive", "vulture_perk_machine_glow_revive" );
	register_perk_machine_fx( "specialty_flakjacket", "vulture_perk_machine_glow_phd_flopper" );
	register_perk_machine_fx( "specialty_longersprint", "vulture_perk_machine_glow_marathon" );
	register_perk_machine_fx( "specialty_deadshot", "vulture_perk_machine_glow_deadshot" );
	register_perk_machine_fx( "specialty_additionalprimaryweapon", "vulture_perk_machine_glow_mule_kick" );
	register_perk_machine_fx( "specialty_bulletaccuracy", "vulture_perk_machine_glow_whos_who" );
	register_perk_machine_fx( "specialty_bulletdamage", "vulture_perk_machine_glow_electric_cherry" );
	register_perk_machine_fx( "specialty_altmelee", "vulture_perk_machine_glow_vulture" );
	register_perk_machine_fx( "specialty_extraammo", "vulture_perk_machine_glow_widows_wine" );
}

register_perk_machine_fx( str_perk, str_fx_reference )
{
	if( !IsDefined( level.perk_vulture.perk_machine_fx ) )
	{
		level.perk_vulture.perk_machine_fx = [];
	}
	if( !IsDefined( level.perk_vulture.perk_machine_fx[ str_perk ] ) )
	{
		level.perk_vulture.perk_machine_fx[ str_perk ] = str_fx_reference;
	}
}

get_waypoint_origin( type )
{
	origin = self.origin;
	angles = ( 0, 0, 0 );
	switch( type )
	{
		case "mysterybox":
			origin = get_mystery_box_origin( self );
			break;

		case "perk":
			origin = get_perk_machine_origin( self );
			break;

		case "packapunch":
			origin = get_pack_a_punch_origin( self );
			break;
	}
	location = [];
	location[ "origin" ] = origin;
	location[ "angles" ] = angles;
	return location;
}

get_mystery_box_origin( trigger )
{
	forward = AnglesToForward( trigger.chest_box.angles + ( 0, 90, 0 ) );
	origin = trigger.chest_box.origin + vector_scale( forward, 10 );
	return origin + ( 0, 0, 30 );
}

get_perk_machine_origin( trigger )
{
	machine = undefined;
	machines = GetEntArray( trigger.target, "targetname" );
	machines = get_array_of_closest( trigger.origin, machines );
	for( i = 0; i < machines.size; i ++ )
	{
		if( !IsDefined( machines[i].script_noteworthy ) || machines[i].script_noteworthy != "clip" )
		{
			machine = machines[i];
			break;
		}
	}
	forward = AnglesToForward( machine.angles - ( 0, 90, 0 ) );
	origin = machine.origin + vector_scale( forward, 10 );
	return origin + ( 0, 0, 50 );
}

get_pack_a_punch_origin( trigger )
{
	machine = GetEnt( trigger.target, "targetname" );
	forward = AnglesToForward( machine.angles - ( 0, 90, 0 ) );
	origin = machine.origin + vector_scale( forward, 20 );
	return origin + ( 0, 0, 40 );
}

check_waypoint_visible( player, struct )
{
	has_perk = false;
	if( struct.check_perk && IsDefined( struct.perk_to_check ) )
	{
		has_perk = player HasPerk( struct.perk_to_check );
	}
	solo_revive_gone = false;
	if( struct.is_revive && flag( "solo_game" ) )
	{
		solo_revive_gone = flag( "solo_revive" );
	}
	is_empty_boxlocation = false;
	if( struct.is_chest && IsDefined( struct.chest_to_check ) )
	{
		is_empty_boxlocation = !is_true( struct.chest_to_check.vulture_waypoint_visible );
	}
	custom_map_check = false;
	if( IsDefined( level.vulture_perk_custom_map_check ) )
	{
		custom_map_check = [[ level.vulture_perk_custom_map_check ]]( struct );
	}
	return !has_perk && !solo_revive_gone && !is_empty_boxlocation && !custom_map_check;
}

play_vulture_perk_bonus_fx( player )
{
	play_oneshot_sound_to_player( player, "zmb_vulture_drop_spawn", self.origin );
	create_loop_fx_to_player( player, self GetEntityNumber(), "vulture_perk_bonus_drop", self.origin, self.angles );
	create_loop_sound_to_player( player, self GetEntityNumber(), "zmb_vulture_drop_loop", self.origin, 0 );
	self waittill( "stop_powerup_fx" );
	destroy_loop_fx_to_player( player, self GetEntityNumber(), true );
	destroy_loop_sound_to_player( player, self GetEntityNumber(), 0 );
}

watch_vulture_shader_glow()
{
	self endon( "disconnect" );
	self.vulture_glow_alpha = 0;
	hud_outline = NewClientHudElem( self );
	hud_outline.foreground = true; 
	hud_outline.sort = 2; 
	hud_outline.hidewheninmenu = false; 
	hud_outline.alignX = "left"; 
	hud_outline.alignY = "bottom";
	hud_outline.horzAlign = "user_left"; 
	hud_outline.vertAlign = "user_bottom";
	hud_outline.x = 0;
	hud_outline.y = 0;
	hud_outline.alpha = 1;
	hud_outline SetShader( "hud_vulture_aid_stink_outline", 48, 48 );
	hud_stink = NewClientHudElem( self );
	hud_stink.foreground = true; 
	hud_stink.sort = 2; 
	hud_stink.hidewheninmenu = false; 
	hud_stink.alignX = "left"; 
	hud_stink.alignY = "bottom";
	hud_stink.horzAlign = "user_left"; 
	hud_stink.vertAlign = "user_bottom";
	hud_stink.x = 0;
	hud_stink.y = 0;
	hud_stink.alpha = 1;
	hud_stink SetShader( "hud_vulture_aid_stink", 48, 48 );
	while( true )
	{
		if( IsDefined( self.perk_hud[ "specialty_altmelee" ] ) )
		{
			hud_outline.x = self.perk_hud[ "specialty_altmelee" ].x - 12;
			hud_outline.y = self.perk_hud[ "specialty_altmelee" ].y + 12;
			hud_outline.alpha = self.vulture_glow_alpha;
			hud_stink.x = self.perk_hud[ "specialty_altmelee" ].x - 12;
			hud_stink.y = self.perk_hud[ "specialty_altmelee" ].y - 24;
			hud_stink.alpha = self.vulture_glow_alpha;
		}
		else
		{
			hud_outline.x = 0;
			hud_outline.y = 0;
			hud_outline.alpha = 0;
			hud_stink.x = 0;
			hud_stink.y = 0;
			hud_stink.alpha = 0;
		}
		wait 0.05;
	}
}

*/