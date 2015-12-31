package txt;

enum PathFit {
    Rainbow;
    Stairstep;
}

;
interface PathPoint {
    public var x:Float;
    public var y:Float;
    public var rotation?:Float;
    public var offsetX?:Float;
}

enum PathAlign {
    Center;
    Right;
    Left;
}

;
class Path {

    private var pathElement:SVGPathElement = null;

    public var path:String = null;

    public var start:Float = 0;

    public var center:Float = null;

    public var end:Float = null;

    public var angles:Dynamic = null;

    public var flipped:Bool = false;

    public var fit:PathFit = txt.PathFit.Rainbow;

    public var align:PathAlign = txt.PathAlign.Center;

    public var length:Float = null;

    public var realLength:Float = null;

    public var closed:Bool = false;

    public var clockwise:Bool = true;

    public function new(path:String, start:Float = 0, end:Float = null, flipped:Bool = false, fit:PathFit = txt.PathFit.Rainbow, align:PathAlign = txt.PathAlign.Center) {
        this.path = path;
        this.start = start;
        this.align = align;
        this.end = end;
        this.flipped = flipped;
        this.fit = fit;
        this.update();
    }

    public function update() {
        this.pathElement = cast(document.createElementNS("http://www.w3.org/2000/svg", "path"), SVGPathElement);
        this.pathElement.setAttributeNS(null, "d", this.path);
        this.length = this.pathElement.getTotalLength();
        this.closed = (!Ts2Hx.areEqual(this.path.toLowerCase().indexOf('z'), -1));
        var pointlength = this.length / 10;
        var points:Array<Int> = [];
        points.push(this.getRealPathPoint(0));
        points.push(this.getRealPathPoint(pointlength));
        points.push(this.getRealPathPoint(pointlength * 2));
        points.push(this.getRealPathPoint(pointlength * 3));
        points.push(this.getRealPathPoint(pointlength * 4));
        points.push(this.getRealPathPoint(pointlength * 5));
        points.push(this.getRealPathPoint(pointlength * 6));
        points.push(this.getRealPathPoint(pointlength * 7));
        points.push(this.getRealPathPoint(pointlength * 8));
        points.push(this.getRealPathPoint(pointlength * 9));
        points.push(this.getRealPathPoint(pointlength * 10));
        var clock = (points[1].x - points[0].x) * (points[1].y + points[0].y) + (points[2].x - points[1].x) * (points[2].y + points[1].y) + (points[3].x - points[2].x) * (points[3].y + points[2].y) + (points[4].x - points[3].x) * (points[4].y + points[3].y) + (points[5].x - points[4].x) * (points[5].y + points[4].y) + (points[6].x - points[5].x) * (points[6].y + points[5].y) + (points[7].x - points[6].x) * (points[7].y + points[6].y) + (points[8].x - points[7].x) * (points[8].y + points[7].y) + (points[9].x - points[8].x) * (points[9].y + points[8].y) + (points[10].x - points[9].x) * (points[10].y + points[9].y);
        if (clock > 0) {
            this.clockwise = false;
        } else {
            this.clockwise = true;
        }
        if (this.end == null) {
            this.end = this.length;
        }
        if (Ts2Hx.areEqual(this.closed, false)) {
            if (Ts2Hx.areEqual(this.flipped, false)) {
                if (this.start > this.end) {
                    this.realLength = this.start - this.end;
                    this.center = this.start - this.realLength / 2;
                } else {
                    this.realLength = this.end - this.start;
                    this.center = this.start + this.realLength / 2;
                }
            } else {
                if (this.start > this.end) {
                    this.realLength = this.start - this.end;
                    this.center = this.start - this.realLength / 2;
                } else {
                    this.realLength = this.end - this.start;
                    this.center = this.start + this.realLength / 2;
                }
            }
        } else if (Ts2Hx.areEqual(this.clockwise, false)) {
            if (Ts2Hx.areEqual(this.flipped, false)) {
                if (this.start > this.end) {
                    this.realLength = this.start - this.end;
                    this.center = this.end + this.realLength / 2;
                } else {
                    this.realLength = (this.start + this.length - this.end);
                    this.center = this.end + this.realLength / 2;
                    if (this.center > this.length) {
                        this.center = this.center - this.length;
                    }
                }
            } else {
                if (this.start > this.end) {
                    this.realLength = (this.end + this.length - this.start);
                    this.center = this.start + this.realLength / 2;
                    if (this.center > this.length) {
                        this.center = this.center - this.length;
                    }
                } else {
                    this.realLength = this.end - this.start;
                    this.center = this.start + this.realLength / 2;
                }
            }
        } else {
            if (Ts2Hx.areEqual(this.flipped, false)) {
                if (this.start > this.end) {
                    this.realLength = this.end + this.length - this.start;
                    this.center = this.start + this.realLength / 2;
                    if (this.center > this.length) {
                        this.center = this.center - this.length;
                    }
                } else {
                    this.realLength = this.end - this.start;
                    this.center = this.start + this.realLength / 2;
                }
            } else {
                if (this.start > this.end) {
                    this.realLength = this.start - this.end;
                    this.center = this.end + this.realLength / 2;
                } else {
                    this.realLength = this.start + this.length - this.end;
                    this.center = this.end + this.realLength / 2;
                    if (this.center > this.length) {
                        this.center = this.center - this.length;
                    }
                }
            }
        }
    }

