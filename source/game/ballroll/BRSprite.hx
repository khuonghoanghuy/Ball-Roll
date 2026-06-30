package game.ballroll;

import flixel.FlxSprite;
import flixel.FlxG;

class BRSprite extends FlxSprite
{
    var randomAnims:Array<String> = [];
    var idleAnimName:String = "idle";
    var randomTimer:Float = 0;
    var nextRandomTime:Float = 0;
    var isRandomActive:Bool = false;
    var minRandomTime:Float = 2.0;
    var maxRandomTime:Float = 5.0;

    public function new(isAnimated:Bool = true, x:Float = 0, y:Float = 0, sprite:String = null, frameWidth:Int = 0, frameHeight:Int = 0) 
    {
        super(x, y);
        if (sprite != null)
        {
            if (isAnimated)
                loadGraphic(Paths.image(sprite), true, frameWidth, frameHeight);
            else
                loadGraphic(Paths.image(sprite), false);
        }
    }    

    public function addAnim(name:String, array:Array<Int>, looped:Bool = false, fps:Int = 12)
        return animation.add(name, array, fps, looped);

    public function playAnim(name:String, force:Bool = false)
        return animation.play(name, force);

    public function addFinishedWork(nameToWork:String, work:Void->Void)
        return animation.onFinish.add(function (name:String) {
            if (name == nameToWork)
                work();
        });

    public function setupAutoRandom(idleAnim:String = "idle", animsList:Array<String>, minTime:Float = 2.0, maxTime:Float = 5.0)
    {
        idleAnimName = idleAnim;
        randomAnims = animsList;
        minRandomTime = minTime;
        maxRandomTime = maxTime;
        isRandomActive = true;
        
        nextRandomTime = FlxG.random.float(minRandomTime, maxRandomTime);

        for (anim in randomAnims)
        {
            addFinishedWork(anim, function() {
                playAnim(idleAnimName);
            });
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (isRandomActive && randomAnims.length > 0)
        {
            if (animation.curAnim != null && animation.curAnim.name != idleAnimName)
            {
                randomTimer = 0;
                return;
            }

            randomTimer += elapsed;

            if (randomTimer >= nextRandomTime)
            {
                randomTimer = 0;
                nextRandomTime = FlxG.random.float(minRandomTime, maxRandomTime);

                var pickedAnim:String = FlxG.random.getObject(randomAnims);
                playAnim(pickedAnim);
            }
        }
    }
}