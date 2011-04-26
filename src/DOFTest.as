/**
 * @author David Lenaerts
 */
package
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.filters.DepthOfFieldFilter3D;

	import away3d.filters.MotionBlurFilter3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.primitives.Sphere;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF(width="1024", height="512", backgroundColor="0x000000", frameRate="60")]
	public class DOFTest extends Sprite
	{
		private static const GRID_NUM_X : int = 10;
		private static const GRID_NUM_Y : int = 10;
		private static const GRID_NUM_Z : int = 10;
		private static const GRID_SPACING : int = 200;
		private static const GRID_ELEMENT_SIZE : int = 20;

		private var _view : View3D;
		private var _dofFilter : DepthOfFieldFilter3D;
		private var _roamer : Mesh;
		private var _light : PointLight;
		private var _light2 : DirectionalLight;
		private var _count1 : Number = 0;
		private var _count2 : Number = 0;

		public function DOFTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			initView3D();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function initView3D() : void
		{
			var element : Mesh;
			var elementMaterial : DefaultMaterialBase = new ColorMaterial(0x808080);
			var base : Sphere = new Sphere(elementMaterial, GRID_ELEMENT_SIZE);

			_view = new View3D();
			_dofFilter = new DepthOfFieldFilter3D(20, 20);
			_dofFilter.range = 400;
			_view.filters3d = [ _dofFilter ];
			_view.camera.x = 0;
			_view.camera.y = 0;
			_view.camera.z = 0;
			addChild(_view);

			for (var gx : uint = 0; gx < GRID_NUM_X; ++gx) {
				for (var gy : uint = 0; gy < GRID_NUM_Y; ++gy) {
					for (var gz : uint = 0; gz < GRID_NUM_Z; ++gz) {
						element = Mesh(base.clone());
						element.x = (gx - GRID_NUM_X*.5) * GRID_SPACING;
						element.y = (gy - GRID_NUM_Y*.5) * GRID_SPACING;
						element.z = (gz - GRID_NUM_Z*.5) * GRID_SPACING;
						_view.scene.addChild(element);
					}
				}
			}

			_roamer = Mesh(base.clone());
			_roamer.material = new ColorMaterial(0xff0000);
			_light = new PointLight();
			_light.color = 0xff0000;
			_light.radius = 100;
			_light.fallOff = 700;
			_light2 = new DirectionalLight(-1, 1, -1);
			_light2.color = 0x9090aa;
			_view.scene.addChild(_light2);
			_roamer.addChild(_light);

			_dofFilter.focusTarget = _roamer;
			elementMaterial.ambientColor = 0x303040;
			elementMaterial.lights = [ _light, _light2 ];

			_view.scene.addChild(_roamer);

			addChild(new AwayStats(_view));
		}

		private function onEnterFrame(event : Event) : void
		{
			_count1 += .01;
			_count2 += .008;
			_roamer.x = Math.sin(Math.cos(_count1))*GRID_NUM_X*.5*GRID_SPACING;
			_roamer.y = Math.sin(_count2)*Math.cos(_count1)*GRID_NUM_Y*.5*GRID_SPACING;
			_roamer.z = Math.cos(_count2*.97)*GRID_NUM_Z*.5*GRID_SPACING;
			_view.camera.lookAt(_roamer.position);
			_view.render();
		}
	}
}
