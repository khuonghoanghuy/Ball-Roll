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
        add(arrowHint);

        add(bunchGroup);

        for (i in 0...bunchBuy.length)
        {
            var box:ShopItemBox = new ShopItemBox(100, 80 + (i * 150), i, bunchBuy[i]);
            
            if (i == 0) box.descText.text = "Increase maxium player health.";
            if (i == 1) box.descText.text = "Create a barrier to protect player.";
            if (i == 2) box.descText.text = "Heal player when player touch the ball.";

            bunchGroup.add(box);
        }

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