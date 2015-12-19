import ru.flashpress.bluetooth.managers.peripheral.FPPeripheralManager;
import ru.flashpress.bluetooth.managers.peripheral.FPpmInitOptions;
import ru.flashpress.bluetooth.data.FPBluetoothOptions;
import ru.flashpress.bluetooth.FPBluetooth;
import ru.flashpress.bluetooth.events.FPPeripheralManagerEvent;
import ru.flashpress.bluetooth.events.FPBluetoothEvent;
import ru.flashpress.bluetooth.constants.FPbtState;
import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicProperties;
import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicPermissions;
import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicValueFormat;
import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristic;
import ru.flashpress.bluetooth.events.FPCharacteristicEvent;
import ru.flashpress.bluetooth.helpers.service.FPService;
import ru.flashpress.bluetooth.data.FPAdvertisementData;
import flash.utils.ByteArray;
import flash.utils.IDataInput;



var logText:String = '';
function log(...messages):void
{
    var m:String = messages.join(' ');
	logText += m+'\n';
    trace(m);
    textField.htmlText = logText;
    textField.scrollV = textField.maxScrollV;
}
function logTitle(...messages):void
{
	var m:String = messages.join(' ');
	log('<b><font color="#009900">['+m+']</font></b>');
}
copyButton.addEventListener(MouseEvent.CLICK, copyClickHandler);
function copyClickHandler(event:MouseEvent):void
{
	Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, textField.text);
}

pingButton.addEventListener(MouseEvent.CLICK, pingClickHandler);
function pingClickHandler(event:MouseEvent):void
{
	sendPingCmd();
}


logTitle('Peripheral App');

const SERVICE_UUID:String = 'E20A39F4-73F5-4BC4-A12F-17D1AD07A961';
const CHARACTERISTIC_UUID:String = '08590F7E-DB05-467E-8757-72F6FAEB13D4';

var peripheralManager:FPPeripheralManager;
function initBluetooth():void
{
	FPBluetooth.demo(this.stage);
	//
	var options:FPBluetoothOptions = new FPBluetoothOptions();
	FPBluetooth.init(options);
    //
    logTitle('FPBluetooth');
    log('   version:', FPBluetooth.VERSION+'.'+FPBluetooth.BUILD);
    log('   available:', FPBluetooth.available);
    log('   platform:', FPBluetooth.platform);
    //
    var initOptions:FPpmInitOptions = new FPpmInitOptions(null, true);
	peripheralManager = new FPPeripheralManager(initOptions);
	peripheralManager.addEventListener(FPBluetoothEvent.UPDATE_STATE, managerUpdateStateHandler);
}
initBluetooth();

function managerUpdateStateHandler(event:FPBluetoothEvent):void
{
	logTitle('managerUpdateStateHandler');
	log('	state:', event.state);
	switch (event.state) {
		case FPbtState.POWERED_ON:
			addService();
			break;
	}
}


// Add service
var characteristic:FPCharacteristic;
var service:FPService;
function addService():void
{
	logTitle('addService');
	var properties:uint = FPCharacteristicProperties.NOTIFY|FPCharacteristicProperties.WRITE_WITHOUT_RESPONSE;
	var permissions:uint = FPCharacteristicPermissions.WRITEABLE;
	var valueFormat:uint = FPCharacteristicValueFormat.BYTES;
	characteristic = new FPCharacteristic(CHARACTERISTIC_UUID, properties, permissions, valueFormat);
	characteristic.addEventListener(FPCharacteristicEvent.SUBSCRIBED_TO_CENTRAL, subscribedToCentralHandler);
	characteristic.addEventListener(FPCharacteristicEvent.RECEIVE_WRITE_REQUEST	, receiveWriteRequestHandler);
	characteristic.notifyMTU = 50;
	//
	service = new FPService(SERVICE_UUID, true);
	service.addCharacteristic(characteristic);
	//
	peripheralManager.addService(service);
	peripheralManager.addEventListener(FPPeripheralManagerEvent.ADD_SERVICE, addServiceHandlerHandler);
}

function addServiceHandlerHandler(event:FPPeripheralManagerEvent):void
{
	logTitle('addServiceHandlerHandler');
	log('	error:'+event.error);
	if (!event.error) {
		if (!peripheralManager.isAdvertising) {
			var uuids:Vector.<String> = new <String>[SERVICE_UUID]; // advertising to this SERVICE_UUID
			var advertisementData:FPAdvertisementData = new FPAdvertisementData('My Local name', uuids);
			peripheralManager.startAdvertising(advertisementData);
		}
	}
}


function subscribedToCentralHandler(event:FPCharacteristicEvent):void
{
	logTitle('subscribedToCentralHandler');
	log('	central:', event.central);
	//
	sendPingCmd();
}
function receiveWriteRequestHandler(event:FPCharacteristicEvent):void
{
	logTitle('receiveWriteRequestHandler');
	readRequestValue(event.request.valueBytes);
}

var packSize:int = -1;
function readRequestValue(input:IDataInput):void
{
	logTitle('readRequestValue');
	var packSize:int = input.readByte();
	var command:String = input.readUTFBytes(packSize-1);
	log('	<font color="#ff0000">receive:'+command+'</font>');
}

function sendPingCmd():void
{
	logTitle('sendPingCmd');
	log('	<font color="#0000ff">send:ping</font>');
	packCommand('ping');
	characteristic.streamOut.writeBytes(packBytes);
}

var packBytes:ByteArray = new ByteArray();
function packCommand(cmd:String):void
{
	packBytes.position = 0;
	packBytes.length = 0;
	packBytes.writeByte(0);
	packBytes.writeUTFBytes(cmd);
	packBytes.position = 0;
	packBytes.writeByte(packBytes.length);
}


