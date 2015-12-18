package ru.flashpress.bluetooth.ui.core
{
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class Input extends TextField
	{
		public function Input(s:Number=1)
		{
			super();
			var size:int = Capabilities.os && Capabilities.os.indexOf('iPhone') != -1 ? 34 : 24;
			var height:Number = Capabilities.os && Capabilities.os.indexOf('iPhone') != -1 ? 60 : 38;
			//
			this.defaultTextFormat = new TextFormat('Tahoma', size*s, 0x0);
			this.border = true;
			this.background = true;
			this.width = 150;
			this.height = height;
			this.type = TextFieldType.INPUT;
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseEnabled = value;
			this.alpha = value ? 1 : 0.2;
		}
	}
}