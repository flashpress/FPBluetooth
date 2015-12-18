package ru.flashpress.bluetooth.ui.log
{
	public function objectToString(data:Object, tab:String=''):String
	{
		var str:String = '';
		var key:String;
		for (key in data) {
			if (data[key == null]) {
				str += tab+key+'=null\n';
			} else if (data[key] is String || data[key] is Number || data[key] is Boolean) {
				str += tab+key+'='+data[key]+'\n';
			} else if (data[key] is Array) {
				str += tab+key+'=[\n'+objectToString(data[key], tab+' ')+tab+']\n';
			} else {
				str += tab+key+'={\n'+objectToString(data[key], tab+' ')+tab+'}\n';
			}
		}
		return str;
	}
}