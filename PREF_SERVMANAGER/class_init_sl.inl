enum _:attributes
{
    damage, speed, lifesteal, sl_leashstack, sl_leashstolen
};
new attribute[128][attributes];

class_change(id) {
	new buffer [512], len = format( buffer, charsmax( buffer ), "%L");
	
	len += format( buffer[ len ], charsmax( buffer ) - len, "%L", LANG_PLAYER, "BOSS_BECOME_MENU");
	len += format( buffer[ len ], charsmax( buffer ) - len, "%L", LANG_PLAYER, "BOSS_DECLINE_MENU");
	
	show_menu( id, MENU_KEY_0|MENU_KEY_1, buffer, -1, "class_choose_menu" );
	return PLUGIN_CONTINUE;
}

public msm_func_classchange(id, key) {
	switch( key ) {
		case 0: msm_set_user_boss(id);
		case 1: freeze_player( msm_boss, false);
		case 9: showMenu(id);
	}
	return PLUGIN_HANDLED;
}