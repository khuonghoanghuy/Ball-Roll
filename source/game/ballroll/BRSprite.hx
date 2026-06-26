package game.ballroll;

import flixel.FlxSprite;

class BRSprite extends FlxSprite
{
    public function new(isAnimated:Bool = true, x:Float = 0, y:Float = 0, sprite:String = null, frameWidth:Int = 0, frameHeight:Int = 0) 
    {
        super(x, y);
        if (isAnimated)
            loadGraphic(Paths.image(sprite), true, frameWidth, frameHeight);
        else
            loadGraphic(Paths.image(sprite), false);
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
}