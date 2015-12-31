package ;
import txt.Align;
import txt.Text;
import createjs.easeljs.Stage;
import js.Browser;
class Main {
    public function new() {
        var canvas = Browser.document.createCanvasElement();
        canvas.width = 1000;
        canvas.height = 1000;
        Browser.document.body.appendChild(canvas);
        var stage = new Stage(canvas);

        var txtParams = new TextParameters();
        txtParams.text='The fox jumped over the log.';
        txtParams.font='raleway';
        txtParams.align=Align.TOP_RIGHT;
        txtParams.tracking=-4;
        txtParams.lineHeight=120;
        txtParams.width=600;
        txtParams.height=360;
        txtParams.size=120;


        var mytxt = new Text(txtParams);
        mytxt.x=10;
        mytxt.y=10;

        stage.addChild(mytxt);
        stage.update();
    }

    public static function main():Void{
        trace("test de txtjs");
        new Main();
    }

}
