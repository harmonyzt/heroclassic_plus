/**
Плагин выдает опыт или бонусы за набранное количество очков
При вашей смерти вы теряете 1 очко

Обновления:

1.0
Релиз плагина
 
 
 
 **/

#include <amxmodx>
#include <amxmisc>
#include <evil_army>
#include <ColorChat>
#include <csx>
#include <fun>
#include <hamsandwich>

#define PLUGIN "Addon for ARMY BONUS"
#define VERSION "1.0"
#define AUTHOR "andrey"

new Score[50]

new Respawn[][] =
{
"В этот раз вам повезло! Вы возродились!",
"Ну, чё встал? Тебе повезло что я добрый :) "
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("HLTV", "CheckSkillRound", "a", "1=0", "2=0");
	register_event( "DeathMsg","EventDeathT","a");
}






public CheckSkillRound(id){

if(Score[id]==0){
ColorChat(id,RED,"У вас недостаточно очков для проверки скилла!")
return
}else{
ColorChat(id,GREEN,"Ваш уровень навыков - [%d]",Score[id]/10)
ColorChat(id,GREEN,"Ваши очки - [%d]",Score[id])
}
}

public EventDeathT(id){
new K,V,H;K=read_data(1);V=read_data(2);H=read_data(3)

if(K==V)
{
client_cmd(0,"mp3 play sound/newmisc/samoybitsa")
new name[32];get_user_name(K,name,31)
set_hudmessage(255, 255, 255, -1.0, 0.2, 0, 6.0, 5.0)
show_hudmessage(0, "%s Самоубийца!",name)
}else{
Score[K]+=1
if(Score[V]<0){	
Score[V]=0
}
}

if(H){
Score[K]+=1	
}
Score[V]-=1

new Float:chance

if(!is_user_alive(V)){
chance=1.0
if(chance==1.0){
client_print(V,print_chat,Respawn[random_num(1,2)])
ExecuteHamB(Ham_Spawn, V)
}
}
}
