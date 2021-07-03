/********************************************************************************************************		
----------------------	
Note
I made this description in english because AMXX-Studio unlike russian language on ANSI AND UTF-8 coding
--------------------			
Its modernized plugin version of original Public or CSDM
If you want more meat, type /ffa (for meat disabled :DDDDDD)
Code Optimization - mmmmm......
Added Status Mode (CSDM, PUBLIC)
Added One Status Bar (In past I made 3 :DDD)
Added FFA MODE (for bots very useful and meat :D)
Added Preset or None Spawn
Added beautyfull Dhud Messages
Added Sync Hud Message
Added Prazdnik
Added demo record on server name and map
Added anti dhud repeat (FFA On i.t.d)
Added Welcome Hudmessage
Added Reset Score
Added some protection for meat (Disabled FFA on Base Spawn :DDDDDD)
Added some protection for already activated functions
Added server MENU
Added Administrator menu (More bugs, later, I fix them)
Added Player Menu
Added Add-on (status_Value)
MORE FUNCTIONS
For users of flags H in new round + 5 Exp Army Ranks (Neded Evil Army ranks)
Needed plugins for good works of main plugin
1) Evil Army Ranks (All versions)
2) Army Ranks (Some versions)
3) CSDM MAIN (VERY IMPORTANT)
4) CSDM FFA (VERY IMPORTANT)
5) CSDM EQUIP (on your taste)
6) CSDM PRESET SPAWN (VERY IMPORTANT)
7) CSDM TICKETS (VERY IMPORTANT)
7) GUNGAME REFIL AMMO gg_ammo
8) WEAPON REMOVER test_wpnrmv (CSDM wpn remover bad works)
**************************************************************************************************************/

#include < amxmodx >	//Core of this Plugin
#include < fun >	// Nedded for set_user_frags
#include < dhudmessage >	// Nedded for show_dhudmessage
#include < cstrike >	// Nedded for cs_set_user_deaths
#include < csdm >	// Nedded for CSDM COMMANDS
#include < hamsandwich >	//Nedded for Check new Round
#include < evil_army >		//Nedded for Exp+
#include < ColorChat2 >		//color chat doesnt works (* colorchat2)
#include < amxmisc >		//configsDir



new Cvar_Prazdnik,csdmpub_autodemo, csdmpub_welc, csdmpub_exp;
new ffam = 0
new preseting = 0
new name[33]
new rejim = 0
new knife_mode = 0

new rejim2	//Sync Obj
new wcm 		//Sync Obj

new adminMenu = 1
new adminname[33]
new one_open

public plugin_init()
{
Cvar_Prazdnik = register_cvar("csdmpub_pr","0")		//EcJIu y Bac Ha CerBePe Prazdnik uJIu 4To to tipo togo, to stavte 1
csdmpub_autodemo = register_cvar("csdmpub_autodemo","1")
csdmpub_welc = register_cvar("csdmpub_welc","1")
csdmpub_exp = register_cvar("csdmpub_exp","5")
RegisterHam(Ham_CS_RoundRespawn,"player","MoreThinks") 	//novaya func
register_plugin("CSDM OR PUBLIC","5.1","andrey");	
register_clcmd("say /pub","PublicAct"); 			//short command
register_clcmd("say_team /pub","PublicAct"); 		//short command
register_clcmd("say /public","PublicAct");
register_clcmd("say_team /public","PublicAct");
register_clcmd("say /csdm","CSDMAct");
register_clcmd("say_team /csdm","CSDMAct");
register_clcmd("say /rs", "rs");
register_clcmd("say /ffa", "ffa");
register_clcmd("say /ffa_off", "ffa_off");
register_clcmd( "say /preset_spawn","Spawn_presetOn")
register_clcmd( "say /none_spawn","Spawn_presetOff")
register_clcmd( "army_menu", "menu_server" )		/// YES!!! I MADE THIS MENU!!!
register_clcmd( "say /army_menu", "menu_server" )		/// YES!!! I MADE THIS MENU!!!
register_clcmd( "adminmenu", "menu_admin" )		/// YES!!! I MADE THIS MENU!!!
register_clcmd( "say /adminmenu", "menu_admin" )		/// YES!!! I MADE THIS MENU!!!
set_msg_block(get_user_msgid("HudTextArgs"), BLOCK_SET)
register_event("CurWeapon", "evCurWeapon", "be", "1=1", "2!29")
wcm = CreateHudSyncObj()
rejim2 = CreateHudSyncObj()
set_task(1.0, "show_mode",_,_,_, "b")
return PLUGIN_CONTINUE
}


