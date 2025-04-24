#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_net;
#include maps\_zombiemode_reimagined_utility;

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
	level.zombiemode_using_electriccherry_perk = false;
	level.zombiemode_using_vulture_perk = false;
	level.zombiemode_using_widowswine_perk = false;

	if( level.bo2_perks ) 
	{
		level.zombiemode_using_electriccherry_perk = true;
		level.zombiemode_using_vulture_perk = true;
		level.zombiemode_using_widowswine_perk = true;
	}
	

	/*
	level.zombiemode_using_chugabud_perk = true;
	
	level.zombiemode_using_bandolier_perk = true;
	level.zombiemode_using_timeslip_perk = true;
	*/
	level.zombiemode_using_pack_a_punch = true;
	

	level place_perk_machines_by_map();
	level thread place_doubletap_machine();

	// Perks-a-cola vending machine use triggers
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	//bump_triggers = GetEntArray( "audio_bump_trigger", "targetname" );

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

	if ( vending_weapon_upgrade_trigger.size >= 1  && level.mapname != "zombie_cod5_sumpf")
	{
		array_thread( vending_weapon_upgrade_trigger, ::vending_weapon_upgrade );
	}

	//Perks machine
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
	//array_thread( bump_triggers, ::bump_trigger_think );
	
	//level thread turn_PackAPunch_on();

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
	machine setModel( "zombie_vending_doubletap2" );
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
		machine_clip setmodel( "collision_geo_64x64x64" );
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
	PrecacheItem( "zombie_knuckle_crack" );

	/*
	PreCacheShader( "specialty_glow_dbl_tap" );
	PreCacheShader( "specialty_glow_deadshot" );
	PreCacheShader( "specialty_glow_flopper" );
	PreCacheShader( "specialty_glow_jugg" );
	PreCacheShader( "specialty_glow_magic_box" );
	PreCacheShader( "specialty_glow_mule_kick" );
	PreCacheShader( "specialty_glow_pap" );
	PreCacheShader( "specialty_glow_quickrevive" );
	PreCacheShader( "specialty_glow_rifle" );
	PreCacheShader( "specialty_glow_skull" );
	PreCacheShader( "specialty_glow_speed" );
	PreCacheShader( "specialty_glow_stamin" );
	PreCacheShader( "specialty_glow_tombstone" );
	PreCacheShader( "specialty_glow_vulture" );
	PreCacheShader( "specialty_glow_whoswho" );
	PreCacheShader( "specialty_glow_widow" );
	PreCacheShader( "specialty_glow_wunderfizz" );
	PreCacheShader( "specialty_nuke_zombies" );
*/

	//Classic hintstrings
	PrecacheString( &"ZOMBIE_PERK_QUICKREVIVE" );
	PrecacheString( &"ZOMBIE_PERK_JUGGERNAUT" );
	PrecacheString( &"ZOMBIE_PERK_FASTRELOAD" );
	PrecacheString( &"ZOMBIE_PERK_DOUBLETAP" );
	PrecacheString( &"ZOMBIE_PERK_MARATHON" );
	PrecacheString( &"ZOMBIE_PERK_DIVETONUKE" );
	PrecacheString( &"ZOMBIE_PERK_DEADSHOT" );
	PrecacheString( &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON" );
	PrecacheString( &"REIMAGINED_ZOMBIE_PERK_CHERRY" );
	PrecacheString( &"REIMAGINED_ZOMBIE_PERK_VULTURE" );
	PrecacheString( &"REIMAGINED_ZOMBIE_PERK_WIDOWSWINE" );

	if( is_true( level.zombiemode_using_juggernaut_perk ) )
	{
		PreCacheShader( "specialty_juggernaut_zombies" );
		PreCacheShader( "specialty_juggernaut_zombies_pro" );
		PreCacheShader( "specialty_glow_jugg" );
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
		PrecacheShader( "specialty_glow_speed" );
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
		PrecacheShader( "specialty_glow_dbl_tap" );
		PreCacheModel( "zombie_vending_doubletap2" );
		PreCacheModel( "zombie_vending_doubletap2_on" );
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

		PrecacheRumble("explosion_generic");
		PreCacheShader( "specialty_divetonuke_zombies" );
		PreCacheShader( "specialty_divetonuke_zombies_pro" );
		PreCacheModel( "zombie_vending_nuke" );
		PreCacheModel( "zombie_vending_nuke_on" );
		PreCacheString( &"REIMAGINED_PERK_DIVETONUKE" );
		level._effect[ "divetonuke_light" ] = LoadFX( "misc/fx_zombie_cola_dtap_on" );
		level._effect["divetonuke_groundhit"] = loadfx("maps/zombie/fx_zmb_phdflopper_exp");

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
		//level._effect[ "electriccherry_light" ] = LoadFX( "misc/fx_zombie_cola_on" );
		level._effect[ "electriccherry_light" ] = level._effect[ "doubletap_light" ];
		thread init_electric_cherry();
		level thread turn_electriccherry_on();
	}
	if( is_true( level.zombiemode_using_vulture_perk ) )
	{
		PreCacheShader( "specialty_vulture_zombies" );
		PreCacheShader( "specialty_vulture_zombies_pro" );
		PreCacheModel( "bo2_zombie_vending_vultureaid" );
		PreCacheModel( "bo2_zombie_vending_vultureaid_on" );
		PreCacheString( &"REIMAGINED_PERK_VULTURE" );
		level._effect[ "vulture_light" ] = level._effect["jugger_light"];
		thread init_vulture();
		level thread turn_vulture_on();
	}
	if( is_true( level.zombiemode_using_widowswine_perk ) )
	{
		PreCacheModel( "bo3_t7_ww_grenade_world" );
		//PreCacheModel( "bo3_t7_ww_grenade_proj" );
		//PreCacheModel( "bo3_t7_ww_grenade_view" );

		PrecacheShader( "vending_widows_grenade_icon" );
		PreCacheShader( "specialty_widowswine_zombies" );
		PreCacheShader( "specialty_widowswine_zombies_pro" );
		PreCacheModel( "bo3_p7_zm_vending_widows_wine_off" );
		PreCacheModel( "bo3_p7_zm_vending_widows_wine_on" );
		PreCacheString( &"REIMAGINED_PERK_WIDOWSWINE" );
		level._effect[ "widow_light" ] = level._effect["jugger_light"];
		thread init_widows_wine();
		level thread turn_widowswine_on();
	}
	if( is_true( level.zombiemode_using_bandolier_perk ) )
	{
		PreCacheShader( "specialty_bandolier_zombies" );
	}
	if( is_true( level.zombiemode_using_timeslip_perk ) )
	{
		PreCacheShader( "specialty_timeslip_zombies" );
	}
	if( is_true( level.zombiemode_using_pack_a_punch ) )
	{
		PreCacheModel( "zombie_vending_packapunch" );
		PreCacheModel( "zombie_vending_packapunch_on" );
		PreCacheString( &"REIMAGINED_PERK_PACKAPUNCH");
		PreCacheString( &"ZOMBIE_GET_UPGRADED" );
		level._effect[ "packapunch_fx" ] = LoadFX( "maps/zombie/fx_zombie_packapunch" );
		level.pap_moving = false;
		level thread turn_PackAPunch_on();
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

	if( IsSubStr( current_weapon, "sabertooth" ) )
		interact_pos += (0,0,10);

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

	//Reimagined-Expanded
	//If gun is the upgraded uzi, get model index specially
	modelIndex = 0;
	if( IsSubStr( current_weapon, "upgraded" ) )
		modelIndex = 1;
	
	
	if( current_weapon == "uzi_upgraded_zm" )
	{
		modelIndex = self maps\_zombiemode_weapon_effects::handle_double_pap_uzi( perk_trigger.double_cost );
	}

	worldgun = spawn( "script_model", origin );
	worldgun.angles  = angles+(0,90,0);
	newGun = level.zombie_weapons[current_weapon].upgrade_name;
	if( !isDefined( newGun ) )
		newGun = current_weapon;

	worldgun setModel( GetWeaponModel( newGun ) );
	worldgun useweaponhidetags( newGun );
	worldgun moveto( interact_pos, 0.5, 0, 0 );
	perk_trigger.worldgun = worldgun;

	worldgundw = undefined;
	if ( maps\_zombiemode_weapons::weapon_is_dual_wield( newGun ) )
	{
		worldgundw = spawn( "script_model", origin + offsetdw );
		worldgundw.angles  = angles+(0,90,0);

		worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( newGun ) );
		worldgundw useweaponhidetags( newGun );
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
				//iprintln("Player in range");
				current_weapon = players[i] getCurrentWeapon();
				if(current_weapon == "microwavegun_zm")
				{
					current_weapon = "microwavegundw_zm";
				}
				primaryWeapons = players[i] GetWeaponsListPrimaries();
				packInUseByThisPlayer = ( flag("pack_machine_in_use") && IsDefined(self.user) && self.user == players[i] );
				if ( players[i] hacker_active() )
				{
					//iprintln("1");
					self SetInvisibleToPlayer( players[i], true );
				}
				else if( !players[i] maps\_zombiemode_weapons::can_buy_weapon() || players[i] maps\_laststand::player_is_in_laststand() || is_true( players[i].intermission ) || players[i] isThrowingGrenade() )
				{
					//iprintln("2");
					self SetInvisibleToPlayer( players[i], true );
				}
				else if( is_true(level.pap_moving) ) //can't use the pap machine while it's being lowered or raised
				{
					//iprintln("3");
					self SetInvisibleToPlayer( players[i], true );
				}
				else if( players[i] isSwitchingWeapons() )
		 		{
					//iprintln("4");
		 			self SetInvisibleToPlayer( players[i], true );
		 		}
		 		else if( !packInUseByThisPlayer && flag("pack_machine_in_use") )
		 		{
					//iprintln("5");
		 			self SetInvisibleToPlayer( players[i], true );
		 		}
				else if ( !packInUseByThisPlayer && ! players[i] check_pap_permitted( current_weapon ) )
				{
					//iprintln("6");
					self SetInvisibleToPlayer( players[i], true );
				}	
				else
				{
					//iprintln("9");
					self SetInvisibleToPlayer( players[i], false );
				}
			}
		}
		wait(0.05);
	}
}

/*

Put these conditions in this method:
	- weapon must be defined
	- uzi may always be pap'd
	- weapon may not be double pap'd
	- certain weapons are blacklisted from double pap

*/

check_pap_permitted( weapon )
{

	if( !isDefined( level.zombie_include_weapons[weapon] ) ) 
		return false;
	
	if( weapon == "uzi_upgraded_zm" ) {
		//NOTHING, weapon can always be papped again
	}
	else if( self maps\_zombiemode_weapons::is_weapon_double_upgraded( weapon ) )
		return false;

	if( vending_2x_blacklist( weapon ) )
		return false;

	return true;

}

//
//	Pack-A-Punch Weapon Upgrade
//
vending_weapon_upgrade()
{
	self endon("death");

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
	alltrue = true;

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
			! player check_pap_permitted( current_weapon ) )
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
		
		if ( player maps\_zombiemode_weapons::is_weapon_upgraded( current_weapon ) && player.score < self.double_cost )
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
		

		self.user = player;
		flag_set("pack_machine_in_use");

		if( IsSubStr(current_weapon, "upgraded") )
			player maps\_zombiemode_score::minus_to_player_score( self.double_cost ); //Double PaP
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

		if( IsSubStr(current_weapon, "upgraded") )
			self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.double_cost );
		else
			self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.double_cost );

		self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.double_cost );
		//self setvisibletoall();
		flag_clear("pack_machine_in_use");
		self.user = undefined;
		self.third_person_weapon_complete = undefined;
		wait(1);
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
	self endon("death");

	while ( 1 )
	{
		self.cost = level.VALUE_PAP_COST;
		self.double_cost = level.VALUE_PAP_X2_COST; 
		if(level.expensive_perks) {
			self.cost = level.VALUE_PAP_EXPENSIVE_COST;
			self.double_cost = level.VALUE_PAP_X2_EXPENSIVE_COST;
		}
			
		
		self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.double_cost );
		
		level waittill( "powerup bonfire sale" );

		self.cost = level.VALUE_PAP_BONFIRE_COST;
		self.double_cost = level.VALUE_PAP_X2_BONFIRE_COST;
		if(level.expensive_perks) {
			self.cost = level.VALUE_PAP_EXPENSIVE_BONFIRE_COST;
			self.double_cost = level.VALUE_PAP_X2_EXPENSIVE_BONFIRE_COST;
		}
			
		self SetHintString( &"REIMAGINED_PERK_PACKAPUNCH", self.cost, self.double_cost );

		level waittill( "bonfire_sale_off" );
	}
}


//
//
wait_for_player_to_take( player, weapon, packa_timer )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon] ), "wait_for_player_to_take: weapon does not exist" );
	//AssertEx( IsDefined( level.zombie_weapons[weapon].upgrade_name ), "wait_for_player_to_take: upgrade_weapon does not exist" );

	upgrade_weapon = level.zombie_weapons[weapon].upgrade_name;

	//Reimagined-Exapnded - Essentially, we use the already upgraded weapon as the new weapon for some weapons
	if( !isDefined( upgrade_weapon ) ) 
		upgrade_weapon = weapon;
	
	//iprintln("Upgrade weapon to give: " );
	//iprintln( upgrade_weapon );

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
					index = player maps\_zombiemode_weapons::get_upgraded_weapon_model_index(upgrade_weapon);

					player GiveWeapon( upgrade_weapon, index, player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					player maps\_zombiemode_weapons::give_max_ammo(upgrade_weapon, 1);
				}

				//Upgraded weapon, upgrade_weapon, weap_upgrade
				player handle_player_packapunch(weapon, true);
				player SwitchToWeapon( upgrade_weapon );
				player notify("weapon_upgrade_complete");
				player maps\_zombiemode_weapons::play_weapon_vo(upgrade_weapon);

				return;
			}

			
		}
		wait( 0.05 );
	}
}

