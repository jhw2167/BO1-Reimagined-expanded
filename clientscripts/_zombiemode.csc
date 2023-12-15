#include clientscripts\_music;
#include clientscripts\_utility;

main()
{
	//iprintlnbold("zombiemode init csc");
	
	level thread clientscripts\_zombiemode_ffotd::main_start();
	level.zombiemode = true;
	level.swimmingFeature = false;
	clientscripts\_load::main();
	clientscripts\_footsteps::SetAIFootstepPrepend( "fly_step_zombie_" );
	level thread clientscripts\_audio::audio_init( 0 );
	init_client_flags();
	init_client_flag_callback_funcs();
	//init_blocker_fx();
	//init_riser_fx();
	level._effect[ "zmb_new_gibtrail_fx" ] = LoadFX( "custom/zm_dog_v2/fx_zmb_blood_trail_mature" );	
	level._effect[ "electric_cherry_explode" ] = LoadFX( "electric_cherry/cherry_shock_large" );
	level._effect[ "electric_cherry_reload_small" ] = LoadFX( "electric_cherry/cherry_shock_large" );
	level._effect[ "electric_cherry_reload_medium" ] = LoadFX( "electric_cherry/cherry_shock_large" );
	level._effect[ "electric_cherry_reload_large" ] = LoadFX( "electric_cherry/cherry_shock_large" );
	//level._effect[ "vulture_perk_zombie_stink" ] = LoadFX( "vulture/fx_zm_vulture_perk_stink" );
	//level._effect[ "vulture_perk_zombie_stink_trail" ] = LoadFX( "vulture/fx_zm_vulture_perk_stink_trail" );
	level._effect[ "vulture_perk_bonus_drop" ] = LoadFX( "vulture/fx_zombie_powerup_vulture" );
	level._effect[ "vulture_drop_picked_up" ] = LoadFX( "misc/fx_zombie_powerup_grab" );
	level._effect[ "vulture_perk_wallbuy_static" ] = LoadFX( "vulture/vulture_wallgun_glow" );
	level._effect[ "vulture_perk_machine_glow_doubletap" ] = LoadFX( "vulture/vulture_dtap_glow" );
	level._effect[ "vulture_perk_machine_glow_juggernog" ] = LoadFX( "vulture/vulture_jugg_glow" );
	level._effect[ "vulture_perk_machine_glow_revive" ] = LoadFX( "vulture/vulture_revive_glow" );
	level._effect[ "vulture_perk_machine_glow_speed" ] = LoadFX( "vulture/vulture_speed_glow" );
	level._effect[ "vulture_perk_machine_glow_marathon" ] = LoadFX( "vulture/vulture_stamin_glow" );
	level._effect[ "vulture_perk_machine_glow_mule_kick" ] = LoadFX( "vulture/vulture_mule_glow" );
	level._effect[ "vulture_perk_machine_glow_pack_a_punch" ] = LoadFX( "vulture/vulture_pap_glow" );
	level._effect[ "vulture_perk_machine_glow_vulture" ] = LoadFX( "vulture/vulture_aid_glow" );
	level._effect[ "vulture_perk_machine_glow_electric_cherry" ] = LoadFX( "vulture/vulture_cherry_glow" );
	level._effect[ "vulture_perk_machine_glow_phd_flopper" ] = LoadFX( "vulture/vulture_phd_glow" );
	//level._effect[ "vulture_perk_machine_glow_whos_who" ] = LoadFX( "vulture/vulture_whoswho_glow" );
	level._effect[ "vulture_perk_machine_glow_widows_wine" ] = LoadFX( "vulture/vulture_widows_glow" );
	level._effect[ "vulture_perk_machine_glow_deadshot" ] = LoadFX( "vulture/vulture_deadshot_glow" );
	level._effect[ "vulture_perk_mystery_box_glow" ] = LoadFX( "vulture/vulture_box_glow" );
	level._effect[ "vulture_perk_powerup_drop" ] = LoadFX( "vulture/vulture_powerup_glow" );
	level._effect[ "vulture_perk_zombie_eye_glow" ] = LoadFX( "vulture/fx_zombie_eye_vulture" );
	//level._effect[ "widows_wine_wrap" ] = LoadFX( "widows_wine/fx_widows_wine_zombie" );
	//level._effect[ "widows_wine_exp_1p" ] = LoadFX( "widows_wine/fx_widows_wine_explode" );
	level._zombieCBFunc = ::on_zombie_spawn;
	level._playerCBFunc = ::on_player_spawn;
	level._gibEventCBFunc = ::on_gib_event;
	level thread ZPO_listener();
	level._BOX_INDICATOR_NO_LIGHTS = -1;
	level._BOX_INDICATOR_FLASH_LIGHTS_MOVING = 99;
	level._BOX_INDICATOR_FLASH_LIGHTS_FIRE_SALE = 98;
	level._box_indicator = level._BOX_INDICATOR_NO_LIGHTS;
	registerSystem( "box_indicator", ::box_monitor );
	level._ZOMBIE_GIB_PIECE_INDEX_ALL = 0;
	level._ZOMBIE_GIB_PIECE_INDEX_RIGHT_ARM = 1;
	level._ZOMBIE_GIB_PIECE_INDEX_LEFT_ARM = 2;
	level._ZOMBIE_GIB_PIECE_INDEX_RIGHT_LEG = 3;
	level._ZOMBIE_GIB_PIECE_INDEX_LEFT_LEG = 4;
	level._ZOMBIE_GIB_PIECE_INDEX_HEAD = 5;
	level._ZOMBIE_GIB_PIECE_INDEX_GUTS = 6;
	
	OnPlayerConnect_Callback( ::on_player_connect );
	init_divetonuke();
	init_deadshot();
	//init_chugabud();
	//init_electric_cherry();
	//init_widows_wine();
	clientscripts\_zombiemode_weap_tesla::init();
	//init_zombie_blood();
	init_client_side_fx();
	//init_vulture();
	//init_lowhealth_sound();
	//clientscripts\_zombiemode_weap_freezegun::init();
	//clientscripts\_zombiemode_weap_tazer_knuckles::init();
	//clientscripts\_zombiemode_weap_thundergun::init();
	level thread init_local_player_count();
	level thread clientscripts\_zombiemode_ffotd::main_end();
	
	//iprintlnbold("FINISHED zombiemode init csc");
}

init_local_player_count()
{
	waitforallclients();
	level._num_local_players = GetLocalPlayers().size;
}

//=========================================================================================================
// Init Misc FX
//=========================================================================================================

init_blocker_fx()
{
	level._effect[ "wood_chunk_destory" ] = LoadFX( "impacts/fx_large_woodhit" );
}

init_riser_fx()
{
	if( IsDefined( level.riser_fx_on_client ) && level.riser_fx_on_client )
	{
		if( IsDefined( level.use_new_riser_water ) && level.use_new_riser_water )
		{
			level._effect[ "rise_burst_water" ] = LoadFX( "maps/zombie/fx_mp_zombie_hand_water_burst" );
			level._effect[ "rise_billow_water" ] = LoadFX( "maps/zombie/fx_mp_zombie_body_water_billowing" );
		}
		level._effect[ "rise_dust_water" ] = LoadFX( "maps/zombie/fx_zombie_body_wtr_falling" );
		level._effect[ "rise_burst" ] = LoadFX( "maps/zombie/fx_mp_zombie_hand_dirt_burst" );
		level._effect[ "rise_billow" ] = LoadFX( "maps/zombie/fx_mp_zombie_body_dirt_billowing" );
		level._effect[ "rise_dust" ] = LoadFX( "maps/zombie/fx_mp_zombie_body_dust_falling" );
		if( IsDefined( level.riser_type ) && level.riser_type == "snow" )
		{
			level._effect[ "rise_burst_snow" ] = LoadFX( "maps/zombie/fx_mp_zombie_hand_snow_burst" );
			level._effect[ "rise_billow_snow" ] = LoadFX( "maps/zombie/fx_mp_zombie_body_snow_billowing" );
			level._effect[ "rise_dust_snow" ] = LoadFX( "maps/zombie/fx_mp_zombie_body_snow_falling" );
		}
	}
}

