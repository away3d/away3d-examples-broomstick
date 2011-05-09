package
{
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimation;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.animators.skeleton.Skeleton;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoadingEvent;
	import away3d.library.assets.AssetType;
	import away3d.library.AssetLibrary;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	[SWF(width="800", height="600", frameRate="60")]
	public class AssetLibraryTest extends Sprite
	{
		private var _view : View3D; 
		
		private var _anim : SkeletonAnimation;
		private var _state : SkeletonAnimationState;
		private var _ctrl : SmoothSkeletonAnimator;
		private var _container : ObjectContainer3D;
		
		private var _meshes : Vector.<Mesh>;
		
		private var _mat : BitmapMaterial;
		
		/*
		[Embed(source="../../../../../../../Desktop/mayaout.awd", mimeType="application/octet-stream")]
		private var CharacterAsset : Class;
		*/
		
		public function AssetLibraryTest()
		{
			super();
			
			_view = new View3D;
			//_view.camera.z = 316;
			//_view.camera.x = -400;
			//_view.camera.y = 50;
			_view.camera.lookAt(new Vector3D);
			this.addChild(_view);
			
			var bmp : BitmapData = new BitmapData(128, 128, false, 0);
			bmp.perlinNoise(10, 10, 10, 10, true, false, 7, true);
			_mat = new BitmapMaterial(bmp);
			
			_meshes = new Vector.<Mesh>;
			
			_container = new ObjectContainer3D;
			_container.y = -150;
			_container.scale(20);
			_container.addChild(new Cube(new ColorMaterial(0x880000), 1, 1, 1));
			_view.scene.addChild(_container); 
			
			AssetLibrary.enableParsers(Parsers.ALL_BUNDLED);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, _handleLibAssetRetrieved);
			AssetLibrary.addEventListener(LoadingEvent.RESOURCE_COMPLETE, _handleLibResourceRetrieved);
			//AssetLibrary.parseData(CharacterAsset);
			//_lib.load(new URLRequest('assets/bindtest.awd'), false, null);
			//AssetLibrary.load(new URLRequest('../../../../../../../Desktop/mayaout.awd'));
			AssetLibrary.load(new URLRequest('../../../../../../../Desktop/guy-anims.awd'));
			
			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			
			this.stage.addEventListener(KeyboardEvent.KEY_UP, _handleStageKeyUp);
		}
		
		
		private function _initAnimation() : void
		{
			if (!_anim) {
				var seq : SkeletonAnimationSequence;
				var skel : Skeleton;
				var anim : SkeletonAnimation;
				var ctrl : SmoothSkeletonAnimator;
				
				skel = Skeleton(AssetLibrary.getAsset('myskel')); 
				seq = SkeletonAnimationSequence(AssetLibrary.getAsset('myanim'));
				
				_anim = new SkeletonAnimation(skel, 3);
				_state = new SkeletonAnimationState(_anim);
				_ctrl = new SmoothSkeletonAnimator(SkeletonAnimationState(_state));
				_ctrl.updateRootPosition = false;
			}
		}
		
		
		private function _handleStageKeyUp(ev : KeyboardEvent) : void
		{
			if (_ctrl) {
				switch (ev.keyCode) {
					case Keyboard.NUMBER_1:
						_ctrl.play('breath');
						break;
					case Keyboard.NUMBER_2:
						_ctrl.play('walk');
						break;
					case Keyboard.NUMBER_3:
						_ctrl.play('laugh');
						break;
					case Keyboard.NUMBER_4:
						_ctrl.play('sad');
						break;
					case Keyboard.NUMBER_5:
						_ctrl.play('dance');
						break;
					case Keyboard.NUMBER_6:
						_ctrl.play('clap');
						break;
					case Keyboard.NUMBER_7:
						_ctrl.play('talk01');
						break;
					case Keyboard.NUMBER_8:
						_ctrl.play('waveOtt');
						break;
					case Keyboard.NUMBER_9:
						_ctrl.play('happy');
						break;
					case Keyboard.NUMBER_0:
						_ctrl.play('shakehead');
						break;
				}
			}
		}
		
		private function _handleEnterFrame(ev : Event) : void
		{
			_container.rotationY += 0.5;
			_view.render();
		}
		
		
		private function _handleLibAssetRetrieved(ev : AssetEvent) : void
		{
			switch (ev.asset.assetType) {
				case AssetType.ANIMATION:
					_initAnimation();
					_ctrl.addSequence(SkeletonAnimationSequence(ev.asset));
					break;
				case AssetType.SKELETON:
					ev.asset.name = 'myskel';
					break;
				case AssetType.MESH:
					trace(ev.asset.name);
					var mesh : Mesh = Mesh(ev.asset);
					_meshes.push(mesh);
					
					if (_anim) {
						mesh.geometry.animation = _anim;
						mesh.animationState = _state;
					}
					
					_container.addChild(mesh);
					mesh.material = _mat;
					
					break;
			}
		}
		
		
		private function _handleLibResourceRetrieved(ev : LoadingEvent) : void
		{
			trace('retrieved everything');
		}
	}
}