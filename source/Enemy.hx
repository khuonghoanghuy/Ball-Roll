package;

import EnemyConfig.EnemySpawnConfig;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

enum EnemyType 
{
    // Actual Enemy
    Normal;
    Notward;
    Wave;
    Backward;

    // Buff - Attack
    Orb;
    Ball_Heal;
}

class Enemy extends FlxSprite
{
    public var type:EnemyType;
    public var canSpawnMultiple:Bool = true;
    public var spawnCount:Int = 1;
    public var spawnChance:Float = 50.0;
    public var unlockTime:Int = 0;
    public var specialBehavior:String = "normal";
    public var customSpeed:Null<Float> = null;
    public var spawnPosition:String = "random_line";
    public var isOrbRedirect:Bool = false;
    
    var jumpTimer:Float = 0;
    var startY:Float;
    var originalSpeed:Float = 0;

    public function new(x:Float = 0, y:Float = 0, type:EnemyType = Normal) 
    {
        super(x, y);
        this.type = type;
        this.startY = y;
        this.originalSpeed = 0;
        
        loadConfig();

        switch (this.type)
        {
            case Normal:
                loadGraphic(AssetPaths.green__png);
            case Wave:
                loadGraphic(AssetPaths.wave__png, true, 48, 48);
                animation.add("wave", [0, 1, 2, 3, 4, 3, 2, 1, 0, 5, 6, 7, 8, 9, 8, 7, 6, 5], 24, true);
                animation.play("wave");
            case Backward:
                loadGraphic(AssetPaths.backward_shity__png);  
            case Notward:
                loadGraphic(AssetPaths.red__png);
            case Orb:
                loadGraphic(AssetPaths.orb__png, true, 32, 32);
                animation.add("idle", [0, 1, 2, 3, 2, 1], 12, true);
                animation.add("counter", [4, 5, 6, 7], 12, false);
                animation.play("idle");
            case Ball_Heal:
                loadGraphic(AssetPaths.ball_heal__png);
        }
    }

    function loadConfig()
    {
        for (config in EnemyConfig.SPAWN_CONFIGS)
        {
            if (config.type == this.type)
            {
                this.spawnChance = config.spawnChance;
                this.canSpawnMultiple = config.canSpawnMultiple;
                this.unlockTime = config.unlockTime;
                this.specialBehavior = config.specialBehavior;
                this.customSpeed = config.customSpeed;
                this.spawnPosition = config.spawnPosition;
                
                if (config.minCount == config.maxCount)
                {
                    this.spawnCount = config.minCount;
                }
                else
                {
                    this.spawnCount = FlxG.random.int(config.minCount, config.maxCount);
                }
                break;
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        switch (type)
        {
            case Normal:
            case Wave:
                jumpTimer += elapsed * 3;
                this.y = startY + Math.sin(jumpTimer) * 15;
            case Backward:
            case Notward:
            case Orb:
            case Ball_Heal:
        }
    }

    public static function createEnemies(type:EnemyType, x:Float, y:Float, speed:Float):Array<Enemy>
    {
        var enemies:Array<Enemy> = [];
        var config = getConfigForType(type);
        
        if (config == null) return enemies;
        
        var count = config.minCount;
        if (config.canSpawnMultiple)
        {
            count = FlxG.random.int(config.minCount, config.maxCount);
        }
        
        for (i in 0...count)
        {
            var enemy = new Enemy(x + (i * 65), y, type);
            enemy.velocity.x = speed;
            if (type == Backward)
            {
                enemy.velocity.x = Math.abs(speed) * 0.4;
            }
            enemies.push(enemy);
        }
        
        return enemies;
    }

    public static function getConfigForType(type:EnemyType):Null<EnemySpawnConfig>
    {
        for (config in EnemyConfig.SPAWN_CONFIGS)
        {
            if (config.type == type)
            {
                return config;
            }
        }
        return null;
    }

    public static function getAvailableEnemies(timeSecond:Int):Array<EnemyType>
    {
        var available:Array<EnemyType> = [];
        for (config in EnemyConfig.SPAWN_CONFIGS)
        {
            if (timeSecond >= config.unlockTime && config.spawnChance > 0)
            {
                available.push(config.type);
            }
        }
        return available;
    }

    public static function getRandomEnemyType(timeSecond:Int):Null<EnemyType>
    {
        var available = getAvailableEnemies(timeSecond);
        if (available.length == 0) return Normal;
        
        // Weighted selection based on spawnChance
        var totalWeight:Float = 0;
        var weights:Array<Float> = [];
        var types:Array<EnemyType> = [];
        
        for (type in available)
        {
            var config = getConfigForType(type);
            if (config != null)
            {
                totalWeight += config.spawnChance;
                weights.push(totalWeight);
                types.push(type);
            }
        }
        
        if (totalWeight == 0) return Normal;
        
        var random = FlxG.random.float(0, totalWeight);
        for (i in 0...weights.length)
        {
            if (random <= weights[i])
            {
                return types[i];
            }
        }
        
        return Normal;
    }
}