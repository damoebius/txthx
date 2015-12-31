package txt;

import txt.Interfaces;
import createjs.easeljs.Container;

@:native("txt.Text")
extern class Text extends Container {

    public var text:String;

    public var lineHeight:Float;

    public var width:Float;

    public var height:Float;

    public var align:Align;

    public var characterCase:Case;

    public var size:Float;

    public var font:String;

    public var tracking:Float;

    public var ligatures:Bool;

    public var fillColor:String;

    public var strokeColor:String;

    public var strokeWidth:Float;

    public var loaderId:Float;

    public var style:Dynamic;

    public var debug:Bool;

    public var original:ConstructObj;

    public var words:Array<Word>;

    public var lines:Array<Line>;

    public var block:Container;

    public var missingGlyphs:Array<Dynamic>;

    public var renderCycle:Bool;

    public var accessibilityText:String;

    public var accessibilityPriority:Float;

    public var accessibilityId:Float;

    public function new(props:ConstructObj = null);

    public function render():Void;

    public function complete():Void;

    public function fontLoaded(font:Dynamic):Void;

    public function layout():Void;

    public function characterLayout():Bool;

    public function wordLayout():Void;

    public function lineLayout():Void;

}

class TextParameters implements ConstructObj{

    public var text:String;

    public var style:Dynamic;

    public var align:Float;

    public var size:Float;

    public var height:Float;

    public var width:Float;

    public var lineHeight:Float;

    public var font:String;

    public var tracking:Float;

    public var characterCase:Float;

    public var fillColor:String;

    public var strokeColor:String;

    public var strokeWidth:Float;

    public var debug:Bool;

    public var character:ShapeEvents;

    public var word:ShapeEvents;

    public var line:ShapeEvents;

    public var block:ShapeEvents;

    public function new(){

    }
}