#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_audio;

init()
{

	init_includes();
	init_weapons();
	init_weapon_upgrade();
	init_weapon_toggle();
	init_pay_turret();
//	init_weapon_cabinet();
	treasure_chest_init();
	level thread add_limited_tesla_gun();

	PreCacheShader( "minimap_icon_mystery_box" );
	PrecacheShader( "specialty_instakill_zombies" );
	PrecacheShader( "specialty_firesale_zombies" );

	level._zombiemode_check_firesale_loc_valid_func = ::default_check_firesale_loc_valid_func;
}

default_check_firesale_loc_valid_func()
{
	return true;
}

add_zombie_weapon( weapon_name, upgrade_name, hint, cost, weaponVO, weaponVOresp, ammo_cost, add_without_include )
{
	if(!IsDefined(add_without_include))
	{
		add_without_include = false;
	}

	if( IsDefined( level.zombie_include_weapons ) && !IsDefined( level.zombie_include_weapons[weapon_name] ) && !add_without_include )
	{
		return;
	}

	// Check the table first
	table = "mp/zombiemode.csv";
	table_cost = TableLookUp( table, 0, weapon_name, 1 );
	table_ammo_cost = TableLookUp( table, 0, weapon_name, 2 );

	if( IsDefined( table_cost ) && table_cost != "" )
	{
		cost = round_up_to_ten( int( table_cost ) );
	}

	if( IsDefined( table_ammo_cost ) && table_ammo_cost != "" )
	{
		ammo_cost = round_up_to_ten( int( table_ammo_cost ) );
	}

	PrecacheString( hint );

	struct = SpawnStruct();

	if( !IsDefined( level.zombie_weapons ) )
	{
		level.zombie_weapons = [];
	}

	struct.weapon_name = weapon_name;
	struct.upgrade_name = upgrade_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.vox = weaponVO;
	struct.vox_response = weaponVOresp;
	struct.is_in_box = level.zombie_include_weapons[weapon_name];

	if( !IsDefined( ammo_cost ) )
	{
		if(weapon_name == "sticky_grenade_zm")
			ammo_cost = cost;
		else if(weapon_name == "kar98k_scoped_zombie")
			ammo_cost = int( cost * 0.25 );
		else
			ammo_cost = round_up_to_ten( int( cost * 0.5 ) );
	}

	struct.ammo_cost = ammo_cost;

	level.zombie_weapons[weapon_name] = struct;
}

default_weighting_func()
{
	return 1;
}

default_tesla_weighting_func()
{
	num_to_add = 1;
	if( isDefined( level.pulls_since_last_tesla_gun ) )
	{
		// player has dropped the tesla for another weapon, so we set all future polls to 20%
		if( isDefined(level.player_drops_tesla_gun) && level.player_drops_tesla_gun == true )
		{
			num_to_add += int(.2 * level.zombie_include_weapons.size);
		}

		// player has not seen tesla gun in late rounds
		if( !isDefined(level.player_seen_tesla_gun) || level.player_seen_tesla_gun == false )
		{
			// after round 10 the Tesla gun percentage increases to 20%
			if( level.round_number > 10 )
			{
				num_to_add += int(.2 * level.zombie_include_weapons.size);
			}
			// after round 5 the Tesla gun percentage increases to 15%
			else if( level.round_number > 5 )
			{
				// calculate the number of times we have to add it to the array to get the desired percent
				num_to_add += int(.15 * level.zombie_include_weapons.size);
			}
		}
	}
	return num_to_add;
}


//
//	For weapons which should only appear once the box moves
default_1st_move_weighting_func()
{
	if( level.chest_moves > 0 )
	{
		num_to_add = 1;

		return num_to_add;
	}
	else
	{
		return 0;
	}
}


//
//	Default weighting for a high-level weapon that is too good for the normal box
default_upgrade_weapon_weighting_func()
{
	if ( level.chest_moves > 1 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}


//
//	Slightly elevate the chance to get it until someone has it, then make it even
default_cymbal_monkey_weighting_func()
{
	players = get_players();
	count = 0;
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] has_weapon_or_upgrade( "zombie_cymbal_monkey" ) )
		{
			count++;
		}
	}
	if ( count > 0 )
	{
		return 1;
	}
	else
	{
		if( level.round_number < 10 )
		{
			return 3;
		}
		else
		{
			return 5;
		}
	}
}


is_weapon_included( weapon_name )
{
	if( !IsDefined( level.zombie_weapons ) )
	{
		return false;
	}

	return IsDefined( level.zombie_weapons[weapon_name] );
}


include_zombie_weapon( weapon_name, in_box, collector, weighting_func )
{
	if( !IsDefined( level.zombie_include_weapons ) )
	{
		level.zombie_include_weapons = [];
		level.collector_achievement_weapons = [];
	}
	if( !isDefined( in_box ) )
	{
		in_box = true;
	}
	if( isDefined( collector ) && collector )
	{
		level.collector_achievement_weapons = array_add( level.collector_achievement_weapons, weapon_name );
	}

	level.zombie_include_weapons[weapon_name] = in_box;

	PrecacheItem( weapon_name );

	if( !isDefined( weighting_func ) )
	{
		level.weapon_weighting_funcs[weapon_name] = maps\_zombiemode_weapons::default_weighting_func;
	}
	else
	{
		level.weapon_weighting_funcs[weapon_name] = weighting_func;
	}
}


