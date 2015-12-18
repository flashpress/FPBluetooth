package ru.flashpress.bluetooth.ui.core
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import ru.flashpress.bluetooth.ui.Conf;

	public class Label extends TextField
	{
		public function Label(text:String='', autoSize:Boolean=false, color:Object=null, s:Number=1)
		{
			super();
			var size:int = Conf.labelSize*s;
			//
			this.defaultTextFormat = new TextFormat('Tahoma', size, color!=null?color:0x666666);
			this.autoSize = autoSize?TextFieldAutoSize.LEFT:TextFieldAutoSize.NONE;
			this.selectable = true;
			//
			if (text) {
				this.text = text;
				this.height = this.textHeight+5;
			} else {
				this.height = 35;
			}
			//
			this.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		private function downHandler(event:MouseEvent):void
		{
			event.stopPropagation();
		}
		
		public override function set width(value:Number):void
		{
			super.width = value;
		}
	}
}