public plugin_cfg()
{
	new szCfgDir[64], szFile[192];
	get_configsdir(szCfgDir, charsmax(szCfgDir));
	formatex(szFile,charsmax(szFile),"%s/csdmorpub/csdmorpub.cfg",szCfgDir);
	if(file_exists(szFile))
		server_cmd("exec %s", szFile);
}



public menu_server(id)
{
            {
	new a_Menu = menu_create("\r.::\wМеню Сервера\r::.^n\dMADE ANDREY", "menu_rendering")
	menu_additem(a_Menu, "\yТоп \r10", "1", 0);
	menu_additem(a_Menu, "\yТоп \r30", "2", 0);
	menu_additem(a_Menu, "\yОбнулить счёт", "3", 0);
	menu_additem(a_Menu, "\yВключить \rCSDM", "4", 0);
	menu_additem(a_Menu, "\yВключить \rPUBLIC", "5", 0);
	menu_additem(a_Menu, "\yВключить \rFFA", "6", 0);
	menu_additem(a_Menu, "\yВключить \rСл. Возрождение", "7", 0);
	menu_additem(a_Menu, "\yВыключить \rFFA", "8", 0);
	menu_additem(a_Menu, "\yВключить \rОб. Возрождение", "9", 0);
	menu_additem(a_Menu, "\rМеню Администратора", "10", 0);
	menu_additem(a_Menu,"\yСтатистика \rArmy Ranks","11",0)
	menu_additem(a_Menu,"\yМеню \rИгрока","12",0)
	menu_setprop(a_Menu, MPROP_BACKNAME, "Назад")
	menu_setprop(a_Menu, MPROP_NEXTNAME, "Далее")
	menu_setprop(a_Menu, MPROP_EXITNAME, "Выход")
 
	menu_display(id, a_Menu, 0)
            }
}

public menu_rendering( id, menu, item )
{
    if( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
    new data[6], iName[64];
    new access, callback;
     
    menu_item_getinfo( menu, item, access, data,5, iName, 63, callback );
    new key = str_to_num( data );
    switch( key )
    {
        case 1:
        {
                        client_cmd(id,"say /top10")
        }
        case 2:
        {
                         client_cmd(id,"say /top30")
        }
        case 3:
        {
                         rs(id)
         }    
        case 4:
        {
                        CSDMAct(id)
        }
        case 5:
        {
                         PublicAct(id)
        }
        case 6:
        {
                        ffa(id)
        }
	        case 7:
        {
                        Spawn_presetOn(id)
        }
	        case 8:
        {
                        ffa_off(id)
        }
	        case 9:
        {
                        Spawn_presetOff(id)
        }
		        case 10:
        {
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
                        menu_admin(id)
		}
        }
case 11:
        {
                        client_cmd(id,"say /statsa")
        }
        case 12:
        {
                        menu_player(id)
        }
    }  
    menu_destroy( menu );
    return PLUGIN_HANDLED;
}




public menu_admin(id)
{
{
	if(get_map_block(id)==1)
	{
	ColorChat(id,RED,"На этой карте не работает Админ-Меню.")
	return	
	}
	if(one_open==1)
	{
	ColorChat(id,RED,"Вы уже открывали Админ-меню в этом раунде...")
	}
	if (get_user_flags(id) & ADMIN_LEVEL_H)
            {
	new b_Menu = menu_create("\rМеню Администратора ^n\dMADE ANDREY", "menu_rendering2")
	menu_additem(b_Menu, "\rВзять \y[AK-47 Gold]", "1", 0);
	menu_additem(b_Menu, "\rВзять \y[AK-47]", "2", 0);
	menu_additem(b_Menu, "\rВзять \y[M4A1]", "3", 0);
	menu_additem(b_Menu, "\rВзять \y[M4A1 Gold]", "4", 0);
	menu_additem(b_Menu, "\rВзять \y[$5000]", "5", 0);
	menu_additem(b_Menu, "\rБольше не показывать это меню.", "6", 0);
	menu_additem(b_Menu, "\rВзять \y20 \rОпыта", "7", 0);
	
	menu_additem(b_Menu, "\rВключить раунд на \yножах", "8", 0);
	menu_setprop(b_Menu, MPROP_BACKNAME, "Назад")
	menu_setprop(b_Menu, MPROP_NEXTNAME, "Далее")
	menu_setprop(b_Menu, MPROP_EXITNAME, "Выход")
 
	menu_display(id, b_Menu, 0)
            }else{
	  ColorChat(id,GREY,"У вас нет доступа к Админ-Меню.")
	}
}	
}


