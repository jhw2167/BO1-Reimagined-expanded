#include maps\_utility;
#include common_scripts\utility;

init()
{
	place_babyjug();

	place_divetonuke();
	place_deadshot();	
	place_marathon();		
	//place_martyrdom();	
	//place_extraammo();		
	//place_chugabud();		
	place_mulekick();	
	//place_vulture();
}


place_babyjug()
{
	machine_origin = (1405, 51, 183);
	machine_angles = (10, 0, 0);
	bottle = Spawn( "script_model", machine_origin );
	bottle.angles = machine_angles;
	bottle setModel( "t6_wpn_zmb_perk_bottle_jugg_world" );

	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 0), 0, 270, 600 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_babyjugg";
	perk_trigger.script_noteworthy = "specialty_bulletaccuracy";

}

place_divetonuke()
{
	machine_origin = (-608.2, -326.0, 226.1);
	machine_angles = (0, 90, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "zombie_vending_nuke" );
	perk.targetname = "vending_divetonuke";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_divetonuke";
	perk_trigger.script_noteworthy = "specialty_flakjacket";
	perk_trigger.script_sound = "mus_perks_phd_jingle";
	perk_trigger.script_label = "mus_perks_phd_sting";
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_deadshot()
{
	machine_origin = (-778.439, 1.64091, 226.125);
	machine_angles = (0, -180, 0);
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
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_marathon()
{
	machine_origin = (140.4, 471.4, 221.9);
	machine_angles = (0, -360, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "zombie_vending_marathon" );
	perk.targetname = "vending_marathon";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_marathon";
	perk_trigger.script_noteworthy = "specialty_longersprint";
	perk_trigger.script_sound = "mus_perks_stamin_jingle";
	perk_trigger.script_label = "mus_perks_stamin_sting";
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_martyrdom()
{
	machine_origin = (1169.64, 622.181, 56.5353);
	machine_angles = (0, -90, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "p6_zm_vending_electric_cherry" );
	perk.targetname = "vending_electriccherry";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_electriccherry";
	perk_trigger.script_noteworthy = "specialty_bulletdamage";
	perk_trigger.script_sound = "mus_perks_cherry_jingle";
	perk_trigger.script_label = "mus_perks_cherry_sting";
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_extraammo()
{
	machine_origin = (1481.5, 64.1, 61.8);
	machine_angles = (0, -180, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "p7_zm_vending_widows_wine" );
	perk.targetname = "vending_widowswine";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_widowswine";
	perk_trigger.script_noteworthy = "specialty_extraammo";
	perk_trigger.script_sound = "mus_perks_widows_jingle";
	perk_trigger.script_label = "mus_perks_widows_sting";
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_chugabud()
{
	machine_origin = (225.3, -748.5, 218.6);
	machine_angles = (0, -90, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "p6_zm_vending_chugabud" );
	perk.targetname = "vending_chugabud";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_chugabud";
	perk_trigger.script_noteworthy = "specialty_bulletaccuracy";
	perk_trigger.script_sound = "mus_perks_whoswho_jingle";
	perk_trigger.script_label = "mus_perks_whoswho_sting";
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_mulekick()
{
	machine_origin = (-91, 540, 64);
	machine_angles = (0, 90, 0);
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
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}

place_vulture()
{
	machine_origin = (640.4, 847.3, 226.1);
	machine_angles = (0, -90, 0);
	perk = Spawn( "script_model", machine_origin );
	perk.angles = machine_angles;
	perk setModel( "p6_zm_vending_vultureaid" );
	perk.targetname = "vending_vulture";
	perk_trigger = Spawn( "trigger_radius_use", machine_origin + (0 , 0, 30), 0, 20, 70 );
	perk_trigger.targetname = "zombie_vending";
	perk_trigger.target = "vending_vulture";
	perk_trigger.script_noteworthy = "specialty_altmelee";
	perk_trigger.script_sound = "mus_perks_vulture_jingle";
	perk_trigger.script_label = "mus_perks_vulture_sting";
	perk_clip = spawn( "script_model", machine_origin );
	perk_clip.angles = machine_angles;
	perk_clip SetModel( "collision_geo_64x64x256" );
	perk_clip Hide();
	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
}