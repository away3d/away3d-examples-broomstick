﻿package {
	
	[SWF(width="1168", height="700", frameRate="60")]	

	import away3d.entities.*;
	import away3d.containers.*;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.cameras.Camera3D;
	import away3d.materials.BitmapMaterial;
	import away3d.debug.AwayStats;
	import away3d.extrusions.PathExtrude;
	import away3d.animators.PathAnimator;
	import away3d.extrusions.PathDuplicator;
	import away3d.extrusions.utils.Path;
	import away3d.loaders.parsers.data.DefaultBitmapData;
	import away3d.lights.PointLight;
	import away3d.materials.MaterialBase;
	import away3d.primitives.*;
	import away3d.events.PathEvent;
	 
	import flash.display.*;
	import flash.geom.Vector3D;
	import flash.events.*;
	 
	public class PathThings extends MovieClip
	{ 
		[Embed(source="assets/models/images/front.jpg")]
		private var Front : Class;
		 
		[Embed(source="assets/models/images/top.jpg")]
		private var Top : Class;
		
		[Embed(source="assets/models/images/left.jpg")]
		private var Left : Class;
		 
		private var _pathExtrude:PathExtrude;
		private var _view : View3D;
		private var camera:Camera3D;
		private var origin:Vector3D = new Vector3D(0,0,0);
		private var wave:Number = 0;
		private var _light1:PointLight;
		private var _light2:PointLight;
		
		//anim
		private var _pathAnimator:PathAnimator;
		private var _path:Path;
		private var _animTime:Number = 0;
		
		//duplicate
		private var _pathDuplicator:PathDuplicator;
		
		
		public function PathThings():void
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		 
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			initView();
			addLights();
			populate();
			initAnimation();
			initPathDuplicator();
			 
			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function initPathDuplicator():void
		{
			var cube1:Cube = new Cube(new BitmapMaterial(new Front().bitmapData), 50, 100, 50 );
			cube1.x = 330;
			cube1.name = "cube1";
			var cube2:Cube = new Cube(new BitmapMaterial(new Left().bitmapData), 30, 200, 30 );
			cube2.x = -330;
			cube2.name = "cube2";
			
			// as the class clones and uses the position as offset, the objects should be centered in own space.
			
			var meshes:Vector.<Mesh> = Vector.<Mesh>([cube1, cube2]);
			//path:Path, meshes:Vector.<Mesh>, scene:Scene3D, repeat:uint = 2, alignToPath = true, segmentSpread = true, 
			//container:ObjectContainer3D, rotations:Vector.<Vector3D>, scales:Vector.<Vector3D>
			_pathDuplicator = new PathDuplicator(_path, meshes, _view.scene, 5, true, true);
			_pathDuplicator.build();
			
			//at this point, if you want to duplicate more, simply define Meshes again, set the repeat value,
			//and call build(); again. No need for a new instance.
			// the classes also gives you back the generated instance if you want to access them to alter there properties
			// the class can return you these after build is called. if build is called again, it will no longer return the first references.
		}
		
		private function initAnimation():void
		{
			// the obecjt we want to animate
			var target:Cube = new Cube(new BitmapMaterial(new BitmapData(256, 256, false, 0x00FF00)), 50, 50, 100 );
			_view.scene.addChild(target);
			
			// the object will be on y axis, 300 units higher than the path
			var offset:Vector3D = new Vector3D(0, 300, 0);
			
			// To force animated object to look at it while moving.
			/*var lookatObject:Sphere = new Sphere(new BitmapMaterial(new BitmapData(256, 256, false, 0xCCCC99)), 100);
			_view.scene.addChild(lookatObject);
			lookatObject.x = lookatObject.z = 1000;
			lookatObject.y = 200;
			//_pathAnimator = new PathAnimator(_path, target, offset, false, lookatObject, null);*/
			_pathAnimator = new PathAnimator(_path, target, offset, true, null, null);
			
			//pathEvents:
			// changeSegment: if for instance you build rails, and want to trigger the sound "tada" of a train when wheel change of rail
			//_pathAnimator.addOnChangeSegment(onChangeSegment);
			// to trigger something when in a given range. (todo: add a series of ranges, only one atm)
			//_pathAnimator.addOnRange(onRange, 0.24, 0.25);
			// triggers each time the pointer goes back to 0
			//_pathAnimator.addOnCycle(onCycle);
		}
		//events animator
		private function onChangeSegment(e:PathEvent):void
		{
			trace("onChangeSegmentEvent");
		}
		private function onRange(e:PathEvent):void
		{
			trace("onRangeEvent");
		}
		private function onCycle(e:PathEvent):void
		{
			trace("cycleEvent");
		}
		 
		private function populate() : void
		{
			 
			// the series of curve to define the total path: here a simple copypaste from Prefab3D's .awp path export files.
			var data:Array = [2275,0,-32.5,2089.75,0,529.75,1665.625,293.9631168664363,971.75,1665.625,293.9631168664363,971.75,1241.5,587.9262337328726,1413.75,498.875,782.3829044346695,1555.125,498.875,782.3829044346695,1555.125,-243.75,976.8395751364665,1696.5,-877.5,784.8225334860448,1483.625,-877.5,784.8225334860448,1483.625,-1511.25,592.8054918356231,1270.75,-1742,398.34882113382616,773.5,-1742,398.34882113382616,773.5,-1972.75,203.8921504320292,276.25,-1797.25,41.503232422655884,-235.625,-1797.25,41.503232422655884,-235.625,-1621.75,-120.88568558671744,-747.5,-1101.75,-224.84387830400362,-1040,-1101.75,-224.84387830400362,-1040,-581.75,-328.8020710212898,-1332.5,34.125,-425.62013723120924,-1324.375,34.125,-425.62013723120924,-1324.375,650,-522.4382034411287,-1316.25,971.75,-463.5435403585238,-1001,971.75,-463.5435403585238,-1001,1293.5,-404.64887727591884,-685.75,1225.25,-205.4879130726602,-250.25,1225.25,-205.4879130726602,-250.25,1157,-6.326948869401548,185.25,724.75,94.53357876487867,472.875,724.75,94.53357876487867,472.875,292.5,195.3941063991589,760.5,-204.75,261.74796098604486,680.875,-204.75,261.74796098604486,680.875,-702,328.1018155729309,601.25,-822.25,406.05368991458886,268.125,-822.25,406.05368991458886,268.125,-942.5,484.00556425624677,-65,-659.75,538.7973031336326,-287.625,-659.75,538.7973031336326,-287.625,-377,593.5890420110183,-510.25,-61.75,674.735882147429,-433.875,-61.75,674.735882147429,-433.875,253.5,755.8827222838397,-357.5,429,859.5828499106706,-117];
			
			//examples other path
			//single segment
			// var data:Array = [	-1000, 0, 0,    0, 500, 500,    1000, 0, 0];
			
			//4 segments
			/*var data:Array = [	-1000, 0, 0,    -750, 0, 0,    -500, 0, 0, 
							  			-500, 0, 0,     -250,0,0,       0,0,0,
										0,0,0, 			250, 0, 0, 		500,0,0,
										500,0,0, 		750, 0, 0, 		1000,0,0
										];*/
			
			var pathData:Vector.<Vector3D> = new Vector.<Vector3D>();
			 
			// building the required Vector.<Vector3D>, a series of vector3d's as Prefab spits out the an array of Numbers
			for(var i:uint = 0;i<data.length;i+=3){
				pathData.push(new Vector3D(data[i],data[i+1], data[i+2]));
			}
			 
			_path = new Path(pathData);
			
			// the profile, the shape definition projected along the path, in this case a circle
			var profile:Vector.<Vector3D> = new Vector.<Vector3D>();
			
			var vector3d:Vector3D;
			var step:Number = 360/36;
			var angle:Number ;
			 
			for(i = 0;i<37;++i){
				angle = 90+(step*i);
				vector3d = new Vector3D();
				vector3d.x = Math.cos(angle/180*Math.PI) * 200;
				vector3d.y = Math.sin(-angle/180*Math.PI) * 200;
				profile.push(vector3d);
			} 
			
			// here a series of materials, using one material, define only the first param in constructor
			var materials:Vector.<MaterialBase> = new Vector.<MaterialBase>();
			
			materials[0] = new BitmapMaterial(new Front().bitmapData);
			materials[0].name = "front";
			materials[0].bothSides = true;
			materials[0].lights = [_light1, _light2];
			
			materials[1] = new BitmapMaterial(new Top().bitmapData);
			materials[1].name = "top";
			materials[1].bothSides = true;
			materials[1].lights = [_light1, _light2];
			
			materials[2] = new BitmapMaterial(new Left().bitmapData);
			materials[2].name = "left";
			materials[2].bothSides = true;
			materials[2].lights = [_light1, _light2];
			
			// its not because molehill can show a lot that you need to bloat the mesh with geometry.
			// go from lowest 2 till you have the right shape smoothness or add definition to the path itself.
			var subdivision:uint = 4;
			 
			//material, path, profile, subdivision, coverAll, coverSegment, alignToPath, centerMesh, mapfit, flip, closePath,
			//materials, scales, smoothScale, rotations, smoothSurface
			_pathExtrude = new PathExtrude(materials[0], _path, profile, subdivision, false, true, true, false, false, false, false, materials, null, true, null, true);//
			 
			 //showtime
			_view.scene.addChild(_pathExtrude);
		}
		
		private function addLights():void
		{
			_light1 = new PointLight();
			_light1.x = -4000;
			_light1.y = 6000;
			_light1.z = -4000;
			_light1.radius = 8000;
			_light1.fallOff = 15000;
			_light1.color = 0xFF9900;
 
			_view.scene.addChild(_light1);
			
			_light2 = new PointLight();
			_light2.x = 4000;
			_light2.y = 2000;
			_light2.z = 4000;
			_light2.radius = 8000;
			_light2.fallOff = 15000;
			_light2.color = 0xFFFFFF;
 
			_view.scene.addChild(_light2);
		}
		
		private function initView():void
		{
			_view = new View3D();
			_view.antiAlias = 2;
			_view.backgroundColor = 0x333333;
			camera = _view.camera;
			camera.lens = new PerspectiveLens();
			camera.x = 500;
			camera.y = 120;
			camera.z = 500;
			addChild(_view);
			addChild(new AwayStats(_view));
			 
			camera.lens.near = 10;
			camera.lens.far = 7000;
		}
		
		private function handleEnterFrame(e : Event) : void
		{
			_view.camera.position = origin;
			_view.camera.rotationY += .5;
			_view.camera.moveBackward(3000);
			
			wave+= .01;
			_view.camera.y = 600+ (600*Math.sin(wave));
			camera.lookAt(_pathExtrude.position);
			
			if(_pathAnimator){
				_animTime += 0.005;
				_pathAnimator.updateProgress(_animTime);
				if(_animTime> 1) _animTime = 0;
				//trace(_pathAnimator.target.position);
			}
			_view.render();
		}
		 
	}
}