// Triggers on any player death.
public player_death() 
{
    static killer, victim, hshot;
    if (!is_user_connected(killer) | !is_user_connected(victim)) // Server crash fix "Out of bounds"
        return PLUGIN_HANDLED;
    hshot = read_data(3);
    killer = read_data(1);
    victim = read_data(2);

    new killername[32]
    get_user_name(killer, killername, 31);

    new weaponname[20]
    read_data(4,weaponname,31)

    // Death of boss
    if(victim == hcp_boss)
    {
		hcp_boss = 0;
        set_user_rendering(victim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		hcp_active = 0;
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5);
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_DEATH", killername);
        client_cmd(0,"spk hcp/boss_defeated");
        emit_sound(victim,CHAN_STATIC,"hcp/boss_death.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
	}

    if (killer != victim)
    {
         // First Blood
        if (isFirstBlood == 0)
        {
            set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
            ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "FIRST_BLOOD", killername);
            client_cmd(0,"spk hcp/firstblood");
            isFirstBlood = 1;
        }

        // Giving a killer one kill and scores
        info[killer][score] += 10;
        info[killer][kills] +=1;

        // Reseting attributes and scores from victim
        info[victim][kills] = 0;
        info[victim][score] -=10;
        attribute[victim][poisoned_from_undying] = 0;
        attribute[victim][berserk_ult_rage] = 0;

        // On headshot
        if (hshot)
        {
            info[killer][headshots] +=1;
            info[killer][score] +=5;
            emit_sound(victim,CHAN_STATIC,"hcp/headshot.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
        }

        // Getting / Giving attributes for each classes on success kill
        switch(hcp_get_user_hero(killer)){

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
        switch(hcp_get_user_hero(victim)){
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
        new herochat = hcp_get_user_hero(killer);
        ColorChat(victim, RED, "%L", LANG_PLAYER, "DEATH_INFO", killername, herochat);

        // Simply Announcing killstreaks
        if(get_cvar_num("hcp_enable_kill_announcer")){
            switch(info[killer][kills])
            { 
                case 3:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "TRIPLE_KILL", killername);
                    emit_sound(killer,CHAN_STATIC,"hcp/triplekill.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                }
                case 4:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MULTI_KILL", killername);
                    emit_sound(killer,CHAN_STATIC,"hcp/multikill.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                }
                case 6:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "KILLING_SPREE", killername);
                    emit_sound(killer,CHAN_STATIC,"hcp/killingspreec.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                }
                case 8:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "UNSTOPPABLE", killername);
                    emit_sound(killer,CHAN_STATIC,"hcp/unstoppable.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                }
                case 10:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MANIAC", killername);
                    emit_sound(killer,CHAN_STATIC,"hcp/maniac.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                }
                case 12:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MASSACRE", killername);
                    emit_sound(killer,CHAN_STATIC,"hcp/massacre.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                }
            }
        }
    }
    return PLUGIN_HANDLED
}

// Function called when round starts
public round_start(){
    RoundCount += 1;
    isFirstBlood = 0;

    for(new id = 1; id <= get_maxplayers(); id++){
        if(is_user_alive(id) && is_user_connected(id)){
            set_user_health(id, hero_hp[id]);
            switch(hcp_get_user_hero(id)){
                case NONE:{
                    
                }
                case SL:{
                
                }
                case UNDYING:{
                
                }
                case BERSERK:{
                
                }
                case ZEUS:{

                }
                case KNIGHT:{
                recover_knight_shield(id);
                }   
            }
        }
    }
}

//
// Playing sounds when choosing a hero
//
public play_s_sound(id) {
if(is_user_alive(id)){
    switch(hcp_get_user_hero(id)){
        case NONE:{
            emit_sound(id, CHAN_STATIC, "hcp/none_spawn.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
        }
        case SL:{
            emit_sound(id, CHAN_STATIC, "hcp/sl_spawn.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
        }
        case UNDYING:{
            emit_sound(id, CHAN_STATIC, "hcp/undying_spawn.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
        }
        case ZEUS:{
            emit_sound(id, CHAN_STATIC, "hcp/zeus_spawn.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
        }
        case BERSERK:{
            emit_sound(id, CHAN_STATIC, "hcp/berserk_spawn.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
        }
        case KNIGHT:{
            emit_sound(id, CHAN_STATIC, "hcp/knight_spawn.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
        }
    }
}
    return PLUGIN_HANDLED;
}

//
// Action to activate ultimate
//
public activate_ult(id) {
    if(is_user_alive(id) && is_user_connected(id))
    switch(hcp_get_user_hero(id)){
        case NONE:
        {
            
        }
        case SL:{
            
        }
        case UNDYING:
        {
        }
        case BERSERK:
        {
            
        } 
        case ZEUS:
        {
        }
    }
}

// Catching out/in-coming damage.
public fwd_Take_Damage(victim, inflicator, attacker, Float:damage) {
    // Checking if player is valid
	if(!is_user_connected(attacker) | !is_user_connected(victim)) return;
	if(victim == attacker || !victim) return;
    if(get_user_team (attacker) == get_user_team (victim)) return;
    
    // TODO: BOT SUPPORT ULTS

    // Multiplying damage for boss.
    if(hcp_boss == attacker){
	    SetHamParamFloat( 4, damage * get_cvar_num("hcp_boss_dmg_mult"));
    }

        // Gaining and stealing attributes for each class on damage
        switch(hcp_get_user_hero(attacker)){
            // For survivors their HP has a cap
            case NONE:
            {
                if(get_user_health(attacker) < get_cvar_num("hcp_hero_survivor_hpcap")){
                    set_user_health(attacker, get_user_health(attacker) + get_cvar_num("hcp_hero_survivor_hp_vampire")); 
                }
            }
            // Slark stealing damage and slowing victim formula.
            case SL:{
                new Float:maxspeedreduceformula[33];
                attribute[victim][sl_leashstack] += 1;
                attribute[attacker][sl_selfstack] += 1;
                if(attribute[victim][sl_leashstack] > 1){
                    maxspeedreduceformula[victim] = get_user_maxspeed(victim) - float(attribute[victim][sl_leashstack]);
                    OnPlayerResetMaxSpeed(victim, maxspeedreduceformula[victim]);
                    SetHamParamFloat(4, damage + (attribute[attacker][sl_selfstack] * 1.3));
                }
                
            }
            

            // Giving some attributes to undying upon hitting a victim
            case UNDYING:
            {
                attribute[attacker][undying_hpstolen_timed] += 1;
                if(attribute[attacker][undying_hpstolen_timed] > 1)
                    undying_hp_gain(attacker);

                attribute[victim][poisoned_from_undying] = 5;   // Setting poison damage on victim ( Go to OneTick() )
            }
            
            // Multiplying damage if berserks health is lower 50% and dealing damage of enemy's max HP
            case BERSERK:
            {
                attribute[attacker][berserk_ult_rage]++
                new Float:berserk_damage = hero_hp[victim] * 0.5;
                SetHamParamFloat(4, damage + berserk_damage);

                if(get_user_health(attacker) < (hero_hp[attacker] * 0.35)){
                    SetHamParamFloat(4, damage + (berserk_damage * get_cvar_num("hcp_hero_berserk_lowhpdamage")));
                }
            }
            
            case ZEUS:
            {
                
            }
 
        }
        
        //  Knight's shield ability
        if(hero[victim] == KNIGHT){
            if(attribute[victim][knight_shield] <= 0 && is_shield_broken[victim] == false){ 
                set_task(20.0, "recover_knight_shield",victim,_,_,_,0);
                is_shield_broken[victim] = true;
            }else if(attacker && is_shield_broken[victim] == false){
                attribute[victim][knight_shield] -= 1;
                SetHamParamFloat(4, damage * 0);
                switch (random_num(1,4)){
                    case 1:{
                        emit_sound(victim,CHAN_STATIC,"hcp/wp_bullet1.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                    }
                    case 2:{
                        emit_sound(victim,CHAN_STATIC,"hcp/wp_bullet2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                    }
                    case 3:{
                        emit_sound(victim,CHAN_STATIC,"hcp/wp_bullet3.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                    }
                    case 4:{
                        emit_sound(victim,CHAN_STATIC,"hcp/wp_bullet4.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
                    }
                }
            }
        }
} 

// Recover a knight's shield after cooldown passed
public recover_knight_shield(id){
    attribute[id][knight_shield] = 15;
    is_shield_broken[id] = false;
    emit_sound(id,CHAN_STATIC,"hcp/knight_shield_ready.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
}