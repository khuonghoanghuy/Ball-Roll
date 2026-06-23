package;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class SettingSubState extends FlxSubState {
    var windowFrame:FlxSprite;
    var titleText:FlxText;
    var versionText:FlxText;
    var closeButton:FlxButton;
    var items:Array<SettingItem> = [];
    var restartNoticeText:FlxText;
    
    static final WIN_WIDTH:Int = 520;
    static final WIN_HEIGHT:Int = 430;
    static final ITEM_HEIGHT:Int = 70;
    static final ITEM_SPACING:Int = 10;

    public function new() {
        super(FlxColor.fromString("0x7F000000"));
    }

    override function create() {
        super.create();
        SettingConfig.init();
        
        createWindow();
        createTitle();
        createSettings();
        createRestartNotice();
        createFooter();
        createCloseButton();
    }
    
    function createWindow():Void {
        windowFrame = new FlxSprite(0, 0);
        windowFrame.makeGraphic(WIN_WIDTH, WIN_HEIGHT, FlxColor.fromRGB(30, 30, 30));
        windowFrame.screenCenter();
        windowFrame.alpha = 0.95;
        add(windowFrame);
    }
    
    function createTitle():Void {
        titleText = new FlxText(windowFrame.x, windowFrame.y + 18, WIN_WIDTH, "Setting");
        titleText.setFormat(null, 24, FlxColor.YELLOW, CENTER);
        titleText.bold = true;
        titleText.borderStyle = OUTLINE;
        titleText.borderColor = FlxColor.BLACK;
        titleText.borderSize = 2;
        add(titleText);
    }
    
    function createSettings():Void {
        var startY:Float = windowFrame.y + 70;
        var x:Float = windowFrame.x + 20;
        var width:Int = WIN_WIDTH - 40;
        
        for (i in 0...SettingConfig.ITEMS.length) {
            var config = SettingConfig.ITEMS[i];
            var y = startY + (i * (ITEM_HEIGHT + ITEM_SPACING));
            
            var item = new SettingItem(x, y, width, ITEM_HEIGHT, config);
            add(item);
            items.push(item);
        }
    }
    
    function createRestartNotice():Void {
        restartNoticeText = new FlxText(windowFrame.x + 20, windowFrame.y + WIN_HEIGHT - 70, WIN_WIDTH - 40, "");
        restartNoticeText.setFormat(null, 13, FlxColor.YELLOW, CENTER);
        restartNoticeText.bold = true;
        
        if (SaveData.noticeRestart) {
            restartNoticeText.text = "Restart required for changes to take effect";
            restartNoticeText.color = FlxColor.ORANGE;
        }
        add(restartNoticeText);
    }
    
    function createFooter():Void {
        var versionStr = "Version: " + FlxG.stage.application.meta.get("version");
        versionText = new FlxText(windowFrame.x + 20, windowFrame.y + WIN_HEIGHT - 35, WIN_WIDTH - 40, versionStr);
        versionText.setFormat(null, 12, FlxColor.GRAY, RIGHT);
        add(versionText);
    }
    
    function createCloseButton():Void {
        var btnY = windowFrame.y + WIN_HEIGHT - 95;
        
        closeButton = new FlxButton(
            windowFrame.x + (WIN_WIDTH - 160) / 2,
            btnY,
            "Close",
            closeSettings
        );
        closeButton.setGraphicSize(160, 36);
        closeButton.updateHitbox();
        closeButton.label.setFormat(null, 14, FlxColor.BLACK, CENTER);
        closeButton.label.bold = true;
        closeButton.label.offset.set(-38, -5);
        add(closeButton);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (restartNoticeText != null) {
            if (SaveData.noticeRestart) {
                restartNoticeText.text = "Restart required for changes to take effect";
                restartNoticeText.color = FlxColor.ORANGE;
                restartNoticeText.visible = true;
            } else {
                restartNoticeText.visible = false;
            }
        }

        if (SaveData.noticeRestart) {
            closeButton.y = windowFrame.y + WIN_HEIGHT - 115;
        }
        
        if (FlxG.keys.justPressed.ESCAPE) {
            closeSettings();
        }
    }

    function closeSettings():Void {
        FlxG.save.flush();
        FlxTween.globalManager.active = true;

        if (SaveData.noticeRestart) {
            openSubState(new TransitionSubState(false, function () {
                SaveData.noticeRestart = false;
                FlxG.resetState();
            }));
        } else {
            SaveData.noticeRestart = false;
            close();
        }
    }
}