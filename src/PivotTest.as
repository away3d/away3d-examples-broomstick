package
{
	import away3d.containers.View3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;
	import away3d.containers.ObjectContainer3D;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	[SWF(frameRate="60", width="1024", height="576")]
	public class PivotTest extends Sprite
	{
		private var _view : View3D;
		
		private var _ctr : ObjectContainer3D;
		private var _light : PointLight;

		[Embed(source="../embeds/crossColor.jpg")]
		private var Albedo : Class;
		
		[Embed(source="../embeds/crossnrm.jpg")]
		private var Normals : Class;

		private var _camController : HoverDragController;
		private var _cube : Cube;
		private var _sphere : Sphere;

		public function PivotTest()
		{
			super();
			
			_view = new View3D();
			_camController = new HoverDragController(_view.camera, stage);
			_camController.radius = 500;

			addChild(_view);
			addEventListener(Event.ENTER_FRAME, _handleEnterFrame);

			var material : BitmapMaterial = new BitmapMaterial(new Albedo().bitmapData);
//			material.normalMap = new Normals().bitmapData;
			material.ambientColor = 0x080820;
//			material.specularMethod = null;

			_cube = new Cube(material, 100, 100, 100, 11, 7, 25, false);
//			_cube.scaleX = 1.5;
//			_cube.scaleY = 1.2;
//			_cube.scaleZ = 1.3;
			_cube.pivotPoint = new Vector3D(-50, -50, -50);
			_sphere = new Sphere(new ColorMaterial(0xff00ff), 5);
			_sphere.x = -50;
			_sphere.y = -50;
			_sphere.z = -50;
			_view.scene.addChild(_cube);
			_view.scene.addChild(_sphere);

			_light = new PointLight();
			_light.x = -1000;
			_light.y = 1000;
			_light.z = -1000;
			_light.color = 0xffeeaa;

			material.lights = [_light];
			_view.scene.addChild(_light);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
        }

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
		
		
		private function _handleEnterFrame(ev : Event) : void
		{
			//_ctr.rotationX = 20 * Math.sin(getTimer() * 0.002);
			_cube.rotationX += .1;
			_cube.rotationY += .11;
			_cube.rotationZ += .09;
			_view.render();
		}
	}
}