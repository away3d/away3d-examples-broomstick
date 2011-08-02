package
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.utils.CubeMap;
	import away3d.primitives.Plane;
	import away3d.primitives.SkyBox;
	
	import flash.display.BitmapData;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	[SWF(width="1024", height="576", frameRate="60")]
	public class WaterTest extends Sprite
	{
		private var _view : View3D;

		private var _yellowLight : PointLight;
		private var _blueLight : PointLight;
		
		[Embed(source="/../embeds/w_normalmap.jpg")]
		private var WaterNormals1 : Class;


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
		private var _envMapMethod : FresnelEnvMapMethod;
		private var _normalMethod : SimpleWaterNormalMethod;
		private var _plane : Plane;

		public function WaterTest()
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
			
			_envMap = new CubeMap(	new EnvPosX().bitmapData, new EnvNegX().bitmapData,
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
			_view.camera.lens.far = 15000;
			addChild(new AwayStats(_view));
			
			_plane = new Plane(null, 15000, 15000, 1, 1, false);
			_plane.geometry.subGeometries[0].scaleUV(5);
			_view.scene.addChild(_plane);
			_view.scene.addChild(_yellowLight);
			_view.scene.addChild(_blueLight);
			_view.scene.addChild(new SkyBox(_envMap));
			initMaterial();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
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

		private function initMaterial() : void
		{
			var material : BitmapMaterial = new BitmapMaterial(new BitmapData(512, 512, true, 0xaa404070));
			material.alphaBlending = true;
			material.lights = [ _blueLight, _yellowLight ];
			material.repeat = true;
			material.normalMethod = _normalMethod = new SimpleWaterNormalMethod(new WaterNormals1().bitmapData, new WaterNormals1().bitmapData);
			material.addMethod(_envMapMethod = new FresnelEnvMapMethod(_envMap));
			_envMapMethod.normalReflectance = .2;
			material.specularMethod = new FresnelSpecularMethod();
			FresnelSpecularMethod(material.specularMethod).normalReflectance = .3;
			material.gloss = 100;
			material.specular = 1;

			_plane.material = material;
		}


		private function _handleEnterFrame(ev : Event) : void
		{
			//_ctr.rotationX = 20 * Math.sin(getTimer() * 0.002);
			if (_normalMethod) {
				_normalMethod.water1OffsetX += .001;
				_normalMethod.water1OffsetY += .001;
				_normalMethod.water2OffsetX += .0007;
				_normalMethod.water2OffsetY += .0006;
			}
//			if (stage.stage3Ds[0].context3D)
//				stage.stage3Ds[0].context3D.setScissorRectangle(new Rectangle(0, 0, 50, 50));
			_view.render();
		}
	}
}