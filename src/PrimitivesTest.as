package
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.Debug;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;

	import away3d.primitives.Sphere;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF(frameRate="60", width="1024", height="576")]
	public class PrimitivesTest extends Sprite
	{
		private var _view : View3D;

		private var _ctr : ObjectContainer3D;
		private var _light : PointLight;
		private var _light2 : PointLight;

		[Embed(source="../embeds/crossColor.jpg")]
		private var Albedo : Class;

		[Embed(source="../embeds/crossnrm.jpg")]
		private var Normals : Class;

		private var _camController : HoverDragController;

		public function PrimitivesTest()
		{
			super();

			_view = new View3D();
			_camController = new HoverDragController(_view.camera, stage);
			_camController.radius = 500;

			this.addChild(_view);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			_ctr = new ObjectContainer3D();
			_view.scene.addChild(_ctr);

			var green : ColorMaterial = new ColorMaterial(0x00FF00);
			var red : ColorMaterial = new ColorMaterial(0xFF0000);
			var material : BitmapMaterial = new BitmapMaterial(new Albedo().bitmapData);
			material.normalMap = new Normals().bitmapData;
			material.ambientColor = 0x080820;

//                      material.specularMethod = null;
//			var green : BitmapMaterial = new BitmapMaterial(new Albedo().bitmapData);
//			var red : BitmapMaterial = new BitmapMaterial(new Albedo().bitmapData);
//			green.normalMap = new Normals().bitmapData;
//			red.normalMap = new Normals().bitmapData;

			_ctr.addChild(new Sphere(green)).x = -200;
			_ctr.addChild(new Sphere(red)).x = 200;
			_ctr.addChild(new Cube(material, 100, 100, 100, 11, 7, 25, false));

			_light = new PointLight();
			_light.x = -1000;
			_light.y = 1000;
			_light.z = -1000;
			_light.color = 0xffeeaa;

			_light2 = new PointLight();
			_light2.x = 1000;
			_light2.y = -1000;
			_light2.z = 1000;
			_light2.color = 0xff2233;

			var lights : Array = [_light, _light2];

			green.lights = lights;
			red.lights = lights;
			material.lights = lights;
			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}


		private function onEnterFrame(ev : Event) : void
		{
			_ctr.rotationY += .1;
			//_ctr.rotationX = 20 * Math.sin(getTimer() * 0.002);
			_view.render();
		}
	}
}
