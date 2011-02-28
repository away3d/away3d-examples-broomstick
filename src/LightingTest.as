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
    import away3d.primitives.Plane;
    import away3d.primitives.Sphere;
    import away3d.entities.Mesh;

	import away3d.containers.ObjectContainer3D;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;

	[SWF(width="800", height="450", frameRate="60")]
	public class LightingTest extends Sprite
	{
		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		private var _view : View3D;
		private var _container : ObjectContainer3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;
		private var _mesh : Mesh;

		public function LightingTest()
		{
			_view = new View3D;
			_light = new PointLight(); // DirectionalLight();
//			_light.x = -5000;
//			_light.y = 5000;
			_light.z = 10000;

			_light.color = 0xff1111;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 5000;
			_light2.y = 5000;
			_light2.z = -2000;
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
			var material : ColorMaterial = new ColorMaterial(0xfff0dd);

			material.gloss = 50;
			material.lights = [_light2, _light, _light3];
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
			_container.rotationY += 2;
			_view.render();
		}
	}
}