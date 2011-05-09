package
{
	import away3d.animators.VertexAnimator;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoadingEvent;
	import away3d.library.assets.AssetType;
	import away3d.library.AssetLibrary;
	import away3d.loaders.parsers.MD2Parser;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.methods.EnvMapDiffuseMethod;
	import away3d.materials.utils.CubeMap;
	import away3d.primitives.SkyBox;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	[SWF(width="1024", height="576", frameRate="60", backgroundColor="0x000000")]
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
		
		private var _envMap : CubeMap;
		private var _timeScale : Number = 3;
		
		public function LoaderMD2Test()
		{
			init3D();

			//Sound(new Audio()).play(0, int.MAX_VALUE, new SoundTransform(.25));

			initLoad();

			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function init3D() : void
		{
			_view = new View3D();
			_view.antiAlias = 4;
			_view.camera.lens.far = 30000;
			addChild(_view);

			_envMap = new CubeMap(	new EnvPosX().bitmapData,  new EnvNegX().bitmapData,
									new EnvPosY().bitmapData,  new EnvNegY().bitmapData,
									new EnvPosZ().bitmapData,  new EnvNegZ().bitmapData);

			_view.scene.addChild(new SkyBox(_envMap));
		}
		
		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
		
		private function initLoad() : void
		{
			AssetLibrary.enableParser(MD2Parser);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetRetrieved);
			AssetLibrary.load(new URLRequest('assets/ogre.md2'));
		}
		
		private function onAssetRetrieved(event : AssetEvent) : void
		{
			if (event.asset.assetType == AssetType.MESH) {
				var material : DefaultMaterialBase;
				var diffuseMap : CubeMap;

				_mesh = Mesh(event.asset);
				_mesh.scaleX = 12;
				_mesh.scaleY = 12;
				_mesh.scaleZ = 12;
				_mesh.y = -300;
				_view.scene.addChild(_mesh);
			
				material = DefaultMaterialBase(_mesh.material);
				material.specularMap = new Spec().bitmapData;
				material.normalMap = new Norm().bitmapData;
	
				diffuseMap = new CubeMap(	new DiffPosX().bitmapData,  new DiffNegX().bitmapData,
											new DiffPosY().bitmapData,  new DiffNegY().bitmapData,
											new DiffPosZ().bitmapData,  new DiffNegZ().bitmapData);
	
				material.diffuseMethod = new EnvMapDiffuseMethod(diffuseMap);
			}
			else if (event.asset.assetType == AssetType.ANIMATOR) {
				var controller : VertexAnimator = VertexAnimator(event.asset);
				controller.play("run");
				controller.timeScale = _timeScale;
			}
		}

		private function handleEnterFrame(ev : Event) : void
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