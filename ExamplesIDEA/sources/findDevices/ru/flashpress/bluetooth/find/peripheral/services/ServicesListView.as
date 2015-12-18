package ru.flashpress.bluetooth.find.peripheral.services
{
	import flash.display.Sprite;
	
	import ru.flashpress.bluetooth.events.FPPeripheralEvent;
	import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheral;
	import ru.flashpress.bluetooth.helpers.service.FPService;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.log.log;

	public class ServicesListView extends Sprite
	{
		private var peripheral:FPPeripheral;
		private var rootBox:VBox;
		private var servicesById:Object;
		public function ServicesListView(peripheral:FPPeripheral)
		{
			this.peripheral = peripheral;
			//
			var label:Label = new Label('ServicesList', true);
			//
			rootBox = new VBox(5);
			rootBox.y = label.height+5;
			//
			this.addChild(label);
			this.addChild(rootBox);
			//
			peripheral.addEventListener(FPPeripheralEvent.DISCOVER_SERVICES, discoverServicesHandler);
		}
		
		private function discoverServicesHandler(event:FPPeripheralEvent):void
		{
			log('discoverServicesHandler: ', peripheral.id);
			//
			this.enabled = true;
			//
			rootBox.removeChildren();
			servicesById = {};
			//
			if (event.error) {
				log('  error: '+event.error);
				return;
			}
			//
			var list:Vector.<FPService> = peripheral.services.list;
			log('list:\n  '+list.join('\n  '));
			var service:FPService;
			var view:ServiceView;
			var i:int;
			for (i=0; i<list.length; i++) {
				service = list[i];
				if (!servicesById[service.id]) {
					view = new ServiceView(service);
					view.width = _width;
					rootBox.addChild(view);
					servicesById[service.id] = view;
				}
			}
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseChildren = this.mouseEnabled = value;
			this.alpha = value ? 1 : 0.5;
		}
		
		private var _width:Number = 100;
		public override function set width(value:Number):void
		{
			_width = value;
			var key:String;
			var service:ServiceView;
			for (key in servicesById) {
				service = servicesById[key];
				service.width = _width;
			}
		}
	}
}