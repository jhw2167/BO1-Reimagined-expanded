#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

//Renn Script
#using_animtree( "generic_human" );
zmb_engineer( target )
{

  if( !isDefined( target ) ) // then ill guess it just be a piece of shit normal zombie
  {
    return;
  }

  if( !is_true(self.zombie_init_done) ) {
	//self waittill( "zombie_init_done");
  }

  //self thread zm_variant_on_death( "engineer" );
		
  spawner = level.enemy_spawns[0];
  self.count=666; 
  self.script_noteworthy = spawner.script_noteworthy;
  self.targetname = spawner.targetname;
  self.target = spawner.target;
  self.deathFunction = ::boss_die;
  self.animname = "boss_zombie";

  self detachAll();
  self.no_gib = 1;
  self setmodel( "char_ger_zombeng_body1_1" );

  self.animname = "boss_zombie";
  self.moveplaybackrate = 0;
  self.talking = true;
  self hide();
  self.ignore_all_poi = true;
  self.ignoreall = true;
  self.meleeDamage = 130;
  self.flame_damage_time = 0;
  self.is_on_fire = true;
  self.a.disablePain = true;
  self disable_react();
  self.allowpain = false;
  self.no_damage_points = true;
  self.zombie_can_sidestep = false;
  self.sideStepType = "none";
  self.noChangeDuringMelee = true;
  self.script_string = undefined;
  self thread magic_bullet_shield();
  self dontinterpolate();
  self.script_disable_bleeder = 1;
  self.script_noteworthy = "find_flesh";
  self.script_moveoverride = true;
  self.first_node.script_noteworthy = "no_blocker";

  self.custom_idle_setup = ::boss_zombie_idle_setup;

  self.set_animarray_standing_override = ::boss_zombie_idle_setup;

  self.a.idleAnimOverrideArray = [];
  self.a.idleAnimOverrideArray["stand"] = [];
  self.a.idleAnimOverrideArray["stand"] = [];
  self.a.idleAnimOverrideArray["stand"][0][0] 	= %ai_zombie_boss_idle_a;
  self.a.idleAnimOverrideWeights["stand"][0][0] 	= 10;
  self.a.idleAnimOverrideArray["stand"][0][1] 	= %ai_zombie_boss_idle_a;
  self.a.idleAnimOverrideWeights["stand"][0][1] 	= 10;

  count = 0;

  target playsound( "zmb_elec_start" );

  while( count < 40 ) // double check to make sure its hiding and not going to be force to teleport to barriers
  {
    self notify( "teleporting" );
    self hide();
    self unlink();
    self.anchor delete();
    self.first_node = undefined;
    self ClearEnemy();
    self ClearGoalVolume();
    self.zombie_move_speed = "walk";
    self.zombie_can_sidestep = false;
    self.zombie_can_forwardstep = false;
    self.shouldSideStepFunc = ::no_reaction;

    count++;
    wait .06;
  }

  count = 0;
  //play boss spawn build up
  fxTarget = target - (0,0,25);
  target playsound( "zmb_elec_start" );
  
  Playfx( level._effect["fx_zombie_boss_spawn_buildup"], fxTarget );
  //Playfx( level._effect["fx_teleporter_pad_glow"], fxTarget );
  Playfx( level._effect["fx_transporter_start"], fxTarget );
  wait(1.5);
  //play boss spawn ground
  Playfx( level._effect["fx_zombie_boss_spawn_ground"], fxTarget );
  //Playfx( level._effect["fx_zombie_boss_spawn"], target );

  //level._effect["poltergeist"]
  //Playfx( level._effect["poltergeist"], target );
  playsoundatposition( "zmb_hellhound_prespawn", target );
  playsoundatposition( "zmb_hellhound_bolt", target );
  //Playfx( level._effect["fx_lighting_strike"], target ); //didnt work
  wait(0.5);
  Earthquake( 0.5, 0.75, target, 1000 );
  PlayRumbleOnPosition( "explosion_generic", target );
  playsoundatposition( "zmb_hellhound_spawn", target );

  self ForceTeleport( target );
  //self ForceTeleport( get_players()[0].origin );

  self thread stop_magic_bullet_shield();

  self.maxHealth=99999999;
  self.health = self.maxhealth*1;
  //self.actor_full_damage_func = ::heavy_zombie_dmg_function;
  //self.custom_damage_func = ::eng_custom_damage;
  self show();
  self.moveplaybackrate = 1;
  self.needs_run_update = true;
  
  
  self maps\_zombiemode_spawner::set_zombie_run_cycle("walk");
  self ClearAnim( %exposed_modern, 0 );
  self SetFlaggedAnimKnobAllRestart( "run_anim", animscripts\zombie_run::GetRunAnim(), %body, 1, 0.2, self.moveplaybackrate );
  self.needs_run_update = false;
  self.script_moveoverride = false;
  self.ignoreall = false;
  self.hasDrop = undefined; //no drops
  self.ignore_enemy_count = true;
  self clearclientflag(level._ZOMBIE_ACTOR_ZOMBIE_HAS_DROP);
  level.engineer_zms_alive++;

  self eng_determine_poi();
  self eng_attack_properties();
  //self thread animscripts\zombie_combat::main();

  /*
  self notify( "stop_find_flesh" );
  self notify( "zombie_acquire_enemy" );
  self notify( "goal" );

  while( count < 20 )
  {
    self thread maps\_zombiemode_spawner::find_flesh();
	self.following_player = true;
    self thread maps\_zombiemode_spawner::zombie_setup_attack_properties();
    //self thread maps\_zombiemode_spawner::reset_attack_spot();
    count++;

    wait .1;
  }
  */

  self.thundergun_disintegrate_func = ::thundergun_disintegrate;
  self.thundergun_knockdown_func = ::thundergun_knockdown;
  self.tesla_head_gib_func = ::tesla_gib;

  self thread watch_eng_goals();

}

	thundergun_disintegrate(player) {
		//nothing
	}

	thundergun_knockdown(player, gib) {
		screamAnim = %ai_zombie_boss_enrage_start_scream_coast;
		//self animscripted( name, self.origin, self.angles, screamAnim );
		playsoundatposition( "zmb_engineer_vocals_hit", self.origin );
		wait(1);
		self thread threadAnim( "scream", screamAnim );
		PlayRumbleOnPosition( "explosion_generic", self.origin );
		self waittill_notify_or_timeout( "anim_done", 1.0 );
	}

	tesla_gib() {
		//nothing
	}



eng_determine_poi()
{
	//speed, jug, cherry
	self.eng_perk_poi = [];

	self.eng_trap_activate_poi = array(
		//(-825, -943, 130)			//2
		//,(933, 1646, 36)			//1
		//,(-1626, 1241, 220)		//4 electric upstairs (-1691, 1627, 220) alt upstairs
	);

	self.eng_trap_death_poi = array( 
		(-962,-619,75)		//fire trap stamina
		,(997,1535,-13)		//electric trap stage
		,(-1567,1341,174)		//electric upstairs
	);

	traps = GetEntArray( "zombie_trap", "targetname" );
	//iprintln( "print traps " + traps.size );
	//maps\_zombiemode_traps::print_traps( traps );

	allTraps = get_trap_objects( traps );
	valid_eng_trap_indices = array( 2, 1, 5 );
	//iprintln("All traps size" + allTraps.size );
	self.eng_trap_activate_poi = [];
	    self.eng_trap_activate_poi[0]  = allTraps[2]; //fire trap stamina
		self.eng_trap_activate_poi[1]  = allTraps[1]; //electric trap stage
		self.eng_trap_activate_poi[2]  = allTraps[5]; //electric upstairs

	
	allPerks = GetEntArray("zombie_vending", "targetname");
	for( i = 0; i < allPerks.size; i++ ) {
		//iprintln( "print perk " + allPerks[i].script_noteworthy + " | " + allPerks[i].origin );
	}
	
	self.eng_perk_poi = [];

			jug = SpawnStruct();
			jug.index = 0;
			jug.origin = (-323, -480, 22);
			jug.modelIndex = 0;
			jug.powerupColor = level._effect["powerup_on_red"];
			jug.script_noteworthy = level.JUG_PRK;
		self.eng_perk_poi[0] = jug;

			speed = SpawnStruct();
			speed.index = 1;
			speed.origin = (1281, 168, -6);
			speed.script_noteworthy = level.SPD_PRK;
			speed.powerupColor = level._effect["powerup_on"];
			speed.modelIndex = 2;
		self.eng_perk_poi[1] = speed;

			cherry = SpawnStruct();
			cherry.index = 2;
			cherry.origin = (-1215, 1168, 180);
			cherry.script_noteworthy = level.ECH_PRK;
			cherry.powerupColor = level._effect["powerup_on_solo"];
			cherry.modelIndex = 8;
		self.eng_perk_poi[2] = cherry;
		
	//iprintln( "print perks " + allPerks.size );

}

	get_trap_objects( arr )
	{
		mapObjects = [];
		k = 0;
		for( i = 0; i < arr.size; i++ )
		{
			if( isDefined( arr[i].target ) )
			{
				components = GetEntArray( arr[i].target, "targetname" );
				for( j = 0; j < components.size; j++ )
				{
					if( components[j].classname == "trigger_use" )
					{
						mapObjects[k] = components[j];
						k++;
					}
				}
			}
		}

		return mapObjects;
	}



