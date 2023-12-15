#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

swap_quick_revive( vending_machines )
{
	trigger = undefined;
	clip = undefined;
	model = undefined;
	for( i = 0; i < vending_machines.size; i ++ )
	{
		if( vending_machines[i].script_noteworthy == "specialty_quickrevive" )
		{
			trigger = vending_machines[i];
			break;
		}
	}
	machine = GetEntArray( trigger.target, "targetname" );
	for( i = 0; i < machine.size; i ++ )
	{
		if( IsDefined( machine[i].script_noteworthy ) && machine[i].script_noteworthy == "clip" )
		{
			clip = machine[i];
		}
		else
		{
			model = machine[i];
		}
	}
	anchor = Spawn( "script_model", model.origin );
	anchor.angles = model.angles;
	anchor SetModel( "tag_origin" );
	clip EnableLinkTo();
	clip LinkTo( anchor );
	trigger EnableLinkTo();
	trigger LinkTo( anchor );
	model.origin = ( 9565, 327, -529 );
	model.angles = ( 0, 90, 0 );
	anchor.origin = model.origin;
	anchor.angles = model.angles;
	level._solo_revive_machine_expire_func = ::solo_quick_revive_disable;
}

solo_quick_revive_disable()
{
	self Unlink();
	self trigger_off();
}

randomize_vending_machines()
{
	vending_machines = GetEntArray( "zombie_vending", "targetname" );
	swap_quick_revive( vending_machines );
	vending_machine_remove = [];
	for( i = 0; i < vending_machines.size; i ++ )
	{
		if( vending_machines[i].script_noteworthy == "specialty_deadshot" || 
		//vending_machines[i].script_noteworthy == "specialty_quickrevive" || 
		vending_machines[i].script_noteworthy == "specialty_bulletdamage" || 
		vending_machines[i].script_noteworthy == "specialty_altmelee" )
		{
			vending_machine_remove[ vending_machine_remove.size ] = vending_machines[i];
		}
	}
	for( i = 0; i < vending_machine_remove.size; i ++ )
	{
		vending_machines = array_remove( vending_machines, vending_machine_remove[i] );
	}
	start_locations = [];
	start_locations[0] = GetEnt( "random_vending_start_location_0", "script_noteworthy" );
	start_locations[1] = GetEnt( "random_vending_start_location_1", "script_noteworthy" );
	start_locations[2] = GetEnt( "random_vending_start_location_2", "script_noteworthy" );
	start_locations[3] = GetEnt( "random_vending_start_location_3", "script_noteworthy" );
	start_locations[4] = spawn_perk_machine_location( "specialty_longersprint" );
	start_locations[5] = spawn_perk_machine_location( "specialty_flakjacket" );
	//start_locations[6] = spawn_perk_machine_location( "specialty_extraammo" );			//wine not used yet
	

	level.start_locations = [];
	level.start_locations[ level.start_locations.size ] = start_locations[0].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[1].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[2].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[3].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[4].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[5].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[6].origin;
	level.start_locations[ level.start_locations.size ] = start_locations[7].origin;
	start_locations = array_randomize( start_locations );

	for( i = 0; i < vending_machines.size; i ++ )
	{
		origin = start_locations[i].origin;
		angles = start_locations[i].angles;
		machine = vending_machines[i] get_vending_machine( start_locations[i] );
		start_locations[i].origin = origin;
		start_locations[i].angles = angles;
		machine.origin = origin;
		machine.angles = angles;
		machine Hide();
		vending_machines[i] trigger_on();
	}
	level.perk_randomization_on = [];
	level.vulture_perk_custom_map_check = ::hide_waypoint_until_perk_spawned;
}

//Reimagined-Expanded, will need to edit with vulture aid
hide_waypoint_until_perk_spawned( struct )
{
	if( IsDefined( struct.perk_to_check ) )
	{
		perk = struct.perk_to_check;
		switch( perk )
		{
			case "specialty_deadshot":
			//case "specialty_quickrevive":
			case "specialty_bulletdamage":
			case "specialty_altmelee":
				return false;
		}
		return !is_true( level.perk_randomization_on[ perk ] );
	}
	return false;
}

spawn_perk_machine_location( perk )
{
	vending_machines = GetEntArray( "zombie_vending", "targetname" );
	for( i = 0; i < vending_machines.size; i ++ )
	{
		if( vending_machines[i].script_noteworthy == perk )
		{
			machine = GetEnt( vending_machines[i].target, "targetname" );
			model = Spawn( "script_model", machine.origin );
			model.angles = machine.angles;
			model SetModel( "tag_origin" );
			return model;
		}
	}
	return undefined;
}

