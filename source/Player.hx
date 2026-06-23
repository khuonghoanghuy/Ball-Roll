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
        
        // #if (mobile || fakeMobile)
        // acceleration.y = 1500; 
        // maxVelocity.y = 1200;
        // #else
        acceleration.y = 1000; 
        maxVelocity.y = 700;
        // #end
        updateHitbox();
    }

    override public function update(elapsed:Float)
    {
        var isJumpingPressed:Bool = FlxG.keys.pressed.UP;

        #if (mobile || fakeMobile)
        for (touch in FlxG.touches.list)
        {
            if (touch.pressed && touch.x < FlxG.width / 2)
            {
                isJumpingPressed = true;
                break;
            }
        }
        #end

        if (velocity.y < 0 && !isJumpingPressed)
        {
            velocity.y += 50;
        }

        super.update(elapsed);
    }
}