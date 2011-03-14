package
{
	import away3d.containers.View3D;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.events.MouseEvent3D;
	import away3d.events.ResourceEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.utils.WireframeMapGenerator;
	import away3d.primitives.Plane;
	import away3d.entities.Mesh;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[SWF(width="800", height="450", frameRate="60")]
	public class InteractionTest extends Sprite
	{
		private var _view : View3D;

		private var _mesh1 : Plane;
		private var _mesh2 : Plane;
		private var _material1 : BitmapMaterial;
		private var _material2 : BitmapMaterial;
		private var _camController:HoverDragController;

		public function InteractionTest()
		{
			_view = new View3D;
			_view.antiAlias = 4;
			this.addChild(_view);

			var bitmapData1 : BitmapData = new BitmapData(512, 512, false, 0x000000);
			var bitmapData2 : BitmapData = new BitmapData(512, 512, false, 0x000000);
			bitmapData1.perlinNoise(64, 64, 5, 0, false, true, BitmapDataChannel.RED);
			bitmapData2.perlinNoise(64, 64, 5, 0, false, true, BitmapDataChannel.BLUE);
			_material1 = new BitmapMaterial(bitmapData1);
			_material2 = new BitmapMaterial(bitmapData2);
			_mesh1 = new Plane(_material1, 500, 500, 1, 1);
			_mesh2 = new Plane(_material2, 500, 500, 1, 1);
			_view.scene.addChild(_mesh1);
			_view.scene.addChild(_mesh2);
			_mesh1.rotationY = .01;
			_mesh2.mouseEnabled = false;
			_mesh1.mouseEnabled = true;
			_mesh1.mouseDetails = true;
			_mesh1.addEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
			_camController = new HoverDragController(_view.camera, stage);

			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		private function onMouseMove(event : MouseEvent3D) : void
		{
			var material : BitmapMaterial = event.target.material;
			var rect : Rectangle = new Rectangle(event.uv.x*material.bitmapData.width-4, event.uv.y*material.bitmapData.height-4, 9, 9);
			material.bitmapData.fillRect(rect, 0x00ff00);
			material.updateTexture();
		}


		private function handleEnterFrame(ev : Event) : void
		{
			_mesh1.rotationX += .01;
			_view.render();
		}
	}
}