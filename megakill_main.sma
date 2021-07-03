#include <amxmodx>
#include <amxmisc>

#define PLUGIN "megakill main plugin"
#define VERSION "1.0"
#define AUTHOR "andrey"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_logevent( "EventRoundStartt", 2, "1=Round_Start" )
	register_event("SendAudio", "win", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "win", "a", "2&%!MRAD_ctwin")
}
public client_putinserver(id){
set_task(3.0,"hello",id)
}

public hello(id){
client_cmd(id,"spk megakill/welcome")
}


public EventRoundStartt(id){
client_cmd(0,"spk megakill/round_start")
}

public win(id){
client_cmd(0,"spk megakill/%d",random_num(1,36))
}



public plugin_precache(){
precache_sound("megakill/1.wav")
precache_sound("megakill/2.wav")
precache_sound("megakill/3.wav")
precache_sound("megakill/4.wav")
precache_sound("megakill/5.wav")
precache_sound("megakill/6.wav")
precache_sound("megakill/7.wav")
precache_sound("megakill/8.wav")
precache_sound("megakill/9.wav")
precache_sound("megakill/10.wav")
precache_sound("megakill/11.wav")
precache_sound("megakill/12.wav")
precache_sound("megakill/13.wav")
precache_sound("megakill/14.wav")
precache_sound("megakill/15.wav")
precache_sound("megakill/16.wav")
precache_sound("megakill/17.wav")
precache_sound("megakill/18.wav")
precache_sound("megakill/19.wav")
precache_sound("megakill/20.wav")
precache_sound("megakill/21.wav")
precache_sound("megakill/22.wav")
precache_sound("megakill/23.wav")
precache_sound("megakill/24.wav")
precache_sound("megakill/25.wav")
precache_sound("megakill/26.wav")
precache_sound("megakill/27.wav")
precache_sound("megakill/28.wav")
precache_sound("megakill/29.wav")
precache_sound("megakill/30.wav")
precache_sound("megakill/31.wav")
precache_sound("megakill/32.wav")
precache_sound("megakill/33.wav")
precache_sound("megakill/34.wav")
precache_sound("megakill/35.wav")
precache_sound("megakill/36.wav")
}
