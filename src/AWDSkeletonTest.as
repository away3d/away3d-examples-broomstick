package 
{
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.ResourceEvent;
	import away3d.loading.ResourceManager;
	import away3d.loading.parsers.AWD2Parser;
	import away3d.materials.ColorMaterial;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	

	[SWF(width="800", height="450", frameRate="60")]
	public class AWDSkeletonTest extends Sprite
	{
		private var _view : View3D;
		private var _container : ObjectContainer3D;
		
		//[Embed(source="../../../../../../../Desktop/mayaout-truckstop.awd", mimeType="application/octet-stream")]
		//private var AWDAsset : Class;
		
		public function AWDSkeletonTest()
		{
			_view = new View3D;
			_view.camera.y = 500;
			addChild(_view);
			
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
			//_container = ObjectContainer3D(ResourceManager.instance.parseData(new AWDAsset, "awdasset", true, AWD2Parser));
			//_container = ObjectContainer3D(ResourceManager.instance.getResource('../../../AWD/Dev/sdks/python-pyawd/bindtest.awd', false, AWD2Parser));
			_container = ObjectContainer3D(ResourceManager.instance.getResource('../../../../../../../Desktop/mayaout.awd', false, new AWD2Parser('')));
			//_container = ObjectContainer3D(ResourceManager.instance.getResource('../../../../../../../Desktop/mayaout-truckstop.awd', false, AWD2Parser));
			_container.scale(20);
			//_container.y = -300;
			_view.scene.addChild(_container);
			onResourceRetrieved(null);
			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}


		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			if (_container && _container.numChildren>0) {
				var mesh : Mesh;
				var len : uint = _container.numChildren;
				
				var bmp : BitmapData = new BitmapData(512, 512);
				bmp.perlinNoise(10, 10, 10, 0, false, false, 7, true);
				
				for (var i : int = 0; i<_container.numChildren; i++) {
					var mat : ColorMaterial = new ColorMaterial(0xffcc00);
					mat.bothSides = true;
					Mesh(_container.getChildAt(i)).material = mat;
				}
				
				SkeletonAnimator(Mesh(_container.getChildAt(0)).animationController).play("hardcoded");
				
				//Mesh(_container.getChildAt(0)).material = new BitmapMaterial(BitmapAsset(new GroundTextureAsset).bitmapData);
				//Mesh(_container.getChildAt(1)).material = new BitmapMaterial(BitmapAsset(new ObjectsTextureAsset).bitmapData);
				//Mesh(_container.getChildAt(1)).material = new BitmapMaterial(bmp);
				
			}
		}

		private function handleEnterFrame(ev : Event) : void
		{
			_container.rotationY += 0.1;
			//_view.camera.y = 300 + 200 * Math.sin(getTimer() * 0.001);
			//_view.camera.lookAt(_container.position);
			_view.camera.y = 100;
			_view.camera.lookAt(new Vector3D());
			_view.render();
		}
	}
}