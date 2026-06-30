package states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import game.objects.Player;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.data.SaveData;
import game.data.Options;
import flixel.util.FlxColor;

class SettingState extends GameState
{
    var options:Array<Options> = [
        new Options("Shader", "Toggle Shader to make game more better", Toggle, SaveData.settings.shader),
        new Options("Mute", "Toggle to mute completely music and sound (Adjust the volume will be ignored)", Toggle, SaveData.settings.muted)
    ];
    var groupOptions:FlxTypedGroup<BRText> = new FlxTypedGroup<BRText>();
    var curSelected:Int = 0;
    var descText:BRText = new BRText(0, FlxG.height * 0.1, FlxG.width * 0.9, "", 24, CENTER);
    var arrowHint:BRSprite = new BRSprite(true, 0, 0, "menu/arrow hint", 32, 32);
    var floor:BRSprite = new BRSprite(false);

    var playerRoll:Player = new Player(FlxG.width + 100, 0);

    override function create() {
        super.create();

        bgColor = FlxColor.GRAY;
        add(groupOptions);

        var titleText:BRText = new BRText(0, 20, FlxG.width, "SETTING", 48, CENTER);
        titleText.color = FlxColor.WHITE;
        add(titleText);

        arrowHint.addAnim("idle", [0, 1, 2, 3, 4], true, 12);
        arrowHint.playAnim("idle");
        arrowHint.flipX = true;
        arrowHint.scale.set(1.75, 1.75);
        arrowHint.updateHitbox();
        add(arrowHint);        

        for (i in 0...options.length) {
            var optionTxt:BRText = new BRText(100, 150 + (i * 50), 0, options[i].toString(), 32, LEFT);
            optionTxt.ID = i;
            groupOptions.add(optionTxt);
        }

        floor.makeGraphic(FlxG.width, 25, FlxColor.GRAY.getDarkened(0.25));
        floor.y = FlxG.height - 25;
        add(floor);

        playerRoll.angle = 720;
        playerRoll.y = floor.y + 32;
        someMoveA();
        add(playerRoll);
        
        updateSelectionVisuals();
        updateDescription();
    }

    function someMoveA() 
    {
        FlxTween.tween(playerRoll, {x: -100, angle: 0}, 12, {ease: FlxEase.linear, onComplete: function (tween:FlxTween) {
            someMoveB();
        }});
    }

    function someMoveB() 
    {
        FlxTween.tween(playerRoll, {x: FlxG.width + 100, angle: 720}, 12, {ease: FlxEase.linear, onComplete: function (tween:FlxTween) {
            someMoveA();
        }});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) {
            changeSelection(1);
        }
        
        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
            changeOptionValue(-1);
        }
        if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) {
            changeOptionValue(1);
        }

        groupOptions.forEach(function(option:BRText) {
            if (FlxG.mouse.overlaps(option)) {
                if (curSelected != option.ID) {
                    curSelected = option.ID;
                    updateSelectionVisuals();
                    updateDescription();
                }
            }
        });

        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            var opt:Options = options[curSelected];
            switch (opt.type) {
                case OptionType.Function:
                    opt.execute();
                default:
                    opt.changeValue();
                    updateOptionTexts();
                    updateDescription();
                    // Save when toggling
                    SaveData.saveSettings();
            }
        }

        if (FlxG.keys.justPressed.ESCAPE) {
            SaveData.saveSettings();
            switchState(new MenuState());
        }
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        
        if (curSelected < 0)
            curSelected = options.length - 1;
        if (curSelected >= options.length)
            curSelected = 0;
        
        updateSelectionVisuals();
        updateDescription();
    }

    function changeOptionValue(direction:Int = 0) {
        var opt:Options = options[curSelected];
        opt.changeValue(direction);
        updateOptionTexts();
        updateDescription();
        // Save when changing values
        SaveData.saveSettings();
    }

    function updateSelectionVisuals() {
        groupOptions.forEach(function(option:BRText) {
            if (option.ID == curSelected) {
                arrowHint.alpha = 1;
                arrowHint.x = option.x - arrowHint.width - 10;
                arrowHint.y = (option.y + (option.height / 2) - (arrowHint.height / 2)) + 5;
            }
        });
    }

    function updateOptionTexts() {
        groupOptions.forEach(function(option:BRText) {
            var opt:Options = options[option.ID];
            option.text = opt.toString();
            option.updateHitbox();
        });
    }

    function updateDescription() {
        var opt:Options = options[curSelected];
        descText.text = opt.desc;
    }
}