package;

import flixel.FlxG;

class SaveData
{
    /**
     * Only use for Setting, for shader options
     */
    public static var noticeRestart:Bool = false;

    public static function initData()
    {
        FlxG.save.bind("BallRollData");
        FlxG.save.flush();
        noticeRestart = false;

        if (FlxG.save.data.highScore == null)
        {
            FlxG.save.data.highScore = 0;
        }
        if (FlxG.save.data.cash == null)
        {
            FlxG.save.data.cash = 0;
        }

        // Upgrade power up
        if (FlxG.save.data.playerHealth == null)
        {
            FlxG.save.data.playerHealth = 100;
        }
        if (FlxG.save.data.barrier == null)
        {
            FlxG.save.data.barrier = 0;
        }
        if (FlxG.save.data.ballGainHealth == null)
        {
            FlxG.save.data.ballGainHealth = 15;
        }

        // Shop system
        if (FlxG.save.data.healthCost == null)
        {
            FlxG.save.data.healthCost = 250;
        }
        if (FlxG.save.data.ballHealthCost == null)
        {
            FlxG.save.data.ballHealthCost = 100;
        }
        if (FlxG.save.data.barrierCost == null)
        {
            FlxG.save.data.barrierCost = 500;
        }

        // Setting
        if (FlxG.save.data.volume == null) {
            FlxG.save.data.volume = 1.0;
        }
        if (FlxG.save.data.muted == null) {
            FlxG.save.data.muted = false;
        }
        if (FlxG.save.data.shader == null) {
            FlxG.save.data.shader = false;
        }

        FlxG.sound.volume = FlxG.save.data.volume;
        FlxG.sound.muted = FlxG.save.data.muted;
    }
}