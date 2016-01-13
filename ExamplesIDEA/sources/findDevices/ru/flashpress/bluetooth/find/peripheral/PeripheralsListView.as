package ru.flashpress.bluetooth.find.peripheral
{
	import flash.display.Sprite;
	
	import ru.flashpress.bluetooth.events.FPCentralManagerEvent;
	import ru.flashpress.bluetooth.managers.central.FPCentralManager;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.log.log;

	public class PeripheralsListView extends Sprite
	{
		private var rootBox:VBox;
		private var peripheralsById:Object;
		public function PeripheralsListView()
		{
			rootBox = new VBox();
			rootBox.addChild(new Label('PeripheralsList', true));
			this.addChild(rootBox);
			//
			peripheralsById = {};
		}
		
		private var _width:Number = 100;
		public override function set width(value:Number):void
		{
			_width = value;
			var key:String;
			var peripheral:PeripheralView;
			for (key in peripheralsById) {
				peripheral = peripheralsById[key];
				peripheral.width = _width;
			}
		}
		
		private var centralManager:FPCentralManager;
		public function init(centralManager:FPCentralManager):void
		{
			this.centralManager = centralManager;
			centralManager.addEventListener(FPCentralManagerEvent.PERIPHERAL_DISCOVER, peripheralDiscoverHandler);
		}
		
		private function peripheralDiscoverHandler(event:FPCentralManagerEvent):void
		{
			log('peripheralDiscoverHandler');
			log('	peripheral: '+event.peripheral);
			if (!peripheralsById[event.peripheral.id]) {
				var peripheralView:PeripheralView = new PeripheralView(event.peripheral);
				rootBox.addChild(peripheralView);
				peripheralsById[event.peripheral.id] = peripheralView;
				peripheralView.width = _width;
				peripheralView.updatePowered(poweredOn);
			}
		}

		private var poweredOn:Boolean;
		public function updatePowered(poweredOn:Boolean):void
		{
			this.poweredOn = poweredOn;
			var key:String;
			var peripheral:PeripheralView;
			for (key in peripheralsById) {
				peripheral = peripheralsById[key];
				peripheral.updatePowered(poweredOn);
			}
		}
	}
}