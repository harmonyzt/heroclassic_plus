public itemshop(id){
    if(is_user_alive(id) && RoundCount < 3){
        client_print_color(id, RED, "%L", LANG_PLAYER, "PERMITTED_ITEMSHOP");
        return PLUGIN_HANDLED;
    }

    new menu = menu_create( "\w[HCP] \rItem Shop", "menu_handler" );
    menu_additem( menu, "\wBuy \yGlorious Armor", "", 0 );
    menu_additem( menu, "\wBuy \yVampiric Helmet", "", 0 );
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( id, menu, 0 );

    return PLUGIN_CONTINUE
 }