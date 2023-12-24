#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

init()
{
	place_babyjug();

	//level._effect[ "lightning_dog_spawn" ] = LoadFX( "maps/zombie/fx_zombie_dog_lightning_buildup" );
	register_perk_spawn( ( -160, -528, 1 ), ( 0, 0, 0 ) );
	register_perk_spawn( ( 443.7, 641.1, 144.1 ), ( 0, -180, 0 ) );
	register_perk_spawn( ( 510.3, 645.9, 1.1 ), ( 0, -180, 0 ) );
	register_perk_spawn( ( 170.8, 326.1, 145.1 ), ( 0, 0, 0 ) );
	spawn_perk( "zombie_vending_jugg", "zombie_vending", "vending_jugg", "specialty_armorvest", "mus_perks_jugganog_jingle", "mus_perks_jugganog_sting" );
	spawn_perk( "zombie_vending_sleight", "zombie_vending", "vending_sleight", "specialty_fastreload", "mus_perks_speed_jingle", "mus_perks_speed_sting" );
	spawn_perk( "zombie_vending_doubletap", "zombie_vending", "vending_doubletap", "specialty_rof", "mus_perks_doubletap_jingle", "mus_perks_doubletap_sting" );
	spawn_perk( "zombie_vending_revive", "zombie_vending", "vending_revive", "specialty_quickrevive", "mus_perks_revive_jingle", "mus_perks_revive_sting" );
	spawn_perk( "zombie_vending_nuke", "zombie_vending", "vending_divetonuke", "specialty_flakjacket", "mus_perks_phd_jingle", "mus_perks_phd_sting" );
	spawn_perk( "zombie_vending_marathon", "zombie_vending", "vending_marathon", "specialty_longersprint", "mus_perks_stamin_jingle", "mus_perks_stamin_sting" );
	spawn_perk( "zombie_vending_ads", "zombie_vending", "vending_deadshot", "specialty_deadshot", "mus_perks_deadshot_jingle", "mus_perks_deadshot_sting" );
	spawn_perk( "zombie_vending_three_gun", "zombie_vending", "vending_additionalprimaryweapon", "specialty_additionalprimaryweapon", "mus_perks_mulekick_jingle", "mus_perks_mulekick_sting" );
	//spawn_perk( "p6_zm_vending_chugabud", "zombie_vending", "vending_chugabud", "specialty_bulletaccuracy", "mus_perks_whoswho_jingle", "mus_perks_whoswho_sting" );
	//spawn_perk( "p6_zm_vending_electric_cherry", "zombie_vending", "vending_electriccherry", "specialty_bulletdamage", "mus_perks_cherry_jingle", "mus_perks_cherry_sting" );
	//spawn_perk( "p6_zm_vending_vultureaid", "zombie_vending", "vending_vulture", "specialty_altmelee", "mus_perks_vulture_jingle", "mus_perks_vulture_sting" );
	//spawn_perk( "p7_zm_vending_widows_wine", "zombie_vending", "vending_widowswine", "specialty_extraammo", "mus_perks_widows_jingle", "mus_perks_widows_sting" );
	//spawn_perk( "zombie_vending_packapunch", "zombie_vending_upgrade", "vending_packapunch", "specialty_weapupgrade", "mus_perks_packa_jingle", "mus_perks_packa_sting" );
	level._solo_revive_machine_expire_func = ::solo_quick_revive_disable;
	level thread randomize_perks_think();
}

place_babyjug()
{
	machine_origin = (308, 241, 62);
	machine_angles = (0, 280, 0);
	bottle = Spawn( "script_model", machine_origin );
	bottle.angles = machine_angles;
	bottle setModel( "t6_wpn_zmb_perk_bottle_jugg_world" );

	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 0), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_babyjugg";
	perk_trigger.script_noteworthy = "specialty_bulletaccuracy";

}

register_perk_spawn( origin, angles )
{
	if( !IsDefined( level.perk_spawn_location ) )
	{
		level.perk_spawn_location = [];
	}
	perk_clip = Spawn( "script_model", origin );
	perk_clip.angles = angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	struct = SpawnStruct();
	struct.origin = origin;
	struct.angles = angles;
	level.perk_spawn_location[ level.perk_spawn_location.size ] = struct;
}

spawn_perk( model, targetname, target, perk, jingle, sting )
{
	machine = Spawn( "script_model", ( 0, 0, -9999 ) );
	machine.angles = ( 0, 0, 0 );
	machine SetModel( model );
	machine.targetname = target;
	trigger = Spawn( "trigger_radius_use", machine.origin + ( 0, 0, 30 ), 0, 20, 70 );
	trigger.targetname = targetname;
	trigger.target = target;
	trigger.script_noteworthy = perk;
	trigger.script_sound = jingle;
	trigger.script_label = sting;
}

