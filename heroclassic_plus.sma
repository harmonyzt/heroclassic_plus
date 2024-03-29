#include < amxmodx >        //  Main amxmodx include.
#include < amxmisc >        //  For an old menu.
#include < fun >            //  For glow effect.
#include < dhudmessage >    //  For new format of hud messages.
#include < colorchat >      //  For colored simple chat.
#include < cstrike >        //  For catching player's team and giving ammo.
#include < hamsandwich >    //  For catching player's damage and increasing it.
#include < fakemeta >       //  For custom player models.
#include < float >          //  For calculations.
#include < nvault >         //  For information storage.


#define plug    "Hero Classic+"
#define ver     "1.7b"
#define auth    "harmony & MuiX"

enum _:InfoTable
{
    kills,
    headshots,
    score,
    skill,
    hasVampiricHelmet,
    hasGloriousArmor
};

new info[128][InfoTable];           // Information with table of stuff to store with nvault
new dmgTakenHUD, dmgDealtHUD;       // Custom damager
new isFirstBlood = 0;               // To check if there was a first blood or not
new announcehud;                    // HUD for kill announcer
new hcp_boss, hcp_active = 0;       // For boss, to check if there is one or not
new bool:is_shield_broken[33];      // To check if shield broken or not (KNIGHT)
new g_msgHideWeapon;                // For hiding HUD
new hcp_vault;                      // For NVault
new RoundCount = 0;                 // For counting rounds
new isAllowedToChangeClass[32] = 0; // To set when the player is allowed to change a class
new Float:skillformula[32];         // For skill calculations

public plugin_init(){
    register_plugin(plug, ver, auth);

    // Main CVARs
    register_cvar("hcp_playerherochange_allowed","9");
    register_cvar("hcp_enable_kill_announcer","1");
    register_cvar("hcp_boss_timer","60.0");
    register_cvar("hcp_hud_tick","1.0");
    register_cvar("hcp_bot_think_min","25.0");
    register_cvar("hcp_bot_think_max","60.0");

    // Boss CVARs
    register_cvar("hcp_boss_health","1500");
    register_cvar("hcp_boss_ammo","300");
    register_cvar("hcp_boss_dmg_mult","1.3");

    // Survivor CVARs
    register_cvar("hcp_hero_survivor_hp","300");
    register_cvar("hcp_hero_survivor_hp_vampire","5");
    register_cvar("hcp_hero_survivor_hpcap","400");

    // Berserk CVARs
    register_cvar("hcp_hero_berserk_hp","350");
    register_cvar("hcp_hero_berserk_rage","15");
    register_cvar("hcp_hero_berserk_ultdamage","1.5");
    
    register_event("DeathMsg","player_death","a");                              // Catching player's death.
    register_logevent("round_start", 2, "1=Round_Start");                       // Catching start of the round.
    register_event("SendAudio", "tt_win", "a", "2&%!MRAD_terwin") 
	register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin")	
    register_event("Damage", "damager", "b", "2!0", "3=0", "4!0");              // Catching REAL damage.
    RegisterHam(Ham_TakeDamage, "player", "fwd_Take_Damage", 0);                // Catching incoming damage.
    RegisterHam(Ham_Spawn, "player", "PlayerSpawn_Post", 1);                    // Catching player respawn.
    g_msgHideWeapon = get_user_msgid("HideWeapon");                             // Hiding default health and armor bar.
	register_event("ResetHUD", "onResetHUD", "b");                              // Hiding default health and armor bar.
	register_message(g_msgHideWeapon, "msgHideWeapon");                         // Hiding default health and armor bar.
    register_dictionary("hcp.txt");                                             // Registering lang file.
    register_clcmd("say /class","class_change");                                // Registering menu (or a command to call menu).
    register_clcmd("say /itemshop", "itemshop");                                // Register Item Shop
    register_clcmd("activate_ultimate","activate_ult");                         // Registering ultimate activation (or a command to call menu).
    hcp_vault = nvault_open("hcpstorage");                                      // Opening nvault storage.
    set_task(1.0, "HudTick",_,_,_,"b");              // Displaying info for each player.
    set_task(1.0, "OneTick",_,_,_,"b");                                         // One second tick for plugin.
    set_task(random_float(get_cvar_float("hcp_bot_think_min"),get_cvar_float("hcp_bot_think_max")), "BotThink",_,_,_,"b");      // Bot thinking to pick a class.
}

