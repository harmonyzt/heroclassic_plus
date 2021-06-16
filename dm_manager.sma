#include <amxmodx>
#include <fun>
#include <dhudmessage>
#pragma tabsize 0
#define plug "Damage manager"
#define ver "0.1"
#define auth "Harmony & MuiX"

enum _:InfoTable
{
    kills,
    headshots,
    deaths,
    score
}

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

public t_won(){

}
public ct_won(){

}

public damage_taken(id)     //TODO - Test this
{
    if (is_user_connected(id))
    {
        new damage, attacker;
        damage = read_data(2)
        attacker = get_user_attacker(id)
        set_hudmessage(85, 170, 255, 0.54, 0.52, 0, 0.15, 0.15, 0.10, 0.10, -1)
        ShowSyncHudMsg(id, dmgDealtHUD, "%d", damage)
        if ((attacker > 0) && (attacker < 33))
        {
            set_hudmessage(85, 170, 255, 0.54, 0.45, 0, 0.15, 0.15, 0.10, 0.10, -1);
            ShowSyncHudMsg(id, dmgTakenHUD, "%d", damage);
        }
    }
}

public player_death()  //TODO - Test this
{
    static killer, victim, hshot;
    killer = read_data(1);
    if (!is_user_connected(killer)) //Server crash fix
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