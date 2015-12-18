package ru.flashpress.bluetooth.ui.log
{
	import ru.flashpress.bluetooth.helpers.characteristic.stream.FPStreamStatistic;

	public function updateStatistic(statistic:FPStreamStatistic):void
	{
		LogBottomView.instance.updateStatistic(statistic);
	}
}