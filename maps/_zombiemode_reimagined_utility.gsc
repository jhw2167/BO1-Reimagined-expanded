#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;


/*
	###############################
	HINT STRING GENERATOR
    ###############################
*/

generate_hint_title( hint_title, hint_text, time )
{
	if( !isdefined( time ) )
		time = 4;
    //Title
    title = NewClientHudElem( self );
	title.alignX = "center";
	title.alignY = "middle";
	title.horzAlign = "user_center";
	title.vertAlign = "user_top";
	title.foreground = true;
	title.font = "big";
	title.fontScale = 3.2;
	title.alpha = 0;
	title.color = (0.5, 0.0, 0.0);
	title SetText( hint_text );

    title.y += 100;

	title FadeOverTime( 1 );
	title.alpha = 1;

    wait(time);
    title FadeOverTime( 2 );
	title.alpha = 0;

	wait(2);

	title destroy_hud();
}

generate_hint( hint_code, hint_text, offset, wait_time )
{
    self endon( "death" );
	self endon( "disconnect" );

    if( isdefined( offset ) )
        y_offset = offset;
    else
        y_offset = 0;

	if( !isdefined( wait_time ) )
		wait_time = 4;


    //Bullets
	text = NewClientHudElem( self );
	text.alignX = "center";
	text.alignY = "middle";
	text.horzAlign = "user_center";
	text.vertAlign = "user_top";
	text.foreground = true;
	text.font = "default";
	text.fontScale = 1.6;
	text.alpha = 0;
	text.color = ( 1.0, 1.0, 1.0 );
    if( IsDefined( hint_code ) )
		text SetText( hint_code );
    else
	    text SetText( hint_text );

	text.y += 120;
    text.y += y_offset;

	text FadeOverTime( 1 );
	text.alpha = 1;

	wait ( wait_time );
    text FadeOverTime( 1 );
	text.alpha = 0.5;

	wait 1;
	text destroy_hud();
}


/* PERK HINTS HANDLED IN _ZOMBIEMODE_FFOTD.CSC CLIENTSCRIPT */

