package txt;

class Interfaces{

}

interface Style {
    public var size:Float;
    public var font:String;
    public var tracking:Float;
    public var characterCase:Float;
    public var fillColor:String;
    public var strokeColor:String;
    public var strokeWidth:Float;
}

interface ConstructObj {
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
}

interface ShapeEvents {
    public var added:EventCallback;
    public var click:EventCallback;
    public var dblclick:EventCallback;
    public var mousedown:EventCallback;
    public var mouseout:EventCallback;
    public var mouseover:EventCallback;
    public var pressmove:EventCallback;
    public var pressup:EventCallback;
    public var removed:EventCallback;
    public var rollout:EventCallback;
    public var rollover:EventCallback;
    public var tick:EventCallback;
}

interface WordEvents {
}

interface LineEvents {
}

interface EventCallback {
}

interface Point {
    public var x:Float;
    public var y:Float;
}

