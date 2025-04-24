#include maps\_utility;
#include common_scripts\utility;

init()
{
	place_babyjug();

	//place_doubletap();
	place_deadshot();
	place_mulekick();

	//these perks only availible if level.bo2_perks is true
	if( level.bo2_perks )
	{
		place_martyrdom();
		place_extraammo();
		//place_chugabud();	//swapped with vultures
		place_vulture();	//vulture
	}
	
}

place_babyjug()
{
	machine_origin = (-570, 205, -254);
	machine_angles = (0, 120, 0);
	bottle = Spawn( "script_model", machine_origin );
	bottle.angles = machine_angles;
	bottle setModel( "t6_wpn_zmb_perk_bottle_jugg_world" );

	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 0), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_babyjugg";
	perk_trigger.script_noteworthy = "specialty_extraammo";

}

place_doubletap()
{
	machine_origin = (1141.7, 736.3, -326.6);
	machine_angles = (0, -180, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "zombie_vending_doubletap2" );
	perk.targetname = "vending_doubletap";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_doubletap";
	perk_trigger.script_noteworthy = "specialty_rof";
	perk_trigger.script_sound = "mus_perks_doubletap_jingle";
	perk_trigger.script_label = "mus_perks_doubletap_sting";
	perk_clip = spawn( "script_model", machine_origin + (0, 0, 30));
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x64" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_deadshot()
{
	machine_origin = (-1531.9, 887.6, -133.0);
	machine_angles = (0, 180, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "zombie_vending_ads" );
	perk.targetname = "vending_deadshot";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_deadshot";
	perk_trigger.script_noteworthy = "specialty_deadshot";
	perk_trigger.script_sound = "mus_perks_deadshot_jingle";
	perk_trigger.script_label = "mus_perks_deadshot_sting";
	perk_clip = spawn( "script_model", machine_origin + (0, 0, 30));
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x64" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";

	level.zombie_deadshot_machine_monkey_angles = (0, 270, 0);
	level.zombie_deadshot_machine_monkey_origins = [];

	level.zombie_deadshot_machine_monkey_origins[0] = machine_origin + (32, 24, 5);
	level.zombie_deadshot_machine_monkey_origins[1] = machine_origin + (0, 30, 5);
	level.zombie_deadshot_machine_monkey_origins[2] = machine_origin + (-29.5, 24, 5);
	

	perk.target = "vending_deadshot_monkey_structs";
	for ( i = 0; i < level.zombie_deadshot_machine_monkey_origins.size; i++ )
	{
		machine_monkey_struct = SpawnStruct();
		machine_monkey_struct.origin = level.zombie_deadshot_machine_monkey_origins[i];
		machine_monkey_struct.angles = level.zombie_deadshot_machine_monkey_angles;
		machine_monkey_struct.script_int = i + 1;
		machine_monkey_struct.script_notetworthy = "cosmo_monkey_deadshot";
		machine_monkey_struct.targetname = "vending_deadshot_monkey_structs";

		if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
		{
			level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
		}

		size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
		level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
	}


}

place_martyrdom()
{
	machine_origin = (58.9087, -886.359, -165.875);
	machine_angles = (0, 180, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "p6_zm_vending_electric_cherry_off" );
	perk.targetname = "vending_electriccherry";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_electriccherry";
	perk_trigger.script_noteworthy = "specialty_bulletdamage";
	perk_trigger.script_sound = "mus_perks_cherry_jingle";
	perk_trigger.script_label = "mus_perks_cherry_sting";
	perk_clip = spawn( "script_model", machine_origin + (0, 0, 30));
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x64" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";

	level.zombie_cherry_machine_monkey_angles = (0, 270, 0);
	level.zombie_cherry_machine_monkey_origins = [];

	level.zombie_cherry_machine_monkey_origins[0] = machine_origin + (29, 24, 2);
	level.zombie_cherry_machine_monkey_origins[1] = machine_origin + (0, 42, 1);
	level.zombie_cherry_machine_monkey_origins[2] = machine_origin + (-31.5, 24, 2);
	

	perk.target = "vending_cherry_monkey_structs";
	for ( i = 0; i < level.zombie_cherry_machine_monkey_origins.size; i++ )
	{
		machine_monkey_struct = SpawnStruct();
		machine_monkey_struct.origin = level.zombie_cherry_machine_monkey_origins[i];
		machine_monkey_struct.angles = level.zombie_cherry_machine_monkey_angles;
		machine_monkey_struct.script_int = i + 1;
		machine_monkey_struct.script_notetworthy = "cosmo_monkey_cherry";
		machine_monkey_struct.targetname = "vending_cherry_monkey_structs";

		if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
		{
			level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
		}

		size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
		level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
	}

}

place_extraammo()
{
	machine_origin = (1387.1, 16.4, -343.2);	
	machine_angles = (0, 180, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "bo3_p7_zm_vending_widows_wine_off" );
	perk.targetname = "vending_widowswine";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_widowswine";
	perk_trigger.script_noteworthy = "specialty_bulletaccuracy";
	perk_trigger.script_sound = "mus_perks_widows_jingle";
	perk_trigger.script_label = "mus_perks_widows_sting";
	perk_clip = spawn( "script_model", machine_origin + (0, 0, 30));
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x64" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";

	level.zombie_wine_machine_monkey_angles = (0, 270, 0);
	level.zombie_wine_machine_monkey_origins = [];

	level.zombie_wine_machine_monkey_origins[0] = machine_origin + (32, 40, 5);
	level.zombie_wine_machine_monkey_origins[1] = machine_origin + (0, 40, 5);
	level.zombie_wine_machine_monkey_origins[2] = machine_origin + (-29.5, 40, 5);
	

	perk.target = "vending_wine_monkey_structs";
	for ( i = 0; i < level.zombie_wine_machine_monkey_origins.size; i++ )
	{
		machine_monkey_struct = SpawnStruct();
		machine_monkey_struct.origin = level.zombie_wine_machine_monkey_origins[i];
		machine_monkey_struct.angles = level.zombie_wine_machine_monkey_angles;
		machine_monkey_struct.script_int = i + 1;
		machine_monkey_struct.script_notetworthy = "cosmo_monkey_wine";
		machine_monkey_struct.targetname = "vending_wine_monkey_structs";

		if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
		{
			level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
		}

		size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
		level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
	}
}

place_vulture()
{
	machine_origin = (627.7, -1825.6, -134.5);
	machine_angles = (0, 270, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "bo2_zombie_vending_vultureaid" );
	perk.targetname = "vending_vulture";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_vulture";
	perk_trigger.script_noteworthy = "specialty_altmelee";
	perk_trigger.script_sound = "mus_perks_vulture_jingle";
	perk_trigger.script_label = "mus_perks_vulture_sting";
	perk_clip = spawn( "script_model", machine_origin + (0, 0, 30));
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x64" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";

	level.zombie_vulture_machine_monkey_angles = (0, 0, 0);
	level.zombie_vulture_machine_monkey_origins = [];

	
	level.zombie_vulture_machine_monkey_origins[0] = machine_origin + (-35, 8, -2);
	level.zombie_vulture_machine_monkey_origins[1] = machine_origin + (-35, 0, 2);
	level.zombie_vulture_machine_monkey_origins[2] = machine_origin + (-35, -8, 7);
	

	perk.target = "vending_vulture_monkey_structs";
	for ( i = 0; i < level.zombie_vulture_machine_monkey_origins.size; i++ )
	{
		machine_monkey_struct = SpawnStruct();
		machine_monkey_struct.origin = level.zombie_vulture_machine_monkey_origins[i];
		machine_monkey_struct.angles = level.zombie_vulture_machine_monkey_angles;
		machine_monkey_struct.script_int = i + 1;
		machine_monkey_struct.script_notetworthy = "cosmo_monkey_vulture";
		machine_monkey_struct.targetname = "vending_vulture_monkey_structs";

		if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
		{
			level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
		}

		size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
		level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
	}
}

place_mulekick()
{
	machine_origin = (420.8, 1359.1, 55);
	machine_angles = (0, 270, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk SetModel( "zombie_vending_three_gun" );
	perk.targetname = "vending_additionalprimaryweapon";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + ( 0, 0, 30 ), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_additionalprimaryweapon";
	perk_trigger.script_noteworthy = "specialty_additionalprimaryweapon";
	perk_trigger.script_sound = "mus_perks_mulekick_jingle";
	perk_trigger.script_label = "mus_perks_mulekick_sting";
	perk_clip = Spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x64" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";

	level.zombie_additionalprimaryweapon_machine_monkey_angles = (0, 0, 0);
	level.zombie_additionalprimaryweapon_machine_monkey_origins = [];

	level.zombie_additionalprimaryweapon_machine_monkey_origins = [];
	level.zombie_additionalprimaryweapon_machine_monkey_origins[0] = (398.8, 1398.6, 60);
	level.zombie_additionalprimaryweapon_machine_monkey_origins[1] = (380.8, 1358.6, 60);
	level.zombie_additionalprimaryweapon_machine_monkey_origins[2] = (398.8, 1318.6, 60);
	

	perk.target = "vending_additionalprimaryweapon_monkey_structs";
	for ( i = 0; i < level.zombie_additionalprimaryweapon_machine_monkey_origins.size; i++ )
	{
		machine_monkey_struct = SpawnStruct();
		machine_monkey_struct.origin = level.zombie_additionalprimaryweapon_machine_monkey_origins[i];
		machine_monkey_struct.angles = level.zombie_additionalprimaryweapon_machine_monkey_angles;
		machine_monkey_struct.script_int = i + 1;
		machine_monkey_struct.script_notetworthy = "cosmo_monkey_additionalprimaryweapon";
		machine_monkey_struct.targetname = "vending_additionalprimaryweapon_monkey_structs";

		if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
		{
			level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
		}

		size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
		level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
	}
}