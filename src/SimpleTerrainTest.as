﻿package
{
	import away3d.containers.View3D;
    import away3d.debug.AwayStats;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.DepthOfFieldFilter3D;
	import away3d.filters.MotionBlurFilter3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
    import away3d.materials.methods.SoftShadowMapMethod;
    import away3d.materials.methods.TerrainDiffuseMethod;
    import away3d.materials.utils.CubeMap;
    import away3d.primitives.Cube;
    import away3d.extrusions.Elevation;
    import away3d.primitives.Plane;
    import away3d.primitives.SkyBox;
    import away3d.primitives.Sphere;
	import away3d.containers.ObjectContainer3D;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	[SWF(width="1024", height="576", frameRate="60")]
	public class SimpleTerrainTest extends Sprite
	{
		private var _view : View3D;
		
		private var _light : DirectionalLight;

        // Environment map.
        [Embed(source="../embeds/envMap/snow_positive_x.jpg")]
        private var EnvPosX:Class;
        [Embed(source="../embeds/envMap/snow_positive_y.jpg")]
        private var EnvPosY:Class;
        [Embed(source="../embeds/envMap/snow_positive_z.jpg")]
        private var EnvPosZ:Class;
        [Embed(source="../embeds/envMap/snow_negative_x.jpg")]
        private var EnvNegX:Class;
        [Embed(source="../embeds/envMap/snow_negative_y.jpg")]
        private var EnvNegY:Class;
        [Embed(source="../embeds/envMap/snow_negative_z.jpg")]
        private var EnvNegZ:Class;

		[Embed(source="../embeds/Heightmap.jpg")]
		private var HeightMap : Class;

		[Embed(source="../embeds/terrain_tex.jpg")]
		private var Albedo : Class;

		[Embed(source="../embeds/terrain_norms.jpg")]
		private var Normals : Class;

		[Embed(source="../embeds/grass.jpg")]
		private var Grass : Class;

		[Embed(source="../embeds/terrainGrassBlend.jpg")]
		private var GrassBlend : Class;

		[Embed(source="../embeds/rock.jpg")]
		private var Rock : Class;

        [Embed(source="../embeds/terrainRockBlend.jpg")]
        private var RockBlend : Class;

		[Embed(source="../embeds/beach.jpg")]
		private var Beach : Class;

        [Embed(source="../embeds/terrainBeachBlend.jpg")]
        private var BeachBlend : Class;


		private var _camController : FlightController;
        private var _terrain : Elevation;
        private var _cubeMap : CubeMap;
		private var _stickToFloor : Boolean = true;
		private var _motionBlur : MotionBlurFilter3D;

		private var _prevX : Number = 0;
		private var _prevY : Number = 0;
		private var _strength : Number = 0;

		public function SimpleTerrainTest()
		{
            var material : BitmapMaterial;
            var terrainMethod : TerrainDiffuseMethod;
            var fog : FogMethod;

			super();

			_view = new View3D();
			_motionBlur = new MotionBlurFilter3D();
			_view.filters3d = [ new BloomFilter3D(20, 20, .75, 1, 3) ];
//			_view.filters3d = [ new DepthOfFieldFilter3D(10, 10) ];
            _view.antiAlias = 4;
            _view.camera.lens.far = 14000;
            _view.camera.lens.near = .1;
//            _view.camera.y = 500;
			_camController = new FlightController(_view.camera, stage);
			_camController.moveSpeed = 1;
            _cubeMap = new CubeMap( new EnvPosX().bitmapData, new EnvNegX().bitmapData,
                                    new EnvPosY().bitmapData, new EnvNegY().bitmapData,
                                    new EnvPosZ().bitmapData, new EnvNegZ().bitmapData);

            _view.scene.addChild(new SkyBox(_cubeMap));
			addChild(_view);
			addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			

            terrainMethod = new TerrainDiffuseMethod();
			terrainMethod.setSplattingLayer(0, new Grass().bitmapData, new GrassBlend().bitmapData, 150);
			terrainMethod.setSplattingLayer(1, new Rock().bitmapData, new RockBlend().bitmapData, 100);
			terrainMethod.setSplattingLayer(2, new Beach().bitmapData, new BeachBlend().bitmapData, 50);
			terrainMethod.normalizeSplats();

			material = new BitmapMaterial(new Albedo().bitmapData);
			material.diffuseMethod = terrainMethod;
            material.normalMap = new Normals().bitmapData;
            material.ambientColor = 0x202030;
			material.ambient = 1;
            material.specular = .2;

            fog = new FogMethod(4000, 0xcfd9de);
            material.addMethod(fog);
			
			// mountain like
            _terrain = new Elevation(material, new HeightMap().bitmapData, 5000, 1300, 5000, 175, 175);
			
			// canyon like
			//_terrain = new Elevation(material, new HeightMap().bitmapData, 5000, 1300, 5000, 175, 175, 100);

			// if your map has noise, the class generates a smoother map to prevent choppy camera movements when using _terrain.getHeightAt
			//_terrain = new Elevation(material, new HeightMap().bitmapData, 5000, 1300, 5000, 175, 175, 255, 0, true);
			//you can access the map after generation via _terrain.smoothedHeightMap;
			 
            _view.scene.addChild(_terrain);
            _light = new DirectionalLight(-300, -300, -5000);
            _light.color = 0xfffdc5;
            material.lights = [_light];

            _view.scene.addChild(_light);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

            addChild(new AwayStats(_view));
        }

		private function onKeyUp(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.SPACE) _stickToFloor = !_stickToFloor;

			_camController.moveSpeed = _stickToFloor? 1 : 5;
		}

		private function onStageResize(event : Event) : void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
		
		
		private function _handleEnterFrame(ev : Event) : void
		{
			var mx : Number = mouseX, my : Number = mouseY;
			var dx : Number = mx - _prevX, dy : Number = my - _prevY;
			var dist : Number = .4 + (dx*dx + dy*dy) / 300;
			if (dist > .9) dist = .9;
			_strength += (dist-_strength)*.05;
//			_motionBlur.strength = _strength;
			_prevX = mx;
			_prevY = my;

			var h : Number = _terrain.getHeightAt(_view.camera.x, _view.camera.z) + 10;
			if (_stickToFloor || h > _view.camera.y) _view.camera.y += (h - _view.camera.y)*.05;
			_view.render();
		}
	}
}