//
//Z2 add_zombie_weapon will call PrecacheItem on the weapon name.  So this means we're loading
//		the model even if we're not using it?  This could save some memory if we change this.
init_weapons()
{
	// Zombify
	//	PrecacheItem( "zombie_melee" );

	//add_zombie_weapon( weapon_name, 				upgrade_name, 							hint, 									cost, 	weaponVO, weaponVOresp, 	ammo_cost, add_without_include )

	isWawMap = false;
	mapname = 	ToLower(GetDvar(#"mapname"));
	switch( mapname )
	{
		case "zombie_cod5_prototype":
		case "zombie_cod5_asylum":
		case "zombie_cod5_sumpf":
		case "zombie_cod5_factory":
		  isWawMap = true;
		  break;
	}
	
	/**************************
		Melee
	**************************/

	//Base
	add_zombie_weapon( "combat_knife_zm",			undefined,								&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		50,		"bowie",			"",		undefined );
	//add_zombie_weapon( "combat_bowie_knife_zm",		undefined,								&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		50,		"bowie",			"",		undefined );
	//add_zombie_weapon( "combat_sickle_knife_zm",	undefined,								&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		50,		"sickle",			"",		undefined );

	add_zombie_weapon( "rebirth_hands_sp",					undefined,								&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		50,		"bowie",			"",		undefined );
	add_zombie_weapon( "vorkuta_knife_sp",					undefined,								&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		50,		"bowie",			"",		undefined );
	add_zombie_weapon( "falling_hands_zm",			undefined,								&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		50,		"bowie",			"",		undefined );

	//Upgrade - none

	//Total: 6 base, 0 upgraded = 6
	/***** END MELEE *****/


	/**************************
		Grenades
	**************************/

	//Base
	if( isWawMap )
	{
		//Waw
		add_zombie_weapon( "molotov_zm", 				undefined,								&"ZOMBIE_WEAPON_FRAG_GRENADE",			250,	"grenade",			"",		undefined );
		add_zombie_weapon( "stielhandgranate", "", 						&"WAW_ZOMBIE_WEAPON_STIELHANDGRANATE_250", 		1000,	"grenade", "", 1000 );
		add_zombie_weapon( "mine_bouncing_betty", "", &"WAW_ZOMBIE_WEAPON_SATCHEL_2000", 2000 );

	}
	else
	{
		add_zombie_weapon( "frag_grenade_zm", 			undefined,								&"ZOMBIE_WEAPON_FRAG_GRENADE",			1000,	"grenade",			"",		undefined );
		add_zombie_weapon( "sticky_grenade_zm", 		undefined,								&"ZOMBIE_WEAPON_STICKY_GRENADE",		1000,	"grenade",			"",		undefined );
		add_zombie_weapon( "claymore_zm", 				undefined,								&"ZOMBIE_WEAPON_CLAYMORE",				1000,	"grenade",			"",		undefined );
		//gerch map specific
		//dolls map specific
	}
	
	add_zombie_weapon( "zombie_cymbal_monkey",		undefined,								&"ZOMBIE_WEAPON_SATCHEL_2000", 			2000,	"monkey",			"",		undefined );
	add_zombie_weapon( "bo3_zm_widows_grenade",		undefined,								&"REIMAGINED_WINE_GRENADES", 		2000,	"webnades",	"",		undefined );

	//Upgrade - none

	//Total: 6 base, 0 upgraded = 10
	/***** END GRENADES *****/

	/**************************
			MGs
	**************************/

	//Base
	add_zombie_weapon( "rpk_zm",					"rpk_upgraded_zm",						&"ZOMBIE_WEAPON_RPK",					4000,		"mg",				"",		undefined );
	add_zombie_weapon( "stoner63_zm",				"stoner63_upgraded_zm",					&"ZOMBIE_WEAPON_STONER63",				4000,		"mg",				"",		undefined );
	add_zombie_weapon( "hk21_zm",					"hk21_upgraded_zm",						&"ZOMBIE_WEAPON_HK21",					4000,		"mg",				"",		undefined );


	//Upgrade
	add_zombie_weapon( "rpk_upgraded_zm",					"rpk_upgraded_zm_x2",					&"ZOMBIE_WEAPON_RPK",					4000,		"mg",				"",		undefined );
	add_zombie_weapon( "hk21_upgraded_zm",					"hk21_upgraded_zm_x2",					&"ZOMBIE_WEAPON_HK21",					4000,		"mg",				"",		undefined );
	//add_zombie_weapon( "stoner63_upgraded_zm",				"stoner63_upgraded_zm",				&"ZOMBIE_WEAPON_STONER63",				4000,		"mg",				"",		undefined );
	//add_zombie_weapon( "m60_upgraded_zm",					"m60_upgraded_zm",					&"ZOMBIE_WEAPON_M60",					4000,		"mg",				"",		undefined );

	//Total: 3 base, 3 upgraded, 2 x2 = 8
	/***** END MGS *****/


	/**************************
		Assault Rifles - includes Burstrifles
	**************************/

	//Base 
	add_zombie_weapon( "aug_acog_zm",				"aug_acog_mk_upgraded_zm",				&"ZOMBIE_WEAPON_AUG",					1200,	"assault",			"",		undefined );
	add_zombie_weapon( "galil_zm",					"galil_upgraded_zm",					&"ZOMBIE_WEAPON_GALIL",					1000,	"assault",			"",		undefined );
	add_zombie_weapon( "commando_zm",				"commando_upgraded_zm",					&"ZOMBIE_WEAPON_COMMANDO",				1000,	"assault",			"",		undefined );
	add_zombie_weapon( "fnfal_zm",					"fnfal_upgraded_zm",					&"ZOMBIE_WEAPON_FNFAL",					1000,	"burstrifle",			"",		undefined );
	add_zombie_weapon( "g11_lps_zm",				"g11_lps_upgraded_zm",					&"ZOMBIE_WEAPON_G11",					900,	"burstrifle",			"",		undefined );
	add_zombie_weapon( "famas_zm",					"famas_upgraded_zm",					&"ZOMBIE_WEAPON_FAMAS",					50,		"burstrifle",			"",		undefined );
	
	//Upgrade
	add_zombie_weapon( "galil_upgraded_zm",					"galil_upgraded_zm_x2",					&"ZOMBIE_WEAPON_GALIL",					1000,	"assault",			"",		undefined );
	add_zombie_weapon( "commando_upgraded_zm",				"commando_upgraded_zm_x2",					&"ZOMBIE_WEAPON_COMMANDO",				1000,	"assault",			"",		undefined );

	//add_zombie_weapon( "aug_acog_mk_upgraded_zm",				"aug_acog_mk_upgraded_zm",				&"ZOMBIE_WEAPON_AUG",					1200,	"assault",			"",		undefined );
	//add_zombie_weapon( "fnfal_upgraded_zm",					"fnfal_upgraded_zm",					&"ZOMBIE_WEAPON_FNFAL",					1000,	"burstrifle",			"",		undefined );
	//add_zombie_weapon( "g11_lps_upgraded_zm",				"g11_lps_upgraded_zm",					&"ZOMBIE_WEAPON_G11",					900,	"burstrifle",			"",		undefined );
	//add_zombie_weapon( "famas_upgraded_zm",					"famas_upgraded_zm",					&"ZOMBIE_WEAPON_FAMAS",					50,		"burstrifle",			"",		undefined );
	
	//Total: 6 base, 6 upgraded, 2 x2 = 14
	/***** END ASSAULT RIFLES *****/

	/**************************
		Shotguns
	**************************/

	//Base
	add_zombie_weapon( "spas_zm",					"spas_upgraded_zm",						&"ZOMBIE_WEAPON_SPAS",					2000,		"shotgun",			"",		undefined );
	add_zombie_weapon( "hs10_zm",					"hs10_upgraded_zm",						&"ZOMBIE_WEAPON_HS10",					50,			"shotgun",			"",		undefined );

	//Upgrade
	//add_zombie_weapon( "spas_upgraded_zm",					"spas_upgraded_zm_x2",						&"ZOMBIE_WEAPON_SPAS",					2000,		"shotgun",			"",		undefined );
	//add_zombie_weapon( "hs10_upgraded_zm",					"hs10_upgraded_zm_x2",						&"ZOMBIE_WEAPON_HS10",					50,			"shotgun",			"",		undefined );

	//Total: 2 base, 2 upgraded, 2 x2 = 5
	/***** END SHOTGUNS *****/


	/**************************
		SMGs
	**************************/

	//Base
	add_zombie_weapon( "spectre_zm",				"spectre_upgraded_zm",					&"ZOMBIE_WEAPON_SPECTRE",				50,		"smg",				"",		undefined );
	add_zombie_weapon( "ppsh_zm",					"ppsh_upgraded_zm",						&"ZOMBIE_WEAPON_PPSh",					1000,		"smg",				"",		undefined );

	//Upgrade
	add_zombie_weapon( "spectre_upgraded_zm",				"spectre_upgraded_zm_x2",					&"ZOMBIE_WEAPON_SPECTRE",				50,		"smg",				"",		undefined );
	add_zombie_weapon( "ppsh_upgraded_zm",					"ppsh_upgraded_zm_x2",						&"ZOMBIE_WEAPON_PPSh",					1000,		"smg",				"",		undefined );

	//Total: 2 base, 2 upgraded, 1 x2 = 5
	/***** END SMGs *****/


	/**************************
		Sidearms
	**************************/

	//Base
	add_zombie_weapon( "python_zm",				"python_upgraded_zm",					&"ZOMBIE_WEAPON_PYTHON",				2200,	"pistol",			"",		undefined );
	add_zombie_weapon( "m1911_zm",				"m1911_upgraded_zm",					&"ZOMBIE_WEAPON_M1911",					50,		"pistol",			"",		undefined );
	add_zombie_weapon( "cz75_zm",				"cz75_upgraded_zm",						&"ZOMBIE_WEAPON_CZ75",					50,		"pistol",			"",		undefined );
	add_zombie_weapon( "cz75dw_zm",				"cz75dw_upgraded_zm",					&"ZOMBIE_WEAPON_CZ75DW",				50,		"dualwield",		"",		undefined );

	//Upgrade
	add_zombie_weapon( "python_upgraded_zm",				"python_upgraded_zm",					&"ZOMBIE_WEAPON_PYTHON",				2200,	"pistol",			"",		undefined );
	add_zombie_weapon( "m1911_upgraded_zm",				"m1911_upgraded_zm",					&"ZOMBIE_WEAPON_M1911",					50,		"pistol",			"",		undefined );
	//add_zombie_weapon( "cz75dw_upgraded_zm",				"cz75dw_upgraded_zm_x2",				&"ZOMBIE_WEAPON_CZ75DW",				50,		"dualwield",		"",		undefined );
	//add_zombie_weapon( "cz75_upgraded_zm",				"cz75_upgraded_zm_x2",					&"ZOMBIE_WEAPON_CZ75",					50,		"pistol",			"",		undefined );

	//Total: 4 base, 4 upgraded, 1 x2 = 9
	/***** END SIDEARMS *****/

	/**************************
		Snipers
	**************************/

	//Base
	add_zombie_weapon( "l96a1_zm",					"l96a1_upgraded_zm",					&"ZOMBIE_WEAPON_L96A1",					50,		"sniper",			"",		undefined );
	add_zombie_weapon( "dragunov_zm",				"dragunov_upgraded_zm",					&"ZOMBIE_WEAPON_DRAGUNOV",				2500,		"sniper",			"",		undefined );
	add_zombie_weapon( "psg1_zm",					"psg1_upgraded_zm",						&"ZOMBIE_WEAPON_PSG1",					2500,		"sniper",			"",		undefined );

	//Upgrade
	//add_zombie_weapon( "l96a1_upgraded_zm",					"l96a1_upgraded_zm",					&"ZOMBIE_WEAPON_L96A1",					50,		"sniper",			"",		undefined );
	//add_zombie_weapon( "dragunov_upgraded_zm",				"dragunov_upgraded_zm_x2",					&"ZOMBIE_WEAPON_DRAGUNOV",				2500,		"sniper",			"",		undefined );
	//add_zombie_weapon( "psg1_upgraded_zm",					"psg1_upgraded_zm",						&"ZOMBIE_WEAPON_PSG1",					2500,		"sniper",			"",		undefined );

	//Total: 3 base, 3 upgraded, 1 x2 = 7
	/***** END SNIPERS *****/

	/**************************
		Launchers
	**************************/

	//Base
	add_zombie_weapon( "m72_law_zm", 				"m72_law_upgraded_zm",					&"ZOMBIE_WEAPON_M72_LAW",	 			2000,	"launcher",			"",		undefined );
	//add_zombie_weapon( "china_lake_zm", 			"china_lake_upgraded_zm",				&"ZOMBIE_WEAPON_CHINA_LAKE", 			2000,	"launcher",			"",		undefined );

	//Upgrade - upgraded launchers get ammo back
	//add_zombie_weapon( "m72_law_upgraded_zm", 				"m72_law_upgraded_zm",					&"ZOMBIE_WEAPON_M72_LAW",	 			2000,	"launcher",			"",		undefined );
	//add_zombie_weapon( "china_lake_upgraded_zm", 			"china_lake_upgraded_zm",				&"ZOMBIE_WEAPON_CHINA_LAKE", 			2000,	"launcher",			"",		undefined );

	//Total: 2 base, 2 upgraded = 4
	/***** END LAUNCHERS *****/


	if( isWawMap )
	{
		/**************************
			WAW
		**************************/

		//Base
		add_zombie_weapon( "zombie_bar",				"zombie_bar_upgraded",					&"WAW_ZOMBIE_WEAPON_BAR_1800",			1800,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_doublebarrel",		"zombie_doublebarrel_upgraded",			&"WAW_ZOMBIE_WEAPON_DOUBLEBARREL_1200",	1200,		"shotgun",			"",		undefined );
		add_zombie_weapon( "zombie_doublebarrel_sawed",	"zombie_doublebarrel_upgraded",	&"WAW_ZOMBIE_WEAPON_DOUBLEBARREL_SAWED_1200",	1200,		"shotgun",			"",		undefined );
		add_zombie_weapon( "zombie_fg42",				"zombie_fg42_upgraded",					&"WAW_ZOMBIE_WEAPON_FG42_1500",			1500,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_gewehr43",			"zombie_gewehr43_upgraded",				&"WAW_ZOMBIE_WEAPON_GEWEHR43_600",		600,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_kar98k",			"zombie_kar98k_upgraded",				&"WAW_ZOMBIE_WEAPON_KAR98K_200",		200,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_m1carbine",			"zombie_m1carbine_upgraded",			&"WAW_ZOMBIE_WEAPON_M1CARBINE_600",		600,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_m1garand",			"zombie_m1garand_upgraded",				&"WAW_ZOMBIE_WEAPON_M1GARAND_600",		600,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_shotgun",			"zombie_shotgun_upgraded",				&"WAW_ZOMBIE_WEAPON_SHOTGUN_1500",		1500,		"shotgun",			"",		undefined );
		add_zombie_weapon( "zombie_springfield",		"zombie_springfield_upgraded",			&"WAW_ZOMBIE_WEAPON_SPRINGFIELD_200",	200,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_stg44",				"zombie_stg44_upgraded",				&"WAW_ZOMBIE_WEAPON_STG44_1200",		1200,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_thompson",			"zombie_thompson_upgraded",				&"WAW_ZOMBIE_WEAPON_THOMPSON_1200",		1200,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_type100_smg",		"zombie_type100_smg_upgraded",			&"WAW_ZOMBIE_WEAPON_TYPE100_1000",		1000,		"mg",				"",		undefined );

		//Upgrade
		/*
		add_zombie_weapon( "zombie_bar_upgraded",		"zombie_bar_upgraded",					&"WAW_ZOMBIE_WEAPON_BAR_1800",			1800,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_doublebarrel_upgraded",	"zombie_doublebarrel_upgraded",			&"WAW_ZOMBIE_WEAPON_DOUBLEBARREL_1200",	1200,		"shotgun",			"",		undefined );
		add_zombie_weapon( "zombie_doublebarrel_upgraded",	"zombie_doublebarrel_upgraded",	&"WAW_ZOMBIE_WEAPON_DOUBLEBARREL_SAWED_1200",	1200,		"shotgun",			"",		undefined );
		add_zombie_weapon( "zombie_fg42_upgraded",		"zombie_fg42_upgraded",					&"WAW_ZOMBIE_WEAPON_FG42_1500",			1500,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_gewehr43_upgraded",	"zombie_gewehr43_upgraded",				&"WAW_ZOMBIE_WEAPON_GEWEHR43_600",		600,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_kar98k_upgraded",	"zombie_kar98k_upgraded",				&"WAW_ZOMBIE_WEAPON_KAR98K_200",		200,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_m1carbine_upgraded",	"zombie_m1carbine_upgraded",			&"WAW_ZOMBIE_WEAPON_M1CARBINE_600",		600,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_m1garand_upgraded",	"zombie_m1garand_upgraded",				&"WAW_ZOMBIE_WEAPON_M1GARAND_600",		600,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_shotgun_upgraded",	"zombie_shotgun_upgraded",				&"WAW_ZOMBIE_WEAPON_SHOTGUN_1500",		1500,		"shotgun",			"",		undefined );
		add_zombie_weapon( "zombie_springfield_upgraded",	"zombie_springfield_upgraded",			&"WAW_ZOMBIE_WEAPON_SPRINGFIELD_200",	200,		"rifle",			"",		undefined );
		add_zombie_weapon( "zombie_stg44_upgraded",		"zombie_stg44_upgraded",				&"WAW_ZOMBIE_WEAPON_STG44_1200",		1200,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_thompson_upgraded",	"zombie_thompson_upgraded",				&"WAW_ZOMBIE_WEAPON_THOMPSON_1200",		1200,		"mg",				"",		undefined );
		add_zombie_weapon( "zombie_type100_smg_upgraded",	"zombie_type100_smg_upgraded",			&"WAW_ZOMBIE_WEAPON_TYPE100_1000",		1000,		"mg",				"",		undefined );
		*/

		//Total: 13 base, 0 upgraded = 13
		/***** END WAW *****/

	}
	else
	{
		/**************************
			Wall
		**************************/

		//Base
		add_zombie_weapon( "rottweil72_zm",					"rottweil72_upgraded_zm",					&"ZOMBIE_WEAPON_ROTTWEIL72",			500,		"shotgun",			"",		undefined );
		add_zombie_weapon( "m14_zm",					"m14_upgraded_zm",						&"ZOMBIE_WEAPON_M14",					500,		"rifle",			"",		undefined );
		add_zombie_weapon( "mp5k_zm",					"mp5k_upgraded_zm",						&"ZOMBIE_WEAPON_MP5K",					1000,		"smg",				"",		undefined );
		add_zombie_weapon( "mpl_zm",					"mpl_upgraded_zm",						&"ZOMBIE_WEAPON_MPL",					1000,		"smg",				"",		undefined );
		add_zombie_weapon( "pm63_zm",					"pm63_upgraded_zm",						&"ZOMBIE_WEAPON_PM63",					1000,		"smg",				"",		undefined );

		add_zombie_weapon( "ithaca_zm",					"ithaca_upgraded_zm",					&"ZOMBIE_WEAPON_ITHACA",				1500,		"shotgun",			"",		undefined );
		add_zombie_weapon( "ak74u_zm",					"ak74u_upgraded_zm",					&"ZOMBIE_WEAPON_AK74U",					1200,		"smg",				"",		undefined );
		add_zombie_weapon( "m16_zm",					"m16_gl_upgraded_zm",					&"ZOMBIE_WEAPON_M16",					1200,		"burstrifle",		"",		undefined );


		//Upgrade
		add_zombie_weapon( "rottweil72_upgraded_zm",				"rottweil72_upgraded_zm",				&"ZOMBIE_WEAPON_ROTTWEIL72",			500,		"shotgun",			"",		undefined );
		add_zombie_weapon( "m14_upgraded_zm",					"m14_upgraded_zm",					&"ZOMBIE_WEAPON_M14",					500,		"rifle",			"",		undefined );
		add_zombie_weapon( "mp5k_upgraded_zm",					"mp5k_upgraded_zm",					&"ZOMBIE_WEAPON_MP5K",					1000,		"smg",				"",		undefined );
		add_zombie_weapon( "mpl_upgraded_zm",					"mpl_upgraded_zm",					&"ZOMBIE_WEAPON_MPL",					1000,		"smg",				"",		undefined );
		add_zombie_weapon( "pm63_upgraded_zm",					"pm63_upgraded_zm",					&"ZOMBIE_WEAPON_PM63",					1000,		"smg",				"",		undefined );

		add_zombie_weapon( "ithaca_upgraded_zm",					"ithaca_upgraded_zm",				&"ZOMBIE_WEAPON_ITHACA",				1500,		"shotgun",			"",		undefined );
		add_zombie_weapon( "ak74u_upgraded_zm",					"ak74u_upgraded_zm",				&"ZOMBIE_WEAPON_AK74U",					1200,		"smg",				"",		undefined );
		add_zombie_weapon( "m16_gl_upgraded_zm",					"m16_gl_upgraded_zm",				&"ZOMBIE_WEAPON_M16",					1200,		"burstrifle",		"",		undefined );

		//Total: 9 base, 9 upgraded = 18
		/***** END WALL *****/

	}

	
	

	/**************************
		Special
	**************************/

		//Base
		add_zombie_weapon( "crossbow_explosive_zm",		"crossbow_explosive_upgraded_zm",		&"ZOMBIE_WEAPON_CROSSBOW_EXPOLOSIVE",	10,		"crossbow",			"",		undefined );
		add_zombie_weapon( "knife_ballistic_zm",		"knife_ballistic_upgraded_zm",			&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		10,		"bowie",	"",		undefined );
		//add_zombie_weapon( "knife_ballistic_bowie_zm",	"knife_ballistic_bowie_upgraded_zm",	&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		10,		"bowie",	"",		undefined );
		//add_zombie_weapon( "knife_ballistic_sickle_zm",	"knife_ballistic_sickle_upgraded_zm",	&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		10,		"sickle",	"",		undefined );


		//Base WW
		switch( mapname )
		{
			case "zombie_cod5_prototype":
			case "zombie_theater":
			case "zombie_cosmodrome":
				add_zombie_weapon( "thundergun_zm",				"thundergun_upgraded_zm",				&"ZOMBIE_WEAPON_THUNDERGUN", 			10,		"thunder",			"",		undefined );
				break;
			
			case "zombie_cod5_asylum":
			case "zombie_pentagon":
				add_zombie_weapon( "freezegun_zm",				"freezegun_upgraded_zm",				&"ZOMBIE_WEAPON_FREEZEGUN", 			10,		"freezegun",		"",		undefined );
				break;

			case "zombie_cod5_sumpf":
			case "zombie_cod5_factory":
			case "zombie_coast":
				break;
			

			case "zombie_moon":			
			case "zombie_temple":
				break;
		}

		add_zombie_weapon( "ray_gun_zm", 				"ray_gun_upgraded_zm",					&"ZOMBIE_WEAPON_RAYGUN", 				10000,	"raygun",			"",		undefined );
		add_zombie_weapon( "tesla_gun_zm",			"tesla_gun_upgraded_zm",				&"ZOMBIE_WEAPON_TESLA", 				10,		"tesla",			"",		undefined );
		
		
		

	//Upgrade - No Double upgrades for specials except for crossbow
	//add_zombie_weapon( "crossbow_explosive_upgraded_zm",		"crossbow_explosive_upgraded_zm_x2",		&"ZOMBIE_WEAPON_CROSSBOW_EXPOLOSIVE",	10,		"crossbow",			"",		undefined );
	//add_zombie_weapon( "knife_ballistic_upgraded_zm",		"knife_ballistic_upgraded_zm",			&"ZOMBIE_WEAPON_KNIFE_BALLISTIC",		10,		"bowie",	"",		undefined );

	//Total: 2 base, 2 upgraded, 0 x2 = 4 + ( 4 WW )
	/***** END SPECIAL *****/


	/**************************
		Map Specific
	**************************/

	switch( mapname )
	{
		case "zombie_cod5_prototype":
		case "zombie_cod5_asylum":
		case "zombie_cod5_sumpf":
		case "zombie_cod5_factory":
		case "zombie_theater":
		case "zombie_coast":
			add_zombie_weapon( "mp40_zm",					"mp40_upgraded_zm",						&"ZOMBIE_WEAPON_MP40",					1000,		"smg",				"",		undefined );
			add_zombie_weapon( "mp40_upgraded_zm",					"mp40_upgraded_zm",					&"ZOMBIE_WEAPON_MP40",					1000,		"smg",				"",		undefined );		
			break;

		case "zombie_cosmodrome":
		case "zombie_moon":
			add_zombie_weapon( "zombie_black_hole_bomb",		undefined,								&"ZOMBIE_WEAPON_SATCHEL_2000", 			2000,	"gersh",			"",		undefined );
			add_zombie_weapon( "zombie_nesting_dolls",		undefined,								&"ZOMBIE_WEAPON_NESTING_DOLLS", 		2000,	"dolls",	"",		undefined );
			break;
		
		case "zombie_pentagon":
		case "zombie_temple":
			break;
	}


	/**************************
		New
	Add these weapons:
	uzi_zm
	asp
	ak47_zm
	c:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops\raw\weapons\sp\skorpion_zm
	**************************/
	add_zombie_weapon( "asp_zm",						"asp_upgraded_zm",									&"ZOMBIE_WEAPON_ASP",				1000,	"pistol",			"",		undefined );
	add_zombie_weapon( "asp_upgraded_zm",						"asp_upgraded_zm_x2",									&"ZOMBIE_WEAPON_ASP",				1000,	"assault",			"",		undefined );
	
	add_zombie_weapon( "ak47_zm",					"ak47_ft_upgraded_zm",					&"ZOMBIE_WEAPON_AK47",				1000,	"assault",			"",		undefined );
	add_zombie_weapon( "uzi_zm", 					"uzi_upgraded_zm",						&"ZOMBIE_WEAPON_UZI",					1000,	"smg",				"",		undefined );
	add_zombie_weapon( "enfield_zm",					"enfield_upgraded_zm",					&"ZOMBIE_WEAPON_ENFIELD",					50,		"burstrifle",			"",		undefined );
	add_zombie_weapon( "m60_zm",					"m60_upgraded_zm",						&"ZOMBIE_WEAPON_M60",					4000,		"mg",				"",		undefined );

	add_zombie_weapon( "makarov_zm",					"makarov_upgraded_zm",					&"ZOMBIE_WEAPON_MAKAROV",					50,		"pistol",			"",		undefined );
	add_zombie_weapon( "ks23_zm",					"ks23_upgraded_zm",						&"ZOMBIE_WEAPON_KS23",					50,		"shotgun",			"",		undefined );
	//add_zombie_weapon( "kiparis_zm",					"kiparis_upgraded_zm",					&"ZOMBIE_WEAPON_KIPARIS",					50,		"smg",			"",		undefined );
	//add_zombie_weapon( "mac11_zm",					"mac11_upgraded_zm",					&"ZOMBIE_WEAPON_MAC11",					50,		"smg",			"",		undefined );
	


	//add_zombie_weapon( weapon_name, 				upgrade_name, 							hint, 									cost, 	weaponVO, weaponVOresp, 	ammo_cost, add_without_include )
	add_zombie_weapon( "sabertooth_zm", 				"sabertooth_upgraded_zm", 				&"ZOMBIE_WEAPON_SABERTOOTH", 			50, 	"pistol", 			"", 	undefined );
	//{{WEAPON_INCLUDE}}

	//Upgrade
	//add_zombie_weapon( "ak47_ft_upgraded_zm",					"ak47_ft_upgraded_zm",					&"ZOMBIE_WEAPON_COMMANDO",				1000,	"assault",			"",		undefined );

	//Total: 4 base, 0 upgraded = 4
	/***** END NEW *****/

	if(IsDefined(level._zombie_custom_add_weapons))
	{
		[[level._zombie_custom_add_weapons]]();
	}

	Precachemodel("zombie_teddybear");
}

//remove this function and whenever it's call for production. this is only for testing purpose.
add_limited_tesla_gun()
{

	weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" );

	for( i = 0; i < weapon_spawns.size; i++ )
	{
		hint_string = weapon_spawns[i].zombie_weapon_upgrade;
		if(hint_string == "tesla_gun_zm")
		{
			weapon_spawns[i] waittill("trigger");
			weapon_spawns[i] disable_trigger();
			break;

		}

	}

}


add_limited_weapon( weapon_name, amount )
{
	if( !IsDefined( level.limited_weapons ) )
	{
		level.limited_weapons = [];
	}

	level.limited_weapons[weapon_name] = amount;
}

// For pay turrets
init_pay_turret()
{
	pay_turrets = [];
	pay_turrets = GetEntArray( "pay_turret", "targetname" );

	for( i = 0; i < pay_turrets.size; i++ )
	{
		cost = level.pay_turret_cost;
		if( !isDefined( cost ) )
		{
			cost = 1000;
		}
		pay_turrets[i] SetHintString( &"ZOMBIE_PAY_TURRET", cost );
		pay_turrets[i] SetCursorHint( "HINT_NOICON" );
		pay_turrets[i] UseTriggerRequireLookAt();

		pay_turrets[i] thread pay_turret_think( cost );
	}
}

// For buying weapon upgrades in the environment
init_weapon_upgrade()
{
	weapon_spawns = [];
	weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" );

	for( i = 0; i < weapon_spawns.size; i++ )
	{
        if(weapon_spawns[i].zombie_weapon_upgrade == "zombie_bar_bipod")
        {
        	weapon_spawns[i].zombie_weapon_upgrade = "zombie_bar";

        	old_model = GetEnt( weapon_spawns[i].target, "targetname" );
			weapon_spawns[i].override_weapon_model = Spawn( "script_model", old_model.origin );
			weapon_spawns[i].override_weapon_model.angles = old_model.angles;
			weapon_spawns[i].override_weapon_model SetModel( GetWeaponModel( weapon_spawns[i].zombie_weapon_upgrade ) );
			weapon_spawns[i].override_weapon_model useweaponhidetags( weapon_spawns[i].zombie_weapon_upgrade );
			weapon_spawns[i].override_weapon_model Hide();
			old_model Delete();
        }

        // HACK - replace Kar98k wallbuy on Verruckt Quick Revive side with Springfield
		/*
		if(level.script == "zombie_cod5_asylum")
		{
			if(weapon_spawns[i].zombie_weapon_upgrade == "zombie_kar98k" && IsDefined(weapon_spawns[i].target) && weapon_spawns[i].target == "pf178_auto1")
			{
				weapon_spawns[i].zombie_weapon_upgrade = "zombie_springfield";
				weapon_spawns[i].script_noteworthy = "springfield";

				model = getent( weapon_spawns[i].target, "targetname" );
				model SetModel( GetWeaponModel( weapon_spawns[i].zombie_weapon_upgrade ) );
				model useweaponhidetags( weapon_spawns[i].zombie_weapon_upgrade );
				model.origin += (-1.5, 0, 0.5);
			}
		}
		*/

		weapon_name = weapon_spawns[i].zombie_weapon_upgrade;
		if( !IsDefined(weapon_name) || !IsDefined( level.zombie_weapons ) )
			continue;
		
		if( !IsDefined( level.zombie_weapons[weapon_name] )
		|| !IsDefined( getent( weapon_spawns[i].target, "targetname" ) )
		 )
		{ 
			setupWeaponOverrideForSpecificWeapons = ( weapon_name == "zombie_bar" );

			if( setupWeaponOverrideForSpecificWeapons ) 
			{
				//Do setup anyways
			}
			else
			{
				continue; //HERE
			}
				
		}
		
		hint_string = get_weapon_hint( weapon_spawns[i].zombie_weapon_upgrade );
		cost = get_weapon_cost( weapon_spawns[i].zombie_weapon_upgrade );
	
		weapon_spawns[i] SetHintString( hint_string, cost );
		weapon_spawns[i] setCursorHint( "HINT_NOICON" );
		weapon_spawns[i] UseTriggerRequireLookAt();

		weapon_spawns[i] thread weapon_spawn_think();
		model = getent( weapon_spawns[i].target, "targetname" );
		model useweaponhidetags( weapon_spawns[i].zombie_weapon_upgrade );
		model hide();
	}
}

// For toggling which weapons can appear from the box
init_weapon_toggle()
{
	if ( !isdefined( level.magic_box_weapon_toggle_init_callback ) )
	{
		return;
	}

	level.zombie_weapon_toggles = [];
	level.zombie_weapon_toggle_max_active_count = 0;
	level.zombie_weapon_toggle_active_count = 0;

	PrecacheString( &"ZOMBIE_WEAPON_TOGGLE_DISABLED" );
	PrecacheString( &"ZOMBIE_WEAPON_TOGGLE_ACTIVATE" );
	PrecacheString( &"ZOMBIE_WEAPON_TOGGLE_DEACTIVATE" );
	PrecacheString( &"ZOMBIE_WEAPON_TOGGLE_ACQUIRED" );
	level.zombie_weapon_toggle_disabled_hint = &"ZOMBIE_WEAPON_TOGGLE_DISABLED";
	level.zombie_weapon_toggle_activate_hint = &"ZOMBIE_WEAPON_TOGGLE_ACTIVATE";
	level.zombie_weapon_toggle_deactivate_hint = &"ZOMBIE_WEAPON_TOGGLE_DEACTIVATE";
	level.zombie_weapon_toggle_acquired_hint = &"ZOMBIE_WEAPON_TOGGLE_ACQUIRED";

	PrecacheModel( "zombie_zapper_cagelight" );
	PrecacheModel( "zombie_zapper_cagelight_green" );
	PrecacheModel( "zombie_zapper_cagelight_red" );
	PrecacheModel( "zombie_zapper_cagelight_on" );
	level.zombie_weapon_toggle_disabled_light = "zombie_zapper_cagelight";
	level.zombie_weapon_toggle_active_light = "zombie_zapper_cagelight_green";
	level.zombie_weapon_toggle_inactive_light = "zombie_zapper_cagelight_red";
	level.zombie_weapon_toggle_acquired_light = "zombie_zapper_cagelight_on";

	weapon_toggle_ents = [];
	weapon_toggle_ents = GetEntArray( "magic_box_weapon_toggle", "targetname" );

	for ( i = 0; i < weapon_toggle_ents.size; i++ )
	{
		struct = SpawnStruct();

		struct.trigger = weapon_toggle_ents[i];
		struct.weapon_name = struct.trigger.script_string;
		struct.upgrade_name = level.zombie_weapons[struct.trigger.script_string].upgrade_name;
		struct.enabled = false;
		struct.active = false;
		struct.acquired = false;

		target_array = [];
		target_array = GetEntArray( struct.trigger.target, "targetname" );
		for ( j = 0; j < target_array.size; j++ )
		{
			switch ( target_array[j].script_string )
			{
			case "light":
				struct.light = target_array[j];
				struct.light setmodel( level.zombie_weapon_toggle_disabled_light );
				break;
			case "weapon":
				struct.weapon_model = target_array[j];
				struct.weapon_model hide();
				break;
			}
		}

		struct.trigger SetHintString( level.zombie_weapon_toggle_disabled_hint );
		struct.trigger setCursorHint( "HINT_NOICON" );
		struct.trigger UseTriggerRequireLookAt();

		struct thread weapon_toggle_think();

		level.zombie_weapon_toggles[struct.weapon_name] = struct;
	}

	//for initial enable and disable of toggles, and determination of which are activated
	level thread [[level.magic_box_weapon_toggle_init_callback]]();
}


// an upgrade of a weapon toggle is also considered a weapon toggle
get_weapon_toggle( weapon_name )
{
	if ( !isdefined( level.zombie_weapon_toggles ) )
	{
		return undefined;
	}

	if ( isdefined( level.zombie_weapon_toggles[weapon_name] ) )
	{
		return level.zombie_weapon_toggles[weapon_name];
	}

	keys = GetArrayKeys( level.zombie_weapon_toggles );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( weapon_name == level.zombie_weapon_toggles[keys[i]].upgrade_name )
		{
			return level.zombie_weapon_toggles[keys[i]];
		}
	}

	return undefined;
}


is_weapon_toggle( weapon_name )
{
	return isdefined( get_weapon_toggle( weapon_name ) );
}


disable_weapon_toggle( weapon_name )
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isdefined( toggle ) )
	{
		return;
	}

	if ( toggle.active )
	{
		level.zombie_weapon_toggle_active_count--;
	}
	toggle.enabled = false;
	toggle.active = false;

	toggle.light setmodel( level.zombie_weapon_toggle_disabled_light );
	toggle.weapon_model hide();
	toggle.trigger SetHintString( level.zombie_weapon_toggle_disabled_hint );
}


enable_weapon_toggle( weapon_name )
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isdefined( toggle ) )
	{
		return;
	}

	toggle.enabled = true;
	toggle.weapon_model show();
	toggle.weapon_model useweaponhidetags( weapon_name );

	deactivate_weapon_toggle( weapon_name );
}


