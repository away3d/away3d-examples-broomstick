﻿package {		[SWF(width="1168", height="700", frameRate="60")]		import away3d.entities.Mesh;	import away3d.containers.View3D;	import away3d.cameras.lenses.PerspectiveLens;	import away3d.cameras.Camera3D;	import away3d.materials.BitmapMaterial;	import away3d.debug.AwayStats;	import away3d.lights.PointLight;	import away3d.tools.Merge;	import away3d.primitives.Cube;	import away3d.primitives.Sphere;	 	import flash.display.MovieClip;	import flash.display.BitmapData;	import flash.geom.Vector3D;	import flash.events.Event;	 	public class MergeTest extends MovieClip	{ 		private var _view : View3D;		private var camera:Camera3D;		private var origin:Vector3D = new Vector3D(0,0,0);		private var wave:Number = 0;		private var _light1:PointLight;		private var _light2:PointLight;		 		public function MergeTest():void		{			addEventListener(Event.ADDED_TO_STAGE, init);		}		 		private function init(e:Event):void		{			removeEventListener(Event.ADDED_TO_STAGE, init);			initView();			addLights();			populate();			 			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);		}		 		private function addLights():void		{			_light1 = new PointLight();			_light1.x = -4000;			_light1.y = 6000;			_light1.z = -4000;			_light1.radius = 8000;			_light1.fallOff = 15000;			_light1.color = 0xFF9900; 			_view.scene.addChild(_light1);						_light2 = new PointLight();			_light2.x = 4000;			_light2.y = 2000;			_light2.z = 4000;			_light2.radius = 8000;			_light2.fallOff = 15000;			_light2.color = 0xFFFFFF; 			_view.scene.addChild(_light2);		}				private function initView():void		{			_view = new View3D();			_view.antiAlias = 2;			_view.backgroundColor = 0x333333;			camera = _view.camera;			camera.lens = new PerspectiveLens();			camera.x = 500;			camera.y = 120;			camera.z = 500;			addChild(_view);			addChild(new AwayStats(_view));			 			camera.lens.near = 10;			camera.lens.far = 15000;		}				private function populate() : void		{			var merge:Merge = new Merge(false, true, false);						var matcube:BitmapMaterial = new BitmapMaterial(new BitmapData(256,256, false, 0xFF0000));			matcube.lights = [_light1, _light2];			matcube.name = "matcube";			var cube1:Cube = new Cube(matcube, 100, 200, 100);			var cube2:Cube = new Cube(matcube, 100, 200, 100);						cube1.x = cube2.x = -8000;			cube1.z = cube2.z = -8000;			cube1.y = cube2.y = 0;						var iterations:uint = 80;			var rotIncrease:Number = 360/iterations;			var posIncrease:Number = 16000/iterations;						for(var i:uint = 0;i<iterations; ++i){				cube2.rotationY += rotIncrease;				cube2.rotationX += rotIncrease;				cube2.x += posIncrease;				merge.apply(cube1, cube2);			}			 			cube2.x += posIncrease;			merge.apply(cube2, cube1);						for(i = 0;i<iterations; ++i){				cube2.rotationX += rotIncrease;				cube2.z += posIncrease;				merge.apply(cube1, cube2);			}						_view.scene.addChild(cube1);		}				private function handleEnterFrame(e : Event) : void		{			_view.camera.position = origin;			_view.camera.rotationY += 1;			_view.camera.moveBackward(3000);						 wave+= .02;			_view.camera.y =  600*Math.sin(wave);			camera.lookAt(origin); 			 			_view.render();		}		 	}}