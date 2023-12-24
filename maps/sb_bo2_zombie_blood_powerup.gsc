#include maps\_utility;
#include maps\_zombiemode_utility;
#include common_scripts\utility;
#include maps\_hud_util;

// Scripted by Slayerbeast12
// Scripted For Der Riese mostly atm updated for all maps now

// Fixed up by xSanchez78

init()
{
	//PreCacheModel( "c_zom_player_honorguard_fb" );
	PreCacheModel( "c_viet_zombie_napalm" );
	//level._effect[ "bo2_powerup_zombie_blood_glow" ] = LoadFX( "custom/zombie_blood/fx_bo2_powerup_zombie_blood_glow" );
	//level._effect["fx_trail_blood_streak"]			= LoadFx("trail/fx_trail_blood_streak");
	level.plr_currently_using_zombie_blood = false;
}


zombie_blood_powerup( player, powerup_time )
{
	player endon( "disconnect" );
	player endon( "zombie_blood_over" );
	level.plr_currently_using_zombie_blood = true;
	player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] += powerup_time;
	//iprintln("bloodPowerup::zombeieblood");
	if( player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] )
	{
		return;
	}

	//player thread zombie_blood_on_death();
	player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] = true;
	
	//iprintln("Setting clientSysState for player with weapon: " + player GetCurrentWeapon() );

	//setClientSysState( "levelNotify", "zblood_on", player );
	//setClientSysState( "levelNotify", "zblood_on");
	player thread zombie_blood_change_playermodel( true );
	//player thread zombie_blood_create_fx();

	player VisionSetNaked( "zombie_blood", 0.5 );
	player SetMoveSpeedScale( player.moveSpeed + 0.3 );
	//start_time = GetRealTime();
	/*
	transition_time = 1.0;
	time=0;
	while( time < transition_time ) {
		progress = time / transition_time;
	 	player SetClientDvar( "cg_fovscale", player GetDvar("cg_fovscale") + ( 0.2 * progress ) );
		time += 0.1;
		wait (0.1);
	} 
	*/
	
	//player SetClientDvar( "cg_fovscale", player GetDvar("cg_fovscale") + 0.2 );
	while( player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] > 0 )
	{
		player VisionSetNaked( "zombie_blood", 0.0 );
		player.ignoreme = true;
		wait 0.1;
		player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] -= 0.1;
	}

	//player SetClientDvar( "cg_fovscale", player GetDvar("cg_fovscale") - 0.2 );
		if( IsDefined( level.zombie_visionset ) )
			player VisionSetNaked( level.zombie_visionset, 0.5 );
		else
			player VisionSetNaked( "undefined", 0.5 );
	player SetMoveSpeedScale( player.moveSpeed - 0.3 );
	player.ignoreme = false;

	player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] = false;
	player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] = 0;
	//setClientSysState( "levelNotify", "zblood_off", player );
	player thread zombie_blood_change_playermodel( false );

	level.plr_currently_using_zombie_blood = false;
	player notify( "zombie_blood_over" );
}



zombie_blood_change_playermodel( change_to_zombie )
{
	if( change_to_zombie )
	{
		self.hero_model = self.model;
		if( level.script == "zombie_moon" )
		{
			if( !self maps\_zombiemode_equipment::is_equipment_active( "equip_gasmask_zm" ) )
			{
				self Detach( self.headModel, "" );
				self Attach( "c_zom_ger_zombie_head1", "", true );
			}
		}
		else
		{
			self SetModel( "c_viet_zombie_napalm" );
			if( IsDefined( self.headModel ) )
			{
				self Detach( self.headModel, "" );
			}
			if( IsDefined( self.hatModel ) )
			{
				self Detach( self.hatModel );
			}
		}
	}
	else
	{
		self SetModel( self.hero_model );
		self.hero_model = undefined;
		if( IsDefined( self.headModel ) )
		{
			self Attach( self.headModel, "", true );
		}
		if( IsDefined( self.hatModel ) )
		{
			self Attach( self.hatModel );
		}
	}
}



/*
zombie_blood_on_death()
{
	self endon( "disconnect" );
	self endon( "zombie_blood_over" );
	self waittill_any( "player_downed", "fake_death" );
	self.zombie_vars[ "zombie_powerup_zombie_blood_time" ] = 0;
	self.zombie_vars[ "zombie_powerup_zombie_blood_on" ] = false;
	//setClientSysState( "levelNotify", "zblood_off", self );
	self thread zombie_blood_change_playermodel( false );
	level.plr_currently_using_zombie_blood = false;
	self notify( "zombie_blood_over" );
}

zombie_blood_create_fx()
{
	self PlaySound( "zmb_bo2_powerup_zombie_blood_start" );
	self PlaySound( "zmb_bo2_powerup_zombie_blood_vox" );
	fx_origin = Spawn( "script_model", self.origin + ( 0, 0, 45 ) );
	fx_origin.angles = ( 0, 0, 0 );
	fx_origin SetModel( "tag_origin" );
	fx_origin EnableLinkTo();
	fx_origin LinkTo( self );
	fx_origin PlayLoopSound( "zmb_bo2_powerup_zombie_blood_loop" );
	PlayFXOnTag( level._effect[ "bo2_powerup_zombie_blood_glow" ], fx_origin, "tag_origin" );
	//iprintln("waiting for zombie blood over");
	self waittill_any( "zombie_blood_over", "disconnect" );
	fx_origin StopLoopSound();
	fx_origin Delete();
	self PlaySound( "zmb_bo2_powerup_zombie_blood_end" );
}
*/