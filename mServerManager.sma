#include < amxmodx >
#include < fun >
#include < dhudmessage >
#include < colorchat2 >

#pragma tabsize 0
#define plug "MSM"
#define ver "0.3"
#define auth "blurry & MuiX"
#define ADMIN_FLAG 'H'

enum _:InfoTable
{
    kills,
    headshots,
    deaths,
    score,
    healed
}
enum _:StatTable
{
    statheads,
    statkills,
    statdamage,
    stathpstolen,
    statdeaths
}
new stat[128][StatTable]
new info[128][InfoTable]
new dmgTakenHUD, dmgDealtHUD
new isconnected[32]

public plugin_init()
{
    register_plugin(plug, ver, auth);
    register_event("SendAudio", "t_won", "a", "2&%!MRAD_terwin"); 	//TT win trigger
	register_event("SendAudio", "ct_won", "a", "2&%!MRAD_ctwin");	//CT win trigger
    register_event("Damage", "damage_taken", "b", "2!0", "3=0", "4!0");
    register_event( "DeathMsg","player_death","a");
    dmgTakenHUD = CreateHudSyncObj();
    dmgDealtHUD = CreateHudSyncObj();
}

public client_putinserver(id){
    isconnected[32] = 1
    set_task(2.5,"welcomepl",id)
}

public client_disconnect(id){
    isconnected[32] = 0
}

public welcomepl(id){
    set_task(1.0,"record_demo", id)
    client_cmd(id,"spk msm/welcome")
}

public record_demo(id){
    new mapname[32]; new randomnrd = random_num(1,9999)
    get_mapname(mapname,31)
    ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "DEMO_RECORDING", mapname[32], randomnrd)
    client_cmd(id,"record fireplay_%s%d", apname[32], randomnrd)
}

// Triggers either first or second one depends on what team won.
public t_won(){

}
public ct_won(){

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

    if (killer != victim && is_user_connected(killer) && is_user_connected(victim))
    {
        info[killer][score] += 10
        info[victim][score] -=10
        if (hshot)
        {
            info[killer][headshots] +=1
            info[killer][score] +=5
        }  
    }
    return PLUGIN_HANDLED
}