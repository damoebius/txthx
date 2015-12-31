package txt;

enum VerticalAlign {
    Top;
    CapHeight;
    Center;
    BaseLine;
    Bottom;
    XHeight;
    Ascent;
    Percent;
}

;
class PathText extends createjs.Container {

    public var text:String = "";

    public var characterCase:Float = txt.Case.NORMAL;

    public var size:Float = 12;

    public var font:String = "belinda";

    public var tracking:Float = 0;

    public var ligatures:Bool = false;

    public var minSize:Float = null;

    public var maxTracking:Float = null;

    public var fillColor:String = "#000";

    public var strokeColor:String = null;

    public var strokeWidth:Float = null;

    public var style:Dynamic = null;

    public var debug:Bool = false;

    public var characters:Dynamic;

    public var block:createjs.Container;

    public var original:ConstructObj = null;

    public var autoExpand:Bool = false;

    public var autoReduce:Bool = false;

    public var overset:Bool = false;

    public var oversetIndex:Float = null;

    public var pathPoints:txt.Path = null;

    public var path:String = "";

    public var start:Float = 0;

    public var end:Float = null;

    public var flipped:Bool = false;

    public var fit:PathFit = txt.PathFit.Rainbow;

    public var align:PathAlign = txt.PathAlign.Center;

    public var valign:VerticalAlign = txt.VerticalAlign.BaseLine;

    public var missingGlyphs:Dynamic = null;

    public var renderCycle:Bool = true;

    public var valignPercent:Float = 1;

    public var initialTracking:Float = 0;

    public var initialOffset:Float = 0;

    public var measured:Bool = false;

    public var oversetPotential:Bool = false;

    public var accessibilityText:String = null;

    public var accessibilityPriority:Float = 2;

    public var accessibilityId:Float = null;

    public function new(props:ConstructObj = null) {
        super();
        if (Ts2Hx.isTrue(props)) {
            this.original = props;
            this.null(props);
            this.original.tracking = this.tracking;
        }
        if (this.style == null) {
            txt.FontLoader.load(this, [this.font]);
        } else {
            var fonts:Array<Dynamic> = [this.font];
            var styleLength = this.style.length;
            var i:Int = 0;
            while (i < styleLength) {
                if (this.style[i] != null) {
                    if (this.style[i].font != null) {
                        fonts.push(this.style[i].font);
                    }
                }
                ++i;
            }
            txt.FontLoader.load(this, fonts);
        }
        this.pathPoints = new txt.Path(this.path, this.start, this.end, this.flipped, this.fit, this.align);
    }

    public function complete() {
    }

    public function setPath(path:String) {
        this.path = path;
        this.pathPoints.path = this.path;
        this.pathPoints.update();
    }

    public function setStart(start:Float) {
        this.start = start;
        this.pathPoints.start = this.start;
        this.pathPoints.update();
    }

    public function setEnd(end:Float) {
        this.end = end;
        this.pathPoints.end = this.end;
        this.pathPoints.update();
    }

    public function setFlipped(flipped:Bool) {
        this.flipped = flipped;
        this.pathPoints.flipped = this.flipped;
        this.pathPoints.update();
    }

    public function setFit(fit:txt.PathFit = txt.PathFit.Rainbow) {
        this.fit = fit;
        this.pathPoints.fit = this.fit;
        this.pathPoints.update();
    }

    public function setAlign(align:PathAlign = txt.PathAlign.Center) {
        this.align = align;
        this.pathPoints.align = this.align;
        this.pathPoints.update();
    }

    public function fontLoaded() {
        this.layout();
    }

    public function render() {
        this.getStage().update();
    }

    public function getWidth():Float {
        return this.pathPoints.realLength;
    }

