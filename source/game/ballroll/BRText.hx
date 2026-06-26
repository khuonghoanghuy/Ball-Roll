package game.ballroll;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class BRText extends FlxText
{
    public function new(x:Float = 0, y:Float = 0, width:Int = 0, ?text:String = "", ?size:Int = 12, ?align:FlxTextAlign = LEFT) 
    {
        super(x, y, width, text, size);
        font = Paths.font("Pixeled.ttf");
        setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
        alignment = align;
    }
}