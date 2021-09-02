#include < amxmodx >        //Main amxmodx include.
#include < amxmisc >        //Old menu.
#include < fun >            //For glow effect.
#include < dhudmessage >    //For new format of hud messages.
#include < colorchat2 >     //For colored simple chat.
#include < cstrike >        //For catching player's team and giving ammo.
#include < hamsandwich >    //For catching player's damage and increasing it.
#include < fakemeta >       //For custom player models.
#include < csdm >


#pragma     tabsize 0
#define plug    "MSM"
#define ver     "0.8p"
#define auth    "blurry & MuiX"
#define ADMIN_FLAG  'H'

#define MSM_TASK_RANDOM      675                // ID of random task.

#define MSM_BOSS_HEALTH 2000					//Boss health.
#define MSM_BOSS_AMMO   300						//Ammo for boss.
#define MSM_BOSS_DAMAGE 2.3						//Damage multiplier.

enum _:InfoTable
{
    kills,
    headshots,
    score
};

new info[128][InfoTable];
new dmgTakenHUD, dmgDealtHUD;
new isFirstBlood = 0;
new announcehud;
new msm_boss, msm_active = 0;

public plugin_init()
{
    register_plugin(plug, ver, auth);
    register_event("DeathMsg","player_death","a");                      // Catching player's death.
    register_logevent("round_start", 2, "1=Round_Start");               // Catching start of the round.
    register_dictionary("msm.txt");                                     // Registering lang file.
    RegisterHam(Ham_TakeDamage, "player", "fwd_Take_Damage", 0);        // Catching incoming damage.
    RegisterHam(Ham_Spawn,"player","player_respawn")                    // Catching player's respawn.
    register_clcmd( "say /svm","class_change" );                        // Registering menu (or a command to call menu)
    set_task(15.0, "msm_boss_random",_,_,_,"b");                        // Finding a boss each 'n' seconds. TODO: cfg
    set_task(0.6, "info_display",_,_,_,"b");                            // Displaying info for each player.
}

//////////////// Trying this once again ////////////////

#include "PREF_SERVMANAGER/intMenu.inl"
#include "PREF_SERVMANAGER/deathEvent.inl"
#include "PREF_SERVMANAGER/playerRespawn.inl"
//#include "PREF_SERVMANAGER/nativeSupport.inl"     // Under development
#include "PREF_SERVMANAGER/botSupport.inl"

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
        //for(new id = 1; id <= get_maxplayers(); id++){
        //}
}

// Catching incoming damage.
public fwd_Take_Damage(victim, inflicator, attacker, Float:damage) {
    // Some checking before doing anything.
	if(!is_user_connected(attacker) | !is_user_connected(victim)) return;
	if(victim == attacker || !victim) return;
    if(get_user_team (attacker) == get_user_team (victim)) return

    if(msm_boss == attacker){
	    SetHamParamFloat( 4, damage * MSM_BOSS_DAMAGE );    //Multiplying damage for boss.
    }

    new damagepure = floatround(damage, floatround_round)
    set_hudmessage(234, 75, 75, 0.54, 0.52, 0, 0.5, 0.30, 0.5, 0.5, -1); 
    ShowSyncHudMsg(victim, dmgTakenHUD, "%d", damagepure);

    set_hudmessage(15, 180, 90, 0.54, 0.45, 0, 0.5, 0.30, 0.5, 0.5, -1);
    ShowSyncHudMsg(attacker, dmgDealtHUD, "%d", damagepure);

        // Here goes stealing attributes
        // Code blah blah...
        switch(msm_get_user_hero(attacker)){

            case NONE:{
                // None of the effects
            }

            case SL:{
                new Float:maxspeedreduceformula[33]
                attribute[victim][sl_leashstack] += 1
                attribute[attacker][sl_selfstack] += 1
                if(attribute[victim][sl_leashstack] < 1){
                    maxspeedreduceformula[victim] = get_user_maxspeed(victim) - float(attribute[victim][sl_leashstack])
                    set_user_maxspeed(victim, maxspeedreduceformula[victim])
                }
            }

            case UNDYING:{
                
            }

        }
}

stock freeze_player(id, status) {           // Just a func of freezing player on place. P useful sometimes so I'll leave it for something later.
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

public info_display(){
    for(new id = 1; id <= get_maxplayers(); id++){
        if(is_user_connected(id)){
            switch(msm_get_user_hero(id)){
                case NONE:{
                    // Skiping this
                }
                case SL:{
                set_dhudmessage(43, 211, 88, 0.0, 0.67, 0, 6.0, 0.5, 0.2, 0.2);
                show_dhudmessage(id, "%L%L^n%L", LANG_PLAYER, "HERO_NAME", LANG_PLAYER, "HERO_SL", LANG_PLAYER, "HERO_SL_SELFSTACK", attribute[id][sl_selfstack]);
                }
            }
        }
    }
    return PLUGIN_HANDLED;
}

public msm_get_user_hero(id){
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