//=========================================================================================================
// Clientflags
//=========================================================================================================

init_client_flags()
{
	level._ZOMBIE_SCRIPTMOVER_FLAG_BOX_RANDOM = 15;
	if( IsDefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
	{
		level._ZOMBIE_SCRIPTMOVER_FLAG_BOARD_HORIZONTAL_FX = 14;
		level._ZOMBIE_SCRIPTMOVER_FLAG_BOARD_VERTICAL_FX = 13;
	}
	if( IsDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
	{
		level._ZOMBIE_SCRIPTMOVER_FLAG_ROCK_FX = 12;
	}
	if( IsDefined( level.riser_fx_on_client ) && level.riser_fx_on_client )
	{
		level._ZOMBIE_ACTOR_ZOMBIE_RISER_FX = 8;
		if( !IsDefined( level._no_water_risers ) )
		{
			level._ZOMBIE_ACTOR_ZOMBIE_RISER_FX_WATER = 9;
		}
		if( IsDefined( level.risers_use_low_gravity_fx ) )
		{
			level._ZOMBIE_ACTOR_ZOMBIE_RISER_LOWG_FX = 7;
		}
	}
}

init_client_flag_callback_funcs()
{
	if( IsDefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
	{
		register_clientflag_callback( "scriptmover", level._ZOMBIE_SCRIPTMOVER_FLAG_BOARD_VERTICAL_FX, ::handle_vertical_board_clientside_fx );
		register_clientflag_callback( "scriptmover", level._ZOMBIE_SCRIPTMOVER_FLAG_BOARD_HORIZONTAL_FX, ::handle_horizontal_board_clientside_fx );
	}
	if( IsDefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
	{
		register_clientflag_callback( "scriptmover", level._ZOMBIE_SCRIPTMOVER_FLAG_ROCK_FX, ::handle_rock_clientside_fx );
	}
	//register_clientflag_callback( "scriptmover", level._ZOMBIE_SCRIPTMOVER_FLAG_BOX_RANDOM, clientscripts\_zombiemode_weapons::weapon_box_callback );
	if( IsDefined( level.riser_fx_on_client ) && level.riser_fx_on_client )
	{
		register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_ZOMBIE_RISER_FX, ::handle_zombie_risers );
		if( !IsDefined( level._no_water_risers ) )
		{
			register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_ZOMBIE_RISER_FX_WATER, ::handle_zombie_risers_water );
		}
		if( IsDefined( level.risers_use_low_gravity_fx ) )
		{
			register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_ZOMBIE_RISER_LOWG_FX, ::handle_zombie_lowg_risers );
		}
	}
}

//=========================================================================================================
// Clientside Board Teardown FX
//=========================================================================================================

handle_horizontal_board_clientside_fx( localClientNum, set, newEnt )
{
	if( set )
	{
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 0, 0, 30 ) );
		realWait( RandomFloat( 0.3, 0.6 ) );
		self thread do_teardown_sound( localClientNum, "plank" );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 0, 0, -30 ) );
	}
	else
	{
		if( IsDefined( level.override_board_repair_sound ) )
		{
			sound = level.override_board_repair_sound;
		}
		else
		{
			sound = "zmb_repair_boards";
		}
		PlaySound( localClientNum, sound, self.origin );
		realWait( 0.3 );
		PlaySound( localClientNum, "zmb_board_slam", self.origin );
		player = GetLocalPlayers()[ localClientNum ];
		player Earthquake( RandomFloatRange( 0.3, 0.4 ), RandomFloatRange( 0.2, 0.4 ), self.origin, 150 );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 0, 0, 30 ) );
		realWait( RandomFloat( 0.3, 0.6 ) );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 0, 0, -30 ) );
	}
}

handle_vertical_board_clientside_fx( localClientNum, set, newEnt )
{
	if( set )
	{
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 30, 0, 0 ) );
		realWait( RandomFloat( 0.3, 0.6 ) );
		self thread do_teardown_sound( localClientNum, "plank" );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( -30, 0, 0 ) );
	}
	else
	{
		if( IsDefined( level.override_board_repair_sound ) )
		{
			sound = level.override_board_repair_sound;
		}
		else
		{
			sound = "zmb_repair_boards";
		}
		PlaySound( localClientNum, sound, self.origin );
		realWait( 0.3 );
		PlaySound( localClientNum, "zmb_board_slam", self.origin );
		player = GetLocalPlayers()[ localClientNum ];
		player Earthquake( RandomFloatRange( 0.3, 0.4 ), RandomFloatRange( 0.2, 0.4 ), self.origin, 150 );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 30, 0, 0 ) );
		realWait( RandomFloat( 0.3, 0.6 ) );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( -30, 0, 0 ) );
	}
}

handle_rock_clientside_fx( localClientNum, set, newEnt )
{
	if( set )
	{
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 30, 0, 0 ) );
		realWait( RandomFloat( 0.3, 0.6 ) );
		self thread do_teardown_sound( localClientNum, "rock" );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( -30, 0, 0 ) );
	}
	else
	{
		PlaySound( 0, "zmb_repair_boards", self.origin );
		player = GetLocalPlayers()[ localClientNum ];
		player Earthquake( RandomFloatRange( 0.3, 0.4 ), RandomFloatRange( 0.2, 0.4 ), self.origin, 150 );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( 30, 0, 0 ) );
		realWait( RandomFloat( 0.3, 0.6 ) );
		PlaySound( localClientNum, "zmb_break_rock_barrier_fix", self.origin );
		PlayFX( localClientNum, level._effect[ "wood_chunk_destory" ], self.origin + ( -30, 0, 0 ) );
	}
}

do_teardown_sound( localClientNum, type )
{
	switch( type )
	{
		case "rock":
			PlaySound( localClientNum, "zmb_break_rock_barrier", self.origin );
			realWait( RandomFloat( 0.3, 0.6 ) );
			PlaySound( localclientnum, "zmb_break_rock_barrier", self.origin );
			break;

		case "plank":
			if(	IsDefined( level.override_board_teardown_sound ) )
			{
				sound = level.override_board_teardown_sound;
			}
			else
			{
				sound = "zmb_break_boards";
			}
			PlaySound( localClientNum, sound, self.origin );
			realWait( RandomFloat( 0.3, 0.6 ) );
			PlaySound( localClientNum, sound, self.origin );
			break;
	}
}

//=========================================================================================================
// Box Monitor
//=========================================================================================================

box_monitor( clientNum, state, oldState )
{
	if( IsDefined( level._custom_box_monitor ) )
	{
		[[ level._custom_box_monitor ]]( clientNum, state, oldState );
	}
}

//=========================================================================================================
// Power Listener
//=========================================================================================================

