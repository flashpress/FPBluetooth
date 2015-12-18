/**
 * Created by sam on 10.04.15.
 */
package ru.flashpress.bt.manager.stream
{
    import flash.utils.ByteArray;

    public class StreamBytes extends ByteArray
    {
        public function StreamBytes()
        {

        }

        public function writeString(s:String):void
        {
            if (s == null) {
                this.writeByte(0xff);
            } else if (s == '') {
                this.writeByte(0);
            } else {
                if (s.length > 0xff-1) {
                    trace('!!! Слишком длинный текст. Текст будет обрезан до первых 255 символов. Для длинных текстов используйте метод writeLongString() !!! ');
                    s = s.slice(0, 0xff-1);
                }
                this.writeByte(s.length);
                this.writeUTFBytes(s);
            }
        }
        public function writeLongString(s:String):void
        {
            if (s == null) {
                this.writeInt(-1);
            } else if (s == '') {
                this.writeInt(0);
            } else {
                if (s.length > 2147483647) {
                    trace('!!! Слишком длинный текст. Текст будет обрезан до первых 2147483647 символов. !!!');
                    s = s.slice(0, 2147483647);
                }
                this.writeInt(s.length);
                this.writeUTFBytes(s);
            }
        }


        public static function readString(bytes:ByteArray):String
        {
            var len:int = bytes.readUnsignedByte();
            switch (len) {
                case 0xff: return null;
                case 0: return '';
            }

            return bytes.readUTFBytes(len);
        }

        public static function readLongString(bytes:ByteArray):String
        {
            var len:int = bytes.readInt();
            switch (len) {
                case -1: return null;
                case 0: return '';
            }

            return bytes.readUTFBytes(len);
        }
    }
}