activate_weapon_toggle( weapon_name, trig_for_vox )
{
	if ( level.zombie_weapon_toggle_active_count >= level.zombie_weapon_toggle_max_active_count )
	{
        if( IsDefined( trig_for_vox ) )
        {
            trig_for_vox thread maps\_zombiemode_audio::weapon_toggle_vox( "max" );
        }

		return;
	}

	toggle = get_weapon_toggle( weapon_name );
	if ( !isdefined( toggle ) )
	{
		return;
	}

	if( IsDefined( trig_for_vox ) )
	{
	    trig_for_vox thread maps\_zombiemode_audio::weapon_toggle_vox( "activate", weapon_name );
	}

	level.zombie_weapon_toggle_active_count++;
	toggle.active = true;

	toggle.light setmodel( level.zombie_weapon_toggle_active_light );
	toggle.trigger SetHintString( level.zombie_weapon_toggle_deactivate_hint );
}


deactivate_weapon_toggle( weapon_name, trig_for_vox )
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isdefined( toggle ) )
	{
		return;
	}

	if( IsDefined( trig_for_vox ) )
	{
	    trig_for_vox thread maps\_zombiemode_audio::weapon_toggle_vox( "deactivate", weapon_name );
	}

	if ( toggle.active )
	{
		level.zombie_weapon_toggle_active_count--;
	}
	toggle.active = false;

	toggle.light setmodel( level.zombie_weapon_toggle_inactive_light );
	toggle.trigger SetHintString( level.zombie_weapon_toggle_activate_hint );
}


acquire_weapon_toggle( weapon_name, player )
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isdefined( toggle ) )
	{
		return;
	}

	if ( !toggle.active || toggle.acquired )
	{
		return;
	}
	toggle.acquired = true;

	toggle.light setmodel( level.zombie_weapon_toggle_acquired_light );
	toggle.trigger SetHintString( level.zombie_weapon_toggle_acquired_hint );

	toggle thread unacquire_weapon_toggle_on_death_or_disconnect_thread( player );
}


unacquire_weapon_toggle_on_death_or_disconnect_thread( player )
{
	self notify( "end_unacquire_weapon_thread" );
	self endon( "end_unacquire_weapon_thread" );

	player waittill_any( "spawned_spectator", "disconnect" );

	unacquire_weapon_toggle( self.weapon_name );
}


unacquire_weapon_toggle( weapon_name )
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isdefined( toggle ) )
	{
		return;
	}

	if ( !toggle.active || !toggle.acquired )
	{
		return;
	}

	toggle.acquired = false;

	toggle.light setmodel( level.zombie_weapon_toggle_active_light );
	toggle.trigger SetHintString( level.zombie_weapon_toggle_deactivate_hint );

	toggle notify( "end_unacquire_weapon_thread" );
}


weapon_toggle_think()
{
	for( ;; )
	{
		self.trigger waittill( "trigger", player );
		// if not first time and they have the weapon give ammo

		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if ( !self.enabled || self.acquired )
		{
            self.trigger thread maps\_zombiemode_audio::weapon_toggle_vox( "max" );
		}
		else if ( !self.active )
		{
			activate_weapon_toggle( self.weapon_name, self.trigger );
		}
		else
		{
			deactivate_weapon_toggle( self.weapon_name, self.trigger );
		}
	}
}


// weapon cabinets which open on use
init_weapon_cabinet()
{
	// the triggers which are targeted at doors
	weapon_cabs = GetEntArray( "weapon_cabinet_use", "targetname" );

	for( i = 0; i < weapon_cabs.size; i++ )
	{
		weapon_cabs[i] SetHintString( &"ZOMBIE_CABINET_OPEN_1500" );
		weapon_cabs[i] setCursorHint( "HINT_NOICON" );
		weapon_cabs[i] UseTriggerRequireLookAt();
	}

	//array_thread( weapon_cabs, ::weapon_cabinet_think );
}

// returns the trigger hint string for the given weapon
get_weapon_hint( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	if( !IsDefined( level.zombie_weapons ) )
		return "";

	if( IsDefined( level.zombie_weapons[weapon_name].hint ) )
		return level.zombie_weapons[weapon_name].hint;
	

	return "BUY " + weapon_name;
}

get_weapon_cost( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );


	if( IsDefined( level.zombie_weapons[weapon_name].cost ) )
		return level.zombie_weapons[weapon_name].cost;

	return 5000;
}

get_ammo_cost( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	if( IsDefined( level.zombie_weapons[weapon_name].ammo_cost ) )
		return level.zombie_weapons[weapon_name].ammo_cost;
	
	return 500;
}

get_is_in_box( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	if( IsDefined( level.zombie_weapons[weapon_name].is_in_box ) )
		return level.zombie_weapons[weapon_name].is_in_box;

	return false;
}


// Check to see if this is an upgraded version of another weapon
//	weaponname can be any weapon name.
is_weapon_upgraded( weaponname )
{
	if( !isdefined( weaponname ) || weaponname == "" )
	{
		return false;
	}

	weaponname = ToLower( weaponname );

	ziw_keys = GetArrayKeys( level.zombie_weapons );
	for ( i=0; i<level.zombie_weapons.size; i++ )
	{
		if ( IsDefined(level.zombie_weapons[ ziw_keys[i] ].upgrade_name) &&
			 level.zombie_weapons[ ziw_keys[i] ].upgrade_name == weaponname )
		{
			return true;
		}
	}

	return false;
}

//Reimagined-Expanded
is_weapon_double_upgraded( weaponname )
{
	if( !isdefined( weaponname ) || weaponname == "" )
	{
		return false;
	}

	if( IsDefined( self.packapunch_weapons[ weaponname ] ) )
	{
		return ( self.packapunch_weapons[ weaponname ] > 1 );
	}
	else
	{
		return false;
	}

}


//	Check to see if the player has the upgraded version of the weapon
//	weaponname should only be a base weapon name
//	self is a player
has_upgrade( weaponname )
{
	has_upgrade = false;
	if( IsDefined(level.zombie_weapons[weaponname]) && IsDefined(level.zombie_weapons[weaponname].upgrade_name) )
	{
		has_upgrade = self HasWeapon( level.zombie_weapons[weaponname].upgrade_name );
	}

	// double check for the bowie variant on the ballistic knife
	if ( !has_upgrade && weaponname == "knife_ballistic_zm" )
	{
		has_upgrade = has_upgrade( "knife_ballistic_bowie_zm" ) || has_upgrade( "knife_ballistic_sickle_zm" );
	}

	return has_upgrade;
}


//	Check to see if the player has the normal or upgraded weapon
//	weaponname should only be a base weapon name
//	self is a player
has_weapon_or_upgrade( weaponname )
{
	upgradedweaponname = weaponname;
	x2weaponname = weaponname + "_x2";
	if ( IsDefined( level.zombie_weapons[weaponname] ) && IsDefined( level.zombie_weapons[weaponname].upgrade_name ) )
	{
		upgradedweaponname = level.zombie_weapons[weaponname].upgrade_name;
	}

	if( IsSubStr( weaponname, "upgraded" ) )
	{
		x2weaponname = weaponname + "_x2";
	}
	else if( IsSubStr( upgradedweaponname, "upgraded" ) )
	{
		x2weaponname = upgradedweaponname + "_x2";
	}

	has_weapon = false;
	// If the weapon you're checking doesn't exist, it will return undefined
	if( IsDefined( level.zombie_weapons[weaponname] ) )
	{
		has_weapon = self HasWeapon( weaponname ) 
		|| self has_upgrade( weaponname ) 
		|| self HasWeapon( upgradedweaponname ) 
		|| self HasWeapon( x2weaponname );
	}

	// double check for the bowie variant on the ballistic knife
	if ( !has_weapon && "knife_ballistic_zm" == weaponname )
	{
		has_weapon = has_weapon_or_upgrade( "knife_ballistic_bowie_zm" ) || has_weapon_or_upgrade( "knife_ballistic_sickle_zm" );
	}

	return has_weapon;
}


// for the random weapon chest
//
//	The chests need to be setup as follows:
//		trigger_use - for the chest
//			targets the lid
//		lid - script_model.  Flips open to reveal the items
//			targets the script origin inside the box
//		script_origin - inside the box, used for spawning the weapons
//			targets the box
//		box - script_model of the outer casing of the chest
//		rubble - pieces that show when the box isn't there
//			script_noteworthy should be the same as the use_trigger + "_rubble"
//
treasure_chest_init()
{
	if( level.mutators["mutator_noMagicBox"] || level.gamemode == "gg" )
	{
		chests = GetEntArray( "treasure_chest_use", "targetname" );
		if(level.gamemode == "gg" && level.script == "zombie_cod5_prototype")
		{
			for( i=0; i < chests.size; i++ )
			{
				chests[i] disable_trigger();
			}
		}
		else
		{
			for( i=0; i < chests.size; i++ )
			{
				chests[i] get_chest_pieces();
				chests[i] hide_chest();
			}
		}
		return;
	}
	flag_init("moving_chest_enabled");
	flag_init("moving_chest_now");
	flag_init("chest_has_been_used");

	level.chest_moves = 0;
	level.chest_level = 0;	// Level 0 = normal chest, 1 = upgraded chest
	level.chests = GetEntArray( "treasure_chest_use", "targetname" );
	for (i=0; i<level.chests.size; i++ )
	{
		level.chests[i].box_hacks = [];

		level.chests[i].orig_origin = level.chests[i].origin;
		level.chests[i] get_chest_pieces();

		if ( isDefined( level.chests[i].zombie_cost ) )
		{
			level.chests[i].old_cost = level.chests[i].zombie_cost;
		}
		else
		{
			// default chest cost
			level.chests[i].old_cost = 950;
		}

		level.chests[i] thread decide_hide_show_hint();
	}

	level.chest_accessed = 0;

	if (level.chests.size > 1)
	{
		flag_set("moving_chest_enabled");

		level.chests = array_randomize(level.chests);

		//determine magic box starting location at random or normal
		init_starting_chest_location();
	}
	else
	{
		level.chest_index = 0;
	}

	// Show the beacon
	if( !isDefined( level.pandora_show_func ) )
	{
		level.pandora_show_func = ::default_pandora_show_func;
	}

	level.chests[level.chest_index] thread [[ level.pandora_show_func ]]();

	array_thread( level.chests, ::treasure_chest_think );

}

init_starting_chest_location()
{
	level.chest_index = 0;
	start_chest_found = false;
	forced_start_chest = GetDvar(level.script + "_initial_box_location");

	for( i = 0; i < level.chests.size; i++ )
	{
		if(level.gamemode == "survival" && forced_start_chest != "" && forced_start_chest != "random")
		{
			if(level.chests[i].script_noteworthy == forced_start_chest)
			{
				level.chest_index = i;
				level.chests[level.chest_index] hide_rubble();
				level.chests[level.chest_index].hidden = false;
			}
			else
			{
				level.chests[i] hide_chest();
			}
		}
		else if( isdefined( level.random_pandora_box_start ) && level.random_pandora_box_start == true )
		{
			if ( ( start_chest_found || (IsDefined( level.chests[i].start_exclude ) && level.chests[i].start_exclude == 1) ) )
			{
				level.chests[i] hide_chest();
			}
			else
			{
				level.chest_index = i;
				level.chests[level.chest_index] hide_rubble();
				level.chests[level.chest_index].hidden = false;
				start_chest_found = true;
			}

		}
		else
		{
			// Semi-random implementation (not completely random).  The list is randomized
			//	prior to getting here.
			// Pick from any box marked as the "start_chest"
			if ( start_chest_found || !IsDefined(level.chests[i].script_noteworthy ) || ( !IsSubStr( level.chests[i].script_noteworthy, "start_chest" ) ) )
			{
				level.chests[i] hide_chest();
			}
			else
			{
				level.chest_index = i;
				level.chests[level.chest_index] hide_rubble();
				level.chests[level.chest_index].hidden = false;
				start_chest_found = true;
			}
		}
	}

	//make first chest the first index
	if(level.chest_index != 0)
	{
		level.chests = array_swap(level.chests,0,level.chest_index);
		level.chest_index = 0;
	}
}