public menu_rendering2( id, menu, item )
{
    if( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
    new data[6], iName[64];
    new access, callback;
    
    menu_item_getinfo( menu, item, access, data,5, iName, 63, callback );
    new key = str_to_num( data );
    switch( key )
    {
        case 1:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	get_user_name(id,adminname,32)
	client_cmd(id,"say /ak")
	cs_set_user_bpammo( id, CSW_AK47, 90);
        }
        case 2:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	get_user_name(id,adminname,32)
	give_item(id,"weapon_ak47")
	cs_set_user_bpammo( id, CSW_AK47, 90);
	ColorChat(id,RED,"Админ ...:::%s:::... взял [AK-47]",adminname)
        }
        case 3:
        {
if(!is_user_alive(id))
{
ColorChat(id,RED,"Доступно только для живых игроков!")
}
get_user_name(id,adminname,32)
give_item(id,"weapon_m4a1")
cs_set_user_bpammo( id, CSW_M4A1, 90);
ColorChat(id,RED,"Админ ...:::%s:::... взял [M4A1]",adminname)
        }
case 4:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	get_user_name(id,adminname,32)
	client_cmd(id,"say /m4")
	cs_set_user_bpammo( id, CSW_M4A1, 90);
        }
case 5:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	cs_set_user_money(id,cs_get_user_money(id) + 5000)
        }
case 6:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	adminMenu = 0
	ColorChat(id,RED,"Больше не показываем это меню.")
        }
	case 7:{
	if(!is_user_alive(id)){
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	if(one_open==0)
	{
	set_user_exp(id, get_user_exp(id) + 20)
	ColorChat(id,GREEN,"Вы взяли 20 Опыта!")
	}else{
	ColorChat(id,RED,"Вы не можете взять это 2 раза за раунд!")
	return PLUGIN_HANDLED
	}
	one_open=1
}

case 8:{
server_cmd("sv_restart 1")
set_task(3.0,"knife_start")
}
    }
    menu_destroy( menu );
    return PLUGIN_HANDLED
}

public knife_start(id)
{
server_cmd("pb_jasonmode 1")
set_hudmessage(255,0,0,-1.0,-1.0,1,1.0,12.0,0.6,0.6,_)
show_hudmessage(id,"НОЖИ НОЖИ НОЖИ ^nДАВАЙ, ЗАРЕЖЬ ИХ ВСЕХ")
knife_mode =1
}


public evCurWeapon(id) {
if (knife_mode ==1)
engclient_cmd(id,"weapon_knife")
}

public menu_player(id)
{
{
            {
	new c_Menu = menu_create("\yМеню \rИгрока ^n\dMADE ANDREY", "menu_rendering3")
	menu_additem(c_Menu, "\rВзять \y[AK-47 Gold]", "1", 0);
	menu_additem(c_Menu, "\rВзять \y[M4A1 Gold]", "2", 0);
	menu_setprop(c_Menu, MPROP_BACKNAME, "Назад")
	menu_setprop(c_Menu, MPROP_NEXTNAME, "Далее")
	menu_setprop(c_Menu, MPROP_EXITNAME, "Выход")
 
	menu_display(id, c_Menu, 0)
	}
}	
}


