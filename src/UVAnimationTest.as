package
{
	import away3d.animators.UVAnimator;
	import away3d.animators.data.UVAnimationFrame;
	import away3d.animators.data.UVAnimationSequence;
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.BitmapMaterial;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	import mx.core.BitmapAsset;
	
	[SWF(width="800", height="600")]
	public class UVAnimationTest extends Sprite
	{
		private var _view : View3D;
		private var _eyes : Mesh;
		private var _mat : BitmapMaterial;
		private var _animator : UVAnimator;
		
		[Embed(source="/../embeds/uveyes/eyes.png")]
		private var TextureData : Class;
		
		[Embed(source="/../embeds/uveyes/eyes.3ds", mimeType="application/octet-stream")]
		private var MeshData : Class;
		
		
		public function UVAnimationTest()
		{
			super();
			
			initView();
			init3D();
			initAnimation();
		}
		
		
		private function initView() : void
		{
			_view = new View3D;
			this.addChild(_view);
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		private function init3D() : void
		{
			var bmp : BitmapData;
			
			bmp = BitmapAsset(new TextureData).bitmapData;
			
			_mat = new BitmapMaterial(bmp);
			_mat.repeat = true;
			
			AssetLibrary.enableParsers(Parsers.ALL_BUNDLED);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onComplete);
			AssetLibrary.parseData(MeshData);
		}
		
		
		private function initAnimation() : void
		{
			var i : uint;
			var clip : UVAnimationSequence;
			
			clip = new UVAnimationSequence('test');
			for (i=0; i<20; i++) {
				clip.arcane::addFrame(new UVAnimationFrame(Math.random()*0.3-0.15, Math.random()*0.3-0.15), 200);
			}
			
			_animator = new UVAnimator(_mat);
			_animator.addSequence(clip);
			
			_animator.play('test');
		}
		
		
		private function onComplete(ev : LoaderEvent) : void
		{
			_eyes = Mesh(AssetLibrary.getAsset('Cylinder'));
			_eyes.material = _mat;
			_eyes.scale(100);
			_eyes.rotationY = 180;
			_view.scene.addChild(_eyes);
		}
		
		
		private function onEnterFrame(ev : Event) : void
		{
			_view.camera.x = stage.mouseX - stage.stageWidth/2;
			_view.camera.y = stage.mouseY - stage.stageHeight/2;
			_view.camera.lookAt(new Vector3D);
			_view.render();
		}
	}
}