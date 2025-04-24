#include clientscripts\_utility;
#include clientscripts\_music;
#include clientscripts\_zombiemode_weapons;

main()
{
	level._uses_crossbow = true;
	level._power_on = false;
	level.rocket_num = 0;
	
	// define the on and off vision set priorities
	level._visionset_map_nopower = "zombie_cosmodrome_nopower"; // cheat_bw
	level._visionset_priority_map_nopower = 1;
	
	level._visionset_map_sudden_power = "zombie_cosmodrome_powerUP"; // the vision set as the power turns on
	level._visionset_priority_map_sudden_power = 2;
	
	level._visionset_map_poweron = "zombie_cosmodrome_powerON"; // the power is on and the player's eyes are adjusted
	level._visionset_priority_map_poweron = 3;

	level._visionset_map_monkey = "zombie_cosmodrome_monkey";
	level._visionset_priority_map_monkey = 4;
	
	level._visionset_map_begin = "zombie_cosmodrome_begin";
	level._visionset_priority_map_begin = 5;

	level._visionset_map_monkeylandon = "flare";
	level._visionset_priority_map_monkeylandon = 6;
	level._visionset_monkey_transition_time_on = 0.5; 
	level._visionset_monkey_transition_time_off = 3.0; 
	
	level._visionset_zombie_sudden_power_transition_time = 0.1;
	level._visionset_zombie_transition_time = 2.5; // how much time it takes for the vision set to apply
	
	//fog values & priorites
	level._fog_settings_monkey = "monkey";
	level._fog_settings_monkey_priority = 3;
	
	level._fog_settings_lander = "lander";
	level._fog_settings_lander_priority = 2;	
	
	level._fog_settings_default = "normal";
	level._fog_settings_default_priority = 1;	
	
	
	// setup weapons 	
	include_weapons();
	
	// rumble for centrifuge
	PreCacheRumble( "damage_heavy" );
	PrecacheRumble( "explosion_generic" );
	
	// _load!
	clientscripts\_zombiemode::main();

	// This needs to come after the call to _load::main (which is called in _zombiemode)
	register_clientflag_callback("actor", 0, ::actor_flag_soulpull_handler);
	register_clientflag_callback("scriptmover", 0, ::rocket_fx);
	register_clientflag_callback("scriptmover", 1, ::lander_engine_fx);
	register_clientflag_callback("scriptmover", 2, ::lander_status_light);
	
	register_clientflag_callback("scriptmover", 3, ::launch_panel_centrifuge_status);
	register_clientflag_callback("scriptmover", 4, ::launch_panel_baseentry_status);
	register_clientflag_callback("scriptmover", 5, ::launch_panel_storage_status);
	register_clientflag_callback("scriptmover", 6, ::launch_panel_catwalk_status);
	register_clientflag_callback("scriptmover", 7, ::lander_rumble_and_quake);
	
	level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_RUMBLE = 8;
	register_clientflag_callback( "scriptmover", level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_RUMBLE, ::centrifuge_rumble_control );
	
	register_clientflag_callback("scriptmover", 9, ::lander_move_fx);
	register_clientflag_callback("player", 0 , ::player_lander_fog);
	
	// number ten is being used by the black hole bomb
	level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_LIGHTS = 11;
	register_clientflag_callback( "scriptmover", level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_LIGHTS, ::centrifuge_warning_lights_init );
	
	level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_MONKEY_LANDER_FX = 12;
	register_clientflag_callback( "scriptmover", level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_MONKEY_LANDER_FX, ::monkey_lander_fx );
	
	
	//handles the lander docking doors ( movement & light FX )
	level thread catwalk_lander_doors();
	level thread base_entry_lander_doors();
	level thread storage_lander_doors();
	level thread centrifuge_lander_doors();
	
	//the lander station screens
	level thread lander_station_think();
	
	//the fog monitor
	level thread setup_fog();
	
	//when rocket blows up
	level thread init_rocket_debris();
	
	// black hole bomb
	clientscripts\_zombiemode_weap_black_hole_bomb::init();

	clientscripts\zombie_cosmodrome_fx::main();
	thread clientscripts\zombie_cosmodrome_amb::main();
	
	clientscripts\_zombiemode_deathcard::init();

	// Setup the magic box screens	
	level init_cosmodrome_box_screens();
	
	// on player connect
	OnPlayerConnect_Callback( ::cosmo_on_player_connect );
	
	// on player spawn run this function
	OnPlayerSpawned_Callback( ::cosmo_on_player_spawned );
	
	// This needs to be called after all systems have been registered.
	waitforclient(0);

	level thread cosmodrome_ZPO_listener();

	level thread cosmodrome_monkey_round_start_listener();

	register_zombie_types();

	//level thread vista_rockets();
	//level thread migs_fly_by();
	level thread radar_dish_init();

	players = GetLocalPlayers();
	for ( i=0; i<players.size; i++ )
	{
		level thread nml_fx_monitor( i );	
	}

	level.nml_spark_pull = GetStruct( "nml_spark_pull", "targetname" );

	level thread monkey_start_monitor();
	level thread monkey_stop_monitor();

	level thread monkey_land_on();
	level thread monkey_land_off();
	
	level thread cosmodrome_power_vision_set_swap();
	//level.map_visionset_function = ::cosmodrome_custom_visionset_func;
}

cosmodrome_monkey_round_start_listener()
{
	while(1)
	{
		level waittill("MRS");
		
		//sonic boom earthquake
		players = getlocalplayers();
		for ( i = 0; i < players.size; i++ )
		{
			players[i] Earthquake( 0.2, 5.0, players[i].origin, 20000 );
		}
		
		PlaySound( 0, "zmb_ape_intro_sonicboom_fnt", (0,0,0) );		
		
	}
}

//------------------------------------------------------------------------------
cosmodrome_ZPO_listener()
{
	while(1)
	{
		level waittill("ZPO");	// Zombie power on.
		level._power_on = true;

		players = GetLocalPlayers();
		for ( i=0; i<players.size; i++ )
		{
			level thread setup_lander_screens( i );
		}		
	}
}

//------------------------------------------------------------------------------
register_zombie_types()
{
	//character\clientscripts\c_usa_pent_zombie_officeworker::register_gibs();
	character\clientscripts\c_zom_cosmo_scientist::register_gibs();
	character\clientscripts\c_zom_cosmo_spetznaz::register_gibs();
	character\clientscripts\c_zom_cosmo_cosmonaut::register_gibs();

}

//------------------------------------------------------------------------------
include_weapons()
{
	include_weapon( "frag_grenade_zm", false );
	include_weapon( "claymore_zm", false );

	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm" );						// 357
	include_weapon( "python_upgraded_zm", false );
  	include_weapon( "cz75_zm" );
  	include_weapon( "cz75_upgraded_zm", false );

	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false );							// gewehr43
	include_weapon( "m14_upgraded_zm", false );

	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false );						
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );

	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false );						// thompson, mp40, bar
	include_weapon( "ak74u_upgraded_zm", false );
	include_weapon( "mp5k_zm", false );
	include_weapon( "mp5k_upgraded_zm", false );
	include_weapon( "mp40_zm", false );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "mpl_zm", false );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );

	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );

	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false );
	include_weapon( "rottweil72_upgraded_zm", false );
	include_weapon( "spas_zm" );						// 
	include_weapon( "spas_upgraded_zm", false );
	include_weapon( "hs10_zm" );
	include_weapon( "hs10_upgraded_zm", false );

	//	Weapons - Assault Rifles
	include_weapon( "aug_acog_zm" );
	include_weapon( "aug_acog_mk_upgraded_zm", false );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", false );
	include_weapon( "commando_zm" );
	include_weapon( "commando_upgraded_zm", false );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", false );

	//	Weapons - Sniper Rifles
	include_weapon( "dragunov_zm" );					// ptrs41
	include_weapon( "dragunov_upgraded_zm", false );
	include_weapon( "l96a1_zm" );
	include_weapon( "l96a1_upgraded_zm", false );

	//	Weapons - Machineguns
	include_weapon( "rpk_zm" );							// mg42, 30 cal, ppsh
	include_weapon( "rpk_upgraded_zm", false );
	include_weapon( "hk21_zm" );
	include_weapon( "hk21_upgraded_zm", false );

	//	Weapons - Misc
	include_weapon( "m72_law_zm" );
	include_weapon( "m72_law_upgraded_zm", false );
	include_weapon( "china_lake_zm" );
	include_weapon( "china_lake_upgraded_zm", false );

	//	Weapons - Special
	include_weapon( "zombie_black_hole_bomb" );
	include_weapon( "zombie_nesting_dolls" );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "thundergun_zm" );
	include_weapon( "thundergun_upgraded_zm", false );
	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );

	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );
}

//------------------------------------------------------------------------------
vista_rockets()
{
	
	all_rockets = getentarray(0,"vista_rocket","targetname");
	rockets = array_randomize(all_rockets);
	for(i=0;i<rockets.size;i++)
	{	
		level thread rocket_launch(rockets[i]);
		wait(randomintrange(60,300)); // between 1 and 5 minutes
	}
}