handle_player_packapunch(current_weapon, didUpgrade)
{
	self maps\_zombiemode::handle_player_packapunch(current_weapon, didUpgrade);
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


	if( Tolower( GetDvar( #"mapname" ) ) != "zombie_cod5_sumpf" )
		return;
		
	machine = getentarray("vending_packapunch", "targetname");
	level waittill("Pack_A_Punch_on");
	
	for( i = 0; i < machine.size; i++ )
	{
		machine[i] vibrate((0,-100,0), 0.3, 0.4, 3);
		machine[i] playsound("zmb_perks_power_on");
		machine[i] thread perk_fx( "doubletap_light" );
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
	//if map is moon
	if( level.mapname == "zombie_moon")
	{
		setup_revive_moon();
	}
	
	machine = getentarray("vending_revive", "targetname");
	/*machine_model = undefined;
	machine_clip = undefined;

	flag_wait( "all_players_connected" );
	players = get_players();
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

	setup_revive_moon()
	{
		origin = (6, -123, -2);
		machine = getentarray("vending_revive", "targetname");
		trigger = GetEnt( level.QRV_PRK , "script_noteworthy");
		trigger.origin = origin + (0 , 0, 30);
		perk_clip = undefined;

		for( i = 0; i < machine.size; i++ )
		{
			if(IsDefined(machine[i].classname) && machine[i].classname == "script_model")
			{
				machine[i].origin = origin;
				perk_clip = spawn( "script_model", machine[i].origin + (0, 0, 30) );
				perk_clip.angles = machine[0].angles;
				perk_clip SetModel( "collision_geo_64x64x64" );
				perk_clip Hide();

				bump_trigger = Spawn( "trigger_radius", machine[i].origin, 0, 35, 64 );
				bump_trigger.script_activated = 1;
				bump_trigger.script_sound = "fly_bump_bottle";
				bump_trigger.targetname = "audio_bump_trigger";
			}
		}
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

	//iprintln("Juggernog_on");
	//Reimagined-Expanded
	if(level.mapname != "zombie_cod5_sumpf")
	{
		level notify("sleight_on");
		level notify("revive_on");
		level notify("divetonuke_on");
		level notify("marathon_on");
		level notify("doubletap_on");
		level notify("deadshot_on");
		level notify("additionalprimaryweapon_on");
		level notify("electriccherry_on");
		level notify("vulture_on");
		level notify("widowswine_on");
		level notify("Pack_A_Punch_on");
	}
	

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
		machine[i] setmodel("zombie_vending_doubletap2_on");
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

divetonuke_explode( attacker, origin, isDamaged )
{
	// tweakable vars
	//iprintln("divetonuke_explode");
	radius = level.zombie_vars["zombie_perk_divetonuke_radius"];
	min_damage = level.VALUE_PHD_MIN_DAMAGE;
	max_damage = level.VALUE_PHD_MAX_DAMAGE;

	if( !isDefined( isDamaged ) )
		isDamaged = false;
	
	//Perkapunch
	//if player has specialty_flakjacket_upgraded AND BIG JUMP
	zombies = get_array_of_closest( self.origin, GetAiSpeciesArray( "axis", "all" ) , undefined, undefined, radius );
	if( ( attacker hasProPerk(level.PHD_PRO) ) && isDamaged ) 
	{
		//Increase radius and damage significantly
		radius *= level.VALUE_PHD_PRO_RADIUS_SCALER;
		min_damage *= level.VALUE_PHD_PRO_DAMAGE_SCALER;
		max_damage *= level.VALUE_PHD_PRO_DAMAGE_SCALER;

		PlayFx( level._effect["custom_large_explosion"], origin );
		attacker PlaySound("zmb_phdflop_explo");
		PlayRumbleOnPosition("explosion_generic", attacker.origin);
		
		//Also apply hellfire to closest zombies, form _zombiemode_weaponeffects
		//Get all zombies in radius

		for( i = 0; i < zombies.size; i++ ) 
		{
			if( is_boss_zombie( zombies[i].animname ) )
				continue;

			if( checkDist( self.origin, zombies[i].origin, level.VALUE_PHD_PRO_COLLISIONS_RANGE ) ) 
			{
				zombies[i] thread maps\_zombiemode_weapon_effects::bonus_fire_damage(
					 zombies[i] , attacker, 0 , 2 );
			}

			if( i > 100 )	
				break;
			
		}
		
	} else {
		//iprintln("divetonuke_explode");
		PlayFx( level._effect["divetonuke_groundhit"], origin );
		attacker PlaySound("wpn_grenade_explode");
	}

	if( attacker hasProPerk(level.PHD_PRO) )
	{
		for( i = 0; i < zombies.size; i++ ) 
		{
			if( is_boss_zombie( zombies[i].animname ) )
				continue;

			if( checkDist( self.origin, zombies[i].origin, level.VALUE_PHD_PRO_COLLISIONS_RANGE ) ) 
			{
				zombies[i] thread maps\_zombiemode::zombie_knockdown();
			}

			if( i > 3 )	
				break;
			
		}
	
	}

	// radius damage
	attacker.divetonuke_damage = true;
	RadiusDamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	attacker.divetonuke_damage = undefined;

	// play fx
	//PlayFx( level._effect["custom_large_explosion"], origin );

	// WW (01/12/11): start clientsided effects - These client flags are defined in _zombiemode.gsc & _zombiemode.csc
	// Used for zombie_dive2nuke_visionset() in _zombiemode.csc
	//attacker SetClientFlag( level._ZOMBIE_PLAYER_FLAG_DIVE2NUKE_VISION );
	wait( 0.1 );
	//attacker ClearClientFlag( level._ZOMBIE_PLAYER_FLAG_DIVE2NUKE_VISION );
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
	level waittill("additionalprimaryweapon_on");

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
	machine = GetEntArray( "vending_electriccherry", "targetname" );
	level waittill( "electriccherry_on" );
	for( i = 0; i < machine.size; i ++ )
	{
		machine[i] SetModel( "p6_zm_vending_electric_cherry_on" );
		machine[i] Vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
		machine[i] PlaySound( "zmb_perks_power_on" );
		//Determine offset that is "in front" of the machine in a 3D worldspace, r=7
		r=15;
		z=-20;
		angles = machine[i].angles; 
		offset = (r*sin(angles[1]), r*cos(angles[1]), z);
			
		machine[i] thread perk_fx( "electriccherry_light", offset );
	}
	level notify( "specialty_bulletdamage_power_on" );
}

turn_vulture_on()
{
	machine = GetEntArray( "vending_vulture", "targetname" );
	level waittill( "vulture_on" );

	for( i = 0; i < machine.size; i ++ )
	{
		machine[i] SetModel( "bo2_zombie_vending_vultureaid_on" );
		machine[i] Vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
		machine[i] PlaySound( "zmb_perks_power_on" );
		machine[i] thread perk_fx( "vulture_light" );
	}
	level notify( "specialty_altmelee_power_on" );

}

turn_widowswine_on()
{
	machine = GetEntArray( "vending_widowswine", "targetname" );
	level waittill( "widowswine_on" );
	for( i = 0; i < machine.size; i ++ )
	{
		machine[i] SetModel( "bo3_p7_zm_vending_widows_wine_on" );
		machine[i] Vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
		machine[i] PlaySound( "zmb_perks_power_on" );
		machine[i] thread perk_fx( "widow_light" );
	}
	level notify( "specialty_bulletaccuracy_power_on" );
}

//
//
perk_fx( fx, offset )
{
	wait(3);


	//playfxontag( level._effect[ fx ], self, "tag_origin" );
	if( !isdefined( offset ) )
	{
		offset = (0,0,0);
	}
	
	model = Spawn( "script_model", self.origin + offset );
	model.angles = self.angles;
	model setModel( "t6_wpn_zmb_perk_bottle_jugg_world" );
	model NotSolid();
	model Hide();
	playfxontag( level._effect[ fx ], model, "tag_origin" );

	off_event = self.targetname + "_off";
	moved_event = self.targetname + "_moved";

	level waittill_any( off_event, moved_event, "perks_swapping" );

	if( self.targetname == "vending_packapunch" )
	{
		while( flag( "pack_machine_in_use" ) )
		{
			wait 0.05;
		}
		wait( 1.5 );
	}
	

	model Delete();

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


convertProPerkToShaderPro( perk )
{
	if ( !isDefined ( perk ) )
		return "UNKOWN";
	
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
	if (perk == "specialty_bulletdamage_upgrade")
		return "specialty_cherry_zombies_pro";
	if (perk == "specialty_altmelee_upgrade")
		return "specialty_vulture_zombies_pro";
	if (perk == "specialty_bulletaccuracy_upgrade")
		return "specialty_widowswine_zombies_pro";
    
return "UNKOWN";
}

convertPerkToShader( perk )
{
	if ( !isDefined ( perk ) )
		return "UNKOWN";
	
	if (perk == "specialty_armorvest")
		return "specialty_juggernaut_zombies";
	if (perk == "specialty_quickrevive")
		return "specialty_quickrevive_zombies";
	if (perk == "specialty_fastreload")
		return "specialty_fastreload_zombies";
	if (perk == "specialty_rof")
		return "specialty_doubletap_zombies";
	if (perk == "specialty_endurance")
		return "specialty_marathon_zombies";
	if (perk == "specialty_flakjacket")
		return "specialty_divetonuke_zombies";
	if (perk == "specialty_deadshot")
		return "specialty_deadshot_zombies";
	if (perk == "specialty_additionalprimaryweapon")
		return "specialty_mulekick_zombies";
	if (perk == "specialty_bulletdamage")
		return "specialty_cherry_zombies";
	if (perk == "specialty_altmelee")
		return "specialty_vulture_zombies";
	if (perk == "specialty_bulletaccuracy")
		return "specialty_widowswine_zombies";
    
return "UNKOWN";
}

/*
hasProPerk( p )
{ return true; }

addProPerk( p )
{ }
//Self is player
*/

is_boss_zombie( animname ) {
	return maps\_zombiemode::is_boss_zombie( animname );
}

is_special_zombie( animname ) {
	return maps\_zombiemode::is_special_zombie( animname );
}


hasProPerk( perk )
{
	if ( !isDefined ( perk ) )
		return "UNKOWN";

	//If passing normal perk, convert to upgrade
	if( IsSubStr( perk, "_upgrade" ) )
	{
		//nothing
	}
	else
	{
		perk = perk + "_upgrade";
	}

	
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
	if (perk == "specialty_bulletaccuracy_upgrade")
		return self.PRO_PERKS[ level.WWN_PRO ];

	return false;
}

playerHasPerk( perk )
{
	if ( !isDefined ( perk ) )
		return "UNKOWN";
	
	//Mirror the above function - without "_upgrade"
	if (perk == "specialty_armorvest")
		return self HasPerk( "specialty_armorvest" );
	if (perk == "specialty_quickrevive")
		return self HasPerk( "specialty_quickrevive" );
	if (perk == "specialty_fastreload")
		return self HasPerk( "specialty_fastreload" );
	if (perk == "specialty_rof")
		return self HasPerk( "specialty_rof" );
	if (perk == "specialty_endurance")
		return self HasPerk( "specialty_endurance" );
	if (perk == "specialty_flakjacket")
		return self HasPerk( "specialty_flakjacket" );
	if (perk == "specialty_deadshot")
		return self HasPerk( "specialty_deadshot" );
	if (perk == "specialty_additionalprimaryweapon")
		return self HasPerk( "specialty_additionalprimaryweapon" );
	if (perk == "specialty_bulletdamage")
		return self HasPerk( "specialty_bulletdamage" );		//cherry
	if (perk == "specialty_altmelee")
		return self HasPerk( "specialty_altmelee" );		//vulture
	if (perk == "specialty_bulletaccuracy")
		return self HasPerk( "specialty_bulletaccuracy" );		//widowswine

}

//player is player
// perk is always _upgrade
//HERE
addProPerk( perk )
{
	if (perk == "specialty_armorvest_upgrade") {
		self giveArmorVestUpgrade();
		self.PRO_PERKS[ level.JUG_PRO ] = true;
	}
	if (perk == "specialty_quickrevive_upgrade")
	{
		self.PRO_PERKS[ level.QRV_PRO ] = true;
	}	
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
	if (perk == "specialty_altmelee_upgrade") {
		self.PRO_PERKS[ level.VLT_PRO ] = true;
		self giveVultureUpgrade();
	}
		
	if (perk == "specialty_bulletaccuracy_upgrade") {
		self.PRO_PERKS[ level.WWN_PRO ] = true;
		self giveWidowswineUpgrade();
	}

	//iprintln( " ADD PRO PERK : " + perk);
}

//disableProPerk
disablePerk( perk, time ) 
{
	if( !IsDefined( self ) || !IsDefined( self.PRO_PERKS ) ) {
		//iprintln("disablePerk: self or self.PRO_PERKS is undefined");
		return;
	}

	if( self.superpower_active )
		return;

	proPerk = false;
	base_perk = perk;
	if( IsSubStr( perk, "_upgrade" ) )
	{
		proPerk = true;
		len = "_upgrade".size;
		base_perk = GetSubStr( perk, 0, perk.size - len );
	}

	if( !proPerk && !self HasPerk( base_perk ) )
		return;

	if( proPerk && !self hasProPerk( perk ) ) 
		return;

	self removePerk( perk, "DISABLE" );

	wait( time );

	self returnPerk( perk );
	
}

returnPerk( perk )
{
	proPerk = false;
	base_perk = perk;
	hasBasePerk = self HasPerk( perk );
	hasProPerk = false;

	if( IsSubStr( perk, "_upgrade" ) )
	{
		proPerk = true;
		len = "_upgrade".size;
		base_perk = GetSubStr( perk, 0, perk.size - len );

		hasBasePerk = self HasPerk( base_perk );
		hasProPerk = self hasProPerk( perk );
	}
	
	if( !hasBasePerk )
		self give_perk( base_perk );

	wait( .2 );

	if( proPerk && !hasProPerk )
		self give_perk( perk );
}

removePerk( perk, removeOrDisableHud )
{
	if( !IsDefined( self ) || !IsDefined( self.PRO_PERKS ) ) {
		//iprintln("removePerk: self or self.PRO_PERKS is undefined");
		return;
	}


	if( !IsDefined( removeOrDisableHud) )
		removeOrDisableHud = "REMOVE";

	perk_disabled = ( removeOrDisableHud == "DISABLE" );
	base_perk = perk;
	pro_perk = false;

	if( IsSubStr( perk, "_upgrade" ) )
	{
		proPerk = true;
		len = "_upgrade".size;
		base_perk = GetSubStr( perk, 0, perk.size - len );

		if( !self hasProPerk( perk ) )
		{
			//nothing
		}
		else
		{

			if( perk_disabled )
			{
				self.PERKS_DISABLED[ perk ] = true;
				self manage_ui_perk_hud_interface( "disable", perk );
			}

			//Set player pro perk to false
			self.PRO_PERKS[perk] = false;

			//Trigger notify pro perk + "_stop"
			self notify( perk + "_stop" );
			self notify( base_perk + "_stop" );

			//Set player pro perk to false
			self.PRO_PERKS[perk] = false;
			
		}
				
	}

	//Unset base perk and reset stats by calling perk_think via notify
	if (self HasPerk( base_perk ))
	{

		if( perk_disabled ) {
			self.PERKS_DISABLED[ base_perk ] = true;
		}
		
		wait(0.1);
		self notify( base_perk + "_stop" );
	}

	//self update_perk_hud();
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

//giveMuleUpgrade
giveAdditionalPrimaryWeaponUpgrade() 
{
	//Give player Restock - personal Max Ammo
	if( !self.superpower_active )
		level thread maps\_zombiemode_powerups::full_ammo_powerup_implementation( undefined, self, self.entity_num );

	self thread watch_additionalprimaryweapon_upgrade(level.MUL_PRO + "_stop");
}

watch_additionalprimaryweapon_upgrade( stop_event )
{
	self endon( "death" );
	self waittill( stop_event );
 	//self.weapon_taken_by_losing_additionalprimaryweapon = self maps\_zombiemode::take_additionalprimaryweapon();
}

giveStaminaUpgrade()
{
	self SetClientDvar("ui_show_stamina_ghost_indicator", "1");
	self send_message_to_csc("hud_anim_handler", "stamina_ghost_end");
	self thread watch_stamina_upgrade(level.STM_PRO + "_stop");
}

giveFastreloadUpgrade()
{
	//some indicator for fast reload complete
	//self SetClientDvar("ui_show_stamina_ghost_indicator", "1");
	self.speedcola_swap_timeout = 1;
	self thread watch_fastreload_upgrade(level.SPD_PRO + "_stop");
}

givePhdUpgrade() {
	self thread watch_phd_upgrade(level.PHD_PRO + "_stop");
}

giveVultureUpgrade() {
	self thread watch_vulture_upgrade(level.VLT_PRO + "_stop");
}

giveWidowswineUpgrade() {
	self thread watch_widowswine_upgrade(level.WWN_PRO + "_stop");
}


player_print_msg(msg) {
	flag_wait( "all_players_connected" );
	wait(2);
	//iprintln( msg );
}

disableSpeed( wait_time ) {
		wait(wait_time);
		self disablePerk( level.SPD_PRO, 30 );
}

//Reimagined-Expanded, give people points for proning at vending machines
bump_trigger_think()
{
	self endon("death");

	hash = self GetEntityNumber();

	while(1)
	{
		self waittill("trigger", player);

		if(player in_revive_trigger())
		{
			wait( 0.1 );
			continue;
		}

		if( is_true(player.perk_bumps_activated[""+hash]) )
		{
			wait( 0.1 );
			continue;
		}

		if( self.perk == "specialty_armorvest" && level.apocalypse )
		{
			if( flag("power_on") )
				player thread maps\_zombiemode_reimagined_utility::generate_perk_hint( self.perk );
		}

		if(player GetStance() == "prone")
		{
			player.perk_bumps_activated[""+hash] = true;
			wait(1);
			player thread maps\_zombiemode_score::add_to_player_score( 100 );
			wait( 0.1 );
			continue;
		}

		wait( 0.1 );
	}

}

vending_trigger_think()
{
	self endon("death");

	
	if(self.script_noteworthy == "specialty_longersprint") {
		self.script_noteworthy = "specialty_endurance";
	}

	//self thread turn_cola_off();
	perk = self.script_noteworthy;
	solo = false;
	if(self.script_noteworthy == "specialty_longersprint")
		perk = "specialty_endurance";
	
	//iprintln("PRINT PERK" + perk);
	//Reimagined-Expanded babyjugg!
	if ( IsDefined(perk) && perk == "specialty_extraammo" )
	{
		cost = level.VALUE_BABYJUG_COST;
		if(level.expensive_perks)
		{
			cost = level.VALUE_BABYJUG_EXP_COST;
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
				player maps\_zombiemode_score::add_to_player_score( 100000 );
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
			player thread maps\_zombiemode_reimagined_utility::generate_perk_hint( "babyjugg" );

			player playLocalSound("chr_breathing_hurt");
			player thread maps\_gameskill::event_heart_beat( "panicked" , 1 );
			player player_flag_set( "player_has_red_flashing_overlay" );

			level notify ("player_pain");
			
			player waittill( "end_heartbeat_loop" );

			wait (.2);
			player thread maps\_gameskill::event_heart_beat( "none" , 0 );
			player.preMaxHealth = 140;
			player SetClientDvar("perk_bar_00", convertPerkToShader( level.JUG_PRK ) );
			player send_message_to_csc( "hud_anim_handler", "perk_bar_00_on" );
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

	//player_print_msg( "Setting up perk: " + perk );

	if(level.mapname != "zombie_cod5_sumpf" && level.mapname != "zombie_cod5_prototype"  )
	{
		//iprintln("Setting up bumps");
		machine = GetEntArray(self.target, "targetname");
		for(i = 0; i < machine.size; i++)
		{
			if(IsDefined(machine[i].classname) && machine[i].classname == "script_model")
			{
				level thread add_bump_trigger(self.script_noteworthy, machine[i].origin);
				bump_trigger = Spawn( "trigger_radius", machine[i].origin, 0, 35, 64 );
				bump_trigger.perk = self.script_noteworthy;
				bump_trigger thread bump_trigger_think();
			}
		}	
	}

	//Reimagined-Expanded - Do a no perk run!
	if(level.max_perks == 0) {
		return;
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
			level.solo_lives_given = 3;
			players[0].lives = 3;
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

	case "specialty_bulletdamage_upgrade":	//Cherry
	case "specialty_bulletdamage":
		cost = 2500;
		break;

	case "specialty_altmelee_upgrade":	//Vulture
	case "specialty_altmelee":
		cost = 3000;
		break;

	case "specialty_bulletaccuracy_upgrade":	//wine
	case "specialty_bulletaccuracy":
		cost = 3000;
		break;

	}

	self.cost = cost;

	if ( !solo || level.script == "zombie_cod5_sumpf" ) //fix for being able to buy Quick Revive on solo on Shi No Numa before the perk-a-cola spawn animation is complete
	{
		notify_name = perk + "_power_on";
		//level waittill_any( notify_name, );
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

	/*

	//Classic hintstrings
	PrecacheString( &"ZOMBIE_PERK_QUICKREVIVE" );
	PrecacheString( &"ZOMBIE_PERK_JUGGERNAUT" );
	PrecacheString( &"ZOMBIE_PERK_FASTRELOAD" );
	PrecacheString( &"ZOMBIE_PERK_DOUBLETAP" );
	PrecacheString( &"ZOMBIE_PERK_MARATHON" );
	PrecacheString( &"ZOMBIE_PERK_DIVETONUKE" );
	PrecacheString( &"ZOMBIE_PERK_DEADSHOT" );
	PrecacheString( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
	PrecacheString( &"REIMAGINED_ZOMBIE_PERK_CHERRY" );
	PrecacheString( &"REIMAGINED_ZOMBIE_PERK_VULTURE" );
	PrecacheString( &"REIMAGINED_ZOMBIE_PERK_WIDOW" );

	*/

	switch( perk )
	{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
			 if(level.expensive_perks)
			 	cost = 4000;
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_JUGGERNAUT", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_JUGGERNOG", cost, upgrade_perk_cost );
			break;

		case "specialty_quickrevive_upgrade":
		case "specialty_quickrevive":

			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_QUICKREVIVE", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_QUICKREVIVE", cost, upgrade_perk_cost );
		
			break;

		case "specialty_fastreload_upgrade":
		case "specialty_fastreload":
			
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_FASTRELOAD", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_FASTRELOAD", cost, upgrade_perk_cost );

			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_DOUBLETAP", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_DOUBLETAP", cost, upgrade_perk_cost );
			break;

		case "specialty_endurance_upgrade":
		case "specialty_endurance":
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_MARATHON", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_MARATHON", cost, upgrade_perk_cost );
			break;

		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_DIVETONUKE", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_DIVETONUKE", cost, upgrade_perk_cost );
			break;

		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_DEADSHOT", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_DEADSHOT", cost, upgrade_perk_cost );
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			if( level.classic )
				self SetHintString( &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_MULEKICK", cost, upgrade_perk_cost );
			break;

		case "specialty_extraammo_upgrade":
		case "specialty_extraammo":
			//Unused
			//self SetHintString( &"REIMAGINED_PERK_CHUGABUD", cost, upgrade_perk_cost );
			break;

		case "specialty_bulletdamage_upgrade":
		case "specialty_bulletdamage":
			
			if( level.classic )
				self SetHintString( &"REIMAGINED_ZOMBIE_PERK_CHERRY", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_CHERRY", cost, upgrade_perk_cost );

			break;

		case "specialty_altmelee_upgrade":
		case "specialty_altmelee":
			
			if( level.classic )
				self SetHintString( &"REIMAGINED_ZOMBIE_PERK_VULTURE", cost );
			else
				self SetHintString( &"REIMAGINED_PERK_VULTURE", cost, upgrade_perk_cost );

			break;

		case "specialty_bulletaccuracy_upgrade":
		case "specialty_bulletaccuracy":
			
			if( level.classic )
				self SetHintString( &"REIMAGINED_ZOMBIE_PERK_WIDOWSWINE", cost );
			else
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

	if( level.mapname != "zombie_cod5_sumpf" )
	{
		self watch_perk_trigger( perk, cost, upgrade_perk_cost );
	}
	
}

watch_perk_trigger( perk, cost, upgrade_perk_cost, machineTargetName )
{
	if( !IsDefined(machineTargetname) )
		machineTargetname = "zombie_vending";
	
	perkOffEvent = machineTargetName + "_off";

	level endon("perks_swapping"); //shino
	level endon( perkOffEvent ); //nacht

	CONST_PERK = perk;
	CONST_COST = cost;

	i =0;
	for( ;; )
	{
		i++;
		self waittill( "trigger", player );

		index = maps\_zombiemode_weapons::get_player_index(player);

		if (player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			//iprintln("1");
			continue;
		}

		if(player in_revive_trigger())
		{
			//iprintln("2");
			continue;
		}

		if( player isThrowingGrenade() )
		{
			//iprintln("3");
			wait( 0.1 );
			continue;
		}

 		if( player isSwitchingWeapons() )
 		{
			//iprintln("4");
 			
			wait(0.1);
 			continue;
 		}

		if( player is_drinking() )
		{
			//iprintln("5");
			wait( 0.1 );
			continue;
		}
		
		if( player.PERKS_DISABLED[ perk + "_upgrade"] )
		{
			//iprintln("6");
			wait( 0.1 );
			continue;
		}

		if( player.superpower_active )
		{
			//iprintln("8");
			wait( 2 );
			continue;
		}

		if ( player HasPerk( perk ) )
		{
			//iprintln("9");
			cheat = false;

			//Cant upgrade perks in classic!
			if( level.classic )	
			{
				wait(1);
				continue;
			}

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
			//iprintln("10");
			//player //iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		if ( player.num_perks >= player.perk_slots && !is_true(player._retain_perks) )
		{
			//iprintln("11");
			//player //iprintln( "Too many perks already to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			// COLLIN: do we have a VO that would work for this? if not we'll leave it at just the deny sound
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}
		
		//iprintln( "Bought Perk: " + perk );
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
		if( player HasPerk("specialty_fastreload") && !( player hasProPerk(level.SPD_PRO) ) )
		{
			player UnSetPerk("specialty_fastswitch");
		}
		gun = player perk_give_bottle_begin( perk );
		self thread give_perk_think(player, gun, perk, cost);

		//Reset Perk and Const values for next purchase
		perk = CONST_PERK;
		cost = CONST_COST;
		wait(1);
	}
}

give_perk_think(player, gun, perk, cost)
{
	player waittill_any_or_timeout( player.speedcola_swap_timeout, "fake_death", "death", "player_downed", "weapon_change_complete" );

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

	self thread generate_perk_hint( perk );

	//Reimagined-Expanded
	if( IsSubStr( perk, "_upgrade" ) )
	{	
		if( self hasProPerk( perk ) ) {
			return;
		}

		self addProPerk( perk );
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
		self thread watch_player_qrevive();
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

	if(perk == "specialty_additionalprimaryweapon")
	{
		//self SetPerk("specialty_stockpile");
		self SetClientDvar("ui_show_mule_wep_indicator", "1");
		self thread give_back_additional_weapon();
		self thread additional_weapon_indicator(perk, perk_str);
		self thread unsave_additional_weapon_on_bleedout();
	}

	//iprintln("Giving Perk: " + perk);
	if(perk == level.ECH_PRK)
	{
		self thread player_watch_electric_cherry();
	}

	if(perk == level.VLT_PRK)
	{
		self thread player_watch_vulture();
	}

	if(perk == level.WWN_PRK)
	{
		self thread player_watch_widowswine();
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

	wait( 0.1 );

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
				else if( players[i].PERKS_DISABLED[ perk + "_upgrade"] ) 
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

				//self SetInvisibleToPlayer(players[i], false);		//bugfixing only
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

	//If upgraded perk, return immediately
	if( IsSubStr( perk, "_upgrade" ) )
	{
		return;
	}

	perk_str = perk + "_stop";
	proPerk = perk + "_upgrade";
	proPerk_str = proPerk + "_stop";

	//Reimagined-Expanded perkapunch
	result = self waittill_any_return( "fake_death", "death", "player_downed", perk_str, proPerk_str );
	proPerkAvailable = self hasProPerk( proPerk ) && !self.PERKS_DISABLED[ proPerk ];

	while( proPerkAvailable && result != proPerk_str )
	{
		result = self waittill_any_return( "fake_death", "death", "player_downed", perk_str, proPerk_str );
		proPerkAvailable = self hasProPerk( proPerk ) && !self.PERKS_DISABLED[ proPerk ];
	}
	//iprintln( "Perk Think: " + result );
	wait( 0.1 );

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
				current_wep = self GetCurrentWeapon();
				self.weapon_taken_by_losing_additionalprimaryweapon = self maps\_zombiemode::take_additionalprimaryweapon();

				swapPlayerWeapon = IsDefined( self.weapon_taken_by_losing_additionalprimaryweapon[0] );
				swapPlayerWeapon = swapPlayerWeapon && current_wep == self.weapon_taken_by_losing_additionalprimaryweapon[0];

				if( swapPlayerWeapon )
				{
					self SwitchToWeapon( self GetWeaponsListPrimaries()[0] );
				}
				
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
	if( !self.PERKS_DISABLED[ perk + "_upgrade" ] )
	{
		//iprintln( "Perk Think: " + perk + " " + result );
		self perk_hud_destroy( perk );
	}
		

	self.perk_purchased = undefined;
	//self //iprintln( "Perk Lost: " + perk );


	if ( IsDefined( level.perk_lost_func ) )
	{
		self [[ level.perk_lost_func ]]( perk );
	}

	self notify( "perk_lost" );
}

manage_ui_perk_hud_interface( command, perk )
{
	notify_message = "ui_perk_hud_next";
	queue_num = self.perk_hud_queue_num;
	self.perk_hud_queue_num++;

	while( self.perk_hud_queue_locked  || self.perk_hud_queue_unlocks_num < queue_num ) 
	{
		//self waittill( notify_message );	
		wait 0.05;
	}
	self.perk_hud_queue_locked = true;

	self manage_ui_perk_hud( command, perk );

	self.perk_hud_queue_unlocks_num++;
	self.perk_hud_queue_locked = false;
	self notify( notify_message );
}

manage_ui_perk_hud( command, perk )
{
	total_perks = self.purchased_perks.size;
	reset_all = false;

	if( command == "add" || command == "upgrade" )
	{
		if( self.PERKS_DISABLED[ perk ] )
			command = "enable";
	}
	
	switch( command )
	{
		case "add":
			self.purchased_perks[ total_perks ] = perk;
			break;

		case "upgrade":
			//Loop through purchased perks to find base perk
			base_perk = GetSubStr( perk, 0, perk.size - 8); //remove "_upgrade"
			perk_num = total_perks;
			for( i=0; i < total_perks; i++ ) 
			{
				if( self.purchased_perks[i] == base_perk ) {
					perk_num = i;
					break;
				}
			}
			
			self.purchased_perks[ perk_num ] = perk;
			break;

		case "remove":
			perk_num = -1;
			for( i=0; i < total_perks; i++ ) 
			{
				if( !IsDefined( self.purchased_perks[i] ) )
					break;

				if( IsSubStr(  self.purchased_perks[i], perk ) ) {
					perk_num = i;
					break;
				}
			}

			if( perk_num == -1 )
				return;
			
			for( i=perk_num; i < level.VALUE_MAX_AVAILABLE_PERKS; i++ ) 
			{
				if( i == total_perks )
				{
					self.purchased_perks[i] = undefined;
					break;
				}

				self.purchased_perks[i] = self.purchased_perks[i+1];

			}
			reset_all = true;
			break;

		case "disable":
			self.PERKS_DISABLED[ perk ] = true;
			reset_all = true;
			break;

		case "enable":
			//handled elsewhere, dont want to add more perks to UI
			self.PERKS_DISABLED[ perk ] = false;
			break;

		case "flash_start":

			if( self.PERKS_FLASHING[ perk ] )
				return;

			self.PERKS_FLASHING[ perk ] = true;
			break;

		case "flash_end":
			self.PERKS_FLASHING[ perk ] = false;
			reset_all = true;
			break;

		default:
			break;

	}

	base = "perk_slot_";
	
	//Update Perk Hud after each change
	for( i=0; i < level.VALUE_MAX_AVAILABLE_PERKS; i++ ) 
	{
		perk_key = base;
		if( i < 10 )
			perk_key += "0";
		perk_key += i;

		if( reset_all ) 
		{

			if( self.PERKS_FLASHING[ self.purchased_perks[i] ]) 
			{
				self notify( perk_key + "_flash_stop" );
				wait( 0.1 );
				self.PERKS_FLASHING[ self.purchased_perks[i] ] = true;
			}

			self ui_perk_hud_remove( perk_key );
		}
		

		if( !IsDefined( self.purchased_perks[i] ) )
			break; //No more perks to update

		if( self.PERKS_FLASHING[ self.purchased_perks[i] ] ) {
			self thread ui_perk_hud_start_flash( self.purchased_perks[i], perk_key );
			continue;
		}
			

		if( self.PERKS_DISABLED[ self.purchased_perks[i] ] )
			self ui_perk_hud_disable( self.purchased_perks[i], perk_key );
		else
			self ui_perk_hud_activate( self.purchased_perks[i], perk_key );
			
	}
	
}

ui_perk_hud_activate( perk, perk_key )
{

	if( IsSubStr( perk, "_upgrade" ) ) 
	{
		shader = convertProPerkToShaderPro( perk );
	}
	else 
	{
		shader = convertPerkToShader( perk );
	}

	client_msg = perk_key + "_on";
	
	self SetClientDvar(perk_key, shader);
	self send_message_to_csc("hud_anim_handler", client_msg);
}

ui_perk_hud_remove( perk_key )
{

	client_msg = perk_key + "_off";

	self SetClientDvar(perk_key, "");	//Too much fading in and out
	self send_message_to_csc("hud_anim_handler", client_msg);
}

ui_perk_hud_disable( perk, perk_key )
{
	if( IsSubStr( perk, "_upgrade" ) ) 
	{
		shader = convertProPerkToShaderPro( perk );
	}
	else 
	{
		shader = convertPerkToShader( perk );
	}

	//client_msg = perk_key + "_fade";
	client_msg = perk_key + "_dark";

	self SetClientDvar(perk_key, shader);
	self send_message_to_csc("hud_anim_handler", client_msg);
}

ui_perk_hud_start_flash( perk, perk_key )
{
	//client_msg_flash = perk_key + "_off"; //_FLASH
	client_msg_flash = perk_key + "_fade"; //_FLASH
	client_msg_normal = perk_key + "_on";

	queue_num = self.perk_hud_queue_num;

	self thread player_watch_ui_perk_hud_stop_flash( perk, perk_key + "_flash" );

	base_perk = perk;
	if( IsSubStr( perk, "_upgrade" ) ) 
	{
		base_perk = GetSubStr( perk, 0, perk.size - 8); //remove "_upgrade"
	}

	keepFlashing = self.PERKS_FLASHING[ perk ];
	ANIM_TIME = 0.8;
	while( keepFlashing )
	{
		self send_message_to_csc("hud_anim_handler", client_msg_flash);
		self perk_flash_audio( base_perk );

		time =0;
		while( time < ANIM_TIME )
		{
			time += 0.1;
			wait( 0.1 );
			if( !self.PERKS_FLASHING[ perk ] )
				return;
		}

		self send_message_to_csc("hud_anim_handler", client_msg_normal);

		time =0;
		while( time < ANIM_TIME )
		{
			time += 0.1;
			wait( 0.1 );
			if( !self.PERKS_FLASHING[ perk ] )
				return;
		}
	}

}

player_watch_ui_perk_hud_stop_flash( perk, perk_key )
{
	self waittill_any( "perk_lost", perk_key + "_stop");
	self.PERKS_FLASHING[ perk ] = false;
}


perk_hud_create( perk )
{

	//test if perk contains "_upgrade" and if it does, remove it
	if( IsSubStr( perk, "_upgrade" ) )
	{
		self manage_ui_perk_hud_interface( "upgrade", perk );	
	}
	else 
	{
		self manage_ui_perk_hud_interface( "add", perk );
	}

/*
	a = 1;
	if( a==1 )
		return;

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

	//watch_electric_cherry
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

		case "specialty_extraammo_upgrade":
		case "specialty_extraammo":
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

		case "specialty_bulletaccuracy_upgrade":
		case "specialty_bulletaccuracy":
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
		basePerk = GetSubStr( perk, 0, perk.size - 8); //remove "_upgrade"
		
		if( self.PERKS_DISABLED[ perk ] ) {	
			//Reenable disabled pro perk
			self.perk_hud[ basePerk ].alpha = 1;
		} else {
			//Set Pro Shader
			shader = shader + "_pro";
			self.perk_hud[ basePerk ] SetShader( shader, 24, 24 );
		}

		return;
	}

	if( self.PERKS_DISABLED[ perk + "_upgrade"] )
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
	*/
}


perk_hud_destroy( perk )
{
	if( self.PERKS_DISABLED[ perk ] )
		self manage_ui_perk_hud_interface( "disable", perk );
	else
		self manage_ui_perk_hud_interface( "remove", perk );
	//self.perk_hud_num = array_remove_nokeys(self.perk_hud_num, perk);
	//self.perk_hud[ perk ] destroy_hud();
	//self.perk_hud[ perk ] = undefined;
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
		case "specialty_bulletdamage":
            alias = "zmb_hud_flash_phd";
            break;

        case "specialty_deadshot":
		case "specialty_bulletaccuracy":
            alias = "zmb_hud_flash_deadshot";
            break;

        case "specialty_additionalprimaryweapon":
		case "specialty_altmelee":
            alias = "zmb_hud_flash_additionalprimaryweapon";
            break;
    }

    if( IsDefined( alias ) )
        self PlayLocalSound( alias );
}

//Reimagined-Expanded, refactored
perk_hud_start_flash( perk, damage )
{

	if ( self HasPerk( perk ) )
	{
		proPerk = perk + "_upgrade";

		if( self.PERKS_FLASHING[ perk ] || self.PERKS_FLASHING[ proPerk ] ) 
		{
			return;
		}
		
		
		if( self hasProPerk( proPerk ) ) 
		{
			self manage_ui_perk_hud_interface( "flash_start", proPerk );
		}
		else
		{
			self manage_ui_perk_hud_interface( "flash_start", perk );
		}
	}
}

perk_hud_stop_flash( perk, taken )
{
	if( !IsDefined( taken ) )
		taken = false;

	if ( self HasPerk( perk ) )
	{
		proPerk = perk + "_upgrade";
		if( self hasProPerk( proPerk ) && self.PERKS_FLASHING[ proPerk ] ) 
		{

			self manage_ui_perk_hud_interface( "flash_end", proPerk );
			if( taken )
				self thread disablePerk( proPerk, level.VALUE_ZOMBIE_COSMODROME_MONKEY_DISABLE_PRO_PERK_TIME );
				
		}
		else if( self.PERKS_FLASHING[ perk ] )
		{
			self manage_ui_perk_hud_interface( "flash_end", perk );

			if( taken )
				self removePerk( perk );
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

	case "specialty_bulletaccuracy": // ww: wine
	case "specialty_bulletaccuracy_upgrade":
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

// UPGRADE PERK powerup_solo
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

	case "specialty_bulletaccuracy": // ww: wine
	case "specialty_bulletaccuracy_upgrade":
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

	while( is_true( self.superpower_active ) ) {
		wait( 1 );
	}

	perks = [];
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[i].script_noteworthy;

		if(perk == "specialty_extraammo") //babyjugg
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

//Normal Qrevive
watch_player_qrevive()
{
	
	self endon("disconnect");
	self endon("death");
	self endon("fake_death");
	self endon("end_game");


	//iprintln("watch_player_qrevive");

	//if solo game, return
	if( level.players_count == 1 )
	{
		return;
	}
		

	self waittill("player_downed");
	
	//loop over self.purchased_perks
	returnablePerks = [];
	for(i=0;i<self.purchased_perks.size;i++)
	{
		if(self.purchased_perks[i] == level.QRV_PRK)
			continue;

		//if its a pro perk, continue
		if(IsSubStr(self.purchased_perks[i], "_upgrade"))
			continue;

		returnablePerks[returnablePerks.size] = self.purchased_perks[i];
	}

	if(returnablePerks.size == 0)
		return;

	//waittill revived
	self waittill("player_revived");

	perkToReturn = array_randomize(returnablePerks)[0];
	self give_perk(perkToReturn);
	
}

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
		//waittill_return = self waittill_any_return("melee", "damage");
		waittill_return = self waittill_any_return("melee");

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
		if( IsDefined( level.set_custom_visionset_func ) )
		{
			//Handled in CSC
		}
		else
		{
			//iprintln("zombie visionset" + level.zombie_visionset + " " + self.entity_num);
			self VisionSetNaked( "zombie_blood", 0.5 );
		}
		
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

		//iprintln("zombie visionset" + level.zombie_visionset);
		
		if( IsDefined( level.set_custom_visionset_func ) )
			[[ level.set_custom_visionset_func ]]( self );
		else if( IsDefined( level.zombie_visionset ) )
			self VisionSetNaked( level.zombie_visionset, 0.5 );
		else	
			self VisionSetNaked( "undefined", 0.5 );
			

	}

	checkDist(a, b, distance )
	{
		if( !IsDefined( a ) || !IsDefined( b ) )
		{
			//iprintln("checkDist for distance: " + distance + " is undefined" );
			return false;
		}
			

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

	while(1)
	{
		
		//wait till player switches weapons
		self waittill("weapon_switch_complete", perk_str);
		//iprintln("Observed weapon switch");	

		if(self hasProPerk( level.SPD_PRO ) )
		{
			self thread magicReload();
		}
		else
		{
			break;
		}
		wait(0.1);
	}

	self.speedcola_swap_timeout = 10;
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

		if( self HasPerk( level.ECH_PRK) )
			self electric_cherry_reload_attack( self.cherry_sequence, weapons[i] );		//triggers cherry

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
			wait( 0.1 );
		}

		if( IsDefined( self.divetoprone ) && self.divetoprone == 1) 
		{
			self thread managePlayerZombieCollisions( level.TOTALTIME_PHD_PRO_COLLISIONS ,
			 level.VALUE_PHD_PRO_COLLISIONS_RANGE ); //total time, dist

			 //while( self.divetoprone == 1 ) { wait_network_frame();}
			 wait( 0.7 );
			if ( IsDefined( level.zombiemode_divetonuke_perk_func ) )
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin, false );
			
		}

		wait(0.1);
	}

}




//=========================================================================================================
// Electric Cherry
//=========================================================================================================
#using_animtree( "generic_human" );

init_electric_cherry()
{
	level._effect[ "electric_cherry_reload_large" ] = LoadFX( "electric_cherry/fx_electric_cherry_shock_large" );
	level._effect[ "electric_cherry_pool" ] = LoadFX( "electric_cherry/fx_electric_cherry_pool" );
	
	//Reimagined-Expanded
	// See weapon_effects::init() fr init tesla shock fx

	set_zombie_var( "tesla_head_gib_chance", 50 );
	level.electric_stun = [];

	level.electric_stun[0] = %ai_zombie_afterlife_stun_a;
	level.electric_stun[1] = %ai_zombie_afterlife_stun_b;
	level.electric_stun[2] = %ai_zombie_afterlife_stun_c;
	level.electric_stun[3] = %ai_zombie_afterlife_stun_d;
	level.electric_stun[4] = %ai_zombie_afterlife_stun_e;

}


//Self is player
player_watch_electric_cherry()
{
	while( self HasPerk( level.ECH_PRK ) )
	{
		self waittill_any( "reload_start", level.ECH_PRK + "_stop" );

		self thread electric_cherry_reload_attack( self.cherry_sequence );
		if( self.cherry_sequence == 0 )
			self thread player_handle_eletric_cherry_cooldown();

		self.cherry_sequence++;
		//self waittill_any_or_timeout( level.VALUE_CHERRY_SHOCK_SHORT_COOLDOWN, "reload");
		wait( level.VALUE_CHERRY_SHOCK_SHORT_COOLDOWN );
	}

}

//Stop Condenscing methods

	electric_cherry_reload_attack( sequence, weapon )
	{
		self endon( "death" );
		self endon( "disconnect" );

		
		n_fraction = 0;
		if( weapon == "none" ) {
			//nothing
		} else 
		{
			if( !isDefined( weapon ) )
				weapon = self GetCurrentWeapon();

			n_clip_current = self GetWeaponAmmoClip( weapon );
			n_clip_max = WeaponClipSize( weapon );
			n_fraction = n_clip_current / n_clip_max;

		}
		
		perk_radius = level.VALUE_CHERRY_SHOCK_RANGE;
		perk_dmg = level.VALUE_CHERRY_SHOCK_DMG;
		max_enemies = level.VALUE_CHERRY_SHOCK_MAX_ENEMIES;
		efx_range = (32, 32, 4);

		if( n_fraction > 0.75 || sequence>=4 )
			sequence=3;
		else if( n_fraction > 0.5 || sequence==3 )
			sequence=2;
		else if( n_fraction > 0.25 || sequence==2 )
			sequence=1;
		else
			sequence=0;

		fr = 10/16;	// Reduce scalars by 60&, reciprol of 16/10
		for( i = 0; i < sequence; i++ ) 
		{
			perk_radius = int( perk_radius * fr );
			perk_dmg = int( perk_dmg * fr );
			max_enemies = int( max_enemies * fr );
		}

		if( self hasProPerk( level.ECH_PRO) )
		{
			perk_radius = int( perk_radius * level.VALUE_CHERRY_PRO_SCALAR);
			perk_dmg = int( perk_dmg * level.VALUE_CHERRY_PRO_SCALAR );
			max_enemies = int( max_enemies * level.VALUE_CHERRY_PRO_SCALAR );
		}

		self thread electric_cherry_reload_fx( efx_range, perk_radius );
		
		a_zombies = GetAISpeciesArray( "axis", "all" );
		a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, perk_radius );
		n_zombies_hit = 0;
		height_limit = 30;
		
		for( i = 0; i < a_zombies.size; i ++ )
		{
			if( is_true(a_zombies[i].marked_for_tesla) || is_true( self.head_gibbed) )
				continue;

			if( IsAlive( self ) && IsAlive( a_zombies[i] ) && !is_boss_zombie( a_zombies[i].animname  ))
			{

				height_diff = self.origin[2] - a_zombies[i].origin[2];
				if( (height_diff > height_limit) || (height_diff < -1*height_limit) )
					continue;

				if( n_zombies_hit > max_enemies )
					break;
				a_zombies[i].marked_for_tesla = true;

				if( a_zombies[i].health <= perk_dmg ) 
				{
					a_zombies[i] thread electric_cherry_death_fx();
				}
				else 
				{
		
					a_zombies[i] thread electric_cherry_stun();
					a_zombies[i] thread electric_cherry_shock_fx();

					a_zombies[i] thread wait_reset_tesla_mark();
				}
				wait 0.1;
				a_zombies[i] DoDamage( perk_dmg, a_zombies[i].origin, self, undefined, "crush", level.ECH_PRK );
				n_zombies_hit++;

			}
		}
		

	}
		
		wait_reset_tesla_mark()
		{
			wait( level.THRESHOLD_TESLA_SHOCK_TIME );
			if( IsDefined( self ) && IsAlive( self ) )
				self.marked_for_tesla = false;
		}
	

		//Reload fx 
		electric_cherry_reload_fx( range, perk_radius ) 
		{
			//self PlaySound( "cherry_explode" );	//"Explode" sound file, unused
			self PlaySound( "zmb_cherry_explode" );
		
			//Nested for loop to create a 2x2 grid of fx
			for( i = -1; i < 2; i +=2 ) 
			{
				for( j = -1; j < 2; j +=2 ) {
					offset = range * (i, j, 1);
					self thread handle_cherry_pool_fx( self.origin, offset );
				}
			}
			
		}

			handle_cherry_pool_fx( origin, offset )
			{
				model = Spawn( "script_model", self.origin );
				model setModel( "tag_origin" );
				model LinkTo( self, "tag_origin", offset, ( 270, 0, 0 ) );

				PlayFXOnTag(level._effect[ "electric_cherry_reload_large" ], model, "tag_origin" );
				wait( level.VALUE_CHERRY_SHOCK_RELOAD_FX_TIME );
				model delete();
			}
	
	
		electric_cherry_death_fx()
		{
			self endon( "death" );
			tag = "J_SpineUpper";
			fx = "fx_electric_cherry_shock";
			if( is_true(self.isdog) )
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
			fx = "fx_electric_cherry_shock";
			if( is_true( self.isdog ) )
			{
				tag = "J_Spine1";
			}
			else if( self.animname == "monkey_zombie" )
			{
				self animscripted( "tesla_death", self.origin, self.angles, level._zombie_tesla_death["monkey_zombie"][0] );
			}

			self PlaySound( "zmb_elec_jib_zombie" );
			network_safe_play_fx_on_tag( "tesla_shock_fx", 2, level._effect[ fx ], self, tag );
		}
		
		
		
		electric_cherry_stun()
		{
			self endon( "death" );
			self notify( "stun_zombie" );
			//self endon( "stun_zombie" );

			if( self.animname != "zombie" ) 
				return;	

			if( self.health <= 0 )
			{
				return;
			}
			if( !self.has_legs )
			{
				return;
			}
			if( !is_in_array( level.ARRAY_VALID_STANDARD_ZOMBIES, self.animname ) )
			{
				return;
			}
			self.forcemovementscriptstate = true;
			self.ignoreall = true;
			for( i = 0; i < 2; i ++ )
			{
				self AnimScripted( "stunned", self.origin, self.angles, level.electric_stun[0] );
				self animscripts\zombie_shared::DoNoteTracks( "stunned" );
			}
			self.forcemovementscriptstate = false;
			self.ignoreall = true;
			self SetGoalPos( self.origin );
			self thread maps\_zombiemode_spawner::find_flesh();
		}

	player_handle_eletric_cherry_cooldown()
	{
		wait( level.VALUE_CHERRY_SHOCK_LONG_COOLDOWN );
		self.cherry_sequence = 0;
	}

	//Self is player, only triggers if player has Cherry Pro
	player_electric_cherry_defense( zombie )
	{
		self.cherry_defense = false;
		cherry_damage = level.VALUE_CHERRY_SHOCK_DMG * level.VALUE_CHERRY_PRO_SCALAR;
		kill_zombie = ( cherry_damage > zombie.health ) || zombie.animname != "zombie"; //just kill dogs and monkeys and quads, no stun fx

		if( kill_zombie ) 
		{
			zombie thread electric_cherry_death_fx();
		}
		else {
			zombie thread electric_cherry_stun();
			zombie thread electric_cherry_shock_fx();

			zombie thread wait_reset_tesla_mark();
		}

		zombie.marked_for_tesla = true;
		zombie DoDamage( cherry_damage, zombie.origin, self, level.ECH_PRK, "cush" );

		self thread electric_cherry_reload_attack( 2, "NONE" );
		self player_cherry_defense_cooldown();
	}

	//self is player
	player_cherry_defense_cooldown() 
	{
		self endon( "disconnect" );
		self endon( "death" );
		
		wait( level.VALUE_CHERRY_PRO_DEFENSE_COOLDOWN );
		self.cherry_defense = true;
	}


//=========================================================================================================
// Vulture Aid
//=========================================================================================================


//Self is player
player_watch_vulture()
{
	self send_message_to_csc("hud_anim_handler", "vulture_hud_on");
	self.vulture_had_perk = true; //turned off after vulture_destroy_waypoints();
	self thread player_watch_vulture_stop( "vulture_vision_toggle" );
	self thread player_watch_vulture_toggle( "vulture_vision_toggle" );
	self thread player_create_vulture_vision_weapons();
	self thread player_create_vulture_vision_box_glow();

	while( self HasPerk( level.VLT_PRK ) )	{
		//wait
		wait(0.1);
	}

	self notify( level.VLT_PRK + "_stop" );
	self send_message_to_csc("hud_anim_handler", "vulture_hud_off");
}

//Self is player

	player_create_vulture_vision_weapons()
	{
		structs = level.vulture_waypoint_structs;
		for( i = 0; i < structs.size; i++ )
		{
			struct = structs[i];
			if( is_true( struct.is_weapon ) )
				create_loop_fx_to_player( self, struct.ent_num, struct.fx_var, struct.origin, struct.angles );
		}

		self waittill( level.VLT_PRK + "_stop" );

		for( i = 0; i < structs.size; i++ )
		{
			struct = structs[i];
			if( is_true( struct.is_weapon ) )
				destroy_loop_fx_to_player( self, struct.ent_num, true );
		}
		
	}

	//*
	player_create_vulture_vision_box_glow()
	{
		structs = level.vulture_waypoint_structs;
		while( 1 )
		{
			if( !(self HasPerk( level.VLT_PRK )) )
				break;

			//Create fx where box is
					
			for( i = 0; i < structs.size; i++ )
			{
				struct = structs[i];
				if( IsDefined( struct.chest_to_check ) && check_waypoint_visible( self, struct ) ) 
				{
					create_loop_fx_to_player( self, struct.ent_num, struct.fx_var, struct.origin, struct.angles );
					struct.fx_created = true;
				}
					
			}
			
			//Wait for firesale or box moved event
			vision_toggle_event = "vulture_vision_toggle" + self GetEntityNumber();
			event = level waittill_any_return( "powerup fire sale",
											 "fire_sale_off",
											 "moving_chest_now",
											 "player_downed",
											 vision_toggle_event );
			
			//Destroy fx
			for( i = 0; i < structs.size; i++ )
			{
				struct = structs[i];
				if( is_true( struct.chest_to_check ) && is_true( struct.fx_created ) )
					destroy_loop_fx_to_player( self, struct.ent_num, true );
			}

			if( event == vision_toggle_event )
			{
				if( !(self HasPerk( level.VLT_PRK )) )
					break;

				level waittill( vision_toggle_event );

				continue;
			}
			
			//Handle player downed
			if( event == "player_downed" )
			{
				if( !self maps\_laststand::player_is_in_laststand() )
					continue;
			
				
				self waittill_any( "player_revived", "disconnect", "bled_out", "death" );

				if( !(self HasPerk( level.VLT_PRK )) )
					break;
			}
			
			event = level waittill_any_return( 	 "powerup fire sale",
												 "fire_sale_off",
												 "moving_chest_done",
											 	 vision_toggle_event
												);
			
			wait 1;
		}

		//Destroy any existing fx
		
	}
	// */

	player_watch_vulture_toggle( level_notify_str )
	{
		self endon( "disconnect" );
		self endon( level.VLT_PRK + "_stop" );

		while( 1 )
		{
			if( self ADSButtonPressed() && self MeleeButtonPressed() )
			{
				//iprintln( "Vulture Vision Toggled" );
				vulture_vision_toggle_event = level_notify_str + self GetEntityNumber();
				level notify( vulture_vision_toggle_event );
				self.vulture_vison_toggle = !self.vulture_vison_toggle;	
				wait( 1 );
			}
			
				
			wait( 0.1 );
		}
	}

	player_watch_vulture_stop( level_notify_str )
	{
		VULTURE_STOP = level.VLT_PRK + "_stop";
		VULTURE_PRO_STOP = level.VLT_PRO + "_stop";

		event = self waittill_any_return( 	VULTURE_STOP, VULTURE_PRO_STOP );
		//iprintln( "Vulture Vision STOP" );

		level notify( level_notify_str + self GetEntityNumber() );
	}


watch_vulture_upgrade( perk_str )
{
	self send_message_to_csc("hud_anim_handler", "vulture_hud_pro");

	//Reactivate zombies that have drops
	thread vulture_activate_zombie_powerup_glow();

	self thread player_vulture_upgrade_zombie_immune( perk_str );
	//self thread test_disable_vulture();
	self waittill( perk_str );
	self send_message_to_csc("hud_anim_handler", "vulture_hud_off");
}

//Zombies don't attack player for 15s at begging of each round
player_vulture_upgrade_zombie_immune( perk_str )
{

	while( self hasProPerk( level.VLT_PRO ) )
	{
		level waittill( "start_of_round" );

		//self.ignoreme = true;
		wait( level.VALUE_VULTURE_ROUND_START_ZOMBIE_IMMUNITY );
		//self.ignoreme = false;

		level waittill( "end_of_round" );
	}

}

test_disable_vulture()
{
	wait( 5 );
	disablePerk( level.VLT_PRO, 10 );
}
	
 vulture_activate_zombie_powerup_glow()
 {
	//Get all zombies
	zombies = GetAISpeciesArray( "axis", "all" );
	for( i = 0; i < zombies.size; i++ ) 
	{
		hasDrop = IsDefined( zombies[i].hasDrop ) && 
			( zombies[i].hasDrop == "GREEN" || zombies[i].hasDrop == "BLUE" );

		if( hasDrop )
		{
			zombies[i] setclientflag(level._ZOMBIE_ACTOR_ZOMBIE_HAS_DROP);
			wait( 0.1 );
			zombies[i] clearclientflag(level._ZOMBIE_ACTOR_ZOMBIE_HAS_DROP);
		}
	
	}
 }

end_game_turn_off_vulture_overlay()
{
	self endon( "disconnect" );
	level waittill( "end_game" );
	//self thread take_vulture_perk();
}

init_vulture_assets()
{	
	PreCacheModel( "bo2_p6_zm_perk_vulture_ammo" );
	PreCacheModel( "bo2_p6_zm_perk_vulture_points" );

	PreCacheShader( "specialty_glow_rifle" );
	PreCacheShader( "specialty_glow_magic_box" );
	PreCacheShader( "specialty_glow_pap" );	
	PreCacheShader( "specialty_glow_skull" );
	PreCacheShader( "specialty_glow_wunderfizz" );

	level._effect[ "vulture_glow" ] = LoadFX( "vulture/fx_vulture_glow" );
	level._effect[ "vulture_perk_mystery_box_glow" ] = LoadFX( "vulture/fx_vulture_box" );
	level._effect[ "vulture_skull" ] = LoadFX( "vulture/fx_vulture_skull" );
	//level._effect[ "vulture_perk_bonus_drop" ] = level._effect["powerup_on_solo"]; //used in clientscript

	/*
	PreCacheShader( "hud_vulture_aid_stink" );
	PreCacheShader( "hud_vulture_aid_stink_outline" );
	//level._effect[ "vulture_perk_zombie_stink" ] = LoadFX( "vulture/fx_zm_vulture_perk_stink" );
	//level._effect[ "vulture_perk_zombie_stink_trail" ] = LoadFX( "vulture/fx_zm_vulture_perk_stink_trail" );
	//level._effect[ "vulture_perk_bonus_drop" ] = LoadFX( "vulture/fx_zombie_powerup_vulture" );
	//level._effect[ "vulture_drop_picked_up" ] = LoadFX( "misc/fx_zombie_powerup_grab" );
	level._effect[ "vulture_perk_machine_glow_doubletap" ] = LoadFX( "vulture/fx_vulture_double" );
	level._effect[ "vulture_perk_machine_glow_juggernog" ] = LoadFX( "vulture/fx_vulture_jugg" );
	level._effect[ "vulture_perk_machine_glow_revive" ] = LoadFX( "vulture/fx_vulture_revive" );
	level._effect[ "vulture_perk_machine_glow_speed" ] = LoadFX( "vulture/fx_vulture_speed" );
	level._effect[ "vulture_perk_machine_glow_marathon" ] = LoadFX( "vulture/fx_vulture_stamin" );
	level._effect[ "vulture_perk_machine_glow_mule_kick" ] = LoadFX( "vulture/fx_vulture_mule" );
	level._effect[ "vulture_perk_machine_glow_pack_a_punch" ] = LoadFX( "vulture/fx_vulture_pap" );
	level._effect[ "vulture_perk_machine_glow_vulture" ] = LoadFX( "vulture/fx_vulture_vulture" );
	level._effect[ "vulture_perk_machine_glow_electric_cherry" ] = LoadFX( "vulture/fx_vulture_cherry" );
	level._effect[ "vulture_perk_machine_glow_phd_flopper" ] = LoadFX( "vulture/fx_vulture_phd" );
	//level._effect[ "vulture_perk_machine_glow_whos_who" ] = LoadFX( "vulture/fx_vulture_whoswho" );
	level._effect[ "vulture_perk_machine_glow_widows_wine" ] = LoadFX( "vulture/fx_vulture_widow" );
	level._effect[ "vulture_perk_machine_glow_deadshot" ] = LoadFX( "vulture/fx_vulture_deadshot" );
	level._effect[ "vulture_perk_mystery_box_glow" ] = LoadFX( "vulture/fx_vulture_box" );
	//level._effect[ "vulture_perk_powerup_drop" ] = LoadFX( "vulture/fx_vulture_powerup" );
	//level._effect[ "vulture_perk_zombie_eye_glow" ] = LoadFX( "vulture/fx_zombie_eye_vulture" );
	*/
	
}

init_vulture()
{
	init_vulture_assets();
	level.perk_vulture = SpawnStruct();
	level.perk_vulture.zombie_stink_array = [];
	level.perk_vulture.drop_slots_for_network = 0;
	level.perk_vulture.last_stink_zombie_spawned = 0;
	level.perk_vulture.use_exit_behavior = false;
	//maps\_zombiemode_spawner::add_cusom_zombie_spawn_logic( ::vulture_zombie_spawn_func );
	//maps\_zombiemode_spawner::register_zombie_death_event_callback( ::zombies_drop_stink_on_death );

	
	true_thing = true;
	if( true_thing )
	{
		//return;
	}

	flag_wait( "all_players_connected" );
	level thread vulture_watch_powerup_waypoints();
	level thread vulture_perk_watch_waypoints();
	level thread vulture_perk_watch_mystery_box();
	level thread vulture_perk_watch_fire_sale();
	level thread vulture_perk_watch_pap_move();
		
}


/* Waypoints */
 

	vulture_perk_watch_waypoints()
	{
		setup_perk_machine_fx();
		wait 1;
		structs = [];
		weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" );
		weapon_spawns = array_combine( weapon_spawns, GetEntArray( "betty_purchase", "targetname" ) );
		//weapon_spawns = array_combine( weapon_spawns, GetEntArray( "tazer_upgrade", "targetname" ) );
		weapon_spawns = array_combine( weapon_spawns, GetEntArray( "bowie_upgrade", "targetname" ) );
		weapon_spawns = array_combine( weapon_spawns, GetEntArray( "claymore_purchase", "targetname" ) );
		weapon_spawns = array_combine( weapon_spawns, GetEntArray( "sickle_upgrade", "targetname" ) );
		weapon_spawns = array_combine( weapon_spawns, GetEntArray( "spikemore_purchase", "targetname" ) );

		for( i = 0; i < weapon_spawns.size; i ++ )
		{
			model = GetEnt( weapon_spawns[i].target, "targetname" );
			struct = SpawnStruct();
			struct.location = weapon_spawns[i] get_waypoint_origin( "wallgun" );
			struct.origin = struct.location[ "origin" ];
			struct.angles = struct.location[ "angles" ];
			struct.is_weapon = true;
			struct.check_perk = false;
			struct.perk_to_check = undefined;
			struct.is_revive = false;
			struct.is_chest = false;
			struct.chest_to_check = undefined;
			struct.fx_var = "vulture_glow";
			struct.ent_num = model GetEntityNumber();
			struct.script_model = Spawn( "script_model", struct.origin );
			struct.player_waypoint = [];
			struct.wp_type = "WEAPON";
			struct.waypoint_name = "specialty_glow_rifle";

			structs[ structs.size ] = struct;
		}
		vending_triggers = GetEntArray( "zombie_vending", "targetname" );
		for( i = 0; i < vending_triggers.size; i ++ )
		{
			perk = vending_triggers[i].script_noteworthy;
			struct = SpawnStruct();
			struct.perk = perk;
			struct.location = vending_triggers[i] get_waypoint_origin( "perk" );
			struct.origin = struct.location[ "origin" ];
			struct.angles = struct.location[ "angles" ];
			struct.check_perk = perk != "specialty_altmelee";
			struct.perk_to_check = perk;
			struct.is_revive = perk == "specialty_quickrevive";
			struct.is_chest = false;
			struct.chest_to_check = undefined;
			struct.fx_var = "vulture_glow";
			struct.ent_num = vending_triggers[i] GetEntityNumber();
			if( IsDefined(struct.origin) )
				struct.script_model = Spawn( "script_model", struct.origin );
			struct.waypoint_name = convertPerkToShader( perk ) + "_pro";
			struct.wp_type = "PERK";
			struct.player_waypoint = [];

			structs[ structs.size ] = struct;
		}

		if( level.mapname == "zombie_moon" )
		{
			//This is just moon case, may need more fine tuning for shino
			for( i = 0; i < structs.size; i++ )
			{
				struct = structs[i];
				if( IsDefined(struct.perk ) )
					continue;

				//Add Jugg
				struct.perk = level.JUG_PRK;
				structs[ structs.size ] = struct;

				//Add speed
				struct.perk = level.SPD_PRK;
				structs[ structs.size ] = struct;
				
			}
		}

		vending_weapon_upgrade_trigger = GetEntArray( "zombie_vending_upgrade", "targetname" );
		for( i = 0; i < vending_weapon_upgrade_trigger.size; i ++ )
		{
			struct = SpawnStruct();
			struct.location = vending_weapon_upgrade_trigger[i] get_waypoint_origin( "packapunch" );
			struct.origin = struct.location[ "origin" ];
			struct.angles = struct.location[ "angles" ];
			struct.check_perk = false;
			struct.perk_to_check = "specialty_weapupgrade";
			struct.is_revive = false;
			struct.is_chest = false;
			struct.chest_to_check = undefined;
			struct.fx_var = "vulture_glow";
			struct.ent_num = vending_weapon_upgrade_trigger[i] GetEntityNumber();
			struct.script_model = Spawn( "script_model", struct.origin );
			struct.waypoint_name = "specialty_glow_pap";
			struct.player_waypoint = [];
			struct.wp_type = "PAP";
			structs[ structs.size ] = struct;
		}

			//For multiple PAP locations, do a little more work
			pap_locations = getstructarray("pap_location","targetname");
			if( IsDefined( level.pap_locations ) )
				pap_locations = array_combine( pap_locations, level.pap_locations );
			if( IsDefined(pap_locations) && pap_locations.size > 0 )
			{
				structs[ structs.size - 1].using_pap_locations = true;	//Default PaP vending will not be valid waypoint
				for( i = 0; i < pap_locations.size; i++ )
				{
					struct = SpawnStruct();
					struct.location = pap_locations[i] get_waypoint_origin( "pap_location" );
					struct.origin = struct.location[ "origin" ];
					struct.angles = struct.location[ "angles" ];
					struct.original_struct = pap_locations[i];
					struct.check_perk = false;
					struct.perk_to_check = "specialty_weapupgrade_location";
					struct.is_revive = false;
					struct.is_chest = false;
					struct.chest_to_check = undefined;
					struct.fx_var = "vulture_glow";
					struct.ent_num = 0;	//not an entity
					struct.script_model = Spawn( "script_model", struct.origin );
					struct.waypoint_name = "specialty_glow_pap";
					struct.player_waypoint = [];
					struct.wp_type = "PAP_LOC";
					structs[ structs.size ] = struct;
				}
			}

		chests = GetEntArray( "treasure_chest_use", "targetname" );
		for( i = 0; i < chests.size; i ++ )
		{
			struct = SpawnStruct();
			struct.location = chests[i] get_waypoint_origin( "mysterybox" );
			struct.origin = struct.location[ "origin" ];
			struct.angles = struct.location[ "angles" ];
			struct.check_perk = false;
			struct.perk_to_check = undefined;
			struct.is_revive = false;
			struct.is_chest = true;
			struct.chest_to_check = chests[i];
			struct.fx_var = "vulture_perk_mystery_box_glow";
			struct.ent_num = chests[i] GetEntityNumber();
			struct.script_model = Spawn( "script_model", struct.origin );
			struct.waypoint_name = "specialty_glow_magic_box";
			struct.player_waypoint = [];

			structs[ structs.size ] = struct;
		}


		level.vulture_waypoint_structs = structs;
		level thread vulture_perk_watch_perks_move();
		//iprintln( "Waypoints strucuts: " + level.vulture_waypoint_structs.size );
		while(1)
		{
			players = get_players();
			if( level.vulture_waypoint_structs_update ) 
			{
				structs = vulture_update_waypoint_structs();
				level.vulture_waypoint_structs_update = false;
			}

			for( p = 0; p < players.size; p ++ )
			{
				player = players[p];
				num = player GetEntityNumber();
				
				
				for( i = 0; i < structs.size; i ++ )	
				{
					struct = level.vulture_waypoint_structs[i];
					if( isDefined( struct.chest_to_check )  )	//box is handled seperately		
						continue;

					//iprintln( "Origin for struct perk: " + struct.perk + " is " + struct.script_model.origin);
					//Main Loop
					is_visible = player HasPerk( level.VLT_PRK ) && check_waypoint_visible( player, struct );

					if( is_visible )
					{
						if( isDefined( struct.player_waypoint[ num ] ) )
							continue;

						struct.player_waypoint[ num ] = create_individual_waypoint( player, struct );
						//create_loop_fx_to_player( player, struct.ent_num, struct.fx_var, struct.origin, struct.angles );
					}
					else if( isDefined( struct.player_waypoint[ num ] ) )
					{
						destroy_individual_waypoint( struct.player_waypoint[ num ], is_visible );
						//destroy_loop_fx_to_player( player, struct.ent_num, true );		
					}

				}
				//End Structs FOR

				//Add waypoints to boss or special zombies
				if( player HasPerk( level.VLT_PRK ) )
				{
					zombies = GetAiSpeciesArray( "axis", "all" );
					special_zombies = [];
					standard_zombies = [];
					for( i = 0; i < zombies.size; i++ )
					{
						zombie = zombies[i];
						if( !isDefined( zombie ) )
							continue;
						else if( is_boss_zombie( zombie.animname ) || is_special_zombie( zombie.animname ) )
							special_zombies[ special_zombies.size ] = zombie;
						else if ( is_in_array( level.ARRAY_VALID_STANDARD_ZOMBIES, zombie.animname ) )
							standard_zombies[ standard_zombies.size ] = zombie;
					
					}

					player player_vulture_zombie_boss_waypoints( special_zombies );

					player player_vulture_zombie_normal_fx( standard_zombies );

				}

				/* Waypoints for powerup drops */
				for( i = 0; i < level.vulture_track_current_powerups.size; i++ )
				{
					powerup = level.vulture_track_current_powerups[i];
					
					is_visible = player HasPerk( level.VLT_PRK ) && check_waypoint_visible( player, powerup );
					if( !IsDefined( powerup.player_waypoints ) )
						powerup.player_waypoints = [];

					if( is_visible )
					{
						if( isDefined( powerup.player_waypoints[ num ] ) )
							continue;

						powerup.player_waypoints[ num ] = create_individual_waypoint( player, powerup );
					}
					else if ( isDefined( powerup.player_waypoints[ num ] ) )
					{
						destroy_individual_waypoint( powerup.player_waypoints[ num ], is_visible );
					}
				}

			} //End Players FOR
			wait(0.1);
			//wait 2;
		}
		//END WHILE

	}

	// */

		/* 
		Handle boss/special zombies waypoints
		// */

		player_vulture_zombie_boss_waypoints( specials )
		{
			for( i = 0; i < specials.size; i++ )
			{
				zombie = specials[i];
				if( !isDefined( zombie )  || IsDefined( zombie.vulture_waypoint ) )
					continue;

				self thread handle_player_vulture_zombie_boss_waypoint( zombie );
			
			}
		}
		

			//Self is player, individual zombie waypoint handler
			handle_player_vulture_zombie_boss_waypoint( zombie )
			{
				//create a waypoint for the zombie
				keep_waypoint = self HasPerk( level.VLT_PRK ) && check_waypoint_visible( self, zombie );
				if( !keep_waypoint )
					return;

				wp = NewClientHudElem( self );
				icon = "specialty_glow_skull";
				//icon = "specialty_instakill_zombies";
				
				model = Spawn( "script_model", zombie GetTagOrigin( "j_SpineLower") );
				model linkto( zombie, "j_SpineLower" ); //, ( 0, 0, 15 ) );

				wp SetTargetEnt( model );
				wp.hidewheninmenu = true;
				wp.alpha = 0.5;
				wp setWaypoint( true, icon);
				wp.color = ( 1, 0, 0); //red for boss zombies
				zombie.vulture_waypoint = wp;
				
				
				while( keep_waypoint )
				{
					keep_waypoint = self HasPerk( level.VLT_PRK ) && check_waypoint_visible( self, zombie );
					wait 0.1;
				}

				zombie.vulture_waypoint Destroy();
				model Delete();
			}


		player_vulture_zombie_normal_fx( zombies )
		{
			if( zombies.size > 3 || level.zombie_total > 24 ) //only on last horde
				return;

			for( i = 0; i < zombies.size; i++ )
			{
				zombie = zombies[i];
				if( !isDefined( zombie )  || IsDefined( zombie.vulture_waypoint ) )
					continue;

				self thread handle_player_vulture_zombie_fx( zombie );
			
			}
		}
			
		
		handle_player_vulture_zombie_fx( zombie )
		{

			//create a waypoint for the zombie
			keep_waypoint = self HasPerk( level.VLT_PRK ) && check_waypoint_visible( self, zombie );
			if( !keep_waypoint )
				return;

			fx = "vulture_skull";
			zombie.vulture_waypoint = zombie GetEntityNumber();
			//PlayFXOnTag( level._effect[ "vulture_skull" ], zombie, "j_SpineLower" );
			//PlayFxOnTag( level._effect[ "vulture_skull" ], model, "tag_origin" );

			while( keep_waypoint )
			{
				create_loop_fx_to_player( self, zombie GetEntityNumber(), "vulture_skull", zombie GetTagOrigin( "j_SpineLower" ) , zombie.angles );
				
				wait 0.1;

				destroy_loop_fx_to_player( self, zombie GetEntityNumber(), true );

				keep_waypoint = self HasPerk( level.VLT_PRK ) 
					&& check_waypoint_visible( self, zombie )
					&& level.zombie_total <= 3;
			}

			zombie.vulture_waypoint = undefined;
		}

		// */

/* Handle zombie powerup drop waypoints */

		vulture_watch_powerup_waypoints()
		{
			while(1)
			{

				/*
				powerup_notif = level waittill_any_return( "powerup_dropped" );
				
				//all_powerups = GetEntArray( "powerup", "classname" );
				all_powerups = GetEntArray( "script_model", "classname" );
				
				index = -1;
				for( i = 0; i < all_powerups.size; i++ )
				{
					model = all_powerups[i];
					if( IsDefined( model.powerup_name ) && model.powerup_name == powerup_notif.powerup_name )
					{
						//Check existing vulture powerups to cross check against duplicates, use GetEntitNumber() to check
						entity_exists = false;
						for( j = 0; j < level.vulture_track_current_powerups.size; j++ )
						{
							if( level.vulture_track_current_powerups[j].original_entity_number == model GetEntityNumber() )
							{
								entity_exists = true;
								break;
							}
						}

						if( entity_exists )
						{
							continue;
						}
						else
						{
							index = i;
							break;
						}

					}
				}

				if( index == -1 )
					continue;	
				
				powerup = SpawnStruct();
				powerup.origin 					= all_powerups[index].origin;
				powerup.original_entity_number 	= all_powerups[index] GetEntityNumber();
				powerup.name 					= all_powerups[index].powerup_name;

				powerup.script_model = Spawn( "script_model", powerup.origin );
				powerup.script_model linkto( powerup, "tag_origin", (0, 0, 10) );
				powerup.waypoint_name = "specialty_instakill_zombies";
				powerup.is_active_powerup = true;
				*/

				//Repeat above with powerupDrop
				level waittill("powerup_dropped", powerupDrop);

				if( !IsDefined( powerupDrop ) )
					continue;

				isFreePerkDrop = IsDefined(powerupDrop.powerup_name) && (powerupDrop.powerup_name == "free_perk");
				if( isFreePerkDrop )
					continue;

				powerup = SpawnStruct();
				powerup.origin 					= powerupDrop.origin;
				powerup.original_entity_number 	= powerupDrop GetEntityNumber();
				powerup.name 					= powerupDrop.powerup_name;

				powerup.script_model = Spawn( "script_model", powerup.origin );
				powerup.script_model linkto( powerupDrop, "tag_origin", (0, 0, 10) );
				powerup.waypoint_name = "specialty_instakill_zombies";
				powerup.is_active_powerup = true;
				powerup.powerup = powerupDrop;

				size = level.vulture_track_current_powerups.size;
				level.vulture_track_current_powerups[ size ] = powerup;
				//all_powerups[index] thread vulture_watch_powerup_expiration( size );
				powerupDrop thread vulture_watch_powerup_expiration( size );
			}
			
		}

		
		vulture_watch_powerup_expiration( index )
		{
			//level endon( "vulture_powerup_reshuffle" ); 

			self waittill_any( "powerup_timedout", "powerup_grabbed", "hacked" );

			level.vulture_track_current_powerups[ index ].is_active_powerup = false;
			level.vulture_track_current_powerups[ index ].script_model Delete();
			//level thread vulture_powerup_reshuffle( index );
			//level notify( "vulture_powerup_reshuffle" );
		}

		vulture_powerup_reshuffle( index )
		{
			for( i = 0; i < level.vulture_track_current_powerups.size; i++ ) 
			{
				if( i <= index )
					continue;
				level.vulture_track_current_powerups[i-1] = level.vulture_track_current_powerups[i];
				level.vulture_track_current_powerups[i-1] vulture_watch_powerup_expiration( i-1 );
			}
		}


		destroy_individual_waypoint( wp, is_visible )
		{		
			if( !IsDefined( wp ) )
				return;

			wp Destroy();
		}


		//Reimagined-Expanded - currently not used 
		/*
		convertPerkToGlow( perk )
		{
			struct = SpawnStruct();
			if (perk == "specialty_armorvest") {
				struct.glow = "specialty_glow_jugg";
				struct.color = ( 1, .7, .1 );
			} 
			if (perk == "specialty_quickrevive")
				return "specialty_quickrevive_zombies";
			if (perk == "specialty_fastreload")
				return "specialty_glow_speed";
			if (perk == "specialty_rof")
				return "specialty_doubletap_zombies";
			if (perk == "specialty_endurance")
				return "specialty_marathon_zombies";
			if (perk == "specialty_flakjacket")
				return "specialty_divetonuke_zombies";
			if (perk == "specialty_deadshot")
				return "specialty_deadshot_zombies";
			if (perk == "specialty_additionalprimaryweapon")
				return "specialty_mulekick_zombies";
			if (perk == "specialty_bulletdamaged")
				return "specialty_cherry_zombies";
			if (perk == "specialty_altmelee")
				return "specialty_vulture_zombies";
			if (perk == "specialty_bulletaccuracy")
				return "specialty_widowswine_zombies";
			
		return struct;
		}
		*/


		//Self is player with vulture
		//create_waypoint
		create_individual_waypoint( player, struct )
		{
	
			if( !IsDefined( struct.script_model ) )
				return;

			//iprintln( "Script model target ent: " + struct.script_model GetEntityNumber() );
			//iprintln( "Perk: " + struct.perk );
			
			wp = NewClientHudElem( player );
			//Uses pro perk shader
			icon = struct.waypoint_name;
			wp SetTargetEnt( struct.script_model );
			//wp.alpha = level.VALUE_VULTURE_HUD_ALPHA_VERY_FAR;
			wp.hidewheninmenu = true;
			
			if( is_true(struct.is_active_powerup) )
				wp.alpha = 1;
			else 
				wp.alpha = .5;

			wp setWaypoint( true, icon);

			return wp;
		}

			//Utility
			create_loop_fx_to_player( player, identifier, fx_var, origin, angles )
			{
				//iprintln( "Create Loop FX to player" );
				//iprintln( "Player: " + player GetEntityNumber() );
				str_origin = string( origin[0] ) + "|" + string( origin[1] ) + "|" + string( origin[2] );
				str_angles = string( angles[0] ) + "|" + string( angles[1] ) + "|" + string( angles[2] );
				str_clientstate = "fx|looping|start|" + identifier + "|" + fx_var + "|" + str_origin + "|" + str_angles;
				player send_message_to_csc( "client_side_fx", str_clientstate );
			}

			destroy_loop_fx_to_player( player, identifier, delete_fx_immediately )
			{
				str_delete_fx_immediately = bool_to_string( delete_fx_immediately );
				str_clientstate = "fx|looping|stop|" + identifier + "|" + str_delete_fx_immediately;
				player send_message_to_csc( "client_side_fx", str_clientstate );
			}

			

	//Stop condensing my methods

	setup_perk_machine_fx()
	{
		register_perk_machine_fx( "specialty_armorvest", "vulture_perk_machine_glow_juggernog" );
		register_perk_machine_fx( "specialty_fastreload", "vulture_perk_machine_glow_speed" );
		register_perk_machine_fx( "specialty_rof", "vulture_perk_machine_glow_doubletap" );
		register_perk_machine_fx( "specialty_quickrevive", "vulture_perk_machine_glow_revive" );
		register_perk_machine_fx( "specialty_flakjacket", "vulture_perk_machine_glow_phd_flopper" );
		register_perk_machine_fx( "specialty_endurance", "vulture_perk_machine_glow_marathon" );
		register_perk_machine_fx( "specialty_deadshot", "vulture_perk_machine_glow_deadshot" );
		register_perk_machine_fx( "specialty_additionalprimaryweapon", "vulture_perk_machine_glow_mule_kick" );
		//register_perk_machine_fx( "specialty_extraammo", "vulture_perk_machine_glow_whos_who" );
		register_perk_machine_fx( "specialty_bulletdamage", "vulture_perk_machine_glow_electric_cherry" );
		register_perk_machine_fx( "specialty_altmelee", "vulture_perk_machine_glow_vulture" );
		register_perk_machine_fx( "specialty_bulletaccuracy", "vulture_perk_machine_glow_widows_wine" );
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

			case "pap_location":
				origin = get_origin_from_pap_location( self );
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
			origin = trigger.chest_box.origin + vector_scale( forward, level.VALUE_VULTURE_MACHINE_ORIGIN_OFFSET );
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
			angles = ( 0, 0, 0 );

			if( !IsDefined( machine ) )
				return undefined;
				
			if( !IsDefined( machine.angles ) )
				machine.angles = angles;

			forward = AnglesToForward( angles - ( 0, 90, 0 ) );
			origin = machine.origin;
			
			return origin + ( 0, 0, 50 );
		}

		check_map_specific_perk_movements( perk , origin )
		{
			if( !IsDefined( perk ) )
				return false;


			switch ( level.mapname )
			{
				case "zombie_moon":
					if( is_in_array( level.ARRAY_MOON_VALID_NML_PERKS, perk) )
					{
						if( perk != level.nml_perk )
							return false;
					}
					
				break;

				default:
					return true;
			}

			return true;
		}

		get_pack_a_punch_origin( trigger )
		{
			//iprintln( "PAP Origin: ");
			machine = GetEnt( trigger.target, "targetname" );
			forward = AnglesToForward( machine.angles - ( 0, 90, 0 ) );
			origin = machine.origin + vector_scale( forward, level.VALUE_VULTURE_MACHINE_ORIGIN_OFFSET );
			return origin + ( 0, 0, 40 );
		}

		get_origin_from_pap_location( location )
		{
			
			forward = AnglesToForward( location.angles );
			origin = location.origin; //+ vector_scale( forward, level.VALUE_VULTURE_MACHINE_ORIGIN_OFFSET );
			adj = ( 0, 0, 0 );
			switch( level.mapname )
			{
				case "zombie_cod5_sumpf":
					adj = ( 0, 0, 20 );
				break;
				case "zombie_coast":
					adj = ( 0, 0, -20 );
				break;
			}

			return origin + adj;
		}

	//Check Waypoint visibuity

	//tags: isVisible,
	check_waypoint_visible( player, struct )
	{	
		if( !player.vulture_vison_toggle )
		{
			is_weapon = is_true( struct.is_weapon );
			is_chest = is_true( struct.is_chest );
			is_perk = IsDefined( struct.perk_to_check );
			is_active_powerup = is_true( struct.is_active_powerup );
			is_zombie = IsDefined( struct.animname );

			//Turn off vision for chest, weapon, perks if vision toggled
			if( is_weapon || is_chest || is_perk )
				return false;

		}
			
		if( !IsDefined( player ) || !IsDefined( struct ) )
			return false;

		if( !IsDefined( player.origin ) || !IsDefined( struct.origin ) )
			return false;


		/* CHECK DISTANCE CUTOFFS */

		is_visible = false;
		if( is_true( struct.is_weapon ) )		//WEAPON
		{
			if( checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_MED ) )
				is_visible = true;
		} 
		else if( is_true( struct.is_chest ) )	//BOX
		{
			if( IsDefined( struct.chest_to_check ) )
				return is_true( struct.chest_to_check.vulture_waypoint_visible );	
				//let box be visible despite distance
		} 
		else if( isDefined(struct.perk_to_check) )
		{
			//iprintln( "Vis 0: " + struct.perk_to_check  );

			//iprintln( "Vis 1: " + struct.perk_to_check + "  " + is_visible );
			/* Determine if Perk or PAP is in Playable Area */

			//inPlayableArea = checkObjectInPlayableArea( struct.script_model );
			//if( !inPlayableArea )
				//return false;
			

			/* Determine if PAP is at this spot */
			if( struct.perk_to_check == "specialty_weapupgrade_location" )
			{
				//iprintln( "Vis 1.1: " + struct.perk_to_check + "  " + is_visible );

				if( level.pap_moving )
					return false;
				
				//iprintln( "Vis 1.2: " + struct.perk_to_check + "  " + is_visible );
				if( !IsDefined( level.vulture_track_current_pap_spot ))
					return false;

				//iprintln( "Vis 1.3: " + struct.perk_to_check + "  " + is_visible );
				in_range = checkDist( struct.original_struct.origin, level.vulture_track_current_pap_spot, 100 );
				if( !in_range )
					return false;		

				//iprintln( "Vis 1.4: " + struct.perk_to_check + "  " + is_visible );

			}
			else if( struct.perk_to_check == "specialty_weapupgrade" )
			{
				if( is_true( struct.using_pap_locations ))
					return false;
			}

			/* ##############				############## */
			
			if( IsDefined( struct.perk ) )
				is_visible = check_map_specific_perk_movements( struct.perk, struct.origin );
			else
				is_visible = true;

			//iprintln( "Vis 2: " + struct.perk_to_check + "  " + is_visible );
			//wait( 0.5 );
			//Only show perks within VERY_FAR range and IF player is looking in their direction
			if( checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_CUTOFF_VERY_FAR ) )
			{
				is_visible = checkPlayerLookingAtObject( player, struct, level.THRESHOLD_VULTURE_FOV_HUD_DOT ) && is_visible;
			}
			//iprintln( "Vis 3: " + struct.perk + "  " + is_visible );

		} 
		else if( IsDefined( struct.animname ) )	//struct could be a zombie
		{
			//Check for bosses/zombies who are no longer with us
			if( !IsAlive( struct ) || ( IsDefined(self.health) && self.health <= 0 ) )
				return false;

			inPlayableArea = checkObjectInPlayableArea( struct );
			if( !inPlayableArea )
				return false;

			//Fix for thief zombie showing after dead
			if( IsDefined( struct.state ) && struct.state == "exiting" )
				return false;

			cutoffClose = checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_CUTOFF );
			
			if( struct.animname == "monkey" || struct.animname == "monkey_zombie"  )
			{
				cutoffFar = !checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_FAR );

				return !cutoffFar;
			}
				
			looking_at = checkPlayerLookingAtObject( player, struct, level.THRESHOLD_VULTURE_FOV_HUD_DOT );

			if( !cutoffClose && looking_at )
				return true;
				
			return false;
		} 
		else if( is_true( struct.is_active_powerup ) )
		{
			
			inPlayableArea = checkObjectInPlayableArea( struct );
			if( !inPlayableArea )
				return false;

			cutoffClose = checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_CUTOFF );

			if( cutoffClose )
				return false;

			return true;
		}

		
			
		cutoffClose = checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_CUTOFF );
		cutoffFar = !checkDist( player.origin, struct.origin, level.VALUE_VULTURE_HUD_DIST_CUTOFF_VERY_FAR );

		//iprintln("Returning before cutoff: " + struct.perk + "  " + is_visible);

		if( cutoffClose || cutoffFar )
			return false;
		
		//iprintln("Returning is_visible: " + struct.ent_num + "  " + is_visible);
		return is_visible;
	}

	//Utility Function to determine if player is towards object
	checkPlayerLookingAtObject( player, object, fov_threshold )
	{
		return object object_in_player_fov( player, fov_threshold );
		
	}


