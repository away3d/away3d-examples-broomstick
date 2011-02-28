package
{
	import away3d.containers.View3D;
	import away3d.animators.data.AnimationSequenceBase;
	import away3d.animators.data.AnimationSequenceBase;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.debug.AwayStats;
	import away3d.events.LoaderEvent;
	import away3d.events.ResourceEvent;
	import away3d.lights.LightBase;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loading.AssetLoader;
	import away3d.loading.ResourceManager;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.entities.Mesh;

	import away3d.containers.ObjectContainer3D;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	[SWF(width="800", height="450", frameRate="60")]
	public class MD5StressTest extends Sprite
	{
		private static const NUM_MESHES_X : Number = 5;
		private static const NUM_MESHES_Y : Number = 5;
		private static const NUM_MESHES_Z : Number = 5;
		private static const SPACING_X : Number = 120;
		private static const SPACING_Y : Number = 100;
		private static const SPACING_Z : Number = 120;

		private var _view : View3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;

		private var _count : Number = 0;
		private var _container : ObjectContainer3D;

		[Embed(source="/../embeds/lost.jpg")]
		private var Skin : Class;

		[Embed(source="/../embeds/lost_teeth.png")]
		private var Teeth : Class;

		[Embed(source="/../embeds/lost_s.jpg")]
		private var Spec : Class;

		[Embed(source="/../embeds/lost_norm.jpg")]
		private var Norm : Class;
		
		//signature variables
		private var Signature:Sprite;
		
		//signature swf
		[Embed(source="/../embeds/signature_david.swf", symbol="Signature")]
		private var SignatureSwf:Class;
		
		public static const MESH_NAME : String = "lostsoul";
		public static const ANIM_NAMES : Array = [ "sight", "attack2", "attack1", "pain1", "pain2" ];

        private var _sourceMesh : Mesh;
        private var _meshes : Vector.<Mesh>;
        private var _textField : TextField;
		private var _resourceCount : int;

		public function MD5StressTest()
		{
			_view = new View3D();
			addChild(new AwayStats(_view));

			_textField = new TextField();
			_textField.width = 200;
			_textField.x = stage.stageWidth-200;
			_textField.y = 20;
			_textField.textColor = 0xffffff;
			_textField.text = "Loading MD5 Mesh...";
			addChild(_textField);
			
			Signature = Sprite(new SignatureSwf());
			Signature.y = stage.stageHeight - Signature.height;
			
			addChild(Signature);

			_light = new PointLight(); // DirectionalLight();
			this.addChild(_view);
			_light.x = -5000;
			_light.y = 1000;
			_light.z = 7000;
			_light.color = 0xff1111;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 5000;
			_light2.y = 1000;
			_light2.z = 7000;
			_light2.color = 0x1111ff;
			_light3 = new DirectionalLight(0, 50, 1);
//			_light3.diffuse = .25;
//			_light3.specular = .25;
			_light3.color = 0xffeeaa;

			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			_view.scene.addChild(_light3);

			loadResources();
			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
        }

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			
			Signature.y = stage.stageHeight - Signature.height;
		}

		private function loadResources() : void
		{
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);

			_sourceMesh = Mesh(ResourceManager.instance.getResource("assets/" + MESH_NAME+"/"+MESH_NAME+".md5mesh"));
			_sourceMesh.y = 0;
            _sourceMesh.scale(3);

			loadAnimations();
		}

		private function loadAnimations() : void
		{
			for (var i : uint = 0; i < ANIM_NAMES.length; ++i) {
				var seq : SkeletonAnimationSequence = SkeletonAnimationSequence(ResourceManager.instance.getResource("assets/" + MESH_NAME+"/"+ANIM_NAMES[i]+".md5anim"));
				seq.name = ANIM_NAMES[i];
				SmoothSkeletonAnimator(_sourceMesh.animationController).addSequence(seq);
			}
		}

		private function onResourceRetrieved(event : ResourceEvent) : void
		{
			if (event.resource == _sourceMesh) {
				initMaterials();
				cloneMeshes();
			}

			_textField.text = "Retrieved resource "+event.resource.name;

			if (++_resourceCount > ANIM_NAMES.length) {
				_textField.text = "All resources retrieved";

				// start animations randomly
				for (var i : uint = 0; i < _meshes.length; ++i)
					setTimeout(SmoothSkeletonAnimator(_meshes[i].animationController).play, Math.random()*3000, ANIM_NAMES[int(Math.random()*ANIM_NAMES.length)]);
			}
		}

		private function initMaterials() : void
		{
			var material : BitmapMaterial = new BitmapMaterial(new Teeth().bitmapData);
			material.lights = [ _light, _light2, _light3 ];
			material.specular = .2;
			material.transparent = true;
			_sourceMesh.subMeshes[0].material = material;

			material = new BitmapMaterial(new Skin().bitmapData);
			material.lights = [ _light, _light2, _light3 ];
			material.ambientColor = 0x101020;
			material.specularMap = new Spec().bitmapData;
			material.normalMap = new Norm().bitmapData;
            _sourceMesh.material = material;
		}

		private function cloneMeshes() : void
		{
            _meshes = new Vector.<Mesh>();
            _container = new ObjectContainer3D();
            var i : int;
            var clone : Mesh;
            for (var x : int = 0; x < NUM_MESHES_X; ++x) {
                for (var y : int = 0; y < NUM_MESHES_X; ++y) {
                    for (var z : int = 0; z < NUM_MESHES_X; ++z) {
                        clone = Mesh(_sourceMesh.clone());
                        _meshes[i++] = clone;
                        clone.x = (x-(NUM_MESHES_X-1)*.5)*SPACING_X;
                        clone.y = (y-(NUM_MESHES_Y-1)*.5)*SPACING_Y;
                        clone.z = (z-(NUM_MESHES_Z-1)*.5)*SPACING_Z;
                        _container.addChild(clone);
                    }
                }
            }

			_view.scene.addChild(_container);
		}

		private function _handleEnterFrame(ev : Event) : void
		{
			if (_container) _container.rotationY = _count;
			_view.render();
			_count += 1;
		}
	}
}