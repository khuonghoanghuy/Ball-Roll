package game.objects;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import game.ballroll.BRButton;

class ShopItemBox extends FlxSpriteGroup
{
    public var boxBg:BRSprite;
    public var titleText:BRText;
    public var descText:BRText;
    public var infoText:BRText;
    
    public var upgradeButton:BRButton;

    public var id:Int;
    public var isSelected:Float = 0;
    public var currentLevel:Int = 1;
    public var maxLevel:Int = 5;

    public function new(x:Float, y:Float, id:Int, title:String)
    {
        super(x, y);
        this.id = id;

        boxBg = new BRSprite(true, 0, 0, "menu/box", 64, 32);
        boxBg.addAnim("idle", [0]);
        boxBg.addAnim("selected", [0, 1, 2, 3], false, 12);
        boxBg.addAnim("deselected", [3, 2, 1, 0], false, 12);
        boxBg.addFinishedWork("deselected", function () {
            boxBg.playAnim("idle"); 
        });
        boxBg.scale.set(4, 4);
        boxBg.updateHitbox();
        add(boxBg);

        var actualWidth:Float = 256;
        var actualHeight:Float = 128;

        titleText = new BRText(15, 10, 0, title, 14);
        titleText.color = FlxColor.YELLOW;
        add(titleText);

        descText = new BRText(15, 38, 220, "Empty Text", 10);
        add(descText);

        infoText = new BRText(15, 90, 0, 'LV: $currentLevel / $maxLevel', 11);
        add(infoText);

        var btnX:Float = actualWidth - 95;
        var btnY:Float = actualHeight - 45;

        upgradeButton = new BRButton(btnX, btnY, "UPGRADE", upgrade);
        upgradeButton.scale.set(1.2, 0.8);
        upgradeButton.updateHitbox();
        upgradeButton.label.setFormat(null, 10, FlxColor.WHITE, CENTER);
        upgradeButton.label.offset.y = -2;
        add(upgradeButton);
    }

    public function select()
    {
        if (isSelected != 1) {
            isSelected = 1;
            boxBg.playAnim("selected");
        }
    }

    public function deselect()
    {
        if (isSelected != 0) {
            isSelected = 0;
            boxBg.playAnim("deselected");
        }
    }

    public function upgrade()
    {
        if (currentLevel < maxLevel) {
            currentLevel++;
            infoText.text = 'LV: $currentLevel / $maxLevel';
        }
    }
}