    public function layout() {
        txt.Accessibility.null(this);
        this.overset = false;
        this.oversetIndex = null;
        this.removeAllChildren();
        this.characters = [];
        this.missingGlyphs = null;
        this.measured = false;
        this.oversetPotential = false;
        if (Ts2Hx.areEqual(this.debug, true)) {
            var s = new createjs.Shape();
            s.graphics.beginStroke("#FF0000");
            s.graphics.setStrokeStyle(0.1);
            s.graphics.decodeSVGPath(this.path);
            s.graphics.endFill();
            s.graphics.endStroke();
            this.addChild(s);
            s = new createjs.Shape();
            var pp = this.pathPoints.getRealPathPoint(0);
            s.x = pp.x;
            s.y = pp.y;
            s.graphics.beginFill("black");
            s.graphics.drawCircle(0, 0, 2);
            this.addChild(s);
            s = new createjs.Shape();
            var pp = this.pathPoints.getRealPathPoint(this.pathPoints.start);
            s.x = pp.x;
            s.y = pp.y;
            s.graphics.beginFill("green");
            s.graphics.drawCircle(0, 0, 2);
            this.addChild(s);
            s = new createjs.Shape();
            pp = this.pathPoints.getRealPathPoint(this.pathPoints.end);
            s.x = pp.x;
            s.y = pp.y;
            s.graphics.beginFill("red");
            s.graphics.drawCircle(0, 0, 2);
            this.addChild(s);
            s = new createjs.Shape();
            pp = this.pathPoints.getRealPathPoint(this.pathPoints.center);
            s.x = pp.x;
            s.y = pp.y;
            s.graphics.beginFill("blue");
            s.graphics.drawCircle(0, 0, 2);
            this.addChild(s);
        }
        if (this.text == "" || this.text == null) {
            this.render();
            return ;
        }
        this.block = new createjs.Container()
        this.addChild(this.block);
        if (this.autoExpand == true || this.autoReduce == true) {
            if (this.measure() == false) {
                this.removeAllChildren();
                return ;
            }
        }
        if (this.renderCycle == false) {
            this.removeAllChildren();
            this.complete();
            return ;
        }
        if (this.characterLayout() == false) {
            this.removeAllChildren();
            return ;
        }
        this.render();
        this.complete();
    }

    public function measure():Bool {
        this.measured = true;
        var size = this.original.size;
        var len = this.text.length;
        var width = this.getWidth();
        var defaultStyle = {
            size: this.original.size,
            font: this.original.font,
            tracking: this.original.tracking,
            characterCase: this.original.characterCase
        };
        var currentStyle:Dynamic;
        var charCode:Float = null;
        var font:txt.Font;
        var charMetrics:Array<Int> = [];
        var largestFontSize = defaultStyle.size;
        var i:Int = 0;
        while (i < len) {
            charCode = this.text.charCodeAt(i);
            currentStyle = defaultStyle;
            if (this.original.style != null && this.original.style[i] != null) {
                currentStyle = this.original.style[i];
                if (currentStyle.size == null) currentStyle.size = defaultStyle.size;
                if (currentStyle.font == null) currentStyle.font = defaultStyle.font;
                if (currentStyle.tracking == null) currentStyle.tracking = defaultStyle.tracking;
            }
            if (currentStyle.size > largestFontSize) {
                largestFontSize = currentStyle.size;
            }
            font = Ts2Hx.getValue(txt.FontLoader.fonts, currentStyle.font);
            charMetrics.push({
                char: this.text[i],
                size: currentStyle.size,
                charCode: charCode,
                font: currentStyle.font,
                offset: font.glyphs[cast(charCode, Int)].offset,
                units: font.units,
                tracking: this.trackingOffset(currentStyle.tracking, currentStyle.size, font.units),
                kerning: font.glyphs[cast(charCode, Int)].getKerning(this.getCharCodeAt(i + 1), 1)
            });
            i++;
        }
        var space:Dynamic = {
            char: " ",
            size: currentStyle.size,
            charCode: 32,
            font: currentStyle.font,
            offset: font.glyphs[32].offset,
            units: font.units,
            tracking: 0,
            kerning: 0
        };
        charMetrics[cast(charMetrics.length - 1, Int)].tracking = 0;
        len = charMetrics.length;
        var metricBaseWidth:Int = 0;
        var metricRealWidth:Int = 0;
        var metricRealWidthTracking:Int = 0;
        var current = null;
        var i:Int = 0;
        while (i < len) {
            current = charMetrics[i];
            metricBaseWidth = metricBaseWidth + current.offset + current.kerning;
            metricRealWidth = metricRealWidth + ((current.offset + current.kerning) * current.size);
            metricRealWidthTracking = metricRealWidthTracking + ((current.offset + current.kerning + current.tracking) * current.size);
            i++;
        }
        if (metricRealWidth > width) {
            if (this.autoReduce == true) {
                this.tracking = 0;
                this.size = this.original.size * width / (metricRealWidth + (space.offset * space.size));
                if (this.minSize != null && this.size < this.minSize) {
                    this.size = this.minSize;
                    if (this.renderCycle == false) {
                        this.overset = true;
                    } else {
                        this.oversetPotential = true;
                    }
                }
                return true;
            }
        } else {
            var trackMetric = this.offsetTracking((width - metricRealWidth) / (len), current.size, current.units);
            if (trackMetric < 0) {
                trackMetric = 0;
            }
            if (trackMetric > this.original.tracking && this.autoExpand) {
                if (this.maxTracking != null && trackMetric > this.maxTracking) {
                    this.tracking = this.maxTracking;
                } else {
                    this.tracking = trackMetric;
                }
                this.size = this.original.size;
                return true;
            }
            if (trackMetric < this.original.tracking && this.autoReduce) {
                if (this.maxTracking != null && trackMetric > this.maxTracking) {
                    this.tracking = this.maxTracking;
                } else {
                    this.tracking = trackMetric;
                }
                this.size = this.original.size;
                return true;
            }
        }
        return true;
    }

