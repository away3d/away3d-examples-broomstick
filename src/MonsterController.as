<<<<<<< HEAD
/**
 * Author: David Lenaerts
 */
package
{
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.AnimatorEvent;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.materials.BitmapMaterial;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;

	public class MonsterController extends EventDispatcher
	{

		[Embed(source="/../embeds/hellknight/hellknight.jpg")]
		private var BodyAlbedo : Class;

		[Embed(source="/../embeds/hellknight/hellknight_s.png")]
		private var BodySpec : Class;

		[Embed(source="/../embeds/hellknight/hellknight_local.png")]
		private var BodyNorms : Class;

		public static const ROTATION_SPEED : Number = 3;
		public static const RUN_SPEED : Number = 2;
		public static const WALK_SPEED : Number = 1;
		public static const MD5_DIR : String = "hellknight";
		public static const MESH_NAME : String = "hellknight";
		public static const IDLE_NAME : String = "idle2";
		public static const WALK_NAME : String = "walk7";
		public static const ANIM_NAMES : Array = [ 	IDLE_NAME, WALK_NAME,
													"attack3", "turret_attack", "attack2",
													"chest", "roar1", "leftslash", "headpain",
													"pain1", "pain_luparm", "range_attack2"];
		public static const ANIM_LOOPS : Array = [ true, true ];
		public static const XFADE_TIME : Number = .5;

		private var _running : Boolean;
		private var _currentAction : String;
		private var _onceAction : String;
		private var _timeScale : Number;
		private var _walkSpeed : Number = 1;

		private var _controller : SmoothSkeletonAnimator;
		private var _mesh : Mesh;

		private var _rotationDir : Number = 0;
		private var _bodyMaterial : BitmapMaterial;
		private var _moveDir : Number;
		private var _sequences : Vector.<SkeletonAnimationSequence>;

		public function MonsterController(timeScale : Number = 1)
		{
			_sequences = new Vector.<SkeletonAnimationSequence>();
			_timeScale = timeScale;
			initMaterials();
			initMesh();
		}

		public function turn(dir : Number) : void
		{
			_rotationDir = dir;
		}

		public function update() : void
		{
			_mesh.rotationY += _rotationDir * ROTATION_SPEED;
		}

		public function walk(dir : Number) : void
		{
			if (_currentAction != WALK_NAME)
				setNormalState(WALK_NAME);

			_moveDir = dir;
			_walkSpeed = _moveDir;
			_controller.timeScale = (_moveDir*(_running? RUN_SPEED : WALK_SPEED))*_timeScale;
		}

		public function stop() : void
		{
			if (_currentAction == IDLE_NAME) return;
			_controller.timeScale = _timeScale;
			setNormalState(IDLE_NAME);
		}

		private function setNormalState(id : String) : void
		{
			_currentAction = id;
			if (!_onceAction) {
				_controller.play(id, XFADE_TIME);
			}
		}

		public function get running() : Boolean
		{
			return _running;
		}

		public function set running(value : Boolean) : void
		{
			_running = value;
			_walkSpeed = _moveDir*(value? RUN_SPEED : WALK_SPEED);
			if (!_onceAction && _currentAction == WALK_NAME) {
				_controller.timeScale = _walkSpeed*_timeScale;
			}
		}

		public function action(mode : uint) : void
		{
			_onceAction = ANIM_NAMES[mode+2];
//			if (_onceAction == "leftslash")
//				_onceAction = "rightslash";
			_controller.timeScale = _timeScale;
			_controller.play(_onceAction, XFADE_TIME);
		}

		public function get mesh() : Mesh
		{
			return _mesh;
		}

		private function initMaterials() : void
		{
			_bodyMaterial = new BitmapMaterial(new BodyAlbedo().bitmapData);
//			_bodyMaterial.numLights = 3;
			_bodyMaterial.gloss = 20;
			_bodyMaterial.specular = 1.5;
			_bodyMaterial.ambientColor = 0x505060;
			_bodyMaterial.specularMap = new BodySpec().bitmapData;
			_bodyMaterial.normalMap = new BodyNorms().bitmapData;
		}

		public function get bodyMaterial() : BitmapMaterial
		{
			return _bodyMaterial;
		}

		private function initMesh() : void
		{
			AssetLibrary.enableParser(MD5MeshParser);
			AssetLibrary.enableParser(MD5AnimParser);
			
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.load(new URLRequest("assets/" + MD5_DIR + "/" + MESH_NAME + ".md5mesh"));
		}

		private function onAssetComplete(event : AssetEvent) : void
		{
			if (event.asset.assetType == AssetType.MESH) {
				_mesh = event.asset as Mesh;
				_mesh.material = _bodyMaterial;
				dispatchEvent(new MonsterEvent(MonsterEvent.MESH_COMPLETE));
				initAnimation();
			} else if (event.asset.assetType == AssetType.ANIMATION) {
				var seq : SkeletonAnimationSequence = event.asset as SkeletonAnimationSequence;
				seq.name = event.asset.assetNamespace;
				_controller.addSequence(seq);
				
				if (seq.name == IDLE_NAME || seq.name == WALK_NAME) {
					seq.looping = true;
				} else {
					seq.looping = false;
					seq.addEventListener(AnimatorEvent.SEQUENCE_DONE, onClipComplete);
				}
				
				if (seq.name == IDLE_NAME)
					stop();
			}
		}

		private function initAnimation() : void
		{
			_controller = new SmoothSkeletonAnimator(SkeletonAnimationState(_mesh.animationState));
			_controller.timeScale = _timeScale;
			
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			
			for (var i : uint = 0; i < ANIM_NAMES.length; ++i) {
				AssetLibrary.load(new URLRequest("assets/" + MD5_DIR + "/" + ANIM_NAMES[i] + ".md5anim"), null, null, ANIM_NAMES[i]);
			}
		}

		private function onClipComplete(event : AnimatorEvent) : void
		{
			_onceAction = null;
			_controller.play(_currentAction, XFADE_TIME);
			if (_currentAction == WALK_NAME)
				_controller.timeScale = (_moveDir*(_running? RUN_SPEED : WALK_SPEED))*_timeScale;
		}
	}
}
=======
/**
 * Author: David Lenaerts
 */