ZPO_listener()
{
	while( true )
	{
		level waittill( "ZPO" );
		level notify( "power_on" );	
		level notify( "revive_on" );
		level notify( "middle_door_open" );
		level notify( "fast_reload_on" );
		level notify( "doubletap_on" );
		level notify( "divetonuke_on" );
		level notify( "marathon_on" );
		level notify( "jugger_on" );
		level notify( "additionalprimaryweapon_on" );
		level notify( "chugabud_on" );
		level notify( "electriccherry_on" );
		level notify( "widowswine_on" );
	}
}

//=========================================================================================================
// Zombie Eye Glow
//=========================================================================================================

createZombieEyes( localClientNum )
{
	if( IsDefined( self._eyeArray ) )
	{
		if( !IsDefined( self._eyeArray[ localClientNum ] ) )
		{
			fx_name = "eye_glow";
			if( IsDefined( level._override_eye_fx ) )
			{
				fx_name = level._override_eye_fx;
			}
			self._eyeArray[ localClientNum ] = PlayFXOnTag( localClientNum, level._effect[ fx_name ], self, "J_Eyeball_LE" );
		}
	} 
}

deleteZombieEyes( localClientNum )
{
	self vulture_eye_glow_callback_from_system( localClientNum );
	if( IsDefined( self._eyeArray ) )
	{
		if( IsDefined( self._eyeArray[ localClientNum ] ) )
		{
			DeleteFX( localClientNum, self._eyeArray[ localClientNum ], true );
			self._eyeArray[ localClientNum ] = undefined;
		}
	}
}

on_player_connect( localClientNum )
{
	ForceGameModeMappings( localClientNum, "default" );
}

on_player_spawn( localClientNum )
{
	ForceGameModeMappings( localClientNum, "default" );
}

on_zombie_spawn( localClientNum )
{
	self endon( "entityshutdown" );
	if( !IsDefined( self._eyeArray ) )
	{
		self._eyeArray = [];
	}
	wait 0.05;
	if( self HasEyes() )
	{
		self createZombieEyes( localClientNum );
	}
	self MapShaderConstant( localClientNum, 0, "scriptVector0", -4, -1, 0, -1 );
}

zombie_eye_callback( localClientNum, hasEyes )
{
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i ++ )
	{
		if( hasEyes )
		{
			self createZombieEyes( i );
		}
		else
		{
			self deleteZombieEyes( i );
		}
	}
}

//=========================================================================================================
// Perk Machine Lights ( Obsolete )
//=========================================================================================================

init_perk_machines_fx()
{

}

//=========================================================================================================
// Zombie Gibbing
//=========================================================================================================

mark_piece_gibbed( piece_index )
{
	if( !IsDefined( self.gibbed_pieces ) )
	{
		self.gibbed_pieces = [];
	}
	self.gibbed_pieces[ self.gibbed_pieces.size ] = piece_index;
}

has_gibbed_piece( piece_index )
{
	if( !IsDefined( self.gibbed_pieces ) )
	{
		return false;
	}
	for( i = 0; i < self.gibbed_pieces.size; i ++ )
	{
		if( self.gibbed_pieces[i] == piece_index )
		{
			return true;
		}
	}
	return false;
}

do_headshot_gib_fx()
{
	fxOrigin = self GetTagOrigin( "j_neck" );
	upVec = AnglesToUp( self GetTagAngles( "j_neck" ) );
	forwardVec = AnglesToForward( self GetTagAngles( "j_neck" ) );
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i ++ )
	{
		PlayFX( i, level._effect[ "headshot" ], fxOrigin, forwardVec, upVec );
		PlayFX( i, level._effect[ "headshot_nochunks" ], fxOrigin, forwardVec, upVec );
	}
	wait 0.3;
	if( IsDefined( self ) )
	{
		players = GetLocalPlayers();
		for( i = 0; i < players.size; i ++ )
		{
			PlayFXOnTag( i, level._effect[ "bloodspurt" ], self, "j_neck" );
		}
	}
}

do_gib_fx( tag )
{
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i ++ )
	{
		PlayFXOnTag( i, level._effect[ "animscript_gib_fx" ], self, tag );
	}
	PlaySound( 0, "zmb_death_gibs", self GetTagOrigin( tag ) );
}

do_gib( model, tag )
{
	start_pos = self GetTagOrigin( tag );
	start_angles = self GetTagAngles( tag );
	wait 1 / 60;
	if( !IsDefined( self ) )
	{
		end_pos = start_pos + ( AnglesToForward( start_angles ) * 10 );
		angles = start_angles;
	}
	else
	{
		end_pos = self GetTagOrigin( tag );
		angles = self GetTagAngles( tag );
	}
	if( IsDefined( self._gib_vel ) )
	{
		forward = self._gib_vel;
		self._gib_vel = undefined;
	}
	else
	{
		forward = VectorNormalize( end_pos - start_pos );
		forward *= RandomIntRange( 600, 1000 );
		forward += ( 0, 0, RandomIntRange( 400, 700 ) );
	}
	CreateDynEntAndLaunch( 0, model, end_pos, angles, start_pos, forward, level._effect[ "zmb_new_gibtrail_fx" ], 1 );
	if( IsDefined( self ) )
	{
		self do_gib_fx( tag );
	}
	else
	{
		PlaySound( 0, "zmb_death_gibs", end_pos );
	}
}

on_gib_event( localClientNum, type, locations )
{
	if( localClientNum != 0 )
	{
		return;
	}
	if( !is_mature() )
	{
		return;
	}
	if( !IsDefined( self._gib_def ) )
	{
		return;
	}
	if( self._gib_def == -1 )
	{
		return;
	}
	if( IsDefined( level._gib_overload_func ) )
	{
		if( self [[ level._gib_overload_func ]]( type, locations ) )
		{
			return;
		}
	}
	for( i = 0; i < locations.size; i ++ )
	{
		if( IsDefined( self.gibbed ) && level._ZOMBIE_GIB_PIECE_INDEX_HEAD != locations[i] )
		{
			continue;
		}
		switch( locations[i] )
		{
			case 0:
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn1 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag1 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn1, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag1 );
				}
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn2 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag2 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn2, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag2 );
				}
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn3 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag3 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn3, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag3 );
				}
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn4 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag4 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn4, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag4 );
				}
				self thread do_headshot_gib_fx();
				self thread do_gib_fx( "J_SpineLower" );
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_RIGHT_ARM );
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_LEFT_ARM );
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_RIGHT_LEG );
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_LEFT_LEG );
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_HEAD );
				break;

			case 1:
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn1 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag1 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn1, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag1 );
				}
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_RIGHT_ARM );
				break;

			case 2:
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn2 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag2 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn2, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag2 );
				}
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_LEFT_ARM );
				break;

			case 3:
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn3 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag3 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn3, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag3 );
				}
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_RIGHT_LEG );
				break;

			case 4:
				if( IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawn4 ) && IsDefined( level._gibbing_actor_models[ self._gib_def ].gibSpawnTag4 ) )
				{
					self thread do_gib( level._gibbing_actor_models[ self._gib_def ].gibSpawn4, level._gibbing_actor_models[ self._gib_def ].gibSpawnTag4 );
				}
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_LEFT_LEG );
				break;

			case 5:
				self thread do_headshot_gib_fx();
				mark_piece_gibbed( level._ZOMBIE_GIB_PIECE_INDEX_HEAD );
				break;

			case 6:
				self thread do_gib_fx( "J_SpineLower" );
				break;
		} 
	}
	self.gibbed = true;
}

