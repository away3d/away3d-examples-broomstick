package fr.nss.away4.core.animation {
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.skeleton.JointPose;
	import away3d.animators.skeleton.SkeletonPose;
	import away3d.arcane;
	import away3d.core.math.Quaternion;

	import flash.geom.Vector3D;
	
	use namespace arcane;
	/**
	 * @author Seraf
	 */
	public class NSSSkinAnim  {


		private var _numFrames : int;
		private var _numJoints : int;

		private var _baseFrameData : Vector.<BaseFrameData>;

		private var _rotationQuat : Quaternion;
		private var _sequence : SkeletonAnimationSequence;
		
		
		private var skelPose : SkeletonPose ;
		private var jointPoses : Vector.<JointPose> ;
		private var _current_joint : BaseFrameData;

		public function get sequence():SkeletonAnimationSequence{
			return _sequence ;
		}
		public function NSSSkinAnim(name:String){
			_rotationQuat = new Quaternion();
			var t1 : Quaternion = new Quaternion();
			var t2 : Quaternion = new Quaternion();
			t1.fromAxisAngle(Vector3D.X_AXIS, -Math.PI*.5);
			t2.fromAxisAngle(Vector3D.Y_AXIS, Math.PI);
			_rotationQuat.multiply(t2, t1);
		
			_sequence = new SkeletonAnimationSequence(null);
			_sequence.name = name;
		}
		protected function c(n:uint): void{
			_current_joint=_baseFrameData[n];
		}
		protected function x(_x:Number) : void{
			_current_joint.position.x=_x;
		}
		protected function y(_y:Number) : void{
			_current_joint.position.y=_y;
		}
		protected function z(_z:Number) : void{
			_current_joint.position.z=_z;
		}
		protected function d(_rx:Number) : void{
			_current_joint.orientation.x=_rx;
			_current_joint.dirty=true;
		}
		protected function s(_ry:Number) : void{
			_current_joint.orientation.y=_ry;
			_current_joint.dirty=true;
		}
		protected function k(_rz:Number) : void{
			_current_joint.orientation.z=_rz;
			_current_joint.dirty=true;
		}
		protected function e() : void{
			skelPose = new SkeletonPose(_numJoints);
			jointPoses = skelPose.jointPoses;
			var pose : JointPose;;
			
			for(var i:uint=0;i<_numJoints;i++){
				pose=new JointPose();
				if(_baseFrameData[i].dirty==true)computeFrameData(_baseFrameData[i]);
				if(i==0){
					pose.orientation.multiply(_rotationQuat, _baseFrameData[i].orientation);
					pose.translation = _rotationQuat.rotatePoint(_baseFrameData[i].position );
				}else{
					pose.orientation.copyFrom(_baseFrameData[i].orientation);
					pose.translation.x = _baseFrameData[i].position.x;
					pose.translation.y = _baseFrameData[i].position.y;
					pose.translation.z = _baseFrameData[i].position.z;
				}
				jointPoses[i]=pose;
				_baseFrameData[i].dirty=false;
			}
			 _sequence.addFrame(skelPose , 1000 / 25);
		}

		private function computeFrameData(bfd : BaseFrameData) : void {
			
			var w:Number = 1 - bfd.orientation.x * bfd.orientation.x - bfd.orientation.y * bfd.orientation.y - bfd.orientation.z * bfd.orientation.z;
			bfd.orientation.w = w < 0 ? 0 : -Math.sqrt(w);
	
		}

		protected function num_frames(n:uint) : void{
			_numFrames = n;
		}
		protected function num_joints(n:uint) : void{
			_numJoints = n;
			_baseFrameData = new Vector.<BaseFrameData>(n, true);
			for(var i:uint=0;i<_numJoints;i++){
				_baseFrameData[i]=new BaseFrameData(new Vector3D(),new Quaternion());
			}
			
		}
	}
}

import away3d.core.math.Quaternion;

import flash.geom.Vector3D;

// value objects

class HierarchyData
{
	public var name : String;
	public var parentIndex : int;
	public var flags : int;
	public var startIndex : int;
}

class BoundsData
{
	public var min : Vector3D;
	public var max : Vector3D;
}

class BaseFrameData
{
	public var dirty : Boolean=true;
	public var position : Vector3D;
	public var orientation : Quaternion;
	public function BaseFrameData(p:Vector3D,q:Quaternion){
		position=p;
		orientation=q;
	}
}

class FrameData
{
	public var index : int;
	public var components : Vector.<Number>;
}