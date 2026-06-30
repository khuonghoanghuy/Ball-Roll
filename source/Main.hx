package;

import game.data.SaveData;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import game.counter.MemoryCounter;

class Main extends Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = states.MenuState;
	var framerate:Int = 60;
	var skipSplash:Bool = false;
	var startFullscreen:Bool = false;

	public static var fpsOverlay:FPS;
	public static var memoryOverlay:MemoryCounter;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		FlxGraphic.defaultPersist = true;
		SaveData.init();

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		fpsOverlay = new FPS(10, 8, 0xFFFFFF);
		addChild(fpsOverlay);

		memoryOverlay = new MemoryCounter(10, 20);
		addChild(memoryOverlay);

		FlxG.autoPause = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;
		FlxG.log.redirectTraces = true;
	}
}
