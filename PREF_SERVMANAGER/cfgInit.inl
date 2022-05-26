public plugin_cfg()
{
	new cfgDir[64], szFile[192];
	get_configsdir(cfgDir, charsmax(cfgDir));
	formatex(szFile,charsmax(szFile),"%s/server_manager.ini",cfgDir);
	if(file_exists(szFile))
		server_cmd("exec %s", szFile);
}