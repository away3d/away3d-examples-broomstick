package
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.LoadingEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.library.AssetLibrary;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF(width="1024", height="576", frameRate="60")]
	public class CelShadingTest extends Sprite
	{
		
		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var EmbeddedOBJ : Class;
		
		private var _view : View3D;
		private var _container : Loader3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;

		public function CelShadingTest()
		{
			_view = new View3D();
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

			Loader3D.enableParsers(Parsers.ALL_BUNDLED);
			
			_container = new Loader3D;
			_container.addEventListener(LoadingEvent.RESOURCE_COMPLETE, onResourceRetrieved);
			_container.parseData(EmbeddedOBJ);
			_container.scale(50);
//			_container.y -= 50;
			_view.scene.addChild(_container);

			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}


		private function onResourceRetrieved(ev : LoadingEvent) : void
		{
			var mesh : Mesh;
			var len : uint = _container.numChildren;
			var material : ColorMaterial = new ColorMaterial(0xe24062 /*0xfbcbc1*/);
			material.ambientColor = 0xaaaaaa; //0xdd5525;
			material.specular = .25;
			material.diffuseMethod = new CelDiffuseMethod(2);
			material.specularMethod = new CelSpecularMethod();
			CelSpecularMethod(material.specularMethod).smoothness = .2;
			CelDiffuseMethod(material.diffuseMethod).smoothness = .1;
			material.lights = [ _light3 ];

			for (var i : uint = 0; i < len; ++i) {
				mesh = Mesh(_container.getChildAt(i));
				mesh.material = material;
			}
		}


		private function handleEnterFrame(ev : Event) : void
		{
			_container.rotationY += .3;
			_view.render();
		}
	}
}