/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package com.xzben;

import android.annotation.SuppressLint;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;


public class LuaJavaBridge extends Util
{	
	public static int addTwoNumbers(final int num1,final int num2){
		return num1 + num2;
	}
	
	public static void callbackLua(final String tipInfo,final int luaFunc){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunc, "success");
		Cocos2dxLuaJavaBridge.releaseLuaFunction(luaFunc);
	}
	
	public static void copyToClipboard(final String text)
	{
		context.runOnUiThread(new Runnable(){
			@SuppressLint("NewApi") 
			public void run(){
				if (sdk_version > 11){
					android.content.ClipboardManager clip = (android.content.ClipboardManager)context.getSystemService(android.content.Context.CLIPBOARD_SERVICE);
					clip.setPrimaryClip(android.content.ClipData.newPlainText("", text));
				}else{
					android.text.ClipboardManager clip = (android.text.ClipboardManager)context.getSystemService(android.content.Context.CLIPBOARD_SERVICE);
					clip.setText(text);
				}
			}
		});
	}
	
	@SuppressLint("NewApi") 
	public static String pasteFromClipboard()
	{
		String text = "";

		if (sdk_version > 11){
			android.content.ClipboardManager clip = (android.content.ClipboardManager)context.getSystemService(android.content.Context.CLIPBOARD_SERVICE);
			text =  clip.getPrimaryClip().getItemAt(0).getText().toString();
		}else{
			android.text.ClipboardManager clip = (android.text.ClipboardManager)context.getSystemService(android.content.Context.CLIPBOARD_SERVICE);
			text = clip.getText().toString();
		}
		
		return text;
	}
}
