package ru.flashpress.bluetooth.ui.log
{
	public function logError(...messages):void
	{
		var html:String = '<font color="#ff0000">'+messages.join(' ')+'</font>';
		LogBottomView.instance.addLog(html);
	}
}