//=========================================================================================================
// Vision System
//=========================================================================================================

zombie_vision_set_apply( str_visionset, int_priority, flt_transition_time, int_clientnum )
{
	self endon( "death" );
	self endon( "disconnect" );
	if( !IsDefined( self._zombie_visionset_list ) )
	{
		self._zombie_visionset_list = [];
	}
	if( !IsDefined( str_visionset ) || !IsDefined( int_priority ) )
	{
		return;
	}
	if( !IsDefined( flt_transition_time ) )
	{
		flt_transition_time = 1;
	}
	already_in_array = false;
	if( self._zombie_visionset_list.size != 0 )
	{
		for( i = 0; i < self._zombie_visionset_list.size; i ++ )
		{
			if( IsDefined( self._zombie_visionset_list[i].vision_set ) && self._zombie_visionset_list[i].vision_set == str_visionset )
			{
				already_in_array = true;
				self._zombie_visionset_list[i].priority = int_priority;
				break;
			}
		}
	}
	if( !already_in_array )
	{
		temp_struct = SpawnStruct();
		temp_struct.vision_set = str_visionset;
		temp_struct.priority = int_priority;
		self._zombie_visionset_list = add_to_array( self._zombie_visionset_list, temp_struct, false );
	}
	vision_to_set = self zombie_highest_vision_set_apply();
	if( IsDefined( vision_to_set ) )
	{
		VisionSetNaked( int_clientnum, vision_to_set, flt_transition_time );
	}
	else
	{
		VisionSetNaked( int_clientnum, "undefined", flt_transition_time );
	}
}

zombie_vision_set_remove( str_visionset, flt_transition_time, int_clientnum )
{
	self endon( "death" );
	self endon( "disconnect" );
	if( !IsDefined( str_visionset ) )
	{
		return;
	}
	if( !IsDefined( flt_transition_time ) )
	{
		flt_transition_time = 1;
	}
	if( !IsDefined( self._zombie_visionset_list ) )
	{
		self._zombie_visionset_list = [];
	}
	temp_struct = undefined;
	for( i = 0; i < self._zombie_visionset_list.size; i ++ )
	{
		if( IsDefined( self._zombie_visionset_list[i].vision_set ) && self._zombie_visionset_list[i].vision_set == str_visionset )
		{
			temp_struct = self._zombie_visionset_list[i];
			break;
		}
	}
	if( IsDefined( temp_struct ) )
	{
		self._zombie_visionset_list = array_remove( self._zombie_visionset_list, temp_struct );
	}
	vision_to_set = self zombie_highest_vision_set_apply();
	if( IsDefined( vision_to_set ) )
	{
		VisionSetNaked( int_clientnum, vision_to_set, flt_transition_time );
	}
	else
	{
		VisionSetNaked( int_clientnum, "undefined", flt_transition_time );
	}
}

zombie_highest_vision_set_apply()
{
	if( !IsDefined( self._zombie_visionset_list ) )
	{
		return;
	}
	highest_score = 0;
	highest_score_vision = undefined;
	for( i = 0; i < self._zombie_visionset_list.size; i ++ )
	{
		if( IsDefined( self._zombie_visionset_list[i].priority ) && self._zombie_visionset_list[i].priority > highest_score )
		{
			highest_score = self._zombie_visionset_list[i].priority;
			highest_score_vision = self._zombie_visionset_list[i].vision_set;
		}
	}
	return highest_score_vision;
}

//=========================================================================================================
// Sidequest Utility
//=========================================================================================================

sidequest_solo_completed_watcher()
{
	level endon( "SQC" );
	level waittill( "SQS" );
	SetCollectible( level.zombie_sidequest_solo_collectible );
}

sidequest_coop_completed_watcher()
{
	level endon( "SQS" );
	level waittill( "SQC" );
	SetCollectible( level.zombie_sidequest_solo_collectible );
	SetCollectible( level.zombie_sidequest_coop_collectible );
}

register_sidequest( solo_collectible, coop_collectible )
{
	level.zombie_sidequest_solo_collectible = solo_collectible;
	level.zombie_sidequest_coop_collectible = coop_collectible;
	level thread sidequest_solo_completed_watcher();
	level thread sidequest_coop_completed_watcher();
}

//=========================================================================================================
// ClientSide Riser FX
//=========================================================================================================

handle_zombie_risers_water( localClientNum, set, newEnt )
{
	self endon( "entityshutdown" );
	if( set )
	{
		PlaySound( localClientNum, "zmb_zombie_spawn_water", self.origin );
		PlayFX( localClientNum, level._effect[ "rise_burst_water" ], self.origin + ( 0, 0, RandomIntRange( 5, 10 ) ) );
		realWait( 0.25 );
		PlayFX( localClientNum, level._effect[ "rise_billow_water"], self.origin + ( RandomIntRange( -10, 10 ), RandomIntRange( -10, 10 ), RandomIntRange( 5, 10 ) ) );
		self thread rise_dust_fx( localClientNum, "water" );
	}
}

handle_zombie_lowg_risers( localClientNum, set, newEnt )
{
	self endon( "entityshutdown" );
	if( set )
	{
		PlaySound( localClientNum, "zmb_zombie_spawn", self.origin );
		PlayFX( localClientNum, level._effect[ "rise_burst_lg" ], self.origin + ( 0, 0, RandomIntRange( 5, 10 ) ) );
		realWait( 0.25 );
		PlayFX( localClientNum, level._effect[ "rise_billow_lg" ], self.origin + ( RandomIntRange( -10, 10 ), RandomIntRange( -10, 10 ), RandomIntRange( 5, 10 ) ) );
		self thread rise_dust_fx( localClientNum, "lowg" );
	}
}

handle_zombie_risers( localClientNum, set, newEnt )
{
	self endon( "entityshutdown" );
	if( set )
	{
		sound = "zmb_zombie_spawn";
		burst_fx = level._effect[ "rise_burst" ];
		billow_fx = level._effect[ "rise_billow" ];
		type = "dirt";
		if( IsDefined( level.riser_type ) && level.riser_type == "snow" )
		{
			sound = "zmb_zombie_spawn_snow";
			burst_fx = level._effect[ "rise_burst_snow" ];
			billow_fx = level._effect[ "rise_billow_snow" ];
			type = "snow";
		}
		PlaySound( localClientNum, sound, self.origin );
		PlayFX( localClientNum, burst_fx, self.origin + ( 0, 0, RandomIntRange( 5, 10 ) ) );
		realWait( 0.25 );
		PlayFX( localClientNum, billow_fx, self.origin + ( RandomIntRange( -10, 10 ), RandomIntRange( -10, 10 ), RandomIntRange( 5, 10 ) ) );
		self thread rise_dust_fx( localClientNum, type );
	}
}

rise_dust_fx( localClientNum, type )
{
	self endon( "entityshutdown" );
	if( !IsDefined( self ) )
	{
		return;
	}
	effect = level._effect[ "rise_dust" ];
	switch( type )
	{
	 	case "water":
			effect = level._effect[ "rise_dust_water" ];
			break;

		case "snow":
			effect = level._effect[ "rise_dust_snow" ];
			break;

		case "lowg":
			effect = level._effect[ "rise_dust_lg" ];
			break;
	}
	for( t = 0; t < 7.5; t += 0.1 )
	{
		if( !IsDefined( self ) )
		{
			return;
		}
		PlayFXOnTag( localClientNum, effect, self, "J_SpineUpper" );
		realWait( 0.1 );
	}
}

