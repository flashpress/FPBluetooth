package ru.flashpress.bluetooth.ui.box
{
	import flash.events.Event;

	public class BoxEvent extends Event
	{
		public static const RESIZE:String = 'boxResize';
		public function BoxEvent(type:String)
		{
			super(type, true, true);
		}
	}
}