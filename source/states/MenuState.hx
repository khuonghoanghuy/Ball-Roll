package states;

import game.data.SaveData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import game.objects.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import game.states.GameState;

class MenuState extends GameState
{
	var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromString("0x4E91E9"));
	var versionText:BRText = new BRText(20, FlxG.height - 40, 0, "Version Game: " + FlxG.stage.window.application.meta.get("version"), 12, LEFT);
	var player:Player = new Player(100, 100);
	var floor:BRSprite = new BRSprite(false, 0, FlxG.height * 0.625, "background/grass floor");
	var logo:BRSprite = new BRSprite(false, 0, 0, "menu/logo");

	var arrowShop:BRSprite = new BRSprite(true, 0, 0, "menu/arrow hint", 32, 32);
	var shopText:BRText = new BRText(0, 0, 0, "PRESS LEFT TO OPEN SHOP", 12, LEFT);

	var arrowPlay:BRSprite = new BRSprite(true, 0, 0, "menu/arrow hint", 32, 32);
	var playText:BRText = new BRText(0, 0, 0, "PRESS RIGHT TO PLAY", 12, RIGHT);

	public static var isBackFromShop:Bool = false;
	var syncTime:Float = 1.5;
	var stopKey:Bool = false;

	override public function create():Void
	{
		SaveData.init();

		super.create();
		add(background);

		floor.scale.set(10, 5);
		floor.updateHitbox();
		add(floor);

		player.scale.set(3, 3);
		player.screenCenter(X);
		player.updateHitbox();
		player.y = floor.y - (32 * 3);

		logo.updateHitbox();
		logo.screenCenter();
		logo.setPosition(402, 38);

		if (isBackFromShop) {
			stopKey = true;
			player.x = -200;
			player.angle = -360;
			logo.y = -logo.height - 50;

			FlxTween.tween(logo, {y: 38}, 0.8 * syncTime, {ease: FlxEase.cubeOut, onComplete: function(t:FlxTween) {
				startLogoAnimation();
			}});

			FlxTween.tween(player, {x: 524, angle: 0}, 0.8 * syncTime, {
				ease: FlxEase.backOut,
				onComplete: function (tween:FlxTween) {
					isBackFromShop = false;
					stopKey = false;
				}
			});
		} else {
			player.x -= 100;
			startLogoAnimation();
		}
		add(player);
		add(logo);

		arrowShop.addAnim("idle", [0, 1, 2, 3, 4], true, 8);
		arrowShop.playAnim("idle", true);
		arrowShop.scale.set(4, 4);
		arrowShop.screenCenter(Y);
		arrowShop.updateHitbox();
		arrowShop.x += 100;
		arrowShop.y -= 75;
		add(arrowShop);

		shopText.x = 50;
		shopText.y = arrowShop.y + arrowShop.height - 45;
		add(shopText);

		startArrowAnimation(arrowShop, shopText);

		arrowPlay.addAnim("idle", [0, 1, 2, 3, 4], true, 8);
		arrowPlay.playAnim("idle", true);
		arrowPlay.scale.set(4, 4);
		arrowPlay.screenCenter(Y);
		arrowPlay.updateHitbox();
		arrowPlay.flipX = true;
		arrowPlay.x = FlxG.width - 200;
		arrowPlay.y -= 75;
		add(arrowPlay);

		playText.x = FlxG.width - 250;
		playText.y = arrowPlay.y + arrowPlay.height - 45;
		add(playText);

		startArrowAnimation(arrowPlay, playText);

		add(versionText);
	}

	function startLogoAnimation() {
		FlxTween.cancelTweensOf(logo);
		logo.y = 38;

		FlxTween.tween(logo, {y: 38 + 15}, 1 * syncTime, {
			ease: FlxEase.sineInOut, 
			type: PINGPONG
		});
	}

	function startArrowAnimation(arrow:BRSprite, text:BRText) 
	{
		FlxTween.cancelTweensOf(arrow);
		FlxTween.cancelTweensOf(text);
		var baseArrowY:Float = arrow.y;
		var baseTextY:Float = text.y;

		FlxTween.tween(arrow, {y: baseArrowY + 5}, 1.25 * syncTime, {
			ease: FlxEase.sineInOut, 
			type: PINGPONG
		});
		FlxTween.tween(text, {y: baseTextY + 5}, 1.25 * syncTime, {
			startDelay: 0.25,
			ease: FlxEase.sineInOut, 
			type: PINGPONG
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!stopKey)
		{
			if (FlxG.keys.justPressed.ONE)
				player.playAnim("blink");
			if (FlxG.keys.justPressed.TWO)
				player.playAnim("get hurt");

			if (FlxG.keys.justPressed.LEFT)
			{
				woaMoveToShop();
			}
		}
	}

	function woaMoveToShop()
	{
		stopKey = true;
		FlxTween.cancelTweensOf(logo);
		FlxTween.cancelTweensOf(player);

		FlxTween.cancelTweensOf(arrowShop);
		FlxTween.cancelTweensOf(shopText);
		FlxTween.cancelTweensOf(arrowPlay);
		FlxTween.cancelTweensOf(playText);

		var targetLogoY:Float = 38;

		FlxTween.tween(logo, {y: targetLogoY + 15}, 0.25 * syncTime, {ease: FlxEase.sineIn, onComplete: function (tween:FlxTween) {
			FlxTween.tween(logo, {y: -logo.height - 50}, 0.65 * syncTime, {ease: FlxEase.cubeIn});
		}});

		FlxTween.tween(arrowShop, {alpha: 0, y: arrowShop.y + 20}, 0.4 * syncTime, {ease: FlxEase.sineIn});
		FlxTween.tween(shopText, {alpha: 0, y: shopText.y + 20}, 0.4 * syncTime, {ease: FlxEase.sineIn});
		FlxTween.tween(arrowPlay, {alpha: 0, y: arrowPlay.y + 20}, 0.4 * syncTime, {ease: FlxEase.sineIn});
		FlxTween.tween(playText, {alpha: 0, y: playText.y + 20}, 0.4 * syncTime, {ease: FlxEase.sineIn});

		FlxTween.tween(player, {x: -200, angle: -720}, 0.55 * syncTime, {
			ease: FlxEase.backIn, 
			startDelay: 0.05 * syncTime,
			onComplete: function (tween:FlxTween) {
				switchState(new ShopState());
			}
		});
	}
}