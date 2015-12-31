package txt;

import js.html.CanvasRenderingContext2D;
import createjs.easeljs.Graphics;
@:native("txt.Glyph")
extern class Glyph {

    public var path:String;

    public var offset:Float;

    public var kerning:Dynamic;

    private var _graphic:Graphics;

    public var _fill:Dynamic;

    public var _stroke:Dynamic;

    public var _strokeStyle:Dynamic;

    public function graphic():Graphics;

    public function draw(ctx:CanvasRenderingContext2D):Bool;

    public function getKerning(characterCode:Float, size:Float):Float;

}