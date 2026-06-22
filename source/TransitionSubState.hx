package;

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
    var quiteTheMusic:Bool = false;

    public function new(isOpening:Bool = false, onMidpoint:Void->Void = null, quiteTheMusic:Bool = false)
    {
        super();
        this.isOpeningPhase = isOpening;
        this.OnMidpoint = onMidpoint;
        this.quiteTheMusic = quiteTheMusic;
    }

    override public function create()
    {
        super.create();

        maskCamera = new FlxCamera();
        maskCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(maskCamera, false);

        mask = new FlxSprite();
        mask.loadGraphic(AssetPaths.black__png);
        mask.screenCenter();
        mask.camera = maskCamera;
        add(mask);

        if (!isOpeningPhase)
        {
            mask.scale.set(0, 0);
            
            FlxTween.tween(mask.scale, {x: 1.5, y: 1.5}, speed, {
                ease: FlxEase.cubeIn,
                onComplete: function(tw:FlxTween) {
                    if (quiteTheMusic)
                    {
                        if (FlxG.sound.music != null)
                        {
                            FlxG.sound.music.fadeOut(0.5, function(tweener) {
                                if (OnMidpoint != null)
                                {
                                    OnMidpoint();
                                }
                            });
                        }
                    }
                    else if (!quiteTheMusic)
                    {
                        if (OnMidpoint != null) 
                        {
                            OnMidpoint(); 
                        }
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