package
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.primitives.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;

	[SWF(width="1168", height="700", frameRate="60")]
	public class WireGridTest extends MovieClip
	{
		private var _primitive : WireframePrimitiveBase;
		private var _view : View3D;
		private var camera : Camera3D;
		private var origin : Vector3D = new Vector3D(0, 0, 0);

		private var wave : Number = 0;

		public function WireGridTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			initView();
			populate();

			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		private function initView() : void
		{
			_view = new View3D();
			_view.antiAlias = 4;
			_view.backgroundColor = 0x333333;
			camera = _view.camera;
			camera.lens = new PerspectiveLens();
//			camera.lens = new OrthographicLens();

			camera.x = 500;
			camera.y = 1;
			camera.z = 500;
			addChild(_view);
			addChild(new AwayStats(_view));

			camera.lookAt(new Vector3D(0, 0, 0));
			camera.lens.near = 10;
			camera.lens.far = 3000;
		}

		private function populate() : void
		{
			//displays the 3 world planes
			var wireFrameGrid : WireframeAxesGrid = new WireframeAxesGrid(50, 500, 1);
			_view.scene.addChild(wireFrameGrid);

//			_primitive = new WireframeCube(100, 100, 100, 0xffff99, 1);
			_primitive = new WireframeSphere(100);

			_primitive.x = 0;
			_primitive.y = 0;
			_primitive.z = 0;
			_view.scene.addChild(_primitive);
		}

		private function handleEnterFrame(e : Event) : void
		{

			wave += .02;
			_primitive.y = 200 * Math.sin(wave);

			_view.camera.position = origin;
			_view.camera.rotationY += .5;
			_view.camera.moveBackward(500);
			_view.camera.y = 50 * Math.sin(wave);

			_view.render();
		}

	}
}