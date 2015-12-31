package txt;

class FontLoader {

    static public var path:String = "/font/";

    static public var cache:Bool = false;

    static public var version:Float = 0;

    static public var fonts:Dynamic = {
    };

    static public var loaders:Dynamic = [];

    static public function isLoaded(name:String):Bool {
        if (txt.FontLoader.fonts.function hasOwnProperty() { [native code] }(name)) {
            return Ts2Hx.getValue(txt.FontLoader.fonts, name).loaded;
        }
        return false;
    }

    static public function getFont(name:String):txt.Font {
        if (txt.FontLoader.fonts.function hasOwnProperty() { [native code] }(name)) {
            return Ts2Hx.getValue(txt.FontLoader.fonts, name);
        }
        return null;
    }

    static public function load(target:Dynamic, fonts:Dynamic) {
        var loader:Dynamic;
        if (target.loaderId == null) {
            loader = {
            };
            target.loaderId = txt.FontLoader.loaders.push(loader) - 1;
            loader._id = target.loaderId;
            loader._target = target;
        } else {
            loader = Ts2Hx.getValue(txt.FontLoader.loaders, target.loaderId);
        }
        var fontCount = fonts.length;
        var i:Int = 0;
        while (i < fontCount) {
            Ts2Hx.setValue(loader, fonts[i], false);
            ++i;
        }
        for (prop in Reflect.fields(loader)) {
            if (!Ts2Hx.areEqual(prop.charAt(0), "_")) {
                txt.FontLoader.loadFont(prop, loader);
            }
        }
    }

    static public function check(id:Float) {
        var loader = Ts2Hx.getValue(txt.FontLoader.loaders, id);
        for (prop in Reflect.fields(loader)) {
            if (!Ts2Hx.areEqual(prop.charAt(0), "_")) {
                Ts2Hx.setValue(loader, prop, txt.FontLoader.isLoaded(prop))
                if (Ts2Hx.areEqual(Ts2Hx.getValue(loader, prop), false)) return ;
            }
        }
        window.setTimeout(function() {
            loader._target.fontLoaded();
        }, 1);
    }

