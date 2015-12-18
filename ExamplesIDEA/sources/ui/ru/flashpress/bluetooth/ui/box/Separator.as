package ru.flashpress.bluetooth.ui.box
{
	import flash.display.Shape;

	public class Separator extends Shape
	{
		public function Separator(w:Number=20, h:Number=0)
		{
			this.graphics.beginFill(0x0, 0);
			this.graphics.drawRect(0, 0, w, h?h:w);
			this.graphics.endFill();
		}
	}
}