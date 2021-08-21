enum _:attributes
{
    dmg, speed, lifesteal, sl_leashstack, sl_leashstolen
};

enum _:classes
{
    none, sl
};
new attribute[128][attributes];
new class[128][classes];

public class_change(id) {
	new buffer [512], len = format( buffer, charsmax( buffer ), "%L", LANG_PLAYER, "CLASS_CHANGE");
	
	len += format( buffer[ len ], charsmax( buffer ) - len, "%L", LANG_PLAYER, "BOSS_BECOME_MENU");
	len += format( buffer[ len ], charsmax( buffer ) - len, "%L", LANG_PLAYER, "BOSS_DECLINE_MENU");
	
	show_menu( id, MENU_KEY_0|MENU_KEY_1, buffer, -1, "class_choose_menu" );
}
public msm_func_classchange(id, key) {
	switch( key ) {
		case 0: ColorChat();
		case 1: test;
		case 9: return  0;
	}
	return PLUGIN_HANDLED;
}