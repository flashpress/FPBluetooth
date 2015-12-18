package ru.flashpress.bluetooth.ui.core
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;


	public class CheckBox extends Sprite
	{
		private var save2ShareId:String;
		//
		private var selectedDisable:Boolean;
		private var icon:Shape;
		private var labelField:Label;
		public function CheckBox(label:String=null, save2ShareId:String=null, selectedDisable:Boolean=false, defValue:Boolean=false)
		{
			this.save2ShareId = save2ShareId;
			this.selectedDisable = selectedDisable;
			//
			var size:int = Capabilities.os && Capabilities.os.indexOf('iPhone') != -1 ? 50 : 30;
			var border:int = size*0.1;
			var radius:int = size*0.3;
			//
			var back:Shape = new Shape();
			back.graphics.beginFill(0xff0000, 1);
			back.graphics.drawRect(0, 0, size, size);
			back.graphics.beginFill(0xffffff, 1);
			back.graphics.drawRect(border, border, size-border*2, size-border*2);
			back.graphics.endFill();
			this.addChild(back);
			//
			icon = new Shape();
			icon.visible = false;
			icon.graphics.beginFill(0xff0000, 1);
			icon.graphics.drawCircle(size/2, size/2, radius);
			icon.graphics.endFill();
			this.addChild(icon);
			//
			labelField = new Label(label, true, null, 1);
			labelField.selectable = false;
			this.addChild(labelField);
			labelField.x = back.width;
			//
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, int.MAX_VALUE-1);
			//
			if (save2ShareId) {
				this.selected = Shared.open(save2ShareId, defValue);
			}
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			this.selected = !this._selected;
		}
		
		public function set label(value:String):void
		{
			labelField.text = value;
		}
		
		private var _selected:Boolean;
		public function get selected():Boolean {return this._selected;}
		public function set selected(value:Boolean):void
		{
			this._selected = value;
			icon.visible = value;
			if (selectedDisable) {
				this.enabled = !value;
			}
			if (save2ShareId) {
				Shared.save(save2ShareId, this._selected);
			}
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseChildren = this.mouseEnabled = value;
			this.alpha = value ? 1 : 0.5;
		}
	}
}
