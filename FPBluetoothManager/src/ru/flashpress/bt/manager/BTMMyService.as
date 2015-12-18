/**
 * Created by sam on 10.04.15.
 */
package ru.flashpress.bt.manager
{

    import flash.utils.ByteArray;

    import ru.flashpress.bluetooth.events.FPCharacteristicEvent;
    import ru.flashpress.bluetooth.helpers.central.FPCentral;

    import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristic;
    import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicPermissions;
    import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicProperties;
    import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicValueFormat;

    import ru.flashpress.bluetooth.helpers.service.FPService;
    import ru.flashpress.bt.manager.core.ns.bluetoothManagerNS;
    import ru.flashpress.bt.manager.core.ns.log.btmLog;
    import ru.flashpress.bt.manager.stream.StreamBytes;
    import ru.flashpress.bt.manager.stream.StreamController;
    import ru.flashpress.bt.manager.stream.bytesToString;

    public class BTMMyService extends StreamController
    {
        use namespace bluetoothManagerNS;
        //
        bluetoothManagerNS var service:FPService;
        bluetoothManagerNS var characteristic:FPCharacteristic;
        bluetoothManagerNS var bytesOut:StreamBytes;
        public function BTMMyService()
        {
            super();
            //
            bytesOut = new StreamBytes();
        }

        private var _serviceUUID:String;
        private var _characteristicUUID:String;
        bluetoothManagerNS function createService(config:BTMConfig):void
        {
            btmLog('BTMMyService:createService');
            this._serviceUUID = config.serviceUUID;
            this._characteristicUUID = config.characteristicUUID;
            //
            service = new FPService(this._serviceUUID);
            //
            var properties:uint = FPCharacteristicProperties.NOTIFY | FPCharacteristicProperties.WRITE_WITHOUT_RESPONSE;
            var permissions:uint = FPCharacteristicPermissions.WRITEABLE;
            var valueFormat:uint = FPCharacteristicValueFormat.BYTES;
            characteristic = new FPCharacteristic(this._characteristicUUID, properties, permissions, valueFormat);
            characteristic.addEventListener(FPCharacteristicEvent.SUBSCRIBED_TO_CENTRAL, subscribedToCentralHandler);
            characteristic.addEventListener(FPCharacteristicEvent.UNSUBSCRIBED_FROM_CENTRAL, unsubscribedFromCentralHandler);
            characteristic.addEventListener(FPCharacteristicEvent.RECEIVE_WRITE_REQUEST, writeRequestHandler);
            characteristic.notifyMTU = 100;
            //
            service.addCharacteristic(characteristic);
        }

        private function unsubscribedFromCentralHandler(event:FPCharacteristicEvent):void
        {
            btmLog('BTMMyService:unsubscribedFromCentralHandler');
        }
        private function subscribedToCentralHandler(event:FPCharacteristicEvent):void
        {
            btmLog('BTMMyService:subscribedToCentralHandler');
        }
        private function writeRequestHandler(event:FPCharacteristicEvent):void
        {
            btmLog('BTMMyService:writeRequestHandler');
            var bytes:ByteArray = event.request.valueBytes;
            btmLog(' bytes:', bytesToString(bytes));
            bytes.position = 2; // shift short length
            parseRequest(event.request.central, bytes);
        }

        bluetoothManagerNS var parseRequestCallback:Function;
        protected function parseRequest(central:FPCentral, bytes:ByteArray):void
        {
            btmLog('BTMMyService:parseRequest', central.uuid, bytesToString(bytes));
            if (parseRequestCallback) {
                parseRequestCallback.call(null, central, bytes);
            }
        }

        private var currentRecipient:FPCentral;
        bluetoothManagerNS function setRecipient(central:FPCentral):void
        {
            if (currentRecipient == central) return;
            this.currentRecipient = central;
            characteristic.streamOut.setRecipients(central.id);

        }

        public function writeBytes(bytes:ByteArray):void
        {
            btmLog('BTMMyService:writeBytes', bytesToString(bytes));
            characteristic.streamOut.writeBytes(this.packCommand(bytes));
        }

    }
}
