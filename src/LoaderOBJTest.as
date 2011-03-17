package
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.ResourceEvent;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	[SWF(width="1280", height="720", frameRate="60", backgroundColor="0x000000")]
	public class LoaderOBJTest extends Sprite
	{
		private var _view : View3D;
		private var _container : ObjectContainer3D;

		private var _light : PointLight;

		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;

		[Embed(source="/../embeds/head/Images/Map-COL.jpg")]
		private var Albedo : Class;

		[Embed(source="/../embeds/head/Images/Map-spec.jpg")]
		private var Specular : Class;

		[Embed(source="/../embeds/head/Images/Infinite-Level_02_Tangent_NoSmoothUV.jpg")]
		private var Normal : Class;

		//signature variables
		private var Signature : Sprite;

		//signature swf
		[Embed(source="/../embeds/signature_david_head.swf", symbol="Signature")]
		private var SignatureSwf : Class;

		private var _camController : HoverDragController;
		private var _count : Number = 0;
		private var _subsurfaceMethod : SubsurfaceScatteringDiffuseMethod;
		private var _diffuseMethod : BasicDiffuseMethod;
		private var _material : BitmapMaterial;
		private var _fresnelMethod : FresnelSpecularMethod;
		private var _specularMethod : BasicSpecularMethod;

		public function LoaderOBJTest()
		{
			_view = new View3D();
			_view.antiAlias = 4;
			this.addChild(_view);

			Signature = Sprite(new SignatureSwf());
			Signature.y = stage.stageHeight - Signature.height;

			addChild(Signature);

			_light = new PointLight();
			_light.x = 15000;
			_light.z = 15000;
			_light.color = 0xffddbb;
			_view.scene.addChild(_light);
			_camController = new HoverDragController(_view.camera, stage);
			addChild(new AwayStats(_view));
			initMesh();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
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

		private function initMesh() : void
		{
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
//			_container = ObjectContainer3D(ResourceManager.instance.getResource("head/head.obj"));
			_container = ObjectContainer3D(ResourceManager.instance.parseData(new OBJ(), "head", true));
			_container.y = -50;
			_view.scene.addChild(_container);

			_material = new BitmapMaterial(new Albedo().bitmapData);
			_subsurfaceMethod = new SubsurfaceScatteringDiffuseMethod(2048, 2);
			_diffuseMethod = new BasicDiffuseMethod();
			_fresnelMethod = new FresnelSpecularMethod(true);
			_specularMethod = new BasicSpecularMethod();
			_material.normalMap = new Normal().bitmapData;
			_material.specularMap = new Specular().bitmapData;
			_material.lights = [ _light ];
			_material.gloss = 10;
			_material.specular = 3;
			_material.ambientColor = 0x303040;
			_subsurfaceMethod.scatterColor = 0xff7733; //0xff9966;
			_subsurfaceMethod.scattering = .05;
			_subsurfaceMethod.translucency = 4;
			_material.diffuseMethod = _subsurfaceMethod;
			_material.specularMethod = _fresnelMethod;
		}

		private function onResourceRetrieved(event : ResourceEvent) : void
		{
			var mesh : Mesh;
			for (var i : int = 0; i < _container.numChildren; ++i) {
				mesh = Mesh(_container.getChildAt(i));
				mesh.geometry.scale(100);
				mesh.material = _material
			}
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			_material.diffuseMethod = _material.diffuseMethod == _diffuseMethod ? _subsurfaceMethod : _diffuseMethod;
//            _material.specularMethod = _material.specularMethod == _specularMethod? _fresnelMethod : _specularMethod;
		}

		private function onEnterFrame(ev : Event) : void
		{
			_count += .003;
//			_container.rotationY += .3;

			_light.x = Math.sin(_count) * 150000;
			_light.y = 1000;
			_light.z = Math.cos(_count) * 150000;

			_view.render();
		}
	}
}