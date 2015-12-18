package ru.flashpress.bluetooth.find.peripheral.services.characteristics
{
	import flash.display.Sprite;
	
	import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristic;
	import ru.flashpress.bluetooth.helpers.service.FPService;
	import ru.flashpress.bluetooth.helpers.service.FPServiceEvent;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.log.log;
	import ru.flashpress.bluetooth.ui.log.logError;

	public class CharacteristicsListView extends Sprite
	{
		private var service:FPService;
		private var rootBox:VBox;
		private var characteristicsById:Object;
		public function CharacteristicsListView(service:FPService)
		{
			this.service = service;
			//
			var label:Label = new Label('CharacteristicsList', true); 
			//
			rootBox = new VBox(5);
			rootBox.y = label.height+5;
			//
			//
			this.addChild(label);
			this.addChild(rootBox);
			//
			this.service.addEventListener(FPServiceEvent.DISCOVER_CHARACTERISTICS, discoverCharacteristicsHandler);
		}
		
		private function discoverCharacteristicsHandler(event:FPServiceEvent):void
		{
			log('discoverCharacteristicsHandler:', service.id);
			//
			characteristicsById = {};
			rootBox.removeChildren();
			//
			if (event.error) {
				logError(' error: '+event.error);
				return;
			}
			//
			var list:Vector.<FPCharacteristic> = service.characteristics.list;
			log('list:\n  '+list.join('\n  '));
			var characteristic:FPCharacteristic;
			var i:int;
			var view:CharacteristicView;
			for (i=0; i<list.length; i++) {
				characteristic = list[i];
				if (!characteristicsById[characteristic.id]) {
					view = new CharacteristicView(characteristic);
					view.width = _width;
					rootBox.addChild(view);
					characteristicsById[characteristic.id] = view;
				}
			}
		}
		
		private var _width:Number = 100;
		public override function set width(value:Number):void
		{
			this._width = value;
			var key:String;
			var characteristic:CharacteristicView;
			for (key in characteristicsById) {
				characteristic = characteristicsById[key];
				characteristic.width = _width;
			}
		}
	}
}