//------------------------------------------------------------------------------
rocket_launch(rocket)
{
	
	wait(.1);

	//playfx(0,level._effect["rocket_linger"],rocket.origin);
	//playfxontag(0,level._effect["rocket_blast"],rocket,"tag_engine01");
	//playfxontag(0,level._effect["rocket_blast"],rocket,"tag_engine02");
	//playfxontag(0,level._effect["rocket_blast"],rocket,"tag_engine03");
	//playfxontag(0,level._effect["rocket_blast"],rocket,"tag_engine04");

	
	rocket moveto(rocket.origin + (0,0,50000),50,45);	
	rocket waittill("movedone");
	rocket delete();	

}

//------------------------------------------------------------------------------
closest_point_on_line_to_point( Point, LineStart, LineEnd )
{
	
	LineMagSqrd = lengthsquared(LineEnd - LineStart);
 
    t =	( ( ( Point[0] - LineStart[0] ) * ( LineEnd[0] - LineStart[0] ) ) +
				( ( Point[1] - LineStart[1] ) * ( LineEnd[1] - LineStart[1] ) ) +
				( ( Point[2] - LineStart[2] ) * ( LineEnd[2] - LineStart[2] ) ) ) /
				( LineMagSqrd );
 
  if( t < 0.0  )
	{
		return LineStart;
	}
	else if( t > 1.0 )
	{
		return LineEnd;
	}
	else
	{
		start_x = LineStart[0] + t * ( LineEnd[0] - LineStart[0] );
		start_y = LineStart[1] + t * ( LineEnd[1] - LineStart[1] );
		start_z = LineStart[2] + t * ( LineEnd[2] - LineStart[2] );
		
		return (start_x,start_y,start_z);
	}
}


plane_position_updater (fake_ent, plane)
{
	//length of sound file to fly overhead in ms
	apex = 5000;
	
	soundid = -1;
	dx = undefined;
	last_time = undefined;
	last_pos = undefined;
	start_time = 0;
	
	while(IsDefined(plane))
	{
		setfakeentorg(0, fake_ent, plane.origin);
		
		if((soundid < 0) && isdefined(last_pos))
		{
			dx = plane.origin - last_pos;
			
			if(length(dx) > .01)
			{
				velocity = dx / (getrealtime()-last_time);
				assert(isdefined(velocity));
				players = getlocalplayers();
				assert(isdefined(players));
				other_point = plane.origin + (velocity * 100000);
				player_origin = players[0] GetOrigin();
				if( !isDefined( player_origin ) )
				{
					continue;
				}
				point = closest_point_on_line_to_point(player_origin, plane.origin, other_point );
				assert(isdefined(point));
				dist = Distance( point, plane.origin );	
				assert(isdefined(dist));
				time = dist / length(velocity);
				assert(isdefined(time));
				
				if(time < apex)
				{
					soundid = playloopsound(0, fake_ent, "veh_mig_flyby", 0 );				
					playsound (0, "veh_mig_flyby_lfe", (0,0,0));
					start_time = getRealTime();
				}
				
			//	println("vel:"+velocity+" pnt:"+point+" dst:"+dist+" t:"+time+"\n");
			}
	
		}
		
		last_pos = plane.origin;
		last_time = GetRealTime();
		

		if(start_time != 0)
		{
			//iprintlnbold("time: "+((GetRealTime()-start_time)/1000)+"\n");		
		}

					
		wait(0.1);		
		
	}
	deletefakeent(0, fake_ent);

}
migs_fly_by()
{
	
	points = getstructarray("spawn_flyby","targetname");
	
	while(1)
	{
		point = random(points);
		planes = [];
		fake_ent_planes = [];	
		
		planes[0] = spawn(0,point.origin,"script_origin");
		planes[0] setmodel("t5_veh_jet_mig17");
		planes[0].angles = point.angles;
		
		fake_ent_planes[0] = spawnfakeent( 0 );
		
		wait(.1);
		
		if(randomint(100) > 50 )
		{
			planes[1] =  spawn(0,point.origin + ( -1100,0,0),"script_origin");
			planes[1].angles = point.angles; 
			planes[1] setmodel("t5_veh_jet_mig17");
			fake_ent_planes[1] = spawnfakeent( 0 );
			wait(.1);
			if(randomint(100) > 50 )
			{
				planes[2] =  spawn(0,point.origin + ( 1100,0,0),"script_origin");
				planes[2].angles = point.angles; 
				planes[2] setmodel("t5_veh_jet_mig17");
				fake_ent_planes[2] = spawnfakeent( 0 );
				wait(.1);
			}
		}	
		
	
		
		for(i=0;i<planes.size;i++)
		{		
			playfxontag(0,level._effect["mig_trail"],planes[i],"tag_engine");	
			
			planes[i] rotateto(point.angles,.05);	
			forward = anglestoforward (point.angles);
			moveto_spot = vector_scale_2d(forward,50000);
			planes[i] moveto( moveto_spot,20);
			

				
			if(planes.size > 2 && i == 0)
			{
				wait(.35);
			}
		}
		playsound (0, "veh_mig_flyby_2d", (0,0,0));
		for(i=0;i<fake_ent_planes.size;i++)
		{
			
			//TEMP play the sound mang
			//playloopsound(0, fake_ent_planes[i], "mig_flyby", 1 );			
			thread plane_position_updater (fake_ent_planes[i], planes[i]);
		}
		
		planes[0] waittill("movedone");
		
		
		for(i=0;i<planes.size;i++)
		{
			planes[i] delete();
		}
	
		wait(randomintrange(60, 180));
	}	
	
}

vector_scale_2d(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] );
	return vec;
}

//*****************************************************************************
// rotating background radar dishes (need to clientside)
//*****************************************************************************
radar_dish_init()
{
	radar_dish = GetEntArray(0, "zombie_cosmodrome_radar_dish", "targetname");
	if(IsDefined(radar_dish))
	{
		for ( i = 0; i < radar_dish.size; i++ )
		{
			radar_dish[i] thread radar_dish_rotate();
		}	
	}
}	

radar_dish_rotate()
{
	wait(0.1);
	
	while(true)
	{
		self rotateyaw( 360, 10 );
		self waittill("rotatedone");
	}	
}

/* no mans land */
//
nml_electric_barriers( client_num )
{
	level endon("nm0");

	while (1)
	{
		// Create buildup
		buildup_spots = GetStructArray( "nml_build_sparks", "targetname" );
		for( i=0; i< buildup_spots.size; i++ )
		{
			level waittill( "eb+" );	// activate another electric barrier

			angles = (0, 0, 0);
			if ( IsDefined( buildup_spots[i].angles ) )
			{
				angles = buildup_spots[i].angles;
			}
			buildup_spots[i].fx = SpawnFx( client_num, level._effect[ "zombie_power_switch" ], buildup_spots[i].origin, 0, AnglesToForward(angles), AnglesToUp(angles) );
			triggerfx( buildup_spots[i].fx );
		}

		level waittill( "eb1" );

		// Start sending FX over
		for( i=0; i<buildup_spots.size; i++ )
		{
			if ( IsDefined( buildup_spots[i].target ) )
			{
				buildup_spots[i] thread perk_wire_fx_client( client_num, "wire_fx_done" );
			}
		}
		wait( 0.5 );

		// Start sending FX over
		for( i=0; i<buildup_spots.size; i++ )
		{
			if ( IsDefined( buildup_spots[i].target ) )
			{
				buildup_spots[i] thread perk_wire_fx_client( client_num, "wire_fx_done" );
			}
		}
		wait( 0.5 );

		// Kill the buildup sparks and send them off!
		for( i=0; i<buildup_spots.size; i++ )
		{
			if ( IsDefined( buildup_spots[i].fx ) )
			{
				buildup_spots[i].fx Delete();
				if ( IsDefined( buildup_spots[i].target ) )
				{
					buildup_spots[i] thread perk_wire_fx_client( client_num, "wire_fx_done" );
				}
			}
		}

//		level waittill( "wire_fx_done" );

		// Create the trap sparks
		trap_spots = GetStructArray( "nml_trap_sparks", "targetname" );
		for( i=0; i<trap_spots.size; i++ )
		{
			angles = (0, 0, 0);
			if ( IsDefined( trap_spots[i].angles ) )
			{
				angles = trap_spots[i].angles;
			}
			trap_spots[i].fx = SpawnFx( client_num, level._effect[ "elec_terminal" ], trap_spots[i].origin, 0, AnglesToForward(angles), AnglesToUp(angles) );
			triggerfx( trap_spots[i].fx );
		}

		level waittill( "eb0" );

		// Kill the trap sparks
		for( i=0; i<trap_spots.size; i++ )
		{
			if ( IsDefined(trap_spots[i].fx) )
			{
				trap_spots[i].fx Delete();
			}
		}
	}
}


//
//	Keep running the nml thread
nml_fx_monitor( client_num )
{
	while (1)
	{
		level thread nml_electric_barriers( client_num );

		level waittill("nm0");

		buildup_spots = GetStructArray( "nml_build_sparks", "targetname" );
		// Kill the buildup sparks and send them off!
		for( i=0; i<buildup_spots.size; i++ )
		{
			if ( IsDefined( buildup_spots[i].fx ) )
			{
				buildup_spots[i].fx Delete();
			}
		}

		// Kill the trap sparks
		trap_spots = GetStructArray( "nml_trap_sparks", "targetname" );
		for( i=0; i<trap_spots.size; i++ )
		{
			if ( IsDefined(trap_spots[i].fx) )
			{
				trap_spots[i].fx Delete();
			}
		}
	}
}


