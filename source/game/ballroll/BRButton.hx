package game.ballroll;

import flixel.util.FlxColor;
import flixel.ui.FlxButton;

class BRButton extends FlxButton
{
    public function new(x:Float = 0, y:Float = 0, text:String = "", ?onClick:Void->Void) {
        super(x, y, text, onClick);
        loadGraphic(Paths.image("menu/box"), true, 64, 32);
        label.setFormat(Paths.font("Pixeled"), 12, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
    }    
}