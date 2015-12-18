/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager
{
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;

    import ru.flashpress.bluetooth.FPBluetooth;
    import ru.flashpress.bluetooth.constants.FPbtState;
    import ru.flashpress.bluetooth.data.FPAdvertisementData;

    import ru.flashpress.bluetooth.events.FPBluetoothEvent;
    import ru.flashpress.bluetooth.events.FPCentralManagerEvent;
    import ru.flashpress.bluetooth.events.FPCharacteristicEvent;
    import ru.flashpress.bluetooth.helpers.central.FPCentral;
    import ru.flashpress.bluetooth.managers.central.FPCentralManager;
    import ru.flashpress.bluetooth.managers.peripheral.FPPeripheralManager;
    import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheral;
    import ru.flashpress.bt.manager.core.ns.bluetoothManagerNS;
    import ru.flashpress.bt.manager.core.ns.log.btmLog;
    import ru.flashpress.bt.manager.device.BTMDevice;
    import ru.flashpress.bt.manager.device.BTMDevicesList;

    public class FPBluetoothManager extends EventDispatcher
    {
        use namespace bluetoothManagerNS;
        //
        private var config:BTMConfig;
        public function FPBluetoothManager(config:BTMConfig)
        {
            this.config = config;
        }

        public function init():void
        {
            FPBluetooth.init(config.initOptions);
        }

        private var pm:FPPeripheralManager;
        private var cm:FPCentralManager;
        private var myService:BTMMyService;
        private var devicesById:BTMDevicesList;
        public function start():void
        {
            btmLog('start');
            pm = new FPPeripheralManager(null, config.pmQueue);
            pm.addEventListener(FPBluetoothEvent.UPDATE_STATE, updatePMStateHandler);
            //
            cm = new FPCentralManager(null, config.cmQueue);
            cm.addEventListener(FPCentralManagerEvent.PERIPHERAL_DISCOVER, discoverPeripheralHandler);
            //
            devicesById = new BTMDevicesList();
        }

        private function updatePMStateHandler(event:FPBluetoothEvent):void
        {
            btmLog('updatePMStateHandler:', event.state);
            //
            this.dispatchEvent(event.clone());
            //
            if (event.state != FPbtState.POWERED_ON) {
                devicesById.stopAll();
                if (pm) {
                    pm.stopAdvertising();
                }
                return;
            }
            //
            devicesById.reconnectAll();
            //
            cm.startScan(config.scanOptions, config.serviceUUID);
            //
            if (!myService) {
                myService = new BTMMyService();
                myService.parseRequestCallback = parseRequestCallback;
                myService.createService(config);
                myService.characteristic.addEventListener(FPCharacteristicEvent.SUBSCRIBED_TO_CENTRAL, subscribedToCentralHandler);
                myService.characteristic.addEventListener(FPCharacteristicEvent.UNSUBSCRIBED_FROM_CENTRAL, unsubscribedFromCentralHandler);
                pm.addService(myService.service);
            }
            //
            var uuids:Vector.<String> = new Vector.<String>();
            uuids.push(config.serviceUUID);
            var advertisementData:FPAdvertisementData = new FPAdvertisementData(config.localName, uuids);
            pm.startAdvertising(advertisementData);
        }

        private function discoverPeripheralHandler(event:FPCentralManagerEvent):void
        {
            var peripheral:FPPeripheral = event.peripheral;
            btmLog('discoverPeripheralHandler', peripheral);
            //
            var device:BTMDevice;
            var isCreated:Boolean;
            if (!devicesById.hasByUUID(peripheral.uuid)) {
                isCreated = true;
                //
                device = new BTMDevice(myService, config);
                device.initPeripheral(peripheral);
                //
                devicesById.add(device);
            } else {
                device = devicesById.getByUUID(peripheral.uuid);
                if (!device.initedPeripheral) {
                    device.initPeripheral(peripheral);
                    isCreated = true;
                }
            }
            device.connect();
            //
            btmLog('isCreated:', isCreated, peripheral);
            if (isCreated && this.hasEventListener(FPBluetoothManagerEvent.FIND_DEVICE)) {
                var dropEvent:FPBluetoothManagerEvent = new FPBluetoothManagerEvent(FPBluetoothManagerEvent.FIND_DEVICE);
                dropEvent.device = device;
                this.dispatchEvent(dropEvent);
            }
        }

        private function subscribedToCentralHandler(event:FPCharacteristicEvent):void
        {
            var central:FPCentral = event.central;
            btmLog('subscribedToCentralHandler', central);
            //
            var device:BTMDevice;
            if (!devicesById.hasByUUID(central.uuid)) {
                device = new BTMDevice(myService, config);
                device.initCentral(central);
                devicesById.add(device);
            } else {
                device = devicesById.getByUUID(central.uuid);
                device.initCentral(central);
            }
        }
        private function unsubscribedFromCentralHandler(event:FPCharacteristicEvent):void
        {
            var device:BTMDevice = devicesById.getByUUID(event.central.uuid);
            device.removeCentral();
        }

        private function parseRequestCallback(central:FPCentral, bytes:ByteArray):void
        {
            var device:BTMDevice = devicesById.getByUUID(central.uuid);
            device.parseRequest(bytes);
        }
    }
}
