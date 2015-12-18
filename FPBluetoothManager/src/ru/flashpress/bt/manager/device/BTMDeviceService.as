/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager.device
{
    import flash.events.Event;

    import ru.flashpress.bluetooth.events.FPCharacteristicEvent;

    import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristic;
    import ru.flashpress.bluetooth.helpers.characteristic.FPCharacteristicValueFormat;

    import ru.flashpress.bluetooth.helpers.service.FPService;
    import ru.flashpress.bluetooth.helpers.service.FPServiceEvent;
    import ru.flashpress.bt.manager.core.ns.log.btmLog;
    import ru.flashpress.bt.manager.stream.StreamController;

    public class BTMDeviceService extends StreamController
    {
        internal var serviceUUID:String;
        internal var characteristicUUID:String;
        //
        internal var service:FPService;
        internal var characteristic:FPCharacteristic;
        public function BTMDeviceService(serviceUUID:String, characteristicUUID:String)
        {
            this.serviceUUID = serviceUUID;
            this.characteristicUUID = characteristicUUID;
        }

        public function update(service:FPService):void
        {
            btmLog('BTMDeviceService:update');
            if (this.service == service) return;
            //
            stop();
            //
            this.service = service;
            if (this.service) {
                this.service.addEventListener(FPServiceEvent.DISCOVER_CHARACTERISTICS, discoverCharacteristicsHandler);
                this.service.discoverCharacteristicUUIDs(characteristicUUID);
            }
        }

        private function discoverCharacteristicsHandler(event:FPServiceEvent):void
        {
            btmLog('BTMDeviceService:discoverCharacteristicsHandler');
            characteristic = service.characteristics.findByUUID(characteristicUUID);
            characteristic.initValueFormat(FPCharacteristicValueFormat.BYTES);
            characteristic.addEventListener(FPCharacteristicEvent.UPDATE_NOTIFICATION, updateNotifyHandler);
            characteristic.addEventListener(FPCharacteristicEvent.UPDATE_BYTES, updateBytesHandler);
            characteristic.setNotify(true);
        }

        private function updateNotifyHandler(event:FPCharacteristicEvent):void
        {
            if (event.isNotifying) {
                this.dispatchEvent(new Event(Event.COMPLETE));
            } else {
                trace('!!!!!!!!! error: isNotifying=false !!!!!!!!!');
            }
        }

        private function updateBytesHandler(event:FPCharacteristicEvent):void
        {
            btmLog('BTMDeviceService:updateBytesHandler');
            readStream(characteristic.streamIn);
        }

        public function stop():void
        {
            if (this.service) {
                this.service.removeEventListener(FPServiceEvent.DISCOVER_CHARACTERISTICS, discoverCharacteristicsHandler);
                if (characteristic) {
                    characteristic.removeEventListener(FPCharacteristicEvent.UPDATE_BYTES, updateBytesHandler);
                    characteristic.removeEventListener(FPCharacteristicEvent.UPDATE_NOTIFICATION, updateNotifyHandler);
                    if (characteristic.isNotifying && !characteristic.invalidated) {
                        characteristic.setNotify(false);
                    }
                    characteristic = null;
                }
                service = null;
            }
        }
    }
}
