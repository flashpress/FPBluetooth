package ru.flashpress.bluetooth.ui
{
	import flash.display.Stage;
	import flash.system.Capabilities;

	public class Conf
	{
		private static var _isMobile:Boolean;
		private static var stage:Stage;
		public static function init(stage:Stage):void
		{
			Conf.stage = stage;
			_isMobile = Capabilities.os && Capabilities.os.indexOf('iPhone') != -1;
			//
			if (_isMobile) {
				labelSize = 28;
				buttonSize = 32;
			} else {
				labelSize = 20;
				buttonSize = 12;
			}
		}
		
		public static function get isMobile():Boolean {return _isMobile;}
		
		public static function get width():Number
		{
			return _isMobile ? Capabilities.screenResolutionX : stage.stageWidth;
		}
		
		public static function get height():Number
		{
			return _isMobile ? Capabilities.screenResolutionY : stage.stageHeight;
		}
		
		public static var labelSize:int;
		public static var buttonSize:int;
	}
}