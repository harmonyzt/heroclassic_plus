// Hides Radar, Health & Armor
#define HUD_HIDE_RHA (1<<3)

public onResetHUD(id)
{
	new iHideFlags = GetHudHideFlags();
	if(iHideFlags)
	{
		message_begin(MSG_ONE, g_msgHideWeapon, _, id);
		write_byte(iHideFlags);
		message_end();
	}	
}

public msgHideWeapon()
{
	new iHideFlags = GetHudHideFlags();
	if(iHideFlags)
		set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | iHideFlags);
}

GetHudHideFlags()
{
	new iFlags;
	iFlags |= HUD_HIDE_RHA;
	return iFlags;
}
