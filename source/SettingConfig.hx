package;

typedef SettingItemConfig = {
    var id:String;
    var name:String;
    var description:String;
    var type:String; // "slider", "toggle", "button"
    var defaultValue:Dynamic;
    var minValue:Null<Float>;
    var maxValue:Null<Float>;
    var step:Null<Float>;
    var saveKey:String;
    var requireRestart:Bool;
}

class SettingConfig {
    public static var ITEMS:Array<SettingItemConfig> = [];
    
    public static function init():Void {
        ITEMS = SettingLoader.loadConfigFromJSON();
        if (ITEMS.length == 0) {
            ITEMS = getDefaultConfig();
        }
        trace("Setting config loaded! " + ITEMS.length + " items configured.");
    }
    
    static function getDefaultConfig():Array<SettingItemConfig> {
        return [
            {
                id: "volume",
                name: "Master Volume",
                description: "Adjust game sound volume",
                type: "slider",
                defaultValue: 1.0,
                minValue: 0,
                maxValue: 1,
                step: 0.1,
                saveKey: "volume",
                requireRestart: false
            },
            {
                id: "muted",
                name: "Mute",
                description: "Toggle all sound on/off",
                type: "toggle",
                defaultValue: false,
                minValue: null,
                maxValue: null,
                step: null,
                saveKey: "muted",
                requireRestart: false
            },
            {
                id: "shader",
                name: "Shader",
                description: "Toggle shader effect on/off",
                type: "toggle",
                defaultValue: null,
                minValue: null,
                maxValue: null,
                step: null,
                saveKey: "shader",
                requireRestart: true
            }
        ];
    }
    
    public static function getConfigForId(id:String):Null<SettingItemConfig> {
        for (config in ITEMS) {
            if (config.id == id) return config;
        }
        return null;
    }
}