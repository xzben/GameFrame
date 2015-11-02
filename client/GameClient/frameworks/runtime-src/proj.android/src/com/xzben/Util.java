package com.xzben;

import org.cocos2dx.lua.AppActivity;

public class Util 
{
	public static AppActivity context = null;
	public static int sdk_version =  android.os.Build.VERSION.SDK_INT;
	
	public static void init(AppActivity ctx)
	{
		context  = ctx;
	}
}