    public function characterLayout():Bool {
        var len = this.text.length;
        var char:Character;
        var defaultStyle = {
            size: this.size,
            font: this.font,
            tracking: this.tracking,
            characterCase: this.characterCase,
            fillColor: this.fillColor,
            strokeColor: this.strokeColor,
            strokeWidth: this.strokeWidth
        };
        var currentStyle = defaultStyle;
        var hPosition:Float = 0;
        var charKern:Float;
        var tracking:Float;
        var angle:Float;
        var i:Int = 0;
        while (i < len) {
            if (this.style != null && this.style[i] != null) {
                currentStyle = this.style[i];
                if (currentStyle.size == null) currentStyle.size = defaultStyle.size;
                if (currentStyle.font == null) currentStyle.font = defaultStyle.font;
                if (currentStyle.tracking == null) currentStyle.tracking = defaultStyle.tracking;
                if (currentStyle.characterCase == null) currentStyle.characterCase = defaultStyle.characterCase;
                if (currentStyle.fillColor == null) currentStyle.fillColor = defaultStyle.fillColor;
                if (currentStyle.strokeColor == null) currentStyle.strokeColor = defaultStyle.strokeColor;
                if (currentStyle.strokeWidth == null) currentStyle.strokeWidth = defaultStyle.strokeWidth;
            }
            if (Ts2Hx.areEqual(this.text.charAt(i), "\n")) {
                continue;
            }
            if (txt.FontLoader.isLoaded(currentStyle.font) == false) {
                txt.FontLoader.load(this, [currentStyle.font]);
                return false;
            }
            if (Ts2Hx.areEqual(hPosition, 0)) {
                hPosition = this.initialOffset + this.trackingOffset(this.initialTracking, currentStyle.size, txt.FontLoader.getFont(currentStyle.font).units);
            }
            char = new Character(this.text.charAt(i), currentStyle, i);
            if (Ts2Hx.isTrue(this.original.character)) {
                if (Ts2Hx.isTrue(this.original.character.added)) {
                    char.on('added', this.original.character.added);
                }
                if (Ts2Hx.isTrue(this.original.character.click)) {
                    char.on('click', this.original.character.click);
                }
                if (Ts2Hx.isTrue(this.original.character.dblclick)) {
                    char.on('dblclick', this.original.character.dblclick);
                }
                if (Ts2Hx.isTrue(this.original.character.mousedown)) {
                    char.on('mousedown', this.original.character.mousedown);
                }
                if (Ts2Hx.isTrue(this.original.character.mouseout)) {
                    char.on('mouseout', this.original.character.mouseout);
                }
                if (Ts2Hx.isTrue(this.original.character.mouseover)) {
                    char.on('mouseover', this.original.character.mouseover);
                }
                if (Ts2Hx.isTrue(this.original.character.pressmove)) {
                    char.on('pressmove', this.original.character.pressmove);
                }
                if (Ts2Hx.isTrue(this.original.character.pressup)) {
                    char.on('pressup', this.original.character.pressup);
                }
                if (Ts2Hx.isTrue(this.original.character.removed)) {
                    char.on('removed', this.original.character.removed);
                }
                if (Ts2Hx.isTrue(this.original.character.rollout)) {
                    char.on('rollout', this.original.character.rollout);
                }
                if (Ts2Hx.isTrue(this.original.character.rollover)) {
                    char.on('rollover', this.original.character.rollover);
                }
                if (Ts2Hx.isTrue(this.original.character.tick)) {
                    char.on('tick', this.original.character.tick);
                }
            }
            if (Ts2Hx.isTrue(char.missing)) {
                if (this.missingGlyphs == null) {
                    this.missingGlyphs = [];
                }
                this.missingGlyphs.push({
                    position: i,
                    character: this.text.charAt(i),
                    font: currentStyle.font
                });
            }
            if (Ts2Hx.areEqual(currentStyle.tracking, 0) && Ts2Hx.areEqual(this.ligatures, true)) {
                var ligTarget = this.text.substr(i, 4);
                if (Ts2Hx.isTrue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)))) {
                    if (Ts2Hx.isTrue(Ts2Hx.getValue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)), ligTarget.charAt(1)))) {
                        if (Ts2Hx.isTrue(Ts2Hx.getValue(Ts2Hx.getValue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)), ligTarget.charAt(1)), ligTarget.charAt(2)))) {
                            if (Ts2Hx.isTrue(Ts2Hx.getValue(Ts2Hx.getValue(Ts2Hx.getValue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)), ligTarget.charAt(1)), ligTarget.charAt(2)), ligTarget.charAt(3)))) {
                                char.setGlyph(Ts2Hx.getValue(Ts2Hx.getValue(Ts2Hx.getValue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)), ligTarget.charAt(1)), ligTarget.charAt(2)), ligTarget.charAt(3)).glyph);
                                i = i + 3;
                            } else {
                                char.setGlyph(Ts2Hx.getValue(Ts2Hx.getValue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)), ligTarget.charAt(1)), ligTarget.charAt(2)).glyph);
                                i = i + 2;
                            }
                        } else {
                            char.setGlyph(Ts2Hx.getValue(Ts2Hx.getValue(char._font.ligatures, ligTarget.charAt(0)), ligTarget.charAt(1)).glyph);
                            i = i + 1;
                        }
                    }
                }
            }
            if (Ts2Hx.areEqual(this.overset, true)) {
                break;
            } else if (Ts2Hx.areEqual(this.measured, true) && hPosition + char.measuredWidth > this.getWidth() && Ts2Hx.areEqual(this.oversetPotential, true)) {
                this.oversetIndex = i;
                this.overset = true;
                break;
            } else if (Ts2Hx.areEqual(this.measured, false) && hPosition + char.measuredWidth > this.getWidth()) {
                this.oversetIndex = i;
                this.overset = true;
                break;
            } else {
                char.hPosition = hPosition;
                this.characters.push(char);
                this.block.addChild(char);
            }
            hPosition = hPosition + (char._glyph.offset * char.size) + char.characterCaseOffset + char.trackingOffset() + char._glyph.getKerning(this.getCharCodeAt(i + 1), char.size);
            i++;
        }
        len = this.characters.length;
        var pathPoint:Dynamic;
        var nextRotation:Bool = false;
        i = 0;
        while (i < len) {
            char = cast(this.characters[i], txt.Character);
            pathPoint = this.pathPoints.getPathPoint(char.hPosition, hPosition, char._glyph.offset * char.size);
            if (Ts2Hx.areEqual(nextRotation, true)) {
                Ts2Hx.getValue(this.characters, i - 1).parent.rotation = pathPoint.rotation;
                nextRotation = false;
            }
            if (Ts2Hx.areEqual(pathPoint.next, true)) {
                nextRotation = true;
            }
            char.rotation = pathPoint.rotation;
            if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.BaseLine)) {
                char.x = pathPoint.x;
                char.y = pathPoint.y;
                if (Ts2Hx.isTrue(pathPoint.offsetX)) {
                    var offsetChild = new createjs.Container();
                    offsetChild.x = pathPoint.x
                    offsetChild.y = pathPoint.y
                    offsetChild.rotation = pathPoint.rotation;
                    char.parent.removeChild(char);
                    offsetChild.addChild(char);
                    char.x = pathPoint.offsetX;
                    char.y = 0;
                    char.rotation = 0;
                    this.addChild(offsetChild);
                } else {
                    char.x = pathPoint.x;
                    char.y = pathPoint.y;
                    char.rotation = pathPoint.rotation;
                }
            } else {
                var offsetChild = new createjs.Container();
                offsetChild.x = pathPoint.x
                offsetChild.y = pathPoint.y
                offsetChild.rotation = pathPoint.rotation;
                char.parent.removeChild(char);
                offsetChild.addChild(char);
                char.x = 0;
                if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.Top)) {
                    char.y = char.size;
                } else if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.Bottom)) {
                    char.y = char._font.descent / char._font.units * char.size;
                } else if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.CapHeight)) {
                    char.y = Ts2Hx.getValue(char._font, 'cap-height') / char._font.units * char.size;
                } else if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.XHeight)) {
                    char.y = Ts2Hx.getValue(char._font, 'x-height') / char._font.units * char.size;
                } else if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.Ascent)) {
                    char.y = char._font.ascent / char._font.units * char.size;
                } else if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.Center)) {
                    char.y = Ts2Hx.getValue(char._font, 'cap-height') / char._font.units * char.size / 2;
                } else if (Ts2Hx.areEqual(this.valign, txt.VerticalAlign.Percent)) {
                    char.y = this.valignPercent * char.size;
                } else {
                    char.y = 0;
                }
                char.rotation = 0;
                this.addChild(offsetChild);
            }
            i++;
        }
        if (Ts2Hx.isTrue(this.original.block)) {
            if (Ts2Hx.isTrue(this.original.block.added)) {
                this.block.on('added', this.original.block.added);
            }
            if (Ts2Hx.isTrue(this.original.block.click)) {
                this.block.on('click', this.original.block.click);
            }
            if (Ts2Hx.isTrue(this.original.block.dblclick)) {
                this.block.on('dblclick', this.original.block.dblclick);
            }
            if (Ts2Hx.isTrue(this.original.block.mousedown)) {
                this.block.on('mousedown', this.original.block.mousedown);
            }
            if (Ts2Hx.isTrue(this.original.block.mouseout)) {
                this.block.on('mouseout', this.original.block.mouseout);
            }
            if (Ts2Hx.isTrue(this.original.block.mouseover)) {
                this.block.on('mouseover', this.original.block.mouseover);
            }
            if (Ts2Hx.isTrue(this.original.block.pressmove)) {
                this.block.on('pressmove', this.original.block.pressmove);
            }
            if (Ts2Hx.isTrue(this.original.block.pressup)) {
                this.block.on('pressup', this.original.block.pressup);
            }
            if (Ts2Hx.isTrue(this.original.block.removed)) {
                this.block.on('removed', this.original.block.removed);
            }
            if (Ts2Hx.isTrue(this.original.block.rollout)) {
                this.block.on('rollout', this.original.block.rollout);
            }
            if (Ts2Hx.isTrue(this.original.block.rollover)) {
                this.block.on('rollover', this.original.block.rollover);
            }
            if (Ts2Hx.isTrue(this.original.block.tick)) {
                this.block.on('tick', this.original.block.tick);
            }
        }
        return true;
    }

    public function trackingOffset(tracking:Float, size:Float, units:Float):Float {
        return size * (2.5 / units + 1 / 900 + tracking / 990);
    }

    public function offsetTracking(offset:Float, size:Float, units:Float):Float {
        return Math.floor((offset - 2.5 / units - 1 / 900) * 990 / size);
    }

    public function getCharCodeAt(index:Float):Float {
        if (Ts2Hx.areEqual(this.characterCase, txt.Case.NORMAL)) {
            return this.text.charAt(index).charCodeAt(0);
        } else if (Ts2Hx.areEqual(this.characterCase, txt.Case.UPPER)) {
            return this.text.charAt(index).toUpperCase().charCodeAt(0);
        } else if (Ts2Hx.areEqual(this.characterCase, txt.Case.LOWER)) {
            return this.text.charAt(index).toLowerCase().charCodeAt(0);
        } else if (Ts2Hx.areEqual(this.characterCase, txt.Case.SMALL_CAPS)) {
            return this.text.charAt(index).toUpperCase().charCodeAt(0);
        } else {
            return this.text.charAt(index).charCodeAt(0);
        }
    }

}


