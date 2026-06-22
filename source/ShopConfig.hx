package;

import flixel.FlxG;

typedef ShopItemConfig = {
    var id:String;
    var name:String;
    var description:String;
    var icon:String;
    var type:String; // "upgrade" or "buy"
    var baseCost:Int;
    var costMultiplier:Float;
    var maxLevel:Int;
    var incrementAmount:Int;
    var saveKey:String;
    var costKey:String;
}

class ShopConfig {
    public static var ITEMS:Array<ShopItemConfig> = [];
    
    public static function init():Void {
        ITEMS = ShopLoader.loadConfigFromJSON();
        if (ITEMS.length == 0) {
            ITEMS = getDefaultConfig();
        }
        trace("Shop config loaded! " + ITEMS.length + " items configured.");
    }
    
    static function getDefaultConfig():Array<ShopItemConfig> {
        return [
            {
                id: "playerHealth",
                name: "Player Health",
                description: "Increase max health",
                icon: "heart",
                type: "upgrade",
                baseCost: 250,
                costMultiplier: 1.5,
                maxLevel: 10000,
                incrementAmount: 25,
                saveKey: "playerHealth",
                costKey: "healthCost"
            },
            {
                id: "ballHealth",
                name: "Ball Health",
                description: "Health gained from balls",
                icon: "ball_heal",
                type: "upgrade",
                baseCost: 100,
                costMultiplier: 1.4,
                maxLevel: 100,
                incrementAmount: 5,
                saveKey: "ballGainHealth",
                costKey: "ballHealthCost"
            },
            {
                id: "barrier",
                name: "Barrier",
                description: "Protects from damage",
                icon: "barrier",
                type: "buy",
                baseCost: 500,
                costMultiplier: 1.0,
                maxLevel: 99,
                incrementAmount: 1,
                saveKey: "barrier",
                costKey: "barrierCost"
            }
        ];
    }
    
    public static function getConfigForId(id:String):Null<ShopItemConfig> {
        for (config in ITEMS) {
            if (config.id == id) return config;
        }
        return null;
    }
}