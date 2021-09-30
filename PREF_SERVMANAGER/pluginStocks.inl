// Useful features

// Simple fade
stock user_fade(id, red, green, blue, density, duration, hold_time)
{
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{0,0,0},id)
	write_short(duration * 4096)
	write_short(hold_time * 4096)
	write_short(0x0001)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(density)
	message_end()
}

// Freezing player on place
stock freeze_player(id, status) {
	if(!is_user_connected(id) && !is_user_alive(id)) 
        return false;
	set_user_godmode(id, status);
	if(status) 
    {
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
		set_user_gravity( id, 9999.0 );
		set_user_rendering(id, kRenderFxGlowShell, 80, 224, 255, kRenderNormal, 5);
	} else {
		set_pev(id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN);
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		set_user_gravity(id, 1.0 );
	}
	return true;
}

// Giving a default model
stock msm_align_model(id){
	if(hero[id] == NONE || hero[id] == ZEUS || hero[id] == BERSERK){
        switch(cs_get_user_team(id)){
            case CS_TEAM_T:{
                cs_set_user_model(id,"msm-tt");
            }
            case CS_TEAM_CT:{
                cs_set_user_model(id,"msm-ct");
            }
        }
    }
	if(hero[id] == UNDYING){
		cs_set_user_model(id,"msm-undying")
	}
}

// Returning name of hero
stock msm_get_user_hero(id){
    return hero[id]
}
