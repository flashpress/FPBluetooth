/**
 * Created by sam on 18.12.15.
 */
package ru.flashpress.bluetooth.ui.core {
    import flash.net.SharedObject;

    public class Shared
    {
        private static var inited:Boolean;
        private static var share:SharedObject;
        private static function init():void
        {
            inited = true;
            share = SharedObject.getLocal('data');
        }

        public static function open(name:String, def:*=null):*
        {
            if (!inited) init();
            return share.data[name] != null ? share.data[name] : def;
        }

        public static function save(name:String, value:*=null):*
        {
            if (!inited) init();
            share.data[name] = value;
            share.flush();
        }
    }
}
