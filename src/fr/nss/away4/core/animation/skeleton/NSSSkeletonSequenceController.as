package fr.nss.away4.core.animation.skeleton {
	import away3d.animators.AnimatorBase;
	import away3d.animators.data.AnimationSequenceBase;
	import away3d.animators.data.AnimationStateBase;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.animators.skeleton.SkeletonTimelineClipNode;
	import away3d.animators.skeleton.SkeletonTreeNode;
	import away3d.arcane;

	import fr.nss.NSSClock;

	import flash.geom.Vector3D;
	
	use namespace arcane;

	/**
	 * AnimationSequenceController provides a controller for single clip-based animation sequences (fe: md2, md5anim).
	
	 * 
	 */ 
	public class NSSSkeletonSequenceController extends AnimatorBase {
	
		private var _sequences : Array;
		private var _activeClip : SkeletonTimelineClipNode;
		private var _sequenceAbsent : String;
		private var _timeScale : Number = 1;
		private var _startTime : uint;

		/**
		 * Creates a new AnimationSequenceController object.
		 */
		public function NSSSkeletonSequenceController() {
			_sequences = [];
		}
		

		
		/**
		 * @inheritDoc
		 */
		override public function set animationState(value : AnimationStateBase) : void
		{
			var state : SkeletonAnimationState = SkeletonAnimationState(value);
			super.animationState = value;

			if (state.numJoints > 0)
				state.blendTree = (_activeClip ||= new SkeletonTimelineClipNode(state.numJoints));
		}

		/**
		 * Plays a sequence with a given name. If the sequence is not found, it may not be loaded yet, and it will retry every frame.
		 * @param sequenceName The name of the clip to be played.
		 */
		public function play(sequenceName : String) : void
		{
			_startTime=uint(NSSClock.currentTime);
			var state : SkeletonAnimationState = SkeletonAnimationState(_animationState);
			if (state && state.numJoints > 0) {
				_activeClip ||= new SkeletonTimelineClipNode(state.numJoints);
				_activeClip.clip = _sequences[sequenceName];
				_activeClip.time = 0;
			}

			if (!(_activeClip && _activeClip.clip)) {
				_sequenceAbsent = sequenceName;
			}
			else {
				_sequenceAbsent = null;
				//_activeClip.time = 0;
			}
			//_activeClip.reset();	_activeClip.time = 0;
		}

		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up animations.
		 */
		public function get timeScale() : Number
		{
			return _timeScale;
		}

		public function set timeScale(value : Number) : void
		{
			_timeScale = value;
		}

		/**
		 * Adds a sequence to the controller.
		 */
		public function addSequence(sequence : SkeletonAnimationSequence) : void
		{
			_sequences[sequence.name] = sequence;
		}

		/**
		 * @inheritDoc
		 */
		override public function clone() : AnimatorBase
		{
			var clone : NSSSkeletonSequenceController = new NSSSkeletonSequenceController();

			clone._sequences = _sequences;

			return clone;
		}

		/**
		 * @inheritDoc
		 * @private
		 *
		 * todo: remove animationState reference, change target to something "IAnimatable" that provides the state?
		 */
		override arcane function updateAnimation(dt:uint) : void
		{
			var blendTree: SkeletonTreeNode;
			var delta: Vector3D;

			// keep trying to play
			if (_sequenceAbsent)
				play(_sequenceAbsent);

			if (_activeClip && _activeClip.clip && _activeClip.clip.duration > 0) {
				blendTree = SkeletonAnimationState(_animationState).blendTree;
				
			
				if(_activeClip.clip.looping){
					var time:Number=(NSSClock.currentTime-_startTime)/_activeClip.clip.duration*_timeScale;
					if (time >= 1) {
						time -= int(time);
						_startTime=uint(NSSClock.currentTime);
					}
					_activeClip.time=time;
				}else{
					_activeClip.time=(NSSClock.currentTime-_startTime)/_activeClip.clip.duration*_timeScale;
				}
			
				
				
				//_activeClip.time += dt/_activeClip.clip.duration*_timeScale;
				
					//Logger.log(_activeClip.clip.name+"   "+_activeClip.clip.looping+"   "+_activeClip.time);
				_animationState.invalidateState();
				blendTree.updatePositionData();
				delta = blendTree.rootDelta;

				var dist : Number = delta.length;
				var len : uint;

				if (dist > 0) {
					len = _targets.length;
					for (var i : uint = 0; i < len; ++i)
						_targets[i].translateLocal(delta, dist);
				}
			
			}
		}

		/**
		 * Retrieves a sequence with a given name.
		 * @private
		 */
		public function getSequence(sequenceName : String) : AnimationSequenceBase
		{
			return _sequences[sequenceName];
		}
		
		public function get startTime() : uint {
			return _startTime;
		}
		
		public function get activeClip() : SkeletonTimelineClipNode {
			return _activeClip;
		}
	}
}