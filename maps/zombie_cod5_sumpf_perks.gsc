#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;


solo_quick_revive_disable()
{
	self Unlink();
	self trigger_off();
}

randomize_vending_machines()
{
	if( is_true( flag( "sumpf_perks" ) ) )
		return;
	
	flag_init( "sumpf_perks" );
	
	level thread watch_randomize_vending_machines();
	level thread watch_swamplights();

	flag_set( "sumpf_perks" );
}

watch_randomize_vending_machines()
{
	self endon( "end_game" );

	//self thread watch_hanging_zombie_eye_glow();
	while( true )
	{
		rounds_until_swap = randomintrange( 1, 4 );
		if( is_true( level.dev_only))
			rounds_until_swap = 1;
		//iprintln( "Rounds until vending machines swap: " + rounds_until_swap );
		for( i = 0; i < rounds_until_swap; i++ )
		{
			event = self waittill_any_return( "end_of_round", "shino_force_swap");
			if( event == "shino_force_swap" )
				break;
			
		}
		
		//iprintln( "Randomizing vending machines" );
		self notify( "perks_swapping" );
		wait( 2 );
	}

}

/* Free perks will spawn if you kill zombies within the swamp lights */
watch_swamplights()
{
	self endon( "end_game" );
	//iprintln( "ENTER SWAMPLIGHTS" );

	level waittill( "pap_available" );
	zone_keys = GetArrayKeys( level.ARRAY_SWAMPLIGHTS_POS );


	wait_times = array(30, 60, 240, 300);
	if( is_true( level.dev_only ) )
		wait_times = array(10, 5);

	while( true )
	{
		wait( array_randomize( wait_times )[0] );
		//iprintln( "Waiting 10" );
		//wait(10);
		
		total_swamplights = 3;
		randomized_keys = array_randomize( zone_keys );
		positions = [];

		for(i=0; i < total_swamplights; i++)
		{
			positions[i] = randomint( 3 ); // 0, 1, 2
			struct = Spawn("script_model", level.ARRAY_SWAMPLIGHTS_POS[ randomized_keys[i] ][ positions[i] ] );
			struct.origin += (0, 0, 10);
			struct.angles = (0, 0, 0);
			struct SetModel( "t6_wpn_zmb_perk_bottle_jugg_world" );
			struct NotSolid();
			struct Hide();
			
			isFullfilled = watch_spawn_swamplight( struct );
			//iprintln( isFullfilled );

			if( !is_true(isFullfilled) )
			{
				struct Delete();
				break;
			}

			if( i == total_swamplights - 1 )
			{
				//idx = randomint( 3 );
				dropLoc = level.ARRAY_SWAMPLIGHTS_POS[ randomized_keys[i] ][ positions[i] ];
				maps\_zombiemode_powerups::specific_powerup_drop( "free_perk", dropLoc );
				level waittill( "powerup_dropped", powerup );
	
				//watch_spawn_swamplight( powerup );
				//powerup Delete();
			}

			struct notify( "death" );
			struct Delete();
				
		}

	}

}

#using_animtree ( "generic_human" );
watch_spawn_swamplight(struct)
{
	level notify( "swamplight_expire" );
	wait( 1 );
	level endon( "swamplight_expire" );

	thread watch_swamplight_expire( struct );
	
	//Spawn_fx
	if( IsDefined( struct.powerup_name ) )
		return;

	while( true )
	{
		level.current_swamplight_struct = struct;
		level waittill("swamplight_zomb_sacraficed", zomb);
		level.current_swamplight_struct = undefined;
		
		if( !IsDefined( zomb ) || !IsAlive( zomb ) )
			continue;
		
		zomb zombie_handle_swamplight_fx();
		zomb DoDamage( zomb.health + 10, zomb.origin, undefined );
		return true;
			
	}

	return false;
}

	zombie_handle_swamplight_fx()
	{
	
		//Sacrafice zombie
		self.ignoreme = true;
		self.ignoreall = true;
		self disable_pain();
		self thread magic_bullet_shield();
		
		self.animname = "dancer";
		self thread beat_break( %ai_zombie_flinger_flail );

		//Move zombie up
		light_mover = Spawn( "script_model", self.origin );
		light_mover.angles = self.angles;
		light_mover SetModel( "tag_origin" );
		self LinkTo( light_mover );
		
		move_dist = 64;
		raise_time = 4;
		light_mover MoveZ( move_dist, raise_time );

		light_mover waittill_notify_or_timeout( "movedone", raise_time + 1 );

		//Smite zombie
		maps\zombie_cod5_sumpf_perk_machines::hellhound_spawn_fx( self.origin );

		self thread stop_magic_bullet_shield();
		self Unlink();
		self DoDamage( self.health + 10, self.origin, undefined );
		self Hide();
		
	}

	//Rise zombie into the air and smite it
	beat_break( str_anim )
	{
		self.ignoreall = true;
		self.ignoreme = true;

		while( IsDefined( self ) && IsAlive( self ) )
		{
			dance_anim = str_anim;
			self SetFlaggedAnimKnobAllRestart( "dance_anim", dance_anim, %body, 1, .1, 1 );
			animscripts\traverse\zombie_shared::wait_anim_length( dance_anim, .02 );
		}
	}
	