// modified this func from factory
//	Causes an electric spark to move along a line of structs
perk_wire_fx_client( client_num, done_notify )
{
	println( "perk_wire_fx_client for client #"+client_num );
	targ = GetStruct(self.target, "targetname");
	if ( !IsDefined( targ ) )
	{
		return;
	}
	
	mover = Spawn( client_num, targ.origin, "script_model" );
	mover SetModel( "tag_origin" );	
	fx = PlayFxOnTag( client_num, level._effect["wire_spark"], mover, "tag_origin" );
	
	// If you uncomment this, uncomment the part below that deletes the fake_ent
//	fake_ent = spawnfakeent(0);
//	setfakeentorg(0, fake_ent, mover.origin);
// 	playsound( 0, "tele_spark_hit", mover.origin );
// 	playloopsound( 0, fake_ent, "tele_spark_loop");
//	mover thread tele_spark_audio_mover(fake_ent);

	while(isDefined(targ))
	{
		if(isDefined(targ.target))
		{
			println( "perk_wire_fx_client#"+client_num+" next target: "+targ.target );
			target = getstruct(targ.target,"targetname");
			
			mover MoveTo( target.origin, 0.5 );
			wait( 0.5 );

			targ = target;
		}
		else
		{
			break;
		}		
	}
	level notify( "spark_done" );
	mover Delete();
//	deletefakeent(0,fake_ent);

	// Spark travel complete
	level notify( done_notify );
}

tele_spark_audio_mover(fake_ent)
{
	level endon( "spark_done" );

	while (1)
	{
		realwait(0.05);
		setfakeentorg(0, fake_ent, self.origin);
	}
}


//
//	Needed to activate a client
actor_flag_soulpull_handler( client_num, set, newEnt )
{
	if ( set )
	{
		self thread soul_pull( client_num );
	}
}

//
//	Spawn a particle and float to the device
//		self will be a dead zombie
soul_pull( client_num )
{
	println("*** ACTOR soul_pull .  pos="+self.origin+" ;  to "+level.nml_spark_pull.origin );
	mover = Spawn( client_num, self.origin, "script_model" );
	mover SetModel( "tag_origin" );	
//	fx = PlayFxOnTag( client_num, level._effect["wire_spark"], mover, "tag_origin" );
	fx = PlayFxOnTag( client_num, level._effect["soul_spark"], mover, "tag_origin" );

	// If you uncomment this, uncomment the part below that deletes the fake_ent
//	fake_ent = spawnfakeent(0);
//	setfakeentorg(0, fake_ent, mover.origin);
// 	playsound( 0, "tele_spark_hit", mover.origin );
// 	playloopsound( 0, fake_ent, "tele_spark_loop");
//	mover thread tele_spark_audio_mover(fake_ent);
	wait( 1.0 );

	mover MoveTo( level.nml_spark_pull.origin, 3.0 );
	wait( 3.0 );
//	mover waittill( "movedone" );
	mover Delete();
//	deletefakeent(0,fake_ent);

}

//------------------------------------------------------------------------------
// Cosmodrome video tracking for the magic box
// Originally developed for cosmodrome by Walter Williams.
//------------------------------------------------------------------------------
init_cosmodrome_box_screens()
{
	// logic is written to deal with arrays!
	level._cosmodrome_fire_sale = array( "p_zom_monitor_csm_screen_fsale1", "p_zom_monitor_csm_screen_fsale2" );
	level.magic_box_tv_off = array( "p_zom_monitor_csm_screen_off" );
	level.magic_box_tv_on = array( "p_zom_monitor_csm_screen_on" );
	
	level.magic_box_tv_start_1 = array( "p_zom_monitor_csm_screen_obsdeck" );
	level.magic_box_tv_roof_connector = array( "p_zom_monitor_csm_screen_labs" );
	level.magic_box_tv_centrifuge = array( "p_zom_monitor_csm_screen_centrifuge" );
	level.magic_box_tv_base_entry = array( "p_zom_monitor_csm_screen_enter" );
	level.magic_box_tv_storage = array( "p_zom_monitor_csm_screen_storage" );
	level.magic_box_tv_catwalks = array( "p_zom_monitor_csm_screen_catwalk" );
	level.magic_box_tv_north_pass = array( "p_zom_monitor_csm_screen_topack" );
	level.magic_box_tv_warehouse = array( "p_zom_monitor_csm_screen_warehouse"  );

	level.magic_box_tv_random = array( "p_zom_monitor_csm_screen_logo" );	
	
	level._box_locations = array(	level.magic_box_tv_start_1, //"start_chest" power building roof - 0
																level.magic_box_tv_roof_connector, //"chest1" roof_connector_zone - 1
																level.magic_box_tv_centrifuge, //"chest2" centrifuge room - 2
																level.magic_box_tv_base_entry, //"base_entry_chest" - 3
																level.magic_box_tv_storage, //"storage_area_chest" - 4
																level.magic_box_tv_catwalks, //"chest5" catwalks - 5
																level.magic_box_tv_north_pass, //"chest6" north pass to pack - 6
																level.magic_box_tv_warehouse ); //"warehouse_lander_chest" - 7
					
	level._custom_box_monitor = ::cosmodrome_screen_switch;															
}
cosmodrome_screen_switch( client_num, state, oldState )
{
	cosmodrome_tv_init( client_num );

	if( state == "n" ) // "n" can mean no power or undefined spot
	{
		if( level._power_on == false )
		{
			screen_to_display = level.magic_box_tv_off;
		}
		else
		{
			screen_to_display = level.magic_box_tv_on;
		}
	}
	else if( state == "f" ) // a state of "f" means "fire_sale"
	{
		screen_to_display = level._cosmodrome_fire_sale;
	}
	else // the state was a number that matches a spot in level._box_locations
	{
		// client info is sent as a string, this is a number i need
		array_number = Int( state );

		// which spot in the array is the box? this string matches the fx to play
		screen_to_display = level._box_locations[ array_number ];
	}
	
	stop_notify = "stop_tv_swap";


	// play the correct fx on each screen
	for( i = 0; i < level.cosmodrome_tvs[client_num].size; i++ )
	{
		tele = level.cosmodrome_tvs[client_num][i];		
		tele notify( stop_notify );
		wait( 0.2 );
		tele thread magic_box_screen_swap( screen_to_display, "stop_tv_swap" ); 
		tele thread play_magic_box_tv_audio( state );
	}

}
cosmodrome_tv_init( client_num )
{
	if ( !isdefined( level.cosmodrome_tvs ) )
	{
		level.cosmodrome_tvs = [];
	}

	if ( isdefined( level.cosmodrome_tvs[client_num] ) )
	{
		return;
	}

	level.cosmodrome_tvs[client_num] = GetEntArray( client_num, "model_cosmodrome_box_screens", "targetname" );

	// set up tag origin models to play the fx off of
	for( i = 0; i < level.cosmodrome_tvs[client_num].size; i++ )
	{
		tele = level.cosmodrome_tvs[client_num][i];
		
		tele SetModel( level.magic_box_tv_off[0] );
		
		wait( 0.1 );
	}
}
// changes the model (self) through the array of models passed in
// this will also check to see if level.magic_box_tv_random is defined and throw in a surprise
magic_box_screen_swap( model_array, endon_notify )
{
	self endon( endon_notify );
	
	while( true )
	{
		for( i = 0; i < model_array.size; i++ )
		{
			self SetModel( model_array[i] );
			wait( 3.0 );
		}
		
		if( 3 > RandomInt( 100 ) && IsDefined( level.magic_box_tv_random ) )
		{
			self SetModel( level.magic_box_tv_random[ RandomInt( level.magic_box_tv_random.size ) ] );
			wait( 2.0 );
		}
		
		wait( 1.0 );
	}
	
}
play_magic_box_tv_audio( state )
{
    alias = "amb_tv_static";
    
    if( state == "n" )
	{
		if( level._power_on == false )
		{
		    alias = undefined;
		}
		else
		{
		    alias = "amb_tv_static";
		}
	}
	else if( state == "f" )
	{
	    alias = "mus_fire_sale";
	}
	else
	{
	    alias = "amb_tv_static";
	}
	
	if( !IsDefined(alias) )
	{
	    self stoploopsound( .5 );
	}
	else
	{
	    self PlayLoopSound( alias, .5 );
	}
}

//
// Pulls the fog in
monkey_start_monitor()
{
	while( 1 )
	{
		level waittill( "monkey_start" );

//		start_dist = 497.452;
//		half_dist = 302.622;
//		half_height = 306.395;
//		base_height = 344.622;
//		fog_r = 0.74902;
//		fog_g = 0.223529;
//		fog_b = 0.113725;
//		fog_scale = 1.81002;
//		sun_col_r = 0.243137;
//		sun_col_g = 0.270588;
//		sun_col_b = 0.270588;
//		sun_dir_x = 0.291692;
//		sun_dir_y = -0.720765;
//		sun_dir_z = 0.628819;
//		sun_start_ang = 0;
//		sun_stop_ang = 0;
//		time = 0;
//		max_fog_opacity = 0.65;
//
//		setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
//			sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
//			sun_stop_ang, time, max_fog_opacity);
		
		players = GetLocalPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_monkey, level._visionset_priority_map_monkey );
			players[i] fog_apply( "monkey",level._fog_settings_monkey_priority );
		}

		level._effect["eye_glow"] = level._effect["monkey_eye_glow"];
	}
}


