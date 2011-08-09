package
{
	import away3d.bounds.BoundingSphere;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[SWF(width="800", height="450", frameRate="60")]
	public class InteractionTest2 extends Sprite
	{
		private var _view : View3D;

		private var _mesh1 : Cube;
		private var _mesh2 : Cube;
		private var _material1 : BitmapMaterial;
		private var _material2 : BitmapMaterial;
		private var _camController:HoverDragController;
		private var _viewContainer : Sprite;

		public function InteractionTest2()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			_viewContainer = new Sprite();
			_viewContainer.x = -100;
			_viewContainer.y = 50;
			addChild(_viewContainer);

			_view = new View3D();
			_view.x = 100;
			_view.y = 50;
			_view.width = 600;
			_view.height = 300;

			_view.antiAlias = 4;
			_view.forceMouseMove = true;
			_viewContainer.addChild(_view);

			var bitmapData1 : BitmapData = new BitmapData(512, 512, false, 0x000000);
			var bitmapData2 : BitmapData = new BitmapData(512, 512, false, 0x000000);
			bitmapData1.perlinNoise(64, 64, 5, 0, false, true, BitmapDataChannel.RED);
			bitmapData2.perlinNoise(64, 64, 5, 0, false, true, BitmapDataChannel.BLUE);
			_material1 = new BitmapMaterial(bitmapData1);
			_material2 = new BitmapMaterial(bitmapData1);
			_material1.alpha = .9;
			_mesh1 = new Cube(_material1, 10000, 1, 10000, 1, 1, 1, false);
			_mesh1.bounds = new BoundingSphere();

			_mesh2 = new Cube(_material2, 500, 500, 500, 1, 1, 1, false);

//			_container3D.mouseChildren = false;
			_view.scene.addChild(_mesh1);
			_view.scene.addChild(_mesh2);

			_mesh1.rotationY = .01;
			_mesh1.mouseEnabled = true;
			_mesh1.mouseDetails = true;
			_mesh2.mouseEnabled = true;
			_mesh2.mouseDetails = true;
//			_container3D.addEventListener(MouseEvent3D.CLICK, onContainerClick);
			_mesh1.addEventListener(MouseEvent3D.MOUSE_UP, onClick);
			_mesh1.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
			_mesh1.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
			_mesh2.addEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
			_camController = new HoverDragController(_view.camera, stage);

			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		private function onMouseOver(event : MouseEvent3D) : void
		{
			_mesh1.scaleX = _mesh1.scaleY = _mesh1.scaleZ = 1.1;
		}

		private function onMouseOut(event : MouseEvent3D) : void
		{
			_mesh1.scaleX = _mesh1.scaleY = _mesh1.scaleZ = 1;
		}

		private function onClick(event : MouseEvent3D) : void
		{
			var material : BitmapMaterial = event.target.material;
			material.mipmap = !material.mipmap;

			var rect : Rectangle = new Rectangle(event.uv.x*material.bitmapData.width-4, event.uv.y*material.bitmapData.height-4, 9, 9);
			material.bitmapData.fillRect(rect, 0x00ff00);
			material.updateTexture();
		}

		private function onMouseMove(event : MouseEvent3D) : void
		{
			var material : BitmapMaterial = event.target.material;
			var rect : Rectangle = new Rectangle(event.uv.x*material.bitmapData.width-4, event.uv.y*material.bitmapData.height-4, 9, 9);
			material.bitmapData.fillRect(rect, 0x00ff00);
			material.updateTexture();
		}


		private function handleEnterFrame(ev : Event) : void
		{
			_mesh1.rotationX += 1;
//			_viewContainer.x += _dirX;
//			_viewContainer.y += _dirY;
//			if (_dirX > 0 && _viewContainer.x > 200) _dirX = -1;
//			if (_dirY > 0 && _viewContainer.y > 200) _dirY = -1;
//			if (_dirX < 0 && _viewContainer.x < -100) _dirX = 1;
//			if (_dirY > 0 && _viewContainer.y < -200) _dirY = 1;

			_view.render();
		}
	}
}