package;

import SettingConfig.SettingItemConfig;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class SettingItem extends FlxGroup {
    var config:SettingItemConfig;
    var bg:FlxSprite;
    var nameText:FlxText;
    var descText:FlxText;
    var valueText:FlxText;
    var sliderBar:FlxBar;
    var leftButton:FlxButton;
    var rightButton:FlxButton;
    var actionButton:FlxButton;
    var restartIcon:FlxText;
    
    public function new(x:Float, y:Float, width:Int, height:Int, config:SettingItemConfig) {
        super();
        this.config = config;
        
        createBackground(x, y, width, height);
        createTexts(x, y, width, height);
        createControls(x, y, width, height);
        updateValue();
    }
    
    function createBackground(x:Float, y:Float, width:Int, height:Int):Void {
        bg = new FlxSprite(x, y).makeGraphic(width, height, FlxColor.fromRGB(50, 50, 50));
        bg.alpha = 0.7;
        add(bg);
    }
    
    function createTexts(x:Float, y:Float, width:Int, height:Int):Void {
        nameText = new FlxText(x + 15, y + 10, width - 120, config.name);
        nameText.setFormat(null, 16, FlxColor.WHITE);
        nameText.bold = true;
        add(nameText);
        
        descText = new FlxText(x + 15, y + 34, width - 120, config.description);
        descText.setFormat(null, 11, FlxColor.fromRGB(180, 180, 180));
        add(descText);
    }
    
    function createControls(x:Float, y:Float, width:Int, height:Int):Void {
        switch(config.type) {
            case "slider":
                createSliderControls(x, y, width, height);
            case "toggle":
                createToggleControl(x, y, width, height);
        }
    }
    
    function createSliderControls(x:Float, y:Float, width:Int, height:Int):Void {
        var btnSize:Int = 28;
        var btnY:Float = y + (height - btnSize) / 2;
        var sliderX:Float = x + width - 150;
        var sliderWidth:Int = 100;
        var sliderY:Float = y + (height - 10) / 2;
        
        leftButton = new FlxButton(sliderX - 30, btnY, "-", function() {
            adjustValue(-config.step);
        });
        leftButton.setGraphicSize(btnSize, btnSize);
        leftButton.updateHitbox();
        leftButton.label.setFormat(null, 16, FlxColor.BLACK, CENTER);
        leftButton.label.bold = true;
        leftButton.label.offset.set(25, 0);
        add(leftButton);
        
        valueText = new FlxText(sliderX + 50, y + 10, 50, "100%");
        valueText.setFormat(null, 15, FlxColor.GREEN, CENTER);
        valueText.bold = true;
        add(valueText);
        
        rightButton = new FlxButton(sliderX + sliderWidth + 10, btnY, "+", function() {
            adjustValue(config.step);
        });
        rightButton.setGraphicSize(btnSize, btnSize);
        rightButton.updateHitbox();
        rightButton.label.setFormat(null, 16, FlxColor.BLACK, CENTER);
        rightButton.label.bold = true;
        rightButton.label.offset.set(25, 0);
        add(rightButton);
        
        sliderBar = new FlxBar(sliderX + 5, sliderY, LEFT_TO_RIGHT, sliderWidth, 10, this, "sliderValue", 0, 1);
        sliderBar.createFilledBar(FlxColor.GRAY, FlxColor.GREEN, true, FlxColor.BLACK, 0);
        add(sliderBar);
    }
    
    var sliderValue:Float = 1.0;
    
    function createToggleControl(x:Float, y:Float, width:Int, height:Int):Void {
        var btnWidth:Int = 70;
        var btnY:Float = y + (height - 32) / 2;
        var btnX:Float = x + width - btnWidth - 15;
        
        actionButton = new FlxButton(btnX, btnY, "OFF", function() {
            toggleValue();
        });
        actionButton.setGraphicSize(btnWidth, 32);
        actionButton.updateHitbox();
        actionButton.label.setFormat(null, 14, FlxColor.WHITE, CENTER);
        actionButton.label.bold = true;
        actionButton.label.offset.set(3, -3);
        add(actionButton);
        updateToggleColor();
    }
    
    function adjustValue(delta:Float):Void {
        if (config.saveKey == null) return;
        
        var current = Reflect.getProperty(FlxG.save.data, config.saveKey);
        if (current == null) current = config.defaultValue;
        
        var newValue:Float = current + delta;
        if (config.minValue != null) newValue = Math.max(config.minValue, newValue);
        if (config.maxValue != null) newValue = Math.min(config.maxValue, newValue);
        
        Reflect.setProperty(FlxG.save.data, config.saveKey, newValue);
        sliderValue = newValue;
        
        if (config.saveKey == "volume") {
            FlxG.sound.volume = newValue;
        }
        
        FlxG.save.flush();
        FlxG.sound.play(AssetPaths.select__ogg);
        updateValue();
        
        // Check if this setting requires restart
        if (config.requireRestart) {
            SaveData.noticeRestart = true;
        }
    }
    
    function toggleValue():Void {
        if (config.saveKey == null) return;
        
        var current = Reflect.getProperty(FlxG.save.data, config.saveKey);
        if (current == null) current = config.defaultValue;
        
        var newValue = !current;
        Reflect.setProperty(FlxG.save.data, config.saveKey, newValue);
        
        if (config.saveKey == "muted") {
            FlxG.sound.muted = newValue;
        }
        
        FlxG.save.flush();
        FlxG.sound.play(AssetPaths.select__ogg);
        updateValue();
        updateToggleColor();
        
        // Check if this setting requires restart
        if (config.requireRestart) {
            SaveData.noticeRestart = true;
        }
    }
    
    function updateToggleColor():Void {
        if (actionButton == null) return;
        var current = Reflect.getProperty(FlxG.save.data, config.saveKey);
        if (current == null) current = config.defaultValue;
        actionButton.color = current ? FlxColor.fromRGB(60, 200, 60) : FlxColor.fromRGB(200, 60, 60);
        actionButton.label.text = current ? "ON" : "OFF";
    }
    
    function updateValue():Void {
        if (config.type == "slider" && config.saveKey != null) {
            var current = Reflect.getProperty(FlxG.save.data, config.saveKey);
            if (current == null) current = config.defaultValue;
            sliderValue = current;
            var percent = Math.round(current * 100);
            valueText.text = percent + "%";
            
            if (percent > 70) valueText.color = FlxColor.GREEN;
            else if (percent > 30) valueText.color = FlxColor.YELLOW;
            else valueText.color = FlxColor.RED;
            
            if (sliderBar != null) {
                var color = percent > 70 ? FlxColor.GREEN : (percent > 30 ? FlxColor.YELLOW : FlxColor.RED);
                sliderBar.createFilledBar(FlxColor.GRAY, color, true, FlxColor.BLACK, 0);
            }
        }
        
        if (config.type == "toggle" && actionButton != null) {
            var current = Reflect.getProperty(FlxG.save.data, config.saveKey);
            if (current == null) current = config.defaultValue;
            actionButton.label.text = current ? "ON" : "OFF";
            actionButton.color = current ? FlxColor.fromRGB(60, 200, 60) : FlxColor.fromRGB(200, 60, 60);
        }
    }
}