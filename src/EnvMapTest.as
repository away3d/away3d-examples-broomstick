package
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.ResourceEvent;
	import away3d.lights.PointLight;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapDiffuseMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.utils.CubeMap;
	import away3d.primitives.SkyBox;
	
	import com.bit101.components.HSlider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	[SWF(width="1024", height="576", frameRate="60")]
	public class EnvMapTest extends Sprite
	{
		private var _view : View3D;

		private var _container : ObjectContainer3D;
		private var _yellowLight : PointLight;
		private var _blueLight : PointLight;
		
		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		[Embed(source="/../embeds/head/Images/Map-COL.jpg")]
		private var Albedo : Class;

		[Embed(source="/../embeds/head/Images/Map-spec.jpg")]
		private var Specular : Class;

		[Embed(source="/../embeds/head/Images/Infinite-Level_02_Tangent_NoSmoothUV.jpg")]
		private var Normals : Class;

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
		
		//signature variables
		private var Signature:Sprite;
		
		//signature swf
		[Embed(source="/../embeds/signature_david_head.swf", symbol="Signature")]
		private var SignatureSwf:Class;
		
		private var _diffuseMap : CubeMap;
		private var _envMap : CubeMap;

		private var _camController : HoverDragController;
		private var _envMapMethod : EnvMapMethod;

		public function EnvMapTest()
		{
			super();

			_view = new View3D();
			_view.camera.x = -300;
			_view.camera.z = 0;
			_view.camera.lookAt(new Vector3D());

			this.addChild(_view);
			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			
			Signature = Sprite(new SignatureSwf());
			Signature.y = stage.stageHeight - Signature.height;
			
			addChild(Signature);
			
			_diffuseMap = new CubeMap(new DiffPosX().bitmapData, new DiffNegX().bitmapData,
					new DiffPosY().bitmapData, new DiffNegY().bitmapData,
					new DiffPosZ().bitmapData, new DiffNegZ().bitmapData);
			_envMap = new CubeMap(new EnvPosX().bitmapData, new EnvNegX().bitmapData,
					new EnvPosY().bitmapData, new EnvNegY().bitmapData,
					new EnvPosZ().bitmapData, new EnvNegZ().bitmapData);

			_yellowLight = new PointLight();
			_yellowLight.color = 0xd2cfb9;
			_yellowLight.x = -450;
			_yellowLight.y = 100;
			_yellowLight.z = 1000;
			_blueLight = new PointLight();
			_blueLight.color = 0x266fc8;
			_blueLight.x = 800;
			_blueLight.z = 800;
			_blueLight.y = 100;

			_camController = new HoverDragController(_view.camera, stage);
			addChild(new AwayStats(_view));
			
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
			_container = ObjectContainer3D(ResourceManager.instance.parseData(new OBJ(), "head", true));
			_container.scale(100);

			_view.scene.addChild(_container);
			_view.scene.addChild(_yellowLight);
			_view.scene.addChild(_blueLight);
			_view.scene.addChild(new SkyBox(_envMap));
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function initControls() : void
		{
			var slider : HSlider = new HSlider();
			slider.x = 20;
			slider.y = 100;
			slider.minimum = 0;
			slider.maximum = 1;
			slider.value = _envMapMethod.alpha;
			slider.addEventListener(Event.CHANGE, onSliderChange);
			slider.addEventListener(MouseEvent.MOUSE_DOWN, stopEvent);
			addChild(slider);
		}

		private function stopEvent(event : MouseEvent) : void
		{
			event.stopImmediatePropagation();
		}

		private function onSliderChange(event : Event) : void
		{
			_envMapMethod.alpha = event.target.value;
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			
			Signature.y = stage.stageHeight - Signature.height;
		}

		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			var mesh : Mesh;
			var len : uint = _container.numChildren;
			var material : BitmapMaterial = new BitmapMaterial(new Albedo().bitmapData);
//			var material : ColorMaterial = new ColorMaterial(0xffffff);
//			material.normalMap = new Normals().bitmapData;
//			material.ambientMethod = new EnvMapAmbientMethod(_diffuseMap);
			material.specularMethod = new FresnelSpecularMethod(true);
			material.lights = [ _blueLight, _yellowLight ];
//			material.diffuseMethod = new EnvMapDiffuseMethod(_diffuseMap);
			material.addMethod(_envMapMethod = new EnvMapMethod(_envMap));
			material.gloss = 10;
//			material.lights = [ _yellowLight, _blueLight ];
			material.specular = .25;
			material.specularMap = new Specular().bitmapData;

			for (var i : uint = 0; i < len; ++i) {
				mesh = Mesh(_container.getChildAt(i));
				mesh.material = material;
			}
			initControls();
		}


		private function _handleEnterFrame(ev : Event) : void
		{
			_container.rotationY += .5;
			//_ctr.rotationX = 20 * Math.sin(getTimer() * 0.002);
			_view.render();
		}
	}
}