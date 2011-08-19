﻿package {
	
	[SWF(width="1168", height="700", frameRate="60")]	

	import away3d.entities.WireframeGrid;
	import away3d.containers.View3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.cameras.Camera3D;
	import away3d.materials.BitmapMaterial;
	import away3d.debug.AwayStats;
	import away3d.extrusions.LinearExtrude;
	import away3d.lights.PointLight;
	import away3d.materials.utils.MultipleMaterials;
	 
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.events.Event;
	 
	public class LinearExtrudeTest extends MovieClip
	{ 
		[Embed(source="assets/models/images/front.jpg")]
		private var Front : Class;
		
		[Embed(source="assets/models/images/back.jpg")]
		private var Back : Class;
		
		[Embed(source="assets/models/images/top.jpg")]
		private var Top : Class;
		
		[Embed(source="assets/models/images/bottom.jpg")]
		private var Bottom : Class;
		
		[Embed(source="assets/models/images/left.jpg")]
		private var Left : Class;
		
		[Embed(source="assets/models/images/right.jpg")]
		private var Right : Class;
		
		private var _view : View3D;
		private var camera:Camera3D;
		private var origin:Vector3D = new Vector3D(0,0,0);
		private var wave:Number = 0;
		private var _light1:PointLight;
		private var _light2:PointLight;
		private var _linearExtrude:LinearExtrude;
		 
		public function LinearExtrudeTest():void
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		 
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			initView();
			addLights();
			populate();
			 
			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function addLights():void
		{
			_light1 = new PointLight();
			_light1.x = -4000;
			_light1.y = 4000;
			_light1.z = -4000;
			_light1.radius = 3000;
			_light1.fallOff = 15000;
			_light1.color = 0xFFFFFFF;
 
			_view.scene.addChild(_light1);
			
			_light2 = new PointLight();
			_light2.x = 4000;
			_light2.y = -4000;
			_light2.z = 4000;
			_light2.radius = 3000;
			_light2.fallOff = 15000;
			_light2.color = 0xFFFFFFF;
 
			_view.scene.addChild(_light2);
		}
		
		private function initView():void
		{
			_view = new View3D();
			_view.antiAlias = 4;
			_view.backgroundColor = 0x333333;
			camera = _view.camera;
			camera.lens = new PerspectiveLens();
			addChild(_view);
			addChild(new AwayStats(_view));
			camera.lens.near = 10;
			camera.lens.far = 3000;
		}
		
		private function populate() : void
		{
			var wireFrameGrid:WireframeGrid = new WireframeGrid(10, 500, 1, 0x985555, null, true);
			_view.scene.addChild(wireFrameGrid);
			
			var frontmat:BitmapMaterial = new BitmapMaterial(new Front().bitmapData);
			frontmat.lights = [_light1, _light2];
			
			//smallest definition: a segment
			var path:Vector.<Vector3D> = Vector.<Vector3D>([	new Vector3D(-250, 0, -250), new Vector3D(250, 0, -250)]);
			 
			// Using multiple materials
			var multy:MultipleMaterials = new MultipleMaterials();
			multy.front = frontmat;
			multy.back = new BitmapMaterial(new Back().bitmapData);
			multy.back.lights = [_light1, _light2];
			multy.left = new BitmapMaterial(new Left().bitmapData);
			multy.left.lights = [_light1, _light2];
			multy.right = new BitmapMaterial(new Right().bitmapData);
			multy.right.lights = [_light1, _light2];
			multy.top = new BitmapMaterial(new Top().bitmapData);
			multy.top.lights = [_light1, _light2];
			multy.bottom = new BitmapMaterial(new Bottom().bitmapData);
			multy.bottom.lights = [_light1, _light2];
			
			//material, vectors, axis, offset, subdivision, coverAll, thickness, thicknessSubdivision,
			//materials, centerMesh, closePath, ignoreSides, flip
			_linearExtrude = new LinearExtrude(null, path, LinearExtrude.Y_AXIS, 250, 3, false, 200, 3, multy, false, false, "", false);
			_view.scene.addChild(_linearExtrude);
			
			//other examples, with no thickness and single materials
			var path2:Vector.<Vector3D> = Vector.<Vector3D>([	new Vector3D(-200, 0, 0),
															   							new Vector3D(200, 0, 0),
																						new Vector3D(200, 0, 200),
																						new Vector3D(-200, 0, 200),
																						new Vector3D(-200, 0, 100)
																						]);
			
			var linearExtrude2:LinearExtrude = new LinearExtrude(null, path2, LinearExtrude.Y_AXIS, 100, 3, false, 40, 3, multy, false, false, "", false);
			_view.scene.addChild(linearExtrude2);
			
			var path3:Vector.<Vector3D> = Vector.<Vector3D>([	new Vector3D(-400, 0, 400),
															   							new Vector3D(400, 0, 400),
																						new Vector3D(400, 0, -400),
																						new Vector3D(-400, 0, -400)
																						]);
			
			var linearExtrude3:LinearExtrude = new LinearExtrude(frontmat, path3, LinearExtrude.Y_AXIS, 150, 3, true);
			_view.scene.addChild(linearExtrude3);
			 
		}
		
		private function handleEnterFrame(e : Event) : void
		{
			_view.camera.position = origin;
			_view.camera.rotationY += .5;
			_view.camera.moveBackward(700);
			
			wave+= .002;
			_view.camera.y = 400*Math.sin(wave);
			
			camera.lookAt(_linearExtrude.position);
			
			_view.render();
		}
		 
	}
}