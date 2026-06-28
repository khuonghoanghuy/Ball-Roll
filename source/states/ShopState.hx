package states;

import game.objects.ShopItemBox;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;

class ShopState extends GameState
{
    var background:FlxSprite = new FlxSprite(0, 0);
    var arrowHint:BRSprite = new BRSprite(true, 0, 0, "menu/arrow hint", 32, 32);
    var bunchBuy:Array<String> = ["Player Health", "Barrier", "Ball Heal"];
    
    var bunchGroup:FlxTypedGroup<ShopItemBox> = new FlxTypedGroup<ShopItemBox>();
    var curSelected:Int = 0;

    var shopGuy:BRSprite = new BRSprite(true, 0, 0, "player/shop guy", 64, 64);

    override function create() 
    {
        super.create();
        background.makeGraphic(FlxG.width, FlxG.height, FlxColor.BROWN);
        background.screenCenter();
        background.updateHitbox();
        add(background);

        arrowHint.addAnim("idle", [0, 1, 2, 3, 4], true, 12);
        arrowHint.playAnim("idle");
        arrowHint.flipX = true;
        arrowHint.alpha = 0;
        arrowHint.scale.set(1.5, 1.5);
        arrowHint.updateHitbox();
        add(arrowHint);

        add(bunchGroup);

        for (i in 0...bunchBuy.length)
        {
            var box:ShopItemBox = new ShopItemBox(100, 100 + (i * 150), i, bunchBuy[i]);
            bunchGroup.add(box);
        }

        shopGuy.addAnim("idle", [0]);
        shopGuy.addAnim("scale", [0, 1, 2, 2, 1, 0]);
        shopGuy.addAnim("jump", [3, 4, 5, 6, 7, 8, 9, 10]);
        shopGuy.addAnim("blink", [11, 12, 11]);
        shopGuy.addAnim("talk", [13, 14]);
        shopGuy.addFinishedWork("jump", function () {
            shopGuy.playAnim("idle"); 
        });
        shopGuy.setupAutoRandom("idle", ["blink", "scale"], 2.0, 5.0);
        shopGuy.scale.set(4.5, 4.5);
        shopGuy.updateHitbox();
        shopGuy.setPosition(866, 277);
        shopGuy.playAnim("idle");
        add(shopGuy);

        changeSelection(0);
    }
    
    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            MenuState.isBackFromShop = true;
            switchState(new MenuState());
        }

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) {
            changeSelection(1);
        }

        bunchGroup.forEach(function(box:ShopItemBox) {
            if (FlxG.mouse.overlaps(box.boxBg)) {
                if (curSelected != box.id) {
                    curSelected = box.id;
                    updateSelectionVisuals();
                }

                @:privateAccess
                box.upgradeButton.updateStatusAnimation(); 
            }
        });

        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            bunchGroup.members[curSelected].upgrade();
        }
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = bunchGroup.length - 1;
        if (curSelected >= bunchGroup.length)
            curSelected = 0;

        updateSelectionVisuals();
    }

    function updateSelectionVisuals()
    {
        bunchGroup.forEach(function(box:ShopItemBox) {
            if (box.id == curSelected) {
                box.select();
                arrowHint.alpha = 1;
                arrowHint.x = box.x - arrowHint.width - 10;
                arrowHint.y = box.y + (box.boxBg.height / 2) - (arrowHint.height / 2);
            } else {
                box.deselect();
            }
        });
    }
}