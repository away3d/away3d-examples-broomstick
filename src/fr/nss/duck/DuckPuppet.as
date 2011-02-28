package fr.nss.duck {
	import away3d.events.AnimationEvent;
	import away3d.entities.Mesh;

	import fr.nss.NSSClock;
	import fr.nss.away4.core.animation.skeleton.NSSSkeletonSequenceController;

	import flash.events.MouseEvent;

	/**
	 * @author Seraf
	 */
	public class DuckPuppet {
		
		private var eyeController : NSSSkeletonSequenceController;
		private var bodyController : NSSSkeletonSequenceController;
		private var becController : NSSSkeletonSequenceController;
		private var duckBodyMesh : Mesh;
		private var duckBecMesh : Mesh;
		private var eye : Mesh;

		private const STAND01 : String="stand01";
		private const STAND02 : String="stand02";
		private const WALK : String="walk";
		private const START_WALK : String="startWalk";
		private const END_WALK : String="endWalk";
	
		private var startTime : uint;

		public function DuckPuppet(){

			eye=Mesh(World.ressources.duckEye01.mesh.clone());
			World.view.scene.addChild(eye);
			eyeController = NSSSkeletonSequenceController(eye.animationController);

			duckBodyMesh=Mesh(World.ressources.duckBody.mesh.clone());
			eye.addChild(duckBodyMesh);
			bodyController = NSSSkeletonSequenceController(duckBodyMesh.animationController);
			
			duckBecMesh=Mesh(World.ressources.duckBec01.mesh.clone());
			eye.addChild(duckBecMesh);
			becController = NSSSkeletonSequenceController(duckBecMesh.animationController);

		}

		private function endStand02(event : AnimationEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(STAND02).removeEventListener(AnimationEvent.PLAYBACK_ENDED, endStand02);
				bodyController.play(START_WALK);startTime=uint(bodyController.startTime);
				eyeController.play(START_WALK);
				becController.play(START_WALK);
				bodyController.getSequence(START_WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, startWalkEnd);
			}
		}
		private function endStand01(event : AnimationEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(STAND01).removeEventListener(AnimationEvent.PLAYBACK_ENDED, endStand01);
				bodyController.play(START_WALK);startTime=uint(bodyController.startTime);
				eyeController.play(START_WALK);
				becController.play(START_WALK);
				bodyController.getSequence(START_WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, startWalkEnd);
			}
		}

		private function endWalkEnd(event : AnimationEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(END_WALK).removeEventListener(AnimationEvent.PLAYBACK_ENDED, endWalkEnd);
			if(Math.random()>.66){
				bodyController.play(START_WALK);startTime=uint(bodyController.startTime);
				eyeController.play(START_WALK);
				becController.play(START_WALK);
				bodyController.getSequence(START_WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, startWalkEnd);
			}else if(Math.random()<.33){
				bodyController.play(STAND02);startTime=uint(bodyController.startTime);
				eyeController.play(STAND02);
				becController.play(STAND02);
				bodyController.getSequence(STAND02).addEventListener(AnimationEvent.PLAYBACK_ENDED, endStand02);
			}else{
				bodyController.play(STAND01);startTime=uint(bodyController.startTime);
				eyeController.play(STAND01);
				becController.play(STAND01);
				bodyController.getSequence(STAND01).addEventListener(AnimationEvent.PLAYBACK_ENDED, endStand01);
			}
			}
		}

		private function walkEnd(event : AnimationEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				if(Math.random()<.33){
					bodyController.getSequence(WALK).removeEventListener(AnimationEvent.PLAYBACK_ENDED, walkEnd);
					bodyController.play(END_WALK);
					startTime=uint(bodyController.startTime);
					eyeController.play(END_WALK);
					becController.play(END_WALK);
					bodyController.getSequence(END_WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, endWalkEnd);
				}else{
					bodyController.getSequence(START_WALK).removeEventListener(AnimationEvent.PLAYBACK_ENDED, startWalkEnd);
					bodyController.play(WALK);
					startTime=uint(bodyController.startTime);
					becController.play(WALK);
					eyeController.play(WALK);
					bodyController.getSequence(WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, walkEnd);

				}
			}
		}

		private function startWalkEnd(event : AnimationEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(START_WALK).removeEventListener(AnimationEvent.PLAYBACK_ENDED, startWalkEnd);
				bodyController.play(WALK);
				startTime=uint(bodyController.startTime);
				becController.play(WALK);
				eyeController.play(WALK);
				bodyController.getSequence(WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, walkEnd);
			}

		}

		public function playAnim(event : MouseEvent) : void {
			bodyController.play(START_WALK);	startTime=uint(bodyController.startTime);
			eyeController.play(START_WALK);
			becController.play(START_WALK);
			bodyController.getSequence(START_WALK).addEventListener(AnimationEvent.PLAYBACK_ENDED, startWalkEnd);
		}
		
		public function get mesh() : Mesh {
			return eye;
		}
		
	}
}