//=========================================================================================================
// PHD Flopper
//=========================================================================================================

init_divetonuke()
{
	add_level_notify_callback( "phdflopper_vision", ::zombie_dive2nuke_visionset );
}

zombie_dive2nuke_visionset( localClientNum )
{
	player = GetLocalPlayers()[ localClientNum ];
	player thread zombie_vision_set_apply( "zombie_cosmodrome_diveToNuke", 11, 0, localClientNum );
	realWait( 0.5 );
	player thread zombie_vision_set_remove( "zombie_cosmodrome_diveToNuke", 0.5, localClientNum );
}

//=========================================================================================================
// Deadshot
//=========================================================================================================

init_deadshot()
{
	level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK = 12;
	register_clientflag_callback( "player", level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK, ::player_deadshot_perk_handler );
}

player_deadshot_perk_handler( localClientNum, set, newEnt )
{
	if( !self IsLocalPlayer() || self IsSpectating() || self GetEntityNumber() != GetLocalPlayers()[ localClientNum ] GetEntityNumber() )
	{
		return;
	}
	if( set )
	{
		self UseAlternateAimParams();
	}
	else
	{
		self ClearAlternateAimParams();
	}
}

//=========================================================================================================
// Who's Who
//=========================================================================================================

init_chugabud()
{
	add_level_notify_callback( "chugabud_active", ::whoswhoaudio, "1" );
	add_level_notify_callback( "chugabud_deactive", ::whoswhoaudio, "0" );
}

whoswhoaudio( localclientnum, state )
{
	if( state == "1" )
	{
		activatewwaudio( localclientnum );
	}
	else
	{
		deactivatewwaudio( localclientnum );
	}
}

activatewwaudio( localclientnum )
{
	if( !IsDefined( level.sndwwent ) )
	{
		level.sndwwent = Spawn( 0, ( 0, 0, 0 ), "script_origin" );
	}
	PlaySound( 0, "evt_ww_activate", ( 0, 0, 0 ) );
	level.sndwwent PlayLoopSound( "evt_ww_looper", 3 );
	//clientscripts\_audio::snd_set_snapshot( "zmb_duck_ww" );
	player = GetLocalPlayers()[ localclientnum ];
	player thread zombie_vision_set_apply( "_xS78_whoswho", 50, 0, localclientnum );
}

deactivatewwaudio( localclientnum )
{
	if( IsDefined( level.sndwwent ) )
	{
		level.sndwwent Delete();
		level.sndwwent = undefined;
	}
	PlaySound( 0, "evt_ww_deactivate", ( 0, 0, 0 ) );
	//clientscripts\_audio::snd_set_snapshot( "default" );
	player = GetLocalPlayers()[ localclientnum ];
	player thread zombie_vision_set_remove( "_xS78_whoswho", 0, localclientnum );
}

//=========================================================================================================
// Electric Cherry
//=========================================================================================================

init_electric_cherry()
{
	level._ZOMBIE_PLAYER_FLAG_ELECTRIC_CHERRY_RELOAD_FX = 13;
	register_clientflag_callback( "player", level._ZOMBIE_PLAYER_FLAG_ELECTRIC_CHERRY_RELOAD_FX, ::init_electric_cherry_reload_fx );
}

init_electric_cherry_reload_fx( localclientnum, set, newEnt )
{
	add_level_notify_callback( "cherry_fx_cancel_" + self GetEntityNumber(), ::electric_cherry_reload_attack_fx, self, 0 );
	add_level_notify_callback( "cherry_fx_small_" + self GetEntityNumber(), ::electric_cherry_reload_attack_fx, self, 1 );
	add_level_notify_callback( "cherry_fx_medium_" + self GetEntityNumber(), ::electric_cherry_reload_attack_fx, self, 2 );
	add_level_notify_callback( "cherry_fx_large_" + self GetEntityNumber(), ::electric_cherry_reload_attack_fx, self, 3 );
}

electric_cherry_reload_attack_fx( localclientnum, player, newval )
{
	if( IsDefined( player.electric_cherry_reload_fx ) )
	{
		StopFX( localclientnum, player.electric_cherry_reload_fx );
	}
	if( newval == 1 )
	{
		player.electric_cherry_reload_fx = PlayFXOnTag( localclientnum, level._effect[ "electric_cherry_reload_small" ], player, "tag_origin" );
	}
	else if( newval == 2 )
	{
		player.electric_cherry_reload_fx = PlayFXOnTag( localclientnum, level._effect[ "electric_cherry_reload_medium" ], player, "tag_origin" );
	}
	else if( newval == 3 )
	{
		player.electric_cherry_reload_fx = PlayFXOnTag( localclientnum, level._effect[ "electric_cherry_reload_large" ], player, "tag_origin" );
	}
	else
	{
		if( IsDefined( player.electric_cherry_reload_fx ) )
		{
			StopFX( localclientnum, player.electric_cherry_reload_fx );
		}
		player.electric_cherry_reload_fx = undefined;
	}
}

//=========================================================================================================
// Widow's Wine
//=========================================================================================================

init_widows_wine()
{
	add_level_notify_callback( "widows_wine_1p_contact_explosion", ::widows_wine_1p_contact_explosion );
	level._ZOMBIE_ACTOR_FLAG_WIDOWS_WINE_WRAPPING = widows_wine_clientflag_override();
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_WIDOWS_WINE_WRAPPING, ::widows_wine_wrap_cb );
}

widows_wine_clientflag_override()
{
	if( IsDefined( level.widows_wine_perk_clientflag_override ) )
	{
		return level.widows_wine_perk_clientflag_override;
	}
	return 7;
}

widows_wine_wrap_cb( localClientNum, set, newEnt )
{
	if( set )
	{
		if( IsDefined( self ) && IsAlive( self ) )
		{
			if( !IsDefined( self.fx_widows_wine_wrap ) )
			{
				self.fx_widows_wine_wrap = PlayFXOnTag( localClientNum, level._effect[ "widows_wine_wrap" ], self, "j_spineupper" );
			}
			if( !IsDefined( self.sndWidowsWine ) )
			{
				self PlaySound( 0, "wpn_wwgrenade_cocoon_imp" );
				self.sndWidowsWine = self PlayLoopSound( "wpn_wwgrenade_cocoon_lp", 0.1 );
			}
		}
	}
	else
	{
		if( IsDefined( self.fx_widows_wine_wrap ) )
		{
			StopFX( localClientNum, self.fx_widows_wine_wrap );
			self.fx_widows_wine_wrap = undefined;
		}
		if( IsDefined( self.sndWidowsWine ) )
		{
			self PlaySound( 0, "wpn_wwgrenade_cocoon_stop" );
			self StopLoopSound( 0.1 );
		}
	}
}

widows_wine_1p_contact_explosion( localClientNum )
{
	level thread widows_wine_1p_contact_explosion_play( localClientNum );
}

widows_wine_1p_contact_explosion_play( localClientNum )
{
	fx_contact_explosion = PlayViewmodelFX( localClientNum, level._effect[ "widows_wine_exp_1p" ], "tag_flash" );
	realWait( 2 );
	DeleteFX( localClientNum, fx_contact_explosion, true );
}

//=========================================================================================================
// Utility
//=========================================================================================================

add_level_notify_callback( message, callback_func, arg1, arg2, arg3 )
{
    level thread level_notify_callback_think( message, callback_func, arg1, arg2, arg3 );
	
	if(message == "zblood_on")
	{
		level waittill( "zblood_on", localclientnum );
		//iprintlnbold("zblood_on came" + localClientNum);
	
	} else if (message == "zblood_off")
	{

		level waittill( "power_on", localclientnum );
		//iprintlnbold("zblood_off came" + localClientNum);
	
	}
	
}

