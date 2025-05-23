#include maps\_utility; 
#include common_scripts\utility;

main()
{
	maps\createart\zombie_coast_art::main();
	maps\createfx\zombie_coast_fx::main();

	precache_scripted_fx();
	precache_createfx_fx();
	footsteps(); 
//	thread manage_fog();	

	thread water_settings();
	
	// DCS: resetting water burst effects special for Coast.
	level thread reset_water_burst_fx();

}

footsteps()
{
}

precache_scripted_fx()
{
	level._effect["large_ceiling_dust"]					= LoadFx( "maps/zombie/fx_dust_ceiling_impact_lg_mdbrown" );
	level._effect["poltergeist"]								= LoadFx( "misc/fx_zombie_couch_effect" );
	level._effect["gasfire"] 										= LoadFx("destructibles/fx_dest_fire_vert");
	level._effect["switch_sparks"]							= loadfx("env/electrical/fx_elec_wire_spark_burst");
	level._effect["wire_sparks_oneshot"] 				= loadfx("env/electrical/fx_elec_wire_spark_dl_oneshot");
	
	level._effect["electric_current"] 					= loadfx("misc/fx_zombie_elec_trail");
	//level._effect["zapper_fx"] 									= loadfx("misc/fx_zombie_zapper_powerbox_on");	
	//level._effect["zapper"]											= loadfx("misc/fx_zombie_electric_trap");
	//level._effect["zapper_wall"] 								= loadfx("misc/fx_zombie_zapper_wall_control_on");
	level._effect["zapper_light_ready"] 				= loadfx("misc/fx_zombie_zapper_light_green");
	level._effect["zapper_light_notready"] 			= loadfx("misc/fx_zombie_zapper_light_red");
	level._effect["elec_room_on"] 							= loadfx("fx_zombie_light_elec_room_on");
	//level._effect["elec_md"] 										= loadfx("maps/zombie/fx_elec_player_md");
	//level._effect["elec_sm"] 										= loadfx("maps/zombie/fx_elec_player_sm");
	//level._effect["elec_torso"] 								= loadfx("maps/zombie/fx_elec_player_torso");
	level._effect["elec_trail_one_shot"] 				= loadfx("misc/fx_zombie_elec_trail_oneshot");	
	
	level._effect["lght_marker"] 								= Loadfx("maps/zombie/fx_zmb_coast_weapon_box_marker");
	level._effect["lght_marker_flare"] 					= Loadfx("maps/zombie/fx_zombie_coast_marker_fl");
	level._effect["corpse_burst"]								= LoadFX("maps/zombie/fx_zombie_dog_explosion");
	level._effect["player_rain"]								= loadfx( "maps/zombie/fx_zombie_coast_snow_oneshot" );

	level._effect["buff_electrified"]			= LoadFX( "maps/zombie/fx_zmb_coast_electrified_torso" );
	
	level._effect[ "lighthouse_morse_code" ] = LoadFX( "maps/zombie/fx_zmb_coast_morse_code" );

	level._effect["waterfreeze"] = LoadFX( "maps/zombie/fx_zmb_coast_waterfreeze_lower_body" );
	
	level._effect[ "flare" ] = LoadFX( "maps/zombie/fx_zmb_coast_flare" );
	level._effect[ "flare_no_dlight" ] = LoadFX( "maps/zombie/fx_zmb_coast_flare_no_dlight" );
	
	level._effect[ "box_spark" ] = LoadFX( "maps/zombie/fx_zmb_coast_dest_fuse_box" );
	level._effect[ "rtg_field" ] = LoadFX( "maps/zombie/fx_zmb_coast_rtg_gen_glow" );
}

