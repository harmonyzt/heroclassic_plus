#include < amxmodx >        //  Main amxmodx include.
#include < amxmisc >        //  For an old menu.
#include < fun >            //  For glow effect.
#include < dhudmessage >    //  For new format of hud messages.
#include < colorchat2 >     //  For colored simple chat.
#include < cstrike >        //  For catching player's team and giving ammo.
#include < hamsandwich >    //  For catching player's damage and increasing it.
#include < fakemeta >       //  For custom player models.
#include < float >          //  For calculations.
#include < nvault >          //  For calculations.

#pragma tabsize 0
#define plug    "MSM"
#define ver     "1.6"
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

new info[128][InfoTable];           // Info made for skill and such.
new dmgTakenHUD, dmgDealtHUD;       // Custom damager.
new isFirstBlood = 0;               // To check if there was a first blood or not.
new announcehud;                    // HUD for kill announcer.
new msm_boss, msm_active = 0;       // For boss, to check if there is one or not.
new bool:is_shield_broken[33];      // To check if shield broken or not (KNIGHT).
new g_msgHideWeapon;                 // For hiding HUD.
new msm_vault;                       // For NVault.
new RoundCount = 0;                  // For counting rounds.



public plugin_init()
{
    register_plugin(plug, ver, auth);

    // Boss CVARs
    register_cvar("msm_boss_health","1500");
    register_cvar("msm_boss_ammo","300");
    register_cvar("msm_boss_dmg_mult","1.3");
    register_cvar("msm_enable_kill_announcer","1");

    // Survivor CVARs
    register_cvar("msm_hero_survivor_hp","300");
    register_cvar("msm_hero_survivor_hp_vampire","5");
    register_cvar("msm_hero_survivor_hpcap","400");

    // Berserk CVARs
    register_cvar("msm_hero_berserk_hp","350");
    register_cvar("msm_hero_berserk_rage","15");
    register_cvar("msm_hero_berserk_proportionaldamage","0.10");
    register_cvar("msm_hero_berserk_lowhpdamage","2")

    register_event("DeathMsg","player_death","a");                      // Catching player's death.
    register_logevent("round_start", 2, "1=Round_Start");               // Catching start of the round.
    register_event("Damage", "damager", "b", "2!0", "3=0", "4!0");      // Catching REAL damage.
    g_msgHideWeapon = get_user_msgid("HideWeapon");                     // Hiding default health and armor bar.
	register_event("ResetHUD", "onResetHUD", "b");                      // Hiding default health and armor bar.
	register_message(g_msgHideWeapon, "msgHideWeapon");                 // Hiding default health and armor bar.
    register_dictionary("msm.txt");                                     // Registering lang file.
    RegisterHam(Ham_TakeDamage, "player", "fwd_Take_Damage", 0);        // Catching incoming damage.
    register_clcmd("say /class","class_change");                        // Registering menu (or a command to call menu).
    register_clcmd("activate_ultimate","activate_ult");                 // Registering menu (or a command to call menu).
    msm_vault = nvault_open("mserver");                                 // Opening nvault storage.
    set_task(60.0, "msm_boss_random",_,_,_,"b");                        // Finding a boss each 'n' seconds. TODO: cfg
    set_task(1.0, "HudTick",_,_,_,"b");                                 // Displaying info for each player.
    set_task(1.0, "OneTick",_,_,_,"b");                                 // One second tick for plugin.
    set_task(random_float(15.0,70.0), "BotThink",_,_,_,"b");            // Bot thinking to pick a class.
    RegisterHam(Ham_Item_PreFrame, "player", "OnPlayerResetMaxSpeed", 1) 
}

public plugin_cfg()
{
	new cfgDir[64], File[192];
	get_configsdir(cfgDir, charsmax(cfgDir));
	formatex(File,charsmax(File),"%s/server_manager.ini",cfgDir);
	if(file_exists(File))
		server_cmd("exec %s", File);
}

////////////////    Plugin Functions   ////////////////////////////


#include "msm_pref/classInit.inl"
#include "msm_pref/playerEvents.inl"
#include "msm_pref/pluginStocks.inl"
//#include "msm_pref/nativeSupport.inl"     // Under development
#include "msm_pref/botSupport.inl"
#include "msm_pref/hideHUD.inl"
#include "msm_pref/nVault.inl"

////////////////////////////////////////////////////////////////////


// Recording a demo when player joins.
public welcomepl(id){
    client_cmd(id,"spk msm/serverjoin");
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

public undying_hp_gain(id)
{
    new totalhealth = undying_hpstolen_timed + 9 + get_user_health(id);
    set_user_health(id, totalhealth);
}

public msm_boss_random() {      // Choosing random player to be a boss
	if(msm_active == 0 && RoundCount > 5) {
		static Players[32], Count, id_rand;
		get_players(Players, Count, "ah");
		id_rand = random_num(0, Count - 1);
		msm_boss = Players[id_rand];
        if(hero[msm_boss] != NONE){
            msm_boss = 0;
            return PLUGIN_HANDLED;
        }
		msm_active = 1;
        msm_set_user_boss(msm_boss);
	}
        return PLUGIN_HANDLED;
}

public msm_set_user_boss(id) {
	if(is_user_connected(id) && hero[msm_boss] == NONE) {
        client_cmd(id, "slot1; drop");
		give_item(id,"weapon_m249");
		cs_set_user_bpammo(id, CSW_M249, get_cvar_num("msm_boss_ammo"));
		set_user_health(id, get_cvar_num("msm_boss_health"));
		client_cmd(0,"spk msm/boss_spawned");
        new nm[33]; get_user_name(id, nm, 32);
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5);
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_SPAWNED", nm);
        hero[id] = BOSS;
		switch(cs_get_user_team(id)) {
			case CS_TEAM_T: set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
			case CS_TEAM_CT: set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);
		}
	}
}

