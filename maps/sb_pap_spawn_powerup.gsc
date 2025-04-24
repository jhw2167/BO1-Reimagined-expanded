#include maps\_utility;
#include maps\_zombiemode_utility;
#include common_scripts\utility;
#include maps\_hud_util;

// Scripted by Slayerbeast12
// Support for nacht mb
// system for increasing odds for pap if it hasnt drop for a long time

// Cleaned up and fixed some issues - xSanchez78

init()
{
	PreCacheModel( "p_glo_ammo_box_pile_b" );
	level.pap_moving = true;
	level.pap_spawn_enabled = false;
	level.pap_spawn_active = false;
	switch( ToLower( GetDvar( #"mapname" ) ) )
	{
		case "zombie_cod5_sumpf":
			register_packapunch_spawnpoint( ( 11400.7, 3042.27, -657.875 ), ( 0, 224, 0 ) );
			register_packapunch_spawnpoint( ( 10689.9, 722.114, -660.875 ), ( 0, 270, 0 ) );
			register_packapunch_spawnpoint( ( 12292.6, -1555.6, -646.875 ), ( 0, 190, 0 ) );
			register_packapunch_spawnpoint( ( 7615.62, -833.013, -679.875 ), ( 0, 48, 0 ) );
			register_packapunch_spawnpoint( ( 8112.05, 3476.15, -664.875 ), ( 0, 135, 0 ) );
			level thread wait_all_perk_spawn();
			break;

		case "zombie_cod5_asylum":
			register_packapunch_spawnpoint( ( 1279, 607.533, 64.125 ), ( 0, 0, 0 ) );
			register_packapunch_spawnpoint( ( 341.335, 817.357, 64.125 ), ( 0, 0, 0 ) );
			register_packapunch_spawnpoint( ( -840.187, 618.704, 226.125 ), ( 0, 90, 0 ) );
			register_packapunch_spawnpoint( ( -545.304, 430.139, 226.125 ), ( 0, 0, 0 ) );
			register_packapunch_spawnpoint( ( 807.058, 405.28, 226.125 ), ( 0, 270, 0 ) );
			level thread asylum_wait_for_power();
			break;
	}
	level.debris_pap = [];
	for( i = 0; i < level.pap_spawn_location.size; i ++ )
	{
		level.debris_pap[i] = Spawn( "script_model", level.pap_spawn_location[i].origin );
		level.debris_pap[i].angles = level.pap_spawn_location[i].angles;
		level.debris_pap[i] SetModel( "p_glo_ammo_box_pile_b" );
		clip = Spawn( "script_model", level.pap_spawn_location[i].origin );
		clip.angles = level.pap_spawn_location[i].angles;
		clip SetModel( "zm_collision_perks1" );
	}
	level.pap_machine = Spawn( "script_model", ( 0, 0, -9999 ) );
	level.pap_machine.angles = ( 0, 0, 0 );
	level.pap_machine SetModel( "zombie_vending_packapunch_on" );
	level.pap_machine.targetname = "zombie_pap";
	level.pap_machine_trigger = Spawn( "trigger_radius_use", level.pap_machine.origin + ( 0, 0, 30 ), 0, 20, 70 );
	level.pap_machine_trigger.targetname = "zombie_vending_upgrade";
	level.pap_machine_trigger.target = "zombie_pap";
	level.pap_machine_trigger.script_sound = "mus_perks_packa_jingle";
	level.pap_machine_trigger.script_label = "mus_perks_packa_sting";
	level.pap_machine_trigger EnableLinkTo();
	level.pap_machine_trigger LinkTo( level.pap_machine );
}

register_packapunch_spawnpoint( origin, angles )
{
	if( !IsDefined( level.pap_spawn_location ) )
	{
		level.pap_spawn_location = [];
	}
	struct = SpawnStruct();
	struct.origin = origin;
	struct.angles = angles;
	level.pap_spawn_location[ level.pap_spawn_location.size ] = struct;
}

pap_appear()
{
	if( is_false( level.pap_spawn_enabled ) || is_true( level.pap_spawn_active ) )
	{
		return;
	}
	num = find_right_spot();
	if( !IsDefined( num ) )
	{
		return;
	}
	struct = level.pap_spawn_location[ num ];
	level.pap_spawn_active = true;
	level.pap_moving = undefined;
	level.zombie_vars[ "zombie_powerup_bonfire_sale_on" ] = true;
	level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] = 120;
	PlayFX( level._effect[ "lightning_dog_spawn" ], struct.origin );
	PlaySoundAtPosition( "zmb_hellhound_prespawn", struct.origin );
	wait 1.5;
	PlaySoundAtPosition( "zmb_hellhound_bolt", struct.origin );
	Earthquake( 0.5, 0.75, struct.origin, 1000 );
	PlayRumbleOnPosition( "explosion_generic", struct.origin );
	PlaySoundAtPosition( "zmb_hellhound_spawn", struct.origin );
	level.debris_pap[ num ] Hide();
	level.pap_machine.origin = struct.origin;
	level.pap_machine.angles = struct.angles;
	level.pap_machine_trigger maps\zombie_cod5_prototype_perk_machines::perk_vulture_update_position( "specialty_weapupgrade" );
	pap_machine_light = Spawn( "script_model", level.pap_machine.origin + ( 0, 0, 16 ) );
	pap_machine_light.angles = level.pap_machine.angles + ( -90, -90, 0 );
	pap_machine_light SetModel( "tag_origin" );
	PlayFXOnTag( level._effect[ "lght_marker" ], pap_machine_light, "tag_origin" );
	PlayFX( level._effect[ "poltergeist" ], level.pap_machine.origin );
	while( level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] > 0 )
	{
		wait 0.1;
		level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] -= 0.1;
	}
	while( flag( "pack_machine_in_use" ) )
	{
		wait 0.05;
	}
	level.pap_moving = true;
	level.zombie_vars[ "zombie_powerup_bonfire_sale_on" ] = false;
	level.zombie_vars[ "zombie_powerup_bonfire_sale_time" ] = 0;
	pap_machine_light Delete();
	fake_packapunch = Spawn( "script_model", level.pap_machine.origin );
	fake_packapunch.angles = level.pap_machine.angles;
	fake_packapunch SetModel( level.pap_machine.model );
	level.pap_machine.origin = ( 0, 0, -9999 );
	level.pap_machine.angles = ( 0, 0, 0 );
	level.perk_randomization_on[ "specialty_weapupgrade" ] = false;
	direction = fake_packapunch.origin;
	direction = ( direction[1], direction[0], 0 );
	if( direction[1] < 0 || ( direction[0] > 0 && direction[1] > 0 ) )
	{
		direction = ( direction[0], direction[1] * -1, 0 );
	}
	else if( direction[0] < 0 )
	{
		direction = ( direction[0] * -1, direction[1], 0 );
	}
	fake_packapunch PlaySound( "zmb_box_move" );
	fake_packapunch MoveTo( fake_packapunch.origin + ( 0, 0, 40 ), 3 );
	fake_packapunch Vibrate( direction, 10, 0.5, 5 );
	fake_packapunch waittill( "movedone" );
	PlayFX( level._effect[ "poltergeist" ], fake_packapunch.origin );
	PlaySoundAtPosition( "zmb_box_poof", fake_packapunch.origin );
	fake_packapunch Delete();
	level.debris_pap[ num ] Show();
	level.pap_spawn_active = false;
}

