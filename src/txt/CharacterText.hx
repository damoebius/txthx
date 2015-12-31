package txt;

class CharacterText extends createjs.Container {

    public var text:String = "";

    public var lineHeight:Float = null;

    public var width:Float = 100;

    public var height:Float = 20;

    public var align:Float = txt.Align.TOP_LEFT;

    public var characterCase:Float = txt.Case.NORMAL;

    public var size:Float = 12;

    public var minSize:Float = null;

    public var maxTracking:Float = null;

    public var font:String = "belinda";

    public var tracking:Float = 0;

    public var ligatures:Bool = false;

    public var fillColor:String = "#000";

    public var strokeColor:String = null;

    public var strokeWidth:Float = null;

    public var singleLine:Bool = false;

    public var autoExpand:Bool = false;

    public var autoReduce:Bool = false;

    public var overset:Bool = false;

    public var oversetIndex:Float = null;

    public var loaderId:Float = null;

    public var style:Dynamic = null;

    public var debug:Bool = false;

    public var original:ConstructObj = null;

    public var lines:Dynamic = [];

    public var block:createjs.Container;

    public var missingGlyphs:Dynamic = null;

    public var renderCycle:Bool = true;

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
    }

    public function complete() {
    }

    public function fontLoaded() {
        this.layout();
    }

    public function render() {
        this.getStage().update();
    }

    public function layout() {
        txt.Accessibility.null(this);
        this.overset = false;
        this.measured = false;
        this.oversetPotential = false;
        if (Ts2Hx.isTrue(this.original.size)) {
            this.size = this.original.size;
        }
        if (Ts2Hx.isTrue(this.original.tracking)) {
            this.tracking = this.original.tracking;
        }
        this.text = this.text.replace(/([\n][ \t]+)/g, '\n');
        if (this.singleLine == true) {
            this.text = this.text.split('\n').join('');
            this.text = this.text.split('\r').join('');
        }
        this.lines = [];
        this.missingGlyphs = null;
        this.removeAllChildren();
        if (this.text == "" || this.text == null) {
            this.render();
            this.complete();
            return ;
        }
        this.block = new createjs.Container()
        this.addChild(this.block);
        if (Ts2Hx.areEqual(this.debug, true)) {
            var font:txt.Font = txt.FontLoader.getFont(this.font);
            var s = new createjs.Shape();
            s.graphics.beginStroke("#FF0000");
            s.graphics.setStrokeStyle(1.2);
            s.graphics.drawRect(0, 0, this.width, this.height);
            this.addChild(s);
            s = new createjs.Shape();
            s.graphics.beginFill("#000");
            s.graphics.drawRect(0, 0, this.width, 0.2);
            s.x = 0;
            s.y = 0;
            this.block.addChild(s);
            s = new createjs.Shape();
            s.graphics.beginFill("#F00");
            s.graphics.drawRect(0, 0, this.width, 0.2);
            s.x = 0;
            s.y = -Ts2Hx.getValue(font, 'cap-height') / font.units * this.size;
            this.block.addChild(s);
            s = new createjs.Shape();
            s.graphics.beginFill("#0F0");
            s.graphics.drawRect(0, 0, this.width, 0.2);
            s.x = 0;
            s.y = -font.ascent / font.units * this.size;
            this.block.addChild(s);
            s = new createjs.Shape();
            s.graphics.beginFill("#00F");
            s.graphics.drawRect(0, 0, this.width, 0.2);
            s.x = 0;
            s.y = -font.descent / font.units * this.size;
            this.block.addChild(s);
        }
        if (this.singleLine == true && (this.autoExpand == true || this.autoReduce == true)) {
            this.measure();
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
        this.lineLayout();
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
        if (metricRealWidth > this.width) {
            if (this.autoReduce == true) {
                this.tracking = 0;
                this.size = this.original.size * this.width / (metricRealWidth + (space.offset * space.size));
                if (this.minSize != null && this.size < this.minSize) {
                    this.size = this.minSize;
                    this.oversetPotential = true;
                }
                return true;
            }
        } else {
            var trackMetric = this.offsetTracking((this.width - metricRealWidth) / (len), current.size, current.units);
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

    public function trackingOffset(tracking:Float, size:Float, units:Float):Float {
        return size * (2.5 / units + 1 / 900 + tracking / 990);
    }

    public function offsetTracking(offset:Float, size:Float, units:Float):Float {
        return Math.floor((offset - 2.5 / units - 1 / 900) * 990 / size);
    }

    public function getWidth():Float {
        return this.width;
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
        var vPosition:Float = 0;
        var charKern:Float;
        var tracking:Float;
        var lineY:Float = 0;
        var firstLine:Bool = true;
        var currentLine:Line = new Line();
        this.lines.push(currentLine);
        this.block.addChild(currentLine);
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
            if (Ts2Hx.areEqual(this.text.charAt(i), "\n") || Ts2Hx.areEqual(this.text.charAt(i), "\r")) {
                if (i < len - 1) {
                    if (firstLine == true) {
                        vPosition = currentStyle.size;
                        currentLine.measuredHeight = currentStyle.size;
                        currentLine.measuredWidth = hPosition;
                        lineY = 0;
                        currentLine.y = 0;
                    } else if (this.lineHeight != null) {
                        vPosition = this.lineHeight;
                        currentLine.measuredHeight = vPosition;
                        currentLine.measuredWidth = hPosition;
                        lineY = lineY + vPosition;
                        currentLine.y = lineY;
                    } else {
                        vPosition = char.measuredHeight;
                        currentLine.measuredHeight = vPosition;
                        currentLine.measuredWidth = hPosition;
                        lineY = lineY + vPosition;
                        currentLine.y = lineY;
                    }
                    firstLine = false;
                    currentLine = new Line();
                    currentLine.measuredHeight = currentStyle.size;
                    currentLine.measuredWidth = 0;
                    this.lines.push(currentLine);
                    this.block.addChild(currentLine);
                    vPosition = 0;
                    hPosition = 0;
                }
                if (Ts2Hx.areEqual(this.text.charAt(i), "\r") && Ts2Hx.areEqual(this.text.charAt(i + 1), "\n")) {
                    i++;
                }
                continue;
            }
            if (txt.FontLoader.isLoaded(currentStyle.font) == false) {
                txt.FontLoader.load(this, [currentStyle.font]);
                return false;
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
            if (firstLine == true) {
                if (vPosition < char.size) {
                    vPosition = char.size;
                }
            } else if (this.lineHeight != null && this.lineHeight > 0) {
                if (vPosition < this.lineHeight) {
                    vPosition = this.lineHeight;
                }
            } else if (char.measuredHeight > vPosition) {
                vPosition = char.measuredHeight;
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
            } else if (this.singleLine == false && hPosition + char.measuredWidth > this.width) {
                var lastchar:Character = cast(Ts2Hx.getValue(currentLine.children, currentLine.children.length - 1), txt.Character);
                if (Ts2Hx.areEqual(lastchar.characterCode, 32)) {
                    currentLine.measuredWidth = hPosition - lastchar.measuredWidth - lastchar.trackingOffset() - lastchar._glyph.getKerning(this.getCharCodeAt(i), lastchar.size);
                } else {
                    currentLine.measuredWidth = hPosition - lastchar.trackingOffset() - lastchar._glyph.getKerning(this.getCharCodeAt(i), lastchar.size);
                }
                if (firstLine == true) {
                    currentLine.measuredHeight = vPosition;
                    currentLine.y = 0;
                    lineY = 0;
                } else {
                    currentLine.measuredHeight = vPosition;
                    lineY = lineY + vPosition;
                    currentLine.y = lineY;
                }
                firstLine = false;
                currentLine = new Line();
                currentLine.addChild(char);
                if (Ts2Hx.areEqual(char.characterCode, 32)) {
                    hPosition = 0;
                } else {
                    hPosition = char.x + (char._glyph.offset * char.size) + char.characterCaseOffset + char.trackingOffset();
                }
                this.lines.push(currentLine);
                this.block.addChild(currentLine);
                vPosition = 0;
            } else if (Ts2Hx.areEqual(this.measured, true) && this.singleLine == true && hPosition + char.measuredWidth > this.width && Ts2Hx.areEqual(this.oversetPotential, true)) {
                this.oversetIndex = i;
                this.overset = true;
            } else if (Ts2Hx.areEqual(this.measured, false) && this.singleLine == true && hPosition + char.measuredWidth > this.width) {
                this.oversetIndex = i;
                this.overset = true;
            } else {
                char.x = hPosition;
                currentLine.addChild(char);
                hPosition = char.x + (char._glyph.offset * char.size) + char.characterCaseOffset + char.trackingOffset() + char._glyph.getKerning(this.getCharCodeAt(i + 1), char.size);
            }
            i++;
        }
        if (Ts2Hx.areEqual(currentLine.children.length, 0)) {
            var lw = this.lines.pop();
            currentLine = Ts2Hx.getValue(this.lines, this.lines.length - 1);
            hPosition = currentLine.measuredWidth;
            vPosition = currentLine.measuredHeight;
        }
        if (firstLine == true) {
            currentLine.measuredWidth = hPosition;
            currentLine.measuredHeight = vPosition;
            currentLine.y = 0;
        } else {
            currentLine.measuredWidth = hPosition;
            currentLine.measuredHeight = vPosition;
            if (Ts2Hx.areEqual(vPosition, 0)) {
                if ((this.lineHeight != 0 && this.lineHeight == this.lineHeight)) {
                    vPosition = this.lineHeight;
                } else {
                    vPosition = currentStyle.size;
                }
            }
            currentLine.y = lineY + vPosition;
        }
        return true;
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

    public function lineLayout() {
        var blockHeight:Int = 0;
        var measuredWidth:Int = 0;
        var measuredHeight:Int = 0;
        var line;
        var a = txt.Align;
        var fnt:txt.Font = txt.FontLoader.getFont(this.font);
        var aHeight = this.size * fnt.ascent / fnt.units;
        var cHeight = this.size * Ts2Hx.getValue(fnt, 'cap-height') / fnt.units;
        var xHeight = this.size * Ts2Hx.getValue(fnt, 'x-height') / fnt.units;
        var dHeight = this.size * fnt.descent / fnt.units;
        var len = this.lines.length;
        var i:Int = 0;
        while (i < len) {
            line = this.lines[i];
            if (line.lastCharacter()) {
                line.measuredWidth -= line.lastCharacter().trackingOffset();
            }
            if (Ts2Hx.isTrue(this.original.line)) {
                if (Ts2Hx.isTrue(this.original.line.added)) {
                    line.on('added', this.original.line.added);
                }
                if (Ts2Hx.isTrue(this.original.line.click)) {
                    line.on('click', this.original.line.click);
                }
                if (Ts2Hx.isTrue(this.original.line.dblclick)) {
                    line.on('dblclick', this.original.line.dblclick);
                }
                if (Ts2Hx.isTrue(this.original.line.mousedown)) {
                    line.on('mousedown', this.original.line.mousedown);
                }
                if (Ts2Hx.isTrue(this.original.line.mouseout)) {
                    line.on('mouseout', this.original.line.mouseout);
                }
                if (Ts2Hx.isTrue(this.original.line.mouseover)) {
                    line.on('mouseover', this.original.line.mouseover);
                }
                if (Ts2Hx.isTrue(this.original.line.pressmove)) {
                    line.on('pressmove', this.original.line.pressmove);
                }
                if (Ts2Hx.isTrue(this.original.line.pressup)) {
                    line.on('pressup', this.original.line.pressup);
                }
                if (Ts2Hx.isTrue(this.original.line.removed)) {
                    line.on('removed', this.original.line.removed);
                }
                if (Ts2Hx.isTrue(this.original.line.rollout)) {
                    line.on('rollout', this.original.line.rollout);
                }
                if (Ts2Hx.isTrue(this.original.line.rollover)) {
                    line.on('rollover', this.original.line.rollover);
                }
                if (Ts2Hx.isTrue(this.original.line.tick)) {
                    line.on('tick', this.original.line.tick);
                }
            }
            measuredHeight += line.measuredHeight;
            if (this.align == a.TOP_CENTER) {
                line.x = (this.width - line.measuredWidth) / 2;
            } else if (this.align == a.TOP_RIGHT) {
                line.x = (this.width - line.measuredWidth);
            } else if (this.align == a.MIDDLE_CENTER) {
                line.x = (this.width - line.measuredWidth) / 2;
            } else if (this.align == a.MIDDLE_RIGHT) {
                line.x = (this.width - line.measuredWidth);
            } else if (this.align == a.BOTTOM_CENTER) {
                line.x = (this.width - line.measuredWidth) / 2;
            } else if (this.align == a.BOTTOM_RIGHT) {
                line.x = (this.width - line.measuredWidth);
            }
            i++;
        }
        if (this.align == a.TOP_LEFT || this.align == a.TOP_CENTER || this.align == a.TOP_RIGHT) {
            if (Ts2Hx.areEqual(fnt.top, 0)) {
                this.block.y = this.lines[0].measuredHeight * fnt.ascent / fnt.units;
            } else {
                this.block.y = this.lines[0].measuredHeight * fnt.ascent / fnt.units + this.lines[0].measuredHeight * fnt.top / fnt.units;
            }
        } else if (this.align == a.MIDDLE_LEFT || this.align == a.MIDDLE_CENTER || this.align == a.MIDDLE_RIGHT) {
            this.block.y = this.lines[0].measuredHeight + (this.height - measuredHeight) / 2 + this.lines[0].measuredHeight * fnt.middle / fnt.units;
        } else if (this.align == a.BOTTOM_LEFT || this.align == a.BOTTOM_CENTER || this.align == a.BOTTOM_RIGHT) {
            this.block.y = this.height - Ts2Hx.getValue(this.lines, this.lines.length - 1).y + this.lines[0].measuredHeight * fnt.bottom / fnt.units;
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
    }

}


//# lineMapping=1,1,3,3,5,4,7,6,9,7,11,8,13,9,15,10,17,11,19,12,21,13,23,14,25,15,27,16,29,17,31,18,33,19,35,20,37,21,39,22,41,23,43,24,45,25,47,26,49,27,51,28,53,29,55,30,57,31,59,32,61,33,63,34,65,35,67,38,69,39,71,40,72,42,73,44,74,45,75,46,76,47,77,48,78,49,79,50,80,51,81,52,82,53,83,54,84,54,85,55,86,56,87,57,88,58,89,59,90,54,91,60,92,61,93,62,96,66,99,69,100,70,103,75,104,76,107,81,108,82,109,85,110,87,111,88,112,90,113,91,114,92,115,93,116,94,117,95,118,96,119,98,120,99,121,100,122,101,123,102,124,104,125,105,126,107,127,108,128,109,130,111,131,112,132,114,133,118,134,120,135,122,136,123,137,124,138,125,139,126,140,127,141,130,142,131,143,132,144,133,145,134,146,135,147,137,148,138,149,139,150,140,151,141,152,142,153,144,154,145,155,146,156,147,157,148,158,149,159,151,160,152,161,153,162,154,163,155,164,156,165,158,166,159,167,160,168,162,169,163,170,164,172,166,173,168,174,169,176,171,177,172,178,173,179,174,182,177,183,178,184,184,185,185,186,186,187,187,188,188,189,189,190,190,191,191,192,192,193,193,194,194,195,195,196,196,197,197,198,200,199,198,200,201,201,203,202,205,203,206,204,208,205,209,206,210,207,211,208,212,209,213,210,214,211,215,212,216,213,220,214,221,215,222,216,223,217,224,218,225,219,226,220,227,221,228,222,200,223,229,224,233,225,234,226,235,227,236,228,237,229,238,230,239,231,240,232,241,233,242,234,243,235,245,236,250,237,252,238,254,239,256,240,259,241,257,242,260,243,261,244,262,245,263,246,259,247,265,248,269,249,270,250,271,251,272,252,273,253,274,254,275,255,276,256,278,257,279,258,280,259,282,260,283,261,284,262,285,263,287,264,288,265,289,266,290,267,291,268,292,269,293,270,295,271,296,272,298,273,299,274,300,275,301,276,302,277,303,278,304,279,306,280,307,281,308,282,309,285,312,286,313,289,316,290,317,293,320,294,321,297,325,298,330,299,331,300,332,301,333,302,334,303,335,304,336,305,337,306,338,307,339,308,340,309,341,310,342,311,343,312,344,313,345,314,346,315,347,316,349,317,350,318,352,319,356,320,353,321,358,322,359,323,361,324,362,325,363,326,364,327,365,328,366,329,367,330,368,331,374,332,377,333,378,334,379,335,380,336,381,337,382,338,383,339,384,340,385,341,386,342,387,343,388,344,389,345,390,346,391,347,392,348,393,349,394,350,395,351,396,352,397,353,399,354,400,355,401,356,402,357,403,358,404,359,405,360,406,361,408,362,409,363,410,365,413,366,416,367,417,368,418,369,419,370,420,371,424,372,425,373,426,374,427,375,428,376,429,377,430,378,431,379,432,380,433,381,434,382,435,383,436,384,437,385,438,386,439,387,440,388,441,389,442,390,443,391,444,392,445,393,446,394,447,395,448,396,449,397,450,398,451,399,452,400,453,401,454,402,455,403,456,404,457,405,458,406,459,407,460,408,461,409,464,410,465,411,466,412,467,413,468,414,468,415,468,416,468,417,468,418,469,419,471,420,473,421,474,422,475,423,476,424,478,425,479,426,480,427,481,428,482,429,483,430,487,431,489,432,490,433,492,434,494,435,496,436,497,437,499,438,500,439,501,440,503,441,504,442,505,443,506,444,508,445,509,446,510,447,511,448,512,449,514,451,516,452,517,453,518,454,519,455,520,456,521,457,522,458,523,459,524,460,525,461,526,462,527,463,528,464,529,465,530,466,531,467,532,468,533,469,534,470,536,471,537,472,538,473,539,474,540,475,541,476,543,477,544,478,545,479,548,480,552,481,553,482,557,483,560,484,561,485,564,486,565,487,567,488,568,489,356,490,569,491,572,492,573,493,574,494,575,495,576,496,577,497,579,498,580,499,581,500,582,501,583,502,584,503,585,504,586,505,587,506,588,507,589,508,590,509,591,510,592,511,593,512,594,513,595,516,598,517,599,518,600,519,601,520,603,521,604,522,606,523,607,524,609,525,610,526,612,527,613,530,617,531,620,532,621,533,622,535,624,536,625,537,626,538,627,539,628,540,629,541,631,542,632,543,632,544,633,545,637,546,638,547,639,548,641,549,642,550,643,551,644,552,645,553,646,554,647,555,648,556,649,557,650,558,651,559,652,560,653,561,654,562,655,563,656,564,657,565,658,566,659,567,660,568,661,569,662,570,663,571,664,572,665,573,666,574,667,575,668,576,669,577,670,578,671,579,672,580,673,581,674,582,675,583,676,584,677,585,678,586,679,587,682,588,683,589,685,590,686,591,688,592,689,593,691,594,692,595,694,596,695,597,697,598,698,599,700,600,632,601,701,602,704,603,705,604,706,605,707,606,708,607,709,608,710,609,713,610,714,611,717,612,718,613,720,614,721,615,722,616,723,617,724,618,725,619,726,620,727,621,728,622,729,623,730,624,731,625,732,626,733,627,734,628,735,629,736,630,737,631,738,632,739,633,740,634,741,635,742,636,743,637,744,638,745,639,746,640,747,641,748,642,749,643,750,644,751,645,752,646,753,647,754,648,755,649,756,650,757,653,759