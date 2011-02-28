package
{
    import away3d.containers.View3D;
    import away3d.animators.SkeletonAnimator;
	import away3d.animators.VertexAnimator;
	import away3d.events.ResourceEvent;
    import away3d.lights.DirectionalLight;
    import away3d.lights.LightBase;
    import away3d.lights.PointLight;
    import away3d.loading.AssetLoader;
    import away3d.loading.ResourceManager;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.methods.EnvMapDiffuseMethod;
	import away3d.materials.utils.CubeMap;
	import away3d.primitives.SkyBox;
	import away3d.entities.Mesh;

    import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.setTimeout;

	[SWF(width="800", height="450", frameRate="60", backgroundColor="0x000000")]
    public class LoaderMD2Test extends Sprite
    {
        private var _view : View3D;
        private var _mesh : Mesh;

        [Embed(source="/../embeds/ogrespec.jpg")]
        private var Spec : Class;
        [Embed(source="/../embeds/ogrebump_NRM.png")]
        private var Norm : Class;
		[Embed(source="/../embeds/audio.mp3")]
		private var Audio : Class;

		[Embed(source="/../embeds/envMap/arch_positive_x.jpg")]
		private var EnvPosX : Class;

		[Embed(source="/../embeds/envMap/arch_positive_y.jpg")]
		private var EnvPosY : Class;

		[Embed(source="/../embeds/envMap/arch_positive_z.jpg")]
		private var EnvPosZ : Class;

		[Embed(source="/../embeds/envMap/arch_negative_x.jpg")]
		private var EnvNegX : Class;

		[Embed(source="/../embeds/envMap/arch_negative_y.jpg")]
		private var EnvNegY : Class;

		[Embed(source="/../embeds/envMap/arch_negative_z.jpg")]
		private var EnvNegZ : Class;

		[Embed(source="/../embeds/diffuseEnvMap/night_m04_posX.jpg")]
		private var DiffPosX : Class;

		[Embed(source="/../embeds/diffuseEnvMap/night_m04_posY.jpg")]
		private var DiffPosY : Class;

		[Embed(source="/../embeds/diffuseEnvMap/night_m04_posZ.jpg")]
		private var DiffPosZ : Class;

		[Embed(source="/../embeds/diffuseEnvMap/night_m04_negX.jpg")]
		private var DiffNegX : Class;

		[Embed(source="/../embeds/diffuseEnvMap/night_m04_negY.jpg")]
		private var DiffNegY : Class;

		[Embed(source="/../embeds/diffuseEnvMap/night_m04_negZ.jpg")]
		private var DiffNegZ : Class;

        private var _resourceManager : ResourceManager;
		private var _envMap : CubeMap;
		private var _diffuseMap : CubeMap;
		private var _timeScale : Number = 3;

        public function LoaderMD2Test()
        {
            _resourceManager = ResourceManager.instance;
            _view = new View3D;
			_view.camera.lens.far = 30000;
            this.addChild(_view);

			Sound(new Audio()).play(0, int.MAX_VALUE, new SoundTransform(.25));
			_envMap = new CubeMap(	new EnvPosX().bitmapData,  new EnvNegX().bitmapData,
									new EnvPosY().bitmapData,  new EnvNegY().bitmapData,
									new EnvPosZ().bitmapData,  new EnvNegZ().bitmapData);
			_diffuseMap = new CubeMap(	new DiffPosX().bitmapData,  new DiffNegX().bitmapData,
										new DiffPosY().bitmapData,  new DiffNegY().bitmapData,
										new DiffPosZ().bitmapData,  new DiffNegZ().bitmapData);
			_view.scene.addChild(new SkyBox(_envMap));
			initMesh();
            initAnimation();
			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
        }

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}

		private function initMesh() : void
		{
			var material : DefaultMaterialBase;
			_mesh = Mesh(_resourceManager.getResource("assets/ogre.md2"));
			_mesh.scaleX = 12;
            _mesh.scaleY = 12;
            _mesh.scaleZ = 12;
			_mesh.y = -300;
			_view.scene.addChild(_mesh);

			material = DefaultMaterialBase(_mesh.material);
            material.specularMap = new Spec().bitmapData;
            material.normalMap = new Norm().bitmapData;
			material.diffuseMethod = new EnvMapDiffuseMethod(_diffuseMap);
		}

		private function initAnimation() : void
		{
			var controller : VertexAnimator = VertexAnimator(_mesh.animationController);
			controller.play("run");
			controller.timeScale = _timeScale;
		}

        private function _handleEnterFrame(ev : Event) : void
        {
            if (_mesh) {
                _mesh.rotationY += 1;
				_mesh.moveRight(2*_timeScale);
				_view.camera.lookAt(_mesh.position);
			}
            _view.render();
        }
    }
}