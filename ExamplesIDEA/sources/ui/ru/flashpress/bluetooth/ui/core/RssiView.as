package ru.flashpress.bluetooth.ui.core
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import ru.flashpress.bluetooth.ui.core.Label;
	
	public class RssiView extends Sprite
	{
		private var items:Vector.<Shape>;
		private var cont:Sprite;
		private var rssiLabel:Label;
		public function RssiView()
		{
			cont = new Sprite();
			this.addChild(cont);
			//
			var i:int;
			var count:int = 25;
			for (i=0; i<count; i++) {
				createItem(i*(13), 0xeeeeee);
			}
			//
			items = new Vector.<Shape>();
			var item:Shape;
			for (i=0; i<count; i++) {
				item = createItem(i*(13), 0x009900);
				items.push(item);
			}
			//
			rssiLabel = new Label('RSSI: 000000', true);
			this.addChild(rssiLabel);
			rssiLabel.x = cont.x + cont.width+10;
		}
		
		private function createItem(x:Number, color:int):Shape
		{
			var item:Shape = new Shape();
			item.x = x;
			item.graphics.beginFill(color, 1);
			item.graphics.drawRect(0, 0, 10, 35);
			item.graphics.endFill();
			cont.addChild(item);
			return item;
		}
		
		private var max:Number = 0;
		public function update(rssi:Number):void
		{
			max = Math.min(rssi, max);
			var percent:Number = 1-rssi/max;
			if (percent < 0) percent = 0;
			if (percent > 1) percent = 1;
			var i:int;
			for (i=0; i<items.length; i++) {
				items[i].visible = i/items.length < percent;
			}
			rssiLabel.text = 'RSSI: '+(Math.floor(rssi*1000)/1000);
		}
	}
}