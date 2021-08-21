enum _:attributes
{
    dmg, speed, lifesteal, sl_leashstack, sl_leashstolen
};

enum _:classes
{
    none, sl, pg
};
new attribute[128][attributes];
new class[128][classes];

public class_change(id) {
	new buffer [512], len = format( buffer, charsmax( buffer ), "%L", LANG_PLAYER, "CLASS_CHANGE");
	
	len += format( buffer[ len ], charsmax( buffer ) - len, "%L", LANG_PLAYER, "CLASS_SL");
	len += format( buffer[ len ], charsmax( buffer ) - len, "%L", LANG_PLAYER, "CLASS_PG");
	
	show_menu( id, MENU_KEY_0|MENU_KEY_1, buffer, -1, "class_choose_menu" );
}
public msm_func_classchange(id, key) {
	switch( key ) {
		case 0:{
		class[id][none] = 0
		class[id][pg] = 0
		class[id][sl] = 1
		}
		case 1:{
		class[id][none] = 0
		class[id][pg] = 1
		class[id][sl] = 0
		}
		case 9: return  0;
	}
	return PLUGIN_HANDLED;
}