eng_attack_properties() 
{

	//basic properties
	self.trap_damage = 50000;
	self.enraged_time = undefined; 		//tracks when engineer was enraged
	self.time_to_live = 60; //60				//number of seconds before engineer dies
	self.empowered_time_to_live = 120;	//120	//number of seconds before enraged engineer dies
	self.damaged_by_trap = undefined; 	//tracks which traps damaged engineer

	self.eng_near_perk_threshold = 200; //distance from perk to trigger enrage
	self.eng_near_trap_threshold = 100; //distance from trap to trigger it
	self.player_lookat_threshold = 1.0; //number of seconds player can look at engineer before enraging him


	self maps\_zombiemode_spawner::zombie_setup_attack_properties();
	self.run_combatanim = level.scr_anim["boss_zombie"]["sprint1"];
	self PushPlayer( false );
	self.animplaybackrate = 1;
	self.pathEnemyFightDist = 80;
	self.meleeAttackDist = 80;

	self.script_noteworthy = "find_flesh";
	self.script_moveoverride = false; //spawners will go before fighting
	//self.deathAnim = %ai_zombie_boss_death_a;

	self.activated = false; //variable tracks when he's enraged
	self.performing_activation = false; //variable tracks when he's performing activation
	self.ground_hit = false; //variable tracks when he's performing ground hit
	//self.marked_for_death = true; //makes eng immune to traps, also makes him not attack
	self.eng_perks = array( "", "", "", "" );

}

/**

	Threaded method loops and occaisionally sets new goal for engineer zombie
	//watch_eng_goals
**/
watch_eng_goals()
{
	i = 0;
	level.valid_eng_states = array( "trap", "perk", "attack", "enrage", "death" );

	self.state = "trap";
	//self.state = "enrage";
	//self.state = "attack";
	//self.state = "perk";

	//fire trap, electric trap, electric upstairs
	self.trapTargetIndex = randomInt( self.eng_trap_activate_poi.size );
	self.perkTargetIndex = randomInt(3);
	
	if( is_true(level.dev_only)) {
		self.perkTargetIndex = 0; //jug=0, speed=1, cherry=2
		self.trapTargetIndex = 2; //fire trap = 0, electric trap = 1, electric upstairs = 2
	}
	//iprintln(" Targeting perk: " + self.eng_perk_poi[self.perkTargetIndex].script_noteworthy );

	self thread eng_watch_teleport_triggers();

	while( IsAlive(self) )
	{
		//self maps\_zombiemode_spawner::set_zombie_run_cycle("walk");
		//iprintln( "Enge choose new goal: " + self.state );
		self notify( "choose_new_goal" );

		//1. Target POI
		if( self.state == "trap") 
		{
			//iprintln("0");
			self thread eng_watch_trigger_enrage(true, true);
			self eng_target_poi();

		} else if( self.state == "perk" ) {
			//iprintln("1");
			if(!self.activated)
				self thread eng_watch_trigger_enrage(true, false);
			self eng_target_poi();

		} else if( self.state == "attack" ) {
			//iprintln("2");
			self eng_execute_attack();

		} else if( self.state == "enrage" ) {
			//iprintln("3");
			self eng_execute_enrage();

		} else if( self.state == "teleport" ) {
			//iprintln("4");
			self eng_tp_death();
			break;
		}

		wait(0.05);
	}

	if(isDefined( self.powerup_fx ) )
		self.powerup_fx delete();
	

}

checkDist(a, b, distance ) {
	return maps\_zombiemode::checkDist( a, b, distance );
}

/*
	Eng is enraged on 3 different events
	1. Player looks at engineer too long
	2. Player damages engineer
	3. Engineer spontaneously drinks perk

*/
eng_watch_trigger_enrage(trackEyes, trackPerk)
{
	self endon("death");
	self endon("choose_new_goal");
	//trackEyes = false;

	players = get_players();
	for (i = 0; i < players.size; i++) {
		if(trackEyes)
			players[i] thread eng_track_player_eyes( self );
	}

	if(trackPerk)
		self thread eng_watch_near_perk();


	self thread eng_amb_vocals();

	self waittill("activated");
	self.state = "enrage";
}

	//self is player
	//watch_eyes, track_eyes
	eng_track_player_eyes( eng ) 
	{	
		self endon("death");
		self endon("disconnect");
		eng endon("choose_new_goal");
		eng endon("death");

		//iprintln( "Eng: Tracking player eyes" );
		face_dot = 0.9;
		while(!eng.activated) 
		{
			eng_face = eng.origin + (0,0,40);
			self waittill_player_looking_at( eng_face, face_dot, true);
			count = 0;
			threshold = 10*eng.player_lookat_threshold;

			while( is_player_looking_at( eng_face, face_dot, true ) ) 
			{
				wait(0.1);
				if( count > threshold )
					break;

				eng_face = eng.origin + (0,0,40);
				count++;
			}
			//iprintln("Player stopped looking at eng " + count);
			//iprintln("Player stopped looking at eng thresh " + threshold);
			if( count >= threshold ) {
				eng.favoriteenemy = self;
				eng notify( "activated" );
				break;
			}

			wait(0.05);
				
		}

	}
	
	
	//Play ambient vocals for the guy every few seconds
	eng_amb_vocals()
	{
		self endon("death");
		self endon("choose_new_goal");
		self endon("activated");

		while(IsAlive(self) || is_true(self.useAmbientVocals) ) 
		{
			
			if( randomInt(100) < 5) {
				playsoundatposition( "zmb_engineer_vocals_hit", self.origin );
			} else {
				playsoundatposition( "zmb_engineer_vocals_amb", self.origin );
			}
			
			wait(2);
		}
	}



