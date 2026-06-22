package;

import ShopConfig.ShopItemConfig;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class ShopItemBox extends FlxGroup {
    public var config:ShopItemConfig;
    public var box:FlxSprite;
    public var icon:FlxSprite;
    public var titleText:FlxText;
    public var descText:FlxText;
    public var statusText:FlxText;
    public var costText:FlxText;
    public var actionButton:FlxButton;

    public var x:Float = 0;
    public var y:Float = 0;
    
    var onBuyCallback:Void->Void;
    
    public function new(x:Float, y:Float, config:ShopItemConfig, onBuy:Void->Void) {
        super();
        this.config = config;
        this.onBuyCallback = onBuy;
        this.x = x;
        this.y = y;
        
        createBox(x, y);
        createIcon(x, y);
        createTexts(x, y);
        createButton(x, y);
        updateUI();
    }
    
    function createBox(x:Float, y:Float):Void {
        box = new FlxSprite(x, y).makeGraphic(400, 150, FlxColor.fromRGB(40, 40, 40));
        box.alpha = 0.85;
        add(box);
    }
    
    function createIcon(x:Float, y:Float):Void {
        var iconPath = switch(config.icon) {
            case "heart": AssetPaths.heart__png;
            case "barrier": AssetPaths.barrier__png;
            case "ball_heal": AssetPaths.ball_heal__png;
            default: AssetPaths.heart__png;
        }
        icon = new FlxSprite(x + 15, y + 15, iconPath);
        icon.setGraphicSize(48, 48);
        icon.updateHitbox();
        add(icon);
    }
    
    function createTexts(x:Float, y:Float):Void {
        titleText = new FlxText(x + 75, y + 10, 300, config.name);
        titleText.setFormat(null, 18, FlxColor.WHITE, LEFT);
        titleText.bold = true;
        add(titleText);
        
        descText = new FlxText(x + 75, y + 38, 300, config.description);
        descText.setFormat(null, 12, FlxColor.fromRGB(180, 180, 180), LEFT);
        add(descText);
        
        statusText = new FlxText(x + 75, y + 62, 200, "Current: 0 / 100");
        statusText.setFormat(null, 13, FlxColor.fromRGB(255, 220, 100), LEFT);
        add(statusText);
        
        costText = new FlxText(x + 230, y + 62, 150, "");
        costText.setFormat(null, 16, FlxColor.fromRGB(100, 255, 100), RIGHT);
        costText.bold = true;
        add(costText);
    }
    
    function createButton(x:Float, y:Float):Void {
        actionButton = new FlxButton(x + 310, y + 95, "Buy", function() {
            if (onBuyCallback != null) onBuyCallback();
        });
        actionButton.setGraphicSize(75, 38);
        actionButton.updateHitbox();
        actionButton.label.setFormat(null, 13, FlxColor.WHITE, CENTER);
        actionButton.label.bold = true;
        actionButton.label.offset.set(0, -5);
        add(actionButton);
    }
    
    public function updateUI():Void {
        var currentValue = getCurrentValue();
        var cost = getCurrentCost();
        var isMaxed = currentValue >= config.maxLevel;
        
        if (isMaxed) {
            statusText.text = "Current" + currentValue + " / " + config.maxLevel;
            statusText.color = FlxColor.GREEN;
            costText.text = "MAX";
            costText.color = FlxColor.GREEN;
            actionButton.label.text = "MAX";
            actionButton.label.color = FlxColor.GRAY;
            actionButton.active = false;
            actionButton.color = FlxColor.fromRGB(80, 80, 80);
        } else {
            statusText.text = "Current: " + currentValue + " / " + config.maxLevel;
            statusText.color = FlxColor.fromRGB(255, 220, 100);
            costText.text = "$" + cost;
            costText.color = FlxColor.fromRGB(100, 255, 100);
            actionButton.label.text = (config.type == "upgrade" ? "Upgrade" : "Buy");
            actionButton.label.color = FlxColor.BLACK;
            actionButton.active = true;
            actionButton.color = FlxColor.fromRGB(255, 255, 255);
        }
    }
    
    function getCurrentValue():Int {
        return switch(config.saveKey) {
            case "playerHealth": FlxG.save.data.playerHealth;
            case "ballGainHealth": FlxG.save.data.ballGainHealth;
            case "barrier": FlxG.save.data.barrier;
            default: 0;
        }
    }
    
    function getCurrentCost():Int {
        return switch(config.costKey) {
            case "healthCost": FlxG.save.data.healthCost;
            case "ballHealthCost": FlxG.save.data.ballHealthCost;
            case "barrierCost": FlxG.save.data.barrierCost;
            default: config.baseCost;
        }
    }
}