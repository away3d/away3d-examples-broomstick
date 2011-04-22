package
{
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.SkeletonAnimation;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.containers.View3D;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.events.ResourceEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.utils.WireframeMapGenerator;
	import away3d.entities.Mesh;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;

	[SWF(width="800", height="450", frameRate="60")]
	public class WireframeTest extends Sprite
	{
		private var _view : View3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;

		public static const MESH_NAME : String = "imp";
		public static const ANIM_NAME : String = "idle1";

		private var _mesh : Mesh;
		private var _animationController : SkeletonAnimator;

		public function WireframeTest()
		{
			_view = new View3D;
			_view.antiAlias = 4;
			_light = new PointLight(); // DirectionalLight();
			_light.x = 1000;
			_light.y = 2000;
			_light.z = -2000;
			_light.color = 0xffffff;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 5000;
			_light2.y = 5000;
			_light2.z = 2000;
			_light2.color = 0x1111ff;
			_light3 = new DirectionalLight(-1, -1, 1);
//			_light3.specular = .25;
//			_light3.diffuse = .25;
			_light3.color = 0xffffff;

			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			_view.scene.addChild(_light3);
			this.addChild(_view);

			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved)
			_mesh = Mesh(ResourceManager.instance.getResource("assets/" + MESH_NAME + "/" + MESH_NAME + ".md5mesh"));
			_mesh.scale(4);
			_mesh.y = -150;
			_view.scene.addChild(_mesh);

			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
		}


		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			if (ev.resource == _mesh) {
				var texture : BitmapData = WireframeMapGenerator.generateSolidMap(_mesh, 0xffffff, 2, 0, 0, 512, 512);
				var material : BitmapMaterial = new BitmapMaterial(texture);
				material.bothSides = true;
				material.alpha = .5;
				material.transparent = true;
				material.mipmap = false;
				_mesh.material = material;

				var seq : SkeletonAnimationSequence = SkeletonAnimationSequence(ResourceManager.instance.getResource("assets/" + MESH_NAME + "/" + ANIM_NAME + ".md5anim"));
				seq.name = ANIM_NAME;
			}
			else {
				_animationController = new SkeletonAnimator(SkeletonAnimationState(_mesh.animationState));
				_animationController.addSequence(SkeletonAnimationSequence(ev.resource));
				_animationController.play(ANIM_NAME);
			}
		}

		private function _handleEnterFrame(ev : Event) : void
		{
			if (_mesh) {
				_mesh.rotationY += 1;
			}
			_view.render();
		}
	}
}