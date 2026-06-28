package states;

import game.objects.ShopItemBox;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;

class ShopState extends GameState
{
    var background:FlxSprite = new FlxSprite(0, 0);
    var arrowHint:BRSprite = new BRSprite(true, 0, 0, "menu/arrow hint", 32, 32);
    var bunchBuy:Array<String> = ["Player Health", "Barrier", "Ball Heal"];
    
    var bunchGroup:FlxTypedGroup<ShopItemBox> = new FlxTypedGroup<ShopItemBox>();
    var curSelected:Int = 0;
    var descBox:BRSprite = new BRSprite(true, 0, 0, "menu/box", 64, 32);
    var descText:BRText = new BRText(0, 0, 0, "", 12, CENTER);

    var shopGuy:BRSprite = new BRSprite(true, 0, 0, "player/shop guy", 64, 64);
    var tableShop:BRSprite = new BRSprite(false, 0, 0, "menu/table shop");

    var randomMessages:Array<String> = [
        "Welcome to my shop",
        "Please buy something",
        "Buy please, I need money",
        "This is the only shop here man"
    ];

    var currentMessage:String = "";

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
        arrowHint.scale.set(1.75, 1.75);
        arrowHint.updateHitbox();
        add(arrowHint);

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

        tableShop.screenCenter(Y);
        tableShop.scale.set(10, 8);
        tableShop.updateHitbox();
        tableShop.x = FlxG.width - (64 * 10);
        tableShop.y += 100;
        add(tableShop);

        descBox.addAnim("idle", [0]);
        descBox.playAnim("idle");
        descBox.scale.set(8, 7);
        descBox.updateHitbox();
        descBox.setPosition(730, 500);
        add(descBox);

        descText.size = 20;
        descText.setPosition(749, 543);
        descText.alignment = CENTER;
        descText.fieldWidth = descBox.width - 20;
        add(descText);

        add(bunchGroup);

        pickRandomMessage();

        for (i in 0...bunchBuy.length)
        {
            var box:ShopItemBox = new ShopItemBox(100, 120 + (i * 150), i, bunchBuy[i]);
            bunchGroup.add(box);
        }
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
                    updateDescription();
                }

                @:privateAccess
                box.upgradeButton.updateStatusAnimation(); 
            }
        });

        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            bunchGroup.members[curSelected].upgrade();
            updateDescription();
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
        updateDescription();
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

    function pickRandomMessage()
    {
        var randomIndex:Int = Math.floor(Math.random() * randomMessages.length);
        currentMessage = randomMessages[randomIndex];
    }

    function updateDescription()
    {
        if (bunchGroup.members != null && bunchGroup.members.length > 0)
        {
            var selectedBox:ShopItemBox = bunchGroup.members[curSelected];
            var itemName:String = bunchBuy[curSelected];
            var isMaxed:Bool = selectedBox.currentLevel >= selectedBox.maxLevel;
            
            if (isMaxed)
            {
                descText.text = itemName + "\nMAX LEVEL!";
            }
            else
            {
                var description:String = getItemDescription(itemName);
                descText.text = description;
            }
        }
        else
        {
            descText.text = currentMessage;
        }
    }

    function getItemDescription(itemName:String):String
    {
        switch(itemName)
        {
            case "Player Health":
                return "Increase maximum health";
            case "Barrier":
                return "Improve barrier strength";
            case "Ball Heal":
                return "Enhance ball healing";
            default:
                return "Upgrade " + itemName;
        }
    }
}