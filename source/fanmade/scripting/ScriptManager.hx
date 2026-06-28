package fanmade.scripting;

import hscript.Parser;
import hscript.Interp;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import fanmade.utils.FourthWall;
import fanmade.ai.ChatBot;

class ScriptManager {
    public var interp:Interp;
    public var parser:Parser;

    public function new() {
        parser = new Parser();
        interp = new Interp();

        // Allow Lua/JS style "print"
        interp.variables.set("print", function(v:Dynamic) {
            trace("SCRIPT: " + Std.string(v));
        });

        // --- Core Haxe/Flixel Access ---
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("Math", Math);
        interp.variables.set("Std", Std);
        
        // --- Your Custom Addon Access ---
        interp.variables.set("window", FourthWall);
        
        // --- Helper Functions for Scripts ---
        interp.variables.set("spawnSprite", function(x:Float, y:Float, asset:String) {
            var s = new FlxSprite(x, y).loadGraphic(asset);
            FlxG.state.add(s);
            return s;
        });

        interp.variables.set("shake", function(intensity:Float, duration:Float) {
            FlxG.camera.shake(intensity, duration);
        });
    }

    /**
     * Runs a script string. 
     * This works for both .lua and .js style logic!
     */
    public function execute(code:String):Dynamic {
        try {
            var program = parser.parseString(code);
            return interp.execute(program);
        } catch (e:Dynamic) {
            trace("SCRIPT ERROR: " + e);
            return null;
        }
    }

    /**
     * Sets a variable that the script can use (like a ChatBot instance)
     */
    public function setVar(name:String, value:Dynamic):Void {
        interp.variables.set(name, value);
    }
}
