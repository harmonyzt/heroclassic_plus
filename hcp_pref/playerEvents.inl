// Triggers on players death
public player_death(){
    static killer, victim, hshot;
    killer = read_data(1);
    hshot = read_data(3);
    victim = read_data(2);
    
    if (!is_user_connected(killer) | !is_user_connected(victim)) // Server crash fix "Out of bounds"
        return PLUGIN_HANDLED;

    new killername[32];
    get_user_name(killer, killername, 31);

    client_cmd(victim,"spk hcp/death");
    isAllowedToChangeClass[victim] = 0;

    // Death of the boss
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
        info[killer][kills] += 1;

        // Reseting attributes and scores from victim
        reset_all_attributes(victim)
        info[victim][kills] = 0;
        info[victim][score] -= 10;

        // On headshot
        if (hshot)
        {
            info[killer][headshots] += 1;
            info[killer][score] += 10;
            client_cmd(0,"spk hcp/headshot");
        }

        // Getting / Giving attributes for each classes on success kill
        switch(hcp_get_user_hero(killer)){
            case NONE:{
                
            }
            case SLARK:{

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
        
        // Simply Announcing killstreaks
        if(get_cvar_num("hcp_enable_kill_announcer") == 1){
            switch(info[killer][kills]){ 
                case 3:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "TRIPLE_KILL", killername);
                    client_cmd(0,"spk hcp/triplekill");
                }
                case 4:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MULTI_KILL", killername);
                    client_cmd(0,"spk hcp/multikill");
                }
                case 6:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "KILLING_SPREE", killername);
                    client_cmd(0,"spk hcp/killingspree");
                }
                case 8:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "UNSTOPPABLE", killername);
                    client_cmd(0,"spk hcp/unstoppable");
                }
                case 10:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MANIAC", killername);
                    client_cmd(0,"spk hcp/maniac");
                }
                case 12:
                {
                    set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5);
                    ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MASSACRE", killername);
                    client_cmd(0,"spk hcp/massacre");
                }
            }
        }
    }
    return PLUGIN_HANDLED;
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
                case SLARK:{
                
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
        case SLARK:{
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
    if(is_user_alive(id) && is_user_connected(id)){
    switch(hcp_get_user_hero(id)){
        case NONE:
        {
            
        }
        case SLARK:{
            
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
	    SetHamParamFloat( 4, damage * get_cvar_float("hcp_boss_dmg_mult"));
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
            case SLARK:{
                attribute[victim][sl_leashstack] += 1;
                attribute[attacker][sl_selfstack] += 1;
                if(attribute[victim][sl_leashstack] > 1){
                    SetHamParamFloat(4, damage + (attribute[attacker][sl_selfstack] * 1.3));
                }
                
            }

            // Giving HP to undying when hitting a victim
            case UNDYING:
            {
                attribute[attacker][undying_hpstolen_timed] += 1;
                // Gaining HP
                if(attribute[attacker][undying_hpstolen_timed] > 1){
                    new totalhealth = undying_hpstolen_timed + 9 + get_user_health(attacker);
                    set_user_health(attacker, totalhealth);
                }
                attribute[victim][poisoned_from_undying] = 5;   // Setting poison damage on victim ( Go to OneTick() )
            }
            
            // Multiplying damage if berserks health is lower 50% and dealing damage of enemy's max HP
            case BERSERK:
            {
                attribute[attacker][berserk_ult_rage]++
                new Float:berserk_damage = hero_hp[victim] * 0.1;
                SetHamParamFloat(4, damage + berserk_damage);

                if(get_user_health(attacker) < (hero_hp[attacker] * 0.50)){
                    SetHamParamFloat(4, damage + (berserk_damage * get_cvar_float("hcp_hero_berserk_ultdamage")));
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

// Recover a knight's shield after cooldown
public recover_knight_shield(id){
    attribute[id][knight_shield] = 15;
    is_shield_broken[id] = false;
    emit_sound(id,CHAN_STATIC,"hcp/knight_shield_ready.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
}

// Undying gains HP on hit
public undying_hp_gain(id)
{
    new totalhealth = undying_hpstolen_timed + 9 + get_user_health(id);
    set_user_health(id, totalhealth);
}

// Player respawn
public PlayerSpawn_Post(id) {
    if(is_user_alive(id) && is_user_connected(id) && !is_user_bot(id)){
        isAllowedToChangeClass[id] = 1;
        client_cmd(id,"spk hcp/respawn");
        ColorChat(id, GREY, "%L", LANG_PLAYER, "CHANGE_ALLOWED", get_cvar_float("hcp_playerherochange_allowed"));
        set_task(get_cvar_float("hcp_playerherochange_allowed"), "ChangeClassAllowed",id+34532,_,_,_);
    }
}

// Removing a task to disallow player from changing a class
public ChangeClassAllowed(id){
    id = id - 34532;
    isAllowedToChangeClass[id] = 0;
    remove_task(id);
}
