#include < amxmodx >
#include < fun >
#include < dhudmessage >
#include < colorchat2 >

#pragma tabsize 0
#define plug "MSM"
#define ver "0.4"
#define auth "blurry & MuiX"
#define ADMIN_FLAG 'H'

enum _:InfoTable
{
    kills,
    headshots,
    score,
    healed
}
enum _:StatTable
{
    statheads,
    statkills,
    statdamage,
    stathpstolen,
    statdeaths,
    statfbmade,
}
new stat[128][StatTable]
new info[128][InfoTable]
new dmgTakenHUD, dmgDealtHUD
new isconnected[32]
new isFirstBlood = 0
new announcehud

public plugin_init()
{
    register_plugin(plug, ver, auth);
    register_event("SendAudio", "t_won", "a", "2&%!MRAD_terwin"); 	//TT win trigger
	register_event("SendAudio", "ct_won", "a", "2&%!MRAD_ctwin");	//CT win trigger
    register_event("Damage", "damage_taken", "b", "2!0", "3=0", "4!0");
    register_event( "DeathMsg","player_death","a");
    register_logevent( "round_start", 2, "1=Round_Start" );
    register_dictionary("msm.txt");
    dmgTakenHUD = CreateHudSyncObj();
    dmgDealtHUD = CreateHudSyncObj();
    announcehud = CreateHudSyncObj();
}

public client_putinserver(id){
    isconnected[id] = 1
    set_task(2.5,"welcomepl",id)
}

public client_disconnect(id){
    isconnected[id] = 0
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

// Triggers either first or second one depends on what team won.
public t_won(){

}

public ct_won(){

}

public round_start(){
    isFirstBlood = 0
    for(new id = 1; id <= get_maxplayers(); id++){
       // info[id][death] = 0
    }
}

// Damage Visualisation.
public damage_taken(id)
{
    if (is_user_connected(id))
    {
        new damage, attacker;
        damage = read_data(2)
        attacker = get_user_attacker(id)
        set_hudmessage(234, 75, 75, 0.54, 0.52, 0, 0.5, 0.30, 0.5, 0.5, -1)
        ShowSyncHudMsg(id, dmgTakenHUD, "%d", damage)
        if ((attacker > 0) && (attacker < 33))
        {
            set_hudmessage(15, 180, 90, 0.54, 0.45, 0, 0.5, 0.30, 0.5, 0.5, -1);
            ShowSyncHudMsg(attacker, dmgDealtHUD, "%d", damage);
        }
        //Calculating health we will give to player (attacker)
        if(get_user_flags(attacker) & ADMIN_FLAG){
        info[attacker][healed]= get_user_health(attacker) + 1;
        set_user_health(attacker,info[attacker][healed]);
        info[attacker][healed]= get_user_health(attacker)
        }
    }
}

// Triggers on any player death.
public player_death() 
{
    static killer, victim, hshot;
    killer = read_data(1);
    if (!is_user_connected(killer)) // Server crash fix "Out of bounds"
        return PLUGIN_HANDLED

    victim = read_data(2);
    hshot = read_data(3);
    new killername[32]
    get_user_name(killer, killername, 31);
    if (isFirstBlood == 0){     // First Blood
        set_hudmessage(212, 255, 255, -1.0, 0.2, 1, 6.0, 3.0, 0.5)
        ShowSyncHudMsg(0, announcehud, "%L", LANG_PLAYER, "FIRST_BLOOD", killername)
        client_cmd(0,"spk msm/firstblood")
        isFirstBlood = 1;
    }
    if (killer != victim && is_user_connected(killer) && is_user_connected(victim))
    {
        info[killer][score] += 10
        info[victim][score] -=10
        info[killer][kills]++
        info[victim][kills] = 0
        if (hshot)
        {
            info[killer][headshots] +=1
            info[killer][score] +=5
            client_cmd(0,"spk msm/headshot")
        }
        switch(info[killer][kills]){
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
}