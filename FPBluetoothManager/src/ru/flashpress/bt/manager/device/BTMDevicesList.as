/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager.device
{

    public class BTMDevicesList
    {
        private var deviceByUUID:Object;
        private var list:Vector.<BTMDevice>;
        public function BTMDevicesList()
        {
            deviceByUUID = {};
            list = new Vector.<BTMDevice>();
        }

        public function hasByUUID(uuid:String):Boolean
        {
            return deviceByUUID.hasOwnProperty(uuid);
        }

        public function add(device:BTMDevice):void
        {
            if (deviceByUUID[device.uuid]) return;
            deviceByUUID[device.uuid] = device;
            list.push(device);
        }

        public function getByUUID(uuid:String):BTMDevice
        {
            return deviceByUUID[uuid];
        }

        public function stopAll():void
        {
            var i:int;
            var count:int = list.length;
            var device:BTMDevice;
            for (i=0; i<count; i++) {
                device = list[i];
                device.stop();
            }
        }

        public function reconnectAll():void
        {
            var i:int;
            var count:int = list.length;
            var device:BTMDevice;
            for (i=0; i<count; i++) {
                device = list[i];
                device.connect();
            }
        }
    }
}
