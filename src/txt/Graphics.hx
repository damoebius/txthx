createjs.Graphics.prototype.decodeSVGPath = function(data:String) {
    txt.Graphics.init(this, data);
    return this;
}
package txt;

class Graphics {

    static public function init(target, svgpath:String) {
        var ca = Graphics.parsePathData(svgpath);
        var G = createjs.Graphics;
        var closedPath:Bool = false;
        var n:Int = 0;
        while (n < ca.length) {
            var c = ca[n].command;
            var p = ca[n].points;
            switch (c) {
                case 'L':
                    target.append(new G.LineTo(p[0], p[1]));
                case 'M':
                    target.append(new G.MoveTo(p[0], p[1]));
                case 'C':
                    target.append(new G.BezierCurveTo(p[0], p[1], p[2], p[3], p[4], p[5]));
                case 'Q':
                    target.append(new G.QuadraticCurveTo(p[0], p[1], p[2], p[3]));
                case 'A':
                    target.append(new G.SVGArc(p[0], p[1], p[2], p[3], p[4], p[5], p[6]));
                case 'Z':
                    target.append(new G.ClosePath());
                    target.append(new G.MoveTo(p[0], p[1]));
            }
            n++;
        }
    }

    static public function parsePathData(data) {
        if (!Ts2Hx.isTrue(data)) {
            return [];
        }
        var cs = data;
        var cc:Array<String> = ['m', 'M', 'l', 'L', 'v', 'V', 'h', 'H', 'z', 'Z', 'c', 'C', 'q', 'Q', 't', 'T', 's', 'S', 'a', 'A'];
        cs = cs.replace(new RegExp(' ', 'g'), ',');
        var n:Int = 0;
        while (n < cc.length) {
            cs = cs.replace(new RegExp(cc[n], 'g'), '|' + cc[n]);
            n++;
        }
        var arr = cs.split('|');
        var ca:Array<Int> = [];
        var cpx:Int = 0;
        var cpy:Int = 0;
        var arrLength = arr.length;
        var startPoint = null;
        n = 1;
        while (n < arrLength) {
            var str = arr[n];
            var c = str.charAt(0);
            str = str.slice(1);
            str = str.replace(new RegExp(',-', 'g'), '-');
            str = str.replace(new RegExp('-', 'g'), ',-');
            str = str.replace(new RegExp('e,-', 'g'), 'e-');
            var p = str.split(',');
            if (p.length > 0 && p[0] == '') {
                p.shift();
            }
            var pLength = p.length;
            var i:Int = 0;
            while (i < pLength) {
                p[i] = Std.parseFloat(p[i]);
                i++;
            }
            if (c == 'z' || c == 'Z') {
                p = [true]
            }
            while (p.length > 0) {
                if (isNaN(p[0])) {
                    break;
                }
                var cmd = null;
                var points:Array<Int> = [];
                var startX:Int = cpx, startY:Int = cpy;
                var prevCmd, ctlPtx, ctlPty;
                var rx, ry, psi, fa, fs, x1, y1;
                switch (c) {
                    case 'l':
                        cpx += p.shift();
                        cpy += p.shift();
                        cmd = 'L';
                        points.push(cpx, cpy);
                    case 'L':
                        cpx = p.shift();
                        cpy = p.shift();
                        points.push(cpx, cpy);
                    case 'm':
                        var dx = p.shift();
                        var dy = p.shift();
                        cpx += dx;
                        cpy += dy;
                        if (startPoint == null) {
                            startPoint = [cpx, cpy];
                        }
                        cmd = 'M';
                        points.push(cpx, cpy);
                        c = 'l';
                    case 'M':
                        cpx = p.shift();
                        cpy = p.shift();
                        cmd = 'M';
                        if (startPoint == null) {
                            startPoint = [cpx, cpy];
                        }
                        points.push(cpx, cpy);
                        c = 'L';
                    case 'h':
                        cpx += p.shift();
                        cmd = 'L';
                        points.push(cpx, cpy);
                    case 'H':
                        cpx = p.shift();
                        cmd = 'L';
                        points.push(cpx, cpy);
                    case 'v':
                        cpy += p.shift();
                        cmd = 'L';
                        points.push(cpx, cpy);
                    case 'V':
                        cpy = p.shift();
                        cmd = 'L';
                        points.push(cpx, cpy);
                    case 'C':
                        points.push(p.shift(), p.shift(), p.shift(), p.shift());
                        cpx = p.shift();
                        cpy = p.shift();
                        points.push(cpx, cpy);
                    case 'c':
                        points.push(cpx + p.shift(), cpy + p.shift(), cpx + p.shift(), cpy + p.shift());
                        cpx += p.shift();
                        cpy += p.shift();
                        cmd = 'C';
                        points.push(cpx, cpy);
                    case 'S':
                        ctlPtx = cpx;
                        ctlPty = cpy;
                        prevCmd = ca[cast(ca.length - 1, Int)];
                        if (prevCmd.command == 'C') {
                            ctlPtx = cpx + (cpx - prevCmd.points[2]);
                            ctlPty = cpy + (cpy - prevCmd.points[3]);
                        }
                        points.push(ctlPtx, ctlPty, p.shift(), p.shift());
                        cpx = p.shift();
                        cpy = p.shift();
                        cmd = 'C';
                        points.push(cpx, cpy);
                    case 's':
                        ctlPtx = cpx;
                        ctlPty = cpy;
                        prevCmd = ca[cast(ca.length - 1, Int)];
                        if (prevCmd.command == 'C') {
                            ctlPtx = cpx + (cpx - prevCmd.points[2]);
                            ctlPty = cpy + (cpy - prevCmd.points[3]);
                        }
                        points.push(ctlPtx, ctlPty, cpx + p.shift(), cpy + p.shift());
                        cpx += p.shift();
                        cpy += p.shift();
                        cmd = 'C';
                        points.push(cpx, cpy);
                    case 'Q':
                        points.push(p.shift(), p.shift());
                        cpx = p.shift();
                        cpy = p.shift();
                        points.push(cpx, cpy);
                    case 'q':
                        points.push(cpx + p.shift(), cpy + p.shift());
                        cpx += p.shift();
                        cpy += p.shift();
                        cmd = 'Q';
                        points.push(cpx, cpy);
                    case 'T':
                        ctlPtx = cpx;
                        ctlPty = cpy;
                        prevCmd = ca[cast(ca.length - 1, Int)];
                        if (prevCmd.command == 'Q') {
                            ctlPtx = cpx + (cpx - prevCmd.points[0]);
                            ctlPty = cpy + (cpy - prevCmd.points[1]);
                        }
                        cpx = p.shift();
                        cpy = p.shift();
                        cmd = 'Q';
                        points.push(ctlPtx, ctlPty, cpx, cpy);
                    case 't':
                        ctlPtx = cpx;
                        ctlPty = cpy;
                        prevCmd = ca[cast(ca.length - 1, Int)];
                        if (prevCmd.command == 'Q') {
                            ctlPtx = cpx + (cpx - prevCmd.points[0]);
                            ctlPty = cpy + (cpy - prevCmd.points[1]);
                        }
                        cpx += p.shift();
                        cpy += p.shift();
                        cmd = 'Q';
                        points.push(ctlPtx, ctlPty, cpx, cpy);
                    case 'A':
                        rx = p.shift();
                        ry = p.shift();
                        psi = p.shift();
                        fa = p.shift();
                        fs = p.shift();
                        x1 = cpx;
                        y1 = cpy;
                        cpx = p.shift();
                        cpy = p.shift();
                        cmd = 'A';
                        points = [[x1, y1], rx, ry, psi, fa, fs, [cpx, cpy]];
                    case 'a':
                        rx = p.shift();
                        ry = p.shift();
                        psi = p.shift();
                        fa = p.shift();
                        fs = p.shift();
                        x1 = cpx;
                        y1 = cpy;
                        cpx += p.shift();
                        cpy += p.shift();
                        cmd = 'A';
                        points = [[x1, y1], rx, ry, psi, fa, fs, [cpx, cpy]];
                    case 'z':
                        cmd = 'Z';
                        if (Ts2Hx.isTrue(startPoint)) {
                            cpx = startPoint[0];
                            cpy = startPoint[1];
                            startPoint = null;
                        } else {
                            cpx = 0;
                            cpy = 0;
                        }
                        p.shift();
                        points = [cpx, cpy];
                    case 'Z':
                        cmd = 'Z';
                        if (Ts2Hx.isTrue(startPoint)) {
                            cpx = startPoint[0];
                            cpy = startPoint[1];
                            startPoint = null;
                        } else {
                            cpx = 0;
                            cpy = 0;
                        }
                        p.shift();
                        points = [cpx, cpy];
                }
                ca.push({
                    command: cmd || c,
                    points: points,
                    start: {
                        x: startX,
                        y: startY
                    }
                });
            }
            n++;
        }
        return ca;
    }

}

