enum _:attributes
{
    dmg, speed, lifesteal, sl_leashstack, sl_leashstolen, spawnhealth
};

new attribute[128][attributes];
enum _:
{
    NONE, SL, UNDYING
};

new hero[33]

new const nonehero_sounds[][] =
{
    "msm/none_laugh.wav", "msm/none_laugh1.wav", "msm/none_laugh2.wav"
};
//
// Creating Menu
//
public class_change(id){
    new menu = menu_create( "\w[SVM BETA] \rChoose your class", "menu_handler" );
    menu_additem( menu, "\wPlay as \ySlark ", "", 0 );
    menu_additem( menu, "\wPlay as \yUndying", "", 0 );
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( id, menu, 0 );
 }
//
// Main Menu Function
//
 public menu_handler(id, menu, item)
 {
    switch(item)
    {
        case 0:
        {
         	ColorChat(id, GREEN, "%L", LANG_PLAYER, "SL_PLAY")
            hero[id] = SL
            play_s_sound(id)
         	return PLUGIN_HANDLED;
        }
        case 1:
        {
        	menu_destroy(menu);
         	return PLUGIN_HANDLED;
        }
        case MENU_EXIT:
        {
        	menu_destroy(menu);
         	return PLUGIN_HANDLED;
        }
    }
	menu_destroy( menu );
    return PLUGIN_HANDLED;
 }
//
// Playing sounds for different heroes
//
public play_s_sound(id) {
if(is_user_alive(id)){
    switch(msm_get_user_hero(id)){
        case NONE:{
            emit_sound(id, CHAN_STATIC, nonehero_sounds[id][random_num(1,3)], VOL_NORM,ATTN_NORM, 0, PITCH_NORM)
        }
        case SL:{
            emit_sound(id, CHAN_STATIC, "msm/sl.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM)
        }
    }
}
    return PLUGIN_HANDLED;
}