//HERE_
vulture_perk_watch_pap_move()
{
	
	while( 1 ) 
	{
		while( !IsDefined( level.pap_moving) ||  !level.pap_moving ) { //Pap is either still or not available
			wait 0.5;
		}

		while( is_true( level.pap_moving ) ) {
			wait 0.5;
		}
		
		machine = undefined;
		vending_weapon_upgrade_trigger = GetEntArray("zombie_vending_upgrade", "targetname");
		for(i=0; i<vending_weapon_upgrade_trigger.size; i++ )
		{
			perk = getent(vending_weapon_upgrade_trigger[i].target, "targetname");
			
			if(isDefined(perk) && isDefined(perk.origin) )
			{
				level.vulture_track_current_pap_spot = perk.origin;
			}
			else
			{
				
				machine_array = vending_weapon_upgrade_trigger;
				for( j = 0; j < machine_array.size; j ++ )
				{
					if( IsDefined( machine_array[j].script_noteworthy ) && machine_array[j].script_noteworthy == "clip" )
						continue;
					machine = machine_array[j];
				}
				level.vulture_track_current_pap_spot = machine.origin;
			
			}
		}
		
		//iprintln( "new pap: " );
		//iprintln( level.vulture_track_current_pap_spot );
	}
}

vulture_perk_watch_perks_move()
{

	//HERE
	while(1) 
	{
		event = level waittill_any_return( "zombie_vending_off", "zombie_vending_spawned", "perks_swapping" );
		structs = vulture_update_waypoint_structs();

		vending_triggers = GetEntArray( "zombie_vending", "targetname" );
		
		for( i = 0; i < vending_triggers.size; i ++ )
		{
			perk = vending_triggers[i].script_noteworthy;

			//Search through existing structs and match on perk
			for( j = 0; j < structs.size; j++ )
			{
				if( structs[j].wp_type != "PERK" )
					continue;

				if( structs[j].perk == perk )
				{
					structs[j].location = vending_triggers[i] get_waypoint_origin( "perk" );
					structs[j].origin = structs[j].location[ "origin" ];
					structs[j].angles = structs[j].location[ "angles" ];

					if( event == "perks_swapping" )
					{
						structs[j].origin = (0, 0, -9999);
						structs[j].angles = (0, 0, 0);
					}
				
					break;
				}

			}
		}
		
		vulture_update_waypoint_structs( structs );
	}
}

	vulture_update_waypoint_structs( new_vulture_structs )
	{
		if( isDefined( new_vulture_structs ) )
		{
			for( i = 0; i < level.vulture_waypoint_structs.size; i++ )
			{
				for( j = 0; j < new_vulture_structs.size; j++ )
				{
				
					if( level.vulture_waypoint_structs[i].wp_type != "PERK" )
						continue;

					existing_entnum = level.vulture_waypoint_structs[i].script_model GetEntityNumber();
					new_entnum = new_vulture_structs[j].script_model GetEntityNumber();

					if( existing_entnum != new_entnum )
						continue;

					level.vulture_waypoint_structs[i].origin = new_vulture_structs[i].origin;
					level.vulture_waypoint_structs[i].script_model Delete();
					level.vulture_waypoint_structs[i].script_model = Spawn( "script_model", new_vulture_structs[i].origin );
				
				}
			}
			
			
			
			level.vulture_waypoint_structs_update = true;
		}
			
		return level.vulture_waypoint_structs;
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

/* Vulture Perk - Drop bonuses */
//tags: ammo_drop, vultureAmmoDrop, vulture_zombie_ammo
zombie_watch_vulture_drop_bonus()
{
	self waittill("death");

	rand = randomint(1000);	//Normalized to 1000, don't want to to deal with decimals

	scaler = count_total_vulture_players();
	ammo_rate = Int( ( level.VALUE_VULTURE_BONUS_AMMO_SPAWN_CHANCE * scaler ) );

	if( flag( "enter_nml" ) )
	{
		ammo_rate = 0;
	}
	//blue_rate = Int( ( level.VALUE_ZOMBIE_DROP_RATE_BLUE / total ) * 1000);
	//red_rate = Int( ( level.VALUE_ZOMBIE_DROP_RATE_RED / total ) * 1000);

	//Apocalypse or extra drops
	//iprintln("rand: " + rand + " ammo_rate: " + ammo_rate);
	if( rand < ammo_rate )
		level thread zombie_vulture_handle_drop( "bo2_p6_zm_perk_vulture_ammo", self.origin );

}

//Zombie vulture drop helper methods

	count_total_vulture_players()
	{
		total = 0;
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] HasPerk( level.VLT_PRK ) )
				total++;
		}

		return total;
	}

	zombie_vulture_handle_drop( str_drop, origin )
	{
		delay = randomint( level.VALUE_VULTURE_BONUS_DROP_DELAY_TIME );

		wait(delay);

		drop = Spawn( "script_model", origin + (0,0,40) );
		drop SetModel( str_drop );

		playable_area = getentarray("player_volume","script_noteworthy");
		valid_drop = false;
		for (i = 0; i < playable_area.size; i++)
		{
			if (drop IsTouching(playable_area[i])) {
				valid_drop = true;
				break;
			}
		}
			
		if(!valid_drop)
		{
			drop Delete();
			return;
		}

		drop Show();
		level.count_vulture_fx_drops_round++;
		players = get_players();
		for( i = 0; i < players.size; i++ ) 
		{
			if( players[i] HasPerk( level.VLT_PRK ) ) 
			{
				drop SetInvisibleToPlayer( players[i], false );
				drop thread watch_player_vulture_drop_pickup( players[i] );
			}
			else
				drop SetInvisibleToPlayer( players[i], true );
		}
		
		drop waittill_any_or_timeout( level.VALUE_VULTURE_BONUS_DROP_TIME, "powerup_grabbed");
		drop notify( "vulture_drop_done" );

		wait( 1 );	//wait for players to cleanup fx, may need to be longer
		drop Delete();

	}
	