precache_createfx_fx()
{	
	level._effect["fx_zombie_boss_water_intro"]	        = loadfx("maps/zombie/fx_zombie_boss_water_intro");	
	level._effect["fx_zombie_boss_water_boil"]	        = loadfx("maps/zombie/fx_zombie_boss_water_boil");
	level._effect["fx_zombie_boss_water_boil_sm"]	      = loadfx("maps/zombie/fx_zombie_boss_water_boil_sm");			
	
	level._effect["fx_zmb_coast_spotlight_main"]				= loadfx("maps/zombie/fx_zmb_coast_spotlight_main");
	level._effect["fx_zmb_coast_spotlight_burst"]	      = loadfx("maps/zombie/fx_zmb_coast_spotlight_burst");
	
	level._effect["fx_fire_line_xsm"]								  	= loadfx("env/fire/fx_fire_line_xsm");
	level._effect["fx_zmb_coast_sparks_int_runner"]	    = loadfx("maps/zombie/fx_zmb_coast_sparks_int_runner");					
		
	level._effect["fx_zmb_coast_packapunch"]				    = loadfx("maps/zombie/fx_zmb_coast_packapunch");
	level._effect["fx_zmb_coast_packapunch_rising"]			= loadfx("maps/zombie/fx_zmb_coast_packapunch_rising");	
	level._effect["fx_zmb_coast_spotlight_packapunch"]  = loadfx("maps/zombie/fx_zmb_coast_spotlight_packapunch");	
	level._effect["fx_zmb_coast_spotlight_pap_202"]     = loadfx("maps/zombie/fx_zmb_coast_spotlight_pap_202");						

	level._effect["fx_zmb_coast_ray_moon_md"]						= loadfx("maps/zombie/fx_zmb_coast_ray_moon_md");
	level._effect["fx_zmb_coast_ray_moon_lg"]						= loadfx("maps/zombie/fx_zmb_coast_ray_moon_lg");
	level._effect["fx_zmb_coast_light_tinhat_cage"]			= loadfx("maps/zombie/fx_zmb_coast_light_tinhat_cage");		
	level._effect["fx_zmb_coast_light_floodlight"]			= loadfx("maps/zombie/fx_zmb_coast_light_floodlight");
	level._effect["fx_zmb_coast_perk_dlight"]			      = loadfx("maps/zombie/fx_zmb_coast_perk_dlight");	
	level._effect["fx_light_bulb_incandescent_red"]			= loadfx("env/light/fx_light_bulb_incandescent_red");
	level._effect["fx_light_bulb_incandescent"]		     	= loadfx("env/light/fx_light_bulb_incandescent");		
	level._effect["fx_zmb_coast_light_lantern"]	        = loadfx("maps/zombie/fx_zmb_coast_light_lantern");							
	
	level._effect["fx_lightning_flash_single"]	        = loadfx("env/weather/fx_lightning_flash_single");					
	
	level._effect["zombie_coast_snow_med"]							= loadfx("maps/zombie/fx_zombie_coast_snow_med");
	level._effect["fx_zmb_coast_blizzard_med"]					= loadfx("maps/zombie/fx_zmb_coast_blizzard_med");
		
	level._effect["fx_zmb_coast_snow_gust_xsm"]	        = loadfx("maps/zombie/fx_zmb_coast_snow_gust_xsm");
	level._effect["fx_zmb_coast_snow_gust_sml"]	        = loadfx("maps/zombie/fx_zmb_coast_snow_gust_sml");	
	level._effect["fx_zmb_coast_snow_gust_med"]	        = loadfx("maps/zombie/fx_zmb_coast_snow_gust_med");	
	level._effect["fx_zmb_coast_snow_gust_vertical"]	  = loadfx("maps/zombie/fx_zmb_coast_snow_gust_vertical");		
	level._effect["fx_zmb_coast_snow_window"]	          = loadfx("maps/zombie/fx_zmb_coast_snow_window");			
	level._effect["fx_zmb_coast_snowfall_entrance_lrg"]	= loadfx("maps/zombie/fx_zmb_coast_snowfall_entrance_lrg");
	level._effect["fx_zmb_coast_snowfall_ledge"]	      = loadfx("maps/zombie/fx_zmb_coast_snowfall_ledge");	
	
	level._effect["fx_zmb_coast_cloud_1"]	              = loadfx("maps/zombie/fx_zmb_coast_cloud_1");
	level._effect["fx_zmb_coast_cloud_2"]	              = loadfx("maps/zombie/fx_zmb_coast_cloud_2");
	level._effect["fx_zmb_coast_lightning_burst"]	      = loadfx("maps/zombie/fx_zmb_coast_lightning_burst");
	level._effect["fx_zmb_coast_lightning_d_light"]	    = loadfx("maps/zombie/fx_zmb_coast_lightning_d_light");		
	level._effect["fx_lightning_flash_single_md"]	      = loadfx("env/weather/fx_lightning_flash_single_md");
	level._effect["fx_zmb_coast_lightning_intro_xlg"]	  = loadfx("maps/zombie/fx_zmb_coast_lightning_intro_xlg");						
		
	level._effect["fx_zmb_coast_interior_fog"]	        = loadfx("maps/zombie/fx_zmb_coast_interior_fog");	
	level._effect["fx_zmb_coast_corridor_fog"]	        = loadfx("maps/zombie/fx_zmb_coast_corridor_fog");
	level._effect["fx_zmb_coast_offshore_fog_1"]	      = loadfx("maps/zombie/fx_zmb_coast_offshore_fog_1");
	
  // easter eggs
	level._effect["fx_zmb_coast_beam_submarine"]				= loadfx("maps/zombie/fx_zmb_coast_beam_submarine");		
	level._effect["fx_zmb_coast_beam_vert_shaft"]				= loadfx("maps/zombie/fx_zmb_coast_beam_vert_shaft");	
	level._effect["fx_zmb_coast_sacrifice_flash"]				= loadfx("maps/zombie/fx_zmb_coast_sacrifice_flash");	
	level._effect["fx_zmb_coast_vault_door_glow"]				= loadfx("maps/zombie/fx_zmb_coast_vault_door_glow");	
	level._effect["fx_zmb_coast_dest_fuse_box"]			  	= loadfx("maps/zombie/fx_zmb_coast_dest_fuse_box");														


	// auto turret
	level._effect["auto_turret_light"]      = loadfx("maps/zombie/fx_zombie_auto_turret_light");

	// riser effects in snow
	level._effect["rise_burst_snow"]        = loadfx("maps/zombie/fx_mp_zombie_hand_snow_burst");
	level._effect["rise_billow_snow"]       = loadfx("maps/zombie/fx_mp_zombie_body_snow_billowing");
	level._effect["rise_dust_snow"]					= LoadFX("maps/zombie/fx_mp_zombie_body_snow_falling");	
	
	// NEW riser effects in water
	level._effect["rise_burst_water"]			  = LoadFX("maps/zombie/fx_mp_zombie_hand_water_burst");
	level._effect["rise_billow_water"]			= LoadFX("maps/zombie/fx_mp_zombie_body_water_billowing");	
	
}