find_right_spot()
{
	possible_spawns = [];
	for( i = 0; i < level.pap_spawn_location.size; i ++ )
	{
		if( check_point_in_active_zone( level.pap_spawn_location[i].origin ) )
		{
			possible_spawns[ possible_spawns.size ] = i;
		}
	}
	if( possible_spawns.size == 0 )
	{
		return undefined;
	}
	return possible_spawns[ RandomInt( possible_spawns.size ) ];
}

asylum_wait_for_power()
{
	flag_wait( "power_on" );
	level.pap_spawn_enabled = true;
}

wait_all_perk_spawn()
{
	level.perk_activated = 0;
	level thread wait_for_perk( "specialty_armorvest_power_on" );
	level thread wait_for_perk( "specialty_rof_power_on" );
	level thread wait_for_perk( "specialty_quickrevive_power_on" );
	level thread wait_for_perk( "specialty_fastreload_power_on" );
	level thread wait_for_perk( "specialty_longersprint_power_on" );
	level thread wait_for_perk( "specialty_flakjacket_power_on" );
	level thread wait_for_perk( "specialty_extraammo_power_on" );
	level thread wait_for_perk( "specialty_bulletaccuracy_power_on" );
	while( level.perk_activated < 8 )
	{
		wait 0.05;
	}
	level.pap_spawn_enabled = true;
}

wait_for_perk( noti )
{
	level waittill( noti );
	level.perk_activated ++;
}