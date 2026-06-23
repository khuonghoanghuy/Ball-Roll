package;

import flixel.tweens.FlxTween;
import openfl.filters.ShaderFilter;
import Boss.BossPhase;
import Boss.BossType;
import Enemy.EnemyType;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class PlayState extends FlxState
{
    var player:Player;
    var invisibleLine:FlxSprite;
    var dustEmitter:FlxEmitter;
    var boss:Boss = null;
    var isBossActive:Bool = false;
    var nextBossScore:Int = 10000;

    var enemyLineUp:FlxGroup;
    var enemyLineDown:FlxGroup;
    var spawnTimer:Float = 0;
    var nextSpawnTime:Float = 1.0;

    var scoreText:FlxText;
    var totalScore:Int = 0;
    var scoreTimer:Float = 0;
    var highScoreText:FlxText;
    var displayedScore:Float = 0;
    var healthBar:FlxBar;
    var timeSecond:Int = 0;
    var timesHitByEnemy:Int = 0;
    var barrierBar:FlxBar;
    var barrierIcon:FlxSprite;
    var bossHealthBar:FlxBar;
    var floorY:Float = 450;
    var baseEnemySpeed:Int = -400;

    var cloudGroup:FlxGroup;
    var cloudImages:Array<String>;
    
    var treeGroup:FlxGroup;
    var treeImages:Array<String>;
    var bushGroup:FlxGroup;
    var bushImages:Array<String>;

    var camHUD:FlxCamera;
    var floor:FlxBackdrop;
    
    var currentGlobalSpeed:Float = -400;
    var bossActiveTimer:Float = 0;
    var bossDefeatedCount:Int = 0;
    var bossDifficultyMultiplier:Float = 1.0;
    
    var bossStartTimeSecond:Int = 0;
    var bossStartGlobalSpeed:Float = 0;
    
    var spawnCount:Int = 0;

    var pauseButton:FlxSprite;
    var touchLeftZone:FlxSprite;
    var touchRightZone:FlxSprite;
    var jumpHint:FlxSprite;
    var diveHint:FlxSprite;
    var touchJumpCooldown:Float = 0;
    var isDiving:Bool = false;

    override public function create()
    {
        super.create();
        openSubState(new TransitionSubState(true));
        bgColor = FlxColor.CYAN;

        if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        {  
            FlxG.sound.playMusic(AssetPaths.game__ogg);
        }
        
        EnemyConfig.init();
        BossConfig.init();

        trace("=== PlayState Initialized ===");
        trace("Enemy Configs Loaded: " + EnemyConfig.SPAWN_CONFIGS.length);
        trace("Boss Configs Loaded: " + BossConfig.CONFIGS.length);

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
            cloud.velocity.x = baseEnemySpeed;
            cloud.alpha = 0.5 + Math.random() * 0.4;
            cloudGroup.add(cloud);
        }
        trace("Clouds Spawned: " + maxClouds);

        treeImages = [
            AssetPaths.tree__png,
            AssetPaths.tree_2__png
        ];
        treeGroup = new FlxGroup();
        add(treeGroup);

        var maxTree:Int = 3;
        for (i in 0...maxTree)
        {
            var tree = new FlxSprite();
            tree.loadGraphic(treeImages[Std.int(Math.random() * treeImages.length)], true, 32, 48);
            tree.animation.add("idle", [0, 1, 2, 3], 12, true);
            tree.animation.play("idle", true);
            tree.scale.set(2, 2);
            tree.updateHitbox();
            tree.x = Math.random() * FlxG.width;
            tree.y = floorY - (48 * 2);
            tree.velocity.x = baseEnemySpeed * 0.8;
            treeGroup.add(tree);
        }
        trace("Trees Spawned: " + maxTree);

        bushImages = [
            AssetPaths.bush__png
        ];
        bushGroup = new FlxGroup();
        add(bushGroup);

        var maxBush:Int = 6;
        for (i in 0...maxBush)
        {
            var bush = new FlxSprite();
            bush.loadGraphic(bushImages[Std.int(Math.random() * bushImages.length)], true, 48, 26);
            bush.animation.add("idle", [0, 1, 2, 3], 12, true);
            bush.animation.play("idle", true);
            bush.updateHitbox();
            bush.x = Math.random() * FlxG.width;
            bush.y = floorY - 26;
            bush.velocity.x = baseEnemySpeed * 0.8;
            bushGroup.add(bush);
        }
        trace("Bushes Spawned: " + maxBush);

        invisibleLine = new FlxSprite(0, floorY);
        invisibleLine.makeGraphic(FlxG.width, 20, FlxColor.YELLOW);
        invisibleLine.alpha = 0;
        invisibleLine.immovable = true;
        add(invisibleLine);

        player = new Player(200, floorY - 76); 
        add(player);
        trace("Player Created at: (" + player.x + ", " + player.y + ")");
        trace("Player Health: " + player.health);

        floor = new FlxBackdrop(AssetPaths.floor__png, X);
        floor.setPosition(0, floorY);
        floor.velocity.x = baseEnemySpeed;
        add(floor);

        dustEmitter = new FlxEmitter(0, 0, 50);
        dustEmitter.makeParticles(4, 4, FlxColor.WHITE, 50);
        dustEmitter.launchMode = SQUARE;
        dustEmitter.velocity.set(-100, -20, -50, -50);
        dustEmitter.lifespan.set(0.3, 0.5);
        dustEmitter.alpha.set(0.8, 1, 0, 0);
        add(dustEmitter);
        dustEmitter.start(false, 0.05);
        trace("Dust Emitter Started");

        enemyLineUp = new FlxGroup();
        add(enemyLineUp);
        
        enemyLineDown = new FlxGroup();
        add(enemyLineDown);

        camHUD = new FlxCamera();
        camHUD.bgColor = FlxColor.TRANSPARENT;
        if (FlxG.save.data.shader)
            camHUD.filters = [new ShaderFilter(Main.chromaticShader)];
        FlxG.cameras.add(camHUD, false);
        trace("HUD Camera Created");

        #if (mobile || fakeMobile)
        touchLeftZone = new FlxSprite(0, 0);
        touchLeftZone.makeGraphic(Std.int(FlxG.width / 2), Std.int(FlxG.height), FlxColor.TRANSPARENT);
        touchLeftZone.camera = camHUD;
        add(touchLeftZone);

        touchRightZone = new FlxSprite(FlxG.width / 2, 0);
        touchRightZone.makeGraphic(Std.int(FlxG.width / 2), Std.int(FlxG.height), FlxColor.TRANSPARENT);
        touchRightZone.camera = camHUD;
        add(touchRightZone);

        var hudOffsetX:Float = 10;
        var hudOffsetY:Float = 10;
        var barWidth:Int = 120;

        scoreText = new FlxText(FlxG.width / 2 - 80, hudOffsetY, 0, "Score: 0");
        scoreText.setFormat(null, 22, FlxColor.WHITE, CENTER);
        scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        scoreText.camera = camHUD;
        add(scoreText);

        highScoreText = new FlxText(FlxG.width / 2 - 80, hudOffsetY + 28, 0, "High Score: " + FlxG.save.data.highScore);
        highScoreText.setFormat(null, 14, FlxColor.YELLOW, CENTER);
        highScoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        highScoreText.camera = camHUD;
        add(highScoreText);

        healthBar = new FlxBar(hudOffsetX + 50, hudOffsetY + 30, LEFT_TO_RIGHT, barWidth, 18, player, "health", 0, player.health);
        healthBar.createFilledBar(FlxColor.fromRGB(60, 0, 0), FlxColor.GREEN, true, FlxColor.BLACK, 1);
        healthBar.camera = camHUD;
        add(healthBar);

        var heartIcon:FlxSprite = new FlxSprite(hudOffsetX, hudOffsetY + 20, AssetPaths.heart__png);
        heartIcon.setGraphicSize(36, 36);
        heartIcon.updateHitbox();
        heartIcon.camera = camHUD;
        add(heartIcon);

        if (FlxG.save.data.barrier > 0)
        {
            var maxBarrier:Int = 5;
            if (FlxG.save.data.barrier > maxBarrier) {
                maxBarrier = FlxG.save.data.barrier;
            }
            barrierBar = new FlxBar(hudOffsetX + 50, hudOffsetY + 52, LEFT_TO_RIGHT, barWidth, 16, FlxG.save.data, "barrier", 0, maxBarrier);
            barrierBar.createFilledBar(FlxColor.fromRGB(40, 40, 40), FlxColor.BLUE, true, FlxColor.BLACK, 1);
            barrierBar.camera = camHUD;
            add(barrierBar);

            barrierIcon = new FlxSprite(hudOffsetX, hudOffsetY + 42, AssetPaths.barrier__png);
            barrierIcon.setGraphicSize(30, 30);
            barrierIcon.updateHitbox();
            barrierIcon.camera = camHUD;
            add(barrierIcon);
            trace("Barrier UI Created: " + FlxG.save.data.barrier + " charges");
        }

        pauseButton = new FlxSprite(FlxG.width - 55, hudOffsetY + 5);
        pauseButton.scale.set(2.5, 2.5);
        pauseButton.updateHitbox();
        pauseButton.loadGraphic(AssetPaths.pause__png, true, 32, 32);
        pauseButton.animation.add("idle", [0]);
        pauseButton.animation.add("pressed", [0, 1, 2], 12, false);
        pauseButton.animation.onFinish.add(function (name:String) {
            if (name == "pressed")
                pauseButton.animation.play("idle", true);
        });
        pauseButton.animation.play("idle", true);
        pauseButton.camera = camHUD;
        add(pauseButton);

        jumpHint = new FlxSprite(40, FlxG.height - 80);
        jumpHint.loadGraphic(AssetPaths.arrow__png, true, 32, 32);
        jumpHint.animation.add("jump", [0]);
        jumpHint.animation.play("jump");
        jumpHint.scale.set(1.5, 1.5);
        jumpHint.alpha = 0.3;
        jumpHint.camera = camHUD;
        add(jumpHint);

        var jumpLabel = new FlxText(20, FlxG.height - 45, 100, "JUMP");
        jumpLabel.setFormat(null, 12, FlxColor.WHITE, CENTER);
        jumpLabel.alpha = 0.3;
        jumpLabel.camera = camHUD;
        add(jumpLabel);

        diveHint = new FlxSprite(FlxG.width - 80, FlxG.height - 80);
        diveHint.loadGraphic(AssetPaths.arrow__png, true, 32, 32);
        diveHint.animation.add("dive", [1]);
        diveHint.animation.play("dive");
        diveHint.scale.set(1.5, 1.5);
        diveHint.alpha = 0.3;
        diveHint.camera = camHUD;
        add(diveHint);

        var diveLabel = new FlxText(FlxG.width - 100, FlxG.height - 45, 100, "DIVE");
        diveLabel.setFormat(null, 12, FlxColor.WHITE, CENTER);
        diveLabel.alpha = 0.3;
        diveLabel.camera = camHUD;
        add(diveLabel);

        trace("Mobile UI Created");
        trace("Mobile Mode Active");

        #else
        scoreText = new FlxText(FlxG.width - 310, 15, 0, "Score: 0");
        scoreText.setFormat(null, 24, FlxColor.WHITE, RIGHT);
        scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        scoreText.camera = camHUD;
        add(scoreText);

        highScoreText = new FlxText(FlxG.width - 310, 50, 0, "High Score: " + FlxG.save.data.highScore);
        highScoreText.setFormat(null, 18, FlxColor.YELLOW, RIGHT);
        highScoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        highScoreText.camera = camHUD;
        add(highScoreText);

        var barWidth:Int = 150;
        healthBar = new FlxBar(55, 23, LEFT_TO_RIGHT, barWidth, 22, player, "health", 0, player.health);
        healthBar.createFilledBar(FlxColor.fromRGB(60, 0, 0), FlxColor.GREEN, true, FlxColor.BLACK, 2);
        healthBar.camera = camHUD;
        add(healthBar);

        var heartIcon:FlxSprite = new FlxSprite(15, 15, AssetPaths.heart__png);
        heartIcon.setGraphicSize(48, 48);
        heartIcon.updateHitbox();
        heartIcon.camera = camHUD;
        add(heartIcon);

        if (FlxG.save.data.barrier > 0)
        {
            var maxBarrier:Int = 5;
            if (FlxG.save.data.barrier > maxBarrier) {
                maxBarrier = FlxG.save.data.barrier;
            }
            barrierBar = new FlxBar(55, 60, LEFT_TO_RIGHT, barWidth, 22, FlxG.save.data, "barrier", 0, maxBarrier);
            barrierBar.createFilledBar(FlxColor.fromRGB(40, 40, 40), FlxColor.BLUE, true, FlxColor.BLACK, 2);
            barrierBar.camera = camHUD;
            add(barrierBar);

            barrierIcon = new FlxSprite(15, 52, AssetPaths.barrier__png);
            barrierIcon.setGraphicSize(48, 48);
            barrierIcon.updateHitbox();
            barrierIcon.camera = camHUD;
            add(barrierIcon);
        }
        trace("Desktop UI Created");
        #end

        bossHealthBar = new FlxBar((FlxG.width - 400) / 2, #if fakeMobile 40 #else 20 #end, LEFT_TO_RIGHT, 400, 20, null, "", 0, 100, true);
        bossHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, true, FlxColor.WHITE);
        bossHealthBar.visible = false;
        bossHealthBar.camera = camHUD;
        add(bossHealthBar);

        trace("=== PlayState Setup Complete ===");
        trace("Starting Score: " + totalScore);
        trace("High Score: " + FlxG.save.data.highScore);
        trace("Next Boss Score: " + nextBossScore);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        var effectiveTimeSecond:Int = isBossActive ? bossStartTimeSecond : timeSecond;
        var speedMultiplier:Float = 1 + (bossDefeatedCount * 0.1);
        var baseSpeed = baseEnemySpeed - (Std.int(effectiveTimeSecond / 5) * 30);
        if (baseSpeed < -900) baseSpeed = -900;
        currentGlobalSpeed = baseSpeed * speedMultiplier;
        
        var floorSpeed:Float = baseEnemySpeed - (Std.int(effectiveTimeSecond / 5) * 30);
        if (floorSpeed < -900) floorSpeed = -900;
        
        for (cloud in cloudGroup.members)
        {
            if (cloud != null)
            {
                var cloudSprite:FlxSprite = cast cloud;
                cloudSprite.velocity.x = currentGlobalSpeed * 0.2;
                
                if (cloudSprite.x + cloudSprite.width < 0)
                {
                    cloudSprite.x = FlxG.width + (Math.random() * 100);
                    cloudSprite.y = 30 + Math.random() * 200;
                    var randomFrame = cloudImages[Std.int(Math.random() * cloudImages.length)];
                    cloudSprite.loadGraphic(randomFrame);
                }
            }
        }

        for (tree in treeGroup.members)
        {
            if (tree != null)
            {
                var treeSprite:FlxSprite = cast tree;
                treeSprite.velocity.x = currentGlobalSpeed * 0.5;
                
                if (treeSprite.x + treeSprite.width < 0)
                {
                    treeSprite.x = FlxG.width + (Math.random() * 100);
                    treeSprite.y = floorY - (48 * 2);
                    treeSprite.loadGraphic(treeImages[Std.int(Math.random() * treeImages.length)], true, 32, 48);
                    treeSprite.animation.add("idle", [0, 1, 2, 3], 12, true);
                    treeSprite.animation.play("idle", true);
                }
            }
        }

        for (bush in bushGroup.members)
        {
            if (bush != null)
            {
                var bushSprite:FlxSprite = cast bush;
                bushSprite.velocity.x = currentGlobalSpeed * 0.5;
                
                if (bushSprite.x + bushSprite.width < 0)
                {
                    bushSprite.x = FlxG.width + (Math.random() * 100);
                    bushSprite.y = floorY - 26;
                    bushSprite.loadGraphic(bushImages[Std.int(Math.random() * bushImages.length)], true, 48, 26);
                    bushSprite.animation.add("idle", [0, 1, 2, 3], 12, true);
                    bushSprite.animation.play("idle", true);
                }
            }
        }

        floor.x += floorSpeed * elapsed;
        player.angle += (Math.abs(currentGlobalSpeed) * elapsed);

        if (dustEmitter != null)
        {
            dustEmitter.x = -10 + (player.x + (player.width / 2));
            dustEmitter.y = player.y + player.height - 4;
            
            if (player.isTouching(FLOOR))
            {
                dustEmitter.emitting = true;
            }
            else
            {
                dustEmitter.emitting = false;
            }
        }

        displayedScore = GameUtil.lerpInt(displayedScore, totalScore, 1, elapsed);
        scoreText.text = "Score: " + Std.int(displayedScore);

        if (!isBossActive)
        {
            scoreTimer += elapsed;
            if (scoreTimer >= 1)
            {
                timeSecond += 1;
                scoreTimer -= 1;
            }
        }
        
        var scoreGainPerSecond:Float = 60; 
        totalScore += Std.int(scoreGainPerSecond * elapsed);
        if (displayedScore > FlxG.save.data.highScore)
        {
            highScoreText.text = "High Score: " + Std.int(displayedScore);
        }

        if (totalScore >= nextBossScore && !isBossActive)
        {
            isBossActive = true;
            bossActiveTimer = 0;
            nextBossScore += 10000;
            
            bossStartTimeSecond = timeSecond;
            bossStartGlobalSpeed = currentGlobalSpeed;
            
            bossDifficultyMultiplier = 1 + (bossDefeatedCount * 0.2);
            boss = Boss.createWithScore(floorY, bossDifficultyMultiplier, totalScore);
            add(boss);

            bossHealthBar.setParent(boss, "health", false);
            bossHealthBar.visible = true;
            trace("=== BOSS SPAWNED ===");
            trace("Score: " + totalScore + " | Time: " + timeSecond + "s");
            trace("Difficulty Multiplier: " + bossDifficultyMultiplier);
            trace("Boss Health: " + boss.health);
        }

        FlxG.collide(player, invisibleLine);
        FlxG.overlap(player, enemyLineUp, onPlayerHitEnemy);
        FlxG.overlap(player, enemyLineDown, onPlayerHitEnemy);
        
        #if (mobile || fakeMobile)
        touchJumpCooldown -= elapsed;
        
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                if (touch.x < FlxG.width / 2)
                {
                    if (player.isTouching(FLOOR) && touchJumpCooldown <= 0)
                    {
                        FlxG.sound.play(AssetPaths.jump__ogg);
                        player.velocity.y = -500;
                        touchJumpCooldown = 0.2;
                        FlxG.camera.shake(0.01, 0.05);
                        
                        if (jumpHint != null)
                        {
                            jumpHint.alpha = 0.8;
                            FlxTween.tween(jumpHint, {alpha: 0.3}, 0.3);
                        }
                    }
                }
                else
                {
                    if (!player.isTouching(FLOOR))
                    {
                        isDiving = true;
                        player.velocity.y = 750;
                        
                        if (diveHint != null)
                        {
                            diveHint.alpha = 0.8;
                            FlxTween.tween(diveHint, {alpha: 0.3}, 0.3);
                        }
                    }
                }
            }
            
            if (touch.justReleased)
            {
                if (touch.x >= FlxG.width / 2)
                {
                    isDiving = false;
                }
            }
            
            if (touch.x >= FlxG.width / 2 && touch.pressed && isDiving)
            {
                if (!player.isTouching(FLOOR))
                {
                    player.velocity.y = 750;
                }
            }
        }
        
        if (pauseButton != null)
        {
            for (touch in FlxG.touches.justReleased())
            {
                if (touch.overlaps(pauseButton))
                {
                    pauseButton.animation.play("pressed", true);
                    this.persistentUpdate = false;
                    openSubState(new PauseSubState());
                    trace("Game Paused");
                    return;
                }
            }
        }
        #else
        if (FlxG.keys.justPressed.UP && player.isTouching(FLOOR))
        {
            FlxG.sound.play(AssetPaths.jump__ogg);
            player.velocity.y = -500;
        }
        
        if (FlxG.keys.justPressed.DOWN && !player.isTouching(FLOOR))
        {
            player.velocity.y = 750;
        }
        
        if (FlxG.keys.justPressed.ESCAPE)
        {
            this.persistentUpdate = false;
            openSubState(new PauseSubState());
            trace("Game Paused");
            return;
        }
        #end

        if (!isBossActive)
        {
            spawnTimer += elapsed;
            if (spawnTimer >= nextSpawnTime)
            {
                var eType:EnemyType = Enemy.getRandomEnemyType(timeSecond);
                if (eType == null) eType = Normal;
                
                spawnCount++;
                if (spawnCount % 10 == 0) {
                    trace("Spawn Count: " + spawnCount + " | Time: " + timeSecond + "s");
                }

                var enemyHeight:Float = 48;
                var config = Enemy.getConfigForType(eType);
                
                if (config != null)
                {
                    var line = 0;
                    var ex:Float = FlxG.width;
                    var ey:Float = floorY - enemyHeight;
                    
                    switch (config.spawnPosition)
                    {
                        case "random_line":
                            line = (Math.random() < 0.5) ? 0 : 1;
                            ey = (line == 1) ? (floorY - enemyHeight) : ((floorY - 160) - enemyHeight);
                            
                        case "up_line":
                            line = 0;
                            ey = floorY - 160 - enemyHeight;
                            
                        case "down_line":
                            line = 1;
                            ey = floorY - enemyHeight;
                            
                        case "left_edge":
                            ex = -50;
                            ey = floorY - enemyHeight;
                            line = 1;
                            
                        case "right_edge":
                            ex = FlxG.width;
                            ey = (line == 1) ? (floorY - enemyHeight) : ((floorY - 160) - enemyHeight);
                            
                        default:
                            line = (Math.random() < 0.5) ? 0 : 1;
                            ey = (line == 1) ? (floorY - enemyHeight) : ((floorY - 160) - enemyHeight);
                    }
                    
                    var count:Int = config.minCount;
                    if (config.canSpawnMultiple)
                    {
                        count = FlxG.random.int(config.minCount, config.maxCount);
                    }
                    
                    for (i in 0...count)
                    {
                        var e = new Enemy(ex + (i * 65), ey, eType);
                        
                        if (eType == Backward)
                        {
                            e.velocity.x = Math.abs(currentGlobalSpeed) * 0.4;
                        }
                        else
                        {
                            e.velocity.x = currentGlobalSpeed;
                        }
                        
                        if (config.customSpeed != null)
                        {
                            e.velocity.x = config.customSpeed;
                        }
                        
                        add(e);
                        if (line == 0) 
                            enemyLineUp.add(e); 
                        else 
                            enemyLineDown.add(e);
                    }
                }
                
                var speedFactor:Float = (timeSecond / 20) * 0.1;
                var minSpawnDelay:Float = 1.2 - speedFactor;
                var maxSpawnDelay:Float = 2.5 - speedFactor;
                if (minSpawnDelay < 0.5) minSpawnDelay = 0.5;
                if (maxSpawnDelay < 1.0) maxSpawnDelay = 1.0;

                nextSpawnTime = minSpawnDelay + Math.random() * (maxSpawnDelay - minSpawnDelay);
                spawnTimer = 0;
            }
        }
        else
        {
            if (boss != null)
            {
                if (boss.currentPhase == BossPhase.Dead)
                {
                    addScore(5000);
                    remove(boss);
                    boss.destroy();
                    boss = null;
                    isBossActive = false;
                    bossDefeatedCount++;
                    
                    if (totalScore >= nextBossScore) {
                        nextBossScore = Std.int(totalScore / 10000) * 15000 + 15000;
                    }
                    bossHealthBar.visible = false;
                    trace("=== BOSS DEFEATED ===");
                    trace("Total Defeated: " + bossDefeatedCount);
                    trace("New Next Boss Score: " + nextBossScore);
                }
                else if (boss.currentPhase == BossPhase.Phase1 || boss.currentPhase == BossPhase.Phase2)
                {
                    if (boss.canShoot())
                    {
                        var targetGroup:FlxGroup = FlxG.random.getObject([enemyLineUp, enemyLineDown]);
                        var spawnY = (targetGroup == enemyLineUp) ? (floorY - 120) : (floorY - 48);
                        var bulletSpeed = boss.getBulletSpeed(-450);
                        var spawnX = boss.getSpawnX();
                        var availableTypes = boss.getAvailableEnemyTypes();
                        var randType = FlxG.random.getObject(availableTypes);
                        
                        if (boss.currentPhase == Phase1)
                        {
                            if (FlxG.random.bool(35))
                            {
                                var orb = new Enemy(spawnX, spawnY, Orb);
                                orb.velocity.x = bulletSpeed * 1.1;
                                add(orb);
                                targetGroup.add(orb);
                            }
                            else
                            {
                                var enemy = new Enemy(spawnX, spawnY, randType);
                                enemy.velocity.x = bulletSpeed;
                                add(enemy);
                                targetGroup.add(enemy);
                            }
                        }
                        else
                        {
                            var spawnCount = boss.getPhase2SpawnCount();
                            for (i in 0...spawnCount)
                            {
                                var enemy = new Enemy(spawnX + (i * 30), spawnY, randType);
                                enemy.velocity.x = bulletSpeed;
                                add(enemy);
                                targetGroup.add(enemy);
                            }
                        }
                    }

                    checkOrbCollision(enemyLineUp);
                    checkOrbCollision(enemyLineDown);
                }
            }
        }
        
        clearOffscreenEnemies(enemyLineUp);
        clearOffscreenEnemies(enemyLineDown);

        if (player.health <= 0)
        {
            this.persistentUpdate = false;
            trace("=== GAME OVER ===");
            trace("Final Score: " + totalScore);
            trace("Time Survived: " + timeSecond + "s");
            trace("Times Hit: " + timesHitByEnemy);
            openSubState(new GameOverSubState(totalScore, timeSecond, timesHitByEnemy));
            return;
        }
    }

    function checkOrbCollision(group:FlxGroup):Void
    {
        for (basic in group.members)
        {
            if (basic != null && basic.alive)
            {
                var enemy:Enemy = cast basic;
                if (enemy.type == Orb && enemy.ID == 999 && enemy.x >= boss.x)
                {
                    enemy.kill();
                    FlxG.sound.play(AssetPaths.hit__ogg);
                    FlxG.camera.shake(0.015, 0.15);
                    addScore(400);
                    boss.takeDamage(Std.int(10 * bossDifficultyMultiplier));
                    trace("Orb Hit! Boss Damage: " + Std.int(10 * bossDifficultyMultiplier));
                }
            }
        }
    }

    function clearOffscreenEnemies(group:FlxGroup)
    {
        for (basic in group.members)
        {
            if (basic != null && basic.alive)
            {
                var enemy:Enemy = cast basic;
                if ((enemy.x + enemy.width < -100 && enemy.type != Backward) || (enemy.x > FlxG.width + 100 && enemy.type == Backward))
                {
                    if (enemy.type != Ball_Heal) {
                        addScore(200);
                    }
                    enemy.kill();
                    group.remove(enemy, true);
                }
            }
        }
    }

    function addScore(points:Int)
    {
        totalScore += points;
    }

    function addHealth(much:Int)
    {
        if (player.health < FlxG.save.data.playerHealth)
        {
            player.health += much;
            trace("Health +" + much + " | New Health: " + player.health);
        }
        else
        {
            trace("Health Full! Current: " + player.health + "/" + FlxG.save.data.playerHealth);
        }
    }

    function onPlayerHitEnemy(player:Player, enemy:Enemy)
    {
        if (enemy.type == Orb)
        {
            if (enemy.ID != 999)
            {
                enemy.ID = 999;
                enemy.velocity.x = 900;
                enemy.animation.play("counter");
                FlxG.sound.play(AssetPaths.select__ogg);
                addScore(100);
                trace("Orb Countered!");
            }
            return;
        }
        else if (enemy.type == Ball_Heal)
        {
            enemy.kill();
            FlxG.sound.play(AssetPaths.select__ogg);
            addScore(50);
            addHealth(FlxG.save.data.ballGainHealth);
            trace("Health Ball Collected!");
            return;
        }

        enemy.kill();
        addScore(50);
        FlxG.sound.play(AssetPaths.hit__ogg);
        
        if (FlxG.save.data.barrier > 0)
        {
            FlxG.save.data.barrier -= 1;
            FlxG.save.flush();
            trace("Barrier Used! Remaining: " + FlxG.save.data.barrier);

            if (FlxG.save.data.barrier <= 0 && barrierBar != null)
            {
                barrierBar.visible = false;
                barrierIcon.visible = false;
                trace("Barrier Depleted!");
            }
        }
        else
        {
            var damageMultiplier:Float = 1 + (timeSecond / 60);
            var damageAmount:Int = Std.int(15 * damageMultiplier);
            if (damageAmount > 50) damageAmount = 50;
            
            player.health -= damageAmount;
            player.animation.play("get hit", true);
            timesHitByEnemy += 1;
            FlxG.camera.shake(0.005 + (damageAmount / 2000), 0.08 + (damageAmount / 2000));
            trace("Player Hit! Damage: " + damageAmount + " | Health: " + player.health);
        }

        FlxG.camera.shake(0.005, 0.08);
    }
}