eng_target_poi() 
{
	
	//here - _TRAP
	poi = undefined;
	randIndex = self.trapTargetIndex;
	if(self.state == "trap") {
		poi = self.eng_trap_activate_poi[ randIndex ];
		poi.death_pos = self.eng_trap_death_poi[ randIndex ];
	} else if(self.state == "perk") {
		poi = self.eng_perk_poi[ self.perkTargetIndex ];
		poi.randIndex = self.perkTargetIndex;
	}
	poi.randIndex = randIndex;
	//iprintln( "Eng: Targeting POI: " + poi.randIndex );

	//Get ready to seek goal
	self notify( "stop_find_flesh" );
	self.poi = undefined;
	self.favoriteenemy = undefined;
	self.ignoreall = true;
	self.ignore_transition=true;
	//self notify( "zombie_acquire_enemy" );
	
	//write a for loop to count to 10
	//iprintln( "Set goal " );
	//iprintln( poi.origin );
	self.goalradius = 60;
	self SetGoalPos( poi.origin );


	//wait
	//here
	notif = self waittill_any_return( "goal", "activated", "perk", "teleport" ,
	 "zombie_start_traverse",  "zombie_end_traverse" );
	//iprintln( "goal reached " + notif ); 

	if( notif == "activated" ) {
		//someone pissed off eng
		self.state = "enrage";
		self SetGoalPos( undefined );
		self ClearGoalVolume();
		return;
	}
	else if( notif == "perk" ) {
		//eng got close to a perk, lets follow that now
		self.state = "perk";
	}
	else if( notif == "teleport" ) {
		//some reason
		self.state = "teleport";
	}
	else if( notif == "goal_interrupted" ) {
		//goal interrupted, reset
		//iprintln( "Goal interrupted, resetting state" );
	}
	else if( notif == "goal" )
	{
		//iprintln( "Goal reached" );
		//iprintln( "Goal reached, state: " + poi.randIndex );
		//Goal Reached
		self.immunity = true;
		if(self.state == "trap") {
			self eng_execute_trap( poi );
		} else if(self.state == "perk") {
			self eng_execute_perk( poi );
		} else {
			//nothing
		}

	} else {
		//Goal Failed
		//iprintln( "Goal undefined or unmatched" );
	}
	
	//iprintln( "Engineer Zombie: Goal reached, state: " + self.state );

}

eng_execute_trap( poi ) 
{

	//1. Do attack anim
	attackAnim = level._zombie_melee["boss_zombie"][0];
	self animscripted( "overhead_attack", self.origin, self.angles, attackAnim );

	//2. wait for anim to finish
	animscripts\traverse\zombie_shared::wait_anim_length( attackAnim, .02 );

	//3. trigger tap, wait to turn on
	//iprintln( "Engineer Zombie: Triggering trap" );
	//iprintln( "Trap: " + poi.randIndex );
	poi notify( "trigger" );

	if(poi.randIndex == 0) {
		self thread boss_fire_death_fx( poi );
	} else {
		self thread boss_shock_death_fx( poi );
	}

	//4. Walk over to Trap
	//iprintln( "Set goal 2" + poi.death_pos );
	self.goalradius = 8;
	self SetGoalPos( poi.death_pos );
	notif = self waittill_any_return( "goal", "goal_interrupted", "activated", "teleport");
	//iprintln( "goal 2 reached " + notif );

	if( notif == "activated" ) {
		self.state = "enrage";
		return;
	}
	if( notif == "teleport" ) {
		self.state = "teleport";
		return;
	}
	else if( notif == "goal_interrupted" ) {
		//goal interrupted, reset
		//iprintln( "Engineer Zombie: Goal interrupted, resetting state" );
	}

	self.immunity = true;

	deathAnim = undefined;
	if( poi.randIndex == 0 ) 
	{  //fire death
		
		enrageAnim = %ai_zombie_boss_enrage_start_scream_coast;
		self animscripted( "enraged", self.origin, self.angles, enrageAnim );
		animscripts\traverse\zombie_shared::wait_anim_length( enrageAnim, 0.02 );
		wait( 0.2 );

		//swing attack
		attackAnim = %ai_zombie_boss_attack_swing_swipe;
		self animscripted( "swing_attack", self.origin, self.angles, attackAnim );
		animscripts\traverse\zombie_shared::wait_anim_length( attackAnim, 0.02 );

		self.deathAnim = %ai_zombie_boss_death_a;

	} else {	//tesla death

		self.deathAnim = %ai_zombie_boss_tesla_death_a_coast;
	}

	self threadAnim( "death", self.deathAnim );

	//iprintln( "Engineer Zombie: Death" );
	//self animscripted( "eng_death", self.origin, self.angles, deathAnim );
	//animscripts\traverse\zombie_shared::wait_anim_length( deathAnim, .02 );

	//self dodamage(self.health + 666, self.origin, undefined);
	self.state = "teleport";

}

	boss_close_to_fx_point( point, dist ) 
	{
		self endon("death" );
		self endon("delete" );
		level endon( "end_game" );

		count = 0;
		while(count < 800) 
		{
			if( checkDist( self.origin, point, dist ) ) {
				return true;
			}

			wait(0.1);
			count++;
		}
		return false;
	}

	boss_fire_death_fx( poi ) 
	{
		closeEnough = self boss_close_to_fx_point( poi.death_pos, 128 );
		if( !closeEnough ) {
			return;
		}

		PlayFxOnTag( level._effect["character_fire_death_sm"], self, "J_SpineLower" );
		PlayFxOnTag( level._effect["character_fire_death_torso"], self, "J_SpineLower" );
		self playsound("evt_zombie_ignite");

		wait(2);
		PlayFxOnTag( level._effect["character_fire_death_sm"], self, "J_SpineLower" );
		PlayFxOnTag( level._effect["character_fire_death_torso"], self, "J_SpineLower" );
		self playsound("evt_zombie_ignite");
	}

	boss_shock_death_fx( poi ) {

		closeEnough = self boss_close_to_fx_point( poi.death_pos, 8 );
		if( !closeEnough ) {
			return;
		}
		
		self maps\_zombiemode_perks::electric_cherry_shock_fx();

		wait(2);
		self maps\_zombiemode_perks::electric_cherry_shock_fx();

	}


/*
	Drinking a perk enrages and strengthens the engineer zombie

*/
eng_execute_perk( poi  ) 
{
	self.immunity = true;
	//self thread magic_bullet_shield();
  
	//1. Do attack anim
	bumpAnim = %ai_zombie_boss_headbutt;
	self thread threadAnim( "perk_bump", bumpAnim );
	//self animscripted( "perk_bump", self.origin, self.angles, bumpAnim );
	//animscripts\traverse\zombie_shared::wait_anim_length( bumpAnim, .02 );
	PlaySoundAtPosition( "fly_bump_bottle", self.origin );
	wait(0.5);
	playsoundatposition("evt_bottle_dispense", self.origin);

	//2. Drink the perk
	//self GiveWeapon( "zombie_perk_bottle", poi.modelIndex );
	//self SwitchToWeapon( "zombie_perk_bottle" );
	//drinkAnim = %p_zombie_perkacola_drink;
	//self animscripted( "perk_drink", self.origin, self.angles, drinkAnim );
	//self TakeWeapon ( "zombie_perk_bottle" );

	//wait(0.5);
	
	//3. Start fx on zombie
		if(isDefined( self.powerup_fx ) )
			self.powerup_fx delete();
		self.powerup_fx = Spawn( "script_model", self GetTagOrigin( "j_SpineUpper" ) );
		self.powerup_fx LinkTo( self, "j_SpineUpper" );
		self.powerup_fx SetModel( "tag_origin" );

	PlayFxOnTag( poi.powerupColor, self.powerup_fx, "tag_origin" );
	self.eng_perks[poi.index] = poi.script_noteworthy;
	self.empowered = true;
	self.perkTargetIndex = undefined;	//or could set to random perk

	//4. Set state to enrage and return
	self.state = "enrage";
	
}

	threadAnim( name, sampleAnim ) 
	{
		self endon( "death" );
		self animscripted( name, self.origin, self.angles, sampleAnim );
		animscripts\traverse\zombie_shared::wait_anim_length( sampleAnim, 0.02 );
		self notify( "anim_done" );
	}

