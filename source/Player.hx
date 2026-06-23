package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Player extends FlxSprite
{
    public var health:Int = 100;

    public function new(x:Float = 0, y:Float = 0) 
    {
        health = FlxG.save.data.playerHealth;
        super(x, y);
        frames = FlxAtlasFrames.fromSparrow(AssetPaths.ball__png, AssetPaths.ball__xml);
        animation.addByPrefix("idle", "idle");
        animation.addByPrefix("blink", "blink", 8, false);
        animation.addByPrefix("get hit", "get hit0", 12, false);
        animation.onFinish.add(function (name:String) {
            if (name == "blink")
                animation.play("idle");
            if (name == "get hit")
                animation.play("idle");
        });
        animation.play("idle");
        
        acceleration.y = 1000; 
        maxVelocity.y = 700;
        updateHitbox();
    }
}