package fr.nss.duck {
	import away3d.materials.BitmapMaterial;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;

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
	import fr.nss.duck.mesh.DuckBec;
	import fr.nss.duck.mesh.DuckBody;
	import fr.nss.duck.mesh.DuckEye;

	/**
	 * @author Seraf
	 */
	public class Ressource3D {
		//[Embed(source="/../bin/duck/duckColor.png")]
		//private var DuckTexture : Class;
		
		public var duckEye01 : DuckEye;
		public var duckBody : DuckBody;
		public var duckBec01 : DuckBec;
		

		public function Ressource3D(){
			
			
			
			duckEye01=new DuckEye();duckEye01.mesh.material=getMaterial();
			duckBody=new DuckBody();duckBody.mesh.material=getMaterial();
			duckBec01=new DuckBec();duckBec01.mesh.material=getMaterial();
				
			var _controller:NSSSkeletonSequenceController = NSSSkeletonSequenceController(duckEye01.mesh.animationController);
			_controller.timeScale = 1;
			
			var anim:DuckEyeAnim=new DuckEyeAnim();anim.sequence.looping=false;
			anim.sequence.name="walk";
			var duckFaceStartWalk:DuckFaceStartWalk=new DuckFaceStartWalk();duckFaceStartWalk.sequence.looping=false;duckFaceStartWalk.sequence.name="startWalk";
			var duckFaceEndWalk:DuckFaceEndWalk=new DuckFaceEndWalk();duckFaceEndWalk.sequence.looping=false;duckFaceEndWalk.sequence.name="endWalk";
			var duckFaceStand01:DuckFaceStand01=new DuckFaceStand01();duckFaceStand01.sequence.looping=false;duckFaceStand01.sequence.name="stand01";
			var duckFaceStand02:DuckFaceStand02=new DuckFaceStand02();duckFaceStand02.sequence.looping=false;duckFaceStand02.sequence.name="stand02";
			
			_controller.addSequence(anim.sequence);
			_controller.addSequence(duckFaceStartWalk.sequence);
			_controller.addSequence(duckFaceEndWalk.sequence);
			_controller.addSequence(duckFaceStand01.sequence);
			_controller.addSequence(duckFaceStand02.sequence);
			
			
			var bodyController:NSSSkeletonSequenceController = NSSSkeletonSequenceController(duckBody.mesh.animationController);
			bodyController.timeScale = 1;
			
			var duckBodyAnim01:DuckBodyAnimTest=new DuckBodyAnimTest();duckBodyAnim01.sequence.looping=false;duckBodyAnim01.sequence.name="walk";
			var duckBodyStartWalk:DuckBodyStartWalk=new DuckBodyStartWalk();duckBodyStartWalk.sequence.looping=false;duckBodyStartWalk.sequence.name="startWalk";
			var duckBodyEndWalk:DuckBobyEndWalk=new DuckBobyEndWalk();duckBodyEndWalk.sequence.looping=false;duckBodyEndWalk.sequence.name="endWalk";
			var duckBodyStand01:DuckBodyStand01=new DuckBodyStand01();duckBodyStand01.sequence.looping=false;duckBodyStand01.sequence.name="stand01";
			var duckBodyStand02:DuckBodyStand02=new DuckBodyStand02();duckBodyStand02.sequence.looping=false;duckBodyStand02.sequence.name="stand02";
			
			bodyController.addSequence(duckBodyAnim01.sequence);
			bodyController.addSequence(duckBodyStartWalk.sequence);
			bodyController.addSequence(duckBodyEndWalk.sequence);
			bodyController.addSequence(duckBodyStand01.sequence);
			bodyController.addSequence(duckBodyStand02.sequence);
			
			var duckBecSkinController:NSSSkeletonSequenceController = NSSSkeletonSequenceController(duckBec01.mesh.animationController);
			duckBecSkinController.timeScale = 1;
			
			var duckBecAnim01:DuckBecAnim=	new DuckBecAnim();duckBecAnim01.sequence.looping=false;duckBecAnim01.sequence.name="walk";
			var duckBecStartWalk:DuckBecStartWalk=	new DuckBecStartWalk();duckBecStartWalk.sequence.looping=false;duckBecStartWalk.sequence.name="startWalk";
			var duckBecEndWalk:DuckBecEndWalk=	new DuckBecEndWalk();duckBecEndWalk.sequence.looping=false;duckBecEndWalk.sequence.name="endWalk";
			var duckBecStand01:DuckBecStand01=	new DuckBecStand01();duckBecStand01.sequence.looping=false;duckBecStand01.sequence.name="stand01";
			var duckBecStand02:DuckBecStand02=	new DuckBecStand02();duckBecStand02.sequence.looping=false;duckBecStand02.sequence.name="stand02";
			
			duckBecSkinController.addSequence(duckBecAnim01.sequence);
			duckBecSkinController.addSequence(duckBecStartWalk.sequence);
			duckBecSkinController.addSequence(duckBecEndWalk.sequence);
			duckBecSkinController.addSequence(duckBecStand01.sequence);
			duckBecSkinController.addSequence(duckBecStand02.sequence);
			
			
			
			
			
			
			
			
		}
		private function getMaterial() : BitmapMaterial {
			var material :BitmapMaterial  = new BitmapMaterial(new DuckBMP(0,0));
			//var material : ColorMaterial = new ColorMaterial(0xCCCCCC );
			material.ambientColor = 0xCCCCCC; //0xdd5525;
			material.specular = .05;
			material.diffuseMethod = new CelDiffuseMethod(4);
			material.specularMethod = new CelSpecularMethod();
			CelSpecularMethod(material.specularMethod).smoothness = .2;
		//	material.addMethod(new FogMethod(_view.camera.lens.far*.99, 0x0CCCCCC));
			material.lights = [World.light];
			
			/* var texture : BitmapData = WireframeMapGenerator.generateSolidMap(m, 0, .1, 0xFFFFFF, 255, 512*2, 512*2);
				var material : BitmapMaterial = new BitmapMaterial(texture);
				material.bothSides = true;
				material.alpha = .5;
				material.transparent = true;
				material.mipmap = false;*/
			
				
				
			return material;
		}
	}
}
