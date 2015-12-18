/**
 * Created by sam on 10.04.15.
 */
package ru.flashpress.bt.manager.stream
{
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;

    import ru.flashpress.bluetooth.FPBluetooth;

    import ru.flashpress.bluetooth.helpers.characteristic.stream.FPStreamIn;

    public class StreamController extends EventDispatcher
    {
        public function StreamController()
        {
            super();
            //
            outBytes = new ByteArray();
            inBytes = new ByteArray();
        }

        private var outBytes:ByteArray;
        final protected function packCommand(dataBytes:ByteArray=null):ByteArray
        {
            outBytes.length = 0;
            if (dataBytes != null) {
                dataBytes.position = 0;
                outBytes.writeBytes(dataBytes);
            }
            addShortToBegin(outBytes.length, outBytes);
            outBytes.position = 0;
            return outBytes;
        }
        private function addShortToBegin(value:int, pack:ByteArray):void
        {
            // сместить вправо все байты,
            // чтобы осовободить место для длины массива.
            pack.position = 0;
            pack.readBytes(pack, 2);
            //
            // записать в начало длину массива
            pack.position = 0;
            pack.writeShort(value);
        }




        private var packSize:int;
        private var inBytes:ByteArray;
        final protected function readStream(streamIn:FPStreamIn):void
        {
            FPBluetooth.log.streamIn.add('readStream:'+packSize);
            while (1) {
                if (!packSize) {
                    FPBluetooth.log.streamIn.add('  bytes:'+streamIn.bytesAvailable+'/'+streamIn.bytesWaitRetrieve);
                    if (streamIn.bytesAvailable + streamIn.bytesWaitRetrieve < 1) {
                        break;
                        return;
                    }
                    if (streamIn.bytesAvailable < 1) {
                        var count:int = streamIn.retrieve();
                        FPBluetooth.log.streamIn.add('  count:'+count);
                        FPBluetooth.log.streamIn.add('  after retrieve:'+streamIn.bytesAvailable+'/'+streamIn.bytesWaitRetrieve);
                    }
                    try {
                        packSize = streamIn.readUnsignedShort();
                    } catch (error:Error) {
                        FPBluetooth.log.streamIn.add('  error:'+error);
                        trace('Error read pack size: '+error);
                        return;
                    }
                } else {
                    if (streamIn.bytesAvailable  + streamIn.bytesWaitRetrieve < packSize) {
                        break;
                        return;
                    }
                    if (streamIn.bytesAvailable < packSize) {
                        streamIn.retrieve();
                    }
                    //
                    inBytes.length = inBytes.position = 0;
                    try {
                        streamIn.readBytes(inBytes, 0, packSize);
                    } catch (error:Error) {
                        trace('Error read bytes: '+error);
                        return;
                    }
                    packSize = 0;
                    inBytes.position = 0;
                    parseNotify(inBytes);
                }
            }
        }

        public var parseNotifyCallback:Function;
        private function parseNotify(inBytes:ByteArray):void
        {
            if (parseNotifyCallback != null) {
                parseNotifyCallback.call(null, inBytes);
            }
        }

    }
}
