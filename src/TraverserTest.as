package
{
	import away3d.containers.View3D;
	import away3d.core.render.PositionRenderer;
	import away3d.debug.AwayStats;
	import away3d.events.MouseEvent3D;
	import away3d.lights.LightBase;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	import away3d.materials.MaterialLibrary;
	import away3d.primitives.Plane;
	import away3d.entities.Mesh;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.Security;

	[SWF(width="1024", height="576", frameRate="60", backgroundColor=0x000000)]
	public class TraverserTest extends Sprite
	{
		private var _planes : Vector.<Mesh>;
		private var _view : View3D;
		private var _numPlanes : int = 1000;

		[Embed(source="/../embeds/set1/Diffuse Map.jpg")]
		private var TextureAsset : Class;

		[Embed(source="/../embeds/set1/Normal Map.jpg")]
		private var NormalMap2 : Class;

		[Embed(source="/../embeds/set1/SpecStrength Map.jpg")]
		private var SpecularMap : Class;

		[Embed(source="/../embeds/docwallorigin2dt.jpg")]
		private var NormalMapAsset : Class;

		private var _material1 : DefaultMaterialBase;
		private var _material2 : DefaultMaterialBase;
		private var _materialName : String;
		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _count : Number = 0;
		private var _light3 : LightBase;
		private var _materialLibrary : MaterialLibrary;

		public function TraverserTest()
		{
			Security.allowDomain("*");
			stage.quality = StageQuality.HIGH;
			initScene3D();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_materialLibrary = MaterialLibrary.getInstance();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
        }

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}

		// kept for reference
		private function onClick(event : MouseEvent) : void
		{
			var sw : MaterialBase = _material1;
			_material1 = DefaultMaterialBase(_materialLibrary.getMaterial(_materialName));
			_materialLibrary.setMaterial(_materialName, sw);
		}

		private function onEnterFrame(event : Event) : void
		{
			for (var i : int = 0; i < _numPlanes; ++i) {
				var plane : Mesh = _planes[i];
				plane.rotationX += .5;
				if (plane.extra.speed > .01)
					plane.rotationY += plane.extra.speed;
				plane.rotationZ += .4;
				plane.extra.speed *= .98;
			}

			_view.camera.rotationX += .09;
			_view.camera.rotationY += .1;
			_view.camera.rotationZ += .08;

			_light.x = _view.camera.x;//+10000*Math.cos(_count);
			_light.y = _view.camera.y;//+10000*Math.cos(_count*.9);
			_light.z = _view.camera.z;//+10000*Math.cos(_count*1.1);
			_light2.x = _view.camera.x+10000*Math.sin(_count*1.3);
			_light2.y = _view.camera.y+10000*Math.sin(_count*.87);
			_light2.z = _view.camera.z+10000*Math.sin(_count*.667);

			_count += .03;
			_view.render();
		}

		private function initScene3D() : void
		{
			_material2 = new ColorMaterial(0xffffff);/*new BitmapMaterial(new Asset().bitmapData);*/
			_material2.normalMap = new NormalMapAsset().bitmapData;
			_material2.ambientColor = 0x111122;
			ColorMaterial(_material2).alpha = .5;
			_material2.gloss = 250;
			_material1 = new BitmapMaterial(new TextureAsset().bitmapData);
			_material1.normalMap = new NormalMap2().bitmapData;
			_material1.specularMap = new SpecularMap().bitmapData;
			_materialName = _material2.name;
			_planes = new Vector.<Mesh>();
			_view = new View3D();
//			_view.depthPrepass = true;
			var srcplane : Mesh = new Plane(_material1, 500, 500, 30, 30);
			for (var i : int = 0; i < _numPlanes; ++i) {
				var plane : Mesh = Mesh(srcplane.clone());
				plane.material = Math.random() > .5? _material1 : _material2;
				plane.rotationX = Math.random()*360;
				plane.rotationY = Math.random()*360;
				plane.rotationZ = Math.random()*360;
				plane.x = (Math.random()-.5)*10000;
				plane.y = (Math.random()-.5)*10000;
				plane.z = (Math.random()-.5)*10000;
				plane.extra = { speed: 0 };
				plane.mouseEnabled = true;
				plane.mouseDetails = true;
				plane.addEventListener(MouseEvent3D.MOUSE_MOVE, onPlaneMove);
				plane.addEventListener(MouseEvent3D.CLICK, onPlaneClick);
				_view.scene.addChild(plane);
				_view.scene.addChild(plane);
				_planes.push(plane);
			}
//			plane.addChild(_view.camera);

			_view.camera.lens.far = 10000;
			_view.backgroundColor = 0x000000;
			addChild(_view);

			if (Capabilities.os.toLowerCase().indexOf("windows") != -1)
				_view.antiAlias = 4;

			_light = new PointLight(); // DirectionalLight();
			_light.color = 0xff1111;
//			_light.diffuse = .5;
//			_light.specular = .5;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.color = 0x1111ff;
			_light3 = new DirectionalLight(1, -1, 1);
			_light3.color = 0xffeeaa;
//			_light3.specular = .5;
			
			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			_view.scene.addChild(_light3);
//			SimpleRenderer(_view.renderer).depthPrePass = true;
//			_view.renderer = new PositionRenderer();
			_material1.lights = [ _light, _light2, _light3 ];
			_material2.lights = [ _light, _light2, _light3 ];

			addChild(new AwayStats(_view));

		}

		private function onPlaneClick(event : MouseEvent3D) : void
		{
			event.object.extra.speed = 30;
			if (event.material == _material1) {
				Mesh(event.object).material = _material2;
			}
			else {
				Mesh(event.object).material = _material1;
			}
		}

		private function onPlaneMove(event : MouseEvent3D) : void
		{
//			event.object.extra.speed = 30;
			var material : BitmapMaterial = event.material as BitmapMaterial;
			if (material) {
				var rect : Rectangle = new Rectangle(event.uv.x*material.bitmapData.width-9, event.uv.y*material.bitmapData.height-9, 19, 19);
				material.bitmapData.fillRect(rect, 0x0000ff);
				material.updateTexture();
			}
		}
	}
}
