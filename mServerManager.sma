#include < amxmodx >    //Main amxmodx include.
#include < amxmisc >    //Old menu.
#include < fun >        //For glow effect.
#include < dhudmessage >//For new format of hud messages
#include < colorchat2 > //For colored simple chat.
#include < cstrike >    //For catching player's team and giving ammo.
#include < hamsandwich >//For catching player's damage and increasing it.
#include < fakemeta >   //For custom player models.
#include < csdm >


#pragma     tabsize 0
#define plug    "MSM"
#define ver     "0.8p"
#define auth    "blurry & MuiX"
#define ADMIN_FLAG  'H'

#define MSM_TASK_RANDOM      675    // ID of random task.

#define MSM_BOSS_HEALTH 2000					//Boss health.
#define MSM_BOSS_AMMO   300						//Ammo for boss.
#define MSM_BOSS_PLAYERS    4					//Start choosing boss if 'n' player or more.
#define MSM_BOSS_DAMAGE 2.3						//Damage multiplier.

enum _:InfoTable
{
    kills,
    headshots,
    score,
    healed
};
new info[128][InfoTable];
new dmgTakenHUD, dmgDealtHUD;
new isFirstBlood = 0;
new announcehud;
new msm_boss, msm_active = 0;

public plugin_init()
{
    register_plugin(plug, ver, auth);
    register_event("DeathMsg","player_death","a");                      //
    register_logevent("round_start", 2, "1=Round_Start");               //
    register_dictionary("msm.txt");                                     //
    RegisterHam(Ham_TakeDamage, "player", "fwd_Take_Damage", 0);        // Catching incoming damage.
    register_clcmd( "say /svm","class_change" );
    set_task(15.0, "msm_boss_random",_,_,_,"b");                        // Finding a boss each 15 seconds. TODO: cfg
}

//////////////// Trying this once again ////////////////

#include "PREF_SERVMANAGER/intMenu.inl"
#include "PREF_SERVMANAGER/preSpawnInt.inl"

////////////////////////////////////////////////////////

public client_putinserver(id){
    set_task(2.5,"welcomepl",id)
    hero[id] = NONE
}

public client_disconnect(id){
    new dcName[32]
    if( msm_active == 1 && id == msm_boss ) {    //Checking if boss left or not and announcing next one.
		msm_boss = 0;
		msm_active = 0;
		ColorChat(0, RED, "%L", LANG_PLAYER, "BOSS_LEFT", get_user_name(id,dcName,31));
	}
    hero[id] = NONE
    return PLUGIN_CONTINUE;
}

public welcomepl(id){
    set_task(1.0,"record_demo", id)
    client_cmd(id,"spk msm/serverjoin")
}

public record_demo(id){
    new mapname[32]; new randomnrd = random_num(1,9999)
    get_mapname(mapname,31)
    ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "DEMO_RECORDING", mapname, randomnrd)
    client_cmd(id,"record fireplay_%s%d", mapname, randomnrd)
}

public round_start(){
    isFirstBlood = 0
}

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

    if(victim == msm_boss) {    //Death of boss.
		cs_reset_user_model(victim);
		msm_boss = 0; set_user_rendering(victim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		msm_active = 0;
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5)
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_DEATH", killername);
        client_cmd(0,"spk msm/boss_defeated")
        emit_sound(victim,CHAN_STATIC,"msm/boss_death.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	}

    if (killer != victim)
    {
        if (isFirstBlood == 0){     // First Blood (moved here because suiciding was causing first blood)
            set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
            ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "FIRST_BLOOD", killername)
            client_cmd(0,"spk msm/firstblood")
            isFirstBlood = 1;
        }
        info[killer][score] += 10
        info[victim][score] -=10
        info[killer][kills] +=1
        info[victim][kills] = 0
        if (hshot)
        {
            info[killer][headshots] +=1
            info[killer][score] +=5
            client_cmd(0,"spk msm/headshot")
        }
        switch(info[killer][kills]){    // Simply Announcing killstreaks
            case 3:{
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "TRIPLE_KILL", killername);
                client_cmd(0,"spk msm/triplekill")
            }
            case 5:{
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MULTI_KILL", killername);
                client_cmd(0,"spk msm/multikill")
            }
            case 6:{
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "KILLING_SPREE", killername);
                client_cmd(0,"spk msm/killingspree")
            }
            case 7:{
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "UNSTOPPABLE", killername);
                client_cmd(0,"spk msm/unstoppable")
            }
            case 8:{
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MANIAC", killername);
                client_cmd(0,"spk msm/maniac")
            }
            case 10:{
                set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
                ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "MASSACRE", killername);
                client_cmd(0,"spk msm/massacre")
            }
        }
    }
    return PLUGIN_HANDLED
}

