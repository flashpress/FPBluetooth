import ru.flashpress.bluetooth.managers.central.FPCentralManager;
import ru.flashpress.bluetooth.managers.central.FPcmInitOptions;
import ru.flashpress.bluetooth.data.FPBluetoothOptions;
import ru.flashpress.bluetooth.FPBluetooth;
import ru.flashpress.bluetooth.events.FPBluetoothEvent;
import ru.flashpress.bluetooth.events.FPCentralManagerEvent;
import ru.flashpress.bluetooth.constants.FPbtState;
import ru.flashpress.bluetooth.managers.central.FPcmScanOptions;
import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectionOptions;
import ru.flashpress.bluetooth.events.FPPeripheralEvent;
import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheral;
import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectingState;
import ru.flashpress.bluetooth.helpers.service.FPService;
import ru.flashpress.bluetooth.helpers.service.FPServiceEvent;
import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristic;
import flash.events.MouseEvent;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.utils.ByteArray;
import ru.flashpress.bluetooth.events.FPCharacteristicEvent;
import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicWriteTypes;
import flash.geom.Point;

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

const SERVICE_UUID:String = 'E20A39F4-73F5-4BC4-A12F-17D1AD07A961';
const CHARACTERISTIC_UUID:String = '08590F7E-DB05-467E-8757-72F6FAEB13D4';

logTitle('Central App');

var centralManager:FPCentralManager;
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
    var initOptions:FPcmInitOptions = new FPcmInitOptions(null, true);
	centralManager = new FPCentralManager(initOptions);
	centralManager.addEventListener(FPBluetoothEvent.UPDATE_STATE, managerUpdateStateHandler);
	centralManager.addEventListener(FPCentralManagerEvent.PERIPHERAL_DISCOVER, peripheralDiscoverHandler);
}
initBluetooth();

function managerUpdateStateHandler(event:FPBluetoothEvent):void
{
	logTitle('managerUpdateStateHandler');
	log('	state:', event.state);
	if (event.state == FPbtState.POWERED_ON) {
		startScan();
	}
}
function startScan():void
{
	var options:FPcmScanOptions = new FPcmScanOptions(true, null);
	centralManager.startScan(options, SERVICE_UUID);
}

function peripheralDiscoverHandler(event:FPCentralManagerEvent):void
{
	logTitle('peripheralDiscoverHandler');
	log('	device: '+event.peripheral);
	//
	connectToDevice(event.peripheral);
}

function connectToDevice(device:FPPeripheral):void
{
	logTitle('connectToDevice');
	log('	device:', device.id);
	var options:FPPeripheralConnectionOptions = new FPPeripheralConnectionOptions();
	options.notifyOnConnection = true;
	options.notifyOnDisconnection = true;
	options.notifyOnNotification = true;
	device.connect(options);
	//
	device.addEventListener(FPPeripheralEvent.UPDATE_CONNECTING_STATE, updateConnectingStateHandler);
}
function updateConnectingStateHandler(event:FPPeripheralEvent):void
{
	var device:FPPeripheral = event.currentTarget as FPPeripheral;
	logTitle('updateConnectingStateHandler');
	log('	device:', device.id);
	log('	connectingState:', device.connectingState);
	switch (device.connectingState) {
		case FPPeripheralConnectingState.CONNECTED:
			discoverServices(device);
			break;
	}
}

function discoverServices(device:FPPeripheral):void
{
	logTitle('discoverServices');
	log('	device:', device.id);
	device.discoverServiceUUIDs(SERVICE_UUID);
	device.addEventListener(FPPeripheralEvent.DISCOVER_SERVICES, discoverServicesHandler);
}

function discoverServicesHandler(event:FPPeripheralEvent):void
{
	logTitle('discoverServicesHandler');
	//
	var device:FPPeripheral = event.currentTarget as FPPeripheral;
	log('	device:', device.id);
	//
	var list:Vector.<FPService> = device.services.list;
	log('	services list:', list);
	//
	var i:int;
	var service:FPService;
	for (i=0; i<list.length; i++) {
		service = list[i];
		discoverCharacteristicFromService(service);
	}
}

function discoverCharacteristicFromService(service:FPService):void
{
	logTitle('discoverCharacteristicFromService');
	log('	service:', service.id);
	service.discoverCharacteristicUUIDs(CHARACTERISTIC_UUID);
	service.addEventListener(FPServiceEvent.DISCOVER_CHARACTERISTICS, discoverCharacteristicsHandler);
}

var characteristic:FPCharacteristic;
function discoverCharacteristicsHandler(event:FPServiceEvent):void
{
	logTitle('discoverCharacteristicsHandler');
	//
	var service:FPService = event.currentTarget as FPService;
	log('	service:', service.id);
	//
	characteristic = service.characteristics.findByUUID(CHARACTERISTIC_UUID);
	if (characteristic) {
		characteristic.setNotify(true);
		characteristic.addEventListener(FPCharacteristicEvent.UPDATE_BYTES, updateBytesHandler);
	}
}
function updateBytesHandler(event:FPCharacteristicEvent):void
{
	logTitle('updateBytesHandler');
	//
	if (characteristic.streamIn.bytesWaitRetrieve) {
		characteristic.streamIn.retrieve();
	}
	if (characteristic.streamIn.bytesAvailable) {
		readData();
	}
}

var packSize:int = -1;
function readData():void
{
	logTitle('readData');
	while (1) {
		log('	bytesAvailable:', characteristic.streamIn.bytesAvailable);
		if (packSize == -1) {
			if (characteristic.streamIn.bytesAvailable < 1) {
				return;
			}
			packSize = characteristic.streamIn.readByte()-1;
			log('	packSize:', packSize);
		} else {
			if (characteristic.streamIn.bytesAvailable < packSize) {
				return;
			}
			var command:String = characteristic.streamIn.readUTFBytes(packSize);
			packSize = -1;
			log('	<font color="#ff0000">receive:'+command+'</font>');
			switch (command) {
				case 'ping':
					log('	<font color="#0000ff">send:pong</font>');
					packCommand('pong');
					characteristic.writeValue(packBytes, FPCharacteristicWriteTypes.WITHOUT_RESPONSE);
					break;
			}
		}
	}
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



