package;

import flixel.FlxG;

class GameModeHelper
{
    public static function isMobileMode():Bool
    {
        #if mobile
        return true;
        #else
        return FlxG.save.data.gameplayMode == "mobile";
        #end
    }

    public static function isDesktopMode():Bool
    {
        #if mobile
        return false;
        #else
        return FlxG.save.data.gameplayMode == "desktop";
        #end
    }

    public static function getPlatform():String
    {
        #if mobile
        return "mobile";
        #elseif desktop
        return "desktop";
        #else
        return FlxG.save.data.gameplayMode;
        #end
    }
}