public menu_rendering3( id, menu, item )
{
    if( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
    new data[6], iName[64];
    new access, callback;
    
    menu_item_getinfo( menu, item, access, data,5, iName, 63, callback );
    new key = str_to_num( data );
    switch( key )
    {
        case 1:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	get_user_name(id,adminname,32)
	client_cmd(id,"say /ak")
	cs_set_user_bpammo( id, CSW_AK47, 90);
        }

case 2:
        {
	if(!is_user_alive(id))
	{
	ColorChat(id,RED,"Доступно только для живых игроков!")
	}
	get_user_name(id,adminname,32)
	client_cmd(id,"say /m4")
	cs_set_user_bpammo( id, CSW_M4A1, 90);
        }
}  
    menu_destroy( menu );
    return PLUGIN_HANDLED;
}








public demo(id)
{
if(get_pcvar_num(csdmpub_autodemo)==1)
{
new getmap[33] ;get_mapname(getmap,32)
client_cmd(id,"record ^"ShalnayaPulya_%s^"",getmap)
ColorChat(id,RED,"-----------------------------------------")
ColorChat(id,GREY,"Сейчас идет запись демо")
ColorChat(id,GREY,"Имя демо: ShalnayaPulya_%s", getmap)
ColorChat(id,GREY,"Плагин сделал Андрей")
ColorChat(id,RED,"-----------------------------------------")
}else{
return
}
}

public MoreThinks(adm)	
{
one_open=0
if (get_user_flags(adm) & ADMIN_LEVEL_H )
	{
	new exp = get_user_exp(adm)
	set_user_exp(adm,exp + get_pcvar_num(csdmpub_exp))
	set_dhudmessage(99, 184, 255, -1.0, 0.71, 1, 6.0, 3.0, 1.1, 1.5)
	show_dhudmessage(adm,"Вы получили бонус! %d опыта!", get_pcvar_num(csdmpub_exp))
	}
if( get_pcvar_num(Cvar_Prazdnik) == 1)
	{
	set_dhudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.75, 1, 0.2, 6.0, 1.1, 1.5)
	show_dhudmessage(adm,"На сервере Праздник! Поздравляем!!!")
	server_cmd("sv_gravity 600")
	set_user_rendering(adm, kRenderFxGlowShell, random_num(0,255),  random_num(0,255), random_num(0,255), kRenderNormal, 20)
	}
if( get_pcvar_num(Cvar_Prazdnik) == 0)
{
server_cmd("sv_gravity 800")
set_user_rendering(adm, kRenderFxNone, random_num(0,255),  random_num(0,255), random_num(0,50), kRenderNormal, 20)
}

server_cmd("amx_parachute @all")

if (adminMenu == 1)
{
if (get_user_flags(adm) & ADMIN_LEVEL_H )
{
menu_admin(adm)
}
}

if (adminMenu == 0)
{
ColorChat(adm,GREY,"Напиши /adminmenu чтобы открыть Админ-Меню.")	
}
knife_mode=0
if(knife_mode==0){
server_cmd("pb_jasonmode 0")
}
}

public show_mode(id)
{
if (rejim == 0)
{
pause("ac","test_wpnrmv.amxx")
pause("ac","gg_ammo.amxx")	
}

if (rejim == 1)
{
unpause("ac","test_wpnrmv.amxx")
unpause("ac","gg_ammo.amxx")	
}
new rand_r=random_num(0,255)
new rand_g=random_num(0,255)
set_hudmessage(rand_r, rand_g, 100, -1.0, 0.00, 0, 1.5, 1.0, _)
ShowSyncHudMsg(id,rejim2,"Сейчас включен режим: %s ^n%s ^n%s",rejim == 0 ? "PUBLIC":"CSDM", ffam ==0? "Режим FFA: Выключен":"Режим FFA: Включен", preseting ==0? "Возрождение: Обычное":"Возрождение: Случайное")
}


