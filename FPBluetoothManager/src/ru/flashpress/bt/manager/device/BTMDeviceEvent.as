/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager.device
{
    import flash.events.Event;
    import flash.utils.ByteArray;

    public class BTMDeviceEvent extends Event
    {
        public static const INITED_PERIPHERAL:String = 'initedPeripheral';
        public static const INITED_CENTRAL:String = 'initedCentral';
        //
        public static const CONNECTED:String = 'connected';
        public static const DISCONNECTED:String = 'disconnected';
        public static const DATA:String = 'data';
        public static const UPDATE_RSSI:String = 'updateRssi';

        public function BTMDeviceEvent(type:String)
        {
            super(type);
        }

        public var bytes:ByteArray;
        public var dataType:int;
        public var rssi:Number;

        public override function clone():Event
        {
            var cloneEvent:BTMDeviceEvent = new BTMDeviceEvent(this.type);
            cloneEvent.bytes = this.bytes;
            cloneEvent.dataType = this.dataType;
            cloneEvent.rssi = this.rssi;
            return cloneEvent;
        }
    }
}