{
null}

//# lineMapping=1,1,2,2,3,3,4,4,5,5,7,8,9,10,10,12,11,13,12,14,13,16,14,15,15,17,16,18,17,19,18,21,19,22,20,25,21,26,22,29,23,30,24,33,25,34,26,37,27,38,28,41,29,42,30,43,32,16,33,46,36,50,37,51,38,52,39,53,40,54,41,55,42,56,43,57,44,57,45,58,46,57,47,59,48,60,49,61,50,62,51,63,52,64,53,65,54,66,55,66,56,67,57,68,58,69,59,70,60,71,61,72,62,73,63,74,64,75,65,76,66,77,67,78,68,78,69,79,70,78,71,80,72,81,73,82,74,83,75,85,76,86,78,88,79,89,80,90,81,91,84,95,85,97,86,98,87,99,88,100,89,101,90,104,91,105,92,106,93,107,94,110,95,111,96,112,97,113,98,114,99,115,100,116,101,117,102,118,103,119,104,120,105,123,106,124,107,125,108,126,109,127,110,128,111,129,112,130,113,131,114,134,115,135,116,136,117,137,118,140,119,141,120,142,121,143,122,146,123,147,124,148,125,149,126,152,127,153,128,154,129,155,130,158,131,159,132,160,133,161,134,162,135,165,136,166,137,167,138,168,139,169,140,170,141,173,142,174,143,175,144,176,145,177,146,178,147,179,148,180,149,181,150,182,151,183,152,184,153,185,154,188,155,189,156,190,157,191,158,192,159,193,160,194,161,195,162,196,163,197,164,198,165,199,166,200,167,203,168,204,169,205,170,206,171,207,172,210,173,211,174,212,175,213,176,214,177,215,178,218,179,219,180,220,181,221,182,222,183,223,184,224,185,225,186,226,187,227,188,228,189,229,190,232,191,233,192,234,193,235,194,236,195,237,196,238,197,239,198,240,199,241,200,242,201,243,202,246,203,247,204,248,205,249,206,250,207,251,208,252,209,253,210,254,211,255,212,256,213,257,214,260,215,261,216,262,217,263,218,264,219,265,220,266,221,267,222,268,223,269,224,270,225,271,226,274,227,275,228,276,229,277,230,278,231,279,232,280,233,281,234,282,235,283,236,284,237,285,238,288,239,289,240,290,241,291,242,292,243,293,244,294,245,295,246,296,247,297,248,298,249,299,251,302,252,304,253,305,254,306,255,307,256,308,257,309,258,310,259,311,260,66,261,312,262,315,265,317,267,321,268,459