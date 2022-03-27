package hxd;

private class Win {
    public var app:App;
    public function new(app:App) {
        this.app = app;
    }
}

class App implements h3d.IDrawable {
    public static var wins:Array<Win> = [];
	public var engine:h3d.Engine;
    public var s2d:h2d.Scene;
    public var s3d:h3d.scene.Scene;
    public var sevents:hxd.SceneEvents;

    public function new() {
		if (wins.length == 0) {
			hxd.System.start(function() {
				engine = @:privateAccess new h3d.Engine();
				engine.onReady = setup;
				engine.init();
			});
		} else {
			@:privateAccess Window.inst = new hxd.Window(Std.string(hxd.App.wins.length), 800, 600);
			engine = @:privateAccess new h3d.Engine();
			engine.onReady = setup;
			engine.init();
		}
    }

    public static function mainLoop() {
		hxd.Timer.update();

        for (win in wins) {
			var app = win.app;
			@:privateAccess {
				Window.inst = app.engine.window;
				Window.inst.window.renderTo();
			}
			app.engine.setCurrent();
            app.sevents.checkEvents();
            // if( isDisposed ) return;
            app.update(hxd.Timer.dt);
            // if( isDisposed ) return;
            var dt = hxd.Timer.dt;
            if( app.s2d != null ) app.s2d.setElapsedTime(dt);
            if( app.s3d != null ) app.s3d.setElapsedTime(dt);
            app.engine.render(app);
        }
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
		sevents = new hxd.SceneEvents();
		sevents.addScene(s2d);
		sevents.addScene(s3d);
		loadAssets(function() {
			initDone = true;
			init();
			hxd.Timer.skip();
			if (wins.length == 0) {
				mainLoop();
				hxd.System.setLoop(mainLoop);
				hxd.Key.initialize();
			}
			wins.push(new Win(this));
		});
	}
}
