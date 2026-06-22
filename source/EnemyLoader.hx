package;

import Enemy.EnemyType;
import EnemyConfig.EnemySpawnConfig;
import haxe.Json;
import openfl.Assets;

class EnemyLoader
{
    public static function loadConfigFromJSON():Array<EnemySpawnConfig>
    {
        try
        {
            var jsonString = Assets.getText(AssetPaths.enemy__json);
            if (jsonString != null)
            {
                var jsonData = Json.parse(jsonString);
                var configs:Array<EnemySpawnConfig> = [];
                
                for (enemyData in (jsonData.enemies:Array<Dynamic>))
                {
                    configs.push({
                        type: Type.createEnum(EnemyType, enemyData.type),
                        spawnChance: enemyData.spawnChance,
                        minCount: enemyData.minCount,
                        maxCount: enemyData.maxCount,
                        canSpawnMultiple: enemyData.canSpawnMultiple,
                        unlockTime: enemyData.unlockTime,
                        specialBehavior: enemyData.specialBehavior,
                        customSpeed: enemyData.customSpeed,
                        spawnPosition: enemyData.spawnPosition
                    });
                }
                
                return configs;
            }
        }
        catch (e:Dynamic)
        {
            trace("Error loading enemy config: " + e);
        }
        
        // Fallback to hardcoded config
        return EnemyConfig.SPAWN_CONFIGS;
    }
}