public plugin_cfg(){
	new cfgDir[64], File[192];
	get_configsdir(cfgDir, charsmax(cfgDir));
	formatex(File,charsmax(File),"%s/hcp_config.cfg",cfgDir);
	if(file_exists(File)){
		server_cmd("exec %s", File);
    } else {
        server_print("[HCP] Configuration file is missing!");
        abort(43, "No configuration file found");
    }
}

////////////////    Plugin Functions   ////////////////////

#include "hcp_pref/classInit.inl"
#include "hcp_pref/playerEvents.inl"
//#include "hcp_pref/nativeSupport.inl"     // Under development
#include "hcp_pref/botSupport.inl"
#include "hcp_pref/hideHUD.inl"
#include "hcp_pref/nVault.inl"
#include "hcp_pref/itemShop.inl"
#include "hcp_pref/pluginStocks.inl"

///////////////////////////////////////////////////////////

// Recording a demo when player joins.
public welcomepl(id){
    client_cmd(id,"spk hcp/serverjoin");
}

public damager(id){
    static attacker; attacker = get_user_attacker(id);
    static damage; damage = read_data(2);

    if(!is_user_connected(attacker) | !is_user_connected(id)) return;
	if(id == attacker || !id) return;
    if(get_user_team (attacker) == get_user_team (id)) return;

    set_hudmessage(234, 75, 75, 0.54, 0.52, 0, 0.5, 0.30, 0.5, 0.5, -1); 
    ShowSyncHudMsg(id, dmgTakenHUD, "%d", damage);
    set_hudmessage(15, 180, 90, 0.54, 0.45, 0, 0.5, 0.30, 0.5, 0.5, -1);
    ShowSyncHudMsg(attacker, dmgDealtHUD, "%d", damage);
}

// Choosing random player to be a boss
public hcp_boss_random() {
	if(hcp_active == 0 && RoundCount > 5) {
		static Players[32], Count, id_rand;
		get_players(Players, Count, "ah");
		id_rand = random_num(0, Count - 1);
		hcp_boss = Players[id_rand];
        if(hero[hcp_boss] != NONE){
            hcp_boss = 0;
            return PLUGIN_HANDLED;
        }
		    hcp_active = 1;
            hcp_set_user_boss(hcp_boss);
	}
        return PLUGIN_HANDLED;
}

public hcp_set_user_boss(id) {
	if(is_user_connected(id) && hero[hcp_boss] == NONE) {
        hero[id] = BOSS;
        hero_hp[id] = get_cvar_num("hcp_boss_health");
        new nm[33];
        get_user_name(id, nm, 32);

        client_cmd(id, "slot1; drop");
		give_item(id,"weapon_m249");
		cs_set_user_bpammo(id, CSW_M249, get_cvar_num("hcp_boss_ammo"));

		set_user_health(id, get_cvar_num("hcp_boss_health"));

		client_cmd(0,"spk hcp/boss_spawned");
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5);
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_SPAWNED", nm);

		switch(cs_get_user_team(id)) {
			case CS_TEAM_T: set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
			case CS_TEAM_CT: set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);
		}
	}
}