//
//	Rubble is the object that is visible when the box isn't
hide_rubble()
{
	rubble = getentarray( self.script_noteworthy + "_rubble", "script_noteworthy" );
	if ( IsDefined( rubble ) )
	{
		for ( x = 0; x < rubble.size; x++ )
		{
			rubble[x] hide();
		}
	}
	else
	{
		println( "^3Warning: No rubble found for magic box" );
	}
}


//
//	Rubble is the object that is visible when the box isn't
show_rubble()
{
	if ( IsDefined( self.chest_rubble ) )
	{
		for ( x = 0; x < self.chest_rubble.size; x++ )
		{
			self.chest_rubble[x] show();
		}
	}
	else
	{
		println( "^3Warning: No rubble found for magic box" );
	}
}


set_treasure_chest_cost( cost )
{
	level.zombie_treasure_chest_cost = cost;
}

//
//	Save off the references to all of the chest pieces
//		self = trigger
get_chest_pieces()
{
	self.chest_lid		= GetEnt(self.target,				"targetname");
	self.chest_origin	= GetEnt(self.chest_lid.target,		"targetname");

//	println( "***** LOOKING FOR:  " + self.chest_origin.target );

	self.chest_box		= GetEnt(self.chest_origin.target,	"targetname");

	//TODO fix temp hax to separate multiple instances
	self.chest_rubble	= [];
	rubble = GetEntArray( self.script_noteworthy + "_rubble", "script_noteworthy" );
	for ( i=0; i<rubble.size; i++ )
	{
		if ( DistanceSquared( self.origin, rubble[i].origin ) < 10000 )
		{
			self.chest_rubble[ self.chest_rubble.size ]	= rubble[i];
		}
	}
}

play_crazi_sound()
{
	if( is_true( level.player_4_vox_override ) )
	{
		self playlocalsound( "zmb_laugh_rich" );
	}
	else
	{
		self playlocalsound( "zmb_laugh_child" );
	}
}



//
//	Show the chest pieces
//		self = chest use_trigger
//
show_chest()
{
	self thread [[ level.pandora_show_func ]]();

	self enable_trigger();

	self.chest_lid show();
	self.chest_box show();

	self.chest_lid playsound( "zmb_box_poof_land" );
	self.chest_lid playsound( "zmb_couch_slam" );

	self.hidden = false;

	if(IsDefined(self.box_hacks["summon_box"]))
	{
		self [[self.box_hacks["summon_box"]]](false);
	}

}

hide_chest()
{
	self disable_trigger();
	self.chest_lid hide();
	self.chest_box hide();

	if ( IsDefined( self.pandora_light ) )
	{
		self.pandora_light delete();
	}

	self.hidden = true;

	if(IsDefined(self.box_hacks) && IsDefined(self.box_hacks["summon_box"]))
	{
		self [[self.box_hacks["summon_box"]]](true);
	}
}

default_pandora_fx_func( )
{
	self.pandora_light = Spawn( "script_model", self.chest_origin.origin );
	self.pandora_light.angles = self.chest_origin.angles + (-90, 0, 0);
	//	level.pandora_light.angles = (-90, anchorTarget.angles[1] + 180, 0);
	self.pandora_light SetModel( "tag_origin" );
	playfxontag(level._effect["lght_marker"], self.pandora_light, "tag_origin");
}


//
//	Show a column of light
//
default_pandora_show_func( anchor, anchorTarget, pieces )
{
	if ( !IsDefined(self.pandora_light) )
	{
		// Show the column light effect on the box
		if( !IsDefined( level.pandora_fx_func ) )
		{
			level.pandora_fx_func = ::default_pandora_fx_func;
		}
		self thread [[ level.pandora_fx_func ]]();
	}
	playsoundatposition( "zmb_box_poof", self.chest_lid.origin );
	wait(0.5);

	playfx( level._effect["lght_marker_flare"],self.pandora_light.origin );

	//Add this location to the map
	//Objective_Add( 0, "active", "Mystery Box", self.chest_lid.origin, "minimap_icon_mystery_box" );
}

treasure_chest_think()
{
	self endon("kill_chest_think");

	self SetHintString(&"REIMAGINED_MYSTERY_BOX", self.zombie_cost);
	self setCursorHint( "HINT_NOICON" );

	// waittill someuses uses this
	user = undefined;
	user_cost = undefined;
	self.box_rerespun = undefined;
	self.weapon_out = undefined;

	while( 1 )
	{
		if(!IsDefined(self.forced_user))
		{
			self waittill( "trigger", user );
		}
		else
		{
			user = self.forced_user;
		}

		if( user in_revive_trigger() )
		{
			wait( 0.1 );
			continue;
		}

		/*if( user is_drinking() )
		{
			wait( 0.1 );
			continue;
		}*/

		if( user has_powerup_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		if ( is_true( self.disabled ) )
		{
			wait( 0.1 );
			continue;
		}

		if( user GetCurrentWeapon() == "none" )
		{
			wait( 0.1 );
			continue;
		}

		// make sure the user is a player, and that they can afford it
		if( IsDefined(self.auto_open) && is_player_valid( user ) )
		{
			if(!IsDefined(self.no_charge))
			{
				user maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
				user_cost = self.zombie_cost;
			}
			else
			{
				user_cost = 0;
			}

			self.chest_user = user;
			break;
		}
		else if( is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
			user_cost = self.zombie_cost;
			self.chest_user = user;
			break;
		}
		else if ( user.score < self.zombie_cost )
		{
			user maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 2 );
			continue;
		}

		wait 0.05;
	}

	flag_set("chest_has_been_used");

	self._box_open = true;
	self._box_opened_by_fire_sale = false;
	if ( is_true( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && !IsDefined(self.auto_open) && self [[level._zombiemode_check_firesale_loc_valid_func]]())
	{
		self._box_opened_by_fire_sale = true;
	}

	//open the lid
	self.chest_lid thread treasure_chest_lid_open();

	// SRS 9/3/2008: added to help other functions know if we timed out on grabbing the item
	self.timedOut = false;

	// mario kart style weapon spawning
	self.weapon_out = true;
	self.chest_origin thread treasure_chest_weapon_spawn( self, user );

	// the glowfx
	self.chest_origin thread treasure_chest_glowfx();

	// take away usability until model is done randomizing
	self disable_trigger();

	self.chest_origin waittill( "randomization_done" );

	// refund money from teddy.
	if (flag("moving_chest_now") && !self._box_opened_by_fire_sale && IsDefined(user_cost))
	{
		user maps\_zombiemode_score::add_to_player_score( user_cost, false );
	}

	if (flag("moving_chest_now") && !level.zombie_vars["zombie_powerup_fire_sale_on"] && !is_true( self._box_opened_by_fire_sale ))
	{
		//CA AUDIO: 01/12/10 - Changed dialog to use correct function
		//self.chest_user maps\_zombiemode_audio::create_and_play_dialog( "general", "box_move" );
		self thread treasure_chest_move( self.chest_user );
	}
	else
	{
		// Let the player grab the weapon and re-enable the box //
		self.grab_weapon_hint = true;
		self.chest_user = user;
		if(is_tactical_grenade(self.chest_origin.weapon_string))
		{
			self sethintstring( &"REIMAGINED_TRADE_EQUIPMENT" );
		}
		else
		{
			self sethintstring( &"ZOMBIE_TRADE_WEAPONS" );
		}
		self setCursorHint( "HINT_NOICON" );

		//self setvisibletoplayer( user );

		// Limit its visibility to the player who bought the box
		self enable_trigger();
		self thread treasure_chest_timeout();

		// make sure the guy that spent the money gets the item
		// SRS 9/3/2008: ...or item goes back into the box if we time out
		while( 1 )
		{
			self waittill( "trigger", grabber );
			self.weapon_out = undefined;
			if( IsDefined( grabber.is_drinking ) && grabber is_drinking() )
			{
				wait( 0.1 );
				continue;
			}

			if ( grabber == user && user GetCurrentWeapon() == "none" )
			{
				wait( 0.1 );
				continue;
			}

			primaryWeapons = undefined;
			if(grabber != level)
			{
				primaryWeapons = grabber GetWeaponsListPrimaries();
			}

			weapon_limit = 2;
			if( grabber HasPerk( "specialty_additionalprimaryweapon" ) )
		 	{
		 		weapon_limit = 3;
		 	}

			if( grabber != level && ( is_melee_weapon(grabber GetCurrentWeapon()) || is_placeable_mine(grabber GetCurrentWeapon()) ) && IsDefined(primaryWeapons) && primaryWeapons.size >= weapon_limit && !is_tactical_grenade(self.chest_origin.weapon_string) )
			{
				if(IsDefined(grabber.last_held_primary_weapon) && grabber HasWeapon(grabber.last_held_primary_weapon))
				{
					grabber SwitchToWeapon(grabber.last_held_primary_weapon);
				}
				else
				{
					grabber SwitchToWeapon(primaryWeapons[0]);
				}
				wait( 0.1 );
				continue;
			}

			if(grabber != level && (IsDefined(self.box_rerespun) && self.box_rerespun))
			{
				user = grabber;
			}

			if( grabber == user || grabber == level )
			{
				self.box_rerespun = undefined;
				current_weapon = "none";

				if(is_player_valid(user))
				{
					current_weapon = user GetCurrentWeapon();
				}

				if( grabber == user && is_player_valid( user ) && !user is_drinking() && !is_equipment( current_weapon ) && "syrette_sp" != current_weapon)
				{
					//don't let player take weapon from box if they have the upgraded verison of the weapon
					if(grabber has_upgrade(self.chest_origin.weapon_string))
					{
						continue;
					}

					bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type magic_accept",
						user.playername, user.score, level.team_pool[ user.team_num ].score, level.round_number, self.zombie_cost, self.chest_origin.weapon_string, self.origin );
					self notify( "user_grabbed_weapon" );
					user thread treasure_chest_give_weapon( self.chest_origin.weapon_string );

					// fix for grenade ammo
					if(is_lethal_grenade(self.chest_origin.weapon_string) || is_tactical_grenade(self.chest_origin.weapon_string))
					{
						ammo = 0;
						if(is_lethal_grenade(self.chest_origin.weapon_string))
						{
							ammo = 4;
						}
						else if(is_tactical_grenade(self.chest_origin.weapon_string))
						{
							ammo = 3;
						}

						/*if(user HasPerk("specialty_stockpile"))
						{
							ammo += 1;
						}*/

						user SetWeaponAmmoClip(self.chest_origin.weapon_string, ammo);
					}

					break;
				}
				else if( grabber == level )
				{
					// it timed out
					unacquire_weapon_toggle( self.chest_origin.weapon_string );
					self.timedOut = true;
					if(is_player_valid(user))
					{
						bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type magic_reject",
							user.playername, user.score, level.team_pool[ user.team_num ].score, level.round_number, self.zombie_cost, self.chest_origin.weapon_string, self.origin );
					}
					break;
				}
			}

			wait 0.05;
		}

		self.grab_weapon_hint = false;
		self.chest_origin notify( "weapon_grabbed" );

		if ( !is_true( self._box_opened_by_fire_sale ) )
		{
			//increase counter of amount of time weapon grabbed, but not during a fire sale
			level.chest_accessed += 1;
		}

		// PI_CHANGE_BEGIN
		// JMA - we only update counters when it's available
		if( level.chest_moves > 0 && isDefined(level.pulls_since_last_ray_gun) )
		{
			level.pulls_since_last_ray_gun += 1;
		}

		if( isDefined(level.pulls_since_last_tesla_gun) )
		{
			level.pulls_since_last_tesla_gun += 1;
		}
		// PI_CHANGE_END

		self disable_trigger();

		// spend cash here...
		// give weapon here...
		self.chest_lid thread treasure_chest_lid_close( self.timedOut );

		//Chris_P
		//magic box dissapears and moves to a new spot after a predetermined number of uses

		wait 1.5;
		if ( (is_true( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && self [[level._zombiemode_check_firesale_loc_valid_func]]()) || self == level.chests[level.chest_index] )
		{
			self enable_trigger();
			self setvisibletoall();
		}
	}

	self._box_open = false;
	self._box_opened_by_fire_sale = false;
	self.chest_user = undefined;

	self notify( "chest_accessed" );

	self thread treasure_chest_think();
}

//-------------------------------------------------------------------------------
//	Disable trigger if can't buy weapon and also if someone else is using the chest
//	DCS: Disable magic box hint if claymores out.
//-------------------------------------------------------------------------------
decide_hide_show_chest_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	while( true )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			// chest_user defined if someone bought a weapon spin, false when chest closed
			if ( (IsDefined(self.chest_user) && players[i] != self.chest_user ) || !players[i] can_buy_weapon() )
			{
				self SetInvisibleToPlayer( players[i], true );
			}
			else
			{
				self SetInvisibleToPlayer( players[i], false );
			}
		}
		wait( 0.1 );
	}
}

weapon_show_hint_choke()
{
	level._weapon_show_hint_choke = 0;

	while(1)
	{
		wait(0.05);
		level._weapon_show_hint_choke = 0;
	}
}

/*decide_hide_show_hint( endon_notify ) //OLD
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	if(!IsDefined(level._weapon_show_hint_choke))
	{
		level thread weapon_show_hint_choke();
	}

	use_choke = false;

	if(IsDefined(level._use_choke_weapon_hints) && level._use_choke_weapon_hints == 1)
	{
		use_choke = true;
	}


	while( true )
	{

		last_update = GetTime();

		if(IsDefined(self.chest_user) && !IsDefined(self.box_rerespun))//box when its open
		{
			primaryWeapons = self.chest_user GetWeaponsListPrimaries();
			if( is_placeable_mine( self.chest_user GetCurrentWeapon() ) || self.chest_user hacker_active() || (is_melee_weapon(self.chest_user GetCurrentWeapon()) && primaryWeapons.size > 0))
			{
				self SetInvisibleToPlayer( self.chest_user);
			}
			else
			{
				self SetVisibleToPlayer( self.chest_user );
			}
		}
		else if(IsDefined(self.zombie_weapon_upgrade))//wall weapons
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				current_weapon = players[i] GetCurrentWeapon();
				primaryWeapons = self.chest_user GetWeaponsListPrimaries();
				if((is_melee_weapon(current_weapon) || is_placeable_mine(current_weapon)) && primaryWeapons.size == 0)
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else if(is_equipment(current_weapon))
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else if((is_melee_weapon(current_weapon) || is_placeable_mine(current_weapon)) && players[i] has_weapon_or_upgrade(self.zombie_weapon_upgrade))
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else if( IsDefined( players[i].is_drinking ) && players[i] is_drinking() && !players[i] HasWeapon("minigun_zm") && players[i] has_weapon_or_upgrade(self.zombie_weapon_upgrade) )
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else if( players[i] can_buy_weapon())
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else
				{
					self SetInvisibleToPlayer( players[i], true );
				}
			}
		}
		else //box when its closed
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				current_weapon = players[i] GetCurrentWeapon();
				if( IsDefined( players[i].is_drinking ) && players[i] is_drinking() && !players[i] HasWeapon("minigun_zm") )
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else if(is_melee_weapon(current_weapon) || is_placeable_mine(current_weapon) || is_equipment(current_weapon))
				{
					if(IsDefined(self.zombie_weapon_upgrade))
					{
						if(players[i] has_weapon_or_upgrade(self.zombie_weapon_upgrade))
						{
							self SetInvisibleToPlayer( players[i], false );
						}
						else
						{
							self SetInvisibleToPlayer( players[i], true );
						}
					}
					else
					{
						self SetInvisibleToPlayer( players[i], false );
					}
				}
				else if( players[i] can_buy_weapon())
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else
				{
					self SetInvisibleToPlayer( players[i], true );
				}
			}
		}

		if(use_choke)
		{
			while((level._weapon_show_hint_choke > 4) && (GetTime() < (last_update + 150)))
			{
				wait 0.05;
			}
		}
		else
		{
			wait(0.1);
		}

		level._weapon_show_hint_choke ++;
	}
}*/

