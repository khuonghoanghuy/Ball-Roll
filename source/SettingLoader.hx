package;

import SettingConfig.SettingItemConfig;
import haxe.Json;
import openfl.Assets;

class SettingLoader {
    public static function loadConfigFromJSON():Array<SettingItemConfig> {
        try {
            var jsonString = Assets.getText(AssetPaths.setting__json);
            if (jsonString != null) {
                var jsonData = Json.parse(jsonString);
                var configs:Array<SettingItemConfig> = [];
                
                for (itemData in (jsonData.settings:Array<Dynamic>)) {
                    configs.push({
                        id: itemData.id,
                        name: itemData.name,
                        description: itemData.description,
                        type: itemData.type,
                        defaultValue: itemData.defaultValue,
                        minValue: itemData.minValue,
                        maxValue: itemData.maxValue,
                        step: itemData.step,
                        saveKey: itemData.saveKey,
                        requireRestart: itemData.requireRestart
                    });
                }
                return configs;
            }
        } catch (e:Dynamic) {
            trace("Error loading setting config: " + e);
        }
        return [];
    }
}