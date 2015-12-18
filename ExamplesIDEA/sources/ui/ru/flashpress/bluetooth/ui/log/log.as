package ru.flashpress.bluetooth.ui.log
{
    import ru.flashpress.bluetooth.log.nativeLog;

    public function log(...messages):void
	{
        //nativeLog.apply(null, messages);
		LogBottomView.instance.addLog.apply(null, messages);
	}
}