generate_perk_hint( perkOrWeapon, specialHint )
{
    self endon( "death" );
	self endon( "disconnect" );
	
	if( GetDvarInt( "ui_hud_perk_hints") == 0 )
		return;

	if( is_true( self.superpower_active ) )
		return;

	if( !isdefined( specialHint ) )
		specialHint = false;


	if( perkOrWeapon == "rottweil72_upgraded_zm" )
	{
		perkOrWeapon = "specialty_pap_hellfire_onhit";
	}
	else if( perkOrWeapon == "dragunov_upgraded_zm_x2" ) 
	{
		perkOrWeapon = "specialty_pap_hellfire_onhit";
	}
	else if( perkOrWeapon == "spas_upgraded_zm_x2" ) {
		//nothing
	}
	else if( perkOrWeapon == "spectre_upgraded_zm_x2" ) {
		//nothing
	}
	else if( perkOrWeapon == "famas_upgraded_zm_x2" ) {
		//nothing
	}
	else if( perkOrWeapon == "uzi_upgraded_zm_x2" ) {
		//nothing
	}
	else if( perkOrWeapon == "mac11_upgraded_zm_x2" ) {
		//nothing
	}
	else if( perkOrWeapon == "ks23_upgraded_zm_x2" ) {
		//nothing
	}
	else if( is_in_array(level.ARRAY_HELLFIRE_WEAPONS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_pap_hellfire";
	}
	else if( is_in_array(level.ARRAY_SHEERCOLD_WEAPONS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_pap_sheer_cold";
	}
	else if( is_in_array(level.ARRAY_ELECTRIC_WEAPONS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_pap_shock_rounds";
	}
	else if( is_in_array(level.ARRAY_EXECUTE_WEAPONS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_pap_execute";
	}
	else if( is_in_array(level.ARRAY_BIGDMG_WEAPONS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_pap_big_damage";
	}
	else if( is_in_array(level.ARRAY_BIGHEADSHOTDMG_WEAPONS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_pap_big_headshot_damage";
	}
	else if( is_in_array(level.ARRAY_VALID_SHOTGUNS, perkOrWeapon))
	{
		perkOrWeapon = "specialty_shotgun_damage";
	}
	else if( is_in_array( level.ARRAY_VALID_SNIPERS, perkOrWeapon) )
	{
		//perkOrWeapon = "specialty_sniper_damage"; //Not necessary
	}
	//level.ARRAY_SIDEARMBONUS_WEAPONS
	else if( is_in_array(level.ARRAY_SIDEARMBONUS_WEAPONS, perkOrWeapon) )
	{
		perkOrWeapon = "specialty_sidearm_bonus";
	}
	else if( perkOrWeapon == "combat_knife_zm" || perkOrWeapon == "vorkuta_knife_sp" )
	{
		perkOrWeapon = "specialty_offhand_melee";
	}


	//iprintln( "check activated: " + perkOrWeapon );
	hintCode = perkOrWeapon;
	if( is_true( self.hints_activated[ hintCode ] ) )
		return;

	self.hints_activated[ hintCode ] = true;

	//iprintln( "notify: " + hintCode );

	while( self.new_perk_hint ) {
		self waittill( "perk_hint_end" );
	}
	self.new_perk_hint = true;

	//iprintln( "notify 2: " + hintCode );

	returnVultureVision = false;
	if( self.vulture_vison_toggle )
	{
		self.vulture_vison_toggle = false;
		returnVultureVision = true;
	}
		
	BASE_OFFSET = -100;

    //Title
    title = NewClientHudElem( self );
	title.alignX = "center";
	title.alignY = "middle";
	title.horzAlign = "user_center";
	title.vertAlign = "user_bottom";
	title.foreground = true;
	title.font = "big";
	title.fontScale = 1.6;
	title.alpha = 0;
	title.color = ( 1.0, 1.0, 1.0 );

    title.y += BASE_OFFSET;

	if( specialHint )
	{
		title.color = ( 0.5, 0, 0 );
		//title.y -= 20;
	}
		
   


    //Bullets
	text = NewClientHudElem( self );
	text.alignX = "center";
	text.alignY = "middle";
	text.horzAlign = "user_center";
	text.vertAlign = "user_bottom";
	text.foreground = true;
	text.font = "default";
	text.fontScale = 1.2;
	text.alpha = 0;
	text.color = ( 1.0, 1.0, 1.0 );

	text.y += BASE_OFFSET;
    text.y += 20;

	if( specialHint )
	{
		//text.color = ( 1.0, 0.95, 0 );
		//text.y -= 20;
	}
		
   

    /* SET APPROPRIATE HINT */
		switch( hintCode )
		{
		case "apocalypse":
		//\n- Zombies will respawn at full health if not killed quickly \n- Rounds will automatically start if you wait too long; with a break every 5 rounds \n- Damaging zombies gives less points; kills and headshots give more points \n- Points are rewarded for finishing a round quickly \n- Doors and upgrades are more expensive
			title SetText( &"REIMAGINED_APOCALYPSE_TITLE" );
			text SetText( &"REIMAGINED_APOCALYPSE_HINT" );
			break;

		case "apocalypse_rounds":
		//\n- Zombies will respawn at full health if not killed quickly \n- Rounds will automatically start if you wait too long; with a break every 5 rounds \n- Damaging zombies gives less points; kills and headshots give more points \n- Points are rewarded for finishing a round quickly \n- Doors and upgrades are more expensive
			title SetText( &"REIMAGINED_APOCALYPSE_ROUNDS_TITLE" );
			text SetText( &"REIMAGINED_APOCALYPSE_ROUNDS_HINT" );
			break;

		case "apocalypse_points":
		//\n- Zombies will respawn at full health if not killed quickly \n- Rounds will automatically start if you wait too long; with a break every 5 rounds \n- Damaging zombies gives less points; kills and headshots give more points \n- Points are rewarded for finishing a round quickly \n- Doors and upgrades are more expensive
			title SetText( &"REIMAGINED_APOCALYPSE_POINTS_TITLE" );
			text SetText( &"REIMAGINED_APOCALYPSE_POINTS_HINT" );
			break;

		case "babyjugg":
			title SetText( &"REIMAGINED_BABYJUGG_TITLE" );
			text SetText( &"REIMAGINED_BABYJUGG_HINT" );
			break;
		case "specialty_armorvest":
			if( level.apocalypse )
			{
				title SetText( &"REIMAGINED_JUG_PRK_TITLE" );
				text SetText( &"REIMAGINED_JUG_PRK_HINT" );
			}
			break;
		case "specialty_armorvest_upgrade":
			text SetText( &"REIMAGINED_JUG_PRO_HINT" );
			title SetText( &"REIMAGINED_JUG_PRO_TITLE" );
			break;

		case "specialty_quickrevive":
			text SetText( &"REIMAGINED_QRV_PRK_HINT" );
			title SetText( &"REIMAGINED_QRV_PRK_TITLE" );
			break;
			
		case "specialty_quickrevive_upgrade":
			text SetText( &"REIMAGINED_QRV_PRO_HINT" );
			title SetText( &"REIMAGINED_QRV_PRO_TITLE" );
			break;

		//case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			text SetText( &"REIMAGINED_SPD_PRO_HINT" );
			title SetText( &"REIMAGINED_SPD_PRO_TITLE" );
			break;

		case "specialty_rof":
			text SetText( &"REIMAGINED_DBT_PRK_HINT" );
			title SetText( &"REIMAGINED_DBT_PRK_TITLE" );
			break;
		case "specialty_rof_upgrade":
			text SetText( &"REIMAGINED_DBT_PRO_HINT" );
			title SetText( &"REIMAGINED_DBT_PRO_TITLE" );
			break;

		//case "specialty_endurance":
		case "specialty_endurance_upgrade":
			text SetText( &"REIMAGINED_STM_PRO_HINT" );
			title SetText( &"REIMAGINED_STM_PRO_TITLE" );
			break;

		case "specialty_flakjacket":
			text SetText( &"REIMAGINED_PHD_PRK_HINT" );
			title SetText( &"REIMAGINED_PHD_PRK_TITLE" );
		
			break;
		case "specialty_flakjacket_upgrade":
			text SetText( &"REIMAGINED_PHD_PRO_HINT" );
			title SetText( &"REIMAGINED_PHD_PRO_TITLE" );
			break;

		case "specialty_deadshot":
			text SetText( &"REIMAGINED_DST_PRK_HINT" );
			title SetText( &"REIMAGINED_DST_PRK_TITLE" );
			break;
		case "specialty_deadshot_upgrade":
			text SetText( &"REIMAGINED_DST_PRO_HINT" );
			title SetText( &"REIMAGINED_DST_PRO_TITLE" );
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		//case "specialty_additionalprimaryweapon":
			text SetText( &"REIMAGINED_MUL_PRO_HINT" );
			title SetText( &"REIMAGINED_MUL_PRO_TITLE" );
			break;
		case "specialty_bulletdamage":
			text SetText( &"REIMAGINED_ECH_PRK_HINT" );
			title SetText( &"REIMAGINED_ECH_PRK_TITLE" );
			break;
		case "specialty_bulletdamage_upgrade":	//Cherry
		
			text SetText( &"REIMAGINED_ECH_PRO_HINT" );
			title SetText( &"REIMAGINED_ECH_PRO_TITLE" );
			break;
		case "specialty_altmelee":
			text SetText( &"REIMAGINED_VLT_PRK_HINT" );
			title SetText( &"REIMAGINED_VLT_PRK_TITLE" );
			break;

		case "specialty_altmelee_upgrade":	//Vulture
			text SetText( &"REIMAGINED_VLT_PRO_HINT" );
			title SetText( &"REIMAGINED_VLT_PRO_TITLE" );
			break;

		case "specialty_bulletaccuracy":
			text SetText( &"REIMAGINED_WWN_PRK_HINT" );
			title SetText( &"REIMAGINED_WWN_PRK_TITLE" );
			break;

		case "specialty_bulletaccuracy_upgrade":	//wine
			text SetText( &"REIMAGINED_WWN_PRO_HINT" );
			title SetText( &"REIMAGINED_WWN_PRO_TITLE" );
			break;

		case "specialty_pap_hellfire":
			text SetText( &"REIMAGINED_PAP_HELLFIRE_HINT" );
			title SetText( &"REIMAGINED_PAP_HELLFIRE_TITLE" );
			break;

		case "specialty_pap_hellfire_onhit":
			text SetText( &"REIMAGINED_PAP_HELLFIRE_ONHIT_HINT" );
			title SetText( &"REIMAGINED_PAP_HELLFIRE_ONHIT_TITLE" );
			break;

		case "specialty_pap_sheer_cold":
			text SetText( &"REIMAGINED_PAP_SHEER_COLD_HINT" );
			title SetText( &"REIMAGINED_PAP_SHEER_COLD_TITLE" );
			break;

		case "specialty_pap_shock_rounds":
			text SetText( &"REIMAGINED_PAP_SHOCK_ROUNDS_HINT" );
			title SetText( &"REIMAGINED_PAP_SHOCK_ROUNDS_TITLE" );
			break;

		case "specialty_pap_big_damage":
			text SetText( &"REIMAGINED_PAP_BIG_DAMAGE_HINT" );
			title SetText( &"REIMAGINED_PAP_BIG_DAMAGE_TITLE" );
			break;

		case "specialty_pap_big_headshot_damage":
			text SetText( &"REIMAGINED_PAP_BIG_HEADSHOT_DAMAGE_HINT" );
			title SetText( &"REIMAGINED_PAP_BIG_HEADSHOT_DAMAGE_TITLE" );
			break;

		case "specialty_pap_execute":
			text SetText( &"REIMAGINED_PAP_EXECUTE_HINT" );
			title SetText( &"REIMAGINED_PAP_EXECUTE_TITLE" );
			break;

		case "specialty_shotgun_damage":
			text SetText( &"REIMAGINED_SHOTGUN_DAMAGE_HINT" );
			title SetText( &"REIMAGINED_\SHOTGUN_DAMAGE_TITLE" );
			break;

		case "specialty_sniper_damage":
			text SetText( &"REIMAGINED_SNIPER_DAMAGE_HINT" );
			title SetText( &"REIMAGINED_SNIPER_DAMAGE_TITLE" );
			break;

		case "specialty_sidearm_bonus":
			if( level.apocalypse )
			{
				text SetText( &"REIMAGINED_SIDEARM_DAMAGE_HINT" );
				title SetText( &"REIMAGINED_SIDEARM_DAMAGE_TITLE" );
			}
			break;
		case "specialty_offhand_melee":
			text SetText( &"REIMAGINED_OFFHAND_MELEE_HINT" );
			title SetText( &"REIMAGINED_OFFHAND_MELEE_TITLE" );
			break;

		case "free_perk_powerup":
			text SetText( &"REIMAGINED_FREE_PERK_HINT" );
			title SetText( &"REIMAGINED_FREE_PERK_TITLE" );
			break;

		case "superpower_powerup":
			text SetText( &"REIMAGINED_POWERUP_SUPERPOWER_HINT" );
			title SetText( &"REIMAGINED_POWERUP_SUPERPOWER_TITLE" );
			break;

		case "restock_powerup":
			text SetText( &"REIMAGINED_POWERUP_RESTOCK_HINT" );
			title SetText( &"REIMAGINED_POWERUP_RESTOCK_TITLE" );
			break;

		/* Specific Weapons */
		case "m1911_upgraded_zm":
			//Dont set if player is in last stand
			if( self maps\_laststand::player_is_in_laststand() )
			{
				self.hints_activated[ "m1911_upgraded_zm" ] = false;
				return;
			}
				
			text SetText( &"REIMAGINED_PAP_M1911_HINT" );
			title SetText( &"REIMAGINED_PAP_M1911_TITLE" );
			break;

		//for uzi
		case "uzi_upgraded_zm_x2":
			text SetText( &"REIMAGINED_PAP_UZIZI_HINT" );
			title SetText( &"REIMAGINED_PAP_UZIZI_TITLE" );
			break;

		//for famas
		case "famas_upgraded_zm_x2":
			text SetText( &"REIMAGINED_PAP_FAMAS_HINT" );
			title SetText( &"REIMAGINED_PAP_FAMAS_TITLE" );
			break;

		//for mac11
		case "mac11_upgraded_zm_x2":
			text SetText( &"REIMAGINED_PAP_MAC11_HINT" );
			title SetText( &"REIMAGINED_PAP_MAC11_TITLE" );
			break;

		//for ks23
		case "ks23_upgraded_zm_x2":
			text SetText( &"REIMAGINED_PAP_KS23_HINT" );
			title SetText( &"REIMAGINED_PAP_KS23_TITLE" );
			break;

		//for spas
		case "spas_upgraded_zm_x2":
			text SetText( &"REIMAGINED_PAP_SPAS_HINT" );
			title SetText( &"REIMAGINED_PAP_SPAS_TITLE" );
			break;

		}

	text FadeOverTime( 1 );
	text.alpha = 1;

	title FadeOverTime( 1 );
	title.alpha = 1;

	wait_time = 7;

	if( specialHint )
		wait_time = 10;	

	wait( wait_time );
	self.new_perk_hint = false;
	self notify( "perk_hint_end" );


    title FadeOverTime( 2 );
	title.alpha = 0;

    text FadeOverTime( 2 );
	text.alpha = 0;

	if( returnVultureVision )
		self.vulture_vison_toggle = true;

	title destroy_hud();
	text destroy_hud();

	//iprintln( "notify 3: " + hintCode );
}

wait_print( msg, data )
{
	flag_wait("begin_spawning");
	wait(5);
	if( isdefined( data ) )
	{
		//iprintln( msg + " " + data );
	}
	else
	{
		//iprintln( msg  + " undefined data");
	}
	
}

/*
	###############################
		X2 Weapon Names
	###############################
*/

/*

	REFERENCE          	WEAPON_SABERTOOTH
LANG_ENGLISH       	"Sabertooth"

REFERENCE          	SABERTOOTH_UPGRADED
LANG_ENGLISH       	"S-115 Dismemberer"

REFERENCE          	SABERTOOTH_UPGRADED
LANG_ENGLISH       	"S-339 Incinerator"

REFERENCE          	CROSSBOW_EXPLOSIVE_UPGRADED_X2
LANG_ENGLISH        "Deliverance"

REFERENCE          	KNIFE_BALLISTIC_UPGRADED_X2
LANG_ENGLISH        "Krauss Defibrillator"


REFERENCE          	KS23_UPGRADED
LANG_ENGLISH       	"KS-56"

REFERENCE          	KS23_UPGRADED_X2
LANG_ENGLISH       	"Shock Army Executioner"

REFERENCE          	SPAS_UPGRADED_X2
LANG_ENGLISH       	"Spas-M24"

REFERENCE          	HS10_UPGRADED_X2
LANG_ENGLISH        "Typhoid & Mary (Divorced)"



REFERENCE          	AK47_UPGRADED
LANG_ENGLISH       	"The Red Mist"

REFERENCE          	AK47_UPGRADED
LANG_ENGLISH       	"Blitzkrieg"

REFERENCE          	ENFIELD_UPGRADED
LANG_ENGLISH       	"WINFIELD"

REFERENCE          	ENFIELD_UPGRADED_X2
LANG_ENGLISH       	"Bullpup Penatrator"

REFERENCE          	AUG_UPGRADED_X2
LANG_ENGLISH        "Shock & AUG"

REFERENCE          	FAMAS_UPGRADED_X2
LANG_ENGLISH        "G16-G-Infinite"

REFERENCE          	FNFAL_UPGRADED_X2
LANG_ENGLISH        "FN Peacemaker"

REFERENCE          	G11_LPS_UPGRADED_X2
LANG_ENGLISH        "Gone-11"

REFERENCE          	GALIL_UPGRADED_X2
LANG_ENGLISH        "Winter's Wail"

REFERENCE          	COMMANDO_UPGRADED_X2
LANG_ENGLISH        "The Feast"



REFERENCE          	SPECTRE_UPGRADED_X2
LANG_ENGLISH        "Wraith"

REFERENCE          	PPSH_UPGRADED
LANG_ENGLISH       	"The Reaper"

REFERENCE          	PPSH_UPGRADED_X2
LANG_ENGLISH       	"YTE SLAYA"

REFERENCE          	UZI_UPGRADED
LANG_ENGLISH       	"Uzizi"

REFERENCE          	UZI_UPGRADED_X2
LANG_ENGLISH       	"Uzizi "

REFERENCE          	MAC11_UPGRADED
LANG_ENGLISH       	"Killer & Psycho"

REFERENCE          	MAC11_UPGRADED_X2
LANG_ENGLISH       	"Turmoil Twins"


REFERENCE          	ASP_UPGRADED
LANG_ENGLISH       	"Another Side Piece"

REFERENCE          	ASP_UPGRADED_X2
LANG_ENGLISH       	"PSA Death"

REFERENCE          	CZ75_DW_UPGRADED_X2
LANG_ENGLISH        "Silhouette and Gamble"

REFERENCE          	CZ75_UPGRADED_X2
LANG_ENGLISH        "Silhouette"

REFERENCE          	PYTHON_UPGRADED_X2
LANG_ENGLISH        "Cobra's Frenzy"


REFERENCE          	STONER63_UPGRADED
LANG_ENGLISH       	"Stoned69"

REFERENCE          	STONER63_UPGRADED_x2
LANG_ENGLISH       	"He Who is Without Sin"

REFERENCE          	HK21_UPGRADED_X2
LANG_ENGLISH        "H115 Oscillator"

REFERENCE          	RPK_UPGRADED_X2
LANG_ENGLISH        "Scorched Earch"

REFERENCE          	M60_UPGRADED
LANG_ENGLISH       	"Mega-60"

REFERENCE          	M60_UPGRADED_X2
LANG_ENGLISH       	"Big Daddy"



REFERENCE          	PSG1_UPGRADED
LANG_ENGLISH       	"Psychotic Salient Genius"

REFERENCE          	PSG1_UPGRADED_X2
LANG_ENGLISH       	"Serendipity"

REFERENCE          	L96A1_UPGRADED_X2
LANG_ENGLISH        "L115 Decimator"

REFERENCE          	DRAGUNOV_UPGRADED_X2
LANG_ENGLISH        "Zmei's Breath"


REFERENCE          	RAY_GUN_UPGRADED_X2
LANG_ENGLISH        "RAY_GUN_UPGRADED_X2"

REFERENCE          	CHINA_LAKE_UPGRADED_X2
LANG_ENGLISH        "CHINA_LAKE_UPGRADED_X2"


REFERENCE          	ROTTWEIL72_UPGRADED_X2
LANG_ENGLISH        "ROTTWEIL72_UPGRADED_X2"

REFERENCE          	ITHACA_UPGRADED_X2
LANG_ENGLISH        "Destroyer"

REFERENCE          	M14_UPGRADED_X2
LANG_ENGLISH        "M14_UPGRADED_X2"

REFERENCE          	M16_UPGRADED_X2
LANG_ENGLISH        "M16_UPGRADED_X2"

REFERENCE          	MP40_UPGRADED_X2
LANG_ENGLISH        "MP40_UPGRADED_X2"

REFERENCE          	MP5K_UPGRADED_X2
LANG_ENGLISH        "MP5K_UPGRADED_X2"

REFERENCE          	MPL_UPGRADED_X2
LANG_ENGLISH        "MPL_UPGRADED_X2"

REFERENCE          	PM63_UPGRADED_X2
LANG_ENGLISH        "PM63_UPGRADED_X2"

REFERENCE          	PM63_UPGRADED_X2
LANG_ENGLISH        "PM63_UPGRADED_X2"

REFERENCE          	AK74U_UPGRADED_X2
LANG_ENGLISH        "AK74U_UPGRADED_X2"

REFERENCE          	SHOTGUN_DOUBLE_BARRELED_UPGRADED
LANG_ENGLISH        "SHOTGUN_DOUBLE_BARRELED_UPGRADED"

REFERENCE          	FG42_UPGRADED_X2
LANG_ENGLISH        "FG42_UPGRADED_X2"

REFERENCE          	GEWEHR43_UPGRADED_X2
LANG_ENGLISH        "GEWEHR43_UPGRADED_X2"

REFERENCE          	KAR98K_UPGRADED_X2
LANG_ENGLISH        "KAR98K_UPGRADED_X2"

REFERENCE          	M1A1CARBINE_UPGRADED_X2
LANG_ENGLISH        "M1A1CARBINE_UPGRADED_X2"

REFERENCE          	SHOTGUN_UPGRADED_X2
LANG_ENGLISH        "SHOTGUN_UPGRADED_X2"

REFERENCE          	STG-44_UPGRADED
LANG_ENGLISH        "STG-44_UPGRADED"

REFERENCE          	THOMPSON_UPGRADED_X2
LANG_ENGLISH        "THOMPSON_UPGRADED_X2"

REFERENCE          	TYPE100_SMG_UPGRADED_X2
LANG_ENGLISH        "TYPE100_SMG_UPGRADED_X2"


REFERENCE          	BAR_UPGRADED
LANG_ENGLISH        "THE STANDARD"

REFERENCE          	M1GARAND_UPGRADED
LANG_ENGLISH        "BULLPUP T31"

REFERENCE          	SPRINGFIELD_UPGRADED
LANG_ENGLISH        "WINTERFIELD"

REFERENCE          	MAKAROV_UPGRADED
LANG_ENGLISH        "PM Standartnyy"




*/

/*
	method: getWeaponUiName

	description: Returns the weapon name for the given weapon using the weapon file's string
	and the number of PaP metadata

*/
getWeaponUiName( weapon )
{

	if( IsDefined( self.packapunch_weapons[ weapon ] ) )
	{
		//if substring allready contains _x2, nothing
		if( isSubStr( weapon, "_x2" ) )	{
			//nothing
		}
		else if( self.packapunch_weapons[ weapon ] > 1 )
		{
			weapon += "_x2";
		}
	}

	
	wepName = "";
	switch( weapon )
	{
		case "sabertooth_upgraded_zm_x2":
			wepName = "S-339 Disintegrator";
		break;

		case "crossbow_explosive_upgraded_zm_x2":
			wepName = "Deliverance";
		break;

		case "knife_ballistic_upgraded_zm_x2":
			wepName = "Krauss Defibrillator";
		break;
		
		case "ks23_upgraded_zm_x2":
			wepName = "Shock Army Exterminator";
		break;

		case "spas_upgraded_zm_x2":
			wepName = "Spontaneity";
		break;

		case "hs10_upgraded_zm_x2":
			wepName = "Typhoid & Mary (Divorced)";
		break;

		case "ak47_upgraded_zm_x2":
			wepName = "Blitzkrieg";
		break;

		case "enfield_upgraded_zm_x2":
			wepName = "Bullpup Penetrator";
		break;

		case "aug_acog_mk_upgraded_zm_x2":
			wepName = "Shock & AUG";
		break;

		case "famas_upgraded_zm_x2":
			wepName = "G16-G-Infinite";
		break;

		case "fnfal_upgraded_zm_x2":
			wepName = "The Peacemaker";
		break;

		case "g11_lps_upgraded_zm_x2":
			wepName = "Gone-11";
		break;

		case "galil_upgraded_zm_x2":
			wepName = "Winter's Wail";
		break;

		case "commando_upgraded_zm_x2":
			wepName = "The Feast";
		break;


		case "spectre_upgraded_zm_x2":
			wepName = "Wraith";
		break;

		case "kiparis_upgraded_zm_x2":
			wepName = "Little John";
		break;

		case "ppsh_upgraded_zm_x2":
			wepName = "Y0TE SLAYA";
		break;

		case "uzi_upgraded_zm_x2":
			type = level.WEAPON_UZI_TYPES[ self.weap_options["uzi_upgraded_zm_x2"] ];
			wepName = "Uzizi " + type;
		break;

		case "mac11_upgraded_zm_x2":
			wepName = "Turmoil Twins";
		break;

		case "asp_upgraded_zm_x2":
			wepName = "PSA Death";
		break;

		case "cz75_dw_upgraded_zm_x2":
			wepName = "Silhouette and Gamble";
		break;

		case "cz75_upgraded_zm_x2":
			wepName = "Silhouette";
		break;

		case "python_upgraded_zm_x2":
			wepName = "Cobra's Frenzy";
		break;

		case "makarov_upgraded_zm_x2":
			wepName = "Winter's Uzhas";
		break;

		case "hk21_upgraded_zm_x2":
			//wepName = "H115 Oscillator";
		break;

		case "rpk_upgraded_zm_x2":
			//wepName = "Scorched Earth";
		break;

		case "m60_upgraded_zm_x2":
			wepName = "Big Daddy";
		break;

		case "stoner63_upgraded_zm_x2":
			wepName = "He Who is Without Sin";
		break;

		case "psg1_upgraded_zm_x2":
			wepName = "Serendipity";
		break;

		case "l96a1_upgraded_zm_x2":
			wepName = "L115 Decimator";
		break;

		case "dragunov_upgraded_zm_x2":
			wepName = "Zmei's Breath";
		break;

		//Knives
		case "knife_zm":
			if( self.knife_index == level.VALUE_WPN_INDEX_BOWIE)
				wepName = "Bowie Knife";
			else if( self.knife_index == level.VALUE_WPN_INDEX_SICKLE)
				wepName = "Sickle";
		break;
	
		case "combat_knife_zm":
			if( self.knife_index == level.VALUE_WPN_INDEX_BOWIE)
				wepName = "Bowie Knife";
			else if( self.knife_index == level.VALUE_WPN_INDEX_SICKLE)
				wepName = "Sickle";

	}

	//iprintln( "DYNAMIC NAME: " + wepName );

	return wepName;
}


/*
	###############################
	PRO PERK PLACER
    ###############################
*/


/*
	Enter visualizer
	self is player placing the object
*/
start_properk_placer()
{
	//iprintlnbold("Starting Pro Perk Placer");
	
	r=150;
	z=10;
	//angles = self GetPlayerAngles(); 
	//offset = (r*sin(angles[1]), r*cos(angles[1]), z);
	forward_view_angles = self GetWeaponForwardDir();
	offset = vector_scale(forward_view_angles, r);

	//iprintlnbold("Forward view angles: " + forward_view_angles);
	//iprintlnbold("self: " + self.origin);
	//iprintlnbold("Offset: " + offset);

	new_pos = self.origin + offset;
	//iprintln("new pos: " + new_pos );
	object = Spawn( "script_model", new_pos);
	object SetModel( "t6_wpn_zmb_perk_bottle_jugg_world" );
	//object SetModel( "t5_weapon_sabretooth_world" );
  	//object SetModel( "char_ger_zombeng_body1_1" );

	/*
	object SetModel( "p_glo_propanetank_thin" );
	wait(1);
	object SetModel( "p_jun_dollytanks" );
	wait(1);
	object SetModel( "p_rus_chemtank_med" );
	wait(1);
	object SetModel( "zombie_tank" );
	wait(1);
	object SetModel( "zombie_vending_sleight" );
	wait(1);
	object SetModel( "p_a51_fueltank_01" );
	*/
	//object SetModel( "zombie_vending_doubletap2" );
	//object SetModel( "zombie_vending_revive" );
	//object SetModel( "zombie_vending_nuke" );
	//object SetModel( "zombie_vending_marathon" );
	//object SetModel( "zombie_vending_ads" );
	//object SetModel( "zombie_vending_three_gun" );
	//object SetModel( "p6_zm_vending_chugabud" );
	//object SetModel( "p6_zm_vending_electric_cherry_off" );
	//object SetModel( "bo2_zombie_vending_vultureaid" );
	//object SetModel( "bo3_p7_zm_vending_widows_wine_off" );


	//object.angles = angles + (0, 180, 0);
	object.angles = VectorToAngles(forward_view_angles);

	//iprintlnbold("Configured object");

	wait(1);

	level.editing = array("x", "y", "z", "theta", "ro", "phi");
	level.fidelities = array(5, 10, 45);

    while(1)
    {
		/*
			q - return obj to player
			e - edit obj position and angles
				v - change editing index: x, y, z, theta, ro, phi
						- theta - like a clock
						- ro - roll

						- z - up/downm
				c - change fidelity index: 1, 5, 10, 45
				f - moves into editing mode, must press enter once to exit
					f - adjust value up
					r - adjust value down

			enter, exit fine tuning, return object to player

		*/

		if( self buttonPressed("q") )
		{
			//Return object to player
			forward_view_angles = self GetWeaponForwardDir();
			offset = vector_scale(forward_view_angles, r);

			object.origin = self.origin + offset;
			object.angles = VectorToAngles(forward_view_angles);
			object.angles += (0, -90, 0);
			//iprintlnbold("Returning object to player");
			wait(1);
			continue;
		}

		if( self buttonPressed("e") )
		{
			count = 0;
			show = 30;
			//Edit objects position and angles
			i = 0; // Editing Index
    		j = level.fidelities.size-1; //fidelities index
			//iprintlnbold("Tuning: " + level.editing[i] + " : " + level.fidelities[j]);
			
			while(1)
			{
				//every 10 counts display the print statement
				if(count % show == 0)
				{
					//iprintlnbold("Tuning: " + level.editing[i] + " : " + level.fidelities[j]);
				}
				count++;

				if(self buttonPressed("v"))
				{
					i++;
					if(i >= level.editing.size)
						i = 0;
					editing = level.editing[i];
					//iprintlnbold("Editing: " + editing);
					wait( 0.5 );
					continue;
				}

				if(self buttonPressed("c"))
				{
					j++;
					if(j >= level.fidelities.size)
						j = 0;
					//iprintlnbold("Fidelity: " + level.fidelities[j]);
					wait( 0.5 );
					continue;
				}

				if(self buttonPressed("f"))
				{
					//iprintlnbold("Editing: ");
					temp = self editObject( object, i, j );
					object.origin = temp.origin;
					object.angles = temp.angles;

					//iprintln("pos: " + object.origin);
					//iprintln("ang: " + object.angles);
				}
				
				wait(0.2);

				if(self buttonPressed("ENTER"))
					break;
				
				
			}
			
			
			//iprintlnbold("object position: " + object.origin);
			//iprintlnbold("object angles: " + object.angles);
		}

		//iprintln("no input");
        wait 0.1;
    }
}


editObject( object, i, j )
{

	editing = level.editing[i];

	struct = SpawnStruct();
	struct.origin = object.origin;
	struct.angles = object.angles;
	//iprintlnbold("Begining position: " + object.origin);
	//iprintlnbold("Begining angles: " + object.angles);

	while(1)
	{
		
		wait(1);

		if(self buttonPressed("r"))
		{
			//iprintln("UP");
			struct adjust( editing, level.fidelities[j] );
			//wait(0.05);
			return struct;
		}
			
		if(self buttonPressed("f"))
		{
			//iprintln("DOWN");
			struct adjust( editing, -1 * level.fidelities[j] );
			//wait(0.05);
			return struct;
		}


		if(self buttonPressed("ENTER"))
		{
			//iprintlnbold("Returning struct");
			return struct;
		}
		
		
	}


}




adjust( editing, adj )
{
	angles = self.angles;
	new_angles = (0,0,0);
	//iprintlnbold("Adjusting: " + editing + " by " + adj);

	//editing = "none";
	//self.origin += (10, 0, 0);
	//self.angles += (10, 0, 0);

	switch(editing)
	{
		case "x":
			self.origin += (adj, 0, 0);
			break;
		case "y":
			self.origin += (0, adj, 0);
			break;
		case "z":
			self.origin += (0, 0, adj);
			break;
		case "theta":
		//iprintln("Adjusting theta " + adj);
		//iprintln("current theta " + angles[0]);
			if(angles[0] + adj > 180 )
			{
				diff = (angles[0] + adj) - 180;
				self.angles += (-180 + diff, 0, 0);
			}
			else if(angles[0] - adj < -180)
			{
				diff = (angles[0] + adj) + 180;
				self.angles += ( 180 - diff, 0, 0);
			}
			else
				self.angles += (adj, 0, 0);
			break;
		case "ro":
		//iprintln("Adjusting roll " + adj);
		//iprintln("current roll " + angles[1]);
			if(angles[1] + adj > 180 )
			{
				diff = (angles[1] + adj) - 180;
				self.angles += (0, -180 + diff, 0);
			}
			else if(angles[1] - adj < -180)
			{
				diff = (angles[1] + adj) + 180;
				self.angles += (0, 180 - diff, 0);
			}
			else
				self.angles += (0, adj, 0);
			break;
		case "phi":
		//iprintln("Adjusting pitch " + adj);
		//iprintln("current pitch " + angles[2]);
			if(angles[2] + adj > 180 )
			{
				diff = (angles[2] + adj) - 180;
				self.angles += (0, 0, -180 + diff);
			}
			else if(angles[2] - adj < -180)
			{
				diff = (angles[2] + adj) + 180;
				self.angles += (0, 0, 180 - diff);
			}
			else
				self.angles += (0, 0, adj);
			break;

		default:
			break;
	}

	//iprintlnbold("New position: " + self.origin);
	//iprintlnbold("New angles: " + self.angles);


}

/*
	###############################
   	ZOMBIE UTILITY
	###############################
*/

/*
	get_upgraded_weapon_string
	ugrade_weapon_string
	string_weapon_upgrade

*/

get_upgraded_weapon_string( weapon )
{
	if( IsDefined( self.packapunch_weapons[ weapon ] ) )
	{
		//if substring allready contains _x2, then exit for loop
		if( isSubStr( weapon, "_x2" ) )	{
			//nothing
		}
		else if( self.packapunch_weapons[ weapon ] > 1 )
		{
			weapon += "_x2";
		}
	}

	return weapon;
}


/*
	###############################
    GENERAL UTILITY
	###############################
*/

checkObjectInPlayableArea( object )
{
	playable_area = getentarray("player_volume","script_noteworthy");
	for (i = 0; i < playable_area.size; i++)
	{
		if (object IsTouching(playable_area[i])) {
			return true;
		}
	}
	return false;
}

//Get next index in array
get_next_index( pos, dir, size )
{
	if( dir > 0)
	{
		while( dir > 0)
		{
			pos++;
			if( pos >= size )
				pos = 0;
			dir--;
		}
		
	}
	else
	{
		while( dir < 0)
		{
			pos--;
			if( pos < 0 )
				pos = size - 1;
			dir++;
		}
	}

	return pos;
}

/*
wait_print( msg, data )
	{
		flag_wait("begin_spawning");
		//iprintln( msg );
		
		if( IsDefined( data ) )
		{
			//iprintln( data );
		}
		
	}
	*/

	printHelper( a, b, c, d, e, f)
	{
		if( !IsDefined( a ) )
			a = "";
		
		if( !IsDefined( b ) )
			b = "";

		if( !IsDefined( c ) )
			c = "";

		if( !IsDefined( d ) )
			d = "";

		if( !IsDefined( e ) )
			e = "";
		
		if( !IsDefined( f ) )
			f = "";
		
		//iprintln( a + " " + b + " " + c + " " + d + " " + e + " " + f );
	}
