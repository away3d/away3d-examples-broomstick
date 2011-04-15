package
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.ResourceEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(width="1024", height="576", frameRate="60")]
	public class LightingTest extends Sprite
	{
		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;

		[Embed(source="/../embeds/head/Images/Map-COL.jpg")]
		private var Albedo : Class;

		[Embed(source="/../embeds/head/Images/Map-spec.jpg")]
		private var Specular : Class;

		[Embed(source="/../embeds/head/Images/Infinite-Level_02_Tangent_NoSmoothUV.jpg")]
		private var Normal : Class;

		private var _view : View3D;
		private var _container : ObjectContainer3D;

		private var _light : PointLight;
		private var _light2 : PointLight;
		private var _light3 : LightBase;
		private var _mesh : Mesh;
		private var _camController : HoverDragController;

		public function LightingTest()
		{
			_view = new View3D();
			_view.antiAlias = 4;
			_light = new PointLight(); // DirectionalLight();
			_light.x = -5000;
			_light.y = 5000;
			_light.z = 10000;
			//			_light.radius = 2000;
			//			_light.fallOff = 3000;
			_light.color = 0xff1111;

			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 5000;
			_light2.y = 5000;
			_light2.z = -10000;
			//			_light2.radius = 2000;
			//			_light2.fallOff = 3000;
			_light2.color = 0x1111ff;

			_light3 = new DirectionalLight(0, -1, 1);
			_light3.specular = 1;
			_light3.diffuse = 1;
			_light3.color = 0xffffff;

			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			_view.scene.addChild(_light3);
			this.addChild(_view);

			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved)
			_container = ObjectContainer3D(ResourceManager.instance.parseData(new OBJ(), "head", true));
			_container.scale(50);
			_view.scene.addChild(_container);

			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);

			_camController = new HoverDragController(_view.camera, stage);
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}

		private function onClick(event : MouseEvent) : void
		{
			_mesh.geometry.subGeometries[0].useFaceWeights = !_mesh.geometry.subGeometries[0].useFaceWeights;
		}


		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			var mesh : Mesh;
			var len : uint = _container.numChildren;
			var material : BitmapMaterial = new BitmapMaterial(new Albedo().bitmapData);
			material.normalMap = new Normal().bitmapData;
			material.specularMap = new Specular().bitmapData;
			material.specular = .5;
			material.gloss = 50;
			material.lights = [_light, _light2, _light3];
			//			material.specularMethod = null;

			for (var i : uint = 0; i < len; ++i) {
				mesh = Mesh(_container.getChildAt(i));
				mesh.material = material;
				mesh.geometry.subGeometries[0].autoDeriveVertexNormals = true;
				mesh.geometry.subGeometries[0].autoDeriveVertexTangents = true;
			}
			_mesh = mesh;
		}


		private function _handleEnterFrame(ev : Event) : void
		{
			_container.rotationY += 0.3;
			_view.render();
		}
	}
}