decide_hide_show_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	if(!IsDefined(level._weapon_show_hint_choke))
	{
		level thread weapon_show_hint_choke();
	}

	use_choke = false;

	if(IsDefined(level._use_choke_weapon_hints) && level._use_choke_weapon_hints == 1)
	{
		use_choke = true;
	}

	dist = 256 * 256;

	while( true )
	{

		last_update = GetTime();

		if(IsDefined(self.chest_user) && !IsDefined(self.box_rerespun)) //box when it is open
		{
			primaryWeapons = self.chest_user GetWeaponsListPrimaries();
			if( self.chest_user can_buy_weapon())
			{
				self SetInvisibleToPlayer( self.chest_user, false );
			}
			else
			{
				self SetInvisibleToPlayer( self.chest_user, true );
			}
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(players[i] != self.chest_user && players[i].sessionstate != "spectator")
				{
					self SetInvisibleToPlayer( players[i], true );
				}
			}
		}
		else if(IsDefined(self.placeable_mine_name)) //mines
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					current_weapon = players[i] GetCurrentWeapon();
					if( players[i] is_player_placeable_mine( self.placeable_mine_name ) && players[i] GetWeaponAmmoClip(self.placeable_mine_name) == WeaponClipSize(self.placeable_mine_name) )
					{
						self SetInvisibleToPlayer( players[i], true );
					}
					else if( players[i] can_buy_weapon())
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else
					{
						self SetInvisibleToPlayer( players[i], true );
					}
				}
			}
		}
		else if(IsDefined(self.melee_wallbuy_name)) //melee wallbuys
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					if( players[i] HasWeapon( self.melee_wallbuy_name ) )
					{
						self SetInvisibleToPlayer( players[i], true );
					}
					else if( players[i] isSwitchingWeapons() )
					{
						self SetInvisibleToPlayer( players[i], true );
					}
					else if( players[i] can_buy_weapon())
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else
					{
						self SetInvisibleToPlayer( players[i], true );
					}
				}
			}
		}
		else if(IsDefined(self.zombie_weapon_upgrade) || IsDefined(self.zombie_weapon_cabinet)) //wall weapons
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					weapon = self.zombie_weapon_upgrade;
					current_weapon = players[i] GetCurrentWeapon();
					primaryWeapons = players[i] GetWeaponsListPrimaries();
					weapon_type = WeaponType( self.zombie_weapon_upgrade );
					pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
					has_weapon = players[i] HasWeapon(self.zombie_weapon_upgrade);
					has_weapon_upgrade = players[i] has_upgrade(self.zombie_weapon_upgrade) && weapon_type != "grenade" && pap_triggers.size > 0;
					player_ammo = undefined;
					max_ammo = undefined;
					player_alt_ammo = undefined;
					max_alt_ammo = undefined;

					if(has_weapon || has_weapon_upgrade)
					{
						if(has_weapon_upgrade)
						{
							weapon = level.zombie_weapons[self.zombie_weapon_upgrade].upgrade_name;
						}

						player_ammo = players[i] GetWeaponAmmoStock(weapon);
						max_ammo = WeaponMaxAmmo(weapon);
						dual_wield_weapon = WeaponDualWieldWeaponName(weapon);
						alt_weapon = WeaponAltWeaponName(weapon);

						if(weapon_type != "grenade")
						{
							if(players[i] HasPerk("specialty_stockpile"))
							{
								max_ammo += WeaponClipSize(weapon);
							}
						}
	
						if(dual_wield_weapon != "none")
						{
							if(players[i] HasPerk("specialty_stockpile"))
							{
								max_ammo += WeaponClipSize(weapon);
							}
						}

						if(alt_weapon != "none")
						{
							player_alt_ammo = players[i] GetWeaponAmmoStock(alt_weapon);
							max_alt_ammo = WeaponMaxAmmo(alt_weapon);
							if(players[i] HasPerk("specialty_stockpile"))
							{
								max_alt_ammo += WeaponClipSize(alt_weapon);
							}
						}
					}

					// fix for grenade ammo
					if(is_lethal_grenade(self.zombie_weapon_upgrade) || is_tactical_grenade(self.zombie_weapon_upgrade))
					{
						if(is_lethal_grenade(self.zombie_weapon_upgrade))
						{
							max_ammo = 4;
						}
						else if(is_tactical_grenade(self.zombie_weapon_upgrade))
						{
							max_ammo = 3;
						}

						/*if(players[i] HasPerk("specialty_stockpile"))
						{
							max_ammo += 1;
						}*/
					}

					if(IsDefined(player_ammo) && IsDefined(max_ammo) && !IsDefined(player_alt_ammo) && !IsDefined(max_alt_ammo) && player_ammo == max_ammo)
					{
						self SetInvisibleToPlayer( players[i], true );
					}
					else if(IsDefined(player_ammo) && IsDefined(max_ammo) && IsDefined(player_alt_ammo) && IsDefined(max_alt_ammo) && player_ammo == max_ammo && player_alt_ammo == max_alt_ammo)
					{
						self SetInvisibleToPlayer( players[i], true );
					}
					else if( players[i] can_buy_weapon() )
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else
					{
						self SetInvisibleToPlayer( players[i], true );
					}
				}
			}
		}
		else if(IsDefined(self.box_rerespun)) //box when its been hacked twice (powerup form)
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					current_weapon = players[i] GetCurrentWeapon();
					primaryWeapons = players[i] GetWeaponsListPrimaries();

					if( players[i] can_buy_weapon())
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else
					{
						self SetInvisibleToPlayer( players[i], true );
					}
				}
			}
		}
		else //box when it is closed
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					current_weapon = players[i] GetCurrentWeapon();

					if(is_placeable_mine(current_weapon))
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else if( IsDefined( players[i].is_drinking ) && players[i] is_drinking() && !players[i] has_powerup_weapon() )
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else if( players[i] can_buy_weapon())
					{
						self SetInvisibleToPlayer( players[i], false );
					}
					else
					{
						self SetInvisibleToPlayer( players[i], true );
					}
				}
			}
		}

		if(use_choke)
		{
			while((level._weapon_show_hint_choke > 4) && (GetTime() < (last_update + 150)))
			{
				wait 0.05;
			}
		}
		else
		{
			wait(0.05);
		}

		level._weapon_show_hint_choke ++;
	}
}

can_buy_weapon()
{
	if( IsDefined( self.is_drinking ) && self is_drinking() )
	{
		return false;
	}

	if(self hacker_active())
	{
		return false;
	}

	current_weapon = self GetCurrentWeapon();
	if( is_equipment( current_weapon ) )
	{
		return false;
	}

	/*primaryWeapons = self GetWeaponsListPrimaries();
	if( is_melee_weapon(current_weapon) && primaryWeapons.size > 0 ) //TODO - make so can buy weapons with 0 weps //might be fixed?
	{
		return false;
	}*/

	if( self in_revive_trigger() )
	{
		return false;
	}

	if( current_weapon == "none" )
	{
		return false;
	}

	return true;
}

default_box_move_logic()
{
	// Check to see if there's a chest selection we should use for this move
	// This is indicated by a script_noteworthy of "moveX*"
	//	(e.g. move1_chest0, move1_chest1)  We will randomly choose between
	//		one of those two chests for that move number only.
	index = -1;
	for ( i=0; i<level.chests.size; i++ )
	{
		// Check to see if there is something that we have a choice to move to for this move number
		if ( IsSubStr( level.chests[i].script_noteworthy, ("move"+(level.chest_moves+1)) ) &&
			 i != level.chest_index )
		{
			index = i;
			break;
		}
	}

	if ( index != -1 )
	{
		level.chest_index = index;
	}
	else
	{
		level.chest_index++;
	}

	if (level.chest_index >= level.chests.size)
	{
		//PI CHANGE - this way the chests won't move in the same order the second time around
		temp_chest_name = level.chests[level.chest_index - 1].script_noteworthy;
		level.chest_index = 0;
		level.chests = array_randomize(level.chests);
		//in case it happens to randomize in such a way that the chest_index now points to the same location
		// JMA - want to avoid an infinite loop, so we use an if statement
		if (temp_chest_name == level.chests[level.chest_index].script_noteworthy)
		{
			level.chests = array_swap(level.chests, 0, RandomIntRange(1, level.chests.size));
		}
		//END PI CHANGE
	}
}

//
//	Chest movement sequence, including lifting the box up and disappearing
//
treasure_chest_move( player_vox )
{
	level waittill("weapon_fly_away_start");

	players = get_players();

	array_thread(players, ::play_crazi_sound);

	level waittill("weapon_fly_away_end");

	self.chest_lid thread treasure_chest_lid_close(false);
	self setvisibletoall();

	self treasure_chest_fly_away(true);

	if( IsDefined( player_vox ) )
    {
        player_vox maps\_zombiemode_audio::create_and_play_dialog( "general", "box_move" );
    }

    if(IsDefined(level._zombiemode_custom_box_move_logic))
	{
		[[level._zombiemode_custom_box_move_logic]]();
	}
	else
	{
		default_box_move_logic();
	}

	// DCS 072710: check if fire sale went into effect during move, reset with time left.
	if(level.zombie_vars["zombie_powerup_fire_sale_on"] == true)
	{
		if(self [[level._zombiemode_check_firesale_loc_valid_func]]())
		{
			self thread fire_sale_fix();

			while(level.zombie_vars["zombie_powerup_fire_sale_time"] > 0)
			{
				wait(0.1);
			}
		}
	}
	else
	{
		if(IsDefined(level.chests[level.chest_index].box_hacks["summon_box"]))
		{
			level.chests[level.chest_index] [[level.chests[level.chest_index].box_hacks["summon_box"]]](false);
		}

		level.chests[level.chest_index] treasure_chest_fly_away(false);
	}

	level.verify_chest = false;

	flag_clear("moving_chest_now");
	self.chest_origin.chest_moving = false;
	level notify("moving_chest_done");
}

treasure_chest_fly_away(up, no_sound)
{
	if(!IsDefined(up))
	{
		up = true;
	}

	if(!IsDefined(up))
	{
		fire_sale = false;
	}

	if((up && self.hidden) || (!up && !self.hidden))
	{
		return;
	}

	if(is_true(self.moving))
	{
		self waittill("box_move_done");

		if((up && self.hidden) || (!up && !self.hidden))
		{
			return;
		}
	}

	self.moving = true;

	fake_pieces = [];
	fake_pieces[0] = spawn("script_model",self.chest_lid.origin);
	fake_pieces[0].angles = self.chest_lid.angles;
	fake_pieces[0] setmodel(self.chest_lid.model);

	fake_pieces[1] = spawn("script_model",self.chest_box.origin);
	fake_pieces[1].angles = self.chest_box.angles;
	fake_pieces[1] setmodel(self.chest_box.model);

	anchor = spawn("script_origin",fake_pieces[0].origin);
	soundpoint = spawn("script_origin", self.chest_origin.origin);

	for(i=0;i<fake_pieces.size;i++)
	{
		fake_pieces[i] linkto(anchor);
	}

	dist = (0,0,75);

	if(up)
	{
		self hide_chest();

		anchor playsound("zmb_box_move");
		playsoundatposition ("zmb_whoosh", soundpoint.origin );

		if(!no_sound)
		{
			if( is_true( level.player_4_vox_override ) )
			{
				playsoundatposition ("zmb_vox_rich_magicbox", soundpoint.origin );
			}
			else
			{
				playsoundatposition ("zmb_vox_ann_magicbox", soundpoint.origin );
			}
		}

		anchor moveto(anchor.origin + dist, 5);
	}
	else
	{
		self hide_rubble();

		playfx(level._effect["poltergeist"], self.chest_origin.origin);
		playsoundatposition ("zmb_box_poof", soundpoint.origin);

		anchor.origin = anchor.origin + dist;
		anchor moveto(anchor.origin - dist, 2.5);
	}

	//anchor rotateyaw(360 * 10,5,5);
	if( isDefined( level.custom_vibrate_func ) )
	{
		[[ level.custom_vibrate_func ]]( anchor );
	}
	else
	{
	   	//Get the normal of the box using the positional data of the box and self.chest_lid
	   	direction = self.chest_box.origin - self.chest_lid.origin;
	   	direction = (direction[1], direction[0], 0);

	   	if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
	   	{
        	direction = (direction[0], direction[1] * -1, 0);
       	}
       	else if(direction[0] < 0)
       	{
            direction = (direction[0] * -1, direction[1], 0);
       	}

       	if(up)
       	{
       		anchor Vibrate( direction, 10, 0.5, 5);
       	}
        else
        {
        	anchor Vibrate( direction, 10, 0.5, 2.5);
        }
	}

	//anchor thread rotateroll_box();
	anchor waittill("movedone");
	//players = get_players();
	//array_thread(players, ::play_crazi_sound);
	//wait(3.9);

	if(up)
	{
		playfx(level._effect["poltergeist"], self.chest_origin.origin);
		playsoundatposition ("zmb_box_poof", soundpoint.origin);

		self show_rubble();
	}
	else
	{
		self show_chest();
	}

	for(i=0;i<fake_pieces.size;i++)
	{
		fake_pieces[i] delete();
	}

	anchor delete();
	soundpoint delete();

	self.moving = undefined;
	self notify("box_move_done");
}


fire_sale_fix()
{
	if( !isdefined ( level.zombie_vars["zombie_powerup_fire_sale_on"] ) )
	{
		return;
	}

	if( level.zombie_vars["zombie_powerup_fire_sale_on"] )
	{
		self.old_cost = 950;
		self thread maps\_zombiemode_weapons::treasure_chest_fly_away(false, true);
		self.zombie_cost = 10;
		self SetHintString(&"REIMAGINED_MYSTERY_BOX", self.zombie_cost);

		while(level.zombie_vars["zombie_powerup_fire_sale_time"] > 0)
		{
			wait(.1);
		}

		while(is_true(self._box_open))
		{
			wait(.1);
		}

		if(level.zombie_vars["zombie_powerup_fire_sale_on"])
		{
			return;
		}

		self thread maps\_zombiemode_weapons::treasure_chest_fly_away(true, true);

		self.zombie_cost = self.old_cost;
		//self set_hint_string( self , "reimagined_treasure_chest_" + self.zombie_cost );
		self SetHintString(&"REIMAGINED_MYSTERY_BOX", self.zombie_cost);
	}
}

check_for_desirable_chest_location()
{
	if( !isdefined( level.desirable_chest_location ) )
		return level.chest_index;

	if( level.chests[level.chest_index].script_noteworthy == level.desirable_chest_location )
	{
		level.desirable_chest_location = undefined;
		return level.chest_index;
	}
	for(i = 0 ; i < level.chests.size; i++ )
	{
		if( level.chests[i].script_noteworthy == level.desirable_chest_location )
		{
			level.desirable_chest_location = undefined;
			return i;
		}
	}

	/#
		//iprintln(level.desirable_chest_location + " is an invalid box location!");
#/
	level.desirable_chest_location = undefined;
	return level.chest_index;
}


rotateroll_box()
{
	angles = 40;
	angles2 = 0;
	//self endon("movedone");
	while(isdefined(self))
	{
		self RotateRoll(angles + angles2, 0.5);
		wait(0.7);
		angles2 = 40;
		self RotateRoll(angles * -2, 0.5);
		wait(0.7);
	}



}
//verify if that magic box is open to players or not.
verify_chest_is_open()
{

	//for(i = 0; i < 5; i++)
	//PI CHANGE - altered so that there can be more than 5 valid chest locations
	for (i = 0; i < level.open_chest_location.size; i++)
	{
		if(isdefined(level.open_chest_location[i]))
		{
			if(level.open_chest_location[i] == level.chests[level.chest_index].script_noteworthy)
			{
				level.verify_chest = true;
				return;
			}
		}

	}

	level.verify_chest = false;


}


treasure_chest_timeout()
{
	self endon( "user_grabbed_weapon" );
	self.chest_origin endon( "box_hacked_respin" );
	self.chest_origin endon( "box_hacked_rerespin" );

	player = self.chest_user;
	weapon = self.chest_origin.weapon_string;

	wait( 9 );
	
	/*if(IsDefined(player.already_got_weapons) && is_in_array(player.already_got_weapons, weapon))
	{
		player.already_got_weapons = array_remove(player.already_got_weapons, weapon);
	}*/
	self notify( "trigger", level );
}

treasure_chest_lid_open()
{
	openRoll = 105;
	openTime = 0.5;

	self RotateRoll( 105, openTime, ( openTime * 0.5 ) );

	play_sound_at_pos( "open_chest", self.origin );
	play_sound_at_pos( "music_chest", self.origin );
}

treasure_chest_lid_close( timedOut )
{
	closeRoll = -105;
	closeTime = 0.5;

	self RotateRoll( closeRoll, closeTime, ( closeTime * 0.5 ) );
	play_sound_at_pos( "close_chest", self.origin );

	self notify("lid_closed");
}

treasure_chest_ChooseRandomWeapon( player )
{
	// this function is for display purposes only, so there's no need to bother limiting which weapons can be displayed
	// while they float, only the last selection needs to be limited, which is decided by treasure_chest_ChooseWeightedRandomWeapon()
	// plus, this is all clientsided at this point anyway
	keys = GetArrayKeys( level.zombie_weapons );
	return keys[RandomInt( keys.size )];

}