//
// Pushes fog out
monkey_stop_monitor()
{
	while( 1 )
	{
		level waittill( "monkey_stop" );

//		start_dist = 0;
//		half_dist = 195.739;
//		half_height = 442.001;
//		base_height = -925;
//		fog_r = 0.45098;
//		fog_g = 0.588235;
//		fog_b = 0.564706;
//		fog_scale = 1;
//		sun_col_r = 0.686275;
//		sun_col_g = 0.752941;
//		sun_col_b = 0.847059;
//		sun_dir_x = -0.634962;
//		sun_dir_y = 0.543349;
//		sun_dir_z = 0.549177;
//		sun_start_ang = 14.832;
//		sun_stop_ang = 60.0278;
//		time = 7;
//		max_fog_opacity = 1;  
//
//		setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
//			sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
//			sun_stop_ang, time, max_fog_opacity);

		players = GetLocalPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] clientscripts\_zombiemode::zombie_vision_set_remove( level._visionset_map_monkey );
			players[i] fog_remove( "monkey" );
		}

		level._effect["eye_glow"] = level._effect["zombie_eye_glow"];
	}
}

// monkey vision set changes
monkey_land_on()
{
	while ( 1 )
	{
		level waittill( "MLO" );

		players = GetLocalPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_monkeylandon, level._visionset_priority_map_monkeylandon, level._visionset_monkey_transition_time_on );
		}

		wait( 0.05 );
	}
}

monkey_land_off()
{
	while ( 1 )
	{
		level waittill( "MLF" );

		players = GetLocalPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] clientscripts\_zombiemode::zombie_vision_set_remove( level._visionset_map_monkeylandon, level._visionset_monkey_transition_time_off );
		}

		wait( 0.05 );
	}
}

// ww: things that need to be set when the level starts clean
cosmo_on_player_connect( int_local_client_num )
{
	// when starting from a fresh start the player connects but doesn't spawn
	self endon( "disconnect" );
	
	while( !ClientHasSnapshot( int_local_client_num ) )
	{
		wait( 0.05 );
	}
	
	// only client 0 works on this part
	if( int_local_client_num != 0 )
	{
		return;
	}
	
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		// players[i] cosmodrome_vision_set( i );
		// WW (01/12/11): The color should be on at first then fade away as the players lower in to the centrifuge room. Both transition times
		// are set to zero at first because they need to be set. The remove has the actual time it will take between the transitions
		players[i] thread cosmodrome_first_vision_set( i );
	}
	
}

// ww: anything that needs to be run on players when they start the level should go here
cosmo_on_player_spawned( int_local_client_num )
{
	self endon( "disconnect" );

	// Wait until we've got the whole picture
	while ( !self hasdobj( int_local_client_num ) )
	{
		wait( 0.05 );
	}
	
	if( int_local_client_num != 0 )
	{
		return;
	}
	
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] cosmodrome_vision_set( i );
		players[i] fog_apply( "normal", level._fog_settings_default_priority );
	}	
		
}

cosmodrome_first_vision_set( int_client_num )
{
	self endon( "disconnect" );

	self clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_begin, level._visionset_priority_map_begin, 0.1, int_client_num );
	self clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_nopower, level._visionset_priority_map_nopower, 0.1, int_client_num );

	level waittill( "ZID" ); // notify client -- "Zombie Introscreen Done"
	
	self clientscripts\_zombiemode::zombie_vision_set_remove( level._visionset_map_begin, 8.5, int_client_num );
}

cosmodrome_vision_set( int_client_num )
{
	self endon( "disconnect" );
	
	// self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_nopower, level._visionset_priority_map_nopower, level._visionset_zombie_transition_time, int_client_num );
	if( level._power_on == true ) // if the power is on then use the power on visionset
	{
		self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_poweron, level._visionset_priority_map_poweron, level._visionset_zombie_transition_time, int_client_num );
	}
	else  // vision set for beginning (no power)
	{
		self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_nopower, level._visionset_priority_map_nopower, 0, int_client_num );
	}
}

// ww: changes the vision set to the power on version
cosmodrome_power_vision_set_swap()
{
	level waittill( "ZPO" );
	
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_sudden_power, level._visionset_priority_map_sudden_power, level._visionset_zombie_sudden_power_transition_time, i );
	}
	
	wait( 1.0 );
	
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] clientscripts\_zombiemode::zombie_vision_set_apply( level._visionset_map_poweron, level._visionset_priority_map_poweron, level._visionset_zombie_transition_time, i );
	}
}

cosmodrome_custom_visionset_func( str_vision_old, str_vision_new, int_clientnum, int_trans, vision_priority )
{

	if( !IsDefined( vision_priority ) )
	{
		vision_priority = 1;
	}
	
	if( IsDefined( str_vision_old ) ) // remove
	{
		clientscripts\_zombiemode::zombie_vision_set_remove( str_vision_old, 0, int_clientnum );
	}
	
	if( IsDefined( int_trans ) )
	{
		trans_time = int_trans;
	}
	else
	{
		trans_time = 0;
	}
	
	// wait( 0.1 );
	//iprintlnbold( "cosmodrome_custom_visionset_func: ");
	//iprintlnbold( str_vision_new );
	clientscripts\_zombiemode::zombie_vision_set_apply( str_vision_new, vision_priority, trans_time, int_clientnum );
	
	/#
	// PrintLn( "$$$$ " + start_vision[0] + " $$$$" );
	#/
}


/*------------------------------------
lander docking stations
------------------------------------*/
//lander_station3
catwalk_lander_doors()
{
	level thread catwalk_lander_doors_only();
	while(1)
	{
		level waittill("CW_O");	
		level thread open_lander_bay_doors("catwalk_zip_door");
		level waittill("CW_C");
		level thread close_lander_bay_doors("catwalk_zip_door");
	}	
}	

catwalk_lander_doors_only()
{
	while(1)
	{
		level waittill("CWD");	
		level thread open_lander_bay_doors_only("catwalk_zip_door");
	}	
}	



//lander_station1
base_entry_lander_doors()
{
	level thread base_entry_lander_doors_only();
	while(1)
	{
		level waittill("BE_O");	
		level thread open_lander_bay_doors("base_entry_zip_door");
		level waittill("BE_C");
		level thread close_lander_bay_doors("base_entry_zip_door");
	}	
}	

base_entry_lander_doors_only()
{
	while(1)
	{
		level waittill("BED");	
		level thread open_lander_bay_doors_only("base_entry_zip_door");
	}	
}	

//lander_station1
storage_lander_doors()
{
	level thread storage_lander_doors_only();
	while(1)
	{
		level waittill("S_O");	
		level thread open_lander_bay_doors("storage_zip_door");
		level waittill("S_C");
		level thread close_lander_bay_doors("storage_zip_door");
	}	
}	

storage_lander_doors_only()
{
	while(1)
	{
		level waittill("SOD");	
		level thread open_lander_bay_doors_only("storage_zip_door");
	}	
}	


//lander station5
centrifuge_lander_doors()
{
	level thread centrifuge_lander_doors_only();
	while(1)
	{
		level waittill("CF_O");	
		level thread open_lander_bay_doors("centrifuge_zip_door");
		level waittill("CF_C");
		level thread close_lander_bay_doors("centrifuge_zip_door");
	}	
}

centrifuge_lander_doors_only()
{
	while(1)
	{
		level waittill("CFD");	
		level thread open_lander_bay_doors_only("centrifuge_zip_door");
	}	
}	



open_lander_bay_doors(door_name)
{
	
	println("***** -- Opening door");
	players = GetLocalPlayers();
	sound_count = 0;
	for(x=0;x<players.size;x++)
	{	
		doors = getentarray(x,door_name,"targetname");
		for(i=0;i<doors.size;i++)
		{
			open_pos = getstruct(doors[i].target, "targetname");
			start_pos = getstruct(open_pos.target, "targetname");	
		
			if( !IsDefined(doors[i].script_noteworthy))
			{	
				doors[i] moveto(start_pos.origin, 1.0);
				
				if( sound_count == 0 )
				{
				    PlaySound( 0, "zmb_lander_door", doors[i].origin );
				    sound_count++;
				}
			}
		}		
	}	

	level waittill("LL");
	println("raising_shaft_cap");
	
	players = GetLocalPlayers();
	sound_count = 0;	
	for(x=0;x<players.size;x++)
	{	
		doors = getentarray(x,door_name,"targetname");

		for(i=0;i<doors.size;i++)
		{
			open_pos = getstruct(doors[i].target, "targetname");
			start_pos = getstruct(open_pos.target, "targetname");	
		
			if(IsDefined(doors[i].script_noteworthy))
			{			
				doors[i] moveto(open_pos.origin, 1.0);
				
				if( sound_count == 0 )
				{
				    PlaySound( 0, "zmb_lander_door", doors[i].origin );
				    sound_count++;
				}
			}	
		}	
	}
}

