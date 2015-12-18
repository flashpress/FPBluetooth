package ru.flashpress.bluetooth.ui.core
{
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class MouseView extends Shape
	{
		private var stageLink:Stage;
		public function MouseView(stage:Stage)
		{
			this.graphics.lineStyle(2, 0x0, 1);
			this.graphics.drawCircle(0, 0, 40);
			this.graphics.endFill();
			//
			this.stageLink = stage;
			this.stageLink.addEventListener(MouseEvent.MOUSE_DOWN, downHandler, true);
			this.stageLink.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			this.stageLink.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		
		private function downHandler(event:MouseEvent):void
		{
			this.removeEventListener(Event.ENTER_FRAME, hideHandler);
			//
			this.x = event.stageX;
			this.y = event.stageY;
			stageLink.addChild(this);
		}
		private function moveHandler(event:MouseEvent):void
		{
			event.updateAfterEvent();
			this.x = event.stageX;
			this.y = event.stageY;
		}
		private function upHandler(event:MouseEvent):void
		{
			this.addEventListener(Event.ENTER_FRAME, hideHandler);
		}
		
		private function hideHandler(event:Event):void
		{
			this.alpha -= 0.15;
			if (this.alpha <= 0) {
				this.alpha = 1;
				this.removeEventListener(Event.ENTER_FRAME, hideHandler);
				if (stageLink.contains(this)) {
					stageLink.removeChild(this);
				}
			}
		}
	}
}