package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.FlxButton;

class ChooseYourDeviceState extends FlxState
{
    var desktopButton:FlxSprite;
    var mobileButton:FlxSprite;

    override function create() 
    {
        super.create();
        bgColor = FlxColor.fromRGB(30, 30, 30);

        var text:FlxText = new FlxText(0, 80, 0, "Choose Your Device", 32);
        text.screenCenter(X);
        text.setFormat(null, 32, FlxColor.YELLOW, CENTER);
        text.bold = true;
        text.borderStyle = OUTLINE;
        text.borderColor = FlxColor.BLACK;
        text.borderSize = 2;
        add(text);

        desktopButton = new FlxSprite(0, 0);
        desktopButton.loadGraphic(AssetPaths.game_device_mode__png, true, 64, 64);
        desktopButton.animation.add("desktop", [0]);
        desktopButton.animation.play("desktop");
        desktopButton.scale.set(3, 3);
        desktopButton.updateHitbox();
        desktopButton.screenCenter();
        desktopButton.x -= 150;
        desktopButton.y -= 20;
        add(desktopButton);

        mobileButton = new FlxSprite(0, 0);
        mobileButton.loadGraphic(AssetPaths.game_device_mode__png, true, 64, 64);
        mobileButton.animation.add("mobile", [1]);
        mobileButton.animation.play("mobile");
        mobileButton.scale.set(3, 3);
        mobileButton.updateHitbox();
        mobileButton.screenCenter();
        mobileButton.x += 150;
        mobileButton.y -= 20;
        add(mobileButton);

        var desktopLabel:FlxText = new FlxText(0, 0, 0, "Desktop", 16);
        desktopLabel.setFormat(null, 16, FlxColor.WHITE, CENTER);
        desktopLabel.screenCenter(X);
        desktopLabel.x -= 150;
        desktopLabel.y = desktopButton.y + desktopButton.height + 10;
        add(desktopLabel);

        var mobileLabel:FlxText = new FlxText(0, 0, 0, "Mobile", 16);
        mobileLabel.setFormat(null, 16, FlxColor.WHITE, CENTER);
        mobileLabel.screenCenter(X);
        mobileLabel.x += 150;
        mobileLabel.y = mobileButton.y + mobileButton.height + 10;
        add(mobileLabel);
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(desktopButton)) {
            if (FlxG.mouse.justPressed)
            {
                FlxG.save.data.gameplayMode = "desktop";
                processToMenuBtw();
            }
        }

        if (FlxG.mouse.overlaps(mobileButton)) {
            if (FlxG.mouse.justPressed)
            {
                FlxG.save.data.gameplayMode = "mobile";
                processToMenuBtw();
            }
        }
    }

    function processToMenuBtw() 
    {
        FlxG.switchState(() -> new MenuState());    
    }
}