package game.states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TransitionSubState extends FlxSubState
{
    var mask:FlxSprite;
    var OnMidpoint:Void->Void;
    var maskCamera:FlxCamera;
    
    var speed:Float = 0.5;
    var isOpeningPhase:Bool = false;

    public function new(isOpening:Bool = false, onMidpoint:Void->Void = null)
    {
        super();
        this.isOpeningPhase = isOpening;
        this.OnMidpoint = onMidpoint;
    }

    override public function create()
    {
        super.create();

        maskCamera = new FlxCamera();
        maskCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(maskCamera, false);

        mask = new FlxSprite();
        mask.makeGraphic(2000, 2000, FlxColor.BLACK);
        mask.screenCenter();
        mask.camera = maskCamera;
        add(mask);

        if (!isOpeningPhase)
        {
            mask.scale.set(0, 0);
            
            FlxTween.tween(mask.scale, {x: 1.5, y: 1.5}, speed, {
                ease: FlxEase.cubeIn,
                onComplete: function(tw:FlxTween) {
                    if (OnMidpoint != null) 
                    {
                        OnMidpoint(); 
                    }
                }
            });
        }
        else
        {
            mask.scale.set(1.5, 1.5);
            
            FlxTween.tween(mask.scale, {x: 0, y: 0}, speed, {
                ease: FlxEase.cubeOut,
                onComplete: function(tw:FlxTween) {
                    close();
                }
            });
        }
    }
}