public Spawn_presetOff(id)
{
if (preseting == 0)
{
set_dhudmessage(99, 184, 255, -1.0, 0.55, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [Обычное появление] уже включен!");
return;	
}
csdm_setstyle("none")	
set_dhudmessage(99, 184, 255, -1.0, 0.55, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [Обычное возрождение] Активирован!");
preseting = 0
}


public Spawn_presetOn(id)
{
if (rejim == 0)
{
set_dhudmessage(99, 184, 255, -1.0, 0.60, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Нельзя активировать [Случайное появление] с режимом [PUBLIC]");
emit_sound(id, CHAN_WEAPON, "csdmpub/Error.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
return;	
}
if (preseting == 1)
{
set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [Случайное появление] уже включен!");
return;	
}
csdm_setstyle("preset")
set_dhudmessage(99, 184, 255, -1.0, 0.60, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [Случайное Возрождение] Активирован!");
preseting = 1
}

public ffa(id)
{
if (rejim == 0)
{
set_dhudmessage(99, 184, 255, -1.0, 0.60, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Нельзя активировать [FFA Режим] с режимом [PUBLIC]");
emit_sound(id, CHAN_WEAPON, "csdmpub/Error.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
return;
}
if (preseting == 0)
{
set_dhudmessage(99, 184, 255, -1.0, 0.60, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Нельзя включать [Режим FFA], если не включено [Случайное появление]");
emit_sound(id, CHAN_WEAPON, "csdmpub/Error.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
return;
}
if (ffam == 1)
{
set_dhudmessage(99, 184, 255, -1.0, 0.70, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [FFA] уже включен!");
return;
}
csdm_set_ffa(1)
server_cmd("pb_ffa 1")
set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [FFA] Включен!");
ffam = 1
}

public PublicAct(id)
{
if (rejim == 0)
{
set_dhudmessage(99, 184, 255, -1.0, 0.70, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [Public] уже включен!");
return;
}
server_cmd("csdm_disable")
server_cmd("pb_ffa 0")
server_cmd("sv_restart 1")
set_task(4.0,"pub_message");
csdm_setstyle("none")
rejim = 0
ffam = 0
preseting = 0
}

public client_disconnect(id)
{
if (is_user_bot(id))
return

if (is_user_hltv(id))
return

server_cmd("pb_ffa 0")

	
}

public ffa_off(id)
{
if (ffam == 0)
{
set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [FFA] уже выключен!");
return;
}
csdm_set_ffa(0)
server_cmd("pb_ffa 0")
set_dhudmessage(99, 184, 255, -1.0, 0.60, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [FFA] Выключен!");
ffam = 0
}




public rs(id)
{
set_user_frags(id, 0);
cs_set_user_deaths(id, 0);
set_user_frags(id, 0);		//Rs geustvuet tolko posle 2 pa3a
cs_set_user_deaths(id, 0);	//Rs geustvuet tolko posle 2 pa3a
get_user_name(id, name, 32);
set_dhudmessage(99, 184, 255, -1.0, 0.60, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "%s, Ты обнулил счет :D", name);
emit_sound(id, CHAN_WEAPON, "csdmpub/bell.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}




public CSDMAct(id)
{
if (rejim == 1)
{
set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [CSDM]  уже включен!");
return;
}
server_cmd("sv_restart 1");
server_cmd("csdm_enable")
set_task(4.0,"csdm_message");
csdm_setstyle("none")		//6e3 etogo IIJIariny meshaet config csdm.cfg
rejim = 1
preseting = 0
}

public zdarova(pid)
{
server_cmd("amx_parachute @all")
if(get_pcvar_num(csdmpub_welc)==1)
{
set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, -1.0, 1, 6.0, 5.0)
ShowSyncHudMsg(pid,wcm,"---Добро пожаловать на сервер--- ^n---[Шальная Пуля 14+]--- ^n---Мы всегда рады тебя  видеть!--- ^n---Удачной Игры!---")
}else{
return	
}
}


public csdm_message(id)
{
set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [CSDM] Включен!");
}

public client_putinserver(id)
{
if (is_user_bot(id))
return			//anti crash cs

if (is_user_hltv(id))
return			//anti crash cs

set_task(8.0,"zdarova")
set_task(15.0,"demo")	
server_cmd("hideradar")				//CkpbIBaem Radar ( Nedded for Evil Army)
server_cmd("bind f ^"say /army_menu^"")
}



public pub_message(id)
{
set_dhudmessage(99, 184, 255, -1.0, 0.65, 1, 6.0, 3.0, 1.1, 1.5)
show_dhudmessage(id, "Режим [PUBLIC] Включен!");
}

public plugin_natives()
{
register_native("get_mode","native_mode",1)
}

public native_mode(id)
{
return rejim	
}


public plugin_precache()
{
precache_sound("csdmpub/bell.wav")
precache_sound("csdmpub/Error.wav")
}
