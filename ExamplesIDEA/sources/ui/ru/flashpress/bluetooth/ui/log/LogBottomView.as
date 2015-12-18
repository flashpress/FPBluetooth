package ru.flashpress.bluetooth.ui.log
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import ru.flashpress.bluetooth.helpers.characteristic.stream.FPStreamStatistic;
	import ru.flashpress.bluetooth.ui.core.Button;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.core.Shared;

	public class LogBottomView extends Sprite
	{
		private static var _instance:LogBottomView;
		public static function get instance():LogBottomView {return _instance;}
		//
		//
		//
		private var logField:Label;
		private var logback:Shape;
		private var buttonHeight:Button;
		private var statisticField:Label;
		public function LogBottomView()
		{
			_instance = this;
			//
			logHeight = Shared.open('logHeight', 0.3);
			//
			logback = new Shape();
			logback.graphics.beginFill(0xe0dede, 1);
			logback.graphics.drawRect(0, 0, 10, 10);
			logback.graphics.endFill();
			this.addChild(logback);
			//
			logField = new Label();
			logField.selectable = true;
			var size:int = Capabilities.os && Capabilities.os.indexOf('iPhone') != -1 ? 20 : 12;
			logField.defaultTextFormat = new TextFormat('Tahoma', size);
			logField.autoSize = TextFieldAutoSize.NONE;
			logField.multiline = true;
			logField.wordWrap = true;
			logField.border = true;
			logField.textColor = 0x0;
			this.addChild(logField);
			//
			buttonHeight = new Button('drag for resize log', 0x666666, 0xbbbbbb);
			this.addChild(buttonHeight);
			//
			dragBound = buttonHeight.height*1.2;
			//
			statisticField = new Label(' ', true);
			this.addChild(statisticField);
			//
			buttonHeight.addEventListener(MouseEvent.MOUSE_DOWN, dragDownHandler);
		}
		
		private var dragBound:int;
		private function dragDownHandler(event:MouseEvent):void
		{
			buttonHeight.startDrag(false, new Rectangle(0, dragBound, 0, _height-dragBound*2));
			//
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		private function moveHandler(event:MouseEvent):void
		{
			event.updateAfterEvent();
			logback.y = logField.y = buttonHeight.y+buttonHeight.height;
			logback.height = logField.height = _height-logField.y;
			logHeight = logField.height/_height;
			statisticField.y = buttonHeight.y-statisticField.height;
		}
		private function upHandler(event:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			buttonHeight.stopDrag();
			Shared.save('logHeight', logHeight);
		}
		
		private var logHeight:Number = 0.3;
		protected var _width:Number = 100;
		protected var _height:Number = 100;
		public function resize(w:Number, h:Number):void
		{
			this._width = w;
			this._height = h;
			//
			logField.width = w-1;
			logField.height = h*logHeight;
			logField.y = h-logField.height;
			//
			logback.width = logField.width;
			logback.height = logField.height;
			logback.y = logField.y;
			//
			buttonHeight.width = w;
			buttonHeight.y = logField.y-buttonHeight.height;
			logField.scrollV = logField.maxScrollV;
			//
			statisticField.y = buttonHeight.y-statisticField.height;
		}
		
		private var textLog:String = '';
		public function addLog(...messages):void
		{
			var date:Date = new Date();
			date.time = getTimer();
			var timeString:String = timeFormat(date.getMinutes(), 2)+':'+timeFormat(date.getSeconds(), 2)+':'+timeFormat(date.getMilliseconds(), 3)+'| ';
			//trace(messages.join(' '));
			textLog += timeString+messages.join(' ')+'<br>';
			logField.htmlText = textLog;
			logField.scrollV = logField.maxScrollV;
		}
		
		private function timeFormat(num:int, len:int):String
		{
			var str:String = '000'+num;
			return str.slice(str.length-len);
		}
		
		public function updateStatistic(statistic:FPStreamStatistic):void
		{
			statisticField.text = 'statistic: send:'+statistic.sendCount+', recieve:'+statistic.recieveCount;
		}
	}
}