reset_water_burst_fx()
{
	wait(2.0);
		
	// NEW riser effects in water
	level._effect["rise_burst_water"]			= LoadFX("maps/zombie/fx_mp_zombie_hand_water_burst");
	level._effect["rise_billow_water"]			= LoadFX("maps/zombie/fx_mp_zombie_body_water_billowing");
}	
	
manage_fog()
{
	setVolFog( 110, 2016, 621, 674, 0.572, 0.672, 0.678, 0 );
	wait( 1 );

	while ( 1 )
	{
		exploder( 1001 );
		wait( 30 );

		exploder( 1002 );
		wait( 30 );

		exploder( 1003 );
		wait( 30 );
	}
}
//------------------------------------------------------------------------------
//The blizzard exploder ID number is #101. Currently the exploder effects are 10 seconds long. 
//Lets start off with the blizzard lasting for 120 seconds (spawning exploder consecutively 12 times), 
//with 180 seconds dead time between the end of the blizzard and the start of the next one. 
//------------------------------------------------------------------------------
manage_blizzard()
{
	level endon("kill_blizzard");	// will only be sent if we're in the intro_anim state - or using a levelnotify from Rex.
	level thread blizzard_tidyup();

	if( flag( "power_on" ) )
	{
		return;
	}
	
	flag_wait("all_players_connected");
	
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{	
		players[i] SetClientFlag(level._COAST_FOG_BLIZZARD);			
	}
  	snd_ent = Spawn( "script_origin", (0,0,0) );
	snd_ent PlayLoopSound( "amb_blizzard_heavy_loop", 4 );

	flag_wait("all_players_spawned");
	wait(1);

	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{	
		players[i] ClearClientFlag(level._COAST_FOG_BLIZZARD);			
	}
	snd_ent thread wait_and_delete_sound_ent();
	
	wait(8);
	
	sound_ent = undefined;
	blizzard_time = 0;
	while ( true )
	{
		if(blizzard_time < 12)
		{
			if(blizzard_time == 0)
			{
				//level thread coast_fog_blizzard();
				level clientnotify ("FI");
				players = get_players();
				for ( i = 0; i < players.size; i++ )
				{	
					players[i] SetClientFlag(level._COAST_FOG_BLIZZARD);			
				}
				
				rand = RandomIntRange(0,players.size);
				players[rand] thread maps\_zombiemode_audio::create_and_play_dialog( "general", "weather_bad" );
			}	
			
			//AUDIO
			if( !IsDefined( sound_ent ) )
			{
			    sound_ent = Spawn( "script_origin", (0,0,0) );
			}
			
			sound_ent PlayLoopSound( "amb_blizzard_heavy_loop", 4 );
						
			exploder( 101 );
			wait( 5 );
			exploder( 102 );
			wait( 5 );
			blizzard_time++;
			
			//IPrintLnBold("play blizzard fx");
		}
		else
		{
			//IPrintLnBold("stop blizzard fx");
			blizzard_time = 0;
			level clientnotify ("FO");
			//level thread coast_fog_clear();
			players = get_players();
			for ( i = 0; i < players.size; i++ )
			{	
				
				players[i] ClearClientFlag(level._COAST_FOG_BLIZZARD);			
			}
			
			rand = RandomIntRange(0,players.size);
				players[rand] thread maps\_zombiemode_audio::create_and_play_dialog( "general", "weather_good" );
			
			if( IsDefined( sound_ent ) )
			{
			    sound_ent thread wait_and_delete_sound_ent();
			}

			exploder( 110 );

			//Reimagined-Expanded, no blizzard with power on
			if( flag( "power_on" ) )
			{
				return;
			}

			wait(180);
		}		
		

	}
}

