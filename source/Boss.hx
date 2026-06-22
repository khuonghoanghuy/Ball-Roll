package;

import BossConfig.BossSpawnConfig;
import Enemy.EnemyType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

enum BossPhase {
    Intro;
    Phase1;
    Phase2;
    Dead;
}

enum BossType {
    Classic;
    Surprise;
}

class Boss extends FlxSprite {
    public var currentPhase:BossPhase = Intro;
    public var bossType:BossType = Classic;
    public var maxHealth:Float = 100;
    public var health:Float = 100;
    public var difficultyMultiplier:Float = 1.0;
    
    var phase2Timer:Float = 15;
    var phase2Duration:Float = 15;
    var phase2HealthDrain:Float = 0;
    
    var targetX:Float;
    var startY:Float;
    var jumpTimer:Float = 0;
    var teleportTimer:Float = 0;
    var config:BossSpawnConfig;
    
    var shootTimer:Float = 0;
    var shootCooldown:Float = 0.6;
    
    var isDying:Bool = false;
    var deathTimer:Float = 0;

    public function new(x:Float, y:Float, type:BossType, difficulty:Float = 1.0) {
        super(x, y);
        this.bossType = type;
        this.startY = y;
        this.difficultyMultiplier = difficulty;
        this.targetX = FlxG.width - 150;
        
        config = BossConfig.getConfigForType(type);
        if (config == null) {
            @:privateAccess
            config = BossConfig.getDefaultConfig()[0];
        }
        
        setupBoss();
        setupAppearance();
        
        health = maxHealth;
        phase2Duration = config.phase2Duration;
        phase2Timer = config.phase2Duration;
        shootCooldown = config.shootCooldown / difficultyMultiplier;
    }
    
    function setupBoss():Void {
        maxHealth = config.maxHealth * difficultyMultiplier;
        phase2HealthDrain = maxHealth / config.phase2Duration;
    }
    
    function setupAppearance():Void {
        if (bossType == Classic) {
            loadGraphic(AssetPaths.classic_boss__png, true, 128, 128);
            animation.add("idle", [0]);
            animation.add("hurt", [1, 2, 3, 4], 12, false);
            animation.add("dead", [0, 4, 3, 2, 5], 12, false);
            animation.onFinish.add(function (name:String) {
                if (bossType == Classic)
                {
                    if (name == "hurt")
                        animation.play("idle", true);
                }
            });
            animation.play("idle", true);
        } else if (bossType == Surprise) {
            loadGraphic(AssetPaths.surprise_boss__png);
        }
    }
    
