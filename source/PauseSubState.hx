package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PauseSubState extends FlxSubState
{
    var windowFrame:FlxSprite;
    var titleText:FlxText;
    var btnResume:FlxButton;
    var btnSetting:FlxButton;
    var btnQuit:FlxButton;

    public function new() 
    {
        super(FlxColor.fromString("0x7F000000"));
    }

    override function create() 
    {
        super.create();

        var winWidth:Int = 450;
        var winHeight:Int = 380;

        windowFrame = new FlxSprite(0, 0);
        windowFrame.makeGraphic(winWidth, winHeight, FlxColor.fromRGB(30, 30, 30));
        windowFrame.screenCenter();
        add(windowFrame);

        titleText = new FlxText(windowFrame.x, windowFrame.y + 25, winWidth, "GAME PAUSED");
        titleText.setFormat(null, 28, FlxColor.YELLOW, CENTER);
        titleText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        add(titleText);

        var btnWidth:Int = 280;
        var btnHeight:Int = 45;
        var startY:Float = windowFrame.y + 100;
        var spacingY:Float = 65;

        btnResume = createPauseButton(windowFrame.x + (winWidth - btnWidth) / 2, startY, btnWidth, btnHeight, "RESUME", function() {
            close();
        });
        add(btnResume);

        btnSetting = createPauseButton(windowFrame.x + (winWidth - btnWidth) / 2, startY + spacingY, btnWidth, btnHeight, "SETTINGS", function() {
            openSubState(new SettingSubState());
        });
        add(btnSetting);

        btnQuit = createPauseButton(windowFrame.x + (winWidth - btnWidth) / 2, startY + (spacingY * 2), btnWidth, btnHeight, "QUIT TO MENU", function() {
            openSubState(new TransitionSubState(false, function() {
                FlxG.switchState(() -> new MenuState());
            }));
        });
        add(btnQuit);
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER)
        {
            close();
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            openSubState(new TransitionSubState(false, function() {
                FlxG.switchState(() -> new MenuState());
            }));
        }
    }

    function createPauseButton(x:Float, y:Float, width:Int, height:Int, text:String, onClick:Void->Void):FlxButton
    {
        var btn = new FlxButton(x, y, text, onClick);
        btn.setGraphicSize(width, height);
        btn.updateHitbox();
        btn.label.width = width;
        btn.label.fieldWidth = width;
        btn.label.setFormat(null, 14, FlxColor.BLACK, CENTER);
        btn.label.offset.y = -(height - btn.label.height) / 2;
        return btn;
    }
}