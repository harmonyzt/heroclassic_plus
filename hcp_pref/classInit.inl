enum _:attributes
{
    sl_leashstack, sl_selfstack, undying_hpstack, 
    undying_hpstolen_timed, poisoned_from_undying, 
    knight_shield, ult_counter, ultimate_cooldown, is_ult_ready, berserk_ult_rage
};
enum _:
{
    NONE, SLARK, UNDYING, ZEUS, BERSERK, BOSS, KNIGHT
};
new attribute[256][attributes];
new hero_hp[33];
new hero[33];
//
// Creating Menu
//
public class_change(id){
    //if(isAllowedToChangeClass[id] = 0 && RoundCount < 3){
    //    client_print_color(id, RED, "%L", LANG_PLAYER, "PERMITTED_CHANGECLASS");
    //    return PLUGIN_HANDLED;
    //}

    new menu = menu_create( "\w[SVM BETA] \rChoose your class", "menu_handler" );
    menu_additem( menu, "\wDon't play as \yanyone", "", 0 );
    menu_additem( menu, "\wPlay as \ySlark", "", 0 );
    menu_additem( menu, "\wPlay as \yUndying", "", 0 );
    // REMAKE THIS HERO!
    // Hero gains rage with every hit
    // At 15 hits he can use the special ability to deal damage as some % of max victims HP instead of constant % damage
    menu_additem( menu, "\wPlay as \yBerserk", "", 0 );
    // REMAKE
    // Passive -  Shock at 4% shakes victims camera
    // Active - Has its cooldown (30 seconds), guaranted shocks an enemy for longer and disables the ability to change weapons for victim
    menu_additem( menu, "\wPlay as \yZeus", "", 0 );
    menu_additem( menu, "\wPlay as \yKnight", "", 0 );
    menu_additem( menu, "\wPlay as \yAssasin", "", 0 );
    menu_additem( menu, "\wPlay as \yElemental", "", 0 );
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
            hero_hp[id] = get_cvar_num("hcp_hero_survivor_hp");
            set_user_health(id, hero_hp[id])
            client_print_color(id, GREEN, "%L", LANG_PLAYER, "NONE_PLAY");
            reset_all_attributes(id)
            play_s_sound(id);

            return PLUGIN_HANDLED;
        }
        case 1:
        {
            hero[id] = SLARK;
            hero_hp[id] = 530;
            set_user_health(id, hero_hp[id]);
            client_print_color(id, GREEN, "%L", LANG_PLAYER, "SLARK_PLAY");
            reset_all_attributes(id)
            play_s_sound(id);
            
         	return PLUGIN_HANDLED;
        }
        case 2:
        {
            hero[id] = UNDYING;
            hero_hp[id] = 380;
            set_user_health(id, hero_hp[id]);
            client_print_color(id, GREEN, "%L", LANG_PLAYER, "UD_PLAY"); 
            reset_all_attributes(id)
            play_s_sound(id);

            return PLUGIN_HANDLED;
        }
        case 3:
        {
            hero[id] = BERSERK;
            hero_hp[id] = 450;
            set_user_health(id, hero_hp[id]);
            client_print_color(id, GREEN, "%L", LANG_PLAYER, "BERSERK_PLAY"); 
            reset_all_attributes(id)
            play_s_sound(id);

            return PLUGIN_HANDLED;
        }
        case 4:
        {
            hero[id] = ZEUS;
            hero_hp[id] = 250;
            attribute[id][ult_counter] = 30;
            set_user_health(id, hero_hp[id]);
            client_print_color(id, GREEN, "%L", LANG_PLAYER, "ZEUS_PLAY"); 
            reset_all_attributes(id)
            play_s_sound(id);
            return PLUGIN_HANDLED;
        }
        case 5:
        {
            hero[id] = KNIGHT;
            hero_hp[id] = 600;
            set_user_health(id, hero_hp[id]);
            client_print_color(id, GREEN, "%L", LANG_PLAYER, "KNIGHT_PLAY"); 
            reset_all_attributes(id)
            play_s_sound(id);
            return PLUGIN_HANDLED;
        }

        case MENU_EXIT:
        {
        	menu_destroy(menu);
         	return PLUGIN_HANDLED;
        }
    }
	menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public reset_all_attributes(id){
    attribute[id][is_ult_ready] = 0;
    attribute[id][berserk_ult_rage] = 0;
    is_shield_broken[id] = false;
    attribute[id][knight_shield] = 15;
    attribute[id][sl_leashstack] = 0;
    attribute[id][sl_selfstack] = 0;
    attribute[id][poisoned_from_undying] = 0;
    attribute[id][undying_hpstolen_timed] = 0;
    remove_task(id, 0);
}