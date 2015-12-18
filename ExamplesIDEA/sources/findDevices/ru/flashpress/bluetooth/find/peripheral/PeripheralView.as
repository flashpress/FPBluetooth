package ru.flashpress.bluetooth.find.peripheral
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ru.flashpress.bluetooth.events.FPPeripheralEvent;
	import ru.flashpress.bluetooth.find.peripheral.services.ServicesListView;
	import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheral;
	import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectingState;
	import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectionOptions;
	import ru.flashpress.bluetooth.ui.box.BoxEvent;
	import ru.flashpress.bluetooth.ui.box.HBox;
	import ru.flashpress.bluetooth.ui.box.Separator;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Button;
	import ru.flashpress.bluetooth.ui.core.CheckBox;
	import ru.flashpress.bluetooth.ui.core.Input;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.core.RssiView;
	import ru.flashpress.bluetooth.ui.core.Shared;
	import ru.flashpress.bluetooth.ui.log.log;
	import ru.flashpress.bluetooth.ui.log.logError;

	public class PeripheralView extends Sprite
	{
		private var peripheral:FPPeripheral;
		//
		private var rootBox:VBox;
		private var deviceNameLabel:Label;
		private var idLabel:Label;
		private var uuidLabel:Label;
		private var advertisementView:AdvertisementView;
		private var connectingStateLabel:Label;
		private var notifyOnConnectionBox:CheckBox;
		private var notifyOnDisconnectionBox:CheckBox;
		private var notifyOnNotificationBox:CheckBox;
		private var notifyBoxes:VBox;
		private var connectButton:Button;
		private var rssiView:RssiView;
		//
		private var discoverListInput:Input;
		private var discoverButton:Button;
		private var servicesListBox:ServicesListView;
		public function PeripheralView(peripheral:FPPeripheral)
		{
			this.peripheral = peripheral;
			//
			rootBox = new VBox(5);
			rootBox.x = 10;
			rootBox.y = 10;
			//
			deviceNameLabel = new Label('Device, name: '+peripheral.name, false, 0x0, 1.5);
			deviceNameLabel.height = 45;
			//
			idLabel = new Label('id: '+peripheral.id);
			//
			uuidLabel = new Label('uuid: '+peripheral.uuid);
			//
			advertisementView = new AdvertisementView(peripheral.advertisementInited);
			//
			connectingStateLabel = new Label('connecting state:', false, null, 1);
			//
			rssiView = new RssiView();
			//
			notifyOnConnectionBox = new CheckBox('notifyOnNotification', 'notifyOnNotification', false, true);
			notifyOnDisconnectionBox = new CheckBox('notifyOnDisconnectionBox', 'notifyOnDisconnectionBox', false, true);
			notifyOnNotificationBox = new CheckBox('notifyOnNotificationBox', 'notifyOnNotificationBox', false, true);
			notifyBoxes = VBox.create(0, notifyOnConnectionBox, notifyOnDisconnectionBox, notifyOnNotificationBox);
			notifyBoxes.enabled = false;
			//
			connectButton = new Button('connect', 0xffffff, 0xff0000, notifyBoxes.height);
			connectButton.width = 200;
			connectButton.addEventListener(MouseEvent.CLICK, connectClickHandler);
			connectButton.enabled = false;
			//
			discoverListInput = new Input(0.7);
			discoverListInput.multiline = true;
			discoverListInput.enabled = false;
			discoverListInput.text = Shared.open('servicesList', '');
			discoverListInput.width = 400;
			discoverListInput.height = 60;
			//
			discoverButton = new Button('discover services');
			discoverButton.height = discoverListInput.height;
			discoverButton.addEventListener(MouseEvent.CLICK, discoverClickHandler);
			discoverButton.enabled = false;
			//
			servicesListBox = new ServicesListView(peripheral);
			//
			this.addChild(rootBox);
			rootBox.addChild(deviceNameLabel);
			rootBox.addChild(idLabel);
			rootBox.addChild(uuidLabel);
			rootBox.addChild(advertisementView);
			rootBox.addChild(HBox.create(new Label('connecting state:', true), connectingStateLabel));
			rootBox.addChild(rssiView);
			rootBox.addChild(HBox.create(notifyBoxes, connectButton));
			rootBox.addChild(new Separator(40));
			rootBox.addChild(new Label('Enter the services or blank for find all services:', true, null, 0.7));
			rootBox.addChild(HBox.create(discoverListInput, discoverButton));
			rootBox.addChild(servicesListBox);
			//
			drawBack();
			//
			//
			//
			peripheral.addEventListener(FPPeripheralEvent.CONNECTED, connectedHandler);
			peripheral.addEventListener(FPPeripheralEvent.CONNECT_FAIL, connectFailHandler);
			peripheral.addEventListener(FPPeripheralEvent.DISCONNECT, disconnectedHandler);
			peripheral.addEventListener(FPPeripheralEvent.UPDATE_CONNECTING_STATE, updateConnectingStateHandler);
			updateConnectingStateHandler();
			//
			peripheral.addEventListener(FPPeripheralEvent.UPDATE_RSSI, updateRSSIHandler);
			//
			this.addEventListener(BoxEvent.RESIZE, resizeHandler);
		}
		
		private function resizeHandler(event:BoxEvent):void
		{
			drawBack();
		}
		private function drawBack():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x999999, 1);
			this.graphics.drawRect(0, 0, _width, rootBox.height+rootBox.y*2);
			this.graphics.endFill();
		}
		
		private var _width:Number = 100;
		public override function set width(value:Number):void
		{
			_width = value;
			var w:Number = value-rootBox.x*2;
			deviceNameLabel.width = w;
			idLabel.width = w;
			uuidLabel.width = w;
			advertisementView.width = w;
			connectingStateLabel.width = w-connectingStateLabel.x;
			discoverListInput.width = w-discoverButton.width-10;
			discoverButton.x = discoverListInput.width+10;
			servicesListBox.width = w;
			//
			drawBack();
		}
		
		private function connectedHandler(event:FPPeripheralEvent):void
		{
			log('connectedHandler: '+peripheral.id);
		}
		private function connectFailHandler(event:FPPeripheralEvent):void
		{
			logError('connectFailHandler: '+peripheral.id);
			logError('  error: '+event.error);
		}
		private function disconnectedHandler(event:FPPeripheralEvent):void
		{
			logError('disconnectedHandler: '+peripheral.id);
			logError('  error: '+event.error);
		}
		private function updateConnectingStateHandler(event:FPPeripheralEvent=null):void
		{
			log('updateConnectingStateHandler: '+peripheral.id);
			log('  connectingState: '+FPPeripheralConnectingState.toString(peripheral.connectingState));
			switch (peripheral.connectingState) {
				case FPPeripheralConnectingState.NONE:
					connectingStateLabel.text = 'NONE';
					connectingStateLabel.textColor = 0xff0000;
					notifyBoxes.enabled = false;
					connectButton.enabled = false;
					connectButton.label = 'connect';
					break;
				case FPPeripheralConnectingState.DISCOVERED:
					connectingStateLabel.text = 'DISCOVERED';
					connectingStateLabel.textColor = 0x469ef0;
					notifyBoxes.enabled = true;
					connectButton.enabled = true;
					break;
				case FPPeripheralConnectingState.CONNECTING:
					connectingStateLabel.text = 'CONNECTING';
					connectingStateLabel.textColor = 0x469ef0;
					notifyBoxes.enabled = false;
					connectButton.enabled = false;
					break;
				case FPPeripheralConnectingState.CONNECTED:
					connectingStateLabel.text = 'CONNECTED';
					connectingStateLabel.textColor = 0x009900;
					notifyBoxes.enabled = false;
					connectButton.enabled = true;
					connectButton.label = 'disconnect';
					break;
				case FPPeripheralConnectingState.FAIL:
					connectingStateLabel.text = 'FAIL';
					connectingStateLabel.textColor = 0xff0000;
					notifyBoxes.enabled = true;
					connectButton.enabled = true;
					connectButton.label = 'connect';
					break;
			}
			if (peripheral.connectingState == FPPeripheralConnectingState.CONNECTED) {
				discoverButton.enabled = true;
				discoverListInput.enabled = true;
			} else {
				discoverButton.enabled = false;
				discoverListInput.enabled = false;
				servicesListBox.enabled = false;
			}
		}
		
		private function connectClickHandler(event:MouseEvent):void
		{
			log('connectClickHandler: '+peripheral.id);
			if (peripheral.connectingState == FPPeripheralConnectingState.DISCOVERED) {
				var options:FPPeripheralConnectionOptions = new FPPeripheralConnectionOptions();
				options.notifyOnConnection = notifyOnConnectionBox.selected;
				options.notifyOnDisconnection =  notifyOnDisconnectionBox.selected;
				options.notifyOnNotification =  notifyOnNotificationBox.selected;
				peripheral.connect(options);
			} else {
				peripheral.cancelConnect();
			}
		}
		
		private function updateRSSIHandler(event:FPPeripheralEvent):void
		{
			rssiView.update(event.rssi);
		}
		
		private function discoverClickHandler(event:MouseEvent):void
		{
			log('discoverClickHandler: '+peripheral.id);
			var serviceUUIDs:Array;
			if (discoverListInput.text != '') {
				serviceUUIDs = discoverListInput.text.split(',');
			}
			log('  serviceUUIDs:', serviceUUIDs);
			Shared.save('servicesList', discoverListInput.text);
			//
			peripheral.discoverServiceUUIDs(serviceUUIDs);
		}
	}
}