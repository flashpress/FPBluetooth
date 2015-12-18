/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager.device
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;

    import ru.flashpress.bluetooth.events.FPPeripheralEvent;
    import ru.flashpress.bluetooth.helpers.central.FPCentral;

    import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheral;
    import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectingState;
    import ru.flashpress.bt.manager.BTMConfig;
    import ru.flashpress.bt.manager.BTMMyService;
    import ru.flashpress.bt.manager.core.ns.bluetoothManagerNS;
    import ru.flashpress.bt.manager.core.ns.log.btmLog;
    import ru.flashpress.bt.manager.stream.bytesToString;

    public class BTMDevice extends EventDispatcher
    {
        use namespace bluetoothManagerNS;

        private var myService:BTMMyService;
        private var peripheral:FPPeripheral;
        private var config:BTMConfig;
        //
        private var deviceService:BTMDeviceService;
        public function BTMDevice(myService:BTMMyService, config:BTMConfig)
        {
            this.myService = myService;
            this.config = config;
            //
            this.deviceService = new BTMDeviceService(config.serviceUUID, config.characteristicUUID);
            this.deviceService.addEventListener(Event.COMPLETE, serviceCompleteHandler);
            this.deviceService.parseNotifyCallback = parseNotify;
        }

        private var _uuid:String;
        public function get uuid():String {return this._uuid;}

        // init methods ************************************************************************

        private function updateRSSIHandler(event:FPPeripheralEvent):void
        {
            var dropEvent:BTMDeviceEvent = new BTMDeviceEvent(BTMDeviceEvent.UPDATE_RSSI);
            dropEvent.rssi = event.rssi;
            this.dispatchEvent(dropEvent);
        }


        public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeak:Boolean=false):void
        {
            super.addEventListener(type, listener, useCapture, priority, useWeak);
            //
            switch (type) {
                case BTMDeviceEvent.UPDATE_RSSI:
                        peripheral.addEventListener(FPPeripheralEvent.UPDATE_RSSI, updateRSSIHandler);
                    break;
            }
        }
        public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            super.removeEventListener(type, listener, useCapture);
            //
            switch (type) {
                case BTMDeviceEvent.UPDATE_RSSI:
                        peripheral.removeEventListener(FPPeripheralEvent.UPDATE_RSSI, updateRSSIHandler);
                    break;
            }
        }

        private var _initedPeripheral:Boolean;
        public function get initedPeripheral():Boolean {return this._initedPeripheral;}

        bluetoothManagerNS function initPeripheral(peripheral:FPPeripheral):void
        {
            btmLog('BTMDevice:initPeripheral');
            btmLog(' peripheral:', peripheral);
            if (this._initedPeripheral) return;
            //
            this._initedPeripheral = true;
            this._uuid = peripheral.uuid;
            //
            this.peripheral = peripheral;
            this.peripheral.addEventListener(FPPeripheralEvent.CONNECTED, peripheralConnectedHandler);
            this.peripheral.addEventListener(FPPeripheralEvent.DISCONNECT, peripheralDisconnectedHandler);
            this.peripheral.addEventListener(FPPeripheralEvent.DISCOVER_SERVICES, discoverServicesHandler);
            this.peripheral.addEventListener(FPPeripheralEvent.MODIFY_SERVICES, modifyServicesHandler);
            //
            this.dispatchEvent(new BTMDeviceEvent(BTMDeviceEvent.INITED_PERIPHERAL));
        }

        private var central:FPCentral;
        bluetoothManagerNS function initCentral(central:FPCentral):void
        {
            btmLog('BTMDevice:initCentral');
            btmLog(' central:', central);
            if (this.central) return;
            //
            this._uuid = central.uuid;
            //
            this.central = central;
            //
            this.dispatchEvent(new BTMDeviceEvent(BTMDeviceEvent.INITED_CENTRAL));
            //
            checkConnected();
        }

        bluetoothManagerNS function removeCentral():void
        {
            this.central = null;
            //
            disconnected();
        }

        // private methods ************************************************************************

        private function peripheralConnectedHandler(event:FPPeripheralEvent):void
        {
            btmLog('BTMDevice:peripheralConnectedHandler');
            peripheral.discoverServiceUUIDs(deviceService.serviceUUID);
        }
        private function peripheralDisconnectedHandler(event:FPPeripheralEvent):void
        {
            btmLog('BTMDevice:peripheralDisconnectedHandler');
            serviceComplete = false;
            deviceService.stop();
            disconnected();
        }
        private function discoverServicesHandler(event:FPPeripheralEvent):void
        {
            btmLog('BTMDevice:discoverServicesHandler');
            deviceService.update(peripheral.services.findByUUID(deviceService.serviceUUID));
        }
        private function modifyServicesHandler(event:FPPeripheralEvent):void
        {
            if (event.invalidateServices && event.invalidateServices.indexOf(deviceService.serviceUUID)) {
                serviceComplete = false;
                disconnected();
            }
            peripheral.discoverServiceUUIDs(deviceService.serviceUUID);
        }

        private var serviceComplete:Boolean;
        private function serviceCompleteHandler(event:Event):void
        {
            btmLog('BTMDevice:serviceCompleteHandler');
            serviceComplete = true;
            checkConnected();
        }

        private var _connected:Boolean;
        public function get connected():Boolean {return this._connected;}

        private function checkConnected():void
        {
            btmLog('BTMDevice:checkConnected', serviceComplete);
            var subscribedCentrals:Vector.<String> = myService.characteristic.subscribedCentrals;
            btmLog('    subscribedCentrals:', subscribedCentrals);
            btmLog('    central:', central);
            //
            if (central && subscribedCentrals && subscribedCentrals.indexOf(central.id) == -1) {
                central = null;
            }
            //
            if (serviceComplete && central != null) {
                _connected = true;
                //
                this.dispatchEvent(new BTMDeviceEvent(BTMDeviceEvent.CONNECTED));
            } else {
                _connected = false;
            }
        }
        private function disconnected():void
        {
            if (_connected) {
                _connected = false;
                this.dispatchEvent(new BTMDeviceEvent(BTMDeviceEvent.DISCONNECTED));
            }
        }

        private function parseNotify(bytes:ByteArray):void
        {
            btmLog('BTMDevice:parseCommand');
            btmLog(' bytes:', bytesToString(bytes));
            //
            var dropEvent:BTMDeviceEvent = new BTMDeviceEvent(BTMDeviceEvent.DATA);
            dropEvent.bytes = bytes;
            dropEvent.dataType = BTMDataTypes.NOTIFY;
            this.dispatchEvent(dropEvent);
        }

        bluetoothManagerNS function parseRequest(bytes:ByteArray):void
        {
            btmLog('BTMDevice:parseRequest');
            btmLog(' bytes:', bytesToString(bytes));
            //
            var dropEvent:BTMDeviceEvent = new BTMDeviceEvent(BTMDeviceEvent.DATA);
            dropEvent.bytes = bytes;
            dropEvent.dataType = BTMDataTypes.REQUEST;
            this.dispatchEvent(dropEvent);
        }

        // public methods ************************************************************************

        public function connect():void
        {
            btmLog('BTMDevice:connect, state:'+peripheral.connectingState);
            if (peripheral.connectingState != FPPeripheralConnectingState.CONNECTED && peripheral.connectingState != FPPeripheralConnectingState.CONNECTING) {
                peripheral.connect(config.connectOptions);
            }
        }

        public function stop():void
        {
            deviceService.stop();
            peripheral.cancelConnect();
            //
            disconnected();
        }

        public function get id():String {return peripheral.id;}
        public function get name():String {return peripheral.name;}
        public function get localName():String {return peripheral.advertisementInited.localName;}
        public function get rssi():Number {return peripheral.rssi;}

        public function send(bytes:ByteArray):Boolean
        {
            btmLog('BTMDevice:send');
            if (!_connected) {
                btmLog('Device is not connected!');
                return false;
            }
            myService.setRecipient(this.central);
            myService.writeBytes(bytes);
            return true;
        }
    }
}