public HudTick(){
    for(new id = 1; id <= get_maxplayers(); id++){
        if(is_user_connected(id) && is_user_connected(id) && is_user_alive(id)){
            set_dhudmessage(43, 211, 88, 0.02, 0.60, 0, 6.0, 1.1, 0.3, 0.3);
            switch(msm_get_user_hero(id)){
                case NONE:{
                    show_dhudmessage(id, "%L %L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_NONE", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HP", get_user_health(id));
                }
                case SL:{
                    show_dhudmessage(id, "%L %L^n%L^n%L ^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_SL", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HERO_SL_SELFSTACK", attribute[id][sl_selfstack], LANG_PLAYER, "HP", get_user_health(id));
                }
                case UNDYING:{
                    show_dhudmessage(id, "%L %L^n%L^n%L^n%L^n%L %L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_UD", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "HERO_UD_HPSTACK", attribute[id][undying_hpstack], LANG_PLAYER, "HERO_UD_HPSTOLEN", attribute[id][undying_hpstolen_timed], LANG_PLAYER, "PASSIVE", LANG_PLAYER, "PASSIVE_POISON_TOUCH", LANG_PLAYER, "HP", get_user_health(id));
                }
                case BERSERK:{
                    show_dhudmessage(id, "%L %L^n%L^n%L %L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_BERSERK", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "PASSIVE", LANG_PLAYER, "BERSERK_POWERGAIN", LANG_PLAYER, "HP", get_user_health(id), LANG_PLAYER, "BERSERK_ULT", attribute[id][berserk_ult_rage]);
                }
                case ZEUS:{
                    show_dhudmessage(id, "%L %L^n%L^n%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_ZEUS", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER,"HP", get_user_health(id), LANG_PLAYER, "HERO_ULT", attribute[id][ult_counter]);
                }
                case KNIGHT:{
                    show_dhudmessage(id, "%L %L^n%L^n%L %L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_KNIGHT", LANG_PLAYER, "SCORE_SKILL", info[id][score], info[id][skill], LANG_PLAYER, "PASSIVE", LANG_PLAYER, "PASSIVE_KNIGHT_SHIELD", attribute[id][knight_shield], LANG_PLAYER, "HP", get_user_health(id));
                }
                case BOSS:{
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
                emit_sound(id, CHAN_STATIC, "msm/undying_poison.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM);
            }

            // Cooldowns for ultimates (ONLY FOR SECOND COOLDOWNS)
            if(attribute[id][is_ult_ready] == 0){
                attribute[id][ult_counter] -= 1;
                if(attribute[id][ult_counter] == 0 && is_user_alive(id) && is_user_connected(id)){
                    set_ult_active(id);
                }
            }
        }
    }
}

// Set the ultimate on cooldown to count again
public set_ult_active(id){
    switch(msm_get_user_hero(id)){
        case NONE:{
        }
        case SL:{
                        
        }
        case UNDYING:{
            
        }
        case BERSERK:{
            emit_sound(id,CHAN_STATIC,"msm/adrenaline_full.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            ColorChat(id, GREEN, "%L", LANG_PLAYER, "HERO_ULT_READY"); 
            attribute[id][ult_counter] = 0;
        }
        case ZEUS:{
            emit_sound(id,CHAN_STATIC,"msm/ultimate_ready.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
            ColorChat(id, GREEN, "%L", LANG_PLAYER, "HERO_ULT_READY"); 
            attribute[id][is_ult_ready] = 1;
            attribute[id][ult_counter] = 0;
        }
        case KNIGHT:{
            
        }
        case BOSS:{
                        
        }
    }
}

public OnPlayerResetMaxSpeed(id, Float:speed){
    if(!is_user_alive(id) || speed < 0)
	    return

    set_user_maxspeed(id, get_user_maxspeed(id))
}

// Closing data storage when plugin finished it's work
public plugin_end(){
	nvault_close(msm_vault);
}

public plugin_precache(){
    if(get_cvar_num("msm_enable_kill_announcer")){
    precache_sound("msm/firstblood.wav")
    precache_sound("msm/headshot.wav")
    precache_sound("msm/killingspree.wav")
    precache_sound("msm/maniac.wav")
    precache_sound("msm/massacre.wav")
    precache_sound("msm/multikill.wav")
    precache_sound("msm/serverjoin.wav")
    precache_sound("msm/triplekill.wav")
    precache_sound("msm/unstoppable.wav")
    }
    precache_sound("msm/boss_defeated.wav")
    precache_sound("msm/boss_spawned.wav")
    precache_sound("msm/boss_death.wav")
    precache_sound("msm/sl_spawn.wav")
    precache_sound("msm/none_spawn.wav")
    precache_sound("msm/undying_spawn.wav")
    precache_sound("msm/berserk_spawn.wav")
    precache_sound("msm/zeus_spawn.wav")
    precache_sound("msm/undying_poison.wav")
    precache_sound("msm/knight_shield_ready.wav")
    precache_sound("msm/knight_spawn.wav")
    precache_sound("msm/wp_bullet1.wav")
    precache_sound("msm/wp_bullet2.wav")
    precache_sound("msm/wp_bullet3.wav")
    precache_sound("msm/wp_bullet4.wav")
    precache_sound("msm/ultimate_ready.wav")
    dmgTakenHUD = CreateHudSyncObj();
    dmgDealtHUD = CreateHudSyncObj();
    announcehud = CreateHudSyncObj();
}
