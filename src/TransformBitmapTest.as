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

	import away3d.primitives.Sphere;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[SWF(width="800", height="450", frameRate="60")]
	public class TransformBitmapTest extends Sprite
	{
		private var _view : View3D;

		private var _mesh : Sphere;
		private var _material : BitmapMaterial;
		private var _camController:HoverDragController;

		[Embed(source="../embeds/crossColor.jpg")]
		private var Albedo : Class;

		[Embed(source="../embeds/crossnrm.jpg")]
		private var Normals : Class;

		private var _light : PointLight;

		private var _count1 : Number = 0;
		private var _count2 : Number = 0;

		public function TransformBitmapTest()
		{
			_view = new View3D();
			_view.antiAlias = 4;
			addChild(_view);

			_material = new BitmapMaterial(new Albedo().bitmapData);
			_material.repeat = true;
			_material.normalMap = new Normals().bitmapData;
			_material.ambientColor = 0x080820;
			_mesh = new Sphere(_material, 400);
			_view.scene.addChild(_mesh);
			_mesh.rotationY = .01;
			_camController = new HoverDragController(_view.camera, stage);

			_light = new PointLight();
			_light.x = -1000;
			_light.y = 1000;
			_light.z = -1000;
			_light.color = 0xffeeaa;

			_material.lights = [ _light ];
			_view.scene.addChild(_light);

			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		private function handleEnterFrame(ev : Event) : void
		{
			_count1 += .002;
			_count2 += .003;
			_material.scaleU = Math.sin(_count1)*5;
			_material.scaleV = Math.cos(_count2)*5;
			_material.offsetU = _count1*.1;
			_material.offsetV = _count2*.1;
			_material.uvRotation = _count1;
			_view.render();
		}
	}
}