/* Handle Drops */

		//Self is drop
		watch_player_vulture_drop_pickup( player )
		{
			create_loop_fx_to_player( player, self GetEntityNumber(), "vulture_perk_bonus_drop", self.origin, self.angles );
			self vulture_drop_pickup( player );
			destroy_loop_fx_to_player( player, self GetEntityNumber(), true );
			self SetInvisibleToPlayer( player, true );
		}

		//Self is drop
		vulture_drop_pickup( player )
		{
			self endon( "vulture_drop_done" );
			
			while( player HasPerk( level.VLT_PRK ) ) 
			{
				threshold = level.THRESHOLD_VULTURE_BONUS_AMMO_PICKUP_RANGE;
				did_pickup = checkDist( player.origin, self.origin, threshold );
				if( did_pickup ) 
				{
					playfx( level._effect["powerup_grabbed_solo"], self.origin );
					//playfx( level._effect["powerup_grabbed_wave_solo"], self.origin );
					player thread vulture_drop_ammo_bonus();
					self notify( "powerup_grabbed" );
					return;
				}
				wait( 0.1 );
			}

		}

		vulture_drop_ammo_bonus()
		{
			str_weapon_current = self GetCurrentWeapon();
			otherWeps = self GetWeaponsListPrimaries();
			validAmmoWeapon = is_valid_ammo_bonus_weapon( str_weapon_current );
			index = 0;
			
			if( !IsDefined( otherWeps ) || otherWeps.size == 0 )
				return;

			while( !validAmmoWeapon && index < otherWeps.size )
			{
				str_weapon_current = otherWeps[index];

				if( is_valid_ammo_bonus_weapon( str_weapon_current ) ) 
				{
					currentAmmo = self GetWeaponAmmoStock( str_weapon_current );
					maxWepAmmo = WeaponMaxAmmo( str_weapon_current );

					if( currentAmmo < maxWepAmmo )
					{
						validAmmoWeapon = true;
						break;
					}

				}
				
				index++;
				
			}

			if( str_weapon_current != "none" )
			{
				if( validAmmoWeapon )
				{
					/*
					n_ammo_count_current = self GetWeaponAmmoStock( str_weapon_current );
					n_ammo_count_max = WeaponMaxAmmo( str_weapon_current );
					ammo_fraction = RandomFloatRange( 0, level.VALUE_VULTURE_BONUS_AMMO_CLIP_FRACTION );
					n_ammo_refunded = clamp( Int( n_ammo_count_max * ammo_fraction ), 1, n_ammo_count_max );

	
					if( n_ammo_refunded < level.VALUE_VULTURE_MIN_AMMO_BONUS )
						n_ammo_refunded = level.VALUE_VULTURE_MIN_AMMO_BONUS;
					else if( n_ammo_refunded > level.VALUE_VULTURE_MAX_AMMO_BONUS )
						n_ammo_refunded = level.VALUE_VULTURE_MAX_AMMO_BONUS;
					*/

					n_ammo_refunded = RandomintRange( level.VALUE_VULTURE_MIN_AMMO_BONUS, level.VALUE_VULTURE_MAX_AMMO_BONUS );

					//If weapon class is spread, give small portion of ammo
					if( WeaponClass(str_weapon_current) == "spread" 
						|| is_in_array(level.ARRAY_VALID_SNIPERS, str_weapon_current) )
					{
						n_ammo_refunded = RandomIntRange( 1, level.VALUE_VULTURE_MIN_AMMO_BONUS );
					}

					//if Weapon class is pistol, take half of the ammo
					//if weapon is in array: level.ARRAY_SIDEARMBONUS_WEAPONS
					if( WeaponClass(str_weapon_current) == "pistol" 
						|| is_in_array(level.ARRAY_SIDEARMBONUS_WEAPONS, str_weapon_current) )
					{
						n_ammo_refunded = int( n_ammo_refunded / 2 );
					}


					if( self hasProPerk( level.VLT_PRO ) )
						n_ammo_refunded = int( level.VALUE_VULTURE_PRO_SCALE_AMMO_BONUS * n_ammo_refunded );

					n_ammo_count_current = self GetWeaponAmmoStock( str_weapon_current );
					n_ammo_count_max = WeaponMaxAmmo( str_weapon_current );

					stock_ammo = n_ammo_count_current + n_ammo_refunded;

					//iprintln( "Current Ammo: " + n_ammo_count_current + "  New Stock: " + stock_ammo );
					if( stock_ammo > n_ammo_count_max )
						stock_ammo = n_ammo_count_max;
					
					self SetWeaponAmmoStock( str_weapon_current, stock_ammo );
				}
					self PlaySoundToPlayer( "zmb_vulture_drop_pickup_ammo", self );

					//self PlaySound( "zmb_vulture_drop_pickup_money" );
					//self PlaySound( "zmb_vulture_drop_pickup_ammo" );
					//self PlaySound( "vulture_pickup" );
					//self PlaySound( "vulture_money" );
			}
		}

		is_valid_ammo_bonus_weapon( weapon )
		{
			//iprintln( "Checking is valid bonus ammo: "  );
			//iprintln( "Weapon: " + weapon );
			if( !isDefined( weapon ) || weapon == "none" )
				return false;

			if( is_in_array( level.ARRAY_VULTURE_INVALID_AMMO_WEAPONS, weapon ) )
				return false;
			
			return true;
		}

