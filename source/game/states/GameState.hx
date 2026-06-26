package game.states;

import flixel.FlxG;
import flixel.FlxState;

class GameState extends FlxState
{
    public function new() {
        super();
        openSubState(new TransitionSubState(true));
    }

    /**
        Use this function instead
    **/
    function switchState(state:GameState)
    {
        openSubState(new TransitionSubState(false, function () {
            FlxG.switchState(() -> state);
        }));
        return;
    }
}