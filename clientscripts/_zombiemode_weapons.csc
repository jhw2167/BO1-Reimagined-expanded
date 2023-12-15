#include clientscripts\_utility;

weapon_box_callback( localClientNum, set, newEnt )
{
	if( localClientNum != 0 )
	{
		return;
	}
	if( set )
	{
		self thread weapon_floats_up();
	}
	else
	{
		self notify( "end_float" );
		cleanup_weapon_models();
	}
}

cleanup_weapon_models()
{
	if( IsDefined( self.weapon_models ) )
	{
		players = GetLocalPlayers();
		for( index = 0; index < players.size; index ++ )
		{
			if( IsDefined( self.weapon_models[ index ] ) )
			{
				self.weapon_models[ index ].dw Delete();
				self.weapon_models[ index ] Delete();
			}
		}
		self.weapon_models = undefined;
	}
}

weapon_is_dual_wield( name )
{
	switch( name )
	{
		case "cz75dw_zm":
		case "cz75dw_upgraded_zm":
		case "mkb42dw_zm":
		case "mkb42dw_upgraded_zm":		
		case "m1911_upgraded_zm":
		case "hs10_upgraded_zm":
		case "pm63_upgraded_zm":
		case "microwavegundw_zm":
		case "microwavegundw_upgraded_zm":
			return true;

		default:
			return false;
	}
}

get_left_hand_weapon_model_name( name )
{
	switch( name )
	{
		case "microwavegundw_zm":
			return GetWeaponModel( "microwavegunlh_zm" );

		case "microwavegundw_upgraded_zm":
			return GetWeaponModel( "microwavegundwlh_upgraded_zm" );

		default:
			return GetWeaponModel( name );
	}
}

weapon_floats_up()
{
	self endon( "end_float" );
	cleanup_weapon_models();
	self.weapon_models = [];
	rand = treasure_chest_ChooseRandomWeapon();
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i ++ )
	{
		self.weapon_models[i] = Spawn( i, self.origin, "script_model" );
		self.weapon_models[i].angles = self.angles + ( 0, 180, 0 );
		self.weapon_models[i] SetModel( GetWeaponModel( rand ) );
		self.weapon_models[i] UseWeaponHideTags( rand );
		self.weapon_models[i].dw = Spawn( i, self.weapon_models[i].origin - ( 3, 3, 3 ), "script_model" );
		self.weapon_models[i].dw.angles = self.weapon_models[i].angles;
		if( weapon_is_dual_wield( rand ) )
		{
			self.weapon_models[i].dw SetModel( get_left_hand_weapon_model_name( rand ) );
			self.weapon_models[i].dw Show();
		}
		else
		{
			self.weapon_models[i].dw SetModel( "tag_origin" );
			self.weapon_models[i].dw Hide();
		}
		self.weapon_models[i] MoveTo( self.origin + ( 0, 0, 64 ), 3, 2, 0.9 );
		self.weapon_models[i].dw MoveTo( self.origin + ( -3, -3, 61 ), 3, 2, 0.9 );
	}
	for( i = 0; i < 39; i ++ )
	{
		if( i < 20 )
		{
			realWait( 0.05 );
		}
		else if( i < 30 )
		{
			realWait( 0.1 );
		}
		else if( i < 35 )
		{
			realWait( 0.2 );
		}
		else if( i < 38 )
		{
			realWait( 0.3 );
		}
		rand = treasure_chest_ChooseRandomWeapon();
		players = GetLocalPlayers();
		for( index = 0; index < players.size; index ++ )
		{
			if( IsDefined( self.weapon_models[ index ] ) )
			{
				self.weapon_models[ index ] SetModel( GetWeaponModel( rand ) );
				self.weapon_models[ index ] UseWeaponHideTags( rand );
				if( weapon_is_dual_wield( rand ) )
				{
					self.weapon_models[ index ].dw SetModel( get_left_hand_weapon_model_name( rand ) );
					self.weapon_models[ index ].dw Show();
				}
				else
				{
					self.weapon_models[ index ].dw SetModel( "tag_origin" );
					self.weapon_models[ index ].dw Hide();
				}
			}
		}
	}
	cleanup_weapon_models();
}

is_weapon_included( weapon_name )
{
	if( !IsDefined( level._included_weapons ) )
	{
		return false;
	}
	for( i = 0; i < level._included_weapons.size; i ++ )
	{
		if( weapon_name == level._included_weapons[i] )
		{
			return true;
		}
	}
	return false;
}

include_weapon( weapon, display_in_box )
{
	if( !IsDefined( level._included_weapons ) )
	{
		level._included_weapons = [];
	}
	level._included_weapons[ level._included_weapons.size ] = weapon;
	if( !IsDefined( level._display_box_weapons ) )
	{
		level._display_box_weapons = [];
	}
	if( !IsDefined( display_in_box ) )
	{
		display_in_box = true;
	}
	if( !display_in_box )
	{
		return;
	}
	level._display_box_weapons[ level._display_box_weapons.size ] = weapon;
}

treasure_chest_ChooseRandomWeapon()
{
	return level._display_box_weapons[ RandomInt( level._display_box_weapons.size ) ];
}