/**


*/
eng_execute_enrage() 
{
	self endon( "death" );
	
	self.performing_activation = true;
	self setgoalpos( undefined );
	self ClearGoalVolume();
	self notify( "stop_find_flesh" );

	//self thread magic_bullet_shield();
	self.activated = true;
	//self eng_calculate_enraged_health();
	//self.a.disablePain = true;
	//self.allowpain = true;
	//self.deathAnim = %ai_zombie_boss_death;
		

	//Play enrage anim
	screamAnim = %ai_zombie_boss_enrage_start_scream_coast;
	//self animscripted( name, self.origin, self.angles, screamAnim );
	playsoundatposition( "zmb_engineer_vocals_hit", self.origin );
	wait(1);
	self thread threadAnim( "scream", screamAnim );
	PlayRumbleOnPosition( "explosion_generic", self.origin );
	self waittill_notify_or_timeout( "anim_done", 1.0 );
	self.performing_activation = false;

	if( isDefined(self.favoriteenemy) ) 
	{
		count = 0;
		//while( count < 40 ) // double check to make sure its hiding and not going to be force to teleport to barriers
  		{
			self.ignore_all_poi = true;
			self.using_teleport = true;
			self notify( "stop_find_flesh" );
			self notify( "teleporting" );
			self hide();
			self unlink();
			self.anchor delete();
			self.first_node = undefined;
			self ClearEnemy();
			self ClearGoalVolume();
			/*
			self.zombie_move_speed = "walk";
			self.zombie_can_sidestep = false;
			self.zombie_can_forwardstep = false;
			self.shouldSideStepFunc = ::no_reaction;

			wait(0.05);
			count++;
			*/
		}

		self ForceTeleport( self.favoriteenemy.origin );
		self.ignore_all_poi = false;
		self.using_teleport = false;

		//3. Start enrage anim while hidden
		self thread eng_groundslam();
		//Play hellhound prespawn sound
		PlaySoundAtPosition( "zmb_hellhound_prespawn", self.origin );
		wait(0.5);
		//Play hellhound bolt
		PlaySoundAtPosition( "zmb_hellhound_bolt", self.origin );
		Playfx( level._effect["poltergeist"], self.origin + (0,0,10) );
		wait(0.1);
		self show();

	}
	else {
		players = array_randomize( get_players() );
		for( i=0; i< players.size; i++ ) {
			if( players[i] maps\_laststand::player_is_in_laststand() )
				continue;
			self.favoriteenemy = players[i];
			break;
		}

		self thread eng_groundslam();			
		wait(1);
	}

	//if( self.zombie_move_speed != "sprint") 
	{
		self.moveplaybackrate = 1.10;
		if( is_in_array( self.eng_perks, level.SPD_PRK ) )
			self.moveplaybackrate = 1.25;

		//iprintln( "Engineer Zombie: Setting run cycle to sprint " + self.zombie_move_speed );
		runAnim = "sprint1";
		if( randomInt(2) > 0 )
			runAnim = "sprint3";
		self.zombie_move_speed = "sprint";
  		self set_run_anim( runAnim );
		self.run_combatanim = level.scr_anim["boss_zombie"][runAnim];
		self.needs_run_update = true;
	}

	
	//self.enemyoverride = self.favoriteenemy;
	self.enraged_time = GetTime();
	self.performing_activation = false;
	self.state = "attack";

	if( !isDefined( self.favoriteenemy ) ) {
		self.state = "teleport";
	}

}

/**
	Function of round, times died, and perks
*/
	eng_calculate_enraged_health()
	{
		if(!isDefined( level.eng_times_died ) )
			level.eng_times_died = 0;

		//Should be like killing 16 zombies
		zombsScale = level.zombie_health*(16 + 4*level.eng_times_died);
		playerScale = 1;
		for( i=0;i < get_players().size; i++ ) {
			playerScale += 0.1;
		}
		//iprintln( "Engineer Zombie: Player scale: " + playerScale );
		//iprintln( "Engineer Zombie: Zombie scale: " + zombsScale );

		baseHealth = level.VALUE_ENGINEER_ZOMBIE_BASE_HEALTH;
		baseHealth += zombsScale;
		baseHealth *= playerScale;

		//iprintln( "Engineer Zombie: Base health: " + baseHealth );

		if( is_in_array( self.eng_perks, level.JUG_PRK ) ) {
			baseHealth *= 2;
		}
		if( is_in_array( self.eng_perks, level.SPD_PRK ) ) {
			baseHealth *= 1.25;
		}
		if( is_in_array( self.eng_perks, level.ECH_PRK ) ) {
			baseHealth *= 1.25;
		}

		//Do damage such the the engineer's remaining health is baseHealth
		if( self.health > baseHealth )
			 self DoDamage( self.health - baseHealth, self.origin, undefined );
		else
			self.health = baseHealth;

		//self.maxHealth = baseHealth;
	}




