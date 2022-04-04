package;

class Main2 extends hxd.App {
    var txt1:h2d.Text;
    var txt2:h2d.Text;
    var c:Float = 0;
    var b:Int = 0;
    override function init() {
        txt1 = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        txt1.text = "WINDOW 2 !";
        txt1.setPosition(300,300);
        txt1.setScale(2);

        txt2 = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        txt2.text = "POS : ";
        txt2.setScale(2);
        @:privateAccess engine.window.title = "2";
    }

    override function update(dt:Float) {
        txt2.text = "X: " + s2d.mouseX + " Y:" + s2d.mouseY + " | " + engine.fps;
        txt1.rotate(0.025);
        c+=dt;

        // if (b < 1 && c >= 2) {
        //     new Main2();
        //     c = 0;
        //     b++;
        // }
    }
}
