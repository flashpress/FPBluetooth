package ru.flashpress.bluetooth.ui.box
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class VBox extends Sprite
	{
		public static function create(...childs):VBox
		{
			var box:VBox = new VBox(childs[0] is Number?childs[0]:10);
			var i:int;
			for (i=0; i<childs.length; i++) {
				if (!(childs[i] is Number)) {
					box.addChild(childs[i]);
				}
			}
			return box;
		}
		//
		//
		//
		private var gap:Number;
		public function VBox(gap:Number=10)
		{
			this.gap = gap;
			this.maxHeight = 0;
			//
			this.addEventListener(BoxEvent.RESIZE, resizeHandler);
		}
		
		private function resizeHandler(event:BoxEvent):void
		{
			reposition();
		}
		
		private var maxHeight:Number;
		public function reposition():void
		{
			var i:int;
			var child:DisplayObject;
			maxHeight = 0;
			for (i=0; i<this.numChildren; i++) {
				child = this.getChildAt(i);
				child.y = maxHeight;
				maxHeight += child.height+gap;
			}
			if (this.name == 'root') {
				
			}
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			child.y = maxHeight;
			maxHeight += child.height+gap;
			super.addChild(child);
			//
			this.dispatchEvent(new BoxEvent(BoxEvent.RESIZE));
			//
			return child;
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);
			reposition();
			//
			return child;
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseChildren = this.mouseEnabled = value;
			this.alpha = value ? 1 : 0.5;
		}
	}
}