// Triggers on any player death.
public player_death() 
{
    static killer, victim, hshot;
    killer = read_data(1);
    victim = read_data(2);
    if (!is_user_connected(killer) | !is_user_connected(victim)) // Server crash fix "Out of bounds"
        return PLUGIN_HANDLED;
    hshot = read_data(3);
    new killername[32]
    get_user_name(killer, killername, 31);

    // Death of boss
    if(victim == msm_boss)
    {
		msm_boss = 0;
        set_user_rendering(victim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		msm_active = 0;
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5);
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_DEATH", killername);
        client_cmd(0,"spk msm/boss_defeated");
        emit_sound(victim,CHAN_STATIC,"msm/boss_death.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
	}

    if (killer != victim)
    {
         // First Blood
        if (isFirstBlood == 0)
        {
            set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
            ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "FIRST_BLOOD", killername);
            client_cmd(0,"spk msm/firstblood");
            isFirstBlood = 1;
        }

        // Giving a killer one kill and scores
        info[killer][score] += 10;
        info[killer][kills] +=1;

        // Reseting attributes and scores from victim
        info[victim][kills] = 0;
        info[victim][score] -=10;
        attribute[victim][poisoned_from_undying] = 0;

        // On headshot
        if (hshot)
        {
            info[killer][headshots] +=1;
            info[killer][score] +=5;
            emit_sound(victim,CHAN_STATIC,"msm/headshot.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
        }

        // Getting / Giving attributes for each classes on success kill
        switch(msm_get_user_hero(killer)){

            case NONE:{
                
            }
            case SL:{

            }
            case UNDYING:{
                attribute[killer][undying_hpstack] += 1;
                hero_hp[killer] += 30;
            }
            case BERSERK:{

            }
            case ZEUS:{
            
            }
            case KNIGHT:{

            }
        }

        // Reseting gained stats for each dead hero
        switch(msm_get_user_hero(victim)){
            case NONE:{
                
            }
            case SL:{
                attribute[victim][sl_leashstack] = 0;
                attribute[victim][sl_selfstack] = 0;
            }
            case UNDYING:{
                attribute[victim][undying_hpstolen_timed] = 0;
            }
            case BERSERK:{

            }
            case ZEUS:{
                
            }
            case KNIGHT:{
                remove_task(victim, 0)
            }

        }
        // Giving the victim info about killer (oficially broken)
        new herochat = msm_get_user_hero(killer);
        ColorChat(victim, RED, "%L", LANG_PLAYER, "DEATH_INFO", killername, herochat);

        // Simply Announcing killstreaks
        switch(info[killer][kills])
        { 
            case 3:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "TRIPLE_KILL", killername);
                emit_sound(0,CHAN_STATIC,"msm/triplekill.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            }
            case 4:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MULTI_KILL", killername);
                emit_sound(0,CHAN_STATIC,"msm/multikill.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            }
            case 6:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "KILLING_SPREE", killername);
                emit_sound(0,CHAN_STATIC,"msm/killingspreec.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            }
            case 8:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "UNSTOPPABLE", killername);
                emit_sound(0,CHAN_STATIC,"msm/unstoppable.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            }
            case 10:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MANIAC", killername);
                emit_sound(0,CHAN_STATIC,"msm/maniac.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            }
            case 12:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MASSACRE", killername);
                emit_sound(0,CHAN_STATIC,"msm/massacre.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            }
        }
    }
    return PLUGIN_HANDLED
}