//Tags: Mystery box, weapons, box weapons, HERE
treasure_chest_ChooseWeightedRandomWeapon( player, final_wep, empty )
{
	if(IsDefined(player) && !IsDefined( player.already_got_weapons )  )	//Back to regular randomness - Reimagined-Expanded
		player.already_got_weapons = [];

	keys = GetArrayKeys( level.zombie_weapons );

	toggle_weapons_in_use = 0;
	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		//iprintln( "1" );
		if( !is_true( get_is_in_box( keys[i] ) ) )
		{
			//iprintln( "2" );
			//iprintln( keys[i] + " is not in the box" );
			continue;
		}

		if( isdefined( player ) && is_player_valid(player) && player has_weapon_or_upgrade( keys[i] ) )
		{
			if ( is_weapon_toggle( keys[i] ) )
			{
				toggle_weapons_in_use++;
			}
			//iprintln( "3" );
			continue;
		}

		if( !IsDefined( keys[i] ) )
		{
			//iprintln( "4" );
			continue;
		}

		if(IsDefined(player) && is_in_array( player.already_got_weapons, keys[i] ))
		{
			//iprintln( "5" );
			continue;
		}

		//Special conditions
		/*
		Reimagined-Expanded - Maybe switching specials with wine is fine
		if( player maps\_zombiemode_perks::hasProPerk( level.WWN_PRO )  )
		{
			if( keys[i] == "zombie_quantum_bomb" 
			|| keys[i] == "zombie_black_hole_bomb" 
			|| keys[i] == "zombie_cymbal_monkey" 
			|| keys[i] == "molotov_zm" 
			)
			{
				//iprintln( "6" );
				continue;
			}

		}
		else
		{
			if( keys[i] == "bo3_zm_widows_grenade" )
			{
				//iprintln( "6.6" );
				continue;
			} 
		}
		*/

		if(  IsDefined(player.weapon_taken_by_losing_additionalprimaryweapon[0]) )
		{
			base_wep = player.weapon_taken_by_losing_additionalprimaryweapon[0];
			//iprintln( "base_wep: " + base_wep );
			if( IsSubStr( base_wep, "_x2" ) )
				base_wep = GetSubStr( base_wep, 0, base_wep.size - "_x2".size );

			if( IsSubStr( base_wep, "_upgraded" ) )
				base_wep = GetSubStr( base_wep, 0, base_wep.size - "upgraded_zm".size ) + "_zm";

			//iprintln( "7" );
			if( keys[i] == base_wep )
				continue;
		}


		
		if( keys[i] == "saberooth_zm" ) // Filter out saberooth_zm if any player has it
		{
			players = get_players();
			for( j = 0; j < players.size; j++ )
			{
				if( players[j] has_weapon_or_upgrade( "saberooth_zm" ) )
				{
					//iprintln( "8" );
					continue;
				}
			}
		}

		//iprintln( "9 - Adding weapon" );
		//iprintln( keys[i] );
		filtered[filtered.size] = keys[i];

		/*num_entries = [[ level.weapon_weighting_funcs[keys[i]] ]]();

		for( j = 0; j < num_entries; j++ )
		{
			filtered[filtered.size] = keys[i];
		}*/
	}

	// Filter out the limited weapons
	if( IsDefined( level.limited_weapons ) )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
		for( q = 0; q < keys2.size; q++ )
		{
			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] has_weapon_or_upgrade( keys2[q] ) )
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

			if ( is_weapon_toggle( keys2[q] ) )
			{
				toggle_weapons_in_use += count;
			}

			if( count >= level.limited_weapons[keys2[q]] )
			{
				filtered = array_remove( filtered, keys2[q] );
			}
		}
	}

	// finally, filter based on toggle mechanic
	/*
	if ( IsDefined( level.zombie_weapon_toggles ) )
	{
		keys2 = GetArrayKeys( level.zombie_weapon_toggles );
		for( q = 0; q < keys2.size; q++ )
		{
			if ( level.zombie_weapon_toggles[keys2[q]].active )
			{
				if ( toggle_weapons_in_use < level.zombie_weapon_toggle_max_active_count )
				{
					continue;
				}
			}

			filtered = array_remove( filtered, keys2[q] );
		}
	}
	*/

	//just getting the new list of weapons a player can get from another call
	if(IsDefined(empty) && empty)
	{
		return filtered;
	}

	//reset the weapons a player can get if no weapons available
	if(IsDefined(player) && filtered.size == 0)
	{
		player.already_got_weapons = [];
		if(filtered.size == 0)
			filtered = treasure_chest_ChooseWeightedRandomWeapon( player, undefined, true );
	}

	// try to "force" a little more "real randomness" by randomizing the array before randomly picking a slot in it
	filtered = array_randomize( filtered );
	wep = filtered[RandomInt( filtered.size )];

	//show a new weapon every time, except for if there's only one weapon in the box then we can't
	if(IsDefined(self.previous_floating_weapon) && self.previous_floating_weapon == wep && filtered.size > 1)
	{
		temp = wep;
		filtered = array_remove( filtered, wep );
		wep = filtered[RandomInt( filtered.size )];

		//must add back the wep into filtered for the next if statement to work correctly
		filtered[filtered.size] = temp;
	}

	self.previous_floating_weapon = wep;
	return wep;
}

// Functions namesake in _zombiemode_weapons.csc must match this one.

weapon_is_dual_wield(name)
{
	switch(name)
	{
		case  "cz75dw_zm":
		case  "cz75dw_upgraded_zm":
		case  "m1911_upgraded_zm":
		case  "hs10_upgraded_zm":
		case  "pm63_upgraded_zm":
		case  "microwavegundw_zm":
		case  "microwavegundw_upgraded_zm":
			return true;
		default:
			return false;
	}
}

get_left_hand_weapon_model_name( name )
{
	switch ( name )
	{
		case  "microwavegundw_zm":
			return GetWeaponModel( "microwavegunlh_zm" );
		case  "microwavegundw_upgraded_zm":
			return GetWeaponModel( "microwavegunlh_upgraded_zm" );
		default:
			return GetWeaponModel( name );
	}
}

clean_up_hacked_box()
{
	//self waittill("box_hacked_respin");
	//self endon("box_spin_done");

	if(IsDefined(self.weapon_model))
	{
		self.weapon_model Delete();
		self.weapon_model = undefined;
	}

	if(IsDefined(self.weapon_model_dw))
	{
		self.weapon_model_dw Delete();
		self.weapon_model_dw = undefined;
	}
}

treasure_chest_weapon_spawn( chest, player, respin )
{
	self endon("box_hacked_respin");
	self clean_up_hacked_box();
	assert(IsDefined(player));
	// spawn the model
//	model = spawn( "script_model", self.origin );
//	model.angles = self.angles +( 0, 90, 0 );

//	floatHeight = 40;

	//move it up
//	model moveto( model.origin +( 0, 0, floatHeight ), 3, 2, 0.9 );

	// rotation would go here

	// make with the mario kart
	/*self.weapon_string = undefined;
	modelname = undefined;
	rand = undefined;
	number_cycles = 40;*/

	/*chest.chest_box setclientflag(level._ZOMBIE_SCRIPTMOVER_FLAG_BOX_RANDOM);

	for( i = 0; i < number_cycles; i++ )
	{

		if( i < 20 )
		{
			wait( 0.05 );
		}
		else if( i < 30 )
		{
			wait( 0.1 );
		}
		else if( i < 35 )
		{
			wait( 0.2 );
		}
		else if( i < 38 )
		{
			wait( 0.3 );
		}

		if( i + 1 < number_cycles )
		{
			rand = treasure_chest_ChooseRandomWeapon( player );
		}
		else
		{
			rand = treasure_chest_ChooseWeightedRandomWeapon( player );
			//rand = "zombie_quantum_bomb";

/#
			weapon = GetDvar( #"scr_force_weapon" );
			if ( weapon != "" && IsDefined( level.zombie_weapons[ weapon ] ) )
			{
				rand = weapon;
				SetDvar( "scr_force_weapon", "" );
			}
#/
		}
	}

	// Here's where the org get it's weapon type for the give function
	self.weapon_string = rand;

	chest.chest_box clearclientflag(level._ZOMBIE_SCRIPTMOVER_FLAG_BOX_RANDOM);*/


	//self.model_dw = undefined;

	//self.weapon_model = spawn( "script_model", self.origin + ( 0, 0, floatHeight));
	//self.weapon_model.angles = self.angles +( 0, 90, 0 );

	self.previous_floating_weapon = undefined;

	self weapon_floats_up(player);

	wait_network_frame();

	// Increase the chance of joker appearing from 0-100 based on amount of the time chest has been opened.
	if( (GetDvar( #"magic_chest_movable") == "1") && !is_true( chest._box_opened_by_fire_sale ) && !(is_true( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && self [[level._zombiemode_check_firesale_loc_valid_func]]()) )
	{
		// random change of getting the joker that moves the box
		random = Randomint(100);

		if( !isdefined( level.chest_min_move_usage ) )
		{
			level.chest_min_move_usage = 4;
		}

		if( level.chest_accessed < level.chest_min_move_usage )
		{
			chance_of_joker = -1;
			//chance_of_joker = 70; Reimagined-Expanded, make chst move instantly
		}
		else
		{
			chance_of_joker = level.chest_accessed + 20;

			// make sure teddy bear appears on the 8th pull if it hasn't moved from the initial spot
			if ( level.chest_moves == 0 && level.chest_accessed >= 8 )
			{
				chance_of_joker = 100;
			}

			// pulls 4 thru 8, there is a 15% chance of getting the teddy bear
			// NOTE:  this happens in all cases
			if( level.chest_accessed >= 4 && level.chest_accessed < 8 )
			{
				if( random < 15 )
				{
					chance_of_joker = 100;
				}
				else
				{
					chance_of_joker = -1;
				}
			}

			// after the first magic box move the teddy bear percentages changes
			if ( level.chest_moves > 0 )
			{
				// between pulls 8 thru 12, the teddy bear percent is 30%
				if( level.chest_accessed >= 8 && level.chest_accessed < 13 )
				{
					if( random < 30 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}

				// after 12th pull, the teddy bear percent is 50%
				if( level.chest_accessed >= 13 )
				{
					if( random < 50 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
			}
		}

		if(IsDefined(chest.no_fly_away))
		{
			chance_of_joker = -1;
		}

		if(IsDefined(level._zombiemode_chest_joker_chance_mutator_func))
		{
			chance_of_joker = [[level._zombiemode_chest_joker_chance_mutator_func]](chance_of_joker);
		}

		if ( chance_of_joker > random )
		{
			self.weapon_string = undefined;

			// Delete and respawn the weapon model for the teddy bear so that it faces the correct angle right away

			origin = self.weapon_model.origin;

			self.weapon_model Delete();

			self.weapon_model = spawn("script_model", origin);
			self.weapon_model.angles = self.angles;

			//self.weapon_model SetModel("zombie_teddybear");
			if(level.script == "zombie_cosmodrome")
			{
				self.weapon_model SetModel("zombie_teddybear_reaper");
			}
			else
			{
				self.weapon_model SetModel("zombie_teddybear");
			}

			//model rotateto(level.chests[level.chest_index].angles, 0.01);
			//wait(1);
			//self.weapon_model.angles = self.angles;

			if(IsDefined(self.weapon_model_dw))
			{
				self.weapon_model_dw Delete();
				self.weapon_model_dw = undefined;
			}

			self.chest_moving = true;
			flag_set("moving_chest_now");
			level notify("moving_chest_now");
			level.chest_accessed = 0;

			//allow power weapon to be accessed.
			level.chest_moves++;

			if(level.chest_index + 1 >= level.chests.size)
			{
				PlayFX( level._effect["powerup_grabbed"], self.weapon_model.origin + (0, 0, 18) );
			}
		}
	}

	self notify( "randomization_done" );

	if (flag("moving_chest_now") && !is_true(chest._box_opened_by_fire_sale) && !(level.zombie_vars["zombie_powerup_fire_sale_on"] && self [[level._zombiemode_check_firesale_loc_valid_func]]()))
	{
		wait .5;	// we need a wait here before this notify
		level notify("weapon_fly_away_start");
		wait 2;
		self.weapon_model MoveZ(500, 4, 3);

		if(IsDefined(self.weapon_model_dw))
		{
			self.weapon_model_dw MoveZ(500,4,3);
		}

		self.weapon_model waittill("movedone");
		self.weapon_model delete();

		if(IsDefined(self.weapon_model_dw))
		{
			self.weapon_model_dw Delete();
			self.weapon_model_dw = undefined;
		}

		self notify( "box_moving" );
		level notify("weapon_fly_away_end");
	}
	else
	{
		rand = treasure_chest_ChooseWeightedRandomWeapon( player, true );

		self.weapon_string = rand;

		floatHeight = 40;

		modelname = GetWeaponModel( rand );
		self.weapon_model setmodel( modelname );
		self.weapon_model useweaponhidetags( rand );

		if ( weapon_is_dual_wield(rand))
		{
			//self.weapon_model_dw = spawn( "script_model", self.weapon_model.origin - ( 3, 3, 3 ) ); // extra model for dualwield weapons
			//self.weapon_model_dw.angles = self.angles +( 0, 90, 0 );

			self.weapon_model_dw setmodel( get_left_hand_weapon_model_name( rand ) );
			self.weapon_model_dw useweaponhidetags( rand );
			self.weapon_model_dw show();
		}
		else
		{
			self.weapon_model_dw hide();
		}

		if( !isdefined( player.already_got_weapons_count ) )
		{
			player.already_got_weapons_count = 0;
		}
		else if( player.already_got_weapons_count > 4 )
		{
			player.already_got_weapons_count = 0;
		}

		player.already_got_weapons[player.already_got_weapons_count] = rand;
		player.already_got_weapons_count++;

		acquire_weapon_toggle( rand, player );

		//turn off power weapon, since player just got one
		if( rand == "tesla_gun_zm" || rand == "ray_gun_zm" )
		{
			if( rand == "ray_gun_zm" )
			{
//				level.chest_moves = false;
				level.pulls_since_last_ray_gun = 0;
			}

			if( rand == "tesla_gun_zm" )
			{
				level.pulls_since_last_tesla_gun = 0;
				level.player_seen_tesla_gun = true;
			}
		}

		if(!IsDefined(respin))
		{
			if(IsDefined(chest.box_hacks["respin"]))
			{
				self [[chest.box_hacks["respin"]]](chest, player);
			}
		}
		else
		{
			if(IsDefined(chest.box_hacks["respin_respin"]))
			{
				self [[chest.box_hacks["respin_respin"]]](chest, player);
			}
		}
		self.weapon_model thread timer_til_despawn(floatHeight);
		if(IsDefined(self.weapon_model_dw))
		{
			self.weapon_model_dw thread timer_til_despawn(floatHeight);
		}

		self waittill( "weapon_grabbed" );

		if( !chest.timedOut )
		{
			if(IsDefined(self.weapon_model))
			{
				self.weapon_model Delete();
			}

			if(IsDefined(self.weapon_model_dw))
			{
				self.weapon_model_dw Delete();
			}
		}
	}

	self.weapon_string = undefined;
	self notify("box_spin_done");
}

weapon_floats_up(player)
{
	//self cleanup_weapon_models();

	number_cycles = 37;
	floatHeight = 40;

	rand = treasure_chest_ChooseWeightedRandomWeapon(player);
	modelname = GetWeaponModel( rand );

	self.weapon_model = spawn("script_model", self.origin);
	self.weapon_model.angles = self.angles + ( 0, 90, 0 );
	self.weapon_model_dw = spawn("script_model", self.weapon_model.origin - ( 3, 3, 3 ));
	self.weapon_model_dw.angles = self.weapon_model.angles;
	self.weapon_model_dw Hide();

	self.weapon_model SetModel( modelname );
	self.weapon_model_dw SetModel(modelname);
	self.weapon_model useweaponhidetags( rand );

	//move it up
	self.weapon_model moveto( self.origin + ( 0, 0, floatHeight ), 3, 2, 0.9 );
	self.weapon_model_dw MoveTo(self.origin + (0,0,floatHeight) - ( 3, 3, 3 ), 3, 2, 0.9);

	for( i = 0; i < number_cycles; i++ )
	{

		if( i < 20 )
		{
			wait( 0.05 );
		}
		else if( i < 30 )
		{
			wait( 0.10 );
		}
		else if( i < 35 )
		{
			wait( 0.20 );
		}
		else
		{
			wait( 0.30 );
		}

		//debugstar(self.weapon_models[0].origin, 20, (0,1,0));

		rand = treasure_chest_ChooseWeightedRandomWeapon(player);
		modelname = GetWeaponModel( rand );

		if(IsDefined(self.weapon_model))
		{
			self.weapon_model SetModel( modelname );
			self.weapon_model useweaponhidetags( rand );

			if(weapon_is_dual_wield(rand))
			{
				self.weapon_model_dw SetModel( get_left_hand_weapon_model_name( rand ) );
				self.weapon_model_dw useweaponhidetags(rand);
				self.weapon_model_dw show();
			}
			else
			{
				self.weapon_model_dw Hide();
			}
		}
	}

	wait(.3);

	//self cleanup_weapon_models();
}

cleanup_weapon_models()
{
	if(IsDefined(self.weapon_model))
	{
		if(IsDefined(self.weapon_model))
		{
			self.weapon_model_dw Delete();
			self.weapon_model Delete();
		}
		self.weapon_model = undefined;
	}
}

//
//
chest_get_min_usage()
{
	min_usage = 4;

	/*
	players = get_players();

	// Special case min box pulls before 1st box move
	if( level.chest_moves == 0 )
	{
		if( players.size == 1 )
		{
			min_usage = 2;
		}
		else if( players.size == 2 )
		{
			min_usage = 2;
		}
		else if( players.size == 3 )
		{
			min_usage = 3;
		}
		else
		{
			min_usage = 4;
		}
	}
	// Box has moved, what is the minimum number of times it can move again?
	else
	{
		if( players.size == 1 )
		{
			min_usage = 2;
		}
		else if( players.size == 2 )
		{
			min_usage = 2;
		}
		else if( players.size == 3 )
		{
			min_usage = 3;
		}
		else
		{
			min_usage = 3;
		}
	}
	*/

	return( min_usage );
}

//
//
chest_get_max_usage()
{
	max_usage = 6;

	players = get_players();

	// Special case max box pulls before 1st box move
	if( level.chest_moves == 0 )
	{
		if( players.size == 1 )
		{
			max_usage = 3;
		}
		else if( players.size == 2 )
		{
			max_usage = 4;
		}
		else if( players.size == 3 )
		{
			max_usage = 5;
		}
		else
		{
			max_usage = 6;
		}
	}
	// Box has moved, what is the maximum number of times it can move again?
	else
	{
		if( players.size == 1 )
		{
			max_usage = 4;
		}
		else if( players.size == 2 )
		{
			max_usage = 4;
		}
		else if( players.size == 3 )
		{
			max_usage = 5;
		}
		else
		{
			max_usage = 7;
		}
	}
	return( max_usage );
}


timer_til_despawn(floatHeight)
{
	self endon("kill_weapon_movement");
	// SRS 9/3/2008: if we timed out, move the weapon back into the box instead of deleting it
	putBackTime = 9;
	self MoveTo( self.origin - ( 0, 0, floatHeight ), putBackTime, ( putBackTime * 0.5 ) );
	wait( putBackTime );

	if(isdefined(self))
	{
		self Delete();
	}
}

treasure_chest_glowfx()
{
	fxObj = spawn( "script_model", self.origin +( 0, 0, 0 ) );
	fxobj setmodel( "tag_origin" );
	fxobj.angles = self.angles +( 90, 0, 0 );

	playfxontag( level._effect["chest_light"], fxObj, "tag_origin"  );

	self waittill_any( "weapon_grabbed", "box_moving" );

	fxobj delete();
}

// self is the player string comes from the randomization function
treasure_chest_give_weapon( weapon_string )
{
	self.last_box_weapon = GetTime();
	primaryWeapons = self GetWeaponsListPrimaries();
	current_weapon = undefined;
	weapon_limit = 2;

	if( self has_weapon_or_upgrade( weapon_string ) )
	{
		if ( issubstr( weapon_string, "knife_ballistic_" ) )
		{
			self notify( "zmb_lost_knife" );
		}
		self give_max_ammo(weapon_string);
		self SwitchToWeapon( weapon_string );
		return;
	}

 	if ( self HasPerk( "specialty_additionalprimaryweapon" ) )
 	{
 		weapon_limit = 3;
 	}

	// This should never be true for the first time.
	if( primaryWeapons.size >= weapon_limit )
	{
		current_weapon = self getCurrentWeapon(); // get his current weapon

		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !is_offhand_weapon( weapon_string ) )
			{
				// PI_CHANGE_BEGIN
				// JMA - player dropped the tesla gun
				if( current_weapon == "tesla_gun_zm" )
				{
					level.player_drops_tesla_gun = true;
				}
				// PI_CHANGE_END

				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}

				self TakeWeapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
				if ( current_weapon == "m1911_zm" )
				{
					self.last_pistol_swap = GetTime();
				}

			}
		}
	}

	self play_sound_on_ent( "purchase" );

	if( IsDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon_string );
	}

	modelIndex = 0;
	if( weapon_string == "zombie_cymbal_monkey" )
	{
		if( IsDefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( "zombie_cymbal_monkey" ) )
		{
			self SetWeaponAmmoClip( self get_player_tactical_grenade(), 0 );
			self TakeWeapon( self get_player_tactical_grenade() );
		}
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo(weapon_string);
		return;
	}
	else if( weapon_string == "molotov_zm" )
	{
		if( IsDefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( "molotov_zm" ) )
		{
			self SetWeaponAmmoClip( self get_player_tactical_grenade(), 0 );
			self TakeWeapon( self get_player_tactical_grenade() );
		}
		self giveweapon( "molotov_zm" );
		self set_player_tactical_grenade( "molotov_zm" );
		self play_weapon_vo(weapon_string);
		return;
	}
	else if ( weapon_string == "knife_ballistic_zm" && self HasWeapon( "bowie_knife_zm" ) )
	{
		//weapon_string = "knife_ballistic_bowie_zm";
		modelIndex = 1;
	}
	else if ( weapon_string == "knife_ballistic_zm" && self HasWeapon( "sickle_knife_zm" ) )
	{
		//weapon_string = "knife_ballistic_sickle_zm";
		modelIndex = 2;
	}

	if (weapon_string == "tesla_gun_zm" || weapon_string == "thundergun_zm" || weapon_string == "freezegun_zm" || weapon_string == "sniper_explosive_zm" || weapon_string == "humangun_zm" || weapon_string == "shrink_ray_zm" || weapon_string == "microwavegundw_zm")
	{
		playsoundatposition("mus_wonder_weapon_stinger", (0,0,0));
	}

	self GiveWeapon( weapon_string, modelIndex );
	self maps\_zombiemode::handle_player_packapunch(weapon_string, false);
	self give_max_ammo(weapon_string, 1);
	self SwitchToWeapon( weapon_string );

	self play_weapon_vo(weapon_string);
}


pay_turret_think( cost )
{
	if( !isDefined( self.target ) )
	{
		return;
	}
	turret = GetEnt( self.target, "targetname" );

	if( !isDefined( turret ) )
	{
		return;
	}

	turret makeTurretUnusable();

	// figure out what zone it's in
	zone_name = turret get_current_zone();
	if ( !IsDefined( zone_name ) )
	{
		zone_name = "";
	}

	while( true )
	{
		self waittill( "trigger", player );

		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( player in_revive_trigger() )
		{
			wait( 0.1 );
			continue;
		}

		if( player is_drinking() )
		{
			wait(0.1);
			continue;
		}

		if( player.score >= cost )
		{
			player maps\_zombiemode_score::minus_to_player_score( cost );
			bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type turret", player.playername, player.score, level.team_pool[ player.team_num ].score, level.round_number, cost, zone_name, self.origin );
			turret makeTurretUsable();
			turret UseBy( player );
			self disable_trigger();

			player maps\_zombiemode_audio::create_and_play_dialog( "weapon_pickup", "mg" );

			player.curr_pay_turret = turret;

			turret thread watch_for_laststand( player );
			turret thread watch_for_fake_death( player );
			if( isDefined( level.turret_timer ) )
			{
				turret thread watch_for_timeout( player, level.turret_timer );
			}

			while( isDefined( turret getTurretOwner() ) && turret getTurretOwner() == player )
			{
				wait( 0.05 );
			}

			turret notify( "stop watching" );

			player.curr_pay_turret = undefined;

			turret makeTurretUnusable();
			self enable_trigger();
		}
		else // not enough money
		{
			play_sound_on_ent( "no_purchase" );
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 0 );
		}
	}
}

watch_for_laststand( player )
{
	self endon( "stop watching" );

	while( !player maps\_laststand::player_is_in_laststand() )
	{
		if( isDefined( level.intermission ) && level.intermission )
		{
			intermission = true;
		}
		wait( 0.05 );
	}

	if( isDefined( self getTurretOwner() ) && self getTurretOwner() == player )
	{
		self UseBy( player );
	}
}

watch_for_fake_death( player )
{
	self endon( "stop watching" );

	player waittill( "fake_death" );

	if( isDefined( self getTurretOwner() ) && self getTurretOwner() == player )
	{
		self UseBy( player );
	}
}

watch_for_timeout( player, time )
{
	self endon( "stop watching" );

	self thread cancel_timer_on_end( player );

//	player thread maps\_zombiemode_timer::start_timer( time, "stop watching" );

	wait( time );

	if( isDefined( self getTurretOwner() ) && self getTurretOwner() == player )
	{
		self UseBy( player );
	}
}

cancel_timer_on_end( player )
{
	self waittill( "stop watching" );
	player notify( "stop watching" );
}

weapon_cabinet_door_open( left_or_right )
{
	if( left_or_right == "left" )
	{
		self rotateyaw( 120, 0.3, 0.2, 0.1 );
	}
	else if( left_or_right == "right" )
	{
		self rotateyaw( -120, 0.3, 0.2, 0.1 );
	}
}

check_collector_achievement( bought_weapon )
{
	if ( !isdefined( self.bought_weapons ) )
	{
		self.bought_weapons = [];
		self.bought_weapons = array_add( self.bought_weapons, bought_weapon );
	}
	else if ( !is_in_array( self.bought_weapons, bought_weapon ) )
	{
		self.bought_weapons = array_add( self.bought_weapons, bought_weapon );
	}
	else
	{
		// don't bother checking, they've bought it before
		return;
	}

	for( i = 0; i < level.collector_achievement_weapons.size; i++ )
	{
		if ( !is_in_array( self.bought_weapons, level.collector_achievement_weapons[i] ) )
		{
			return;
		}
	}

	self giveachievement_wrapper( "SP_ZOM_COLLECTOR" );
}

weapon_set_first_time_hint( cost, ammo_cost )
{
	if ( isDefined( level.has_pack_a_punch ) && !level.has_pack_a_punch )
	{
		self SetHintString( &"REIMAGINED_WEAPONCOSTAMMO", cost, ammo_cost );
		//self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost );
	}
	else
	{
		if(IsDefined(self.hacked) && self.hacked)
		{
			self SetHintString( &"REIMAGINED_WEAPONCOSTAMMO_UPGRADE_HACKED", cost, ammo_cost, ammo_cost );
		}
		else
		{
			self SetHintString(&"REIMAGINED_WEAPONCOSTAMMO_UPGRADE", cost, ammo_cost );
		}
		//self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO_UPGRADE", cost, ammo_cost );
	}
}

weapon_spawn_think()
{
	cost = 5000;
	ammo_cost = 4500;
	weapon_name = self.zombie_weapon_upgrade;
	if( IsDefined( level.zombie_weapons[weapon_name] ) )
	{
		cost = get_weapon_cost( weapon_name );
		ammo_cost = get_ammo_cost( weapon_name );
	}

	
	is_grenade = (WeaponType( self.zombie_weapon_upgrade ) == "grenade");

	if(level.gamemode == "gg" && !is_grenade)
	{
		self disable_trigger();
		return;
	}

	self thread decide_hide_show_hint();

	self.first_time_triggered = false;
	for( ;; )
	{
		self waittill( "trigger", player );
		// if not first time and they have the weapon give ammo

		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( player has_powerup_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		// Allow people to get ammo off the wall for upgraded weapons
		player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );

		if( !player_has_weapon )
		{
			// else make the weapon show and give it
			if( player.score >= cost )
			{
				primaryWeapons = player GetWeaponsListPrimaries();
				weapon_limit = 2;
				if( player HasPerk( "specialty_additionalprimaryweapon" ) )
			 	{
			 		weapon_limit = 3;
			 	}

				if( ( is_melee_weapon(player GetCurrentWeapon()) || is_placeable_mine(player GetCurrentWeapon()) ) && IsDefined(primaryWeapons) && primaryWeapons.size >= weapon_limit && !is_grenade )
				{
					if(IsDefined(player.last_held_primary_weapon) && player HasWeapon(player.last_held_primary_weapon))
					{
						player SwitchToWeapon(player.last_held_primary_weapon);
					}
					else
					{
						player SwitchToWeapon(primaryWeapons[0]);
					}
					continue;
				}

				if( self.first_time_triggered == false )
				{
					if(IsDefined(self.override_weapon_model))
					{
						model = self.override_weapon_model;
					}
					else
					{
						model = getent( self.target, "targetname" );
					}
					//model show();
					model thread weapon_show( player );
					self.first_time_triggered = true;

					if(!is_grenade)
					{
						self weapon_set_first_time_hint( cost, ammo_cost );
					}
				}

				player maps\_zombiemode_score::minus_to_player_score( cost );

				bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type weapon",
						player.playername, player.score, level.team_pool[ player.team_num ].score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin );

				if ( is_lethal_grenade( self.zombie_weapon_upgrade ) )
				{
					player takeweapon( player get_player_lethal_grenade() );
					player set_player_lethal_grenade( self.zombie_weapon_upgrade );
				}

				if(IsDefined(self.hacked) && self.hacked)
				{
					player weapon_give(level.zombie_weapons[self.zombie_weapon_upgrade].upgrade_name);
				}
				else
				{
					player weapon_give( self.zombie_weapon_upgrade );
				}

				player check_collector_achievement( self.zombie_weapon_upgrade );
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 1 );

			}
		}
		else
		{
			// MM - need to check and see if the player has an upgraded weapon.  If so, the ammo cost is much higher
			if(IsDefined(self.hacked) && self.hacked)	// hacked wall buys have their costs reversed...
			{
				/*if ( !player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_cost = 2500;
				}
				else
				{
					ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
				}*/
				ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
			}
			else
			{
				if ( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_cost = 4500;
				}
				else
				{
					ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
				}
			}
			// if the player does have this then give him ammo.
			if( player.score >= ammo_cost )
			{
				if( self.first_time_triggered == false )
				{
					if(IsDefined(self.override_weapon_model))
					{
						model = self.override_weapon_model;
					}
					else
					{
						model = getent( self.target, "targetname" );
					}
					//model show();
					model thread weapon_show( player );
					self.first_time_triggered = true;
					if(!is_grenade)
					{
						self weapon_set_first_time_hint( cost, get_ammo_cost( self.zombie_weapon_upgrade ) );
					}
				}

				player check_collector_achievement( self.zombie_weapon_upgrade );

//				MM - I don't think this is necessary
// 				if( player HasWeapon( self.zombie_weapon_upgrade ) && player has_upgrade( self.zombie_weapon_upgrade ) )
// 				{
// 					ammo_given = player ammo_give( self.zombie_weapon_upgrade, true );
// 				}
//				else
				if( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_given = player ammo_give( level.zombie_weapons[ self.zombie_weapon_upgrade ].upgrade_name );
				}
				else
				{
					ammo_given = player ammo_give( self.zombie_weapon_upgrade );
				}

				if( ammo_given )
				{
						player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early

					bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type ammo",
						player.playername, player.score, level.team_pool[ player.team_num ].score, level.round_number, ammo_cost, self.zombie_weapon_upgrade, self.origin );
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 0 );
			}
		}
	}
}