    static public function loadFont(fontName:String, loader:Dynamic) {
        var fonts = txt.FontLoader.fonts;
        if (txt.FontLoader.fonts.function hasOwnProperty() { [native code] }(fontName)) {
            if (Ts2Hx.getValue(txt.FontLoader.fonts, fontName).loaded == true) {
                txt.FontLoader.check(loader._id);
            } else {
                Ts2Hx.getValue(txt.FontLoader.fonts, fontName).targets.push(loader._id);
            }
        } else {
            var font:txt.Font = Ts2Hx.setValue(txt.FontLoader.fonts, fontName, new txt.Font())
            font.targets.push(loader._id);
            var req:Dynamic = new XMLHttpRequest();
            if (localStorage && txt.FontLoader.cache) {
                var local = Ts2Hx.JSONparse(localStorage.getItem('txt_font_' + fontName.split(' ').join('_')));
                if (local != null) {
                    if (local.version == txt.FontLoader.version) {
                        req.cacheResponseText = local.font;
                        req.cacheFont = true;
                    }
                }
            }
            req.onload = function() {
                if (localStorage && txt.FontLoader.cache && FontLoader.cacheFont == null) {
                    localStorage.setItem('txt_font_' + fontName.split(' ').join('_'), Ts2Hx.JSONstringify({
                        font: FontLoader.responseText,
                        version: txt.FontLoader.version
                    }));
                }
                var lines = FontLoader.responseText.split('\n');
                if (Ts2Hx.isTrue(FontLoader.cacheResponseText)) {
                    lines = FontLoader.cacheResponseText.split('\n');
                }
                var len = lines.length;
                var i:Int = 0;
                var line:Dynamic;
                var glyph:txt.Glyph;
                while (i < len) {
                    line = lines[i].split("|");
                    switch (line[0]) {
                        case '0':
                            if (Ts2Hx.areEqual(line[1], 'id') || Ts2Hx.areEqual(line[1], 'panose') || Ts2Hx.areEqual(line[1], 'family') || Ts2Hx.areEqual(line[1], 'font-style') || Ts2Hx.areEqual(line[1], 'font-stretch')) {
                                Ts2Hx.setValue(font, line[1], line[2]);
                            } else {
                                Ts2Hx.setValue(font, line[1], Std.parseInt(line[2]));
                            }
                        case '1':
                            glyph = new txt.Glyph();
                            glyph.offset = Std.parseInt(line[2]) / font.units;
                            glyph.path = line[3];
                            Ts2Hx.setValue(font.glyphs, line[1], glyph);
                        case '2':
                            if (Ts2Hx.getValue(font.kerning, line[1]) == null) {
                                Ts2Hx.setValue(font.kerning, line[1], {
                                });
                            }
                            if (Ts2Hx.getValue(font.glyphs, line[1]) == null) {
                                glyph = new txt.Glyph();
                                glyph.offset = font.null / font.units;
                                glyph.path = '';
                                Ts2Hx.setValue(font.glyphs, line[1], glyph);
                            }
                            Ts2Hx.setValue(Ts2Hx.getValue(font.glyphs, line[1]).kerning, line[2], Std.parseInt(line[3]) / font.units);
                            Ts2Hx.setValue(Ts2Hx.getValue(font.kerning, line[1]), line[2], Std.parseInt(line[3]) / font.units);
                        case '3':
                            line.shift();
                            var lineLen = line.length;
                            var j:Int = 0;
                            while (j < lineLen) {
                                var path = line[j].split("");
                                var pathLength = path.length;
                                var target = font.ligatures;
                                var k:Int = 0;
                                while (k < pathLength) {
                                    if (Ts2Hx.getValue(target, path[k]) == null) {
                                        Ts2Hx.setValue(target, path[k], {
                                        })
                                    }
                                    if (Ts2Hx.areEqual(k, pathLength - 1)) {
                                        Ts2Hx.getValue(target, path[k]).glyph = Ts2Hx.getValue(font.glyphs, line[j])
                                    }
                                    target = Ts2Hx.getValue(target, path[k]);
                                    k++;
                                }
                                j++;
                            }
                    }
                    i++;
                }
                font.cloneGlyph(183, 8226);
                font.cloneGlyph(8729, 8226);
                font.cloneGlyph(12539, 8226);
                font.cloneGlyph(9702, 8226);
                font.cloneGlyph(9679, 8226);
                font.cloneGlyph(9675, 8226);
                if (font.top == null) {
                    font.top = 0;
                }
                if (font.middle == null) {
                    font.middle = 0;
                }
                if (font.bottom == null) {
                    font.bottom = 0;
                }
                var lLen = font.targets.length;
                font.loaded = true;
                var l:Int = 0;
                while (l < lLen) {
                    txt.FontLoader.check(font.targets[l]);
                    ++l;
                }
                font.targets = [];
            }
            if (Ts2Hx.areEqual(req.cacheFont, true)) {
                req.onload();
            } else {
                req.open("get", txt.FontLoader.path + fontName.split(" ").join('_') + '.txt', true);
                req.send();
            }
        }
    }

}


//# lineMapping=1,1,3,3,5,5,7,7,9,9,11,11,12,11,14,13,16,15,17,16,19,18,20,19,23,22,24,23,26,25,27,26,30,29,31,31,32,32,33,33,34,33,35,34,36,35,37,36,38,37,39,38,40,39,41,40,42,41,43,41,45,41,46,44,47,45,48,46,49,47,50,48,51,49,54,52,56,55,57,56,59,58,60,59,61,60,62,61,63,61,64,61,67,64,68,65,69,68,70,71,71,72,72,73,73,77,74,78,75,79,76,82,77,83,78,86,79,88,80,89,81,90,82,91,83,92,84,93,85,94,86,95,87,96,88,97,89,101,90,102,91,102,92,102,93,102,94,103,95,105,96,107,97,108,98,109,99,110,100,111,102,113,103,114,104,115,105,116,106,118,107,120,109,122,111,124,112,127,113,128,114,131,115,132,117,136,118,138,121,140,122,141,123,142,124,143,125,144,127,146,130,151,131,152,132,153,133,154,134,154,135,155,136,156,137,157,138,158,139,158,140,159,143,161,144,162,146,164,147,165,148,158,149,167,150,154,151,168,153,172,154,173,155,174,156,177,157,178,158,179,159,180,160,181,161,184,162,185,163,186,164,187,165,188,166,189,167,190,168,191,169,192,170,196,171,197,172,198,173,198,174,199,175,198,176,200,177,201,178,202,179,204,180,205,181,206,182,207,183,208,184,209,185,210,188,212