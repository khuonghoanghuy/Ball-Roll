package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import openfl.Assets;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;
import flixel.FlxState;

class Main extends Sprite
{
    public static var chromaticShader:FlxRuntimeShader;

    public function new()
    {
        super();
        addChild(new FlxGame(0, 0, MenuState, 60, 60, false, false));
        FlxG.sound.soundTrayEnabled = false;
		FlxG.sound.volumeDownKeys = FlxG.sound.volumeUpKeys = null;
		FlxG.sound.muteKeys = null;

        SaveData.initData();
        
        chromaticShader = new FlxRuntimeShader(Assets.getText(AssetPaths.chromatic__frag));
        chromaticShader.setFloatArray("enabled", [1.0, 1.0]); 
        chromaticShader.setFloatArray("mouseFocusPoint", [0.5, 0.5]); 

		if (FlxG.save.data.shader && FlxG.camera != null) {
            FlxG.camera.filters = [new ShaderFilter(chromaticShader)];
        }

        FlxG.signals.preStateSwitch.add(onStateSwitch);

        #if debug
        FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxSprite, ["x", "y", "frameWidth", "frameHeight", "alpha", "origin", "offset", "scale"], [FlxObject]));
        #end
    }

    private function onStateSwitch():Void
    {
        FlxG.signals.postStateSwitch.addOnce(function() {
			if (FlxG.save.data.shader && FlxG.camera != null && chromaticShader != null) {
                FlxG.camera.filters = [new ShaderFilter(chromaticShader)];
            } else if (FlxG.camera != null) {
                FlxG.camera.filters = [];
            }
        });
    }
}