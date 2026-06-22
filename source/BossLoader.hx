package;

import Boss.BossType;
import BossConfig.BossSpawnConfig;
import haxe.Json;
import openfl.Assets;
import flixel.util.FlxColor;

class BossLoader {
    public static function loadConfigFromJSON():Array<BossSpawnConfig> {
        try {
            var jsonString = Assets.getText(AssetPaths.boss__json);
            if (jsonString != null) {
                var jsonData = Json.parse(jsonString);
                var configs:Array<BossSpawnConfig> = [];
                
                for (bossData in (jsonData.bosses:Array<Dynamic>)) {
                    configs.push({
                        type: Type.createEnum(BossType, bossData.type),
                        displayName: bossData.displayName,
                        color: bossData.color,
                        maxHealth: bossData.maxHealth,
                        phase2Threshold: bossData.phase2Threshold,
                        phase2Duration: bossData.phase2Duration,
                        movePattern: bossData.movePattern,
                        moveSpeed: bossData.moveSpeed,
                        moveAmplitude: bossData.moveAmplitude,
                        shootCooldown: bossData.shootCooldown,
                        phase2ShootMultiplier: bossData.phase2ShootMultiplier,
                        spawnChance: bossData.spawnChance,
                        unlockScore: bossData.unlockScore,
                        available: bossData.available
                    });
                }
                return configs;
            }
        } catch (e:Dynamic) {
            trace("Error loading boss config: " + e);
        }
        return [];
    }
}