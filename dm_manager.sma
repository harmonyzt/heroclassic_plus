#include <amxmodx>
#include <fun>
#include <dhudmessage>

#pragma tabsize 0
#define plug "RPG UM [Utility Manager]"
#define ver "0.2"
#define auth "blurry & MuiX"
#define ADMIN_FLAG H

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
        if(get_user_flags == ADMIN_FLAG){
        info[attacker][healed]= get_user_health(attacker) + 1;
        set_user_health(attacker,info[attacker][healed]);
        info[attacker][healed]= get_user_health(attacker)
        }
    }
}

// Calling function on player death.
public player_death() 
{
    static killer, victim, hshot;
    killer = read_data(1);
    if (!is_user_connected(killer)) // Server crash fix or "Out of bounds" error
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