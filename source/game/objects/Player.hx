package game.objects;

class Player extends BRSprite
{
    public function new(x:Float = 0, y:Float = 0) 
    {
        super(x, y, "player/og", 32, 32);
        
        addAnim("idle", [0], true);
        addAnim("blink", [0, 1, 2, 0]);
        addAnim("get hurt", [3, 4, 5, 6, 0]);
        addAnim("dead", [7, 8, 9, 10, 11, 12, 13, 14, 15]);

        addFinishedWork("blink", function () {
            playAnim("idle");
        });
        addFinishedWork("get hurt", function () {
            playAnim("idle"); 
        });

        playAnim("idle");
    }    
}