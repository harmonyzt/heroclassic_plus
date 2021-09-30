#include <amxmodx>
#include <screenfade_util>

#define PLUGIN "Show the Kill"
#define VERSION "1.5"
#define AUTHOR "{PHILMAGROIN}"

new gCvar_Enabled;
new gCvar_Crosshair;
new gCvar_Headshot;
new gCvar_Screenfade;
new gCvar_Colors[ 3 ];
new const Float: HUD_COORDS[][] = { { 0.75 , 0.70 } , { -1.0 , 0.35 } };

public plugin_init() 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event( "DeathMsg" , "fwDeathMsg" , "a" );
	
	gCvar_Enabled = register_cvar( "stk_on", "1" );
	gCvar_Crosshair = register_cvar( "stk_crosshair", "1" );
	gCvar_Headshot = register_cvar( "stk_headshot", "1" );
	gCvar_Screenfade = register_cvar( "stk_screenfade", "1" );
	gCvar_Colors[ 0 ] = register_cvar( "stk_red", "255" );
	gCvar_Colors[ 1 ] = register_cvar( "stk_green", "0" );
	gCvar_Colors[ 2 ] = register_cvar( "stk_blue", "0" );
}

public fwDeathMsg(id) 
{
	if( get_pcvar_num( gCvar_Enabled ) )
	{
		new iKiller = read_data(1);
		
		if( iKiller && ( iKiller != read_data(2) ) )
		{
			new iCVar = ( get_pcvar_num( gCvar_Crosshair ) != 0 );
			
			static szHUD[9];
			
			new iColor[ 3 ];
			iColor[ 0 ] = get_pcvar_num( gCvar_Colors[ 0 ] );
			iColor[ 1 ] = get_pcvar_num( gCvar_Colors[ 1 ] );
			iColor[ 2 ] = get_pcvar_num( gCvar_Colors[ 2 ] );
			
			set_hudmessage( iColor[0], iColor[1], iColor[2], HUD_COORDS[iCVar][0] , HUD_COORDS[iCVar][1] , 0 , 1.0 , 3.0 , 0.01 , 0.01 , -1 );
			formatex( szHUD , 8 , "%s" , ( get_pcvar_num( gCvar_Headshot ) && read_data(3) ) ? "HEADSHOT" : "KILL" );
			show_hudmessage( iKiller , szHUD );
			if( get_pcvar_num( gCvar_Screenfade ))
			{
				UTIL_ScreenFade( id, iColor,1.0,0.0,75 );
			}
		}
	}
}





/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
