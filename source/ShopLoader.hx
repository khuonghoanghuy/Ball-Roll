package;

import ShopConfig.ShopItemConfig;
import haxe.Json;
import openfl.Assets;

class ShopLoader {
    public static function loadConfigFromJSON():Array<ShopItemConfig> {
        try {
            var jsonString = Assets.getText(AssetPaths.shop__json);
            if (jsonString != null) {
                var jsonData = Json.parse(jsonString);
                var configs:Array<ShopItemConfig> = [];
                
                for (itemData in (jsonData.items:Array<Dynamic>)) {
                    configs.push({
                        id: itemData.id,
                        name: itemData.name,
                        description: itemData.description,
                        icon: itemData.icon,
                        type: itemData.type,
                        baseCost: itemData.baseCost,
                        costMultiplier: itemData.costMultiplier,
                        maxLevel: itemData.maxLevel,
                        incrementAmount: itemData.incrementAmount,
                        saveKey: itemData.saveKey,
                        costKey: itemData.costKey
                    });
                }
                return configs;
            }
        } catch (e:Dynamic) {
            trace("Error loading shop config: " + e);
        }
        return [];
    }
}