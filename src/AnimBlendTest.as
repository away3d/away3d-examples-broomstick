package
{
	import away3d.animators.BlendingSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.animators.skeleton.SkeletonUtils;
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.materials.BitmapMaterial;
	
	import com.bit101.components.HSlider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;

	use namespace arcane;

	[SWF(width="1024", height="576", frameRate="60", backgroundColor="0x000000")]
	public class AnimBlendTest extends Sprite
	{
		private var _view : View3D;

		private var _light : PointLight;
		private var _light2 : PointLight;
		private var _light3 : LightBase;
		private var _loader : Loader3D;
		
		private var _targetLookAt : Vector3D;
		private var _count : Number = 0;

		[Embed(source="../embeds/lost.jpg")]
		private var Skin : Class;

		[Embed(source="../embeds/lost_teeth.png")]
		private var Teeth : Class;

		[Embed(source="../embeds/lost_s.jpg")]
		private var Spec : Class;

		[Embed(source="../embeds/lost_norm.jpg")]
		private var Norm : Class;

		private var _mesh : Mesh;
		private var _animationController : BlendingSkeletonAnimator;
		private var _sliders : Vector.<HSlider> = new Vector.<HSlider>();
		private var _camController : HoverDragController;

		public static const MESH_NAME : String = "lostsoul";
		public static const ANIM_NAMES : Array = [ "sight", "attack2", "attack1", "pain1", "pain2" ];
		
		//signature variables
		private var Signature:Sprite;
		
		//signature swf
		[Embed(source="/../embeds/signature_david.swf", symbol="Signature")]
		private var SignatureSwf:Class;


		public function AnimBlendTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			initView();
			loadResources();
			initControls();
			
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);

		}

		private function initControls() : void
		{
			for (var i : int = 0; i <= ANIM_NAMES.length; ++i)
				addSlider(true);
			addSlider(false);
		}

		private function addSlider(add : Boolean) : void
		{
			var slider : HSlider = new HSlider();
			slider.x = 20;
			slider.y = 200+30*_sliders.length;
			slider.addEventListener(Event.CHANGE, onSliderChange);
			slider.addEventListener(MouseEvent.MOUSE_DOWN, stopEvent);

			addChild(slider);
			if (add) {
				_sliders.push(slider);
				slider.minimum = 0;
				slider.maximum = 1;
			}
			else {
				slider.minimum = -1;
				slider.maximum = 1;
				slider.value = 1;
			}
		}

		private function stopEvent(event : MouseEvent) : void
		{
			event.stopImmediatePropagation();
		}

		private function onSliderChange(event : Event) : void
		{
			var index : int = _sliders.indexOf(event.target);
			if (index >= 0)
				_animationController.setWeight(ANIM_NAMES[index], event.target.value);
			else
				_animationController.timeScale = event.target.value;
		}

		private function loadResources() : void
		{
			AssetLibrary.enableParser(MD5MeshParser);
			AssetLibrary.enableParser(MD5AnimParser);
			
			_loader = new Loader3D();
			_loader.addEventListener(AssetEvent.ASSET_COMPLETE, onMeshComplete);
			_loader.load(new URLRequest("assets/" + MESH_NAME + "/" + MESH_NAME + ".md5mesh"));
			
			_loader.y = 0;
			_loader.scale(25);
			_view.scene.addChild(_loader);

		}

		private function onMeshComplete(event : AssetEvent) : void
		{
			if (event.asset.assetType == AssetType.MESH) {
				_mesh = _loader.handle as Mesh;
				_animationController = new BlendingSkeletonAnimator(SkeletonAnimationState(_mesh.animationState));
				var material : BitmapMaterial = new BitmapMaterial(new Teeth().bitmapData);
				material.lights = [ _light2, _light3 ];
				material.specular = 2;
				material.transparent = true;
				material.ambientColor = 0x202030;
				_mesh.subMeshes[0].material = material;
		
				material = new BitmapMaterial(new Skin().bitmapData);
				material.lights = [ _light2, _light3 ];
				material.gloss = 20;
				material.specular = 2;
				material.ambientColor = 0x202030;
				material.specularMap = new Spec().bitmapData;
				material.normalMap = new Norm().bitmapData;
				_mesh.material = material;
				loadAnimations();
			}
		}
		
		private function onAnimationComplete(event : AssetEvent) : void
		{
			var diffClip : SkeletonAnimationSequence;
			
			if(event.asset.assetNamespace == ANIM_NAMES[0]) {
				diffClip = SkeletonUtils.generateDifferenceClip(	SkeletonAnimationSequence(event.asset),
																	SkeletonAnimationSequence(event.asset)._frames[0]);
				diffClip.name = "additionClip";
				_animationController.addSequence(diffClip);
				ANIM_NAMES[5] = diffClip.name;
			}
			
			var seq : SkeletonAnimationSequence = event.asset as SkeletonAnimationSequence;
			
			seq.name = event.asset.assetNamespace;
			_animationController.addSequence(seq);
			if (event.asset.assetNamespace == "sight") _animationController.play();
			
		}
		
		private function loadAnimations() : void
		{
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAnimationComplete);
			
			for (var i : uint = 0; i < ANIM_NAMES.length; ++i) {
				AssetLibrary.load(new URLRequest("assets/" + MESH_NAME + "/" + ANIM_NAMES[i] + ".md5anim"), null, null, ANIM_NAMES[i]);
			}
		}

		private function initView() : void
		{
			_view = new View3D();
			_view.camera.lookAt(_targetLookAt = new Vector3D());
			addChild(new AwayStats(_view));
			_light = new PointLight(); // DirectionalLight();
			addChild(_view);
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 1000;
			_light2.y = 100;
			_light2.z = 100;
			_light2.color = 0x8080ff;
			_light3 = new DirectionalLight(10, -10, 10);
			_light3.color = 0xffffee;

//			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			_view.scene.addChild(_light3);

			_camController = new HoverDragController(_view.camera, stage);

			Signature = Sprite(new SignatureSwf());
			Signature.y = stage.stageHeight - Signature.height;
			addChild(Signature);

			addChild(new AwayStats(_view));
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			
			Signature.y = stage.stageHeight - Signature.height;
		}

		private function handleEnterFrame(ev : Event) : void
		{
//			var mesh : Mesh = _controller.mesh;
//			_controller.update();
//			_targetLookAt.x = _targetLookAt.x + (mesh.x - _targetLookAt.x)*.03;
//			_targetLookAt.y = _targetLookAt.y + (mesh.y - _targetLookAt.y)*.03;
//			_targetLookAt.z = _targetLookAt.z + (mesh.z - _targetLookAt.z)*.03;
//			_view.camera.lookAt(_targetLookAt);

			_count += .01;
//			_light.x = Math.sin(_count) * 1500;
//			_light.y = 250 + Math.sin(_count * .54) * 200;
//			_light.z = Math.cos(_count * .7) * 1500;
//			_light2.x = -Math.sin(_count * .8) * 1500;
//			_light2.y = 250 - Math.sin(_count * .65) * 200;
//			_light2.z = -Math.cos(_count * .9) * 1500;
			_view.render();
		}
	}
}