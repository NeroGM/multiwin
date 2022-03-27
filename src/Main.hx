class Main extends hxd.App {
    var txt1:h2d.Text;
    var txt2:h2d.Text;
    var c:Float = 0;
    var b:Bool = false;
    override function init() {
        txt1 = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        txt1.text = "WINDOW 1 !";
        txt1.setPosition(300,300);
        txt1.setScale(2);

        txt2 = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        txt2.text = "POS : ";
        txt2.setScale(2);
    }

    override function update(dt:Float) {
        txt2.text = "X: " + s2d.mouseX + " Y:" + s2d.mouseY;
        txt1.rotate(0.025);
        c+=dt;
        if (!b && c >= 1) {
            new Main2();
            b = true;
        }
    }
    static function main() {
        new Main();
    }
}