    public function getRealPathPoint(distance:Float):txt.PathPoint {
        if (distance > this.length) {
            return this.pathElement.getPointAtLength(distance - this.length);
        } else if (distance < 0) {
            return this.pathElement.getPointAtLength(distance + this.length);
        } else {
            return this.pathElement.getPointAtLength(distance);
        }
    }

    public function getPathPoint(distance:Float, characterLength:Float = 0, charOffset:Float = 0):txt.PathPoint {
        distance = distance * 0.99;
        characterLength = characterLength * 0.99;
        var point0:PathPoint;
        var point1:PathPoint;
        var point2:PathPoint;
        var position:Float;
        var direction:Bool = true;
        var realStart:Float = 0;
        if (Ts2Hx.areEqual(this.closed, false)) {
            if (Ts2Hx.areEqual(this.flipped, false)) {
                if (this.start > this.end) {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start - (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start - this.realLength - characterLength;
                    }
                    position = realStart - distance;
                    direction = false;
                } else {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start + (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start + this.realLength - characterLength;
                    }
                    position = realStart + distance;
                }
            } else {
                if (this.start > this.end) {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start - (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start - this.realLength - characterLength;
                    }
                    position = realStart - distance;
                    direction = false;
                } else {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start + (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start + this.realLength - characterLength;
                    }
                    position = realStart - distance;
                }
            }
        } else if (Ts2Hx.areEqual(this.clockwise, false)) {
            if (Ts2Hx.areEqual(this.flipped, false)) {
                if (this.start > this.end) {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start - (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start - this.realLength - characterLength;
                    }
                    position = realStart - distance;
                    direction = false;
                } else {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                        position = realStart - distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start - (this.realLength - characterLength) / 2;
                        position = realStart - distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start - this.realLength - characterLength;
                        position = realStart - distance;
                    }
                    if (position < 0) {
                        position = position + this.length;
                    }
                    direction = false;
                }
            } else {
                if (this.start > this.end) {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                        position = realStart + distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start + (this.realLength - characterLength) / 2;
                        position = realStart + distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start + this.realLength - characterLength;
                        position = realStart + distance;
                    }
                    if (position > this.length) {
                        position = position - this.length;
                    }
                } else {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start + (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start + this.realLength - characterLength;
                    }
                    position = realStart + distance;
                }
            }
        } else {
            if (Ts2Hx.areEqual(this.flipped, false)) {
                if (this.start > this.end) {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                        position = realStart - distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start - (this.realLength - characterLength) / 2;
                        position = realStart - distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start - this.realLength - characterLength;
                        position = realStart - distance;
                    }
                    if (position < 0) {
                        position = position + this.length;
                    }
                    direction = false;
                } else {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start - (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start - this.realLength - characterLength;
                    }
                    position = realStart - distance;
                    direction = false;
                }
            } else {
                if (this.start > this.end) {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start + (this.realLength - characterLength) / 2;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start + this.realLength - characterLength;
                    }
                    position = realStart + distance;
                } else {
                    if (Ts2Hx.areEqual(this.align, PathAlign.Left)) {
                        realStart = this.start;
                        position = realStart + distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Center)) {
                        realStart = this.start + (this.realLength - characterLength) / 2;
                        position = realStart + distance;
                    } else if (Ts2Hx.areEqual(this.align, PathAlign.Right)) {
                        realStart = this.start + this.realLength - characterLength;
                        position = realStart + distance;
                    }
                    if (position > this.length) {
                        position = position - this.length;
                    }
                }
            }
        }
        point1 = this.getRealPathPoint(position);
        var segment = this.pathElement.pathSegList.getItem(this.pathElement.getPathSegAtLength(position)).pathSegType;
        if (Ts2Hx.areEqual(segment, 4)) {
            if (direction) {
            } else {
                if (!Ts2Hx.areEqual(this.pathElement.getPathSegAtLength(position), this.pathElement.getPathSegAtLength(position - charOffset))) {
                    var pp0 = this.getRealPathPoint(position);
                    var pp1 = this.getRealPathPoint(position - charOffset);
                    var ppc = this.pathElement.pathSegList.getItem(this.pathElement.getPathSegAtLength(position) - 1);
                    var d0 = Math.sqrt(Math.pow((pp0.x - Ts2Hx.getValue(ppc, 'x')), 2) + Math.pow((pp0.y - Ts2Hx.getValue(ppc, 'y')), 2));
                    var d1 = Math.sqrt(Math.pow((pp1.x - Ts2Hx.getValue(ppc, 'x')), 2) + Math.pow((pp1.y - Ts2Hx.getValue(ppc, 'y')), 2));
                    if (d0 > d1) {
                        point1 = pp0;
                        point2 = {
                            x: Ts2Hx.getValue(ppc, 'x'),
                            y: Ts2Hx.getValue(ppc, 'y')
                        };
                        var rot12 = Math.atan((point2.y - point1.y) / (point2.x - point1.x)) * 180 / Math.PI;
                        if (point1.x > point2.x) {
                            rot12 = rot12 + 180;
                        }
                        if (rot12 < 0) {
                            rot12 = rot12 + 360;
                        }
                        if (rot12 > 360) {
                            rot12 = rot12 - 360;
                        }
                        point1.rotation = rot12;
                        return point1;
                    } else {
                        point1 = {
                            x: Ts2Hx.getValue(ppc, 'x'),
                            y: Ts2Hx.getValue(ppc, 'y')
                        };
                        point1.offsetX = -d0;
                        point1.next = true;
                        return point1;
                    }
                }
            }
        }
        if (direction) {
            point2 = this.getRealPathPoint(position + charOffset);
        } else {
            point2 = this.getRealPathPoint(position - charOffset);
        }
        var rot12 = Math.atan((point2.y - point1.y) / (point2.x - point1.x)) * 180 / Math.PI;
        if (point1.x > point2.x) {
            rot12 = rot12 + 180;
        }
        if (rot12 < 0) {
            rot12 = rot12 + 360;
        }
        if (rot12 > 360) {
            rot12 = rot12 - 360;
        }
        point1.rotation = rot12;
        return point1;
    }

}