// /


//=========================================================================================================
// Widows Wine
//=========================================================================================================


/*	 Init and Entry Methods	 */

init_widows_wine()
{
	level._effect[ "fx_acidgat_explode" ] = LoadFX( "acidgat/fx_acidgat_explode" );
	//level._effect[ "fx_acidgat_explode_ug" ] = LoadFX( "acidgat/fx_acidgat_explode_ug" );
	//level._effect[ "fx_acidgat_marker" ] = LoadFX( "acidgat/fx_acidgat_marker" );
	//level._effect[ "fx_acidgat_view" ] = LoadFX( "acidgat/fx_acidgat_view" );
	//level._effect[ "fx_acidgat_zombiesplash" ] = LoadFX( "acidgat/fx_acidgat_zombiesplash" );

	level._effect[ "fx_widows_wine_explode" ] = LoadFX( "widowswine/fx_widows_wine_explode" );
	level._effect[ "fx_widows_wine_zombie" ] = LoadFX( "widowswine/fx_widows_wine_zombie" );
	level._effect["fx_trail_crossbow_blink_red_os"]	  = loadfx("weapon/crossbow/fx_trail_crossbow_blink_red_os");
}

player_watch_widowswine()
{
	self thread player_give_wine_grenades( level.WWN_PRK + "_stop" );
	self thread player_watch_widows_warning();
}

