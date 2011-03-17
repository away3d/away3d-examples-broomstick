package
{
	import away3d.containers.View3D;
	import away3d.events.LoaderEvent;
	import away3d.events.ResourceEvent;
	import away3d.lights.LightBase;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loading.AssetLoader;
	import away3d.loading.ResourceManager;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.entities.Mesh;

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.ObjectContainer3D;

	import away3d.materials.utils.CubeMap;
	import away3d.primitives.SkyBox;
	import away3d.primitives.Sphere;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;

	[SWF(width="800", height="450", frameRate="60")]
	public class SSSShadingTest extends Sprite
	{
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
		
		[Embed(source="/../embeds/venusm.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		private var _view : View3D;
		private var _container : ObjectContainer3D;
		private var _camController : HoverDragController;

		private var _light : LightBase;

		private var _envMap : CubeMap;

		public function SSSShadingTest()
		{
			_view = new View3D;
			_light = new PointLight(); // DirectionalLight();
			_light.specular = 1;
			_light.x = -50;
			_light.y = 0;
			_light.z = 2000;

			var sphere : Sphere = new Sphere(new ColorMaterial(0xffff00), 15);

			_light.addChild(sphere);

			_light.color = 0xffeedd;

			_view.scene.addChild(_light);
			this.addChild(_view);

			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved)
			_container = ObjectContainer3D(ResourceManager.instance.parseData(new OBJ(), "head", true));
//			_container.y -= 50;
			_view.scene.addChild(_container);

			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);

			_camController = new HoverDragController(_view.camera, stage);

			_envMap = new CubeMap(new EnvPosX().bitmapData, new EnvNegX().bitmapData,
					new EnvPosY().bitmapData, new EnvNegY().bitmapData,
					new EnvPosZ().bitmapData, new EnvNegZ().bitmapData);
			_view.scene.addChild(new SkyBox(_envMap));
        }

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}


		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			var mesh : Mesh;
			var material : ColorMaterial = new ColorMaterial(0xffffff); //0xd3996b);
			var method : SubsurfaceScatteringDiffuseMethod = new SubsurfaceScatteringDiffuseMethod();
			var len : uint = _container.numChildren;
			method.scattering = .1;
			method.scatterColor = 0xffaa00;
			method.translucency = 5;
			material.ambientColor = 0x202025; //0xdd5525;
			material.diffuseMethod = method;
			material.gloss = 100;
			material.specular = .5;
			material.lights = [ _light ];

			for (var i : uint = 0; i < len; ++i) {
				mesh = Mesh(_container.getChildAt(i));
				mesh.geometry.scale(.25);
				mesh.y -= 300;
				mesh.material = material;
			}
		}

		private var _count : Number = 0;

		private function _handleEnterFrame(ev : Event) : void
		{
			_view.render();
			_light.x = Math.sin(_count)*2000;
			_light.z = Math.cos(_count)*2000;
			_count += .001;
		}
	}
}