public HudTick(){
    for(new id = 1; id <= get_maxplayers(); id++){
        if(is_user_connected(id) && is_user_alive(id) && !is_user_bot(id)){
            switch(hcp_get_user_hero(id)){
                case NONE:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_NONE", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HP", get_user_health(id));
                }
                case SLARK:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L ^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_SL", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HERO_SL_SELFSTACK", attribute[id][sl_selfstack], LANG_PLAYER, "HP", get_user_health(id));
                }
                case UNDYING:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_UD", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HERO_UD_HPSTACK", attribute[id][undying_hpstack], LANG_PLAYER, "HERO_UD_HPSTOLEN", attribute[id][undying_hpstolen_timed], LANG_PLAYER, "HP", get_user_health(id));
                }
                case BERSERK:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_BERSERK", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HP", get_user_health(id), LANG_PLAYER, "BERSERK_ULT", attribute[id][berserk_ult_rage]);
                }
                case ZEUS:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_ZEUS", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER,"HP", get_user_health(id), LANG_PLAYER, "HERO_ULT", attribute[id][ult_counter]);
                }
                case KNIGHT:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_KNIGHT", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill],LANG_PLAYER, "KNIGHT_SHIELD", attribute[id][knight_shield], LANG_PLAYER, "HP", get_user_health(id));
                }
                case BOSS:{
                    set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
                    show_dhudmessage(id, "%L %L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_BOSS", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER,"HP", get_user_health(id));
                }
            }
        }
    }
    return PLUGIN_HANDLED;
}

public OneTick(){
    for(new id = 1; id <= get_maxplayers(); id++){
        if(is_user_connected(id) && is_user_connected(id) && is_user_alive(id)){
            if(hero[id] == UNDYING && attribute[id][undying_hpstolen_timed] > 0 && get_user_health(id) > 10){
                attribute[id][undying_hpstolen_timed] -= 1;
                set_user_health(id, get_user_health(id) - 5);
            }

            // If victim is poisoned
            if(attribute[id][poisoned_from_undying] >= 1 && get_user_health(id) > 15){
                set_user_health(id, get_user_health(id) - 15);
                user_fade(id, 0, 230, 30, 50, 2, 1);
                attribute[id][poisoned_from_undying] -= 1;
                emit_sound(id, CHAN_STATIC, "hcp/undying_poison.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
            }

            // Cooldowns for ultimates (ONLY FOR TIMED COOLDOWNS)
            if(attribute[id][is_ult_ready] == 0){
                attribute[id][ult_counter] -= 1;
                if(attribute[id][ult_counter] == 0 && is_user_alive(id) && is_user_connected(id)){
                    set_ult_active(id);
                }
            }
        }
    }
}

// Closing data storage when plugin finished it's work
public plugin_end(){
	nvault_close(hcp_vault);
}

public plugin_precache(){
    if(get_cvar_num("hcp_enable_kill_announcer") == 1){
    precache_sound("hcp/firstblood.wav");
    precache_sound("hcp/headshot.wav");
    precache_sound("hcp/killingspree.wav");
    precache_sound("hcp/maniac.wav");
    precache_sound("hcp/massacre.wav");
    precache_sound("hcp/multikill.wav");
    precache_sound("hcp/serverjoin.wav");
    precache_sound("hcp/triplekill.wav");
    precache_sound("hcp/unstoppable.wav");
    }
    precache_sound("hcp/boss_defeated.wav");
    precache_sound("hcp/boss_spawned.wav");
    precache_sound("hcp/boss_death.wav");
    precache_sound("hcp/sl_spawn.wav");
    precache_sound("hcp/none_spawn.wav");
    precache_sound("hcp/undying_spawn.wav");
    precache_sound("hcp/berserk_spawn.wav");
    precache_sound("hcp/berserk_ult_hit.wav");
    precache_sound("hcp/adrenaline_full.wav");
    precache_sound("hcp/zeus_spawn.wav");
    precache_sound("hcp/undying_poison.wav");
    precache_sound("hcp/knight_shield_ready.wav");
    precache_sound("hcp/knight_spawn.wav");
    precache_sound("hcp/wp_bullet1.wav");
    precache_sound("hcp/wp_bullet2.wav");
    precache_sound("hcp/wp_bullet3.wav");
    precache_sound("hcp/wp_bullet4.wav");
    precache_sound("hcp/ultimate_ready.wav");
    precache_sound("hcp/death.wav");
    precache_sound("hcp/respawn.wav");
    dmgTakenHUD = CreateHudSyncObj();
    dmgDealtHUD = CreateHudSyncObj();
    announcehud = CreateHudSyncObj();
}
