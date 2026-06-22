package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class MenuState extends FlxState
{
    var ball:Player;
    var isActing:Bool = false;
    var isStartingGame:Bool = false;
    var isStartQueued:Bool = false;

    var cloudGroup:FlxGroup;
    var cloudImages:Array<String>;

    var startButton:FlxSprite;
    var shopButton:FlxSprite;
    var settingButton:FlxSprite;
    
    var logo:FlxSprite;
    var actionTimer:FlxTimer;
    var currentTween:FlxTween = null;

    var floorY:Float;

    override function create() 
    {
        super.create();
        openSubState(new TransitionSubState(true));

        bgColor = FlxColor.CYAN;
        floorY = FlxG.height * 0.625; 

        trace("=== MenuState Initialized ===");
        trace("Screen Size: " + FlxG.width + "x" + FlxG.height);
        trace("Floor Y: " + floorY);
        trace("Cash: " + FlxG.save.data.cash);
        trace("High Score: " + FlxG.save.data.highScore);

        cloudImages = [
            AssetPaths.cloud0001__png,
            AssetPaths.cloud0002__png,
            AssetPaths.cloud0003__png,
            AssetPaths.cloud0004__png
        ];
        cloudGroup = new FlxGroup();
        add(cloudGroup);

        var maxClouds:Int = 6;
        for (i in 0...maxClouds)
        {
            var cloud = new FlxSprite();
            var randomFrame = cloudImages[Std.int(Math.random() * cloudImages.length)];
            cloud.loadGraphic(randomFrame);
            cloud.x = Math.random() * FlxG.width;
            cloud.y = 30 + Math.random() * 200;
            cloud.velocity.x = -(30 + Math.random() * 50);
            cloud.alpha = 0.5 + Math.random() * 0.4;
            cloudGroup.add(cloud);
        }
        trace("Clouds Spawned: " + maxClouds);

        logo = new FlxSprite(0, 40, AssetPaths.logo__png);
        logo.scale.set(4, 4);
        logo.updateHitbox();
        logo.screenCenter(X);
        #if (mobile || fakeMobile)
        logo.x = 200;
        #end
        add(logo);
        trace("Logo Created at: (" + logo.x + ", " + logo.y + ")");

        ball = new Player(200, floorY - 76);
        ball.acceleration.y = 0; 
        ball.maxVelocity.y = 0;
        ball.setGraphicSize(76, 76);
        ball.updateHitbox();
        add(ball);
        trace("Ball Created at: (" + ball.x + ", " + ball.y + ")");

        var floor:FlxSprite = new FlxSprite(0, floorY);
        floor.makeGraphic(FlxG.width, Std.int(FlxG.height - floorY), FlxColor.GREEN);
        add(floor);

        #if (mobile || fakeMobile)
        var btnX:Float = FlxG.width / 2 + 100;
        var btnWidth:Int = 250;
        var btnHeight:Int = 75;
        var btnSpacing:Float = 120;
        var scaleSet:Float = 1.5;

        startButton = new FlxSprite(btnX, 200);
        startButton.loadGraphic(AssetPaths.play__png, true, btnWidth, btnHeight);
        startButton.animation.add("idle", [0]);
        startButton.animation.add("hover", [1]);
        startButton.animation.add("selected", [0, 1, 0, 1], 12, true);
        startButton.animation.play("idle");
        startButton.scale.set(scaleSet, scaleSet);
        startButton.updateHitbox();
        add(startButton);

        shopButton = new FlxSprite(btnX, startButton.y + btnSpacing);
        if (FlxG.save.data.cash == 0)
        {
            shopButton.loadGraphic(AssetPaths.shop_no_cash__png, true, btnWidth, btnHeight);
        }
        else
        {
            shopButton.loadGraphic(AssetPaths.shop_with_cash__png, true, btnWidth, btnHeight);
        }
        shopButton.animation.add("idle", [0]);
        shopButton.animation.add("hover", [1]);
        shopButton.animation.add("selected", [0, 1, 0, 1], 12, true);
        shopButton.animation.play("idle");
        shopButton.scale.set(scaleSet, scaleSet);
        shopButton.updateHitbox();
        add(shopButton);

        settingButton = new FlxSprite(btnX, shopButton.y + btnSpacing);
        settingButton.loadGraphic(AssetPaths.setting__png, true, btnWidth, btnHeight);
        settingButton.animation.add("idle", [0]);
        settingButton.animation.add("hover", [1]);
        settingButton.animation.add("selected", [0, 1, 0, 1], 12, true);
        settingButton.animation.play("idle");
        settingButton.scale.set(scaleSet, scaleSet);
        settingButton.updateHitbox();
        add(settingButton);

        trace("Mobile/Menu UI Created (Centered)");

        #else
        var btnX:Float = FlxG.width - 350;
        var btnWidth:Int = 250;
        var btnHeight:Int = 75;

        startButton = new FlxSprite(btnX, 220);
        startButton.loadGraphic(AssetPaths.play__png, true, btnWidth, btnHeight);
        startButton.animation.add("idle", [0]);
        startButton.animation.add("hover", [1]);
        startButton.animation.add("selected", [0, 1, 0, 1], 12, true);
        startButton.animation.play("idle");
        add(startButton);

        shopButton = new FlxSprite(btnX, startButton.y + 110);
        if (FlxG.save.data.cash == 0)
        {
            shopButton.loadGraphic(AssetPaths.shop_no_cash__png, true, btnWidth, btnHeight);
        }
        else
        {
            shopButton.loadGraphic(AssetPaths.shop_with_cash__png, true, btnWidth, btnHeight);
        }
        shopButton.animation.add("idle", [0]);
        shopButton.animation.add("hover", [1]);
        shopButton.animation.add("selected", [0, 1, 0, 1], 12, true);
        shopButton.animation.play("idle");
        add(shopButton);

        settingButton = new FlxSprite(btnX, shopButton.y + 110);
        settingButton.loadGraphic(AssetPaths.setting__png, true, btnWidth, btnHeight);
        settingButton.animation.add("idle", [0]);
        settingButton.animation.add("hover", [1]);
        settingButton.animation.add("selected", [0, 1, 0, 1], 12, true);
        settingButton.animation.play("idle");
        add(settingButton);

        trace("Desktop UI Created");
        #end

        actionTimer = new FlxTimer().start(1.0, chooseRandomAction);
        trace("=== MenuState Setup Complete ===");
    }

    function chooseRandomAction(timer:FlxTimer):Void
    {
        if (isActing || isStartQueued || isStartingGame) return;

        isActing = true;
        var actionChoice:Int = FlxG.random.int(1, 3);
        
        if (currentTween != null)
        {
            currentTween.cancel();
            currentTween = null;
        }
        
        ball.angle = 0;
        ball.x = 200;
        ball.y = floorY - 76;
        ball.animation.play("blink");
        
        switch (actionChoice)
        {
            case 1:
                ball.animation.play("blink");
                actionTimer = new FlxTimer().start(0.5, function(t:FlxTimer) {
                    isActing = false;
                    checkQueuedStart();
                });
                trace("Ball Action: Blink");
                
            case 2:
                var jumpHeight:Float = floorY - 200;
                currentTween = FlxTween.tween(ball, {angle: 180, y: jumpHeight}, 0.5, {ease: FlxEase.quadOut, onComplete: function(tween:FlxTween) {
                    currentTween = FlxTween.tween(ball, {angle: 360, y: floorY - 76}, 0.5, {ease: FlxEase.quadIn, onComplete: function(tween:FlxTween) {
                        ball.angle = 0;
                        ball.animation.play("blink");
                        isActing = false;
                        currentTween = null;
                        checkQueuedStart();
                        trace("Ball Action: Jump Flip Complete");
                    }});
                }});
                
            case 3:
                currentTween = FlxTween.tween(ball, {angle: 90, x: 300}, 0.8, {ease: FlxEase.sineInOut, onComplete: function (tween:FlxTween) {
                    actionTimer = new FlxTimer().start(0.6, function (timer:FlxTimer) {
                        currentTween = FlxTween.tween(ball, {angle: 0, x: 200}, 0.8, {ease: FlxEase.sineInOut, onComplete: function (tween:FlxTween) {
                            ball.animation.play("blink");
                            isActing = false;
                            currentTween = null;
                            checkQueuedStart();
                            trace("Ball Action: Roll Complete");
                        }});
                    });
                }});
        }
    }

    function checkQueuedStart():Void
    {
        if (isStartQueued)
            preparedToPlay();
        else
            setupNextAction();
    }

    function setupNextAction():Void
    {
        if (isStartQueued || isStartingGame) return;
        var randomDelay:Float = FlxG.random.float(1.5, 3.0);
        actionTimer = new FlxTimer().start(randomDelay, chooseRandomAction);
        trace("Next Action in: " + randomDelay + "s");
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        for (basic in cloudGroup.members)
        {
            if (basic != null)
            {
                var cloud:FlxSprite = cast basic;
                if (cloud.x + cloud.width < 0)
                {
                    cloud.x = FlxG.width + (Math.random() * 100);
                    cloud.y = 30 + Math.random() * 200;
                    var randomFrame = cloudImages[Std.int(Math.random() * cloudImages.length)];
                    cloud.loadGraphic(randomFrame);
                    cloud.velocity.x = -(30 + Math.random() * 50);
                }
            }
        }

        #if (mobile || fakeMobile)
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                if (touch.overlaps(startButton) && !isStartQueued && !isStartingGame)
                {
                    FlxG.sound.play(AssetPaths.select__ogg);
                    isStartQueued = true;
                    if (actionTimer != null) 
                    {
                        actionTimer.cancel();
                        actionTimer = null;
                    }
                    
                    if (currentTween != null)
                    {
                        currentTween.cancel();
                        currentTween = null;
                    }
                    
                    ball.angle = 0;
                    ball.x = 200;
                    ball.y = floorY - 76;
                    ball.animation.play("blink");
                    isActing = false;
                    startButton.animation.play("selected", true);
                    trace("Play Button Touched!");
                    preparedToPlay();
                }
                else if (touch.overlaps(shopButton))
                {
                    FlxG.sound.play(AssetPaths.select__ogg);
                    shopButton.animation.play("selected", true);
                    trace("Shop Button Touched!");
                    openSubState(new TransitionSubState(false, function () {
                        FlxG.switchState(() -> new ShopState());
                    }));
                }
                else if (touch.overlaps(settingButton))
                {
                    FlxG.sound.play(AssetPaths.select__ogg);
                    settingButton.animation.play("selected", true);
                    FlxTween.globalManager.active = false;
                    trace("Setting Button Touched!");
                    openSubState(new SettingSubState());
                }
            }
            
            if (touch.overlaps(startButton))
            {
                startButton.animation.play("hover", true);
            }
            else if (touch.overlaps(shopButton))
            {
                shopButton.animation.play("hover", true);
            }
            else if (touch.overlaps(settingButton))
            {
                settingButton.animation.play("hover", true);
            }
            else
            {
                startButton.animation.play("idle", true);
                shopButton.animation.play("idle", true);
                settingButton.animation.play("idle", true);
            }
        }
        #else
        if (FlxG.mouse.overlaps(startButton))
        {
            startButton.animation.play("hover", true);
        }
        else
        {
            startButton.animation.play("idle", true);
        }

        if (FlxG.mouse.overlaps(shopButton))
        {
            shopButton.animation.play("hover", true);
        }
        else
        {
            shopButton.animation.play("idle", true);
        }

        if (FlxG.mouse.overlaps(settingButton))
        {
            settingButton.animation.play("hover", true);
        }
        else
        {
            settingButton.animation.play("idle", true);
        }

        if (FlxG.mouse.justPressed && !isStartQueued && !isStartingGame)
        {
            if (FlxG.mouse.overlaps(startButton))
            {
                FlxG.sound.play(AssetPaths.select__ogg);
                isStartQueued = true;
                if (actionTimer != null) 
                {
                    actionTimer.cancel();
                    actionTimer = null;
                }
                
                if (currentTween != null)
                {
                    currentTween.cancel();
                    currentTween = null;
                }
                
                ball.angle = 0;
                ball.x = 200;
                ball.y = floorY - 76;
                ball.animation.play("blink");
                isActing = false;
                startButton.animation.play("selected", true);
                trace("Play Button Clicked!");
                preparedToPlay();
            }
            else if (FlxG.mouse.overlaps(shopButton))
            {
                FlxG.sound.play(AssetPaths.select__ogg);
                shopButton.animation.play("selected", true);
                trace("Shop Button Clicked!");
                openSubState(new TransitionSubState(false, function () {
                    FlxG.switchState(() -> new ShopState());
                }));
            }
            else if (FlxG.mouse.overlaps(settingButton))
            {
                FlxG.sound.play(AssetPaths.select__ogg);
                settingButton.animation.play("selected", true);
                FlxTween.globalManager.active = false;
                trace("Setting Button Clicked!");
                openSubState(new SettingSubState());
            }
        }
        #end
    }

    function preparedToPlay()
    {
        isStartQueued = false;
        isStartingGame = true;
        isActing = true;

        if (currentTween != null)
        {
            currentTween.cancel();
            currentTween = null;
        }

        FlxTween.tween(logo, {y: -logo.height - 40}, 0.5, {ease: FlxEase.backIn});
        FlxTween.tween(startButton, {x: FlxG.width + 50}, 0.4, {ease: FlxEase.cubeIn});
        FlxTween.tween(shopButton, {x: FlxG.width + 50}, 0.4, {ease: FlxEase.cubeIn, startDelay: 0.1});
        FlxTween.tween(settingButton, {x: FlxG.width + 50}, 0.4, {ease: FlxEase.cubeIn, startDelay: 0.2, onComplete: function (tween:FlxTween) {
            startedToPlay();
        }});
        trace("Starting Game Transition...");
    }

    function startedToPlay() 
    {
        ball.x = 200;
        ball.y = floorY - 76;
        ball.angle = 0;
        
        FlxTween.tween(ball, {angle: 720, x: FlxG.width + 100, y: floorY - 76}, 0.8, {ease: FlxEase.sineIn, onComplete: function (tween:FlxTween) {
            trace("Transition Complete! Switching to PlayState");
            openSubState(new TransitionSubState(false, function() {
                FlxG.switchState(() -> new PlayState());
            }));
        }});
    }
}