open_lander_bay_doors_only(door_name)
{
	players = GetLocalPlayers();
	sound_count = 0;
	for(x=0;x<players.size;x++)
	{	
		doors = getentarray(x,door_name,"targetname");
		for(i=0;i<doors.size;i++)
		{
			open_pos = getstruct(doors[i].target, "targetname");
			//start_pos = getstruct(open_pos.target, "targetname");	
			if( !IsDefined(doors[i].script_noteworthy))
			{	
				doors[i] moveto(open_pos.origin, 1.0);
				
				if( sound_count == 0 )
				{
				    PlaySound( 0, "zmb_lander_door", doors[i].origin );
				    sound_count++;
				}
			}
		}	
	}	
}

//
//raise_shaft_cap(door_name)
//{
//	level waittill("LL");
//	println("***** -- raising cap on " + door_name );
//
//	players = GetLocalPlayers();	
//	for(x=0;x<players.size;x++)
//	{	
//		doors = getentarray(x,door_name,"targetname");
//
//		for(i=0;i<doors.size;i++)
//		{
//			open_pos = getstruct(doors[i].target, "targetname");
//			start_pos = getstruct(open_pos.target, "targetname");	
//		
//			if(IsDefined(doors[i].script_noteworthy))
//			{			
//				doors[i] moveto(open_pos.origin, 1.0);
//			}	
//		}	
//	}
//}
//
//lower_shaft_cap(door_name)
//{
//}


//---------------------------------------------------------------------------
// Lander shaft doors and cap close when lander in place.
//---------------------------------------------------------------------------
close_lander_bay_doors(door_name)
{
	
	println("***** -- closing door");
	
	players = GetLocalPlayers();	
	sound_count = 0;
	for(x=0;x<players.size;x++)
	{	
		doors = getentarray(x,door_name,"targetname");	
		for(i=0;i<doors.size;i++)
		{
			open_pos = getstruct(doors[i].target, "targetname");		
			start_pos = getstruct(open_pos.target, "targetname");	
		
			if( IsDefined(doors[i].script_noteworthy)  )
			{
				doors[i] moveto(start_pos.origin, 1.0);
				
				if( sound_count == 0 )
				{
				    PlaySound( 0, "zmb_lander_door", doors[i].origin );
				    sound_count++;
				}
			}
		}
	}
	
	level waittill("LG");
		
	players = GetLocalPlayers();	
	sound_count = 0;
	for(x=0;x<players.size;x++)
	{	
		doors = getentarray(x,door_name,"targetname");

		for(i=0;i<doors.size;i++)
		{
			open_pos = getstruct(doors[i].target, "targetname");		
			start_pos = getstruct(open_pos.target, "targetname");	
		
			if(!IsDefined(doors[i].script_noteworthy) )
			{
				doors[i] moveto(start_pos.origin, 1.0);
				
				if( sound_count == 0 )
				{
				    PlaySound( 0, "zmb_lander_door", doors[i].origin );
				    sound_count++;
				}
			}
		}
	}
		
}

rocket_fx( localClientNum, set,newEnt )
{
	if ( !set )
		return;

	//playfx( localClientNum, level._effect["rocket_linger"], self gettagorigin("tag_engine") );
	PlayFxOnTag( localClientNum, level._effect["rocket_blast_trail"], self, "tag_engine" );
}


lander_engine_fx(localClientNum, set,newEnt)
{
	player = getlocalplayers()[localClientNum];
	if(set)
	{
		if(isDefined(player.lander_fx))
		{
			StopFX(localClientNum,player.lander_fx);
			StopFX(localClientNum,player.lander_fx1);
			StopFX(localClientNum,player.lander_fx2);
			StopFX(localClientNum,player.lander_fx3);
			StopFX(localClientNum,player.lander_fx4);
		}
		player.lander_fx = PlayFxOnTag( localClientNum, level._effect["lunar_lander_thruster_leg"], self, "tag_engine01" );
		player.lander_fx1 = PlayFxOnTag( localClientNum, level._effect["lunar_lander_thruster_leg"], self, "tag_engine02" );
		player.lander_fx2 = PlayFxOnTag( localClientNum, level._effect["lunar_lander_thruster_leg"], self, "tag_engine03" );
		player.lander_fx3 = PlayFxOnTag( localClientNum, level._effect["lunar_lander_thruster_leg"], self, "tag_engine04" );
		player.lander_fx4 = PlayFxOnTag( localClientNum, level._effect["lunar_lander_thruster_bellow"], self, "tag_bellow" );
	    
	  self thread start_ground_sounds();
	}
	else
	{
		if(isDefined(player.lander_fx))
		{
			StopFX(localClientNum,player.lander_fx);
			StopFX(localClientNum,player.lander_fx1);
			StopFX(localClientNum,player.lander_fx2);
			StopFX(localClientNum,player.lander_fx3);
			StopFX(localClientNum,player.lander_fx4);
		}
	}
}

start_ground_sounds()
{
    self endon( "entityshutdown" ); 
	level endon( "save_restore" );
	
	self notify( "start_ground_sounds" );
	self.stop_ground_sounds = false;

	trace = undefined; 
	//trace_ent = self;

	self.ground_sound_ent = spawn(0, (0,0,0), "script_origin" );
	pre_origin = ( 100000, 100000, 100000 );

	while( IsDefined( self ) )
	{
		wait( .15 );

		if( IsDefined( self.stop_ground_sounds ) && self.stop_ground_sounds )
		{
			if( IsDefined( self.ground_sound_ent ) )
				self.ground_sound_ent StopLoopSound( 2 );
				
			return;
		}
		
		// do checks only if we moved more than a feet
		if( DistanceSquared( pre_origin, self gettagorigin( "tag_bellow" ) ) < 144 )
		{
			continue;
		}
			
		pre_origin = self gettagorigin( "tag_bellow" );

		trace = bullettrace( self gettagorigin( "tag_bellow" ) , self gettagorigin( "tag_bellow" )  -( 0, 0, 100000 ), false, undefined );
		
		if( !IsDefined( trace ) )
			continue; 

		if( !IsDefined( trace["position"] ) )
		{
			self.ground_sound_ent StopLoopSound( 2 );
			continue; 
		}

		//update origin
		self.ground_sound_ent.origin = trace["position"] + (0,0,30);
		self.ground_sound_ent PlayLoopSound( "zmb_lander_ground_sounds", 3 );
	}	
}
end_ground_sounds()
{
    self endon( "start_ground_sounds" );
    
    self.stop_ground_sounds = true;
    wait(3);
    self.ground_sound_ent Delete();
}

lander_status_light(localClientNum, set,newEnt)
{
	
	if(isDefined(self.status_light))
	{
		StopFX(localclientNum,self.status_light);
	}
	if(set)
	{
		self.status_light = PlayFxOnTag( localClientNum, level._effect["lander_red"], self, "tag_origin" );
	}
	else
	{
		self.status_light = PlayFxOnTag( localClientNum, level._effect["lander_green"], self, "tag_origin" );
	}
}

init_rocket_debris()
{
	players = GetLocalPlayers();	
	for(x=0;x<players.size;x++)
	{	
		rocket_debris = getentarray(x,"rocket_explode_debris","targetname");
		for(i=0;i<rocket_debris.size;i++)
		{
			rocket_debris[i] hide();
		}
	}
	
	level waittill("RX");
	
	players = GetLocalPlayers();	
	for(x=0;x<players.size;x++)
	{
		players[x] thread rain_debris(x);
	}
}


get_random_spot_in_player_view(fwd_min,fwd_max,side_min,side_max)
{
	
	fwd = AnglesToForward( self.angles );
	fwd = vector_scale( fwd, RandomIntRange( fwd_min, fwd_max ) );
	if( randomint(100) > 50 )
	{
		side = AnglesToRight(self.angles);
	}
	else
	{
		side = AnglesToRight(self.angles)	 * - 1;
	}
	
	side = vector_scale( side, RandomIntRange( side_min, side_max ) );
	
	point = self.origin + fwd + side;
	//point = point + (0,0,300);
	
	trace = bullettrace(point,point + (0,0,-10000),false,undefined);
	
	return trace["position"];	
}

rain_debris(clientnum)
{
	rocket_debris = getentarray(clientnum,"rocket_explode_debris","targetname");

	for(i=0;i<10;i++)
	{
		spot = self get_random_spot_in_player_view(1000,3500,50,1000);
		debris =  spawn(clientnum,spot + (0,0,10000),"script_model");
		debris.angles = (randomint(360),randomint(360),randomint(360));; 
		debris setmodel(random(rocket_debris).model);
		debris thread debris_crash_and_burn(spot,clientnum,self);
		wait(randomfloatrange(.5,1.5));
	}
}

debris_crash_and_burn(spot,client,player)
{
	playfxontag(client,level._effect["debris_trail"] ,self,"tag_origin");
	//playfxontag(client,level._effect["fx_fire_sm"],self,"tag_origin");	// This effect no longer exists!
	self moveto(spot,3.1);
	
	for(i=0;i<10;i++)
	{
		self rotateto( (randomint(360),randomint(360),randomint(360)),.3);
		wait(.3);
	}
	wait(3.1);	
	player earthquake(0.4,0.5,self.origin,1200);
	playfx( client, level._effect["debris_hit"], self.origin );
	wait(1);
	self delete();
}

//-------------------------------------------------------------------------------
// DCS 111710: setting on off states for lander screens.
//-------------------------------------------------------------------------------
setup_lander_screens(clientnum)
{
	screens = GetEntArray( clientnum,"lander_screens","targetname");

	for(i=0;i<screens.size;i++)
	{
		if(IsDefined(screens[i].model))
		{
			screens[i] SetModel("p_zom_cosmo_lunar_control_panel_dlc_on");			
		}
	}	
}