level_notify_callback_think( message, callback_func, arg1, arg2, arg3 )
{
    while( true )
    {
		//iprintlnbold("Waiting for message " + message);
        level waittill( message, localclientnum );
		//iprintlnbold("Received message " + message);
        if( IsDefined( arg1 ) && IsDefined( arg2 ) && IsDefined( arg3 ) )
        {
            level thread [[ callback_func ]]( localclientnum, arg1, arg2, arg3 );
        }
        else if( IsDefined( arg1 ) && IsDefined( arg2 ) )
        {
            level thread [[ callback_func ]]( localclientnum, arg1, arg2 );
        }
        else if( IsDefined( arg1 ) )
        {
            level thread [[ callback_func ]]( localclientnum, arg1 );
        }
        else
        {
            level thread [[ callback_func ]]( localclientnum );
        }
    }
}


//=========================================================================================================
// Zombie Blood
//=========================================================================================================

init_zombie_blood()
{
	//iprintlnbold("zombieblood init");
	//level thread add_level_notify_callback( "zblood_on", ::zblood_vision, "1" );
	//level thread add_level_notify_callback( "zblood_off", ::zblood_vision, "0" );
}

zblood_vision( localclientnum, state )
{
	iprintlnbold("zblood vision  :  " + localClientNum );
	player = GetLocalPlayers()[ localclientnum ];
	if( state == "1" )
	{
		player thread zombie_vision_set_apply( "zombie_blood", 49, 0.65, localclientnum );
		player thread zombie_blood_change_fov();
	}
	else
	{
		player thread zombie_vision_set_remove( "zombie_blood", 0.45, localclientnum );
		player thread zombie_blood_reset_fov();
	}
}

zombie_blood_change_fov()
{
	self endon( "disconnect" );
	self endon( "zombie_blood_over" );
	/* start_time = GetRealTime();
	while( GetRealTime() - start_time < 1000 )
	{
		progress = ( GetRealTime() - start_time ) / 1000;
		SetClientDvar( "cg_fovscale", 1 + ( 0.2 * progress ) );
		wait 1 / 60;
	} */
	//SetClientDvar( "cg_fovscale", 1.2 );
	SetClientDvar( "cg_fovscale", GetDvar("cg_fovscale") + 0.2 );
}

zombie_blood_reset_fov()
{
	self notify( "zombie_blood_over" );
	SetClientDvar( "cg_fovscale", GetDvar("cg_fovscale") - 0.2 );
}

//=========================================================================================================
// Client Side Fx/Sounds
//=========================================================================================================

init_client_side_fx()
{
	level.client_side_fx = [];
	level.client_side_sound = [];
	registerSystem( "client_side_fx", ::handle_client_side_fx );
}

handle_client_side_fx( localClientNum, state, oldState )
{
	tokens = StrTok( state, "|" );
	if( tokens[0] == "fx" )
	{
		if( tokens[1] == "looping" )
		{
			if( tokens[2] == "start" )
			{
				if( !IsDefined( level.client_side_fx[ localClientNum ] ) )
				{
					level.client_side_fx[ localClientNum ] = [];
				}
				if( !IsDefined( level.client_side_fx[ localClientNum ][ tokens[3] ] ) )
				{
					origin = ( string_to_float( tokens[5] ), string_to_float( tokens[6] ), string_to_float( tokens[7] ) );
					angles = ( string_to_float( tokens[8] ), string_to_float( tokens[9] ), string_to_float( tokens[10] ) );
					level.client_side_fx[ localClientNum ][ tokens[3] ] = PlayFX( localClientNum, level._effect[ tokens[4] ], origin, AnglesToForward( angles ), AnglesToUp( angles ) );
				}
			}
			else
			{
				if( IsDefined( level.client_side_fx[ localClientNum ] ) && IsDefined( level.client_side_fx[ localClientNum ][ tokens[3] ] ) )
				{
					DeleteFX( localClientNum, level.client_side_fx[ localClientNum ][ tokens[3] ], tokens[4] == "true" );
					level.client_side_fx[ localClientNum ][ tokens[3] ] = undefined;
				}
			}
		}
		else
		{
			origin = ( string_to_float( tokens[3] ), string_to_float( tokens[4] ), string_to_float( tokens[5] ) );
			angles = ( string_to_float( tokens[6] ), string_to_float( tokens[7] ), string_to_float( tokens[8] ) );
			PlayFX( localClientNum, level._effect[ tokens[2] ], origin, AnglesToForward( angles ), AnglesToUp( angles ) );
		}
	}
	else
	{
		if( tokens[1] == "looping" )
		{
			if( tokens[2] == "start" )
			{
				if( !IsDefined( level.client_side_sound[ localClientNum ] ) )
				{
					level.client_side_sound[ localClientNum ] = [];
				}
				if( !IsDefined( level.client_side_sound[ localClientNum ][ tokens[3] ] ) )
				{
					origin = ( string_to_float( tokens[5] ), string_to_float( tokens[6] ), string_to_float( tokens[7] ) );
					info = [];
					info[ "entId" ] = SpawnFakeEnt( localClientNum );
					SetFakeEntOrg( localClientNum, info[ "entId" ], origin );
					info[ "soundId" ] = PlayLoopSound( localClientNum, info[ "entId" ], tokens[4], string_to_float( tokens[8] ) );
					level.client_side_sound[ localClientNum ][ tokens[3] ] = info;
				}
			}
			else
			{
				if( IsDefined( level.client_side_sound[ localClientNum ] ) && IsDefined( level.client_side_sound[ localClientNum ][ tokens[3] ] ) )
				{
					level thread stop_loop_sound( localClientNum, level.client_side_sound[ localClientNum ][ tokens[3] ], string_to_float( tokens[4] ) );
					level.client_side_sound[ localClientNum ][ tokens[3] ] = undefined;
				}
			}
		}
		else
		{
			origin = ( string_to_float( tokens[3] ), string_to_float( tokens[4] ), string_to_float( tokens[5] ) );
			PlaySound( localClientNum, tokens[2], origin );
		}
	}
}

string_to_float( string )
{
	floatParts = StrTok( string, "." );
	if( floatParts.size == 1 )
	{
		return Int( floatParts[0] );
	}
	whole = Int( floatParts[0] );
	decimal = 0;
	for( i = floatParts[1].size - 1; i >= 0; i -- )
	{
		decimal = decimal / 10 + Int( floatParts[1][i] ) / 10;
	}
	if( whole >= 0 )
	{
		return whole + decimal;
	}
	else
	{
		return whole - decimal;
	}
}

stop_loop_sound( localClientNum, sound_array, fade_time )
{
	StopLoopSound( localClientNum, sound_array[ "entId" ], fade_time );
	clientscripts\_audio::soundwait( sound_array[ "soundId" ] );
	DeleteFakeEnt( localClientNum, sound_array[ "entId" ] );
}

//=========================================================================================================
// Vulture Aid
//=========================================================================================================

