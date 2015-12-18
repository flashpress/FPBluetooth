package {

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import ru.flashpress.ane.queue.FPQueueData;

    import ru.flashpress.ane.queue.FPQueueTypes;

    import ru.flashpress.bluetooth.FPBluetooth;
    import ru.flashpress.bluetooth.data.FPBluetoothOptions;
    import ru.flashpress.bluetooth.helpers.peripheral.FPPeripheralConnectionOptions;
    import ru.flashpress.bluetooth.managers.central.FPcmScanOptions;
    import ru.flashpress.bt.manager.BTMConfig;

    import ru.flashpress.bt.manager.FPBluetoothManager;
    import ru.flashpress.bt.manager.FPBluetoothManagerEvent;
    import ru.flashpress.bt.manager.device.BTMDevice;
    import ru.flashpress.bt.manager.device.BTMDeviceEvent;
    import ru.flashpress.bt.manager.stream.StreamBytes;

    public class ExampleManager extends Sprite
    {
        public static const COMMAND_INIT:int = 1;

        private var textField:TextField;

        public function ExampleManager()
        {
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.align = StageAlign.TOP_LEFT;
            //
            textField = new TextField();
            textField.x = 10;
            textField.y = 50;
            textField.defaultTextFormat = new TextFormat('Tahoma', 22);
            textField.multiline = textField.wordWrap = true;
            textField.width = this.stage.stageWidth-textField.x*2;
            textField.height = this.stage.stageHeight-textField.y-10;
            textField.background = true;
            textField.border = true;
            this.addChild(textField);
            //
            createManager();
        }

        private function log(...messages):void
        {
            var m:String = messages.join(' ');
            trace(m);
            textField.appendText(m+'\n');
            textField.scrollV = textField.maxScrollV;
        }

        private var manager:FPBluetoothManager;
        private function createManager():void
        {
            log('create manager');
            FPBluetooth.demo(this.stage);
            //
            var config:BTMConfig = new BTMConfig();
            //
            config.initOptions = new FPBluetoothOptions();
            config.initOptions.nativeLogEnabled = true;
            //
            config.localName = 'btm  manager';
            //
            config.serviceUUID = 'E20A39F4-73F5-4BC4-A12F-17D1AD07A961';
            config.characteristicUUID = '08590F7E-DB05-467E-8757-72F6FAEB13D4';
            //
            config.cmQueue = new FPQueueData('ru.flashpress.chat.central', FPQueueTypes.SERIAL);
            config.scanOptions = new FPcmScanOptions(true, null);
            //
            config.connectOptions = new FPPeripheralConnectionOptions();
            config.connectOptions.notifyOnConnection = true;
            config.connectOptions.notifyOnDisconnection = true;
            config.connectOptions.notifyOnNotification = true;
            //
            manager = new FPBluetoothManager(config);
            manager.init();
            //
            log('--- FPBluetooth ---');
            log('   version:', FPBluetooth.VERSION+'.'+FPBluetooth.BUILD);
            log('   available:', FPBluetooth.available);
            log('   platform:', FPBluetooth.platform);
            //
            manager.addEventListener(FPBluetoothManagerEvent.FIND_DEVICE, findDeviceHandler);
            manager.start();
        }

        private function findDeviceHandler(event:FPBluetoothManagerEvent):void
        {
            var device:BTMDevice = event.device;
            //
            log('find device:');
            log(' uuid:', device.uuid);
            log(' device name:', device.name);
            log(' local name:', device.localName);
            log(' rssi:', device.rssi);
            //
            device.addEventListener(BTMDeviceEvent.DISCONNECTED, disconnectedHandler);
            device.addEventListener(BTMDeviceEvent.DATA, dataHandler);
            //
            if (device.connected) {
                deviceConnected(device);
            } else {
                device.addEventListener(BTMDeviceEvent.CONNECTED, connectedHandler);
            }
        }

        private var sendBytes:StreamBytes = new StreamBytes();
        private function deviceConnected(device:BTMDevice):void
        {
            log('device connected:', device.uuid);
            //
            var command:int = COMMAND_INIT;
            var localTime:Number = (new Date()).getTime();
            var text:String = 'bla bla text';
            //
            sendBytes.length = 0;
            sendBytes.writeByte(command);
            sendBytes.writeUnsignedInt(localTime);
            sendBytes.writeString(text);
            device.send(sendBytes);
        }
        private function connectedHandler(event:BTMDeviceEvent):void
        {
            var device:BTMDevice = event.currentTarget as BTMDevice;
            deviceConnected(device);
        }

        private function disconnectedHandler(event:BTMDeviceEvent):void
        {
            var device:BTMDevice = event.currentTarget as BTMDevice;
            log('device disconnected:', device.uuid);
        }

        private function dataHandler(event:BTMDeviceEvent):void
        {
            var device:BTMDevice = event.currentTarget as BTMDevice;
            log('data from device:', device.uuid);
            //
            var command:int = event.bytes.readByte();
            switch (command) {
                case COMMAND_INIT:
                    var localTime:Number = event.bytes.readUnsignedInt();
                    var text:String = StreamBytes.readString(event.bytes);
                    log(' device init');
                    log(' local time:', localTime);
                    log(' text:', text);
                    break;
            }
        }
    }
}