/*------------------------------------
sets up the initial lander station screens to show as unavailable
------------------------------------*/
lander_at_station(station,clientnum)
{
	
	if(isDefined(self.panel_fx))
	{
		StopFX(clientnum,self.panel_fx);
	}
	if(isDefined(self.lander_fx))
	{
		StopFX(clientnum,self.lander_fx);
	}	
	
	switch(station)
	{
		case "baseentry":			

			self.panel_fx = PlayFxOnTag(clientnum,level._effect["panel_green"],self,"tag_location_3");
			self.lander_location = self gettagorigin("tag_location_3");
			self.lander_location_angles = self gettagangles("tag_location_3");
			break;
			
		case "storage":
			self.panel_fx = PlayFxOnTag(clientnum,level._effect["panel_green"],self,"tag_location_1");
			self.lander_location = self gettagorigin("tag_location_1");
			self.lander_location_angles = self gettagangles("tag_location_1");
			break;
			
		case "catwalk":
			self.panel_fx = PlayFxOnTag(clientnum,level._effect["panel_green"],self,"tag_location_2");
			self.lander_location = self gettagorigin("tag_location_2");
			self.lander_location_angles = self gettagangles("tag_location_2");			
			break;
		
		case "centrifuge":
			self.panel_fx = PlayFxOnTag(clientnum,level._effect["panel_green"],self,"tag_home");
			self.lander_location = self gettagorigin("tag_home");
			self.lander_location_angles = self gettagangles("tag_home");
			break;
	}
}

/*------------------------------------
clientflag set on the lander which is used to start
the moving light on the lander screens
------------------------------------*/
lander_move_fx(localClientNum, set,newEnt)
{
	player = getlocalplayers()[localClientNum];
	
	if(set)
	{
		player thread lander_station_move_lander_marker(localClientNum);
	}
	else
	{
		
	}
}

/*------------------------------------
This moves the light FX on the lander screens 
from point to point as the lander travels 
------------------------------------*/
lander_station_move_lander_marker(localClientNum)
{
	
	dest = undefined;

	x= localClientNum;
	
	screens = GetEntArray( x,"lander_screens","targetname");

	for(i=0;i<screens.size;i++)
	{
		screen = screens[i];
		
		//stop any previous lander_fx
		if(isDefined(screen.lander_fx))
		{
			StopFX(x,screen.lander_fx);
		}
		
		//stop any previous panel_fx
		if(isDefined(screen.panel_fx))
		{
			StopFX(x,screen.panel_fx);
		}
		
		//create the FX ent that will be moving if it's not already 
		if(!isDefined(screen.lander_fx_ent))
		{			
			screen.lander_fx_ent = spawn(x,screen.lander_location,"script_origin");
			screen.lander_fx_ent setmodel("tag_origin");	
			screen.lander_fx_ent.angles = screen.lander_location_angles;		
		}
		
		screen.lander_fx = playfxontag(x,level._effect["panel_green"],screen.lander_fx_ent,"tag_origin");
		
		//this gets the destination station, so we know where to move the point
		switch(level.lander_dest_station)
		{
			case "base":
				dest = screen gettagorigin("tag_location_3");
				break;
				
			case "storage":
				dest = screen gettagorigin("tag_location_1");
				break;
				
			case "centrifuge":
				dest = screen gettagorigin("tag_home");
				break;
				
			case "catwalk":
				dest = screen gettagorigin("tag_location_2");
				break;
		}
		screen.lander_fx_ent moveto(dest,10);
	}
}

lander_station_think()
{
	
	level thread lander_station_centrifuge_mon();
	level thread lander_station_baseentry_mon();
	level thread lander_station_storage_mon();
	level thread lander_station_catwalk_mon();	
	
	level thread lander_station_centrifuge();
	level thread lander_station_baseentry();
	level thread lander_station_storage();
	level thread lander_station_catwalk();
}

///*------------------------------------
//monitors for the lander to be at a station so we can track the movement between stations when it leaves
//------------------------------------*/
lander_station_centrifuge_mon()
{
	while(1)
	{
		level waittill("LLCF");
		level.lander_dest_station = "centrifuge";
	}
}

lander_station_baseentry_mon()
{
	while(1)
	{
		level waittill("LLBE");
		level.lander_dest_station = "base";
	}
}
lander_station_storage_mon()
{
	while(1)
	{
		level waittill("LLSS");
		level.lander_dest_station = "storage";
	}
}
lander_station_catwalk_mon()
{
	while(1)
	{
		level waittill("LLCW");
		level.lander_dest_station = "catwalk";
	}
}


/*------------------------------------
put the lander location lights at the proper place
------------------------------------*/
lander_station_centrifuge()
{
	while(1)
	{
		level waittill("LACF");
		players = GetLocalPlayers();
		for ( x=0; x<players.size; x++ )
		{
			screens = GetEntArray( x,"lander_screens","targetname");
	
			for(i=0;i<screens.size;i++)
			{
				screens[i] lander_at_station("centrifuge",x); //set the initial state of the lander
			}	
		}
	}
}

lander_station_baseentry()
{
	while(1)
	{
		level waittill("LABE");
		players = GetLocalPlayers();
		for ( x=0; x<players.size; x++ )
		{
			screens = GetEntArray( x,"lander_screens","targetname");
	
			for(i=0;i<screens.size;i++)
			{
				screens[i] lander_at_station("baseentry",x);; //set the initial state of the lander
			}	
		}
	}
}

lander_station_storage()
{
	while(1)
	{
		level waittill("LASS");
		players = GetLocalPlayers();
		for ( x=0; x<players.size; x++ )
		{
			screens = GetEntArray( x,"lander_screens","targetname");
	
			for(i=0;i<screens.size;i++)
			{
				screens[i] lander_at_station("storage",x); //set the initial state of the lander
			}	
		}
	}
}

lander_station_catwalk()
{
	while(1)
	{
		level waittill("LACW");
		players = GetLocalPlayers();
		for ( x=0; x<players.size; x++ )
		{
			screens = GetEntArray( x,"lander_screens","targetname");
	
			for(i=0;i<screens.size;i++)
			{
				screens[i] lander_at_station("catwalk",x); //set the initial state of the lander
			}	
		}
	}
}


/*------------------------------------
toggles the light FX on the lander station screens 
------------------------------------*/
launch_panel_centrifuge_status(localClientNum, set,newEnt)
{
	
	if(set)
	{
		if(isDefined(self.centrifuge_status))
		{
			StopFX(localClientNum,self.centrifuge_status);
		}
		self.centrifuge_status = PlayFxOnTag(localClientNum,level._effect["panel_red"],self,"tag_home");
	}
	else
	{
		if(isDefined(self.centrifuge_status))
		{
			StopFX(localClientNum,self.centrifuge_status);
		}
		self.centrifuge_status = PlayFxOnTag(localClientNum,level._effect["panel_green"],self,"tag_home");
	}
}

/*------------------------------------
toggles the light FX on the lander station screens 
------------------------------------*/
launch_panel_storage_status(localClientNum, set,newEnt)
{
	
	if(set)
	{
		if(localClientNum == 0)
		{
			level.rocket_num++;
		}	
		level thread rocket_launch_display(localClientNum);
				
//		if(isDefined(self.storage_status))
//		{
//			StopFX(localClientNum,self.storage_status);
//		}
//		self.storage_status = PlayFxOnTag(localClientNum,level._effect["panel_red"],self,"tag_location_1");
	}
	else
	{
//		if(isDefined(self.storage_status))
//		{
//			StopFX(localClientNum,self.storage_status);
//		}
//		self.storage_status = PlayFxOnTag(localClientNum,level._effect["panel_green"],self,"tag_location_1");
	}
}

/*------------------------------------
toggles the light FX on the lander station screens 
------------------------------------*/
launch_panel_baseentry_status(localClientNum, set,newEnt)
{
	
	if(set)
	{
		if(localClientNum == 0)
		{
			level.rocket_num++;
		}	
		level thread rocket_launch_display(localClientNum);
		
//		if(isDefined(self.baseentry_status))
//		{
//			StopFX(localClientNum,self.baseentry_status);
//		}
//		self.baseentry_status = PlayFxOnTag(localClientNum,level._effect["panel_red"],self,"tag_location_3");
	}
	else
	{
//		if(isDefined(self.baseentry_status))
//		{
//			StopFX(localClientNum,self.baseentry_status);
//		}
//		self.baseentry_status = PlayFxOnTag(localClientNum,level._effect["panel_green"],self,"tag_location_3");
	}
}

/*------------------------------------
toggles the light FX on the lander station screens 
------------------------------------*/
launch_panel_catwalk_status(localClientNum, set,newEnt)
{
	
	if(set)
	{
		if(localClientNum == 0)
		{
			level.rocket_num++;
		}	
		level thread rocket_launch_display(localClientNum);
		
//		if(isDefined(self.catwalk_status))
//		{
//			StopFX(localClientNum,self.catwalk_status);
//		}
//		self.catwalk_status = PlayFxOnTag(localClientNum,level._effect["panel_red"],self,"tag_location_2");
	}
	else
	{
//		if(isDefined(self.catwalk_status))
//		{
//			StopFX(localClientNum,self.catwalk_status);
//		}
//		self.catwalk_status = PlayFxOnTag(localClientNum,level._effect["panel_green"],self,"tag_location_2");
	}
}

