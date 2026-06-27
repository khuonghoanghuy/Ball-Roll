package game.ballroll;

import flixel.ui.FlxButton;

class BRButton extends FlxButton
{
    public function new(x:Float = 0, y:Float = 0, text:String = "", ?onClick:Void->Void) {
        super(x, y, text, onClick);
        loadGraphic(Paths.image("menu/box"), true, 64, 32);
    }    
}