watch_swamplight_expire( struct )
{
	level endon( "swamplight_expire" );

	PlayFXOnTag(level._effect["lght_marker"], struct, "tag_origin");
	PlayFXOnTag( level._effect["chest_light"], struct, "tag_origin");
	
	time = 0;
	limit = level.THRESHOLD_SHINO_SWAMPLIGHT_EXPIRATION_TIME;
	while( time < limit-1 && IsDefined( struct.origin ) )
	{
		PlayFX(level._effect["lght_marker_flare"], struct.origin);//, "tag_origin");
		wait(3);
		time += 3;
	}
	
	//wait( level.THRESHOLD_SHINO_SWAMPLIGHT_EXPIRATION_TIME );
	
	level notify( "swamplight_expire" );
}

	checkDist(a, b, distance )
	{
		return maps\_zombiemode::checkDist( a, b, distance );
	}





watch_hanging_zombie_eye_glow()
{
	self endon( "end_game" );

	//get all assets
	flag_wait("begin_spawning");
	//ents = GetEntArray( "script_model", "classname" );
	ents = GetEntArray( "player", "classname" );

	//iprintln( "ents.size: " + ents.size );
	player = GetPlayers()[0];
	

}


activate_vending_machine( machine, origin, entity, script_noteworthy )
{
	//iprintln( "activate_vending_machine: " + machine );
	//wait 4;

	switch( machine )
	{
		case "zombie_vending_revive_on":
			level thread maps\_zombiemode_perks::turn_revive_on();
			level notify("revive_on");
			break;

		case "zombie_vending_jugg_on":
			level thread maps\_zombiemode_perks::turn_jugger_on();
			level notify("juggernog_on");
			break;

		case "zombie_vending_doubletap2_on":
		case "zombie_vending_doubletap_on":
			level thread maps\_zombiemode_perks::turn_doubletap_on();
			level notify("doubletap_on");
			break;

		case "zombie_vending_sleight_on":
			level thread maps\_zombiemode_perks::turn_sleight_on();
			level notify("sleight_on");
			break;

		case "zombie_vending_marathon_on":
			level thread maps\_zombiemode_perks::turn_marathon_on();
			level notify("marathon_on");
			break;

		case "zombie_vending_three_gun_on":
			level thread maps\_zombiemode_perks::turn_additionalprimaryweapon_on();
			level notify("additionalprimaryweapon_on");
			break;

		case "zombie_vending_ads_on":
			level thread maps\_zombiemode_perks::turn_deadshot_on();
			level notify("deadshot_on");
			break;

		case "zombie_vending_nuke_on":
			level thread maps\_zombiemode_perks::turn_divetonuke_on();
			level notify("divetonuke_on");
			break;

		case "p6_zm_vending_electric_cherry_on":
			level thread maps\_zombiemode_perks::turn_electriccherry_on();
			level notify("electriccherry_on");
			break;

		case "bo2_zombie_vending_vultureaid_on":
			level thread maps\_zombiemode_perks::turn_vulture_on();
			level notify("vulture_on");
			break;

		case "bo3_p7_zm_vending_widows_wine_on":
			level thread maps\_zombiemode_perks::turn_widowswine_on();
			level notify("widowswine_on");
			break;

		case "zombie_vending_packapunch_on":
			level thread maps\_zombiemode_perks::turn_PackAPunch_on();
			level notify("Pack_A_Punch_on");
			break;

		default:
			//iprintln( "activate_vending_machine: " + machine + " not found" );
			break;
	}

	if( IsDefined( script_noteworthy ) )
	{
		level notify( script_noteworthy + "_power_on" );
	}
	else
	{
		//iprintln( "script_noteworthy not defined for: " + machine );
	}
	
	wait 3;
	level notify ("zombie_vending_spawned");

	play_vending_vo( machine, origin );	
}

