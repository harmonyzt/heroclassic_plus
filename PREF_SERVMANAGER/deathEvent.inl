// Triggers on any player death.
public player_death() 
{
    static killer, victim, hshot;
    killer = read_data(1);
    victim = read_data(2);
    if (!is_user_connected(killer) | !is_user_connected(victim)) // Server crash fix "Out of bounds"
        return PLUGIN_HANDLED
    hshot = read_data(3);
    new killername[32]
    get_user_name(killer, killername, 31);

    //Death of boss.
    if(victim == msm_boss)
    {
		msm_boss = 0; set_user_rendering(victim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		msm_active = 0;
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5)
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_DEATH", killername);
        client_cmd(0,"spk msm/boss_defeated")
        emit_sound(victim,CHAN_STATIC,"msm/boss_death.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	}

    if (killer != victim)
    {
         //First Blood (moved here because suiciding was causing first blood)
        if (isFirstBlood == 0)
        {
            set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
            ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "FIRST_BLOOD", killername)
            client_cmd(0,"spk msm/firstblood")
            isFirstBlood = 1;
        }

        // Giving a killer one kill and scores
        info[killer][score] += 10
        info[killer][kills] +=1

        // Reseting attributes and scores from victim
        info[victim][kills] = 0;
        info[victim][score] -=10;
        attribute[victim][sl_leashstack] = 0;
        attribute[victim][sl_selfstack] = 0;
        attribute[victim][undying_hpstolen_timed] = 0;
        attribute[victim][poisoned_from_undying] = 0;

        // On headshot
        if (hshot)
        {
            info[killer][headshots] +=1
            info[killer][score] +=5
            client_cmd(0,"spk msm/headshot")
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

        }
        // Giving the victim info about killer
        new herochat = msm_get_user_hero(killer)
        ColorChat(victim, RED, "%L", LANG_PLAYER, "DEATH_INFO", killername, herochat)
        // Simply Announcing killstreaks
        switch(info[killer][kills])
        { 
            case 3:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "TRIPLE_KILL", killername);
                client_cmd(0,"spk msm/triplekill")
            }
            case 5:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MULTI_KILL", killername);
                client_cmd(0,"spk msm/multikill")
            }
            case 6:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "KILLING_SPREE", killername);
                client_cmd(0,"spk msm/killingspree")
            }
            case 8:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "UNSTOPPABLE", killername);
                client_cmd(0,"spk msm/unstoppable")
            }
            case 10:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MANIAC", killername);
                client_cmd(0,"spk msm/maniac")
            }
            case 12:
            {
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MASSACRE", killername);
                client_cmd(0,"spk msm/massacre")
            }
        }
    }
    return PLUGIN_HANDLED
}