init_vulture()
{
	level.perk_vulture_array_stink_zombies = [];
	level.perk_vulture_array_stink_drop_locations = [];
	level.perk_vulture_vulture_vision_powerups = [];
	level.perk_vulture_vulture_vision_actors_eye_glow = [];
	level.perk_vulture_players_with_vulture_perk = [];
	add_level_notify_callback( "vulture_active_1", ::vulture_toggle, "1" );
	add_level_notify_callback( "vulture_active_0", ::vulture_toggle, "0" );
	add_level_notify_callback( "vulture_stink_sound_1", ::sndvulturestink, "1" );
	add_level_notify_callback( "vulture_stink_sound_0", ::sndvulturestink, "0" );
	level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_POWERUP_DROP = 12;
	level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_STINK_FX = 13;
	level._ZOMBIE_ACTOR_FLAG_VULTURE_STINK_TRAIL_FX = 3;
	level._ZOMBIE_ACTOR_FLAG_VULTURE_EYE_GLOW = 4;
	register_clientflag_callback( "scriptmover", level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_POWERUP_DROP, ::vulture_powerup_drop );
	register_clientflag_callback( "scriptmover", level._ZOMBIE_SCRIPTMOVER_FLAG_VULTURE_STINK_FX, ::vulture_stink_fx );
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_VULTURE_STINK_TRAIL_FX, ::vulture_stink_trail_fx );
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_VULTURE_EYE_GLOW, ::vulture_eye_glow );
}

vulture_toggle( localclientnumber, newval )
{
	if( newval == "1" )
	{
		level.perk_vulture_players_with_vulture_perk[ localclientnumber ] = true;
		for( i = 0; i < level.perk_vulture_array_stink_zombies.size; i ++ )
		{
			zombie = level.perk_vulture_array_stink_zombies[i];
			zombie _stink_trail_enable( localclientnumber );
		}
		for( i = 0; i < level.perk_vulture_array_stink_drop_locations.size; i ++ )
		{
			ent = level.perk_vulture_array_stink_drop_locations[i];
			ent _stink_fx_enable( localclientnumber );
		}
		for( i = 0; i < level.perk_vulture_vulture_vision_powerups.size; i ++ )
		{
			powerup = level.perk_vulture_vulture_vision_powerups[i];
			powerup _powerup_drop_fx_enable( localclientnumber );
		}
		for( i = 0; i < level.perk_vulture_vulture_vision_actors_eye_glow.size; i ++ )
		{
			zombie = level.perk_vulture_vulture_vision_actors_eye_glow[i];
			zombie _zombie_eye_glow_enable( localclientnumber );
		}
	}
	else
	{
		level.perk_vulture_players_with_vulture_perk[ localclientnumber ] = undefined;
		level.perk_vulture_array_stink_zombies = array_removeUndefined( level.perk_vulture_array_stink_zombies );
		level.perk_vulture_vulture_vision_actors_eye_glow = array_removeUndefined( level.perk_vulture_vulture_vision_actors_eye_glow );
		for( i = 0; i < level.perk_vulture_array_stink_zombies.size; i ++ )
		{
			zombie = level.perk_vulture_array_stink_zombies[i];
			zombie _stink_trail_disable( localclientnumber );
		}
		for( i = 0; i < level.perk_vulture_array_stink_drop_locations.size; i ++ )
		{
			ent = level.perk_vulture_array_stink_drop_locations[i];
			ent _stink_fx_disable( localclientnumber );
		}
		for( i = 0; i < level.perk_vulture_vulture_vision_powerups.size; i ++ )
		{
			powerup = level.perk_vulture_vulture_vision_powerups[i];
			powerup _powerup_drop_fx_disable( localclientnumber );
		}
		for( i = 0; i < level.perk_vulture_vulture_vision_actors_eye_glow.size; i ++ )
		{
			zombie = level.perk_vulture_vulture_vision_actors_eye_glow[i];
			zombie _zombie_eye_glow_disable( localclientnumber );
		}
	}
}

vulture_eye_glow( localclientnumber, set, newEnt )
{
	if( set )
	{
		self thread _zombie_eye_glow_think();
		self _zombie_eye_glow_enable( localclientnumber );
	}
	else
	{
		self _zombie_eye_glow_disable( localclientnumber );
	}
}

vulture_eye_glow_callback_from_system( localclientnumber )
{
	self _zombie_eye_glow_disable( localclientnumber );
}

vulture_powerup_drop( localclientnumber, set, newEnt )
{
	if( set )
	{
		level.perk_vulture_vulture_vision_powerups[ level.perk_vulture_vulture_vision_powerups.size ] = self;
		self _powerup_drop_fx_enable( localclientnumber );
	}
	else
	{
		level.perk_vulture_vulture_vision_powerups = array_remove_nokeys( level.perk_vulture_vulture_vision_powerups, self );
		level.perk_vulture_vulture_vision_powerups = array_removeUndefined( level.perk_vulture_vulture_vision_powerups );
		self _powerup_drop_fx_disable( localclientnumber );
	}
}

vulture_stink_fx( localclientnumber, set, newEnt )
{
	if( set )
	{
		level.perk_vulture_array_stink_drop_locations[ level.perk_vulture_array_stink_drop_locations.size ] = self;
		self _stink_fx_enable( localclientnumber );
	}
	else
	{
		level.perk_vulture_array_stink_drop_locations = array_remove_nokeys( level.perk_vulture_array_stink_drop_locations, self );
		level.perk_vulture_array_stink_drop_locations = array_removeUndefined( level.perk_vulture_array_stink_drop_locations );
		self _stink_fx_disable( localclientnumber );
	}
}

vulture_stink_trail_fx( localclientnumber, set, newEnt )
{
	if( set )
	{
		level.perk_vulture_array_stink_zombies[ level.perk_vulture_array_stink_zombies.size ] = self;
		self _stink_trail_enable( localclientnumber );
	}
	else
	{
		level.perk_vulture_array_stink_zombies = array_remove_nokeys( level.perk_vulture_array_stink_zombies, self );
		level.perk_vulture_array_stink_zombies = array_removeUndefined( level.perk_vulture_array_stink_zombies );
		self _stink_trail_disable( localclientnumber );
	}
}

_powerup_drop_fx_enable( localclientnumber )
{
	if( IsDefined( self ) )
	{
		if( !IsDefined( self.perk_vulture_fx_id ) )
		{
			self.perk_vulture_fx_id = [];
		}
		if( _player_has_vulture( localclientnumber ) )
		{
			self.perk_vulture_fx_id[ localclientnumber ] = PlayFX( localclientnumber, level._effect[ "vulture_perk_powerup_drop" ], self.origin );
		}
	}
}

_powerup_drop_fx_disable( localclientnumber )
{
	if( IsDefined( self ) && IsDefined( self.perk_vulture_fx_id ) && IsDefined( self.perk_vulture_fx_id[ localclientnumber ] ) )
	{
		DeleteFX( localclientnumber, self.perk_vulture_fx_id[ localclientnumber ], true );
	}
}

_stink_trail_enable( localclientnumber )
{
	if( IsDefined( self ) && _player_has_vulture( localclientnumber ) )
	{
		self thread _loop_stink_trail( localclientnumber );
	}
}

_loop_stink_trail( localclientnumber )
{
	self endon( "vulture_stop_stink_trail_fx" );
	if( !IsDefined( self.perk_vulture_stink_trail ) )
	{
		self.perk_vulture_stink_trail = [];
	}
	if( !IsDefined( self.sndent ) )
	{
		self.sndent = Spawn( 0, self.origin, "script_origin" );
		self.sndent LinkTo( self );
	}
	sndent = self.sndent;
	sndent PlayLoopSound( "zmb_vulture_stink_loop", 1 );
	self thread sndloopstinktraildelete( sndent );
	while( IsDefined( self ) )
	{
		self.perk_vulture_stink_trail[ localclientnumber ] = PlayFX( localclientnumber, level._effect[ "vulture_perk_zombie_stink_trail" ], self.origin );
		realWait( 0.1 );
	}
	if( IsDefined( sndent ) )
	{
		sndent StopLoopSound();
		sndent Delete();
	}
}

