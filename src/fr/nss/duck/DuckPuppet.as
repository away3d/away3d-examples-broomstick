package fr.nss.duck {
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.entities.Mesh;
	import away3d.events.AnimatorEvent;
	
	import flash.events.MouseEvent;
	
	import fr.nss.NSSClock;
	import fr.nss.away4.core.animation.skeleton.NSSSkeletonSequenceController;
	import fr.nss.duck.anim.DuckBecAnim;
	import fr.nss.duck.anim.DuckBecEndWalk;
	import fr.nss.duck.anim.DuckBecStand01;
	import fr.nss.duck.anim.DuckBecStand02;
	import fr.nss.duck.anim.DuckBecStartWalk;
	import fr.nss.duck.anim.DuckBobyEndWalk;
	import fr.nss.duck.anim.DuckBodyAnimTest;
	import fr.nss.duck.anim.DuckBodyStand01;
	import fr.nss.duck.anim.DuckBodyStand02;
	import fr.nss.duck.anim.DuckBodyStartWalk;
	import fr.nss.duck.anim.DuckEyeAnim;
	import fr.nss.duck.anim.DuckFaceEndWalk;
	import fr.nss.duck.anim.DuckFaceStand01;
	import fr.nss.duck.anim.DuckFaceStand02;
	import fr.nss.duck.anim.DuckFaceStartWalk;

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

			eye = World.ressources.duckEye01.mesh.clone() as Mesh;
			
			eyeController = World.ressources.eyeController.clone(eye.animationState as SkeletonAnimationState);
			
			duckBodyMesh = World.ressources.duckBody.mesh.clone() as Mesh;
			eye.addChild(duckBodyMesh);
			
			bodyController = World.ressources.bodyController.clone(duckBodyMesh.animationState as SkeletonAnimationState);
			
			duckBecMesh = World.ressources.duckBec01.mesh.clone() as Mesh;
			eye.addChild(duckBecMesh);
			
			becController = World.ressources.becController.clone(duckBecMesh.animationState as SkeletonAnimationState);
		}

		private function endStand02(event : AnimatorEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(STAND02).removeEventListener(AnimatorEvent.SEQUENCE_DONE, endStand02);
				bodyController.play(START_WALK);startTime=uint(bodyController.startTime);
				eyeController.play(START_WALK);
				becController.play(START_WALK);
				bodyController.getSequence(START_WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, startWalkEnd);
			}
		}
		private function endStand01(event : AnimatorEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(STAND01).removeEventListener(AnimatorEvent.SEQUENCE_DONE, endStand01);
				bodyController.play(START_WALK);startTime=uint(bodyController.startTime);
				eyeController.play(START_WALK);
				becController.play(START_WALK);
				bodyController.getSequence(START_WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, startWalkEnd);
			}
		}

		private function endWalkEnd(event : AnimatorEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(END_WALK).removeEventListener(AnimatorEvent.SEQUENCE_DONE, endWalkEnd);
			if(Math.random()>.66){
				bodyController.play(START_WALK);startTime=uint(bodyController.startTime);
				eyeController.play(START_WALK);
				becController.play(START_WALK);
				bodyController.getSequence(START_WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, startWalkEnd);
			}else if(Math.random()<.33){
				bodyController.play(STAND02);startTime=uint(bodyController.startTime);
				eyeController.play(STAND02);
				becController.play(STAND02);
				bodyController.getSequence(STAND02).addEventListener(AnimatorEvent.SEQUENCE_DONE, endStand02);
			}else{
				bodyController.play(STAND01);startTime=uint(bodyController.startTime);
				eyeController.play(STAND01);
				becController.play(STAND01);
				bodyController.getSequence(STAND01).addEventListener(AnimatorEvent.SEQUENCE_DONE, endStand01);
			}
			}
		}

		private function walkEnd(event : AnimatorEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				if(Math.random()<.33){
					bodyController.getSequence(WALK).removeEventListener(AnimatorEvent.SEQUENCE_DONE, walkEnd);
					bodyController.play(END_WALK);
					startTime=uint(bodyController.startTime);
					eyeController.play(END_WALK);
					becController.play(END_WALK);
					bodyController.getSequence(END_WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, endWalkEnd);
				}else{
					bodyController.getSequence(START_WALK).removeEventListener(AnimatorEvent.SEQUENCE_DONE, startWalkEnd);
					bodyController.play(WALK);
					startTime=uint(bodyController.startTime);
					becController.play(WALK);
					eyeController.play(WALK);
					bodyController.getSequence(WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, walkEnd);

				}
			}
		}

		private function startWalkEnd(event : AnimatorEvent) : void {
			var time:Number=(NSSClock.currentTime-startTime)/bodyController.activeClip.clip.duration;
			if(time>1){
				bodyController.getSequence(START_WALK).removeEventListener(AnimatorEvent.SEQUENCE_DONE, startWalkEnd);
				bodyController.play(WALK);
				startTime=uint(bodyController.startTime);
				becController.play(WALK);
				eyeController.play(WALK);
				bodyController.getSequence(WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, walkEnd);
			}

		}

		public function playAnim(event : MouseEvent) : void {
			bodyController.play(START_WALK);	startTime=uint(bodyController.startTime);
			eyeController.play(START_WALK);
			becController.play(START_WALK);
			bodyController.getSequence(START_WALK).addEventListener(AnimatorEvent.SEQUENCE_DONE, startWalkEnd);
		}
		
		public function get mesh() : Mesh {
			return eye;
		}
		
	}
}
