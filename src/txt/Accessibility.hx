package txt;

class Accessibility {

    static public var data:Dynamic = [];

    static public var timeout:Dynamic = null;

    static public function null(element:Dynamic) {
        if (element.stage == null) {
            return ;
        }
        if (txt.Accessibility.timeout != null) {
            Ts2Hx.clearTimeout(txt.Accessibility.timeout);
        }
        if (element.accessibilityId == null) {
            txt.Accessibility.data.push(element);
            element.accessibilityId = txt.Accessibility.data.length - 1;
        }
        txt.Accessibility.timeout = Ts2Hx.setTimeout(txt.Accessibility.update, 300);
    }

    static public function update() {
        txt.Accessibility.timeout = null;
        var data = txt.Accessibility.data.slice(0)
        data.sort(function(a, b) {
            return a.accessibilityPriority - b.accessibilityPriority
        });
        var len = data.length;
        var out:String = "";
        var currentCanvas = data[0].stage.canvas;
        var i:Int = 0;
        while (i < len) {
            if (data[i].stage == null) {
                continue;
            }
            if (!Ts2Hx.areEqual(currentCanvas, data[i].stage.canvas)) {
                currentCanvas.innerHTML = out;
                out = "";
                currentCanvas = data[i].stage.canvas;
            }
            if (data[i].accessibilityText == null) {
                out += '<p>' + data[i].text + '</p>';
            } else {
                out += data[i].accessibilityText;
            }
            i++;
        }
        currentCanvas.innerHTML = out;
    }

    static public function clear() {
        txt.Accessibility.data = [];
    }

}


//# lineMapping=1,1,3,3,5,5,7,7,9,9,10,11,12,13,13,15,14,16,15,17,16,19,17,20,18,21,19,22,20,23,23,27,24,28,25,29,26,30,27,30,28,30,29,31,30,32,31,33,32,34,33,34,34,35,36,37,37,38,38,39,39,40,40,41,41,42,42,43,43,44,44,45,45,46,46,47,47,34,48,48,49,49,52,52,53,53,56,55