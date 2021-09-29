#include <amxmodx>

public plugin_precache()
{
	precache_sound("buttons/bell1.wav")
	precache_sound("fvox/flatline.wav")
}

new fade_victim,color_victim,vdensity,vdur,vht, fade_killer,color_killer,kdensity,kdur,kht, vsound,ksound,hsmode
public plugin_init() {
	register_plugin("Kill Fade", "1.7", "<VeCo>")
	register_event("DeathMsg","hook_death","a")
	
	register_cvar("fade_version", "1.7", FCVAR_SERVER|FCVAR_SPONLY)
	fade_victim = register_cvar("fade_victim_on","1")
	color_victim = register_cvar("fade_victim_color","255 0 0")
	vdensity = register_cvar("fade_victim_density","175")
	vdur = register_cvar("fade_victim_duration","1")
	vht = register_cvar("fade_victim_hold_time","1")
	fade_killer = register_cvar("fade_killer_on","1")
	color_killer = register_cvar("fade_killer_color","0 255 0")
	kdensity = register_cvar("fade_killer_density","175")
	kdur = register_cvar("fade_killer_duration","1")
	kht = register_cvar("fade_killer_hold_time","1")
	vsound = register_cvar("fade_victim_sound","1")
	ksound = register_cvar("fade_killer_sound","1")
	hsmode = register_cvar("fade_hs_mode","0")
}

public hook_death()
{
	new killer = read_data(1)
	new victim = read_data(2)
	new hs = read_data(3)
	
	if(is_user_connected(killer) && is_user_connected(victim))
	{
		switch(get_pcvar_num(hsmode))
		{
			case 1:
			{
				if(hs)
				{		
					if(get_pcvar_num(fade_killer)) user_fade(killer,color_killer,get_pcvar_num(kdensity),get_pcvar_num(kdur),get_pcvar_num(kht))
					if(get_pcvar_num(fade_victim)) user_fade(victim,color_victim,get_pcvar_num(vdensity),get_pcvar_num(vdur),get_pcvar_num(vht))
				}
			}
			case 0:
			{
				if(get_pcvar_num(fade_killer)) user_fade(killer,color_killer,get_pcvar_num(kdensity),get_pcvar_num(kdur),get_pcvar_num(kht))
				if(get_pcvar_num(fade_victim)) user_fade(victim,color_victim,get_pcvar_num(vdensity),get_pcvar_num(vdur),get_pcvar_num(vht))
			}
		}
		
		if(get_pcvar_num(ksound)) client_cmd(killer,"spk ^"buttons/bell1.wav^"")
		if(get_pcvar_num(vsound)) client_cmd(victim,"spk ^"fvox/flatline.wav^"")
	}
}

stock user_fade(id,fade_color,density,duration,hold_time)
{
	new color[17],red[5],green[7],blue[5]
	get_pcvar_string(fade_color,color,16)
	parse(color,red,4,green,6,blue,4)
	
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{0,0,0},id)
	write_short(duration * 4096)
	write_short(hold_time * 4096)
	write_short(0x0001)
	write_byte(str_to_num(red))
	write_byte(str_to_num(green))
	write_byte(str_to_num(blue))
	write_byte(density)
	message_end()
}