// Catching incoming damage
public fwd_Take_Damage(victim, inflicator, attacker, Float:damage) {
    // Some checking before doing anything.
	if(!is_user_connected(attacker) | !is_user_connected(victim)) return;
	if(victim == attacker || !victim) return;
    if(get_user_team (attacker) == get_user_team (victim)) return

    if(msm_boss == attacker){
	    SetHamParamFloat( 4, damage * MSM_BOSS_DAMAGE );    //Multiplying damage for boss
    }
    new damagepure = floatround(damage, floatround_round)
    set_hudmessage(234, 75, 75, 0.54, 0.52, 0, 0.5, 0.30, 0.5, 0.5, -1);    // Didn't test this (TODO #26)
    ShowSyncHudMsg(victim, dmgTakenHUD, "%d", damagepure);

    set_hudmessage(15, 180, 90, 0.54, 0.45, 0, 0.5, 0.30, 0.5, 0.5, -1);
    ShowSyncHudMsg(attacker, dmgDealtHUD, "%d", damagepure);

        //Calculating health we will give to player (attacker) (actually will be reworked since it's useless for now)
        if(get_user_flags(attacker) & ADMIN_FLAG){
        info[attacker][healed]= get_user_health(attacker) + 1;
        set_user_health(attacker,info[attacker][healed]);
        info[attacker][healed]= get_user_health(attacker)
        }
        // Here goes stealing attributes (TODO #27)
        // Code blah blah...
}

// Simple as that.
stock float_to_num(Float:num) {
	new str[16]; float_to_str( num, str, 15 );
	new buffer = contain( str, "," );
	format( str, buffer, str );
	return str_to_num( str );
}

stock freeze_player(id, status) {           // Just a func of freezing player on place. P useful sometimes so I'll leave it.
	if(!is_user_connected(id) && !is_user_alive(id)) return false;
	set_user_godmode(id, status);
	if(status) {
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

public msm_boss_random() {      // Choosing random player to be a boss
	if(msm_active == 0) {
		static Players[32], Count, id_rand;
		get_players(Players, Count, "ah");
		id_rand = random_num(0, Count - 1);
		msm_boss = Players[id_rand];
        if(hero[msm_boss] != NONE){
            msm_boss = 0
            return PLUGIN_HANDLED;
        }
		msm_active = 1;
        msm_set_user_boss(msm_boss);
	}
    return PLUGIN_HANDLED;
}

public msm_set_user_boss(id) {
	if(is_user_connected(id) && hero[msm_boss] == NONE) {
		cs_set_user_model(id,"msm_pl_boss");
		give_item(id,"weapon_m249");
		cs_set_user_bpammo(id, CSW_M249, MSM_BOSS_AMMO);
		set_user_health(id, MSM_BOSS_HEALTH);
		client_cmd(0,"spk msm/boss_spawned")
        new nm[33]; get_user_name(id, nm, 32)
        set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.5, 1.5)
        show_dhudmessage(0, "%L", LANG_PLAYER, "BOSS_SPAWNED", nm);

		switch(cs_get_user_team(id)) {
			case CS_TEAM_T: set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
			case CS_TEAM_CT: set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);
		}
	}
}

stock msm_get_user_hero(id){
    return hero[id]
}

public plugin_precache(){
    precache_sound("msm/firstblood.wav")
    precache_sound("msm/headshot.wav")
    precache_sound("msm/killingspree.wav")
    precache_sound("msm/maniac.wav")
    precache_sound("msm/massacre.wav")
    precache_sound("msm/multikill.wav")
    precache_sound("msm/serverjoin.wav")
    precache_sound("msm/triplekill.wav")
    precache_sound("msm/unstoppable.wav")
    precache_sound("msm/boss_defeated.wav")
    precache_sound("msm/boss_spawned.wav")
    precache_sound("msm/boss_death.wav")
    precache_sound("msm/sl.wav")
    precache_sound("msm/none_laugh.wav")
    precache_sound("msm/none_laugh1.wav")
    precache_sound("msm/none_laugh2.wav")
    precache_model("models/player/msm_pl_boss/msm_pl_boss.mdl")
    dmgTakenHUD = CreateHudSyncObj();
    dmgDealtHUD = CreateHudSyncObj();
    announcehud = CreateHudSyncObj();
}