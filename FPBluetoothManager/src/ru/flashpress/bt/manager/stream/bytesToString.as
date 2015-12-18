/**
 * Created by sam on 10.04.15.
 */
package ru.flashpress.bt.manager.stream {
    import flash.utils.ByteArray;

    public function bytesToString(b:ByteArray):String
    {
        if (!b) return '[null]';
        //
        var s:String = '';
        var i:int;
        for (i=0; i<b.length; i++) {
            if (s != '') s += '.';
            s += b[i];
        }
        return '['+b.length+'.'+b.position+'|'+s+']';
    }
}