weapon_show( player )
{
	player_angles = VectorToAngles( player.origin - self.origin );

	player_yaw = player_angles[1];
	weapon_yaw = self.angles[1];

	if ( isdefined( self.script_int ) )
	{
		weapon_yaw -= self.script_int;
	}

	yaw_diff = AngleClamp180( player_yaw - weapon_yaw );

	if( yaw_diff > 0 )
	{
		yaw = weapon_yaw - 90;
	}
	else
	{
		yaw = weapon_yaw + 90;
	}

	self.og_origin = self.origin;
	self.origin = self.origin +( AnglesToForward( ( 0, yaw, 0 ) ) * 8 );

	wait( 0.05 );
	self Show();

	play_sound_at_pos( "weapon_show", self.origin, self );

	time = 1;
	self MoveTo( self.og_origin, time );
}

get_pack_a_punch_weapon_options( weapon )
{
	if ( !isDefined( self.pack_a_punch_weapon_options ) )
	{
		self.pack_a_punch_weapon_options = [];
	}

	if ( !is_weapon_upgraded( weapon ) )
	{
		return self CalcWeaponOptions( 0 );
	}

	if ( isDefined( self.pack_a_punch_weapon_options[weapon] ) )
	{
		return self.pack_a_punch_weapon_options[weapon];
	}

	smiley_face_reticle_index = 21; // smiley face is reserved for the upgraded famas, keep it at the end of the list

	camo_index = 15;
	lens_index = randomIntRange( 0, 6 );
	reticle_index = randomIntRange( 0, smiley_face_reticle_index );
	reticle_color_index = randomIntRange( 0, 6 );

	if ( "famas_upgraded_zm" == weapon )
	{
		reticle_index = smiley_face_reticle_index;
	}

/*
/#
	if ( GetDvarInt( #"scr_force_reticle_index" ) )
	{
		reticle_index = GetDvarInt( #"scr_force_reticle_index" );
	}
#/
*/

	scary_eyes_reticle_index = 8; // weapon_reticle_zom_eyes
	purple_reticle_color_index = 3; // 175 0 255
	if ( reticle_index == scary_eyes_reticle_index )
	{
		reticle_color_index = purple_reticle_color_index;
	}
	letter_a_reticle_index = 2; // weapon_reticle_zom_a
	pink_reticle_color_index = 6; // 255 105 180
	if ( reticle_index == letter_a_reticle_index )
	{
		reticle_color_index = pink_reticle_color_index;
	}
	letter_e_reticle_index = 7; // weapon_reticle_zom_e
	green_reticle_color_index = 1; // 0 255 0
	if ( reticle_index == letter_e_reticle_index )
	{
		reticle_color_index = green_reticle_color_index;
	}

	self.pack_a_punch_weapon_options[weapon] = self CalcWeaponOptions( camo_index, lens_index, reticle_index, reticle_color_index );
	return self.pack_a_punch_weapon_options[weapon];
}

weapon_give( weapon, weapon_unupgraded )
{
	primaryWeapons = self GetWeaponsListPrimaries();
	current_weapon = undefined;
	weapon_limit = 2;

	//if is not an upgraded perk purchase
	/*if( !IsDefined( is_upgrade ) )
	{
		is_upgrade = false;
	}*/

	//just give ammo if player has weapon or unupgraded or upgraded version of weapon
	//if weapon is upgraded, then weapon_unupgraded is defined
	if(IsDefined(weapon_unupgraded))
	{
		if(self HasWeapon(weapon_unupgraded))
		{
			self give_max_ammo(weapon_unupgraded);
			return;
		}
		else if(self HasWeapon(level.zombie_weapons[weapon_unupgraded].upgrade_name))
		{
			self give_max_ammo(level.zombie_weapons[weapon_unupgraded].upgrade_name);
			return;
		}
	}
	else
	{
		if(self HasWeapon(weapon))
		{
			self give_max_ammo(weapon);
			return;
		}
		else if(IsDefined(level.zombie_weapons[weapon]) && IsDefined(level.zombie_weapons[weapon].upgrade_name) && self HasWeapon(level.zombie_weapons[weapon].upgrade_name))
		{
			self give_max_ammo(level.zombie_weapons[weapon].upgrade_name);
			return;
		}
	}

 	if ( self HasPerk( "specialty_additionalprimaryweapon" ) )
 	{
 		weapon_limit = 3;
 	}

	// This should never be true for the first time.
	if( primaryWeapons.size >= weapon_limit )
	{
		current_weapon = self getCurrentWeapon(); // get his current weapon

		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !is_offhand_weapon( weapon ) )
			{
				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}
				self TakeWeapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
				if ( current_weapon == "m1911_zm" )
				{
					self.last_pistol_swap = GetTime();
				}
			}
		}
	}

	if( IsDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
		{
			return;
		}
	}

	if( weapon == "zombie_cymbal_monkey" )
	{
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo( weapon );
		return;
	}

	self play_sound_on_ent( "purchase" );

	if ( !is_weapon_upgraded( weapon ) )
	{
		self GiveWeapon( weapon );
	}
	else
	{
		self GiveWeapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	}

	acquire_weapon_toggle( weapon, self );
	self give_max_ammo(weapon, 1);
	self SwitchToWeapon( weapon );

	self play_weapon_vo(weapon);

	// fix for grenade ammo
	if(is_lethal_grenade(weapon) || is_tactical_grenade(weapon))
	{
		ammo = 0;
		if(is_lethal_grenade(weapon))
		{
			ammo = 4;
		}
		else if(is_tactical_grenade(weapon))
		{
			ammo = 3;
		}

		/*if(self HasPerk("specialty_stockpile"))
		{
			ammo += 1;
		}*/

		self SetWeaponAmmoClip(weapon, ammo);
	}
}

