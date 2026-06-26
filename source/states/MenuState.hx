package states;

import game.objects.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import game.states.GameState;
import flixel.math.FlxRect;

class MenuState extends GameState
{
	var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromString("0x4E91E9"));
	var versionText:BRText = new BRText(20, FlxG.height - 40, 0, "Version Game: " + FlxG.stage.window.application.meta.get("version"), 12, LEFT);
	var player:Player = new Player(100, 100);

	override public function create():Void
	{
		super.create();
		add(background);

		player.scale.set(3, 3);
		player.updateHitbox();
		player.y = FlxG.height * 0.625 - (32 * 3);
		add(player);

		add(versionText);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ONE)
			player.playAnim("blink");
		if (FlxG.keys.justPressed.TWO)
			player.playAnim("get hurt");
	}
}