get_vending_machine( start_location )
{
	machine = undefined;
	machine_array = GetEntArray( self.target, "targetname" );
	for( i = 0; i < machine_array.size; i ++ )
	{
		if( !IsDefined( machine_array[i].script_noteworthy ) || machine_array[i].script_noteworthy != "clip" )
		{
			machine = machine_array[i];
		}		
	}
	if( !IsDefined( machine ) )
	{
		return;
	}
	start_location.origin = machine.origin;
	start_location.angles = machine.angles;
	self EnableLinkTo();
	self LinkTo( start_location );
	return machine;
}

activate_vending_machine( machine, origin, entity )
{
	level notify( "master_switch_activated" );
	switch( machine )
	{
		case "zombie_vending_jugg_on":
			level.perk_randomization_on[ "specialty_armorvest" ] = true;
			level notify( "specialty_armorvest_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "jugger_light" );
			break;

		case "zombie_vending_doubletap_on":
			level.perk_randomization_on[ "specialty_rof" ] = true;
			level notify( "specialty_rof_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "doubletap_light" );
			break;

		case "zombie_vending_three_gun_on":
			level.perk_randomization_on[ "specialty_additionalprimaryweapon" ] = true;
			level notify( "specialty_additionalprimaryweapon_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "additionalprimaryweapon_light" );
			break;

		case "zombie_vending_sleight_on":
			level.perk_randomization_on[ "specialty_fastreload" ] = true;
			level notify( "specialty_fastreload_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "sleight_light" );
			break;

		case "zombie_vending_marathon_on":
			level.perk_randomization_on[ "specialty_longersprint" ] = true;
			level notify( "specialty_longersprint_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "marathon_light" );
			break;

		case "zombie_vending_nuke_on":
			level.perk_randomization_on[ "specialty_flakjacket" ] = true;
			level notify( "specialty_flakjacket_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "divetonuke_light" );
			break;

		case "p6_zm_vending_chugabud_on":
			level.perk_randomization_on[ "specialty_bulletaccuracy" ] = true;
			level notify( "specialty_bulletaccuracy_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "sleight_light" );
			break;

		case "p7_zm_vending_widows_wine_on":
			level.perk_randomization_on[ "specialty_extraammo" ] = true;
			level notify( "specialty_extraammo_power_on" );
			entity maps\_zombiemode_perks::perk_fx( "jugger_light" );
			break;
	}
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

		case "zombie_vending_doubletap_on":
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
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	machines = [];
	for( j = 0; j < vending_triggers.size; j ++ )
	{
		machine_array = GetEntArray( vending_triggers[j].target, "targetname" );
		for( i = 0; i < machine_array.size; i ++ )
		{
			if( !IsDefined( machine_array[i].script_noteworthy ) || machine_array[i].script_noteworthy != "clip" )
			{
				machines[j] = machine_array[i];
			}
		}
	}
	machine = undefined;
	for( j = 0; j < machines.size; j ++ )
	{
		if( machines[j].origin == level.start_locations[ index ] )
		{
			machine = machines[j];
			break;
		}
	}
	PlaySoundAtPosition( "rando_start", machine.origin );
	origin = machine.origin;
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
	for( i = 0; i < 30; i ++ )
	{                             
		wait 0.15;
		if( level.vending_model_info.size > 1 )
		{
			while( !IsDefined( level.vending_model_info[ modelindex ] ) )
			{
				modelindex ++;
				if( modelindex == 8 )
				{
					modelindex = 0;
				}
			}
			modelname = level.vending_model_info[ modelindex ];
			machine SetModel( modelname );
			PlayFXOnTag( level._effect[ "zombie_perk_flash" ], tag_fx, "tag_origin" );
			modelindex ++;
			if( modelindex == 8 )
			{
				modelindex = 0;
			}
		}
	}
	machine SetModel( true_model );
	machine MoveTo( origin, 0.3, 0.3, 0 );
	PlayFXOnTag( level._effect[ "zombie_perk_end" ], machine, "tag_origin" );
	PlaySoundAtPosition( "perks_rattle", machine.origin );
	activate_vending_machine( true_model, origin, machine );
	for( i = 0; i < machines.size; i ++ )
	{
		if( IsDefined( level.vending_model_info[i] ) && level.vending_model_info[i] == true_model )
		{
			level.vending_model_info[i] = undefined;
			break;
		}
	}
}