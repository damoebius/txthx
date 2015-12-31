package txt;

import createjs.easeljs.Container;

@:native("txt.Word")
extern class Word extends Container {

    public var hasNewLine:Bool;

    public var hasHyphen:Bool;

    public var hasSpace:Bool;

    public var measuredWidth:Float;

    public var measuredHeight:Float;

    public var spaceOffset:Float;

    public function new();

    public function lastCharacter():Character;

}