//# lineMapping=1,1,3,3,4,4,5,5,9,8,10,9,11,10,12,11,13,12,14,13,16,15,17,16,18,17,19,18,23,21,25,22,27,23,29,24,31,25,33,26,35,27,37,28,39,29,41,30,43,31,45,32,47,33,49,34,51,35,52,37,53,38,54,39,55,40,56,41,57,42,58,43,61,46,62,47,63,48,64,49,65,50,66,51,67,52,68,53,69,56,70,57,71,58,72,59,73,60,74,61,75,62,76,63,77,64,78,65,79,67,80,69,81,70,82,71,83,72,84,73,85,75,86,76,87,77,88,78,89,79,90,80,91,81,92,82,93,83,94,84,95,85,96,86,97,87,98,88,99,89,100,90,101,91,102,92,103,93,104,94,105,95,106,96,107,98,108,99,109,100,110,101,111,102,112,103,113,104,114,105,115,106,116,107,117,108,118,109,119,110,120,111,121,112,122,113,123,114,124,115,125,116,126,117,127,118,128,119,129,120,130,121,131,122,132,123,133,124,134,125,135,126,136,127,137,128,138,129,139,130,140,131,141,132,142,133,143,134,144,135,145,136,146,137,147,138,148,139,149,140,150,141,151,142,152,143,153,144,154,145,157,148,158,149,159,150,160,151,161,152,162,153,163,154,164,155,167,158,168,159,169,160,170,163,171,164,172,165,173,166,174,167,175,168,176,170,177,172,178,174,179,176,180,177,181,178,182,180,183,181,184,183,185,184,186,185,187,186,188,187,189,190,190,191,191,192,192,194,193,195,194,197,195,198,196,199,197,200,198,202,199,203,200,204,201,205,202,206,203,208,204,209,205,211,206,212,207,213,208,214,209,215,210,217,211,218,212,219,213,221,214,222,215,224,216,225,217,226,218,227,219,229,220,230,221,233,222,235,223,237,224,238,225,239,226,241,227,242,228,244,229,245,230,246,231,248,232,249,233,252,234,253,235,254,236,255,237,257,238,258,239,259,240,261,241,262,242,263,243,265,244,266,245,267,246,268,247,269,248,272,249,275,250,277,251,278,252,279,253,280,254,282,255,283,256,284,257,286,258,287,259,288,260,291,261,292,262,293,263,294,264,298,265,299,266,300,267,302,268,303,269,305,270,306,271,307,272,308,273,310,274,312,275,313,276,315,277,317,278,318,279,319,280,320,281,322,282,323,283,324,284,326,285,327,286,328,287,330,288,331,289,332,290,333,291,334,292,337,293,338,294,339,295,341,296,342,297,344,298,345,299,346,300,347,301,348,302,350,303,353,304,355,305,356,306,357,307,359,308,360,309,362,310,363,311,364,312,365,313,368,314,369,315,370,316,371,317,373,318,374,319,375,320,377,321,378,322,379,323,382,324,383,325,384,326,385,327,387,328,388,329,389,330,392,331,394,332,395,333,396,334,398,335,400,336,401,337,402,338,403,339,405,340,407,341,408,342,409,343,409,344,409,345,409,346,411,347,412,348,413,349,414,350,416,351,417,352,418,353,419,354,420,355,421,356,422,357,424,358,425,359,427,360,427,361,427,362,427,363,428,364,429,365,430,366,431,367,432,368,433,369,434,370,436,371,437,372,438,373,440,374,441,375,444,376,447,377,448,378,449,379,452,380,453,381,454,382,455,383,456,384,457,385,458,386,460,389,462