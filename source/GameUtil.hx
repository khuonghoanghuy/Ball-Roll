package;

import flixel.FlxG;

class GameUtil
{
    public static function lerpInt(current:Float, target:Float, ratio:Float, elapsed:Float):Int
    {
        var nextVal:Float = current + (target - current) * (1 - Math.exp(-ratio * elapsed * 60));
        
        if (Math.abs(target - nextVal) < 0.5) {
            return Std.int(target);
        }
        
        return Std.int(nextVal);
    }
}