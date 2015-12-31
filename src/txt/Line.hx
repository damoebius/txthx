package txt;

import createjs.easeljs.Container;

@:native("txt.Line")
extern class Line extends Container {

    public var measuredWidth:Float;

    public var measuredHeight:Float;

    public function new();

    public function lastWord():Word;

    public function lastCharacter():Character;

}