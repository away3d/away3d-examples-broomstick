package
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.SlowFilteredShadowMapMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.utils.CubeMap;
	import away3d.primitives.Plane;
	import away3d.primitives.SkyBox;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	[SWF(width="1024", height="576", frameRate="60", backgroundColor="0x000000")]
	public class LoaderMD5Test extends Sprite
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
		
		//signature variables
		private var Signature:Sprite;
		
		//signature swf
		[Embed(source="/../embeds/signature_david.swf", symbol="Signature")]
		private var SignatureSwf:Class;
		
		private var _view : View3D;

		private var _light : LightBase;
		private var _light2 : LightBase;
		private var _light3 : LightBase;

		private var _controller : MonsterController;
		private var _targetLookAt : Vector3D;
		private var _envMap : CubeMap;
		private var _count : Number = 0;
		private var _lights : Array;
		private var _shadowMethod : SlowFilteredShadowMapMethod;
		private var _shadowMethod2 : SlowFilteredShadowMapMethod;

		public function LoaderMD5Test()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			initView();
			_controller = new MonsterController();
			_view.scene.addChild(_controller.mesh);
			_controller.bodyMaterial.addMethod(new FogMethod(_view.camera.lens.far*.5, 0x000000));
//			_controller.bodyMaterial.specularMethod = null;
			_controller.bodyMaterial.lights = _lights;
			_controller.bodyMaterial.shadowMethod = _shadowMethod2 = new SlowFilteredShadowMapMethod(_light3);

			Signature = Sprite(new SignatureSwf());
			Signature.y = stage.stageHeight - Signature.height;
			
			addChild(Signature);
			
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
				case Keyboard.ESCAPE:
//					_shadowMethod2.hardEdges = _shadowMethod.hardEdges = !_shadowMethod.hardEdges;
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
			_view = new View3D();
			_view.camera.lens.far = 5000;
			_view.camera.z = -200;
			_view.camera.y = 160;
			_view.camera.lookAt(_targetLookAt = new Vector3D(0, 50, 0));
			addChild(new AwayStats(_view));
			_light = new PointLight(); // DirectionalLight();
			this.addChild(_view);
			_light.x = -1000;
			_light.y = 200;
			_light.z = -1400;
			_light.color = 0xff1111;
			_light2 = new PointLight(); // DirectionalLight();
			_light2.x = 1000;
			_light2.y = 200;
			_light2.z = 1400;
			_light2.color = 0x1111ff;
			_light3 = new DirectionalLight(0, -20, 10);
			_light3.color = 0xffffee;
			_light3.castsShadows = true;

			_lights = [_light, _light2, _light3];

			_view.scene.addChild(_light);
			_view.scene.addChild(_light2);
			_view.scene.addChild(_light3);
			
			var material : BitmapMaterial = new BitmapMaterial(new RedLight().bitmapData);
//			material.blendMode = BlendMode.ADD;
			material.transparent = true;
			material.addMethod(new FogMethod(_view.camera.lens.far*.5, 0x000000));
			sprite = new Sprite3D(material, 200, 200);
			_light.addChild(sprite);
			material = new BitmapMaterial(new BlueLight().bitmapData);
			sprite = new Sprite3D(material, 200, 200);
			material.addMethod(new FogMethod(_view.camera.lens.far*.5, 0x000000));
//			material.blendMode = BlendMode.ADD;
			material.transparent = true;
			_light2.addChild(sprite);

			_envMap = new CubeMap(	new EnvPosX().bitmapData,  new EnvNegX().bitmapData,
									new EnvPosY().bitmapData,  new EnvNegY().bitmapData,
									new EnvPosZ().bitmapData,  new EnvNegZ().bitmapData);
			_view.scene.addChild(new SkyBox(_envMap));

			material = new BitmapMaterial(new FloorDiffuse().bitmapData, true, true, true);
			material.lights = _lights;
			material.ambientColor = 0x202030;
			material.normalMap = new FloorNormals().bitmapData;
			material.specularMap = new FloorSpecular().bitmapData;
			material.shadowMethod = _shadowMethod = new SlowFilteredShadowMapMethod(_light3);
			material.addMethod(new FogMethod(_view.camera.lens.far*.5, 0x000000));
//			material.specularMethod = null;
			var plane : Plane = new Plane(material, 50000, 50000, 1, 1, false);
			plane.geometry.scaleUV(200);
			plane.castsShadows = false;
			_view.scene.addChild(plane);
			
			_view.width = 1024;
			_view.height = 576;
			_view.antiAlias = 4;
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			
			Signature.y = stage.stageHeight - Signature.height;
		}

		private function handleEnterFrame(ev : Event) : void
		{
			var mesh : Mesh = _controller.mesh;
			_controller.update();
			_targetLookAt.x = _targetLookAt.x + (mesh.x - _targetLookAt.x)*.03;
			_targetLookAt.y = _targetLookAt.y + (mesh.y + 50 - _targetLookAt.y)*.03;
			_targetLookAt.z = _targetLookAt.z + (mesh.z - _targetLookAt.z)*.03;
			_view.camera.lookAt(_targetLookAt);

			_count += .01;
			_light.x = Math.sin(_count)*1500;
			_light.y = 250+Math.sin(_count*.54)*200;
			_light.z = Math.cos(_count*.7)*1500;
			_light2.x = -Math.sin(_count*.8)*1500;
			_light2.y = 250-Math.sin(_count*.65)*200;
			_light2.z = -Math.cos(_count*.9)*1500;
			_view.render();
		}
	}
}