/**
	1. Engineer chases players relentlessly for 60s or 120s if he has a perk
	2. Attacks player
	3. May stop by perk machine if he doesn't already have one
	4. may activate trap if he runs by it

*/
eng_execute_attack()
{
	self.activated = true;
	self endon( "death" );	

	//start_find_flesh
	self.ignoreall = false;
	//self.ignore_all_poi = false;	engineer just walks whereever
	self.ignore_transition = false;
	self.disableArrivals = true;
	self.disableExits = true;
	self.goalradius = self.pathEnemyFightDist+10;
	faveEnemy = self.favoriteenemy;
	self SetGoalPos( undefined );
	self ClearGoalVolume();
	self ClearEnemy();
	self.favoriteenemy = faveEnemy;

	self eng_calculate_enraged_health();
	//iprintln( "Engineer Zombie: Setting health to " + self.health );
	
  	self notify( "stop_find_flesh" );
  	self notify( "zombie_acquire_enemy" );
  	self notify( "goal" );
	self notify( "zombie_start_traverse" );
	self notify( "zombie_end_traverse" );


	count = 0;
	while( count < 20 )
	{
		self thread maps\_zombiemode_spawner::find_flesh();
		self.following_player = true;
		//self thread maps\_zombiemode_spawner::reset_attack_spot();
		count++;
		wait .1;
	}

	self thread eng_watch_near_trap();
	self thread eng_watch_near_perk();
	self thread eng_watch_time_alive();

	notif = self waittill_any_return( "stop_find_flesh", "perk", "teleport" );
	if( notif == "perk" ) {
		self.state = "perk";
		//iprintln( "Engineer Zombie: Going to perk" );
	} else if( notif == "teleport" ) {
		self.state = "teleport";
		//iprintln( "Engineer Zombie: Going to tp death" );
	}

	//iprintln( "Stopping attack, notif: " + notif );
	self notify( "stop_eng_watcher" );
	//iprintln( "goal radius: " + self.goalradius );
	//iprintln( "goal: " + self.goal.origin );
	//iprintln( "fave enemy: " + self.favoriteenemy GetEntityNumber() );
	//iprintln( "attacking_spot: " + self.attacking_spot );
	//iprintln( "zombie_move_speed: " + self.zombie_move_speed );
}


	//1. Watch if perk is nearby, maybe grab a drink
	eng_watch_near_perk() 
	{
		self endon( "death" );
		self endon("activated");
		self endon("choose_new_goal");
		self endon( "stop_eng_watcher" );

		if(!isDefined( self.perkTargetIndex ) )
			return;

		perk = self.eng_perk_poi[ self.perkTargetIndex ];
		while(1) 
		{
			if( !IsDefined( perk ) || !isDefined( perk.origin ) )
				break;

			if( checkDist( self.origin, perk.origin, self.eng_near_perk_threshold ) ) {
				//iprintln( "Engineer Zombie: Close to perk, attempting to drink" );
				self notify( "perk" );
				break;
			}
			wait(0.05);
		}
	}

	eng_watch_near_trap() 
	{
		self endon( "death" );
		self endon( "stop_eng_watcher" );

		allTraps = get_trap_objects( GetEntArray( "zombie_trap", "targetname" ) );
		trap = undefined;
		i = 0;
	
		blackListedTrap = undefined;
		while( IsAlive(self) ) 
		{
			wait(0.05);
			for(i = 0; i < allTraps.size; i++ ) 
			{
				if( !IsDefined( allTraps[i] ) || !isDefined( allTraps[i].origin ) )
					continue;
				trap = allTraps[i];
			
				if( checkDist( self.origin, trap.origin, self.eng_near_trap_threshold ) ) 
				{
					if( isdefined(blackListedTrap) && trap.targetname == blackListedTrap )
						continue;

					if( is_true(trap._trap_in_use) )
						continue;

					if( randomInt(100) < 10 ) 
					{
						wait(0.05);
						self eng_groundslam();
						trap notify( "trigger" );
						blackListedTrap = trap.targetname;


					//play fx on boss as he runs through trap
					if( isDefined( trap ) && isDefined( trap.targetname ) )
					{
						if(trap.targetname == "crematorium_room_trap" ) //crema fire trap
						{
							self.death_pos = self.eng_trap_death_poi[0];
							self boss_fire_death_fx(self);
						} else {
							self.death_pos = self.origin;
							self boss_shock_death_fx(self);
						}
					}

					}
					else {
						blackListedTrap = trap.targetname;
						continue;
					}
				}
			}

		}

		//self notify( "stop_find_flesh" );
	}

	eng_watch_time_alive() 
	{
		self endon( "death" );
		self endon( "stop_eng_watcher" );
		self endon( "choose_new_goal" );

		enragedTimeToLive = self.time_to_live;
		if( is_true( self.empowered ) )
			enragedTimeToLive = self.empowered_time_to_live;

		if( !isDefined( self.enraged_time ) )
			return;
		enragedTime = self.enraged_time;
		while( isDefined(self) && IsAlive(self) && !is_true(self.was_slain) )
		{
			//iprintln( "Get Time: " + GetTime() );
			//iprintln( "Enraged Time: " + self.enraged_time );
			//iprintln( "diff: " + (GetTime() - self.enraged_time) );
			if( (GetTime() - enragedTime) >= (enragedTimeToLive * 1000) ) 
			{
				//iprintln( "Time to live expired, going to death state" );
				self notify( "teleport" );
				break;
			}

			wait(1);
		}
	}

	eng_watch_teleport_triggers() 
	{
		self endon( "death" );

		while( IsAlive(self) ) 
		{
			notif = self waittill_any_return( "player_downed", "nuke_triggered", "teleporter_used" );
			
			//if notif is nuke drop or teleporter_used, go to teleport state
			if( notif == "nuke_triggered" || notif == "teleporter_used" ) 
			{
				//iprintln( "nuke drop or tp used" );
				self.was_slain = false;
				self notify( "teleport" );
				break;
			}
			else if( notif == "player_downed" )
			{
				playerDowned = level.lastPlayerDowned;
				//iprintln( "num " + playerDowned.entity_num );
				if(!IsDefined( self.favoriteenemy ) || (!IsDefined( level.lastPlayerDowned ) ))
					continue;

				if( playerDowned.entity_num == self.favoriteenemy.entity_num ) 
				{
					self notify( "teleport" );
					break;
				}
				break;
			}

			wait(0.05);
		}
	}

	//maps\_zombiemode_ai_director::player_electrify() for eCherry hits

	eng_groundslam() 
	{	
		self.ground_hit = true;
		enrageAnim = %ai_zombie_boss_enrage_start_slamground_coast;
		self thread threadAnim( "enraged", enrageAnim );
		wait(.5);
		playsoundatposition( "zmb_engineer_vocals_hit", self.origin );
		wait(.5);
		//electric groundslam fx (magnitude, time, origin, radius)
		Earthquake( 1.2, 1.5, self.origin, 1000 );
		PlayRumbleOnPosition( "explosion_generic", self.origin );
		fxTarget = self.origin - (0,0,10);
		Playfx( level._effect["fx_zombie_boss_grnd_hit"], fxTarget );
		wait(0.3);
		PlaySoundAtPosition( "zmb_engineer_groundbang", self.origin );
		PlayRumbleOnPosition( "explosion_generic", self.origin );
		Playfx( level._effect["fx_transporter_start"], self.origin );
		/*
		Playfx( level._effect["fx_teleporter_pad_glow"], target );

  		//play boss spawn ground
  		Playfx( level._effect["fx_zombie_boss_spawn_ground"], target );
  		Playfx( level._effect["fx_zombie_boss_spawn"], target );
		*/


		//for players in area, shellshock their screen
		players = get_players();
		for( i = 0; i < players.size; i++ ) {
			if( checkDist( players[i].origin, self.origin, 300 ) ) {
				players[i] thread shellShockPlayer();
			}
		}

		//for players too close deal damage
		players = get_players();
		damage = self.meleeDamage;
		for( i = 0; i < players.size; i++ ) {
			if( checkDist( players[i].origin, self.origin, 100 )
			 	&& !players[i] maps\_laststand::player_is_in_laststand() 
				&& players[i].sessionstate != "spectator") {
				radiusdamage(players[i].origin + (0, 0, 5), 10, damage, damage, undefined, "MOD_UNKNOWN");
			}
		}

		wait(0.5);
		//screenShake
		//Earthquake( 0.5, 0.75, self.origin, 1000 );
		//PlayRumbleOnPosition( "explosion_generic", self.origin );

		self.ground_hit = false;
		self notify( "groundslam_done" );
	}

		shellShockPlayer() 
		{
			self shellshock( "explosion", 1.1 );
			self SetMoveSpeedScale( 0.1 );
			wait(.75);
			self SetMoveSpeedScale( 0.6 );
			wait(.25);
			if(!IsDefined(self.move_speed))
				self.move_speed = 1;

			self SetMoveSpeedScale( self.move_speed );
		}

		electroShellShockPlayer() 
		{
			//SetTransported( 2 );
			self setelectrified(1.5);
			self shellshock( "electrocution", 1.5 );
			self SetMoveSpeedScale( 0.3 );
			wait(1.0);
			self SetMoveSpeedScale( 0.6 );
			wait(.25);
			if(!IsDefined(self.move_speed))
				self.move_speed = 1;

			self SetMoveSpeedScale( self.move_speed );
		}

/*
	Eng teleports away just before he dies
*/
eng_tp_death() 
{
	//iprintln( "Engineer Zombie: Teleporting away" );
	/*
	self disable_react();
	self.a.disablePain = true;
  	self.allowpain = false;
  	self.no_damage_points = true;
	self thread magic_bullet_shield();
	*/


	//1. thread scream anim, no groudhit
	self notify( "stop_find_flesh" );
	self.ignoreall = true;  	
	self.ignore_all_poi = true;
	self ClearEnemy();
    self ClearGoalVolume();

	{
		//1.5 get him walkinging then stop
		runAnim = "walk1";
		self.needs_run_update = true;
		self.zombie_move_speed = "walk";
		self set_run_anim( runAnim );
		self.run_combatanim = level.scr_anim["boss_zombie"][runAnim];
		self.needs_run_update = false;
		playsoundatposition( "zmb_engineer_vocals_hit", self.origin );

		screamAnim = %ai_zombie_boss_enrage_start_scream_coast;
		//self animscripted( name, self.origin, self.angles, screamAnim );
		self thread threadAnim( "scream", screamAnim );
		PlayRumbleOnPosition( "explosion_generic", self.origin );
		//playsoundatposition( "zmb_hellhound_spawn", self.origin );
		
		//playsoundatposition( "zmb_hellhound_spawn", self.origin );
		//wait(0.5);

		if( is_true(self.was_slain) ) 
		{
			self waittill( "anim_done" );
			deathAnim = %ai_zombie_boss_death;
			self thread threadAnim( "death", deathAnim );
		} else {
			//wait(0.5);
			self.goal = undefined;
		}
	}

	wait(0.2);

	//Playfx( level._effect["poltergeist"], self.origin );
	Playfx( level._effect["fx_zombie_mainframe_flat_start"], self.origin );
	//Playfx( level._effect["fx_teleporter_pad_glow"], self.origin );
	Playfx( level._effect["fx_transporter_start"], self.origin );
	Playfx( level._effect["fx_zombie_mainframe_beam"], self.origin );
	Playfx( level._effect["fx_zombie_mainframe_flat"], self.origin );	
	
	Earthquake( 0.5, 0.75, self.origin, 1000 );
	PlayRumbleOnPosition( "explosion_generic", self.origin );
	playsoundatposition( "zmb_hellhound_spawn", self.origin );
	playsoundatposition( "zmb_hellhound_bolt", self.origin );

	wait(0.4);

	//3. hide model, kill, delete
	death_pos = self.origin;
	if( isDefined(self.powerup_fx) ) {
		self.powerup_fx delete();
	}
	
	self hide();
	//self stop_magic_bullet_shield();
	//self.a.disablePain = false;
  	//self.allowpain = true;
  	//self.no_damage_points = false;

	//Name: DoDamage( <health>, <source position>, <attacker>, <destructible_piece_index>, <means of death>, <hitloc> )
	self dodamage(self.maxHealth + 666, self.origin, undefined );
	self notify( "death" );
	wait(0.1);
	self delete();
}

