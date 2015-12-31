package txt;

import js.html.XMLHttpRequest;

@:native("txt.Font")
extern class Font {

    public var glyphs:Dynamic;

    public var kerning:Dynamic;

    public var missing:Float;

    public var offset:Float;

    public var descent:Float;

    public var ascent:Float;

    public var top:Float;

    public var middle:Float;

    public var bottom:Float;

    public var units:Float;

    public var id:String;

    public var ligatures:Dynamic;

    public var panose:String;

    public var alphabetic:String;

    public var loaded:Bool;

    public var targets:Array<Float>;

    public var loader:XMLHttpRequest;

    public function cloneGlyph(target:Float, __from:Float):Glyph;

}