
#include <amxmodx>
#include <cstrike>

#define PLUGIN "CSGO Grenade Trail"
#define AUTHOR "Fatih ~ EjderYa"
#define VERSION "1.0"

#define CT_COLOR_RED	0
#define CT_COLOR_GREEN	130
#define CT_COLOR_BLUE	191

new trail
public plugin_init()	register_plugin(PLUGIN, VERSION, AUTHOR)

public plugin_precache()	trail = precache_model("sprites/smoke.spr")

public grenade_throw(id, grenade)
{
	new Players[32] , Numbers
	get_players( Players , Numbers , "bc" )

	for ( new i ; i < Numbers ; i++ ){

		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY , {0,0,0}, Players[i] )
		write_byte(TE_BEAMFOLLOW)
		write_short(grenade)
		write_short(trail)
		write_byte(500)
		write_byte(1)
		Team_Color(id)
		write_byte(225)
		message_end()

	}

}
public Team_Color(id){

	if ( cs_get_user_team(id) == CS_TEAM_T ){
		write_byte(CT_COLOR_BLUE)
		write_byte(CT_COLOR_GREEN)
		write_byte(CT_COLOR_RED)
	}
	else if ( cs_get_user_team(id) == CS_TEAM_CT ){
		write_byte(CT_COLOR_RED)
		write_byte(CT_COLOR_GREEN)
		write_byte(CT_COLOR_BLUE)
	}
	else
	{
		write_byte(120)
		write_byte(120)
		write_byte(120)
	}
}
