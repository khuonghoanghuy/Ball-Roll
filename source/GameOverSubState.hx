package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class GameOverSubState extends FlxSubState
{
    var windowFrame:FlxSprite;
    var titleText:FlxText;
    var statsText:FlxText;
    var highScoreText:FlxText;
    
    var btnRetry:FlxButton;
    var btnMainMenu:FlxButton;

    var finalScore:Int;
    var finalTime:Int;
    var totalHits:Int;
    var coinEarned:Int;
    var penaltyCash:Int;
    var passesTheHighScore:Bool = false;

    public function new(score:Int, time:Int, hits:Int)
    {
        super(FlxColor.fromString("0x7F000000"));

        finalScore = score;
        finalTime = time;
        totalHits = hits;
        
        if (finalScore > FlxG.save.data.highScore) 
        {
            passesTheHighScore = true;
        }
        FlxG.save.data.highScore = Math.max(FlxG.save.data.highScore, finalScore);

        var rawCoins:Int = Math.floor(finalScore / 10) + Math.floor(finalTime / 10);
        penaltyCash = totalHits * 2; 
        coinEarned = rawCoins - penaltyCash;
        if (coinEarned < 0) coinEarned = 0;

        FlxG.save.data.cash += coinEarned;
        FlxG.save.flush();
    }

    override public function create()
    {
        super.create();

        var winWidth:Int = 500;
        var winHeight:Int = 420;

        windowFrame = new FlxSprite(0, 0);
        windowFrame.makeGraphic(winWidth, winHeight, FlxColor.fromRGB(30, 30, 30));
        windowFrame.screenCenter();
        add(windowFrame);

        titleText = new FlxText(windowFrame.x, windowFrame.y + 25, winWidth, "Game Over");
        titleText.setFormat(null, 32, FlxColor.RED, CENTER);
        titleText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        add(titleText);

        if (passesTheHighScore)
        {
            highScoreText = new FlxText(windowFrame.x, windowFrame.y + 75, winWidth, "NEW HIGH SCORE!");
            highScoreText.setFormat(null, 16, FlxColor.YELLOW, CENTER);
            highScoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
            add(highScoreText);
        }

        var statsStr:String = "Final Score: " + finalScore + "\n\n" + 
                                "Time Survived: " + finalTime + "s\n\n" + 
                                "Times Hit: " + totalHits + " (Pentalty: -" + penaltyCash + "$)\n\n" +
                                "Coins Earned: +" + coinEarned + "$";
                              
        statsText = new FlxText(windowFrame.x + 40, windowFrame.y + 115, winWidth - 80, statsStr);
        statsText.setFormat(null, 16, FlxColor.WHITE, CENTER);
        add(statsText);

        var btnWidth:Int = 180;
        var btnHeight:Int = 45;
        var btnY:Float = windowFrame.y + 320;
        var spacingX:Float = 40;
        var startBtnX:Float = windowFrame.x + (winWidth - (btnWidth * 2 + spacingX)) / 2;

        btnRetry = createGameOverButton(startBtnX, btnY, btnWidth, btnHeight, "RETRY", function() {
            openSubState(new TransitionSubState(false, function() {
                FlxG.resetState();
            }));
        });
        add(btnRetry);

        btnMainMenu = createGameOverButton(btnRetry.x + btnWidth + spacingX, btnY, btnWidth, btnHeight, "MAIN MENU", function() {
            openSubState(new TransitionSubState(false, function() {
                FlxG.switchState(() -> new MenuState());
            }));
        });
        add(btnMainMenu);
    }

    function createGameOverButton(x:Float, y:Float, width:Int, height:Int, text:String, onClick:Void->Void):FlxButton
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