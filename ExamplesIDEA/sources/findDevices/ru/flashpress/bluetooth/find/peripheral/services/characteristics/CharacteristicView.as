package ru.flashpress.bluetooth.find.peripheral.services.characteristics
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import ru.flashpress.bluetooth.events.FPCharacteristicEvent;
	import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristic;
	import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicProperties;
	import ru.flashpress.bluetooth.ui.box.BoxEvent;
	import ru.flashpress.bluetooth.ui.box.HBox;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Button;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.log.log;
	import ru.flashpress.bluetooth.ui.log.logError;

	public class CharacteristicView extends Sprite
	{
		private var characteristic:FPCharacteristic;
		private var rootBox:VBox;
		//
		private var idLabel:Label;
		private var uuidLabel:Label;
		private var uuidDescriptionLabel:Label;
		private var propertiesLabel:Label;
		//
		private var notifyButton:Button;
		private var readButton:Button;
		private var valueField:Label;
		public function CharacteristicView(characteristic:FPCharacteristic)
		{
			this.characteristic = characteristic;			
			//
			rootBox = new VBox(5);
			rootBox.x = 10;
			rootBox.y = 10;
			//
			idLabel = new Label('Characteristic, id: '+characteristic.id, false, 0x0);
			uuidLabel = new Label('uuid: '+characteristic.uuid);
			uuidDescriptionLabel = new Label('uuid description: '+characteristic.uuidDescription);
			propertiesLabel = new Label('properties: '+characteristic.properties+' ('+propertiesToString(characteristic.properties)+')');
			//
			notifyButton = new Button('start notify');
			notifyButton.addEventListener(MouseEvent.CLICK, notifyClickHandler);
			//
			readButton = new Button('read');
			readButton.addEventListener(MouseEvent.CLICK, readClickHandler);
			//
			valueField = new Label(' ');
			valueField.border = true;
			valueField.multiline = true;
			valueField.wordWrap = true;
			valueField.width = 400;
			valueField.height = 200;
			//
			this.addChild(rootBox);
			rootBox.addChild(idLabel);
			rootBox.addChild(uuidLabel);
			rootBox.addChild(uuidDescriptionLabel);
			rootBox.addChild(propertiesLabel);
			//
			var hbox:HBox = new HBox();
			if (characteristic.properties & FPCharacteristicProperties.NOTIFY) hbox.addChild(notifyButton);
			if (characteristic.properties & FPCharacteristicProperties.READ) hbox.addChild(readButton);
			if (hbox.numChildren) rootBox.addChild(hbox);
			//
			rootBox.addChild(valueField);
			//
			//
			drawBack();
			this.addEventListener(BoxEvent.RESIZE, resizeHandler);
			//
			characteristic.addEventListener(FPCharacteristicEvent.UPDATE_NOTIFICATION, updateNotificationHandler);
			characteristic.addEventListener(FPCharacteristicEvent.UPDATE_BYTES, updateBytesHandler);
		}
		
		private var _width:Number = 100;
		public override function set width(value:Number):void
		{
			this._width = value;
			//
			var w:Number = _width-rootBox.x*2;
			idLabel.width = w;
			uuidLabel.width = w;
			uuidDescriptionLabel.width = w;
			propertiesLabel.width = w;
			valueField.width = w;
			//
			drawBack();
		}
		
		private function resizeHandler(event:Event):void
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
		
		private function propertiesToString(properties:uint):String
		{
			var propertiesArr:Array = [];
			if (characteristic.properties & FPCharacteristicProperties.BROADCAST)
				propertiesArr.push('broadcast');
			if (characteristic.properties & FPCharacteristicProperties.READ)
				propertiesArr.push('read');
			if (characteristic.properties & FPCharacteristicProperties.WRITE_WITHOUT_RESPONSE)
				propertiesArr.push('writeWithoutResponse');
			if (characteristic.properties & FPCharacteristicProperties.WRITE)
				propertiesArr.push('write');
			if (characteristic.properties & FPCharacteristicProperties.NOTIFY)
				propertiesArr.push('notify');
			if (characteristic.properties & FPCharacteristicProperties.INDICATE)
				propertiesArr.push('indicate');
			if (characteristic.properties & FPCharacteristicProperties.AUTHENTICATED_SIGNED_WRITES)
				propertiesArr.push('authenticatedSignedWrites');
			if (characteristic.properties & FPCharacteristicProperties.EXTENDED_PROPERTIES)
				propertiesArr.push('extendedProperties');
			if (characteristic.properties & FPCharacteristicProperties.NOTIFY_ENCRYPTION_REQUIRED)
				propertiesArr.push('notifyEncryptionRequired');
			if (characteristic.properties & FPCharacteristicProperties.INDICATE_ENCRYPTION_REQUIRED)
				propertiesArr.push('indicateEncryptionRequired');
			//
			return propertiesArr.join(',');
		}
		
		private function notifyClickHandler(event:MouseEvent):void
		{
			log('notifyClickHandler: ', characteristic.id);
			log('  isNotifying: ', characteristic.isNotifying);
			notifyButton.enabled = false;
			if (!characteristic.isNotifying) {
				characteristic.setNotify(true);
			} else {
				characteristic.setNotify(false);
			}
		}
		private function updateNotificationHandler(event:FPCharacteristicEvent):void
		{
			log('updateNotificationHandler: ', characteristic.id);
			log('  isNotifying: ', characteristic.isNotifying);
			if (event.error) {
				logError('  error: '+event.error);
			}
			notifyButton.enabled = true;
			if (characteristic.isNotifying) {
				notifyButton.label = 'stop notify';
			} else {
				notifyButton.label = 'start notify';
			}
		}
		
		private function readClickHandler(event:MouseEvent):void
		{
			log('readClickHandler: ', characteristic.id);
			characteristic.readValue();
		}
		
		private var bytes:ByteArray = new ByteArray();
		private function updateBytesHandler(event:FPCharacteristicEvent):void
		{
			log('updateBytesHandler:', this.characteristic.id);
			valueField.appendText('--- update data ---\n');
			if (event.error) {
				logError('  error: '+event.error);
				valueField.appendText('error: '+event.error+'\n');
			} else {
				if (event.bytesUpdated == 0) {
					return;
				}
				//
				characteristic.streamIn.retrieve();
				bytes.length = 0;
				characteristic.streamIn.readBytes(bytes);
				if (bytes.length > 0) {
					valueField.appendText('bytes: '+bytesToString(bytes)+'\n');
					//
					bytes.position = 0;
					var valueString:String = GattSpecifications.uuidToString(characteristic.uuid, bytes);
					if (!valueString) {
						valueString = bytes.readUTFBytes(bytes.bytesAvailable)
					}
					valueField.appendText('string: '+valueString+'\n');
				}
			}
			valueField.scrollV = valueField.maxScrollV;
		}
		
		private function bytesToString(b:ByteArray):String
		{
			var str:String = '';
			var i:int;
			for (i=0; i<b.length; i++) str += b[i];
			return str;
		}
	}
}