package txt;

import js.html.CanvasRenderingContext2D;
import createjs.easeljs.Shape;

@:native("txt.Character")
extern class Character extends Shape {

    public var character:String;

    public var characterCode:Float;

    public var font:String;

    public var tracking:Float;

    public var characterCase:Float;

    public var characterCaseOffset:Float;

    public var index:Float;

    public var size:Float;

    public var fillColor:String;

    public var strokeColor:String;

    public var strokeWidth:Float;

    public var measuredWidth:Float;

    public var measuredHeight:Float;

    public var hPosition:Float;

    public var missing:Bool;

    public var _glyph:Glyph;

    public var _font:Font;

    public function new(character:String, style:Dynamic, index:Float = null, glyph:Glyph = null);

    public function setGlyph(glyph:Glyph):Void;

    public function trackingOffset():Float;

    public function getWidth():Float;

}