play_vending_vo( machine, origin )
{
	players = GetPlayers();
	players = get_array_of_closest( origin, players, undefined, undefined, 512 );
	player = undefined;
	for( i = 0; i < players.size; i ++ )
	{
		if( SightTracePassed( players[i] GetEye(), origin, false, undefined ) )
		{
			player = players[i];
			break;
		}
	}
	if( !IsDefined( player ) )
	{
		return;
	}
	switch( machine )
	{
		case "zombie_vending_jugg_on":
			player thread maps\_zombiemode_audio::create_and_play_dialog( "level", "jugga" );
			break;

		case "zombie_vending_doubletap2_on":
			player thread maps\_zombiemode_audio::create_and_play_dialog( "level", "doubletap" );
			break;

		case "zombie_vending_revive_on":
			player thread maps\_zombiemode_audio::create_and_play_dialog( "level", "revive" );
			break;

		case "zombie_vending_sleight_on":
			player thread maps\_zombiemode_audio::create_and_play_dialog( "level", "speed" );
			break;
	}
}

vending_randomization_effect( index )
{
	level endon( "end_game" );
	//level endon( "perks_swapping" ); -- cant use, perk_trigger doesnt delete

	flag_set( "pack_machine_in_use" );	//Prevent multiple activations from doors openened on round end

	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	vending_triggers = array_combine( vending_triggers, GetEntArray( "zombie_vending_upgrade", "targetname" ) );
	level.ARRAY_SHINO_ZONE_OPENED[ index ] = true;
	//iprintln( "vending_randomization_effect zone opened: " + index );

	//level.ARRAY_SHINO_PERKS_AVAILIBLE[ index ] = "vending_packapunch";

	//iprintln( "Trying to spawn perk: " + level.ARRAY_SHINO_PERKS_AVAILIBLE[ index ] );
	machine_array = GetEntArray( level.ARRAY_SHINO_PERKS_AVAILIBLE[ index ], "targetname" );

	machine = undefined;
	for( j = 0; j < machine_array.size; j ++ )
	{
		if( IsDefined( machine_array[j].script_noteworthy ) && machine_array[j].script_noteworthy == "clip" )
			continue;
		machine = machine_array[j];
	}

	if( !IsDefined( machine ) )
		//iprintln( "machine not found for: " + level.ARRAY_SHINO_PERKS_AVAILIBLE[ index ] );
	
	machine Hide();
	
	triggers = GetEntArray( machine.targetname, "target" );
	trigInd = 0;

	for( i = 0; i < vending_triggers.size; i ++ )
	{
		if( vending_triggers[i].target == level.ARRAY_SHINO_PERKS_AVAILIBLE[ index ] )
		{
			trigInd = i;
			break;
		}
		
	}
	
	machine.origin = level.perk_spawn_location[ index ].origin;
	machine.angles = level.perk_spawn_location[ index ].angles;

	//This location needs special treatment for cherry
	if( level.ARRAY_SHINO_PERKS_AVAILIBLE[ index ] == "vending_electriccherry"  && index == 1 )
	{
		machine.origin = (11671, 3602, -659);
	}

	PlaySoundAtPosition( "rando_start", machine.origin );
	origin = machine.origin;
	//index
	//iprintln( "Index: " + index );
	//iprintln( "At location: " + origin );
	//iprintln( "Trigger origin: " + vending_triggers[trigInd].origin );
	
	if( level.vending_model_info.size > 1 )
	{
		PlayFXOnTag( level._effect[ "zombie_perk_start" ], machine, "tag_origin" );
		PlaySoundAtPosition( "rando_perk", machine.origin );
	}
	else
	{
		PlayFXOnTag( level._effect[ "zombie_perk_4th" ], machine, "tag_origin" );
		PlaySoundAtPosition( "rando_perk", machine.origin );
	}

	true_model = machine.model;
	machine Show();
	level thread play_sound_2D( "perk_lottery" );
	tag_fx = Spawn( "script_model", machine.origin + ( 0, 0, 40 ) );
	tag_fx SetModel( "tag_origin" );
	tag_fx LinkTo( machine );
	machine MoveTo( origin + ( 0, 0, 40 ), 5, 3, 0.5 );
	machine Vibrate( machine.angles, 2, 1, 4 );
	modelindex = 0;
	level.vending_model_info = array_combine( level.vending_model_info, level.extra_vending_model_info );
	for( i = 0; i < 30; i ++ )
	{                             
		wait 0.15;
		if( level.vending_model_info.size > 1 )
		{
			while( !IsDefined( level.vending_model_info[ modelindex ] ) )
			{
				modelindex ++;
				if( modelindex == 12 )
				{
					modelindex = 0;
				}
			}
			modelname = level.vending_model_info[ modelindex ];
			machine SetModel( modelname );
			PlayFXOnTag( level._effect[ "zombie_perk_flash" ], tag_fx, "tag_origin" );
			modelindex ++;
			if( modelindex == 12 )
			{
				modelindex = 0;
			}
		}
	}
	tag_fx notify( "death" );
	tag_fx Delete();

	machine SetModel( true_model );
	machine MoveTo( origin, 0.3, 0.3, 0 );
	PlayFXOnTag( level._effect[ "zombie_perk_end" ], machine, "tag_origin" );
	PlaySoundAtPosition( "perks_rattle", machine.origin );


	//perk_trigger = Spawn( "trigger_radius_use", machine.origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger = Spawn( "trigger_radius_use", machine.origin + (0 , 0, 0), 0, 20, 70 );
	
	perk_trigger.angles = machine.angles + (0, 90, 0);
	perk_trigger UseTriggerRequireLookAt();
	perk_trigger SetHintString( &"ZOMBIE_NEED_POWER" );
	perk_trigger SetCursorHint( "HINT_NOICON" );
	thread activate_vending_machine( true_model, origin, machine, vending_triggers[trigInd].script_noteworthy );

	time_to_turn_machine_on = 3;
	wait(time_to_turn_machine_on);

	perk_trigger.script_noteworthy = vending_triggers[trigInd].script_noteworthy;
	perk_trigger set_perk_buystring( vending_triggers[trigInd].script_noteworthy );

	level.pap_moving = true;
	wait 0.1;
	level.pap_moving = false;
	flag_clear( "pack_machine_in_use" );

	level waittill( "perks_swapping" );

	while( flag( "pack_machine_in_use" ) )
	{
		wait 0.05;
	}
	wait( 1.5 );

	perk_trigger notify( "death" );
	level.pap_moving = true;

	//iprintln( "delete perk_trigger: " + perk_trigger );
	perk_trigger Delete();

}

set_perk_buystring( script_notetworthy, machineTargetName )
{
	if( script_notetworthy == "specialty_weapupgrade" )
	{
		self thread maps\_zombiemode_perks::vending_weapon_upgrade();
		wait 0.1;
		level notify("Pack_A_Punch_on");
		return;
	}
		

	cost = level.zombie_vars["zombie_perk_cost"];
	switch( script_notetworthy )
	{
	case "specialty_armorvest_upgrade":
	case "specialty_armorvest":
		cost = 2500;
		if( level.expensive_perks )
			cost = 4000;
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

	upgrade_perk_cost = level.VALUE_PERK_PUNCH_COST;
	if(level.expensive_perks)
		upgrade_perk_cost = level.VALUE_PERK_PUNCH_EXPENSIVE_COST;

	switch( script_notetworthy )
	{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
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
	}

	self thread maps\_zombiemode_perks::watch_perk_trigger( script_notetworthy, cost, upgrade_perk_cost, machineTargetName );

}