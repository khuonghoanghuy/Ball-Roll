package game.data;

import flixel.FlxG;

@:structInit class SaveSettings {
    // Gameplay
    public var highScore:Int = 0;

    // Player stats
    public var playerHealth:Int = 0;
    public var ballHeal:Int = 5;
    public var barrier:Int = 1;

    // Shop economy
    public var coin:Int = 0;

    // Setting
    public var shader:Bool = true;
    public var muted:Bool = false;
    public var volume:Float = 1;
}

class SaveData {
	public static var settings:SaveSettings = {};

	public static function init() {
		for (key in Reflect.fields(settings))
			if (Reflect.field(FlxG.save.data, key) != null)
				Reflect.setField(settings, key, Reflect.field(FlxG.save.data, key));
	}

	public static function saveSettings() {
		for (key in Reflect.fields(settings))
			Reflect.setField(FlxG.save.data, key, Reflect.field(settings, key));

		FlxG.save.flush();

		trace('settings saved!');
	}

	public static function eraseData() {
		FlxG.save.erase();
		init();
	}
}