    function getColorFromString(colorName:String):FlxColor {
        return switch(colorName) {
            case "ORANGE": FlxColor.ORANGE;
            case "PURPLE": FlxColor.PURPLE;
            case "RED": FlxColor.RED;
            case "BLUE": FlxColor.BLUE;
            case "GREEN": FlxColor.GREEN;
            case "YELLOW": FlxColor.YELLOW;
            default: FlxColor.GRAY;
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        FlxG.watch.addQuick("Boss Health", this.health);
        FlxG.watch.addQuick("Boss Phase", this.currentPhase);
        FlxG.watch.addQuick("Boss Name", this.bossType.getName());
        
        jumpTimer += elapsed * config.moveSpeed;
        
        if (isDying) {
            deathTimer += elapsed;
            alpha -= elapsed * 1.5;
            scale.x += elapsed * 0.3;
            scale.y += elapsed * 0.3;
            if (alpha <= 0) {
                currentPhase = Dead;
            }
            return;
        }
        
        updateMovement(elapsed);
        
        switch (currentPhase) {
            case Intro:
                if (this.x > targetX) {
                    this.x -= 200 * elapsed;
                } else {
                    this.x = targetX;
                    currentPhase = Phase1;
                    FlxG.camera.shake(0.03, 0.3);
                }
                
            case Phase1:
                shootTimer += elapsed;
                
            case Phase2:
                phase2Timer -= elapsed;
                health -= phase2HealthDrain * elapsed * 0.5;
                
                if (phase2Timer <= 0 || health <= 0) {
                    health = 0;
                    startDeath();
                }
                
                shootTimer += elapsed * (1 / config.phase2ShootMultiplier);
                
            case Dead:
                animation.play("dead", true);
        }
    }
    
    function updateMovement(elapsed:Float):Void {
        switch(config.movePattern) {
            case "sine":
                this.y = startY + Math.sin(jumpTimer) * config.moveAmplitude;
                
            case "erratic":
                this.y = startY + Math.sin(jumpTimer * 1.5) * config.moveAmplitude;
                var shakeX = Math.sin(jumpTimer * 0.7) * 15;
                this.x = targetX + shakeX;
                
            case "teleport":
                this.y = startY + Math.sin(jumpTimer) * config.moveAmplitude;
                teleportTimer += elapsed;
                
                if (teleportTimer > 2 + Math.random() * 1.5) {
                    var newX = FlxG.random.float(100, FlxG.width - 100);
                    this.x = newX;
                    targetX = newX;
                    teleportTimer = 0;
                    FlxG.camera.shake(0.01, 0.1);
                }
                if (alpha < 0.85) {
                    alpha += (0.85 - alpha) * 0.05;
                }
                
            default:
                this.y = startY + Math.sin(jumpTimer) * 40;
        }
    }
    
    function startDeath():Void {
        isDying = true;
        deathTimer = 0;
        FlxG.camera.shake(0.05, 0.5);
    }

    public function takeDamage(amount:Float):Void {
        if (isDying || currentPhase == Dead) return;
        
        health -= amount;
        
        if (currentPhase == Phase1 && health <= config.phase2Threshold * difficultyMultiplier) {
            health = config.phase2Threshold * difficultyMultiplier;
            currentPhase = Phase2;
            phase2Timer = config.phase2Duration;
            phase2HealthDrain = health / config.phase2Duration;
            FlxG.camera.shake(0.05, 0.5);
            FlxG.sound.play(AssetPaths.hit__ogg);
        }
        
        if (health <= 0) {
            health = 0;
            startDeath();
        }
    }
    
    public function canShoot():Bool {
        if (currentPhase == Dead || isDying) return false;
        if (currentPhase == Intro) return false;
        
        var currentCooldown = shootCooldown;
        if (currentPhase == Phase2) {
            currentCooldown *= config.phase2ShootMultiplier;
        }
        currentCooldown /= difficultyMultiplier;
        
        if (shootTimer >= currentCooldown) {
            shootTimer = 0;
            return true;
        }
        return false;
    }
    
    public function getSpawnX():Float {
        if (bossType == Surprise) {
            var spawnX = this.x - 120;
            if (FlxG.random.bool(30)) {
                spawnX = this.x - 200;
            }
            return spawnX;
        }
        return this.x;
    }
    
    public function getAvailableEnemyTypes():Array<EnemyType> {
        var types:Array<EnemyType> = [Normal, Notward];
        
        switch(bossType) {
            case Classic:
                types.push(Wave);
                if (FlxG.random.bool(20)) types.push(Orb);
                
            case Surprise:
                if (FlxG.random.bool(15)) types.push(Wave);
                if (FlxG.random.bool(20)) types.push(Orb);
                if (FlxG.random.bool(15) && currentPhase == Phase1) types.push(Backward);
        }
        
        return types;
    }
    
    public function getPhase2SpawnCount():Int {
        return FlxG.random.bool(30) ? 2 : 1;
    }
    
    public function getBulletSpeed(baseSpeed:Float):Float {
        var speed = baseSpeed;
        if (currentPhase == Phase2) {
            speed *= 1.2;
        }
        return speed;
    }
    
    public static function create(floorY:Float, difficulty:Float):Boss {
        var type = BossConfig.getRandomBossType(0); // Score will be passed from PlayState
        var boss = new Boss(FlxG.width + 100, floorY - 180, type, difficulty);
        return boss;
    }
    
    public static function createWithScore(floorY:Float, difficulty:Float, score:Int):Boss {
        var type = BossConfig.getRandomBossType(score);
        var boss = new Boss(FlxG.width + 100, floorY - 180, type, difficulty);
        return boss;
    }
}