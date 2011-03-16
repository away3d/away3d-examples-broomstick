package
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.containers.View3D;
	import away3d.core.base.SubGeometry;
	import away3d.debug.AwayStats;
	import away3d.entities.TextureProjector;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.ProjectiveTextureMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.utils.CubeMap;
	import away3d.primitives.Plane;
	import away3d.primitives.SkyBox;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	[SWF(width="1024", height="576", frameRate="60", backgroundColor="0x000000")]
	public class MultiViewTest extends Sprite
	{
		[Embed(source="/../embeds/rockbase.jpg")]
		private var FloorDiffuse : Class;

		[Embed(source="/../embeds/rockbase_local.png")]
		private var FloorNormals : Class;

		[Embed(source="/../embeds/rockbase_s.png")]
		private var FloorSpecular : Class;

		[Embed(source="/../embeds/grim_sky/posX.png")]
		private var EnvPosX : Class;

		[Embed(source="/../embeds/grim_sky/posY.png")]
		private var EnvPosY : Class;

		[Embed(source="/../embeds/grim_sky/posZ.png")]
		private var EnvPosZ : Class;

		[Embed(source="/../embeds/grim_sky/negX.png")]
		private var EnvNegX : Class;

		[Embed(source="/../embeds/grim_sky/negY.png")]
		private var EnvNegY : Class;

		[Embed(source="/../embeds/grim_sky/negZ.png")]
		private var EnvNegZ : Class;

		[Embed(source="/../embeds/redlight.png")]
		private var RedLight : Class;

		[Embed(source="/../embeds/bluelight.png")]
		private var BlueLight : Class;

		[Embed(source="/../embeds/shadowBlob.png")]
		private var ShadowBlob : Class;

		//signature variables
		private var Signature:Sprite;
		
		//signature swf
		[Embed(source="/../embeds/signature_david.swf", symbol="Signature")]
		private var SignatureSwf:Class;
		
		private var _view1 : View3D;
		private var _view2 : View3D;
		private var _view3 : View3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;

		private var _controller : MonsterController;
		private var _targetLookAt : Vector3D;
		private var _envMap : CubeMap;
		private var _count : Number = 0;
		private var _bmp : BitmapData;
		private var _lights : Array = [];
		private var _projectionMethod : ProjectiveTextureMethod;
		private var _projector : TextureProjector;

		public function MultiViewTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			initView();
			_controller = new MonsterController();
			_view1.scene.addChild(_controller.mesh);
			_controller.bodyMaterial.addMethod(new FogMethod(_view1.camera.lens.far * .5, 0x000000));
			_controller.bodyMaterial.lights = _lights;
			_controller.bodyMaterial.lights = _lights;
			_controller.mesh.addChild(_view2.camera);
			_controller.mesh.addChild(_projector);
//			_view1.scene.addChild(_projector);
			_projector.y = 500;
			_projector.z = -5;
			_projector.fieldOfView = 15;

			Signature = Sprite(new SignatureSwf());
			Signature.x = 10;
			Signature.y = stage.stageHeight - Signature.height - 10;
			
			addChild(Signature);
			
			addChild(new AwayStats(_view1));
			
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onKeyDown(event : KeyboardEvent) : void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					_controller.running = true;
					break;
				case Keyboard.SPACE:
					_controller.action(0);
					break;
				case Keyboard.ENTER:
					_controller.action(1);
					break;
				case Keyboard.E:
					_controller.action(2);
					break;
				case Keyboard.R:
					_controller.action(3);
					break;
				case Keyboard.T:
					_controller.action(4);
					break;
				case Keyboard.D:
					_controller.action(5);
					break;
				case Keyboard.F:
					_controller.action(6);
					break;
				case Keyboard.G:
					_controller.action(7);
					break;
				case Keyboard.Y:
					_controller.action(8);
					break;
				case Keyboard.H:
					_controller.action(9);
					break;
				case Keyboard.UP:
					_controller.walk(1);
					break;
				case Keyboard.DOWN:
					_controller.walk(-1);
					break;
				case Keyboard.LEFT:
					_controller.turn(-1);
					break;
				case Keyboard.RIGHT:
					_controller.turn(1);
					break;
			}
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					_controller.running = false;
					break;
				case Keyboard.UP:
				case Keyboard.DOWN:
					_controller.stop();
					break;
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					_controller.turn(0);
					break;
			}
		}

		private function initView() : void
		{
			var sprite : Sprite3D;
			_view1 = new View3D();
			_view1.camera.lens.far = 2000;
			_view1.camera.z = -200;
			_view1.camera.y = 160;
			_view1.camera.lookAt(_targetLookAt = new Vector3D());
			_light = new PointLight(); // DirectionalLight();
			_light.x = -1000;
			_light.y = 200;
			_light.z = -1400;
			_light.color = 0xff0000;
			PointLight(_light).radius = 400;
			PointLight(_light).fallOff = 1500;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 1000;
			_light2.y = 200;
			_light2.z = 1400;
			_light2.color = 0x0000ff;
			PointLight(_light2).radius = 0;
			PointLight(_light2).fallOff = 700;
			_light3 = new DirectionalLight(0, -20, 10);
			_light3.castsShadows = true;
//			_light3.shadowMapper.depthMapSize = 2048;
			_light3.color = 0xffffff;

			_projector = new TextureProjector(new ShadowBlob().bitmapData);
			_projectionMethod = new ProjectiveTextureMethod(_projector);

			_view1.scene.addChild(_light);
			_view1.scene.addChild(_light2);
			_view1.scene.addChild(_light3);

			_lights[0] = _light;
			_lights[1] = _light2;
			_lights[2] = _light3;

			var material : BitmapMaterial = new BitmapMaterial(new RedLight().bitmapData);
//			material.blendMode = BlendMode.ADD;
			material.transparent = true;
			material.addMethod(new FogMethod(_view1.camera.lens.far * .5, 0x000000));
			sprite = new Sprite3D(material, 200, 200);
			_light.addChild(sprite);
			material = new BitmapMaterial(new BlueLight().bitmapData);
			sprite = new Sprite3D(material, 200, 200);
			material.addMethod(new FogMethod(_view1.camera.lens.far * .5, 0x000000));
//			material.blendMode = BlendMode.ADD;
			material.transparent = true;
			_light2.addChild(sprite);

			_envMap = new CubeMap(new EnvPosX().bitmapData, new EnvNegX().bitmapData,
					new EnvPosY().bitmapData, new EnvNegY().bitmapData,
					new EnvPosZ().bitmapData, new EnvNegZ().bitmapData);
			_view1.scene.addChild(new SkyBox(_envMap));

			material = new BitmapMaterial(new FloorDiffuse().bitmapData, true, true, true);
			material.lights = _lights;
			material.specular = 1;
			material.ambientColor = 0x505060;
			material.normalMap = new FloorNormals().bitmapData;
			material.specularMap = new FloorSpecular().bitmapData;
			material.addMethod(_projectionMethod);
			material.addMethod(new FogMethod(_view1.camera.lens.far * .5, 0x000000));
			var plane : Plane = new Plane(material, 50000, 50000, 150, 150, false);
			plane.geometry.scaleUV(200);
			plane.castsShadows = false;
			var subGeom : SubGeometry = plane.geometry.subGeometries[0];
			var verts : Vector.<Number> = subGeom.vertexData;
			_bmp = new BitmapData(512, 512, false)
			_bmp.perlinNoise(64, 64, 8, 21, false, true, 7, true);


			for (var x : int = 0; x < 150; x++) {
				for (var y : int = 0; y < 150; y++) {
					var xf : Number = (verts[(x + y * 150) * 3] / 50000 + .5) * 512;
					var yf : Number = (verts[(x + y * 150) * 3 + 2] / 50000 + .5) * 512;
					var xi : int = xf;
					var yi : int = yf;
					var xr : Number = xf - xi;
					var yr : Number = yf - yi;

					verts[(x + y * 150) * 3 + 1] = (((1 - yr) * ((1 - xr) * (_bmp.getPixel(xi, yi) & 0xff) + xr * (_bmp.getPixel(xi + 1, yi) & 0xff)) +
							yr * ((1 - xr) * (_bmp.getPixel(xi, yi + 1) & 0xff) + xr * (_bmp.getPixel(xi + 1, yi + 1) & 0xff))) - 0x80) * 10;
				}
			}

			subGeom.updateVertexData(verts);

			_view1.scene.addChild(plane);

			_view1.x = 20;
			_view1.y = 20;
			_view1.width = 500;
			_view1.height = 536;
			_view1.antiAlias = 4;

			_view2 = new View3D(_view1.scene, new Camera3D(new OrthographicLens(100)));
			_view2.x = 540;
			_view2.y = 20;
			_view2.width = 464;
			_view2.height = 200;
			_view2.antiAlias = 4;
			_view2.camera.y = 100;
			_view2.camera.z = 100;
			_view2.camera.lookAt(new Vector3D(0, 90, 0));

			_view3 = new View3D(_view1.scene);
			_view3.x = 540;
			_view3.y = 240;
			_view3.width = 116;
			_view3.height = 79;
			_view3.scaleX = 4;
			_view3.scaleY = 4;
			_view3.antiAlias = 4;
			_view3.camera.x = 300;
			_view3.camera.y = 500;
			_view3.camera.z = 1000;
//			_view2.camera.lens = new OrthographicLens();
//			_view3.renderer = new PositionRenderer();
			_view3.camera.lookAt(new Vector3D());

			addChild(_view1);
			addChild(_view2);
			addChild(_view3);
		}

		private function onStageResize(event : Event) : void
		{
//			_view1.antiAlias = 16;
			_view1.x = stage.stageWidth / 1024 * 20;
			_view1.y = stage.stageHeight / 576 * 20;
			_view1.width = stage.stageWidth / 1024 * 500;
			_view1.height = stage.stageHeight / 576 * 536;
			_view2.x = stage.stageWidth / 1024 * 540;
			_view2.y = stage.stageHeight / 576 * 20;
			_view2.width = stage.stageWidth / 1024 * 464;
			_view2.height = stage.stageHeight / 576 * 200;
			_view3.x = stage.stageWidth / 1024 * 540;
			_view3.y = stage.stageHeight / 576 * 240;
			_view3.width = stage.stageWidth / 1024 * 116;
			_view3.height = stage.stageHeight / 576 * 79;
			
			Signature.x = 10;
			Signature.y = stage.stageHeight - Signature.height- 10;
		}

		private function handleEnterFrame(ev : Event) : void
		{
			var mesh : Mesh = _controller.mesh;
			var x : Number = (mesh.x / 50000 + .5) * 512;
			var y : Number = (mesh.z / 50000 + .5) * 512;
			var xi : int = x;
			var yi : int = y;
			var xr : Number = x - xi;
			var yr : Number = y - yi;

			mesh.y = (((1 - yr) * ((1 - xr) * (_bmp.getPixel(xi, yi) & 0xff) + xr * (_bmp.getPixel(xi + 1, yi) & 0xff)) +
					yr * ((1 - xr) * (_bmp.getPixel(xi, yi + 1) & 0xff) + xr * (_bmp.getPixel(xi + 1, yi + 1) & 0xff))) - 0x80) * 10;
			_controller.update();

			_targetLookAt.x = _targetLookAt.x + (mesh.x - _targetLookAt.x) * .03;
			_targetLookAt.y = _targetLookAt.y + (mesh.y - _targetLookAt.y) * .03;
			_targetLookAt.z = _targetLookAt.z + (mesh.z - _targetLookAt.z) * .03;
//			_view1.camera.lookAt(_light.position);
			_view1.camera.lookAt(_targetLookAt);
			_view3.camera.lookAt(mesh.position);

			_count += .01;
			_light.x = Math.sin(_count) * 1500;
			_light.y = 250 + Math.sin(_count * .54) * 200;
			_light.z = Math.cos(_count * .7) * 1500;
			_light2.x = -Math.sin(_count * .8) * 1500;
			_light2.y = 250 - Math.sin(_count * .65) * 200;
			_light2.z = -Math.cos(_count * .9) * 1500;
			_view1.render(true);
			_view2.render(false);
			_view3.render(false);
		}
	}
}