watch_widowswine_upgrade( stop_str )
{
	//iprintln("watch_widowswine_upgrade");
	self thread player_give_wine_grenades( stop_str );
	self waittill( stop_str );
}

player_give_wine_grenades( stop_str )
{
	//Check if player has any other tactical grenades
	if( IsDefined( self get_player_tactical_grenade() )  )
		return;
	
	self giveweapon( "bo3_zm_widows_grenade" );
	self set_player_tactical_grenade( "bo3_zm_widows_grenade" );
	
	self thread player_watch_widows_grenade( stop_str );

	self waittill( stop_str );

	self TakeWeapon( "bo3_zm_widows_grenade" );
	self set_player_tactical_grenade( undefined );
	
}
	
/*	 Handle Zombie close HUD  */
/*
level.THRESHOLD_WIDOWS_ZOMBIE_CLOSE_HUD_DISTANCE = 128;

*/

player_watch_widows_warning()
{
	player_num = self GetEntityNumber();

	while(1)
	{
		
		if( self HasPerk( level.WWN_PRK ) )
		{

			no_warning = self maps\_laststand::player_is_in_laststand() 
						|| self.widows_cancel_warning
						|| self IsSprinting();

			if( no_warning ) 
			{
				self notify( "widows_cancel_warning" );
				wait 0.5;
				continue;
			}
					
			threshold_dist = level.THRESHOLD_WIDOWS_ZOMBIE_CLOSE_HUD_DIST;
			zombies = get_array_of_closest( self.origin, GetAiSpeciesArray( "axis", "all" ), undefined, undefined, threshold_dist );
			count_zombs_behind = 0;
			
			for( i = 0; i < zombies.size; i++ )
			{
								
				if( !isDefined( zombies[i] ) )
					continue;

				if( !IsDefined( zombies[i].wine_triggered_player_warning ) )
					zombies[i].wine_triggered_player_warning = [];

				vertical_diff = self.origin[2] - zombies[i].origin[2];
				diff = level.THRESHOLD_WIDOWS_ZOMBIE_CLOSE_HUD_VERTICAL_CUTOFF;
				if( vertical_diff > diff || vertical_diff < diff*-1 )
					continue;

				if( is_true( zombies[i].wine_triggered_player_warning[ player_num ] ) )	{
					//iprintln("already triggered behind");
					//wait 1;
					wait( 0.01 );
					continue;
				}

				if( !( self player_widows_check_zomb_behind( zombies[i] ) ) )
					continue;


				count_zombs_behind++;
				heavy_warning = count_zombs_behind >= level.THRESHOLD_WIDOWS_COUNT_ZOMBS_HEAVY_WARNING;
				heavy_warning = false;	//disabled
				if( heavy_warning && !self.widows_heavy_warning_cooldown )
				{ 
					//iprintln("count zombs behind");
					self thread player_widows_cancel_warning_on_turn();
					self thread player_widows_create_heavy_warning();
					//count_zombs_behind -= -3;
					self thread player_widows_heavy_warning_cooldown();
					wait( 0.01 );
					continue;
				}			
				
				zombies[i].wine_triggered_player_warning[ player_num ] = true;
				self thread player_widows_cancel_warning_on_turn();
				//iprintln("Trigger new warning");
				self thread player_widows_create_warning( zombies[i] );
				zombies[i] thread zombie_widows_delay_repeat_warning( player_num );

				//wait 1;
				wait( 0.01 );
			}
		}
		else
		{
			break;
		}
	
		wait(0.5);
	}
}

