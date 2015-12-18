package ru.flashpress.bluetooth.find.peripheral.services.characteristics
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class GattSpecifications
	{
		[Embed(source="org.bluetooth.characteristic.time_zone.xml", mimeType="application/octet-stream")]
		private static const TimeZoneClass:Class;
		
		
		private static var TimeZoneXml:XML;
		public function GattSpecifications()
		{
		}
		
		private static function createXML(classLink:Class):XML
		{
			var string:String = new classLink();
			return new XML(string);
		}
		
		public static function uuidToString(uuid:String, bytes:ByteArray):String
		{
			bytes.endian = Endian.LITTLE_ENDIAN;
			switch (uuid) {
				// Battery Level
				case '2A19':
					return 'level='+bytes.readByte()+'%';
				// Current Time
				case '2A2B':
					return currentTimeToString(bytes);
					break;
				// Local Time Information
				case '2A0F':
					return localTimeInformationToString(bytes);
				//
				//
				//
				// Notification Source
				case '9FBF120D-6301-42D9-8C58-25E699A21DBD':
					return notificationSourceToString(bytes);
				// Control Point
				case '69D1D8F3-45E1-49A8-9821-9BBDFDAAD9D9':
					// is not notify
                    return controlPointToString(bytes);
				// Data Source
				case '22EAC6E9-24D6-4BB5-BE44-B36ACE7C7BFB':
					return dataSourceToString(bytes);
			}
			return null;
		}
		
		private static function currentTimeToString(b:ByteArray):String
		{
			var year:int = b.readUnsignedShort();
			var month:int = b.readUnsignedByte();
			var day:int = b.readUnsignedByte();
			var hours:int = b.readUnsignedByte();
			var minutes:int = b.readUnsignedByte();
			var seconds:int = b.readUnsignedByte();
			//
			var dayOfWeek:int = b.readUnsignedByte();
			var fraction:int = b.readUnsignedByte();
			var adjustReason:int = b.readUnsignedByte();
			//
			var milliseconds:int = Math.floor(fraction/256*1000);
			var timeString:String = ''+year+'.'+month+'.'+day+' '+hours+':'+minutes+':'+seconds+'.'+milliseconds+'\n';
			
			timeString += 'dayOfWeek:'+dayOfWeek+'\n';
			timeString += 'fraction:'+fraction+'\n';
			timeString += 'adjustReason:'+adjustReason+'\n';
			//
			return timeString;
		}
		
		private static function localTimeInformationToString(b:ByteArray):String
		{
			if (!TimeZoneXml) {
				TimeZoneXml = createXML(TimeZoneClass);
			}
			//
			var timeZone:uint = b.readByte();
			trace('timeZone:', timeZone);
			var timeZoneList:XMLList = TimeZoneXml.Value.Field.Enumerations.Enumeration.(@key == timeZone);
			var timeZoneStr:String;
			if (timeZoneList.length() > 0) {
				timeZoneStr = timeZoneList[0].attribute('value');
			}
			//
			var daylightSavingTime:int = b.readUnsignedByte();
			return 'timeZone='+timeZoneStr+';\ndaylightSavingTime='+daylightSavingTime;
		}
		
		private static function notificationSourceToString(b:ByteArray):String
		{
			var eventId:int = b.readByte();
			var eventFlags:int = b.readByte();
			var categoryId:int = b.readByte();
			var categoryCount:int = b.readByte();
			var notificationUID:int = b.readUnsignedInt();
			var sourceString:String = 'Notification Source->\n';
			sourceString += 'eventId='+eventId+'\n';
			sourceString += 'eventFlags='+eventFlags+'\n';
			sourceString += 'categoryId='+categoryId+'\n';
            sourceString += 'categoryCount='+categoryCount+'\n';
			sourceString += 'notificationUID='+notificationUID+'\n';
            //
            trace('---------------');
            trace(sourceString);
            trace('---------------');
            //
			return sourceString;
		}

        private static function controlPointToString(b:ByteArray):String
        {
            trace('------- controlPointToString -------');
            var commandId:int = b.readByte();
            trace('commandId:', commandId);
            return null;
        }
		
		private static function dataSourceToString(b:ByteArray):String
		{
			trace('------- dataSourceToString -------');
			var s:String = '';
			for (var i:int=0; i<b.length; i++) s += b[i];
			trace(s);
			//
			trace(b.bytesAvailable);
			var commandID:int = b.readByte();
			var notificationUID:int = b.readUnsignedInt();
			trace(commandID, notificationUID);
			trace(b.bytesAvailable);
			//
			return null;
		}
	}
}