/*------------------------------------
change screens for rocket launch sequence
------------------------------------*/
rocket_launch_display(localClientNum)
{
	//wait till the lander has landed
	level waittill("LG");
	
	//wait a few extra seconds to allow for the lander sounds to die down
	wait(2);
	
	//grab all the screens and change them
	rocket_screens = GetEntArray(localClientNum,"rocket_launch_sign","targetname");
	model = rocket_screens[0].model;
	switch(level.rocket_num)
	{
		case 1: 
			model = "p_zom_rocket_sign_02"; 
			break;
		
		case 2:
			model = "p_zom_rocket_sign_03";
			break;
			
		case 3:
			model = "p_zom_rocket_sign_04";
			break;
	}	
	
	array_thread(rocket_screens,::update_rocket_display,model);
}	

update_rocket_display(on_model)
{
	old_model = self.model;
	for(i=0;i<3;i++)
	{
		self SetModel(on_model);
		wait(.35);
		self SetModel(old_model);
		wait(.35);
	}
	self SetModel(on_model);
}


/*------------------------------------
some rumble & earthquake effects while the players are 
waiting for and riding in the lander
------------------------------------*/
lander_rumble_and_quake(localClientNum, set,newEnt)
{
	player = getlocalplayers()[localClientNum];
	
	player endon("death");
	player endon("disconnect");
	
	if(set)
	{
		//small rumble/earthquake when the lander is initially called
		player Earthquake( RandomFloatRange( 0.2, 0.3 ), RandomFloatRange(2, 2.5), player.origin, 150 );
		player PlayRumbleOnEntity(localClientNum,"artillery_rumble");
		
		self thread do_lander_rumble_quake(localClientNum);
	}
	else
	{
		self thread end_ground_sounds();
		//a bit of a big earthquake when the lander lands
		player Earthquake( RandomFloatRange( 0.3, 0.4 ), RandomFloatRange(0.5, 0.6), self.origin, 150 );
		wait( 0.6 );
		player EarthQuake( RandomFloatRange( 0.1, 0.2 ), RandomFloatRange(0.2, 0.3), self.origin, 150 ); 		

		level notify("stop_lander_rumble");
	}
}

/*------------------------------------
rumble/earthquake as lander is in flight
------------------------------------*/
do_lander_rumble_quake(localClientNum)
{
	level endon("stop_lander_rumble");
	
	player = getlocalplayers()[localClientNum];
	
	player endon("death");
	player endon("disconnect");	
	
	while(1)
	{
		
		if(!isDefined(self.origin) || !isDefined(player.origin))
		{
			wait(.05);
			continue;
		}	
		
		if(distancesquared ( player.origin,self.origin) > (1500 * 1500))
		{
			wait(.1);
			continue;
		}
		
		dist = distancesquared ( player.origin,self.origin);
							
		if(dist > 750*750 )
		{
			player Earthquake( RandomFloatRange( 0.1, 0.15 ), RandomFloatRange(0.15, 0.16), self.origin, 1000 );
			rumble = "slide_rumble";		
		}
		else
		{
			player Earthquake( RandomFloatRange( 0.15, 0.2 ), RandomFloatRange(0.15, 0.16), self.origin, 750 );
			rumble = "damage_light";
		}
		player PlayRumbleOnEntity(localClientNum,rumble);
		wait(.1);
	}
	
}

// -- rumble for centrifuge
centrifuge_rumble_control( local_client_num, set, newEnt )
{
	if( local_client_num != 0 )
	{
		return;
	}
	
	if( set ) // start the rumble on the centrifuge
	{
		players = GetLocalPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] thread centrifuge_rumble_when_close( self, i );
		}
	}
	else // disable the centrifuge rumble
	{
		level notify( "centrifuge_rumble_done" );
	}
	
}

centrifuge_rumble_when_close( ent_centrifuge, int_client_num )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "centrifuge_rumble_done" );
	
	rumble_range = 600*600;
	centrifuge_rumble = "damage_heavy";
	client_num = undefined;
	
	while( true )
	{
		distance_to_centrifuge = DistanceSquared( self.origin, ent_centrifuge.origin );
		
		if( ( distance_to_centrifuge < rumble_range ) )
		{
			if( IsDefined( int_client_num ) )
			{
				self PlayRumbleOnEntity( int_client_num, centrifuge_rumble );	
			}
		}
		
		if( ( distance_to_centrifuge > rumble_range ) )
		{
			if( IsDefined( int_client_num ) )
			{
				self StopRumble( int_client_num, centrifuge_rumble );	
			}
			
		}
		
		wait( 0.1 );
	}
	
}

centrifuge_clean_rumble( int_client_num )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self StopRumble( int_client_num, "damage_heavy" );
}

centrifuge_warning_lights_init( local_client_num, set, newEnt )
{
	while( !self hasdobj( local_client_num ) )
	{
		wait(0.1);
	}
	
	if( local_client_num != 0 )
	{
		return;
	}
	
	players = GetLocalPlayers();

	for( i = 0; i < players.size; i++ )
	{
		// clean up any lights that might still be around
		self centrifuge_warning_lights_off( i );
	}
	
	if( set )
	{
		players = GetLocalPlayers();
		
		for( i = 0; i < players.size; i++ )
		{
			self centrifuge_fx_spot_init( i );
			self centrifuge_warning_lights_on( i );
		}
	}

}

monkey_lander_fx_on()
{
	self endon("switch_off_monkey_lander_fx");
	PlaySound(0, "zmb_ape_intro_whoosh", self.origin);
	
	realWait( 2.5 );

	self.fx = [];
	
	players = getlocalplayers();
	ent_num = self GetEntityNumber();
	
	
	for(i = 0; i < players.size; i ++)
	{
		player = players[i];
		
		if(!IsDefined(player._monkey_lander_fx))
		{
			player._monkey_lander_fx = [];
		}		
		
		if(IsDefined(player._monkey_lander_fx[ent_num]))
		{
			DeleteFX(i, player._monkey_lander_fx[ent_num]);
			player._monkey_lander_fx[ent_num] = undefined;
			
		}
		
		player._monkey_lander_fx[ent_num] = PlayFXOnTag(i, level._effect["monkey_trail"],self,"tag_origin");
	}
}

monkey_lander_delay_fx_off()
{
	realWait( 5 );
	self notify("switch_off_monkey_lander_fx");

	players = getlocalplayers();
	ent_num = self GetEntityNumber();

	for(i = 0; i < players.size; i ++)
	{
		player = players[i];

		if(IsDefined(player._monkey_lander_fx[ent_num]))
		{
			DeleteFX(i, player._monkey_lander_fx[ent_num]);
			player._monkey_lander_fx[ent_num] = undefined;
		}
	}
}

monkey_lander_fx_off()
{
	self thread monkey_lander_delay_fx_off();

	players = getlocalplayers();
	ent_num = self GetEntityNumber();
	
	for(i = 0; i < players.size; i ++)
	{
		player = players[i];

		PlayFX(i, level._effect["monkey_spawn"], self.origin );
		PlayRumbleOnPosition( i, "explosion_generic", self.origin ); 
		
		player Earthquake( 0.5, 0.5, player.origin, 1000 );
	}
	
	PlaySound( 0, "zmb_ape_intro_land", self.origin );
	
	level notify( "MLO" );
	wait( 0.5 );
	level notify ( "MLF" );	
}

monkey_lander_fx(local_client_num, set, newEnt)
{
	if( local_client_num != 0 )
	{
		return;
	}
		
	while( !self hasdobj( local_client_num ) )
	{
		wait(0.1);
	}
	
	if(set)
	{
		self thread monkey_lander_fx_on();
	}
	else
	{
		self thread monkey_lander_fx_off();
	}
}

// WW (01/13/2011): There were too many D-lights in the centrifuge room. The centrifuge uses four D-lights in the red light effect,
//  I'm lowering it to only two and replacing the two with no lights with sparks, this should eliminate the D-light issue with the 
// revive perk machine
centrifuge_fx_spot_init( int_client_num )
{
	// light array
	self._centrifuge_lights_[int_client_num] = [];
	
	// add the light tags
	self._centrifuge_lights_[int_client_num] = add_to_array( self._centrifuge_lights_[int_client_num], "tag_light_bk_top", false );
	self._centrifuge_lights_[int_client_num] = add_to_array( self._centrifuge_lights_[int_client_num], "tag_light_fnt_top", false );
	
	// add the spark tags
	self._centrifuge_sparks_[int_client_num] = [];
	self._centrifuge_sparks_[int_client_num] = add_to_array( self._centrifuge_sparks_[int_client_num], "tag_light_bk_bttm", false );
	self._centrifuge_sparks_[int_client_num] = add_to_array( self._centrifuge_sparks_[int_client_num], "tag_light_fnt_bttm", false );		
		
	// steam array
	self._centrifuge_steams_[int_client_num] = [];
	// add the steam tags
	self._centrifuge_steams_[int_client_num] = add_to_array( self._centrifuge_steams_[int_client_num], "tag_vent_bk_btm", false );
	self._centrifuge_steams_[int_client_num] = add_to_array( self._centrifuge_steams_[int_client_num], "tag_vent_top_btm", false );
	
	self._centrifuge_light_mdls_[int_client_num] = []; // this will also have the spark models which is fine since both lights and sparks need to be deleted at teh same time
	
	self._centrifuge_fx_setup = true;

}

