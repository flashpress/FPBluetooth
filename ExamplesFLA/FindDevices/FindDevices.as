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


var centralManager:FPCentralManager;
function initBluetooth():void
{
	FPBluetooth.demo(this.stage);
	//
	var options:FPBluetoothOptions = new FPBluetoothOptions();
	FPBluetooth.init(options);
    //
    logTitle('--- FPBluetooth ---');
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
	centralManager.startScan(options);
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
	device.discoverServiceUUIDs();
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
	service.discoverCharacteristicUUIDs();
	service.addEventListener(FPServiceEvent.DISCOVER_CHARACTERISTICS, discoverCharacteristicsHandler);
}

function discoverCharacteristicsHandler(event:FPServiceEvent):void
{
	logTitle('discoverCharacteristicsHandler');
	//
	var service:FPService = event.currentTarget as FPService;
	log('	service:', service.id);
	//
	var list:Vector.<FPCharacteristic> = service.characteristics.list;
	log('	characteristics list:', list);
	//
	var i:int;
	var characteristic:FPCharacteristic;
	for (i=0; i<list.length; i++) {
		characteristic = list[i];
		sendData(characteristic);
	}
}


function sendData(characteristic:FPCharacteristic):void
{
	logTitle('sendData');
	var bytes:ByteArray = new ByteArray();
	bytes.writeByte(123);
	bytes.writeUTFBytes('ping');
	characteristic.streamOut.writeBytes(bytes);
}