//# lineMapping=1,1,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,15,14,17,15,19,17,21,18,23,19,25,20,27,21,29,22,31,23,33,24,35,25,37,26,39,27,41,28,43,29,45,30,47,31,49,32,51,33,53,34,55,35,57,36,59,37,61,38,63,39,65,40,67,41,69,42,71,43,73,44,75,45,77,46,79,47,81,48,83,49,85,50,87,51,89,55,91,56,93,57,94,60,95,62,96,63,97,64,98,65,99,66,100,67,101,68,102,69,103,70,104,71,105,72,106,72,107,73,108,74,109,75,110,76,111,77,112,72,113,78,114,79,115,80,116,81,119,85,122,87,123,88,124,89,125,90,128,93,129,94,130,95,131,96,134,99,135,100,136,101,137,102,140,105,141,106,142,107,143,108,146,111,147,112,148,113,149,114,152,117,153,118,154,119,155,120,158,123,159,124,162,127,163,128,166,131,167,132,170,135,171,136,172,139,173,140,174,141,175,142,176,143,177,144,178,145,179,146,180,148,181,149,182,150,183,151,184,152,185,153,186,154,187,155,188,157,189,158,190,159,191,160,192,161,193,162,194,163,195,165,196,166,197,167,198,168,199,169,200,170,201,171,202,173,203,174,204,175,205,176,206,177,207,178,208,179,209,181,210,182,211,183,212,184,213,185,214,186,215,187,216,189,217,190,219,192,220,193,221,195,222,197,223,198,224,199,226,201,227,202,228,204,229,205,230,206,232,208,233,210,234,211,236,213,237,214,238,215,241,218,242,219,243,225,244,226,245,227,246,228,247,229,248,230,249,231,250,232,251,233,252,234,253,235,254,236,255,237,256,238,257,241,258,239,259,242,260,244,261,246,262,247,263,249,264,250,265,251,266,252,267,253,268,254,269,255,270,256,271,257,272,261,273,262,274,263,275,264,276,265,277,266,278,267,279,268,280,269,281,241,282,270,283,274,284,275,285,276,286,277,287,278,288,279,289,280,290,281,291,282,292,283,293,284,294,286,295,291,296,293,297,295,298,297,299,300,300,298,301,301,302,302,303,303,304,304,305,300,306,306,307,318,308,319,309,320,310,321,311,322,312,323,313,324,314,325,315,326,316,327,317,328,318,329,319,331,320,332,321,333,322,335,323,336,324,337,325,338,326,340,327,341,328,342,329,343,330,344,331,345,332,346,333,348,334,349,335,351,336,352,337,353,338,354,339,355,340,356,341,357,342,359,343,360,344,361,345,362,348,366,349,368,350,369,351,370,352,371,353,372,354,373,355,374,356,375,357,376,358,377,359,378,360,379,361,380,362,381,363,382,364,383,365,387,366,384,367,389,368,390,369,392,370,393,371,394,372,395,373,396,374,397,375,398,376,399,377,402,379,404,380,408,381,409,382,410,383,411,384,414,385,415,386,416,387,417,388,420,389,421,390,422,391,423,392,424,393,425,394,426,395,427,396,428,397,429,398,430,399,431,400,432,401,433,402,434,403,435,404,436,405,437,406,438,407,439,408,440,409,441,410,442,411,443,412,444,413,445,414,446,415,447,416,448,417,449,418,450,419,451,420,452,421,453,422,454,423,455,424,456,425,457,426,460,427,461,428,462,429,463,430,464,431,464,432,464,433,464,434,464,435,465,436,469,437,471,438,472,439,474,440,476,441,478,442,479,443,481,444,482,445,483,446,485,447,486,448,487,449,488,450,490,451,491,452,492,453,493,454,494,455,502,457,504,458,505,459,511,461,513,462,515,463,521,465,523,466,525,467,526,468,527,469,528,470,529,471,387,472,532,473,534,474,538,475,539,476,540,477,540,478,541,479,542,480,546,481,547,482,548,483,549,484,550,485,551,486,552,487,553,488,557,489,558,490,559,491,562,492,563,493,564,494,565,495,566,496,567,497,568,498,569,499,570,500,571,501,572,502,573,503,574,504,575,505,576,506,577,507,579,508,581,509,582,510,583,511,584,512,585,513,586,514,587,515,590,516,591,517,592,518,594,519,595,520,597,521,598,522,600,523,601,524,603,525,604,526,606,527,607,528,609,529,610,530,612,531,613,532,614,533,615,534,616,535,540,536,618,537,620,538,621,539,622,540,623,541,624,542,625,543,626,544,627,545,628,546,629,547,630,548,631,549,632,550,633,551,634,552,635,553,636,554,637,555,638,556,639,557,640,558,641,559,642,560,643,561,644,562,645,563,646,564,647,565,648,566,649,567,650,568,651,569,652,570,653,571,654,572,655,573,656,574,657,575,659,578,663,579,664,582,667,583,668,586,671,587,672,588,673,589,674,590,676,591,677,592,679,593,680,594,682,595,683,596,686,597,687,600,689