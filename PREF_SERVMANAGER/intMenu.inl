enum _:attributes
{
    dmg, speed, lifesteal, sl_leashstack, sl_selfstack, spawnhealth, undying_hpstack, undying_hpstolen
};
enum _:
{
    NONE, SL, UNDYING, ZEUS, BERSERK
};
new const nonehero_sounds[][] =
{
    "msm/none_laugh.wav", "msm/none_laugh1.wav", "msm/none_laugh2.wav"
};
new attribute[256][attributes];
new hero[33];
//
// Creating Menu
//
public class_change(id){
    if(info[id][dead] == 1){
        ColorChat(id, RED, "%L", LANG_PLAYER, "NOT_ALIVE")
        return PLUGIN_HANDLED
    }

    new menu = menu_create( "\w[SVM BETA] \rChoose your class", "menu_handler" );
    menu_additem( menu, "\wDon't play as \yanyone", "", 0 );
    menu_additem( menu, "\wPlay as \ySlark", "", 0 );
    menu_additem( menu, "\wPlay as \yUndying", "", 0 );
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( id, menu, 0 );
    return PLUGIN_CONTINUE
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
            hero[id] = NONE;
            attribute[id][sl_leashstack] = 0;
            attribute[id][sl_selfstack] = 0;
            play_s_sound(id);

        return PLUGIN_HANDLED;
        }
        case 1:
        {
         	ColorChat(id, GREEN, "%L", LANG_PLAYER, "SL_PLAY")
            hero[id] = SL;
            attribute[id][sl_leashstack] = 0
            attribute[id][sl_selfstack] = 0
            play_s_sound(id);
         	return PLUGIN_HANDLED
        }
        case 2:
        {

        }
        // Add cases
        case MENU_EXIT:
        {
        	menu_destroy(menu);
         	return PLUGIN_HANDLED
        }
    }
	menu_destroy(menu);
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