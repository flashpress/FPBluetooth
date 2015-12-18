package ru.flashpress.bluetooth.ui.box
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class HBox extends Sprite
	{
		public static function create(...childs):HBox
		{
			var box:HBox = new HBox(childs[0] is Number?childs[0]:10);
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
		public function HBox(gap:Number=10)
		{
			this.gap = gap;
			this.maxWidth = 0;
		}
		
		private var maxWidth:Number;
		public function reposition():void
		{
			var i:int;
			var child:DisplayObject;
			maxWidth = 0;
			for (i=0; i<this.numChildren; i++) {
				child = this.getChildAt(i);
				child.x = maxWidth;
				maxWidth += child.width+gap;
			}
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			child.x = maxWidth;
			maxWidth += child.width+gap;
			super.addChild(child);
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
	}
}