/*
eng_custom_damage( player )
{
  if( !isDefined( player.stunned_by_eng ) )
  {
    player thread eng_player_stunned( 1 );
  }
  return self.meleeDamage;
}

eng_player_stunned( stunned_time )
{
	self.stunned_by_eng = true;

	self shellshock( "death", stunned_time );

	wait stunned_time;

  	self stopShellShock();

	self.stunned_by_eng = undefined;
}

eng_enrage_think()
{
	self endon( "death" );
	
	amount_of_dmg_to_rage = 100; // default
	current_dmg = 0;
	
	if( level.round_number <= 15 )
	{
		amount_of_dmg_to_rage = 500;
	}
	else if( level.round_number > 15 )
	{
		amount_of_dmg_to_rage = 250;
	}
	
	while( current_dmg < amount_of_dmg_to_rage )
	{
		self waittill( "damage", amount );
		
		current_dmg += amount;
	}
	
	self animscripted( "enraged", self.origin, self.angles, level.scr_anim["boss_zombie"]["enrage"] );
	self.run_combatanim = level.scr_anim["boss_zombie"]["sprint"+randomintrange( 1, 3 )];
	self.zombie_move_speed = "sprint";
	self.moveplaybackrate = 1.25;
	
	wait 1;
	
	earthquake(0.7,2,self.origin,500);
}

heavy_zombie_dmg_function( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, modelIndex, psOffsetTime )
{
	self endon( "death" );
	
	 if( meansofdeath == "MOD_MELEE" )
	{
		return damage*.15;
	}
	
	if( meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_EXPLOSIVE" || meansofdeath == "MOD_PROJECTILE" || meansofdeath == "MOD_PROJECTILE_SPLASH" )
	{
		return damage*.25;
	}
	
	if( ( sHitLoc == "head" || sHitLoc == "neck" ) && meansofdeath != "MOD_PISTOL_BULLET" )
	{
		return damage*3;
	}
	
	if( self.animname == "boss_zombie" )
	{
		damage *= .70;
	}
	else
	{
		damage *= .45;
	}
	

	return damage;
}

*/
no_reaction( player )
{
  // nothing
}

init_boss_zombie_fx()
{
	level._effect["fx_zombie_boss_footstep"] = loadfx( "fx_zombie_boss_footstep" );
	/*
	fx,misc/fx_zombie_powerup_on_red
	fx,fx_zombie_boss_footstep
	fx,fx_zombie_boss_grnd_hit
	fx,fx_zombie_boss_spawn
	fx,fx_zombie_boss_spawn_buildup
	fx,fx_zombie_boss_spawn_ground
	*/
	level._effect["fx_zombie_boss_grnd_hit"] = loadfx( "maps/zombie/fx_zombie_boss_grnd_hit" );
	level._effect["fx_zombie_boss_spawn"] = loadfx( "maps/zombie/fx_zombie_boss_spawn" );
	level._effect["fx_zombie_boss_spawn_buildup"] = loadfx( "maps/zombie/fx_zombie_boss_spawn_buildup" );
	level._effect["fx_zombie_boss_spawn_ground"] = loadfx( "maps/zombie/fx_zombie_boss_spawn_ground" );
}

boss_zombie_idle_setup()
{
	self.a.array["turn_left_45"] = %exposed_tracking_turn45L;
	self.a.array["turn_left_90"] = %exposed_tracking_turn90L;
	self.a.array["turn_left_135"] = %exposed_tracking_turn135L;
	self.a.array["turn_left_180"] = %exposed_tracking_turn180L;
	self.a.array["turn_right_45"] = %exposed_tracking_turn45R;
	self.a.array["turn_right_90"] = %exposed_tracking_turn90R;
	self.a.array["turn_right_135"] = %exposed_tracking_turn135R;
	self.a.array["turn_right_180"] = %exposed_tracking_turn180L;
	self.a.array["exposed_idle"] = array( %ai_zombie_boss_idle_a, %ai_zombie_boss_idle_b );
	self.a.array["straight_level"] = %ai_zombie_boss_idle_a;
	self.a.array["stand_2_crouch"] = %ai_zombie_shot_leg_right_2_crawl;
}


