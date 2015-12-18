/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager
{
    import flash.events.Event;

    import ru.flashpress.bt.manager.device.BTMDevice;

    public class FPBluetoothManagerEvent extends Event
    {
        public static const FIND_DEVICE:String = 'findDevice';

        public function FPBluetoothManagerEvent(type:String)
        {
            super(type);
        }

        public var device:BTMDevice;
    }
}