// turns on the warning lights
centrifuge_warning_lights_on( client_num )
{
	// spawn a script model at each spot 
	for( i = 0; i < self._centrifuge_lights_[client_num].size; i++ )
	{
		temp_mdl = Spawn( client_num, self GetTagOrigin( self._centrifuge_lights_[client_num][i] ), "script_model" );
		temp_mdl.angles = self GetTagAngles( self._centrifuge_lights_[client_num][i] );
		temp_mdl SetModel( "tag_origin" );
		temp_mdl LinkTo( self, self._centrifuge_lights_[client_num][i] );
		PlayFXOnTag( client_num, level._effect[ "centrifuge_warning_light" ], temp_mdl, "tag_origin" );
		self._centrifuge_light_mdls_[client_num] = add_to_array( self._centrifuge_light_mdls_[client_num], temp_mdl, false );
	}
	
	// WW: adding the spark start here since they are replacing certain lights
	// these will also be placed in the self._centrifuge_light_mdls_[client_num] array so they are deleted when the lights are
	for( i = 0; i < self._centrifuge_sparks_[client_num].size; i++ )
	{
		temp_mdl = Spawn( client_num, self GetTagOrigin( self._centrifuge_sparks_[client_num][i] ), "script_model" );
		temp_mdl.angles = self GetTagAngles( self._centrifuge_sparks_[client_num][i] );
		temp_mdl SetModel( "tag_origin" );
		temp_mdl LinkTo( self, self._centrifuge_sparks_[client_num][i] );
		PlayFXOnTag( client_num, level._effect[ "centrifuge_light_spark" ], temp_mdl, "tag_origin" );
		self._centrifuge_light_mdls_[client_num] = add_to_array( self._centrifuge_light_mdls_[client_num], temp_mdl, false );
	}
	
	// play the steam
	self thread centrifuge_steam_warning( client_num );
	
}

// waits a second then plays the steam fx from the centrifuge
centrifuge_steam_warning( client_num )
{
	wait( 1.0 );
	
	for( i = 0; i < self._centrifuge_steams_[client_num].size; i++ )
	{
		PlayFXOnTag( client_num, level._effect[ "centrifuge_start_steam" ], self, self._centrifuge_steams_[client_num][i] );	
	}
}

// turns off the warning lights
centrifuge_warning_lights_off( client_num )
{
	if( !IsDefined( self._centrifuge_fx_setup ) )
	{
		return;
	}
	
	wait( 0.2 ); // ww: these were shutting down abruptly so adding a small wait will have them turn off after the fuge has stopped for a bit
	
	for( i = 0; i < self._centrifuge_light_mdls_[client_num].size; i++ )
	{
		if( IsDefined( self._centrifuge_light_mdls_[client_num][i] ) )
		{
			self._centrifuge_light_mdls_[client_num][i] Unlink();	
		}
	}
	
	array_delete( self._centrifuge_light_mdls_[client_num] );
	self._centrifuge_light_mdls_[client_num] = [];

}

fog_apply( str_fog, int_priority )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	// make sure the vision set list is on the player
	if( !IsDefined( self._zombie_fog_list ) )
	{
		// if not create it
		self._zombie_fog_list = [];
	}
	
	// make sure the variables passed in are valid
	if( !IsDefined( str_fog ) || !IsDefined( int_priority ) )
	{
		return;
	}
	
	// make sure there isn't already one of the vision set in the array
	already_in_array = false;
	
	// if the array already has items in it check for duplictes
	if( self._zombie_fog_list.size != 0 )
	{
		for( i = 0; i < self._zombie_fog_list.size; i++ )
		{
			if( IsDefined( self._zombie_fog_list[i].fog_setting ) && self._zombie_fog_list[i].fog_setting == str_fog )
			{
				already_in_array = true;
				
				// if the priority is different change it and 
				if( self._zombie_fog_list[i].priority != int_priority )
				{
					// reset the priority based on the new int_priority
					self._zombie_fog_list[i].priority = int_priority;
				}
				
				break;
				
			}
			
		}
	}
	
	// if it isn't in the array add it
	if( !already_in_array )
	{
		// add the new vision set to the array
		temp_struct = spawnStruct();
		temp_struct.fog_setting = str_fog;
		temp_struct.priority = int_priority;
		self._zombie_fog_list = add_to_array( self._zombie_fog_list, temp_struct, false );
	}
	
	// now go through the player's list and find the one with highest priority	
	fog_to_set = get_fog_by_priority();
	//iprintlnbold("setting fog");
	set_fog(fog_to_set);
	//ADD FOG SETTINGS HERE
}

// SELF == PLAYER
fog_remove( str_fog )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	// make sure hte vision set is passed in
	if( !IsDefined( str_fog ) )
	{
		return;
	}
	
	// can't call this before the array has been set up through apply
	if( !IsDefined( self._zombie_fog_list ) )
	{
		self._zombie_fog_list = [];
	}
	
	// remove the vision set from the array
	temp_struct = undefined;
	for( i = 0; i < self._zombie_fog_list.size; i++ )
	{
		if( IsDefined( self._zombie_fog_list[i].fog_setting ) && self._zombie_fog_list[i].fog_setting == str_fog )
		{
			temp_struct = self._zombie_fog_list[i];
		}
	}
	
	if( IsDefined( temp_struct ) )
	{
		self._zombie_fog_list = array_remove( self._zombie_fog_list, temp_struct );
	}
	
	// set the next highest priority	
	fog_to_set = get_fog_by_priority();
	set_fog(fog_to_set);

}

// ww: apply the highest score vision set
get_fog_by_priority()
{
	if( !IsDefined( self._zombie_fog_list ) )
	{
		return;
	}
	
	highest_score = 0;
	highest_score_fog = undefined;
	
	for( i = 0; i < self._zombie_fog_list.size; i++ )
	{
		if( IsDefined( self._zombie_fog_list[i].priority ) && self._zombie_fog_list[i].priority > highest_score )
		{
			highest_score = self._zombie_fog_list[i].priority;
			highest_score_fog = self._zombie_fog_list[i].fog_setting;
		}
	}
	
	return highest_score_fog;
}

setup_fog()
{
	waitforclient(0);
	wait(1);

	players = getlocalplayers();
	for(i=0;i<players.size;i++)
	{
		players[i] fog_apply("normal",level._fog_settings_default_priority);
	}
	
}

set_fog(fog_type)
{
	
	switch(fog_type)
	{
		case "normal":
		
		// Intial Fog Setting
		
	
			start_dist = 2013.52;
			half_dist = 2400.04;
			half_height = 640.408;
			base_height = 805;
			fog_r = 0.055;
			fog_g = 0.0862;
			fog_b = 0.0862;
			fog_scale = 3.29585;
			sun_col_r = 0.341176;
			sun_col_g = 0.368627;
			sun_col_b = 0.388235;
			sun_dir_x = -0.492497;
			sun_dir_y = 0.584479;
			sun_dir_z = 0.64485;
			sun_start_ang = 14.832;
			sun_stop_ang = 113.6;
			time = 5;
			max_fog_opacity = 1;
		
			setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
				sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
				sun_stop_ang, time, max_fog_opacity);
				
				
     break;
			
		case "monkey":
		
		
		// Monkey Round Fog
			
			start_dist = 335.113;
			half_dist = 512.821;
			half_height = 913.4;
			base_height = 539.71;
			fog_r = 0.231373;
			fog_g = 0.176471;
			fog_b = 0.254902;
			fog_scale = 3.57142;
			sun_col_r = 0.431373;
			sun_col_g = 0;
			sun_col_b = 0;
			sun_dir_x = 0;
			sun_dir_y = 0;
			sun_dir_z = -1;
			sun_start_ang = 0;
			sun_stop_ang = 118.502;
			time = 3;
			max_fog_opacity = 0.999887;
		
			setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
				sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
				sun_stop_ang, time, max_fog_opacity);


			
			break;
		
		case "lander":
		
			//iprintlnbold("*** CLIENT: lander fog set");
			
	    start_dist = 767.866;
	    half_dist = 512.821;
	    half_height = 913.4;
	    base_height = 539.71;
	    fog_r = 0.054902;
	    fog_g = 0.0823529;
	    fog_b = 0.0901961;
	    fog_scale = 3.29585;
	    sun_col_r = 0.439216;
	    sun_col_g = 0.466667;
	    sun_col_b = 0.486275;
	    sun_dir_x = -0.290644;
	    sun_dir_y = 0.728615;
	    sun_dir_z = 0.620199;
	    sun_start_ang = 0;
	    sun_stop_ang = 62.865;
	    time = 3;
	    max_fog_opacity = 1;
	
	    setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
	    	sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
	    	sun_stop_ang, time, max_fog_opacity);
	    		                    
	     break;
	}
	
}

player_lander_fog( local_client_num, set, newEnt )
{
	player = getlocalplayers()[local_client_num];
	
	if(set)
	{
		player thread fog_apply( "lander", level._fog_settings_lander_priority );
	}
	else
	{
		player thread fog_remove("lander");		
	}

}