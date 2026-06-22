package;

import flixel.FlxG;
import Boss.BossType;

typedef BossSpawnConfig = {
    var type:BossType;
    var displayName:String;
    var color:String;
    var maxHealth:Float;
    var phase2Threshold:Float;
    var phase2Duration:Float;
    var movePattern:String;
    var moveSpeed:Float;
    var moveAmplitude:Float;
    var shootCooldown:Float;
    var phase2ShootMultiplier:Float;
    var spawnChance:Float;
    var unlockScore:Int;
    var available:Bool;
}

class BossConfig {
    public static var CONFIGS:Array<BossSpawnConfig> = [];
    
    public static function init():Void {
        CONFIGS = BossLoader.loadConfigFromJSON();
        if (CONFIGS.length == 0) {
            CONFIGS = getDefaultConfig();
        }
        trace("Boss config loaded! " + CONFIGS.length + " boss types configured.");
    }
    
    static function getDefaultConfig():Array<BossSpawnConfig> {
        return [
            {
                type: Classic,
                displayName: "Classic",
                color: "ORANGE",
                maxHealth: 100,
                phase2Threshold: 50,
                phase2Duration: 20,
                movePattern: "sine",
                moveSpeed: 2,
                moveAmplitude: 40,
                shootCooldown: 0.6,
                phase2ShootMultiplier: 0.6,
                spawnChance: 50,
                unlockScore: 0,
                available: true
            },
            {
                type: Surprise,
                displayName: "Surprise",
                color: "PURPLE",
                maxHealth: 100,
                phase2Threshold: 50,
                phase2Duration: 12,
                movePattern: "erratic",
                moveSpeed: 3,
                moveAmplitude: 60,
                shootCooldown: 0.45,
                phase2ShootMultiplier: 0.5,
                spawnChance: 30,
                unlockScore: 0,
                available: true
            }
        ];
    }
    
    public static function getConfigForType(type:BossType):Null<BossSpawnConfig> {
        for (config in CONFIGS) {
            if (config.type == type) return config;
        }
        return null;
    }
    
    public static function getAvailableBosses(score:Int):Array<BossType> {
        var available:Array<BossType> = [];
        for (config in CONFIGS) {
            if (config.available && score >= config.unlockScore) {
                available.push(config.type);
            }
        }
        return available;
    }
    
    public static function getRandomBossType(score:Int):BossType {
        var available = getAvailableBosses(score);
        if (available.length == 0) return Classic;
        
        var totalWeight:Float = 0;
        var weights:Array<Float> = [];
        var types:Array<BossType> = [];
        
        for (type in available) {
            var config = getConfigForType(type);
            if (config != null) {
                totalWeight += config.spawnChance;
                weights.push(totalWeight);
                types.push(type);
            }
        }
        
        if (totalWeight == 0) return Classic;
        var random = FlxG.random.float(0, totalWeight);
        
        for (i in 0...weights.length) {
            if (random <= weights[i]) return types[i];
        }
        return Classic;
    }
}