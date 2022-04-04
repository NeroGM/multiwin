package hxd;

class App implements h3d.IDrawable {
    public static var apps:Array<App> = [];

	public var engine:h3d.Engine;
    public var s2d:h2d.Scene;
    public var s3d:h3d.scene.Scene;
    public var sevents:hxd.SceneEvents;

    public function new() {
		if (apps.length == 0) {
			hxd.System.start(function() {
				@:privateAccess {
					engine = new h3d.Engine();
					engine.window.onClose = () -> { engine.window.window.destroy(); apps.remove(this); true; }
				}
				engine.onReady = setup;
				engine.init();
			});
		} else {
			@:privateAccess var oldInst = Window.inst;
			var oldEngine = h3d.Engine.getCurrent();

			@:privateAccess Window.inst.window.renderTo();
			@:privateAccess {
				Window.inst = new hxd.Window(Std.string(hxd.App.apps.length), 800, 600);
				engine = new h3d.Engine();
				engine.window.onClose = () -> { engine.window.window.destroy(); apps.remove(this); true; }
			};
			engine.onReady = setup;
			engine.init();
			
			@:privateAccess Window.inst = oldInst;
			// @:privateAccess Window.inst.window.renderTo();
			
			oldEngine.setCurrent();
		}
    }

	public static var c:Float = 0;
	public static var b:Int = 0;
    public static function mainLoop() {
		hxd.Timer.update();

        for (app in apps) {			
			app.engine.setCurrent();
			@:privateAccess {
				Window.inst = app.engine.window;
				@:privateAccess Window.inst.window.renderTo();
			}
            app.sevents.checkEvents();
            app.update(hxd.Timer.dt);
			@:privateAccess {
				// app.engine.setCurrent();
				// Window.inst = app.engine.window;
				// @:privateAccess Window.inst.window.renderTo(); 
			}
            var dt = hxd.Timer.dt;
            if( app.s2d != null ) app.s2d.setElapsedTime(dt);
            if( app.s3d != null ) app.s3d.setElapsedTime(dt);
			
			app.engine.clear();
			if (!app.engine.render(app)) throw "??";
			app.engine.driver.present();
        }
		// c += hxd.Timer.dt;
		// if (b < 1 && c > 2) {
		// 	new Main2();
		// 	b++;
		// }
	}
    
    function init() { }

	function update(dt:Float) { }

    function loadAssets( onLoaded : Void->Void ) {
		onLoaded();
	}

	public function onResize() { }

	public function render(e:h3d.Engine) {
		s3d.render(e);
		s2d.render(e);
	}

	public function setScene( scene : hxd.SceneEvents.InteractiveScene, disposePrevious = true ) {
		var new2D = hxd.impl.Api.downcast(scene, h2d.Scene);
		var new3D = hxd.impl.Api.downcast(scene, h3d.scene.Scene);
		if( new2D != null ) {
			sevents.removeScene(s2d);
			sevents.addScene(scene, 0);
		} else {
			if( new3D != null )
				sevents.removeScene(s3d);
			sevents.addScene(scene);
		}
		if( disposePrevious ) {
			if( new2D != null )
				s2d.dispose();
			else if( new3D != null )
				s3d.dispose();
			else
				throw "Can't dispose previous scene";
		}
		if( new2D != null )
			this.s2d = new2D;
		if( new3D != null )
			this.s3d = new3D;
	}

    public static function staticHandler() {} //?

    
    private function onContextLost() {
		if( s3d != null ) s3d.onContextLost();
	}

    private function setup() {
		var oEngine = h3d.Engine.getCurrent();
		var oInstance = @:privateAccess Window.inst;
		@:privateAccess Window.inst = engine.window;
		engine.setCurrent();

		var initDone = false;
		engine.onReady = staticHandler;
		engine.onContextLost = onContextLost;
		engine.onResized = function() {
			if( s2d == null ) return; // if disposed
			s2d.checkResize();
			if( initDone ) onResize();
		};
		s3d = new h3d.scene.Scene();
		s2d = new h2d.Scene();
		sevents = new hxd.SceneEvents(@:privateAccess engine.window);
		sevents.addScene(s2d);
		sevents.addScene(s3d);
		loadAssets(function() {
			initDone = true;
			init();
			hxd.Timer.skip();
			if (apps.length == 0) {
				mainLoop();
				hxd.System.setLoop(mainLoop);
				hxd.Key.initialize();
			}
			apps.push(this);
		});

		@:privateAccess Window.inst.window.renderTo();
		engine.render(this);
		engine.driver.present();
		@:privateAccess Window.inst = oInstance;
		oEngine.setCurrent();
	}
}
