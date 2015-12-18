/**
 * Created by sam on 15.04.15.
 */
package ru.flashpress.bt.manager
{
    import ru.flashpress.ane.queue.FPQueueData;
    import ru.flashpress.bluetooth.data.FPBluetoothOptions;
    import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectionOptions;
    import ru.flashpress.bluetooth.managers.central.FPcmScanOptions;

    public class BTMConfig
    {
        public function BTMConfig()
        {
        }

        public var initOptions:FPBluetoothOptions;

        public var localName:String;

        public var serviceUUID:String;
        public var characteristicUUID:String;

        public var cmQueue:FPQueueData;
        public var scanOptions:FPcmScanOptions;

        public var pmQueue:FPQueueData;
        public var connectOptions:FPPeripheralConnectionOptions;
    }
}