init_boss_zombie_anims()
{
	level.scr_anim["boss_zombie"]["death1"] 	= %ai_zombie_boss_death;
	level.scr_anim["boss_zombie"]["death2"] 	= %ai_zombie_boss_death_a;
	level.scr_anim["boss_zombie"]["death3"] 	= %ai_zombie_boss_death_explode;
	level.scr_anim["boss_zombie"]["death4"] 	= %ai_zombie_boss_death_mg;
	
	
	level.scr_anim["boss_zombie"]["walk1"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk2"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk3"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk4"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk5"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk6"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk7"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk8"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["walk9"] 	= %ai_zombie_boss_walk_a;

	/*
	level.scr_anim["boss_zombie"]["run1"] 	= %ai_zombie_walk_fast_v1;
	level.scr_anim["boss_zombie"]["run2"] 	= %ai_zombie_walk_fast_v2;
	level.scr_anim["boss_zombie"]["run3"] 	= %ai_zombie_walk_fast_v3;
	level.scr_anim["boss_zombie"]["run4"] 	= %ai_zombie_run_v2;
	level.scr_anim["boss_zombie"]["run5"] 	= %ai_zombie_run_v4;
	level.scr_anim["boss_zombie"]["run6"] 	= %ai_zombie_run_v3;
	level.scr_anim["boss_zombie"]["sprint1"] = %ai_zombie_boss_sprint_a;
	level.scr_anim["boss_zombie"]["sprint2"] = %ai_zombie_boss_sprint_a;
	level.scr_anim["boss_zombie"]["sprint3"] = %ai_zombie_boss_sprint_b;
	level.scr_anim["boss_zombie"]["sprint4"] = %ai_zombie_boss_sprint_b;
	*/
	level.scr_anim["boss_zombie"]["run1"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run2"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run3"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run4"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run5"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run6"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run7"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["run8"] 	= %ai_zombie_boss_walk_a;
	level.scr_anim["boss_zombie"]["sprint1"] = %ai_zombie_boss_sprint_a;
	level.scr_anim["boss_zombie"]["sprint2"] = %ai_zombie_boss_sprint_a;
	level.scr_anim["boss_zombie"]["sprint3"] = %ai_zombie_boss_sprint_b;
	level.scr_anim["boss_zombie"]["sprint4"] = %ai_zombie_boss_sprint_b;
	level.scr_anim["boss_zombie"]["sprint5"] = %ai_zombie_boss_sprint_b;
	
	level.scr_anim["boss_zombie"]["crawl1"] 	= %ai_zombie_crawl;
	level.scr_anim["boss_zombie"]["crawl2"] 	= %ai_zombie_crawl_v1;
	level.scr_anim["boss_zombie"]["crawl3"] 	= %ai_zombie_crawl_v2;
	level.scr_anim["boss_zombie"]["crawl4"] 	= %ai_zombie_crawl_v3;
	level.scr_anim["boss_zombie"]["crawl5"] 	= %ai_zombie_crawl_v4;
	level.scr_anim["boss_zombie"]["crawl6"] 	= %ai_zombie_crawl_v5;
	level.scr_anim["boss_zombie"]["crawl_hand_1"] = %ai_zombie_walk_on_hands_a;
	level.scr_anim["boss_zombie"]["crawl_hand_2"] = %ai_zombie_walk_on_hands_b;
	level.scr_anim["boss_zombie"]["crawl_sprint1"] 	= %ai_zombie_crawl_sprint;
	level.scr_anim["boss_zombie"]["crawl_sprint2"] 	= %ai_zombie_crawl_sprint_1;
	level.scr_anim["boss_zombie"]["crawl_sprint3"] 	= %ai_zombie_crawl_sprint_2;
	if( !isDefined( level._zombie_melee ) )
	{
		level._zombie_melee = [];
	}
	if( !isDefined( level._zombie_walk_melee ) )
	{
		level._zombie_walk_melee = [];
	}
	if( !isDefined( level._zombie_run_melee ) )
	{
		level._zombie_run_melee = [];
	}
	level._zombie_melee["boss_zombie"] = [];
	level._zombie_walk_melee["boss_zombie"] = [];
	level._zombie_run_melee["boss_zombie"] = [];
	/*
	level._zombie_melee["boss_zombie"][0] 				= %ai_zombie_boss_attack_multiswing_a; 
	level._zombie_melee["boss_zombie"][1] 				= %ai_zombie_boss_attack_multiswing_b; 
	level._zombie_melee["boss_zombie"][2] 				= %ai_zombie_boss_attack_swing_overhead; 
	level._zombie_melee["boss_zombie"][3] 				= %ai_zombie_boss_attack_swing_swipe;	
	level._zombie_melee["boss_zombie"][4] 				= %ai_zombie_boss_headbutt;	
	*/
	level._zombie_melee["boss_zombie"][0] 				= %ai_zombie_boss_attack_swing_overhead; 
	level._zombie_melee["boss_zombie"][1] 				= %ai_zombie_boss_attack_swing_swipe;	
	level._zombie_melee["boss_zombie"][2] 				= %ai_zombie_boss_attack_swing_overhead;
	level._zombie_melee["boss_zombie"][3] 				= %ai_zombie_boss_attack_swing_swipe;	
	level._zombie_melee["boss_zombie"][4] 				= %ai_zombie_boss_attack_swing_swipe;	
	level._zombie_melee["boss_zombie"][5] 				= %ai_zombie_boss_attack_swing_swipe;

	level._zombie_walk_melee["boss_zombie"][0]				= %ai_zombie_boss_attack_swing_overhead;
	level._zombie_walk_melee["boss_zombie"][1]				= %ai_zombie_boss_attack_swing_swipe;
	level._zombie_walk_melee["boss_zombie"][2]				= %ai_zombie_boss_attack_swing_overhead;
	level._zombie_walk_melee["boss_zombie"][3]				= %ai_zombie_boss_attack_swing_swipe;
	
	if( isDefined( level.boss_zombie_anim_override ) )
	{
		[[ level.boss_zombie_anim_override ]]();
	}
	
	level._zombie_run_melee["boss_zombie"][0]				=	%ai_zombie_boss_attack_running;
	level._zombie_run_melee["boss_zombie"][1]				=	%ai_zombie_boss_attack_sprinting;
	level._zombie_run_melee["boss_zombie"][2]				=	%ai_zombie_boss_attack_running;
	level._zombie_run_melee["boss_zombie"][3]				=	%ai_zombie_boss_attack_running;
	level._zombie_run_melee["boss_zombie"][4]				=	%ai_zombie_boss_attack_running;
	level._zombie_run_melee["boss_zombie"][5]				=	%ai_zombie_boss_attack_running;

	level._zombie_sprint_melee["boss_zombie"][0]			=	%ai_zombie_boss_attack_sprinting;
	level._zombie_sprint_melee["boss_zombie"][1]			=	%ai_zombie_boss_attack_sprinting;
	level._zombie_sprint_melee["boss_zombie"][2]			=	%ai_zombie_boss_attack_sprinting;
	level._zombie_sprint_melee["boss_zombie"][3]			=	%ai_zombie_boss_attack_sprinting;
	level._zombie_sprint_melee["boss_zombie"][4]			=	%ai_zombie_boss_attack_sprinting;
	level._zombie_sprint_melee["boss_zombie"][5]			=	%ai_zombie_boss_attack_sprinting;



	
	if( !isDefined( level._zombie_melee_crawl ) )
	{
		level._zombie_melee_crawl = [];
	}
	level._zombie_melee_crawl["boss_zombie"] = [];
	level._zombie_melee_crawl["boss_zombie"][0] 		= %ai_zombie_attack_crawl; 
	level._zombie_melee_crawl["boss_zombie"][1] 		= %ai_zombie_attack_crawl_lunge;
	if( !isDefined( level._zombie_stumpy_melee ) )
	{
		level._zombie_stumpy_melee = [];
	}
	level._zombie_stumpy_melee["boss_zombie"] = [];
	level._boss_zombie_stumpy_melee["boss_zombie"][0] = %ai_zombie_walk_on_hands_shot_a;
	level._boss_zombie_stumpy_melee["boss_zombie"][1] = %ai_zombie_walk_on_hands_shot_b;
	
	if( !isDefined( level._zombie_tesla_deaths ) )
	{
		level._zombie_tesla_deaths = [];
	}
	level._zombie_tesla_death["boss_zombie"] = [];
	level._zombie_tesla_death["boss_zombie"][0] = %ai_zombie_boss_tesla_death_a;
	level._zombie_tesla_death["boss_zombie"][1] = %ai_zombie_boss_tesla_death_a;
	level._zombie_tesla_death["boss_zombie"][2] = %ai_zombie_boss_tesla_death_a;
	level._zombie_tesla_death["boss_zombie"][3] = %ai_zombie_boss_tesla_death_a;
	level._zombie_tesla_death["boss_zombie"][4] = %ai_zombie_boss_tesla_death_a;
	if( !isDefined( level._zombie_tesla_crawl_death ) )
	{
		level._zombie_tesla_crawl_death = [];
	}
	level._zombie_tesla_crawl_death["boss_zombie"] = [];
	level._zombie_tesla_crawl_death["boss_zombie"][0] = %ai_zombie_tesla_crawl_death_a;
	level._zombie_tesla_crawl_death["boss_zombie"][1] = %ai_zombie_tesla_crawl_death_b;
	
	if( !isDefined( level._zombie_deaths ) )
	{
		level._zombie_deaths = [];
	}
	level._zombie_deaths["boss_zombie"] = [];
	level._zombie_deaths["boss_zombie"][0] = %ai_zombie_boss_death;
	level._zombie_deaths["boss_zombie"][1] = %ai_zombie_boss_death_a;
	level._zombie_deaths["boss_zombie"][2] = %ai_zombie_boss_death_explode;
	level._zombie_deaths["boss_zombie"][3] = %ai_zombie_boss_death_mg;
	
	
	if( !isDefined( level._zombie_rise_anims ) )
	{
		level._zombie_rise_anims = [];
	}
	level._zombie_rise_anims["boss_zombie"] = [];
	level._zombie_rise_anims["boss_zombie"][1]["walk"][0]		= %ai_zombie_traverse_ground_v1_walk;
	level._zombie_rise_anims["boss_zombie"][1]["run"][0]		= %ai_zombie_traverse_ground_v1_run;
	level._zombie_rise_anims["boss_zombie"][1]["sprint"][0]	= %ai_zombie_traverse_ground_climbout_fast;
	level._zombie_rise_anims["boss_zombie"][2]["walk"][0]		= %ai_zombie_traverse_ground_v2_walk_altA;
	
	if( !isDefined( level._zombie_rise_death_anims ) )
	{
		level._zombie_rise_death_anims = [];
	}
	level._zombie_rise_death_anims["boss_zombie"] = [];
	level._zombie_rise_death_anims["boss_zombie"][1]["in"][0]		= %ai_zombie_traverse_ground_v1_deathinside;
	level._zombie_rise_death_anims["boss_zombie"][1]["in"][1]		= %ai_zombie_traverse_ground_v1_deathinside_alt;
	level._zombie_rise_death_anims["boss_zombie"][1]["out"][0]		= %ai_zombie_traverse_ground_v1_deathoutside;
	level._zombie_rise_death_anims["boss_zombie"][1]["out"][1]		= %ai_zombie_traverse_ground_v1_deathoutside_alt;
	level._zombie_rise_death_anims["boss_zombie"][2]["in"][0]		= %ai_zombie_traverse_ground_v2_death_low;
	level._zombie_rise_death_anims["boss_zombie"][2]["in"][1]		= %ai_zombie_traverse_ground_v2_death_low_alt;
	level._zombie_rise_death_anims["boss_zombie"][2]["out"][0]		= %ai_zombie_traverse_ground_v2_death_high;
	level._zombie_rise_death_anims["boss_zombie"][2]["out"][1]		= %ai_zombie_traverse_ground_v2_death_high_alt;
	
	
	if( !isDefined( level._zombie_run_taunt ) )
	{
		level._zombie_run_taunt = [];
	}
	if( !isDefined( level._zombie_board_taunt ) )
	{
		level._zombie_board_taunt = [];
	}
	
	level._zombie_run_taunt["boss_zombie"] = [];
	level._zombie_board_taunt["boss_zombie"] = [];
	
	level._zombie_board_taunt["boss_zombie"][0] = %ai_zombie_taunts_4;
	level._zombie_board_taunt["boss_zombie"][1] = %ai_zombie_taunts_7;
	level._zombie_board_taunt["boss_zombie"][2] = %ai_zombie_taunts_9;
	level._zombie_board_taunt["boss_zombie"][3] = %ai_zombie_taunts_5b;
	level._zombie_board_taunt["boss_zombie"][4] = %ai_zombie_taunts_5c;
	level._zombie_board_taunt["boss_zombie"][5] = %ai_zombie_taunts_5d;
	level._zombie_board_taunt["boss_zombie"][6] = %ai_zombie_taunts_5e;
	level._zombie_board_taunt["boss_zombie"][7] = %ai_zombie_taunts_5f;
}


/**
	Entry thread called on level from zombie_theater
	initializes all boss_zombie aspects

*/
init_boss_zombie()
{
	init_boss_zombie_anims();
	init_boss_zombie_fx();
	

	level thread boss_zombie_manager();
}

/*
	Manges boss zombie spawning
	- power must be on
	- all doors except 1 must be open
	- spawns every 3 rounds
	- spawn is guaranteed round after tp is used

*/
boss_zombie_manager()
{
	level endon("end_game");

	//Preconditions
	flag_wait("power_on");
	//iprintln( "Engineer Zombie: Power is on" );
	wait_doors_open();
	//iprintln( "Engineer Zombie: Doors are open" );

	level.theater_rounds_until_boss = level.VALUE_ENGINEER_ZOMBIE_SPAWN_ROUNDS_PER_SPAWN;
	if( is_true(level.dev_only)) {
		level.theater_rounds_until_boss = 0;
	}
	level thread watch_teleporter();
	while(1)
	{
		level waittill( "start_of_round" );

		//if dog round, continue
		if( is_true(flag("dog_round")) )
			continue;

		//iprintln( "Engineer Zombie: Round start, checking for boss spawn " + level.theater_rounds_until_boss );
		if( level.theater_rounds_until_boss <= 0 ) {
			level thread watch_eng_spawn();
			level.theater_rounds_until_boss = level.VALUE_ENGINEER_ZOMBIE_SPAWN_ROUNDS_PER_SPAWN;
		}	

		level waittill( "end_of_round" );

		level.theater_rounds_until_boss--;	
	}

}

	wait_doors_open()
	{
		if(is_true(level.dev_only))
			return;

		while(true)
		{
			zkeys = GetArrayKeys( level.zones );

			zonesClosed = 0;
			for( z=0; z<zkeys.size; z++ )
			{
				zone = level.zones[ zkeys[z] ];
				if ( zone.is_enabled )
					continue;

				zonesClosed++;	
			}

			if( zonesClosed < 1 )
				break;

			wait(2);
		}
	}

	watch_eng_spawn()
	{
		//iprintln( "Engineer Zombie: Watching for spawn" );

		if( !IsDefined(level.theater_last_boss_round) ) {
			level.theater_last_boss_round = level.round_number;
		} else if( level.round_number - level.theater_last_boss_round < 1 ) {
			//iprintln( "Engineer Zombie: Spawn too soon, waiting" );
			return;
		} else if ( isDefined(level.currentEngineer) ) {
			//iprintln( "Engineer Zombie: Already spawned, waiting" );
			return;
		}
		 

		//1. Bells toll to indicate eng is coming
		for(i=0;i< level.enemy_spawns.size; i++) {
			//iprintln("Enemy spawn origin: " + level.enemy_spawns[i].origin);
			level.enemy_spawns[i] playsound( "zmb_engineer_spawn" );
			//sound_origin playsound( "zmb_elec_start" );
			//playsoundatposition( "evt_beam_fx_2d", (0,0,0) );
	    	//here
		}
		//chosenSpawner playsound( "zmb_engineer_death_bells" );	//Doesn't work

		spawnPos = SpawnStruct();
		spawnCounts = level.ARRAY_ENGINEER_SPAWN_LOCS.size;
		spawnPos.origin = level.ARRAY_ENGINEER_SPAWN_LOCS[randomInt(spawnCounts)];
		if(is_true(level.dev_only)) {
			spawnPos.origin = (-1317, 112, 5); //dev spawn
		}
		spawnPos.useAmbientVocals = true;

		spawnPos thread eng_amb_vocals();

		randWait = randomintrange(10, 60);

		if( is_true(level.dev_only) )
			randWait = 1;

		//iprintln( "Engineer Zombie: Waiting for spawn, wait time: " + randWait );
		wait(randWait);

		self playsound( "zmb_engineer_death_bells" );

		wait(5);

		spawner = level.enemy_spawns[0];
		boss = spawner maps\_zombiemode_net::network_safe_stalingrad_spawn( "boss_zombie_spawn", 1 );

		if( spawn_failed( boss ) ) {
			//iprintln( "Engineer Zombie: Spawn failed, aborting" );
			level.theater_rounds_until_boss = 0;
			return;
		}

		level.currentEngineer = boss;
		boss zmb_engineer(spawnPos.origin);
		level.currentEngineer = boss;
	
		spawnPos.useAmbientVocals = false;
		spawnPos Delete();

		//iprintln( "Engineer Zombie: Spawned susscesfully at " + spawnPos.origin );
	}

	boss_die()
	{		
		//self playsound( "zmb_engineer_death_bells" );

		if( is_true(self.was_slain) )
		{
			level.eng_times_died++;

			if( is_true( self.empowered) ) {
				//drop free perk powerup
				maps\_zombiemode_powerups::specific_powerup_drop( "free_perk",  self.origin );
			} else {
				//drop restock
				maps\_zombiemode_powerups::specific_powerup_drop( "restock",  self.origin );
			}

			level.theater_rounds_until_boss+=1;
		}
		
		
		level.currentEngineer = undefined;
		self hide();
		self delete();

		return false;
	}

	watch_teleporter()
	{
		self endon( "end_game" );

		self thread watch_teleporter_end();

		while(1)
		{
			self waittill("teleporter_start");

			if( IsDefined(level.currentEngineer) ) {
				//iprintln("Notifying engineer that players are teleporting");
				level.currentEngineer notify("teleporter_used");
			} else {
				rand = randomIntrange(0, 2);
				level.theater_rounds_until_boss -= rand;
			}
		}

	}

	watch_teleporter_end()
	{
		self endon( "end_game" );
		
		while(1)
		{
			self waittill("teleporter_end");

			if( IsDefined(level.currentEngineer) ) {
				//iprintln("Teleport ended, reset engineer goals");
				level.currentEngineer notify("zombie_end_traverse");
			}
		}
	}