//Utilit and implementation methods
//line

	player_widows_heavy_warning_cooldown()
	{
		self.widows_heavy_warning_cooldown = true;
		wait( level.VALUE_WIDOWS_ZOMBIE_CLOSE_HUD_HEAVY_COOLDOWN );
		self.widows_heavy_warning_cooldown = false;
	}

	zombie_widows_delay_repeat_warning( player_num )
	{
		self endon( "death" );
		wait( level.VALUE_WIDOWS_ZOMBIE_CLOSE_HUD_COOLDOWN );
		self.wine_triggered_player_warning[ player_num ] = false;
	}

	player_widows_cancel_warning_on_turn()
	{
		self endon( "death" );

		forward_view_dir = AnglesToForward( self GetPlayerAngles() );
		
		initial_dir = forward_view_dir[1];
		turn_threshold = 0.2;					//Looks like they use radians

		while ( 1 )
		{
			dir = AnglesToForward( self GetPlayerAngles() );
			dot = VectorDot( forward_view_dir, dir );

			if( dot <= turn_threshold ) //anything at least 90 degrees or more returns <0
				break;
			wait( 0.01 );
		}

		self notify( "widows_cancel_warning" );
		self.widows_cancel_warning = true;
		wait( level.VALUE_WIDOWS_ZOMBIE_CLOSE_HUD_ONTURN_COOLDOWN );
		self.widows_cancel_warning = false;
	}

	player_widows_check_zomb_behind( zomb )
	{
		view_pos = self GetPlayerViewHeight();
		//origin = zomb GetCentroid();
		origin = zomb.origin + ( 0, 0, 40 );
		forward_view_angles = AnglesToForward( self GetPlayerAngles() );

		normal = VectorNormalize( origin - view_pos );
		dot = VectorDot( forward_view_angles, normal );

		return !( zomb object_in_player_fov( self, level.THRESHOLD_WIDOWS_BEHIND_HUD_DOT ) );
	}

	object_in_player_fov( player, threshold )	//threshold is between 0 and 1
	{
		playerAngles = player getplayerangles();
		playerForwardVec = AnglesToForward( playerAngles );
		playerUnitForwardVec = VectorNormalize( playerForwardVec );

		zombiePos = self.origin;
		playerPos = player GetOrigin();
		playerTozombieVec = zombiePos - playerPos;
		playerTozombieUnitVec = VectorNormalize( playerTozombieVec );

		forwardDotzombie = VectorDot( playerUnitForwardVec, playerTozombieUnitVec );
		angleFromCenter = ACos( forwardDotzombie );

		playerFOV = GetDvarFloat( #"cg_fov" );
		inPlayerFov = ( angleFromCenter <= ( playerFOV * 0.5 * ( 1 - threshold ) ) );

		return inPlayerFov;
	}

	//Create hud elem for widows
	player_widows_create_heavy_warning()
	{
		//self notify( "widows_cancel_warning" );
		level.widows_cancel_warning = true;
		wait( 0.1 );
		level.widows_cancel_warning = false;

		self playsound("chr_breathing_better");


		/* Heaving warning accross the bottom doesnt look very good */
		//self thread player_widows_create_warning( self, "left" );	
		//self thread player_widows_create_warning( self, "center" );
		//self thread player_widows_create_warning( self, "right" );

		
		//For heavy warning, large overlay,

		overlay = newClientHudElem( self );
		overlay.x = 0;
		overlay.y = 0;
		ht = 640;
		wd = 480;
		//sclale dimensions by 5%
		ht = Int( ht*1.1 );
		wd = Int( wd*1.1 );
		overlay setshader( "overlay_low_health", ht, wd );
		
		overlay.alignX = "left";
		overlay.alignY = "top";
		overlay.horzAlign = "fullscreen";
		overlay.vertAlign = "fullscreen";
		
		startAlpha = 0.6;
		endAlpha = 0.5;
		overlay.alpha = startAlpha;
		overlay.color = ( 0.5, 0, 0.9 );
		
		self player_widows_handle_warning_fade( 0.5, 0.8, startAlpha, endAlpha, overlay );
		
		overlay Destroy();
		
	}

	player_widows_create_warning( zomb, warning_dir_override )
	{

		//dir = self player_widows_calc_angle_behind_player( zomb );
		dir = "center";
		inner_radius = level.THRESHOLD_WIDOWS_ZOMBIE_CLOSE_HUD_BEHIND_DIST;

		zomb_origin = zomb.origin;
		zomb_centroid = zomb GetCentroid();
		origin = self.origin;
		view_pos = self GetPlayerViewHeight();

		if( IsDefined( warning_dir_override ))
		{
			dir = warning_dir_override;	
		}
		else if( checkDist( origin, zomb_origin, level.THRESHOLD_WIDOWS_ZOMBIE_CLOSE_HUD_BEHIND_DIST ) )
		{
			dir = "center";
		}
		else
		{
			player_angles = self GetPlayerAngles();
			right_angles = AnglesToRight( player_angles );
			left_angles = right_angles * -1;
			//iprintln("Right Angles: " + right_angles);
			//iprintln("Left Angles: " + left_angles);

			right_vector = vector_scale( right_angles, inner_radius );
			left_vector = vector_scale( left_angles, inner_radius );
			//watch_place_bottle(right_vector);
			//iprintln("Right Vector: " + right_vector);
			//iprintln("Left Vector: " + left_vector);

			left_normal = VectorNormalize( zomb_origin - left_vector );
			right_normal = VectorNormalize( zomb_origin - right_vector );
			//left_normal = VectorNormalize(  left_vector - zomb_origin);
			//right_normal = VectorNormalize( right_vector - zomb_origin);
			
			left_dot = VectorDot( left_angles, left_normal );
			right_dot = VectorDot( right_angles, right_normal );

			if( left_dot > 0 )
				dir = "left";
			else if( right_dot > 0)
				dir = "right";
			else
				dir = "center";
		}
		
		overlay = NewClientHudElem( self );
		overlay setshader( "overlay_low_health_compass", 630, 525 );

		overlay.x = 0;
		overlay.y = 0;
		
		overlay.alignX = "center";
		overlay.horzAlign = "user_center";
		offset=300;
		switch( dir )
		{
			case "left":
				overlay.x -= offset;
				break;
			case "right":
				overlay.x += offset;
				break;
			default:
				overlay.alignX = "center";
				overlay.horzAlign = "user_center";
				break;
		}
				
		overlay.alignY = "bottom";
		overlay.vertAlign = "user_bottom";

		overlay.y += 190;		//move down off screen

		overlay.alpha = 1;
		startAlpha = 1;
		endAlpha = 0.8;
		overlay.color = ( 0.4, 0, 0.9 );

		self player_widows_handle_warning_fade( 0.5, 1, startAlpha, endAlpha, overlay );

		overlay Destroy();
	}

//Widows warning heler methods

		player_widows_calc_angle_behind_player( zomb )
		{
			zomb_origin = zomb GetCentroid();
			view_pos = self GetPlayerViewHeight();
			
			angle_offset = 30;
			forward_dir = AnglesToForward( self GetPlayerAngles() );

			forward_angles = VectorToAngles( forward_dir );

			arctan = atan( forward_dir[1] / forward_dir[0] );
			//iprintln("Arctan: " + arctan);
			//iprintln("Angles: " + forward_angles);

			//left-vector, 30deg from forward
			left_angle = arcTan - angle_offset;
			//iprintln("Left Angle: " + left_angle);
			left_vector = ( cos( left_angle ), sin( left_angle ), 0 );
			//iprintln("Left Vector: ");
			//iprintln( left_vector );

			right_angle = arcTan + angle_offset;
			//iprintln("Right Angle: " + right_angle);
			right_vector = ( cos( right_angle ), sin( right_angle ), 0 );
			
			normal = VectorNormalize( zomb_origin - view_pos );

			//if zombie is "in front of" left vector, then it's to the left
			is_left = VectorDot( left_vector, normal ) > 0;
			is_right = VectorDot( right_vector, normal ) > 0;

			//iprintln("Is Left: " + is_left + "  Is Right: " + is_right);

		}

		//Utility method for helping fade time
		player_widows_handle_warning_fade( wait_time, fade_time, startAlpha, endAlpha, overlay )
		{
			//self endon( "widows_cancel_warning" );
			self endon( "death" );

			time = 0;
			while( !self.widows_cancel_warning )
			{
				time += 0.05;
				wait( 0.05 );
				if (time > wait_time)
					break;
			}

			if( self.widows_cancel_warning )
				return;

			time = 0;
			slope = (endAlpha - startAlpha) / fade_time;
			while( !self.widows_cancel_warning )
			{
				time += 0.05;
				overlay.alpha = startAlpha - slope;
				wait( 0.05 );
				if (time > fade_time)
					break;
			}

		}

//End handle HUD warnings


/*	 Handle Widows Poison damage */


player_zombie_handle_widows_poison( zombie )
{
	if( is_true( zombie.marked_for_poison ) || level.classic )
		return;
	else
		zombie.marked_for_poison = true;

	fraction = level.THRESHOLD_WIDOWS_POISON_MIN_HEALTH_FRACTION;
	MAX_TIME = level.THRESHOLD_WIDOWS_POISON_MAX_TIME;
	mod = "unknown";
	if( self hasProPerk( level.WWN_PRO ) ) {
		fraction = level.THRESHOLD_WIDOWS_PRO_POISON_MIN_HEALTH_FRACTION;
		MAX_TIME = level.THRESHOLD_WIDOWS_PRO_POISON_MAX_TIME;
		//mod = "burned";	
	}

	//min_health = fraction * zombie.maxhealth;
	min_health = 0;
	time = MAX_TIME;
	interval = 0.25;	//4 poison ticks a second
	dmg = (zombie.health - min_health) / (MAX_TIME / interval);
	dmg /= 2;	//Half the damage, a zombie can be applied with poison twice
	
	keepPoison = (zombie.health > min_health) && (time > 0);

	points_per_tick = maps\_zombiemode_score::zombie_calculate_damage_points( level.apocalypse, zombie );
	ticks_to_reach_max = level.THRESHOLD_WIDOWS_MAX_POISON_POINTS / points_per_tick;
	max_ticks = MAX_TIME / interval;

	points_count = Int( max_ticks / ticks_to_reach_max );	//Every 1/4 of the way, give points
	fx_count = 12;											//Every 3 seconds, play fx
	count = 0;

	//Play once at start
	zombie thread zombie_handle_widows_poison_fx();

	while( keepPoison )
	{
		wait( interval );
		if( (count % points_count) == 0 )
			zombie doDamage( dmg, zombie.origin, self, level.WWN_PRK, mod );
		else
			zombie doDamage( dmg, zombie.origin, undefined, level.WWN_PRK, "dot" );
		
		time -= interval;
		keepPoison = (zombie.health > min_health) && (time > 0) && IsAlive( zombie ) && zombie.marked_for_poison;

		if( (count % fx_count) == 0 )
		{
			//PlayFxOnTag( level._effect[ "fx_acidgat_explode" ], zombie, "tag_origin" );
			//PlayFxOnTag( level._effect[ "fx_widows_wine_explode" ], zombie, "tag_origin" );
			//PlayFxOnTag( level._effect[ "fx_widows_wine_zombie" ], zombie, "tag_origin" );
			//self PlayLocalSound( "mx_widows_explode" );
			//zombie thread zombie_handle_widows_poison_fx();
		}
		count++;
	}

	zombie.marked_for_poison = false;
}

//Handle widows poison fx

	
	zombie_handle_widows_poison_fx()
	{
		scale = 50;
		//forward = vector_scale( AnglesToForward( self.angles ), scale );
		model = Spawn( "script_model", self GetTagOrigin( "j_SpineLower" ) );
		model SetModel( "tag_origin" );
		model LinkTo( self );	//, "j_SpineLower" );
		
		condition = self.marked_for_poison && IsAlive( self );
		time = 0.75;	//down from 4, only play fx for 1 second
		interval = 0.25;
		PlayFxOnTag( level._effect[ "fx_acidgat_explode" ], model, "tag_origin" );
		
		//PlayFxOnTag( level._effect[ "fx_acidgat_explode" ], self, "j_SpineLower" );
		while( condition )
		{
			condition = self.marked_for_poison && IsAlive( self ) && time > 0;
			wait( interval );
			time -= interval;
		}

		model Delete();
	}
	
//Handle Widows Grenades

player_watch_widows_grenade( stop_str )
{
	self endon( "disconnect" );
	self endon( "death" );

	while( self hasProPerk( level.WWN_PRO ) || (level.classic && self HasPerk( level.WWN_PRK )) )
	{

		self waittill( "grenade_fire", grenade, weapName );
		if( weapName == "bo3_zm_widows_grenade" )
			self thread player_widows_grenade_explode( grenade );

		wait( 0.05 );
	}

}

player_widows_grenade_explode( grenade )
{
	model = Spawn( "script_model", grenade.origin );
	grenade setModel( "tag_orgin" );
	model SetModel( "bo3_t7_ww_grenade_world" );
	PlayFxOnTag( level._effect[ "widow_light" ], model, "tag_origin" );
	model linkTo( grenade );

	MAX_TIME = level.VALUE_WIDOWS_GRENADE_EXPLODE_TIME;
	MAX_RANGE = level.VALUE_WIDOWS_GRENADE_EXPLOSION_RANGE;
	MIN_RANGE = level.VALUE_WIDOWS_GRENADE_TRIGGER_RANGE;
	time = 0;

	zombies = get_array_of_closest( grenade.origin, GetAiSpeciesArray( "axis", "all" ),
								 undefined, undefined, MAX_RANGE );
	
	interval = 0.2;
	while( time < MAX_TIME )
	{
		wait( interval );
		time += interval;
		triggered = (zombies.size > 0) && checkDist( model.origin, zombies[0].origin, MIN_RANGE );
		if( triggered )
			break;

		zombies = get_array_of_closest( model.origin, GetAiSpeciesArray( "axis", "all" ),
									 undefined, undefined, MAX_RANGE );

		if( Int(time / interval) % 5 == 0)
		{
			//PlayFx( level._effect["fx_trail_crossbow_blink_red_os"], model.origin );
			//PlayFx( level._effect["fx_zombie_eye_single"], model.origin );
			PlayFxOnTag( level._effect["fx_trail_crossbow_blink_red_os"], model, "tag_origin" );
		}
	}

	PlayFxOnTag( level._effect[ "fx_widows_wine_explode" ], model, "tag_origin" );
	PlayFx( level._effect[ "fx_widows_wine_explode" ], model.origin );
	PlaySoundAtPosition( "mx_widows_explode", model.origin );
	model Delete();

	for( i = 0; i < zombies.size; i++ ) {
		zombies[i] thread zombie_watch_widows_web( self );			
	}


}


zombie_watch_widows_web( player )
{
	self endon( "death" );

	wait ( RandomFloatrange( 0, 0.5 ) );
	PlayFxOnTag( level._effect[ "fx_widows_wine_explode" ], self, "tag_origin" );
	PlaySoundAtPosition( "mx_widows_explode", self.origin );

	MAX_TIME = level.VALUE_WIDOWS_ZOMBIE_WEBBED_TIME;

	boss_zombie_or_poisoned = is_boss_zombie( self.animname ) || is_special_zombie( self.animname ) || is_true( self.marked_for_poison ) ;

	if( boss_zombie_or_poisoned )
		return;

	can_slow_zombie = is_true( self.is_zombie ) && !is_true( self.marked_for_freeze );

	//iprintln("Can Slow Zombie: " + can_slow_zombie);
	if( can_slow_zombie ) {
		wait( level.VALUE_WIDOWS_ZOMBIE_WAIT_WEBBED_TIME );
		self thread maps\_zombiemode_weapon_effects::slow_zombie_over_time( MAX_TIME, "walk" );
	}
		

	self doDamage( level.VALUE_WIDOWS_GRENADE_EXPLOSION_DAMAGE, self.origin, player, level.WWN_PRK, "MOD_GRENADE_SPLASH" );
	
	player thread player_zombie_handle_widows_poison( self );

	time = 0;
	interval = 1;

	flip_fx = 1;
	fx_spots = array( "j_SpineLower", "j_SpineUpper" );
	while( IsAlive( self ) && time < MAX_TIME )
	{
		wait( interval );
		time += interval;

		PlayFxOnTag( level._effect[ "fx_widows_wine_zombie" ], self, fx_spots[ flip_fx ] );
		flip_fx = !flip_fx;
	}
	
	
}