package
{
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.events.AnimatorEvent;
	import away3d.events.ResourceEvent;
	import away3d.loading.ResourceManager;
	import away3d.materials.BitmapMaterial;
	import away3d.entities.Mesh;

	public class MonsterController
	{

		[Embed(source="/../embeds/hellknight/hellknight.jpg")]
		private var BodyAlbedo : Class;

		[Embed(source="/../embeds/hellknight/hellknight_s.png")]
		private var BodySpec : Class;

		[Embed(source="/../embeds/hellknight/hellknight_local.png")]
		private var BodyNorms : Class;

		public static const ROTATION_SPEED : Number = 3;
		public static const RUN_SPEED : Number = 2;
		public static const WALK_SPEED : Number = 1;
		public static const MD5_DIR : String = "hellknight";
		public static const MESH_NAME : String = "hellknight";
		public static const IDLE_NAME : String = "idle2";
		public static const WALK_NAME : String = "walk7";
		public static const ANIM_NAMES : Array = [ 	IDLE_NAME, WALK_NAME,
													"attack3", "turret_attack", "attack2",
													"chest", "roar1", "leftslash", "headpain",
													"pain1", "pain_luparm", "range_attack2"];
		public static const ANIM_LOOPS : Array = [ true, true ];
		public static const XFADE_TIME : Number = .5;

		private var _running : Boolean;
		private var _currentAction : String;
		private var _onceAction : String;
		private var _timeScale : Number;
		private var _walkSpeed : Number = 1;

		private var _controller : SmoothSkeletonAnimator;
		private var _mesh : Mesh;

		private var _rotationDir : Number = 0;
		private var _bodyMaterial : BitmapMaterial;
		private var _moveDir : Number;
		private var _sequences : Vector.<SkeletonAnimationSequence>;

		public function MonsterController(timeScale : Number = 1)
		{
			_sequences = new Vector.<SkeletonAnimationSequence>();
			_timeScale = timeScale;
			initMaterials();
			initMesh();
		}

		public function turn(dir : Number) : void
		{
			_rotationDir = dir;
		}

		public function update() : void
		{
			_mesh.rotationY += _rotationDir * ROTATION_SPEED;
		}

		public function walk(dir : Number) : void
		{
			if (_currentAction != WALK_NAME)
				setNormalState(WALK_NAME);

			_moveDir = dir;
			_walkSpeed = _moveDir;
			_controller.timeScale = (_moveDir*(_running? RUN_SPEED : WALK_SPEED))*_timeScale;
		}

		public function stop() : void
		{
			if (_currentAction == IDLE_NAME) return;
			_controller.timeScale = _timeScale;
			setNormalState(IDLE_NAME);
		}

		private function setNormalState(id : String) : void
		{
			_currentAction = id;
			if (!_onceAction) {
				_controller.play(id, XFADE_TIME);
			}
		}

		public function get running() : Boolean
		{
			return _running;
		}

		public function set running(value : Boolean) : void
		{
			_running = value;
			_walkSpeed = _moveDir*(value? RUN_SPEED : WALK_SPEED);
			if (!_onceAction && _currentAction == WALK_NAME) {
				_controller.timeScale = _walkSpeed*_timeScale;
			}
		}

		public function action(mode : uint) : void
		{
			_onceAction = ANIM_NAMES[mode+2];
//			if (_onceAction == "leftslash")
//				_onceAction = "rightslash";
			_controller.timeScale = _timeScale;
			_controller.play(_onceAction, XFADE_TIME);
		}

		public function get mesh() : Mesh
		{
			return _mesh;
		}

		private function initMaterials() : void
		{
			_bodyMaterial = new BitmapMaterial(new BodyAlbedo().bitmapData);
//			_bodyMaterial.numLights = 3;
			_bodyMaterial.gloss = 20;
			_bodyMaterial.specular = 1.5;
			_bodyMaterial.ambientColor = 0x505060;
			_bodyMaterial.specularMap = new BodySpec().bitmapData;
			_bodyMaterial.normalMap = new BodyNorms().bitmapData;
		}

		public function get bodyMaterial() : BitmapMaterial
		{
			return _bodyMaterial;
		}

		private function initMesh() : void
		{
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
			_mesh = Mesh(ResourceManager.instance.getResource("assets/" + MD5_DIR + "/" + MESH_NAME + ".md5mesh"));;
			_mesh.material = _bodyMaterial;
		}

		private function onResourceRetrieved(event : ResourceEvent) : void
		{
			if (event.resource == _mesh) {
				initAnimation();
				_mesh.showBoundingBox = true;
			}
			else {
				_controller.addSequence(SkeletonAnimationSequence(event.resource));
				if (event.resource.name == IDLE_NAME) stop();
			}
		}

		private function initAnimation() : void
		{
			_controller = new SmoothSkeletonAnimator(SkeletonAnimationState(_mesh.animationState));
			_controller.timeScale = _timeScale;

			for (var i : uint = 0; i < ANIM_NAMES.length; ++i) {
				_sequences[i] = SkeletonAnimationSequence(ResourceManager.instance.getResource("assets/" + MD5_DIR + "/" + ANIM_NAMES[i] + ".md5anim"));
				_sequences[i].name = ANIM_NAMES[i];
				_sequences[i].looping = ANIM_LOOPS[i];

				if (!_sequences[i].looping)
					_sequences[i].addEventListener(AnimatorEvent.SEQUENCE_DONE, onClipComplete);
			}
		}

		private function onClipComplete(event : AnimatorEvent) : void
		{
			_onceAction = null;
			_controller.play(_currentAction, XFADE_TIME);
			if (_currentAction == WALK_NAME)
				_controller.timeScale = (_moveDir*(_running? RUN_SPEED : WALK_SPEED))*_timeScale;
		}
	}
}
>>>>>>> Wireframe primitives