// Used when killing blizzard FX for screen-shotting.

blizzard_tidyup()
{
	level waittill("kill_blizzard");	// will only be sent if we're in the intro_anim state.

	stop_exploder(101);
	stop_exploder(102);

	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{	
		players[i] ClearClientFlag(level._COAST_FOG_BLIZZARD);			
	}
}

wait_and_delete_sound_ent()
{
    self StopLoopSound( 4 );
    wait(5);
    self Delete();
}

//------------------------------------------------------------------------------
// from mak script, needs to clientside dynamic water.
water_settings()
{
	/* Water Dvars				Default Values		What They Do
	 ====================================================================== 
	r_watersim_enabled			default = true		Enables dynamic water simulation
	r_watersim_debug			default = false		Enables bullet debug markers
	r_watersim_flatten			default = false		Flattens the water surface out
	r_watersim_waveSeedDelay	default = 500.0		Time between seeding a new wave( ms )
	r_watersim_curlAmount		default = 0.5		Amount of curl applied
	r_watersim_curlMax			default = 0.4		Maximum curl limit
	r_watersim_curlReduce		default = 0.95		Amount curl gets reduced by when over limit
	r_watersim_minShoreHeight	default = 0.04		Allows water to lap over the shoreline edge
	r_watersim_foamAppear		default = 20.0		Rate foam appears at
	r_watersim_foamDisappear	default = 0.78		Rate foam disappears at
	r_watersim_windAmount 		default = 0.02		Amount of wind applied
	r_watersim_windDir			default = 45.0		Wind direction( degrees )
	r_watersim_windMax			default = 0.4 		Maximum wind limit
	r_watersim_particleGravity	default = 0.03		Particle gravity
	r_watersim_particleLimit	default = 2.5		Limit at which particles get spawned
	r_watersim_particleLength	default = 0.03		Length of each particle
	r_watersim_particleWidth	default = 2.0		Width of each particle
	*/
	
	SetDvar( "r_watersim_waveSeedDelay", 10 );
	SetDvar( "r_watersim_curlAmount", 0.18 );
	SetDvar( "r_watersim_curlMax", 0.32 );
	SetDvar( "r_watersim_curlReduce", 0.261 );
	SetDvar( "r_watersim_minShoreHeight", 0.358 );
	SetDvar( "r_watersim_foamAppear", 3.01 );
	SetDvar( "r_watersim_foamDisappear", 0.40 );
	SetDvar( "r_watersim_windAmount", 0.179 );
	SetDvar( "r_watersim_windDir", 275 );
	SetDvar( "r_watersim_windMax", 2.69 );
	SetDvar( "r_watersim_particleGravity", 0.03 );
	SetDvar( "r_watersim_particleLimit", 2.5 );
	SetDvar( "r_watersim_particleLength", 0.03 );
	SetDvar( "r_watersim_particleWidth", 2.0 );	      
	
	waittillframeend; 
	WaterSimEnable( true ); 	
}