///*
hidden_perk_waypoints( struct )
{
	return IsDefined( struct.perk_to_check ) && !is_true( level.perk_randomization_on[ struct.perk_to_check ] );
}

perk_vulture_update_position( perk )
{
	if( IsDefined( level.perk_vulture ) && IsDefined( level.perk_vulture.vulture_vision_fx_list ) )
	{
		structs = level.perk_vulture.vulture_vision_fx_list;
		for( i = 0; i < structs.size; i ++ )
		{
			if( IsDefined( structs[i].perk_to_check ) && structs[i].perk_to_check == perk )
			{
				type = "perk";
				switch( perk )
				{
					case "specialty_weapupgrade":
						type = "packapunch";
						break;
				}
				//structs[i].location = self maps\_zombiemode_perks::get_waypoint_origin( type );
				//Need entire Vulture aid code for this to work, see zombiemode_perks.gsc::3500-4900
				level.perk_randomization_on[ perk ] = true;
				return;
			}
		}
	}
}

randomize_perks_think()
{
	while( !IsDefined( level.perk_vulture ) || !IsDefined( level.perk_vulture.vulture_vision_fx_list ) )
	{
		wait 0.05;
	}
	level.perk_randomization_on = [];
	level.vulture_perk_custom_map_check = ::hidden_perk_waypoints;
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	vending_triggers = array_combine( vending_triggers, GetEntArray( "zombie_vending_upgrade", "targetname" ) );
	for( i = 0; i < vending_triggers.size; i ++ )
	{
		machine = GetEnt( vending_triggers[i].target, "targetname" );
		vending_triggers[i] EnableLinkTo();
		vending_triggers[i] LinkTo( machine );
	}

	
	last_perks = [];
	while( true )
	{
		curr_perks = [];
		perk_list = array_randomize( vending_triggers );
		for( i = 0; i < perk_list.size; i ++ )
		{
			machine = GetEnt( perk_list[i].target, "targetname" );
			perk = perk_list[i].script_noteworthy;
			if( is_in_array( last_perks, perk ) || curr_perks.size >= 4 || ( perk == "specialty_quickrevive" && flag( "solo_game" ) && flag( "solo_revive" ) ) )
			{
				machine.origin = ( 0, 0, -9999 );
				machine.angles = ( 0, 0, 0 );
			}
			else
			{
				index = curr_perks.size;
				machine.origin = level.perk_spawn_location[ index ].origin;
				machine.angles = level.perk_spawn_location[ index ].angles;
				perk_list[i] perk_vulture_update_position( perk );
				machine thread perk_swap_fx( perk );
				curr_perks[ index ] = perk;
			}
		}
		last_perks = curr_perks;
		wait RandomFloatRange( 90, 180 );
		level.pap_moving = true;
		while( flag( "pack_machine_in_use" ) )
		{
			wait 0.05;
		}
		level notify( "perks_swapping" );
		wait 10;
		for( i = 0; i < level.perk_spawn_location.size; i ++ )
		{
			level thread hellhound_spawn_fx( level.perk_spawn_location[i].origin );
		}
		wait 1.5;
		level.pap_moving = undefined;
	}
}


perk_swap_fx( perk )
{
	level waittill( "perks_swapping" );
	level.perk_randomization_on[ perk ] = false;
	fake_perk = Spawn( "script_model", self.origin );
	fake_perk.angles = self.angles;
	fake_perk SetModel( self.model );
	self.origin = ( 0, 0, -9999 );
	self.angles = ( 0, 0, 0 );
	direction = fake_perk.origin;
	direction = ( direction[1], direction[0], 0 );
	if( direction[1] < 0 || ( direction[0] > 0 && direction[1] > 0 ) )
	{
		direction = ( direction[0], direction[1] * -1, 0 );
	}
	else if( direction[0] < 0 )
	{
		direction = ( direction[0] * -1, direction[1], 0 );
	}
	fake_perk PlaySound( "zmb_box_move" );
	fake_perk MoveTo( fake_perk.origin + ( 0, 0, 40 ), 3 );
	fake_perk Vibrate( direction, 10, 0.5, 5 );
	fake_perk waittill( "movedone" );
	PlayFX( level._effect[ "poltergeist" ], fake_perk.origin );
	PlaySoundAtPosition( "zmb_box_poof", fake_perk.origin );
	fake_perk Delete();
}

//*
hellhound_spawn_fx( origin )
{
	//PlayFX( level._effect[ "lightning_dog_spawn" ], origin );
	PlaySoundAtPosition( "zmb_hellhound_prespawn", origin );
	wait 1.5;
	PlaySoundAtPosition( "zmb_hellhound_bolt", origin );
	Earthquake( 0.5, 0.75, origin, 1000 );
	PlayRumbleOnPosition( "explosion_generic", origin );
	PlaySoundAtPosition( "zmb_hellhound_spawn", origin );
}

solo_quick_revive_disable()
{
	self Unlink();
	self trigger_off();
}
//*/