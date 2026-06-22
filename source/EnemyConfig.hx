package;

import Enemy.EnemyType;

typedef EnemySpawnConfig = {
    var type:EnemyType;
    var spawnChance:Float;
    var minCount:Int;
    var maxCount:Int;
    var canSpawnMultiple:Bool;
    var unlockTime:Int;
    var specialBehavior:String;
    var customSpeed:Null<Float>;
    var spawnPosition:String;
}

class EnemyConfig {
    public static var SPAWN_CONFIGS:Array<EnemySpawnConfig> = [];
    
    public static function init():Void
    {
        SPAWN_CONFIGS = EnemyLoader.loadConfigFromJSON();
        
        if (SPAWN_CONFIGS.length == 0)
        {
            SPAWN_CONFIGS = getDefaultConfig();
        }
        
        trace("Enemy config loaded! " + SPAWN_CONFIGS.length + " enemy types configured.");
    }
    
    static function getDefaultConfig():Array<EnemySpawnConfig>
    {
        return [
            {
                type: Normal,
                spawnChance: 50,
                minCount: 1,
                maxCount: 3,
                canSpawnMultiple: true,
                unlockTime: 0,
                specialBehavior: "normal",
                customSpeed: null,
                spawnPosition: "random_line"
            },
            {
                type: Notward,
                spawnChance: 30,
                minCount: 1,
                maxCount: 2,
                canSpawnMultiple: true,
                unlockTime: 0,
                specialBehavior: "normal",
                customSpeed: null,
                spawnPosition: "random_line"
            },
            {
                type: Wave,
                spawnChance: 15,
                minCount: 1,
                maxCount: 1,
                canSpawnMultiple: false,
                unlockTime: 0,
                specialBehavior: "wave",
                customSpeed: null,
                spawnPosition: "random_line"
            },
            {
                type: Backward,
                spawnChance: 5,
                minCount: 1,
                maxCount: 1,
                canSpawnMultiple: false,
                unlockTime: 20,
                specialBehavior: "backward",
                customSpeed: null,
                spawnPosition: "left_edge"
            },
            {
                type: Orb,
                spawnChance: 0,
                minCount: 1,
                maxCount: 1,
                canSpawnMultiple: false,
                unlockTime: 0,
                specialBehavior: "orb",
                customSpeed: null,
                spawnPosition: "random_line"
            },
            {
                type: Ball_Heal,
                spawnChance: 25,
                minCount: 1,
                maxCount: 1,
                canSpawnMultiple: false,
                unlockTime: 2,
                specialBehavior: "ball_heal",
                customSpeed: null,
                spawnPosition: "random_line"
            }
        ];
    }
}