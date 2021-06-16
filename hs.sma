#include < amxmodx > 

new const g_Source_Sound [ ][ ] =
{
	"hs/fb.wav",
	"hs/dk.wav",
	"hs/tk.wav",
	"hs/mk.wav",
	"hs/uk.wav",
	"hs/rp.wav"
};

new MyKills [ 33 ], s_fb, s_msg

public plugin_init ( )
{ 
	register_plugin ( "Homicide statistics", "1.0", "OverGame" )
	
	register_event ( "DeathMsg", "event_killing", "a", "1>0" )
	register_logevent ( "event_roundstart", 2, "1=Round_Start" )
	
	s_msg = CreateHudSyncObj ( )
	
	s_fb = true
}

public plugin_precache ( )
{
	for ( new i; i < sizeof ( g_Source_Sound ); i++ )
		precache_sound ( g_Source_Sound [ i ] )
}

public event_roundstart ( )
{
	s_fb = true
	
	for ( new id = 1; id < 33; id++ )
		MyKills [ id ] = 0
		
	return PLUGIN_CONTINUE
}

public event_killing ( )
{
	new iKiller = read_data ( 1 )
	new iVictim = read_data ( 2 )
	
	if ( !is_user_connected ( iKiller ) ||
	!is_user_connected ( iVictim ) || iKiller == iVictim )	return PLUGIN_HANDLED
	
	MyKills [ iKiller ]++
	
	new szNameKiller [ 33 ], szNameVictim [ 33 ]
	get_user_name ( iKiller, szNameKiller, charsmax ( szNameKiller) )
	get_user_name ( iVictim, szNameVictim, charsmax ( szNameVictim ) )
	set_hudmessage ( 100, 100, 100, -1.0, 0.24, 0, 7.0, 4.0, _, _, -1 )
	
	if ( s_fb )
	{
		emit_sound ( 0, 0, g_Source_Sound [ 0 ], 1.0, 1.0, 0, 100 )
		ShowSyncHudMsg ( 0, s_msg, "%s проливает первую кровь,^nубив %s!", szNameKiller, szNameVictim )
		
		s_fb = false
	} else
	if ( MyKills [ iKiller ] == 2 )
	{
		emit_sound ( 0, 0, g_Source_Sound [ 1 ], 1.0, 1.0, 0, 100 )
		ShowSyncHudMsg ( 0, s_msg, "%s совершает двойное убийство!", szNameKiller )
	} else
	if ( MyKills [ iKiller ] == 3 )
	{
		emit_sound ( 0, 0, g_Source_Sound [ 2 ], 1.0, 1.0, 0, 100 )
		ShowSyncHudMsg ( 0, s_msg, "%s совершает тройное убийство!", szNameKiller )
	} else
	if ( MyKills [ iKiller ] == 4 )
	{
		emit_sound ( 0, 0, g_Source_Sound [ 3 ], 1.0, 1.0, 0, 100 )
		ShowSyncHudMsg ( 0, s_msg, "%s входит во вкус убив четверых!", szNameKiller )
	} else
	if ( MyKills [ iKiller ] == 5 )
	{
		emit_sound ( 0, 0, g_Source_Sound [ 4 ], 1.0, 1.0, 0, 100 )
		ShowSyncHudMsg ( 0, s_msg, "%s БОГОПОДОБЕН!", szNameKiller )
	} else
	if ( MyKills [ iKiller ] == 6 )
	{
		emit_sound ( 0, 0, g_Source_Sound [ 5 ], 1.0, 1.0, 0, 100 )
		ShowSyncHudMsg ( 0, s_msg, "%s ПРЕВОСХОДИТ БОГОВ, убийте его кто нибудь!", szNameKiller )
		
		MyKills [ iKiller ] = 5
	}
	
	if ( MyKills [ iVictim ] == 4 )
	{
		ShowSyncHudMsg ( 0, s_msg, "%s убил смертоносного %s", szNameKiller, szNameVictim )
	} else
	if ( MyKills [ iVictim ] == 5 )
	{
		ShowSyncHudMsg ( 0, s_msg, "%s убил буйствуещего %s", szNameKiller, szNameVictim )
	} else
	if ( MyKills [ iVictim ] == 6 )
	{
		ShowSyncHudMsg ( 0, s_msg, "%s спустил с небес ПРЕВЗОШЕДШЕГО БОГОВ %s", szNameKiller, szNameVictim )
	}
	MyKills [ iVictim ] =0
	return PLUGIN_HANDLED
}

public client_putinserver ( id )
	MyKills [ id ] = 0
