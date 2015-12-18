package ru.flashpress.bluetooth.ui.core
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import ru.flashpress.bluetooth.ui.Conf;

	public class Button extends Sprite
	{
		private var backShape:Shape;
		private var textField:TextField;
		public function Button(label:String, textColor:uint=0xffffff, backColor:uint=0xff0000, h:Number=-1)
		{
			var size:int = Conf.buttonSize;
			var border:int;
			if (Conf.isMobile) {
				border = 10;
			} else {
				border = 5;
			}
			backShape = new Shape();
			backShape.graphics.beginFill(backColor, 1);
			backShape.graphics.drawRect(0, 0, 10, 10);
			this.addChild(backShape);
			//
			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = new TextFormat('Tahoma', size, textColor);
			textField.text = label;
			textField.x = 10;
			textField.y = 10;
			textField.mouseEnabled = false;
			this.addChild(textField);
			//
			if (h == -1) h = textField.height+textField.y*2;
			else textField.y = (h-textField.height)/2;
			//
			this.buttonMode = true;
			backShape.width = textField.width+textField.x*2;
			backShape.height = h;
			this._width = super.width;
		}
		
		private var _width:Number;
		public override function set width(value:Number):void
		{
			this._width = value;
			textField.x = (value-textField.width)/2;
			//
			backShape.width = _width;
		}
		
		public override function set height(value:Number):void
		{
			backShape.height = value;
			textField.y = (value-textField.height)/2;
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseEnabled = value;
			this.alpha = value ? 1 : 0.5;
		}
		
		public function set label(value:String):void
		{
			textField.text = value;
			textField.x = (_width-textField.width)/2;
		}
	}
}