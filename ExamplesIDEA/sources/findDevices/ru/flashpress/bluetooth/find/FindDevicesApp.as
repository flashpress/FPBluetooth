package ru.flashpress.bluetooth.find
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ru.flashpress.ane.queue.FPQueueData;
	import ru.flashpress.ane.queue.FPQueueTypes;
	import ru.flashpress.bluetooth.FPBluetooth;
	import ru.flashpress.bluetooth.constants.FPbtState;
	import ru.flashpress.bluetooth.data.FPBluetoothOptions;
    import ru.flashpress.bluetooth.error.FPBluetoothError;
	import ru.flashpress.bluetooth.events.FPBluetoothEvent;
	import ru.flashpress.bluetooth.find.peripheral.PeripheralsListView;
	import ru.flashpress.bluetooth.managers.central.FPCentralManager;
	import ru.flashpress.bluetooth.managers.central.FPcmInitOptions;
	import ru.flashpress.bluetooth.managers.central.FPcmScanOptions;
	import ru.flashpress.bluetooth.ui.Conf;
	import ru.flashpress.bluetooth.ui.box.HBox;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Button;
	import ru.flashpress.bluetooth.ui.core.CheckBox;
	import ru.flashpress.bluetooth.ui.core.Input;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.core.MouseView;
	import ru.flashpress.bluetooth.ui.core.Shared;
	import ru.flashpress.bluetooth.ui.log.LogBottomView;
	import ru.flashpress.bluetooth.ui.log.log;
	import ru.flashpress.bluetooth.ui.log.logError;

	public class FindDevicesApp extends Sprite
	{
		public function FindDevicesApp()
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			//
			Conf.init(this.stage);
			//
			if (Conf.isMobile) {
				new MouseView(this.stage);
			}
			//
			createUI();
			//
			initBluetooth();
		}
		
		private function initBluetooth():void
		{
			FPBluetooth.demo(this.stage);
			//
			var options:FPBluetoothOptions = new FPBluetoothOptions();
			FPBluetooth.init(options);
            //
            log('FPBluetooth, version:'+FPBluetooth.VERSION+', build:'+FPBluetooth.BUILD);
		}
		
		private var rootBox:VBox;
		private var logView:LogBottomView;
		//
		private var queueInput:Input;
		private var showAlertBox:CheckBox;
		private var createButton:Button;
		private var stateLabel:Label;
		//
		private var scanServicesOnlyInput:Input;
		private var allowDuplicatesBox:CheckBox;
		private var startScanButton:Button;
		private var peripheralsListView:PeripheralsListView;
		private function createUI():void
		{
			var sensor:Sprite = new Sprite();
			sensor.graphics.clear();
			sensor.graphics.beginFill(0xff0000, 0);
			sensor.graphics.drawRect(0, 0, Conf.width, Conf.height);
			sensor.graphics.endFill();
			this.addChild(sensor);
			//
			rootBox = new VBox(15);
			rootBox.name = 'root';
			rootBox.x = 20;
			rootBox.y = 50;
			//
			queueInput = new Input();
			queueInput.width = 200;
			//
			showAlertBox = new CheckBox('show alert', 'showAlertBox', false, true);
			//
			createButton = new Button('create manager');
			createButton.addEventListener(MouseEvent.CLICK, createClickHnadler);
			//
			stateLabel = new Label('state: none', true, null, 1);
			//
			//
			//
			scanServicesOnlyInput = new Input(0.7);
			scanServicesOnlyInput.multiline = true;
			scanServicesOnlyInput.height = 60;
			scanServicesOnlyInput.text = Shared.open('scanServicesOnlyInput', '');
			scanServicesOnlyInput.enabled = false;
			//
			allowDuplicatesBox = new CheckBox('allow duplicates', 'allowDuplicatesBox', false, true);
			allowDuplicatesBox.enabled = false;
			//
			startScanButton = new Button('scan devices');
			startScanButton.enabled = false;
			startScanButton.addEventListener(MouseEvent.CLICK, scanClickHandler);
			//
			peripheralsListView = new PeripheralsListView();
			peripheralsListView.width = Conf.width;
			//
			logView = new LogBottomView();
			//
			this.addChild(rootBox);
			rootBox.addChild(HBox.create(new Label('queue', true), queueInput));
			rootBox.addChild(HBox.create(showAlertBox, createButton));
			rootBox.addChild(stateLabel);
			rootBox.addChild(VBox.create(0, new Label('Enter the services or blank for find all devices:', true, null, 0.7), scanServicesOnlyInput));
			rootBox.addChild(HBox.create(allowDuplicatesBox, startScanButton));
			rootBox.addChild(peripheralsListView);
			this.addChild(logView);
			//
			this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			//
			sensor.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			rootBox.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		private function stageResizeHandler(event:Event):void
		{
			var w:Number = Conf.width-rootBox.x*2;
			if (Conf.isMobile) w -= 50;
			//
			scanServicesOnlyInput.width = w;
			//
			if (peripheralsListView) {
				peripheralsListView.width = w;
			}
			//
			logView.resize(Conf.width, Conf.height);
		}
		
		private function wheelHandler(event:MouseEvent):void
		{
			var ypos:Number = rootBox.y + event.delta*2;
			if (ypos < this.stage.stageHeight-rootBox.height)  ypos = this.stage.stageHeight-rootBox.height-100;
			if (ypos > 0) ypos = 0;
			rootBox.y = ypos;
		}
		private function downHandler(event:MouseEvent):void
		{
			if (rootBox.height < Conf.height) return;
			var minY:Number = Conf.height-rootBox.height;
			rootBox.startDrag(false, new Rectangle(20, minY-100, 0, -minY+200));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
		}
		private function stageMoveHandler(event:MouseEvent):void
		{
			event.updateAfterEvent();
		}
		private function stageUpHandler(event: MouseEvent):void
		{
			rootBox.stopDrag();
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
		}
		
		private var centralManager:FPCentralManager;
		private function createClickHnadler(event:MouseEvent):void
		{
			log('create manager2');
			//
			showAlertBox.enabled = false;
			createButton.enabled = false;
			queueInput.enabled = false;
			//
			var initOptions:FPcmInitOptions = new FPcmInitOptions(null, showAlertBox.selected);
			centralManager = new FPCentralManager(initOptions, new FPQueueData(queueInput.name, FPQueueTypes.SERIAL));
			centralManager.addEventListener(FPBluetoothEvent.UPDATE_STATE, managerUpdateStateHandler);
			peripheralsListView.init(centralManager);
		}
		
		private function managerUpdateStateHandler(event:FPBluetoothEvent):void
		{
			log('managerUpdateStateHandler:', event.state);
			if (centralManager.state == FPbtState.POWERED_ON) {
				startScanButton.enabled = true;
				allowDuplicatesBox.enabled = true;
				scanServicesOnlyInput.enabled = true;
			} else {
				startScanButton.enabled = false;
				allowDuplicatesBox.enabled = false;
				allowDuplicatesBox.selected = false;
				scanServicesOnlyInput.enabled = false;
			}
			//
			switch (centralManager.state) {
				case FPbtState.UNKNOWN:
					stateLabel.text = 'state: unknow';
					stateLabel.textColor = 0x0;
					break;
				case FPbtState.RESETTING:
					stateLabel.text = 'state: resetting';
					stateLabel.textColor = 0x000099;
					break;
				case FPbtState.UNSUPPORTED:
					stateLabel.text = 'state: unsupported';
					stateLabel.textColor = 0x999999;
					break;
				case FPbtState.POWERED_OFF:
					stateLabel.text = 'state: powered OFF';
					stateLabel.textColor = 0xff0000;
					break;
				case FPbtState.POWERED_ON:
					stateLabel.text = 'state: powered on';
					stateLabel.textColor = 0x009900;
					break;
			}
		}
		
		private function scanClickHandler(event:MouseEvent):void
		{
			log('scanClickHandler:', centralManager.scanning);
			if (!centralManager.scanning) {
				Shared.save('scanServicesOnlyInput', scanServicesOnlyInput.text);
				//
				startScanButton.label = 'stop scan';
				allowDuplicatesBox.enabled = false;
				//
				var findServices:Array;
				if (scanServicesOnlyInput.text != '') {
					findServices = [];
					var temp:Array = scanServicesOnlyInput.text.split(',');
					var i:int;
					for (i=0; i<temp.length; i++) {
						findServices.push(temp[i]);
					}
					log('  findServices: \n   '+findServices.join('\n  '));
				} else {
					log('  findServices: null');
				}
				//
				var options:FPcmScanOptions = new FPcmScanOptions(allowDuplicatesBox.selected, null);
				try {
					centralManager.startScan(options, findServices);
				} catch (error:FPBluetoothError) {
					logError('error: '+error);
					logError('exception: '+error.exception);
					if (error.exception) {
						logError('  callStackSymbols: '+error.exception.callStackSymbols);
						logError('  callStackReturnAddresses: '+error.exception.callStackReturnAddresses);
					}
				}
			} else {
				startScanButton.label = 'start scan';
				allowDuplicatesBox.enabled = true;
				//
				centralManager.stopScan();
			}
		}
	}
}