sndloopstinktraildelete( sndent )
{
	self endon( "death" );
	self waittill( "vulture_stop_stink_trail_fx" );
	if( IsDefined( sndent ) )
	{
		sndent StopLoopSound();
		sndent Delete();
	}
}

_stink_trail_disable( localclientnumber )
{
	if( IsDefined( self ) )
	{
		self notify( "vulture_stop_stink_trail_fx" );
		if( IsDefined( self.perk_vulture_stink_trail ) && IsDefined( self.perk_vulture_stink_trail[ localclientnumber ] ) )
		{
			DeleteFX( localclientnumber, self.perk_vulture_stink_trail[ localclientnumber ], false );
		}
	}
}

_stink_fx_enable( localclientnumber )
{
	if( IsDefined( self ) && _player_has_vulture( localclientnumber ) )
	{
		self thread _loop_stink_stationary( localclientnumber );
	}
}

_loop_stink_stationary( localclientnumber )
{
	self endon( "vulture_stop_stink_fx" );
	if( !IsDefined( self.perk_vulture_fx ) )
	{
		self.perk_vulture_fx = [];
	}
	sndorigin = self.origin;
	SoundLoopEmitter( "zmb_vulture_stink_loop", sndorigin );
	self thread sndloopstinkstationarydelete( sndorigin );
	while( IsDefined( self ) )
	{
		self.perk_vulture_fx[ localclientnumber ] = PlayFX( localclientnumber, level._effect[ "vulture_perk_zombie_stink" ], self.origin );
		realWait( 0.125 );
	}
	SoundStopLoopEmitter( "zmb_vulture_stink_loop", sndorigin );
}

sndloopstinkstationarydelete( sndorigin )
{
	self endon( "death" );
	self waittill( "vulture_stop_stink_fx" );
	if( IsDefined( sndorigin ) )
	{
		SoundStopLoopEmitter( "zmb_vulture_stink_loop", sndorigin );
	}
}

_stink_fx_disable( localclientnumber, b_kill_fx_immediately )
{
	if( IsDefined( self ) )
	{
		self notify( "vulture_stop_stink_fx" );
		if( IsDefined( self.perk_vulture_fx ) && IsDefined( self.perk_vulture_fx[ localclientnumber ] ) )
		{
			DeleteFX( localclientnumber, self.perk_vulture_fx[ localclientnumber ], true );
		}
	}
}

_zombie_eye_glow_think()
{
	level.perk_vulture_vulture_vision_actors_eye_glow[ level.perk_vulture_vulture_vision_actors_eye_glow.size ] = self;
	self waittill_any( "vulture_eye_glow_disable", "death", "entityshutdown" );
	level.perk_vulture_vulture_vision_actors_eye_glow = array_remove_nokeys( level.perk_vulture_vulture_vision_actors_eye_glow, self );
	level.perk_vulture_vulture_vision_actors_eye_glow = array_removeUndefined( level.perk_vulture_vulture_vision_actors_eye_glow );
}

_zombie_eye_glow_enable( localclientnumber )
{
	if( IsDefined( self ) && _player_has_vulture( localclientnumber ) )
	{
		if( !IsDefined( self.perk_vulture_fx_id ) )
		{
			self.perk_vulture_fx_id = [];
		}
		n_fx_id = level._effect[ "vulture_perk_zombie_eye_glow" ];
		if( IsDefined( level.perk_vulture_vulture_vision_actors_eye_glow_override ) )
		{
			n_fx_id = level.perk_vulture_vulture_vision_actors_eye_glow_override;
		}
		if( IsDefined( self.vulture_perk_actor_eye_glow_override ) )
		{
			n_fx_id = self.vulture_perk_actor_eye_glow_override;
		}
		self.perk_vulture_fx_id[ localclientnumber ] = PlayFXOnTag( localclientnumber, n_fx_id, self, "J_Eyeball_LE" );
	}
}

set_vulture_custom_eye_glow( n_fx_id )
{
	level.perk_vulture_vulture_vision_actors_eye_glow_override = n_fx_id;
}

_zombie_eye_glow_disable( localclientnumber )
{
	self notify( "vulture_eye_glow_disable" );
	if( IsDefined( self ) && IsDefined( self.perk_vulture_fx_id ) && IsDefined( self.perk_vulture_fx_id[ localclientnumber ] ) )
	{
		DeleteFX( localclientnumber, self.perk_vulture_fx_id[ localclientnumber ], true );
	}
}

_player_has_vulture( localclientnumber )
{
	return IsDefined( level.perk_vulture_players_with_vulture_perk[ localclientnumber ] );
}

sndvulturestink( localclientnum, state )
{
	player = GetLocalPlayers()[ localclientnum ];
	if( state == "1" )
	{
		player thread sndactivatevulturestink();
	}
	else
	{
		player thread snddeactivatevulturestink();
	}
}

sndactivatevulturestink()
{
	if( !IsDefined( self.sndstinkent ) )
	{
		self.sndstinkent = Spawn( 0, ( 0, 0, 0 ), "script_origin" );
		self.sndstinkent PlayLoopSound( "zmb_vulture_stink_player_loop", 0.5 );
	}
	PlaySound( 0, "zmb_vulture_stink_player_start", ( 0, 0, 0 ) );
	//clientscripts\_audio::snd_set_snapshot( "zmb_buried_stink" );
}

snddeactivatevulturestink()
{
	PlaySound( 0, "zmb_vulture_stink_player_stop", ( 0, 0, 0 ) );
	clientscripts\_audio::snd_set_snapshot( "default" );
	if( IsDefined( self.sndstinkent ) )
	{
		self.sndstinkent StopLoopSound();
		self.sndstinkent Delete();
		self.sndstinkent = undefined;
	}
}

//=========================================================================================================
// Low Health Sound
//=========================================================================================================

init_lowhealth_sound()
{
	add_level_notify_callback( "lowhealth_sound_start", ::lowhealth_sound_think );
	add_level_notify_callback( "lowhealth_sound_end", ::lowhealth_notify_watcher, "lowhealth_sound_end" );
	add_level_notify_callback( "lowhealth_sound_end_laststand", ::lowhealth_notify_watcher, "lowhealth_sound_end_laststand" );
}

lowhealth_sound_think( localclientnum )
{
	PlaySound( localclientnum, "evt_zmb_dlchd_lowhealth_enter", ( 0, 0, 0 ) );
	soundent = Spawn( localclientnum, ( 0, 0, 0 ), "script_origin" );
	soundent PlayLoopSound( "evt_zmb_dlchd_lowhealth_loop" );
	player = GetLocalPlayers()[ localclientnum ];
	evt = player waittill_any_return( "lowhealth_sound_end", "lowhealth_sound_end_laststand" );
	soundent StopLoopSound();
	soundent Delete();
	if( evt == "lowhealth_sound_end" )
	{
		PlaySound( localclientnum, "evt_zmb_dlchd_lowhealth_end", ( 0, 0, 0 ) );
	}
}

lowhealth_notify_watcher( localclientnum, notification )
{
	player = GetLocalPlayers()[ localclientnum ];
	player notify( notification );
}