play_weapon_vo(weapon)
{
	//Added this in for special instances of New characters with differing favorite weapons
	if ( isDefined( level._audio_custom_weapon_check ) )
	{
		type = self [[ level._audio_custom_weapon_check ]]( weapon );
	}
	else
	{
	    type = self weapon_type_check(weapon);
	}

	self maps\_zombiemode_audio::create_and_play_dialog( "weapon_pickup", type );
}

weapon_type_check(weapon)
{
    if( !IsDefined( self.entity_num ) )
        return "crappy";

    if(level.script != "zombie_cod5_prototype" && level.script != "zombie_cod5_asylum")
    {
    	switch(self.entity_num)
	    {
	        case 0:   //DEMPSEY'S FAVORITE WEAPON: M16 UPGRADED: ROTTWEIL72
	            if( weapon == "m16_zm" )
	                return "favorite";
	            else if( weapon == "rottweil72_upgraded_zm" )
	                return "favorite_upgrade";
	            break;

	        case 1:   //NIKOLAI'S FAVORITE WEAPON: FNFAL UPGRADED: HK21
	            if( weapon == "fnfal_zm" )
	                return "favorite";
	            else if( weapon == "hk21_upgraded_zm" )
	                return "favorite_upgrade";
	            break;

	        case 2:   //TAKEO'S FAVORITE WEAPON: M202 UPGRADED: THUNDERGUN
	            if( weapon == "china_lake_zm" )
	                return "favorite";
	            else if( weapon == "thundergun_upgraded_zm" )
	                return "favorite_upgrade";
	            break;

	        case 3:   //RICHTOFEN'S FAVORITE WEAPON: MP40 UPGRADED: CROSSBOW
	            if( weapon == "mp40_zm" )
	                return "favorite";
	            else if( weapon == "crossbow_explosive_upgraded_zm" )
	                return "favorite_upgrade";
	            break;
	    }
    }

    if( IsSubStr( weapon, "upgraded" ) )
        return "upgrade";
    else
        return level.zombie_weapons[weapon].vox;
}


get_player_index(player)
{
	assert( IsPlayer( player ) );
	assert( IsDefined( player.entity_num ) );
/#
	// used for testing to switch player's VO in-game from devgui
	if( player.entity_num == 0 && GetDvar( #"zombie_player_vo_overwrite" ) != "" )
	{
		new_vo_index = GetDvarInt( #"zombie_player_vo_overwrite" );
		return new_vo_index;
	}
#/
	return player.entity_num;
}

ammo_give( weapon )
{
	// We assume before calling this function we already checked to see if the player has this weapon...

	// Should we give ammo to the player
	give_ammo = false;
	max_ammo = WeaponMaxAmmo(weapon);
	ammo_count = self GetWeaponAmmoStock( weapon );
	dual_wield_weapon = WeaponDualWieldWeaponName( weapon );
	alt_weapon = WeaponAltWeaponName(weapon);

	if(!is_offhand_weapon(weapon))
	{
		if(self HasPerk("specialty_stockpile"))
		{
			max_ammo += WeaponClipSize(weapon);
		}
	}

	if(dual_wield_weapon != "none")
	{
		if(self HasPerk("specialty_stockpile"))
		{
			max_ammo += WeaponClipSize(dual_wield_weapon);
		}
	}

	// compare it with the ammo player actually has, if more or equal just dont give the ammo, else do
	if(ammo_count < max_ammo)
	{
		give_ammo = true;
	}

	if(!give_ammo && alt_weapon != "none")
	{
		max_alt_ammo = WeaponMaxAmmo(alt_weapon);
		if(self HasPerk("specialty_stockpile"))
		{
			max_alt_ammo += WeaponClipSize(alt_weapon);
		}

		if( self GetWeaponAmmoStock( alt_weapon ) < max_alt_ammo )
		{
			give_ammo = true;
		}
	}

	// Check to see if ammo belongs to a primary weapon
	/*if( !is_offhand_weapon( weapon ) )
	{
		if( isdefined( weapon ) )
		{
			// get the max allowed ammo on the current weapon
			//stockMax = 0;	// scope declaration
			//stockMax = WeaponStartAmmo( weapon );

			// Get the current weapon clip count
			//clipCount = self GetWeaponAmmoClip( weapon );

			//currStock = self GetAmmoCount( weapon );

			max_ammo = WeaponMaxAmmo(weapon);
			if(!is_offhand_weapon(weapon))
			{
				max_ammo += WeaponClipSize(weapon);
			}

			// compare it with the ammo player actually has, if more or equal just dont give the ammo, else do
			if( self getammocount( weapon ) < max_ammo )
			{
				give_ammo = true;
			}
		}
	}
	else
	{
		// Ammo belongs to secondary weapon
		if( self has_weapon_or_upgrade( weapon ) )
		{
			// Check if the player has less than max stock, if no give ammo
			if( self getammocount( weapon ) < WeaponMaxAmmo( weapon ) )
			{
				// give the ammo to the player
				give_ammo = true;
			}
		}
	}*/

	if(give_ammo)
	{
		self play_sound_on_ent( "purchase" );

		self give_max_ammo(weapon);

		if(alt_weapon != "none")
		{
			self give_max_ammo(alt_weapon);
		}

		// fix for grenade ammo
		if(is_lethal_grenade(weapon) || is_tactical_grenade(weapon))
		{
			ammo = 0;
			if(is_lethal_grenade(weapon))
			{
				ammo = 4;
			}
			else if(is_tactical_grenade(weapon))
			{
				ammo = 3;
			}

			/*if(self HasPerk("specialty_stockpile"))
			{
				ammo += 1;
			}*/

			self SetWeaponAmmoClip(weapon, ammo);
		}

		return true;
	}
	return false;
}

//include new weapons
init_includes()
{

	//Pistols
	//include_weapon("cz75dw_upgraded_zm_x2");
	//include_weapon("cz75lh_upgraded_zm_x2");
	
	include_weapon("asp_zm");				
	include_weapon("asp_upgraded_zm", false);		
	include_weapon("asp_upgraded_zm_x2", false);

	include_weapon("makarov_zm");
	include_weapon("makarov_upgraded_zm", false);

	//SMGS
	include_weapon("ppsh_zm");
	include_weapon("ppsh_upgraded_zm", false);
	include_weapon("ppsh_upgraded_zm_x2", false);
	include_weapon("spectre_upgraded_zm_x2", false);
	

	include_weapon("uzi_zm");				
	include_weapon("uzi_upgraded_zm", false);
	
	//include_weapon("mac11_zm");
	//include_weapon("mac11_upgraded_zm");
	//include_weapon("kiparis_zm");
	//include_weapon("kiparis_upgraded_zm");
	
	//Shotguns
	//include_weapon("hs10_upgraded_zm_x2");
	include_weapon("ks23_zm");
	include_weapon("ks23_upgraded_zm", false);

	//ARs
	include_weapon("galil_upgraded_zm_x2", false);
	include_weapon("commando_upgraded_zm_x2", false);
	include_weapon("ak47_zm");
	include_weapon("ak47_ft_upgraded_zm", false);
	include_weapon("ft_ak47_upgraded_zm", false);

	include_weapon("enfield_zm");
	include_weapon("enfield_upgraded_zm", false);
	

	//Mgs
	include_weapon("rpk_upgraded_zm_x2", false);
	include_weapon("hk21_upgraded_zm_x2", false);
	include_weapon("stoner63_zm");
	include_weapon("stoner63_upgraded_zm", false);

	include_weapon("m60_zm");
	include_weapon("m60_upgraded_zm", false);

	//Snipers
	include_weapon("psg1_zm");
	include_weapon("psg1_upgraded_zm", false);
	//include_weapon("dragunov_upgraded_zm_x2", false);

	//Specials
	//include_weapon( "crossbow_explosive_upgraded_zm_x2", false );
	include_weapon( "bo3_zm_widows_grenade", true );		//in box, only availible with WWn pro

	include_weapon( "sabertooth_zm" );
	include_weapon( "sabertooth_upgraded_zm", false );
	

	//New weapons
	//{{WEAPON_INCLUDE}}


	/* Only include for WaW zombies */
 	if(IsDefined(level.script) && IsSubStr(level.script, "zombie_cod5"))
 	{
 		include_weapon("molotov_zm");
 		register_tactical_grenade_for_level( "molotov_zm" );
 	}
	/* Only include for BO zombies */
	else 
	{
		include_weapon("ithaca_zm", false);
	}

	//include_weapon("knife_zm", false); //in _zombimeode_utility.gsc
	//register_melee_weapon_for_level( "knife_zm" );

	include_weapon( "vorkuta_knife_sp", false);
	register_melee_weapon_for_level( "vorkuta_knife_sp" );

	include_weapon( "rebirth_hands_sp", false);
	register_melee_weapon_for_level( "rebirth_hands_sp" );
	
 	include_weapon("combat_knife_zm", false);
 	register_melee_weapon_for_level( "combat_knife_zm" );

 	if(level.script == "zombie_cod5_factory" || level.script == "zombie_theater" || level.script == "zombie_pentagon" || level.script == "zombie_temple" || level.script == "zombie_moon")
 	{
 		//include_weapon("combat_bowie_knife_zm", false);
 		//register_melee_weapon_for_level( "combat_bowie_knife_zm" );
 	}
 	else if(level.script == "zombie_cosmodrome" || level.script == "zombie_coast")
 	{
 		//include_weapon("combat_sickle_knife_zm", false);
 		//register_melee_weapon_for_level( "combat_sickle_knife_zm" );
 	}
}

// if the player throws an entity to an unplayable area samantha steals it
entity_stolen_by_sam( ent_grenade, ent_model )
{
	if( !IsDefined( ent_model ) )
	{
		return;
	}

	ent_model UnLink();

	direction = ent_model.origin;
	direction = (direction[1], direction[0], 0);

	if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
	{
		direction = (direction[0], direction[1] * -1, 0);
	}
	else if(direction[0] < 0)
	{
		direction = (direction[0] * -1, direction[1], 0);
	}

	if( is_true( level.player_4_vox_override ) )
	{
		ent_model playsound( "zmb_laugh_rich" );
	}
	else
	{
		ent_model playsound( "zmb_laugh_child" );
	}

	// play the fx on the model
	PlayFXOnTag( level._effect["ent_stolen"], ent_model, "tag_origin" );

	// raise the model
	ent_model MoveZ( 60, 1.0, 0.25, 0.25 );

	// spin it
	ent_model Vibrate( direction, 1.5,  2.5, 1.0 );

	ent_model waittill( "movedone" );

	// delete it
	ent_model Delete();
	if( IsDefined(ent_grenade) )
	{
		ent_grenade Delete();
	}
}

get_upgraded_weapon_model_index(weapon)
{
	//HERE
	//if weapon is ballistic knife, return knife index
	if( IsSubStr(weapon, "knife_ballistic") )
	{
		return self.knife_index;
	}

	if(IsSubStr(level.script, "zombie_cod5_"))
	{
		if(weapon == "tesla_gun_upgraded_zm" || weapon == "mp40_upgraded_zm")
		{
			return 1;
		}
	}

	return 0;
}

place_treasure_chest(script_noteworthy, origin, angles, start_exclude)
{
	if(!IsDefined(level.treasure_box_bottom))
	{
		level.treasure_box_bottom = true;
	}

	if(!IsDefined(start_exclude))
	{
		start_exclude = false;
	}

	forward = AnglesToForward(angles);
	right = AnglesToRight(angles);
	up = AnglesToUp(angles);

	if(IsDefined(level.treasure_box_use_alternate_clip))
	{
		clip1 = Spawn( "script_model", origin + (forward * 26) + (up * 64) );
		clip1.angles = angles;
		clip1 SetModel( "collision_geo_32x32x128" );
		clip1 Hide();

		clip2 = Spawn( "script_model", origin + (up * 64) );
		clip2.angles = angles;
		clip2 SetModel( "collision_geo_32x32x128" );
		clip2 Hide();

		clip4 = Spawn( "script_model", origin + (forward * -26) + (up * 64) );
		clip4.angles = angles;
		clip4 SetModel( "collision_geo_32x32x128" );
		clip4 Hide();
	}
	else
	{
		clip1 = Spawn( "script_model", origin + (forward * 16) + (right * 16) );
		clip1.angles = angles;
		clip1 SetModel( "collision_geo_64x64x64" );
		clip1 Hide();

		clip2 = Spawn( "script_model", origin + (forward * -16) + (right * 16) );
		clip2.angles = angles;
		clip2 SetModel( "collision_geo_64x64x64" );
		clip2 Hide();
	}

	if(IsDefined(level.override_place_treasure_chest_bottom))
	{
		up_amount = [[level.override_place_treasure_chest_bottom]](origin, angles);
		
		if(IsDefined(up_amount))
		{
			origin = origin + (up * up_amount);
		}
	}

	trig_origin = origin + (up * 32);
	if(IsDefined(level.treasure_box_use_alternate_trigger))
	{
		trig_origin = origin + (up * 32) + (right * -18.5);
	}
	
	trigger = Spawn( "trigger_radius_use", trig_origin, 0, 20, 70 );
	trigger.angles = angles;
	id = trigger GetEntityNumber();
	trigger.script_noteworthy = script_noteworthy;
	trigger.targetname = "treasure_chest_use";
	trigger.target = "magic_box_lid_" + id;
	trigger.zombie_cost = 950;
	trigger.start_exclude = start_exclude;

	chest_lid = Spawn( "script_model", origin + (right * 12) + (up * 15.1));
	chest_lid.angles = angles;
	chest_lid SetModel( "zombie_treasure_box_lid" );
	chest_lid.targetname = trigger.target;
	chest_lid.target = "magic_box_weapon_spawn_" + id;

	chest_origin = Spawn( "script_model", origin );
	chest_origin.angles = angles + (0, 90, 0); // need to add 90 degrees for weapons to float up with correct angles
	chest_origin.targetname = chest_lid.target;
	chest_origin.target = "magic_box_base_" + id;

	chest_box = Spawn( "script_model", origin + (up * -3));
	chest_box.angles = angles;
	chest_box SetModel( "zombie_treasure_box" );
	chest_box.targetname = chest_origin.target;

	rubble = Spawn( "script_model", origin );
	if(IsDefined(level.treasure_box_rubble_use_alternate_origin))
	{
		rubble.origin = rubble.origin + (up * -2);
		rubble.angles = angles;
	}
	else
	{
		rubble.origin = rubble.origin + (forward * 18) + (right * 6) + (up * 2.5);
		rubble.angles = angles + (0, 135, 0);
	}
	if(IsDefined(level.treasure_box_rubble_model))
	{
		rubble SetModel( level.treasure_box_rubble_model );
	}
	else
	{
		rubble SetModel( "zombie_coast_bearpile" );
	}
	rubble.script_noteworthy = trigger.script_noteworthy + "_rubble";
	rubble.targetname = "intercom"; // for fire sale sound
}

give_max_ammo(weapon, give_start_ammo)
{
	if(!IsDefined(give_start_ammo))
	{
		give_start_ammo = 0;
	}

	dual_wield_weapon = WeaponDualWieldWeaponName(weapon);
	alt_weapon = WeaponAltWeaponName(weapon);

	max_ammo = WeaponMaxAmmo(weapon) + WeaponClipSize(weapon);
	ammo_to_remove = WeaponClipSize(weapon) - self GetWeaponAmmoClip(weapon);
	if(dual_wield_weapon != "none")
	{
		max_ammo += WeaponClipSize(dual_wield_weapon);
		ammo_to_remove += WeaponClipSize(dual_wield_weapon) - self GetWeaponAmmoClip(dual_wield_weapon);
	}

	alt_max_ammo = 0;
	alt_ammo_to_remove = 0;
	if(alt_weapon != "none")
	{
		alt_max_ammo = WeaponMaxAmmo(alt_weapon) + WeaponClipSize(alt_weapon);
		alt_ammo_to_remove = WeaponClipSize(alt_weapon) - self GetWeaponAmmoClip(alt_weapon);
	}

	if(give_start_ammo)
	{
		self GiveStartAmmo(weapon);
	}
	else
	{
		self GiveMaxAmmo(weapon);
	}

	// upgraded zap gun - remove 4 ammo from stock so stock ammo is divisible by clip size
	// had to be done from here since weaponfile for zap gun isn't in raw
	if(weapon == "microwavegundw_upgraded_zm")
	{
		max_ammo -= 4;
		self SetWeaponAmmoStock(weapon, self GetWeaponAmmoStock(weapon) - 4);
	}

	// specialty_stockpile - give weapons 1 extra stock clip
	if(self HasPerk("specialty_stockpile"))
	{
		if(give_start_ammo)
		{
			// add 1 stock clip (GiveStartAmmo always gives normal stock ammo)
			self SetWeaponAmmoStock(weapon, max_ammo - ammo_to_remove);

			if(alt_weapon != "none")
			{
				self SetWeaponAmmoStock(alt_weapon, alt_max_ammo - alt_ammo_to_remove);
			}
		}
		else
		{
			// remove 1 stock clip (GiveMaxAmmo adds 2 stock clips if player has perk "specialty_stockpile")
			self SetWeaponAmmoStock(weapon, self GetWeaponAmmoStock(weapon) - WeaponClipSize(weapon));
		}
	}
	else if(give_start_ammo && dual_wield_weapon != "none")
	{
		// on dual wield weapons, ammo from stock isn't removed when filling clips from GiveStartAmmo
		self SetWeaponAmmoStock(weapon, self GetWeaponAmmoStock(weapon) - ammo_to_remove);
	}
}