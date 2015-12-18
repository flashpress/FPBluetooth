package ru.flashpress.bluetooth.find.peripheral
{
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	
	import ru.flashpress.bluetooth.data.FPAdvertisementExternalData;
	import ru.flashpress.bluetooth.ui.box.BoxEvent;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.log.objectToString;

	public class AdvertisementView extends Sprite
	{
		private var rootBox:VBox;
		private var dataAllLabel:Label;
		public function AdvertisementView(advertisement:FPAdvertisementExternalData)
		{
			rootBox = new VBox(0);
			rootBox.x = 10;
			rootBox.y = 10;
			//
			rootBox.addChild(new Label('Advertisement info:', 0x0));
			rootBox.addChild(new Label('is connectable: '+advertisement.isConnectable, null, 0.8));
			if (advertisement.localName) {
				rootBox.addChild(new Label('local name: '+advertisement.localName, null, 0.8));
			}
			if (advertisement.serviceUUIDs) {
				rootBox.addChild(new Label('services UUIDs: '+advertisement.serviceUUIDs, null, 0.8));
			}
			if (advertisement.manufacturerData) {
				advertisement.manufacturerData.position = 0;
				advertisement.manufacturerData.position = 0;
				rootBox.addChild(new Label('manufacturer data: '+advertisement.manufacturerData, null, 0.8));
			}
			//
			dataAllLabel = new Label(null, null, 0.8);
			dataAllLabel.autoSize = TextFieldAutoSize.NONE;
			dataAllLabel.wordWrap = true;
			dataAllLabel.multiline = true;
			dataAllLabel.text = 'dataAll: {\n'+objectToString(advertisement.dataAll, ' ')+'}';
			rootBox.addChild(dataAllLabel);
			//
			var data:Object = advertisement.dataAll;
			this.addChild(rootBox);
			//
			drawBack();
		}
		
		private function drawBack():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x999999, 1);
			this.graphics.drawRect(0, 0, rootBox.width+rootBox.x*2, rootBox.height+rootBox.y*2);
			this.graphics.endFill();
		}
		
		public override function set width(value:Number):void
		{
			var i:int;
			for (i=0; i<rootBox.numChildren; i++) {
				rootBox.getChildAt(i).width = value-rootBox.x*2;
			}
			dataAllLabel.height = dataAllLabel.textHeight+10;
			drawBack();
			//
			this.dispatchEvent(new BoxEvent(BoxEvent.RESIZE));
		}
	}
}