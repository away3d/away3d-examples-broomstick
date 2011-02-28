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

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;

	[SWF(width="800", height="450", frameRate="60")]
	public class SSSShadingTest extends Sprite
	{
		
		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		private var _view : View3D;
		private var _container : ObjectContainer3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;

		public function SSSShadingTest()
		{
			_view = new View3D;
			_light = new PointLight(); // DirectionalLight();
			_light.specular = 1;
//			_light.x = 1000;
//			_light.y = 2000;
			_light.z = 3000;
			_light.color = 0xffeedd;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 5000;
			_light2.y = 5000;
			_light2.z = 2000;
			_light2.color = 0x1111ff;
			_light3 = new DirectionalLight(0, 0, 1);
			_light3.specular = .25;
			_light3.diffuse = .25;
			_light3.color = 0xffffff;

			_view.scene.addChild(_light);
//			_view.scene.addChild(_light2);
//			_view.scene.addChild(_light3);
			this.addChild(_view);

			/*loader = new AssetLoader;
			loader.addEventListener(LoaderEvent.LOAD_COMPLETE, _handleLoaderLoadComplete);
			loader.load(new URLRequest('output.awd'));*/

			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved)
			_container = ObjectContainer3D(ResourceManager.instance.parseData(new OBJ(), "head", true));
//			_container.y -= 50;
			_view.scene.addChild(_container);

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


		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			var mesh : Mesh;
			var material : ColorMaterial = new ColorMaterial(0x0c4a18); //0xd3996b);
			var method : SubsurfaceScatteringDiffuseMethod = new SubsurfaceScatteringDiffuseMethod();
			var len : uint = _container.numChildren;
			method.scattering = .25;
			method.scatterColor = 0x78b911;
			method.translucency = 2;
			material.ambientColor = 0x202025; //0xdd5525;
			material.diffuseMethod = method;
			material.gloss = 100;
			material.specular = .5;
			material.lights = [ _light ];

			for (var i : uint = 0; i < len; ++i) {
				mesh = Mesh(_container.getChildAt(i));
				mesh.geometry.scale(50);
				mesh.material = material;
			}
		}

		private var _count : Number = 0;

		private function _handleEnterFrame(ev : Event) : void
		{
			if (_container) {
				_container.rotationY += 1;
//				_mesh0.rotationX += 1;

				_count += .01;

				_light.x = Math.sin(_count)*5000;
//				_light.y = Math.sin(_count*.7)*5000;
				_light.z = Math.cos(_count)*5000;
			}
			_view.render();

		}
	}
}