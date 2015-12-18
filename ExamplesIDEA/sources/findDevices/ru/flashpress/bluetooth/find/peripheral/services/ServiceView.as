package ru.flashpress.bluetooth.find.peripheral.services
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ru.flashpress.bluetooth.find.peripheral.services.characteristics.CharacteristicsListView;
	import ru.flashpress.bluetooth.helpers.service.FPService;
	import ru.flashpress.bluetooth.ui.box.BoxEvent;
	import ru.flashpress.bluetooth.ui.box.VBox;
	import ru.flashpress.bluetooth.ui.core.Button;
	import ru.flashpress.bluetooth.ui.core.Label;
	import ru.flashpress.bluetooth.ui.log.log;

	public class ServiceView extends Sprite
	{
		private var service:FPService;
		private var rootBox:VBox;
		//
		private var idLabel:Label;
		private var uuidLabel:Label;
		private var uuidDescriptionLabel:Label;
		private var isPrimaryLabel:Label;
		//
		private var discoverButton:Button;
		private var characteristicsListView:CharacteristicsListView;
		public function ServiceView(service:FPService)
		{
			this.service = service;
			//
			rootBox = new VBox(5);
			rootBox.x = 10;
			rootBox.y = 10;
			//
			idLabel = new Label('Service, id:'+service.id, 0x0);
			uuidLabel = new Label('uuid:'+service.uuid);
			uuidDescriptionLabel = new Label('uuid description:'+service.uuidDescription);
			isPrimaryLabel = new Label('is primary:'+service.isPrimary);
			//
			discoverButton = new Button('discover characteristics');
			discoverButton.addEventListener(MouseEvent.CLICK, discoverClickHandler);
			//
			characteristicsListView = new CharacteristicsListView(service);
			//
			rootBox.addChild(idLabel);
			rootBox.addChild(uuidLabel);
			rootBox.addChild(uuidDescriptionLabel);
			rootBox.addChild(isPrimaryLabel);
			rootBox.addChild(discoverButton);
			rootBox.addChild(characteristicsListView);
			//
			this.addChild(rootBox);
			//
			drawBack();
			this.addEventListener(BoxEvent.RESIZE, resizeHandler);
		}
		
		private function resizeHandler(event:Event):void
		{
			drawBack();
		}
		private function drawBack():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x999999, 1);
			this.graphics.drawRect(0, 0, _width, rootBox.height+rootBox.y*2);
			this.graphics.endFill();
		}
		
		private function discoverClickHandler(event:MouseEvent):void
		{
			log('discoverClickHandler: ', service.id);
			service.discoverCharacteristicUUIDs();
		}
		
		private var _width:Number = 100;
		public override function set width(value:Number):void
		{
			_width = value;
			var w:Number = _width-rootBox.x*2;
			idLabel.width = w;
			uuidLabel.width = w;
			uuidDescriptionLabel.width = w;
			isPrimaryLabel.width = w;
			characteristicsListView.width = w;
			//
			drawBack();
		}
	}
}