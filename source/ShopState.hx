package;

import ShopConfig.ShopItemConfig;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class ShopState extends FlxState {
    var totalCashText:FlxText;
    var displayedCash:Float = 0;
    var itemBoxes:Array<ShopItemBox> = [];
    var scrollOffset:Float = 0;
    var maxScroll:Float = 0;
    var isDragging:Bool = false;
    var dragStartY:Float = 0;
    var dragStartOffset:Float = 0;
    
    static final BOX_HEIGHT:Int = 170;
    static final BOX_SPACING:Int = 20;
    static final BOX_WIDTH:Int = 420;
    
    override function create() {
        super.create();
        openSubState(new TransitionSubState(true));
        if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        {  
            FlxG.sound.playMusic(AssetPaths.shop__ogg);
        }

        bgColor = FlxColor.fromString("0xFF825A3B");
        displayedCash = FlxG.save.data.cash;
        
        ShopConfig.init();
        createHeader();
        createShopItems();
        createFooter();
    }
    
    function createHeader():Void {
        totalCashText = new FlxText(40, 30, FlxG.width - 80, "$" + FlxG.save.data.cash);
        totalCashText.setFormat(null, 32, FlxColor.YELLOW);
        totalCashText.alignment = LEFT;
        totalCashText.bold = true;
        totalCashText.borderStyle = OUTLINE;
        totalCashText.borderColor = FlxColor.BLACK;
        totalCashText.borderSize = 2;
        add(totalCashText);
        
        var titleText = new FlxText(40, 65, FlxG.width - 100, "Da Shop");
        titleText.setFormat(null, 16, FlxColor.fromRGB(180, 180, 180));
        titleText.alignment = LEFT;
        add(titleText);
    }
    
    function createShopItems():Void {
        var startY:Float = 110;
        var x:Float = (FlxG.width - BOX_WIDTH) / 2;
        
        for (i in 0...ShopConfig.ITEMS.length) {
            var config = ShopConfig.ITEMS[i];
            var y = startY + (i * (BOX_HEIGHT + BOX_SPACING));
            
            var box = new ShopItemBox(x, y, config, function() {
                processBuy(config.id);
            });
            add(box);
            itemBoxes.push(box);
        }
        
        var totalHeight = ShopConfig.ITEMS.length * (BOX_HEIGHT + BOX_SPACING) - BOX_SPACING;
        maxScroll = Math.max(0, totalHeight - (FlxG.height - 200));
    }
    
    function createFooter():Void {
        var backButton = new FlxButton(40, FlxG.height - 55, "Back", function() {
            openSubState(new TransitionSubState(false, function () {
                FlxG.save.flush();
                FlxG.switchState(() -> new MenuState());
            }));
        });
        backButton.setGraphicSize(120, 40);
        backButton.updateHitbox();
        backButton.label.setFormat(null, 14, FlxColor.BLACK, CENTER);
        backButton.label.bold = true;
        backButton.label.offset.set(-20, -7);
        add(backButton);
        
        var helpText = new FlxText(FlxG.width - 160, FlxG.height - 55, 120, "Press ESC to return Menu");
        helpText.setFormat(null, 12, FlxColor.fromRGB(150, 150, 150));
        helpText.alignment = RIGHT;
        add(helpText);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        displayedCash = GameUtil.lerpInt(displayedCash, FlxG.save.data.cash, 1, elapsed);
        totalCashText.text = "$" + Std.int(displayedCash);
        
        handleScroll();
        updateItemPositions();
        
        if (FlxG.keys.justPressed.ESCAPE) {
            openSubState(new TransitionSubState(false, function () {
                FlxG.save.flush();
                FlxG.switchState(() -> new MenuState());
            }, true));
        }
    }
    
    function handleScroll():Void {
        var scrollSpeed:Float = 30;
        
        if (FlxG.mouse.wheel != 0) {
            scrollOffset -= FlxG.mouse.wheel * scrollSpeed;
            scrollOffset = Math.max(0, Math.min(maxScroll, scrollOffset));
        }
        
        if (FlxG.mouse.justPressed) {
            isDragging = true;
            dragStartY = FlxG.mouse.viewX;
            dragStartOffset = scrollOffset;
        }
        
        if (isDragging && FlxG.mouse.justReleased) {
            isDragging = false;
        }
        
        if (isDragging) {
            var deltaY = (dragStartY - FlxG.mouse.viewY) * 0.8;
            scrollOffset = Math.max(0, Math.min(maxScroll, dragStartOffset + deltaY));
        }
    }
    
    function updateItemPositions():Void {
        var startY:Float = 110 - scrollOffset;
        var x:Float = (FlxG.width - BOX_WIDTH) / 2;
        
        for (i in 0...itemBoxes.length) {
            var box = itemBoxes[i];
            var y = startY + (i * (BOX_HEIGHT + BOX_SPACING));
            box.x = x;
            box.y = y;
            
            box.box.x = x;
            box.box.y = y;
            box.icon.x = x + 15;
            box.icon.y = y + 15;
            box.titleText.x = x + 75;
            box.titleText.y = y + 10;
            box.descText.x = x + 75;
            box.descText.y = y + 38;
            box.statusText.x = x + 75;
            box.statusText.y = y + 62;
            box.costText.x = x + 230;
            box.costText.y = y + 62;
            box.actionButton.x = x + 310;
            box.actionButton.y = y + 95;
            
            box.visible = (y > -BOX_HEIGHT && y < FlxG.height);
        }
    }
    
    function processBuy(itemId:String):Void {
        var config = ShopConfig.getConfigForId(itemId);
        if (config == null) return;
        
        var currentValue = getCurrentValue(config);
        var cost = getCurrentCost(config);
        
        if (currentValue >= config.maxLevel) {
            return;
        }
        
        if (FlxG.save.data.cash < cost) {
            showNotEnoughCash();
            return;
        }
        
        FlxG.save.data.cash -= cost;
        FlxG.sound.play(AssetPaths.select__ogg);
        
        switch(itemId) {
            case "playerHealth":
                FlxG.save.data.playerHealth += config.incrementAmount;
                if (FlxG.save.data.playerHealth > config.maxLevel) {
                    FlxG.save.data.playerHealth = config.maxLevel;
                }
                FlxG.save.data.healthCost = Math.round(config.baseCost * Math.pow(config.costMultiplier, 
                    Math.floor(FlxG.save.data.playerHealth / config.incrementAmount)));
                
            case "ballHealth":
                FlxG.save.data.ballGainHealth += config.incrementAmount;
                if (FlxG.save.data.ballGainHealth > config.maxLevel) {
                    FlxG.save.data.ballGainHealth = config.maxLevel;
                }
                FlxG.save.data.ballHealthCost = Math.round(config.baseCost * Math.pow(config.costMultiplier,
                    Math.floor(FlxG.save.data.ballGainHealth / config.incrementAmount)));
                
            case "barrier":
                FlxG.save.data.barrier += config.incrementAmount;
                if (FlxG.save.data.barrier > config.maxLevel) {
                    FlxG.save.data.barrier = config.maxLevel;
                }
        }
        
        FlxG.save.flush();
        updateAllUI();
    }
    
    function getCurrentValue(config:ShopItemConfig):Int {
        return switch(config.saveKey) {
            case "playerHealth": FlxG.save.data.playerHealth;
            case "ballGainHealth": FlxG.save.data.ballGainHealth;
            case "barrier": FlxG.save.data.barrier;
            default: 0;
        }
    }
    
    function getCurrentCost(config:ShopItemConfig):Int {
        return switch(config.costKey) {
            case "healthCost": FlxG.save.data.healthCost;
            case "ballHealthCost": FlxG.save.data.ballHealthCost;
            case "barrierCost": FlxG.save.data.barrierCost;
            default: config.baseCost;
        }
    }
    
    function showNotEnoughCash():Void {
        var msg = new FlxText(0, 0, 0, "Not enough cash!", 20);
        msg.color = FlxColor.RED;
        msg.screenCenter();
        msg.y = FlxG.height - 80;
        msg.bold = true;
        msg.borderStyle = OUTLINE;
        msg.borderColor = FlxColor.BLACK;
        msg.borderSize = 2;
        add(msg);
        FlxTween.tween(msg, {alpha: 0, y: msg.y - 50}, 1.5, {onComplete: function(t) {
            remove(msg);
            msg.destroy();
        }});
    }
    
    function updateAllUI():Void {
        for (box in itemBoxes) {
            box.updateUI();
        }
    }
}