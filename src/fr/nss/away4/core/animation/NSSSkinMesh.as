package fr.nss.away4.core.animation {
	import away3d.animators.data.SkeletonAnimation;
	import away3d.animators.skeleton.SkeletonJoint;
	import away3d.animators.skeleton.Skeleton;
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.math.Quaternion;
	import away3d.entities.Mesh;

	import fr.nss.away4.core.animation.skeleton.NSSSkeletonSequenceController;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	/**
	 * @author Seraf
	 */
	public class NSSSkinMesh {
		protected var _maxJointCount : int=-1;
		protected var _numJoints : int;
		protected var _meshData : Vector.<MeshData>;
		protected var _mesh: Mesh;
		protected var _bindPoses : Vector.<Matrix3D>;
		protected var _geometry : Geometry;
		protected var _skeleton : Skeleton;
		protected var _animationController : NSSSkeletonSequenceController;
		protected var _animation : SkeletonAnimation;
		protected var _rotationQuat : Quaternion;
		protected   var vertexData : Vector.<VertexData>;
		protected	var jointData : Vector.<JointData>;
		
		public function NSSSkinMesh(){
			_rotationQuat = new Quaternion();
			var t1 : Quaternion = new Quaternion();
			var t2 : Quaternion = new Quaternion();
			t1.fromAxisAngle(Vector3D.X_AXIS, -Math.PI*.5);
			t2.fromAxisAngle(Vector3D.Y_AXIS, Math.PI);
			_rotationQuat.multiply(t2, t1);
			_mesh = new Mesh(null, null);
			_geometry = _mesh.geometry;
			_animationController = new NSSSkeletonSequenceController();
			_skeleton = new Skeleton();
			_animation = new SkeletonAnimation(_skeleton);
			_geometry.animation = _animation;
			_mesh.animationController = _animationController;
			
		}

		
		protected function j(boneName:String,boneIndex:uint,parentIndex:int,x:Number,y:Number,z:Number,rx:Number,ry:Number,rz:Number) : void{
			var p:Vector3D=new Vector3D(x,y,z);
			p=_rotationQuat.rotatePoint(p);
			var q:Quaternion=toQuaternion(rx,ry,rz);
			_bindPoses[boneIndex]=q.toMatrix3D();
			_bindPoses[boneIndex].appendTranslation(p.x,p.y,p.z);
			var i:Matrix3D = _bindPoses[boneIndex].clone();
			i.invert();
			var joint:SkeletonJoint=new SkeletonJoint();
			joint.name=boneName;
			joint.parentIndex=parentIndex;
			joint.inverseBindPose=i.rawData;
			_skeleton.joints[boneIndex]=joint;
		}
		protected function v(index : int,s:Number,t:Number,startWeight:int,countWeight:int) : void{
			
			vertexData[index]=new VertexData(index,s,t,startWeight,countWeight);
			
		}
		protected function w(index:int,joint:int,bias:Number,x:Number,y:Number,z:Number) : void{
			
			jointData[index]=new JointData(index,joint,bias,new Vector3D(x,y,z));
			
		}
		protected function lock() : void{
			_animation.jointsPerVertex = _maxJointCount;
			for (var i:uint = 0; i < _meshData.length; ++i) {
				_geometry.addSubGeometry(translateGeom(_meshData[i].vertexData, _meshData[i].weightData, _meshData[i].indices));
			}
			_geometry.animation = _animation;
			_mesh.animationController = _animationController;
			
			
			 
		}
	
		public function get mesh() : Mesh{
			return _mesh;
		}
		protected function joint_num(n:uint) : void{
			_numJoints = n;
			_bindPoses = new Vector.<Matrix3D>(n, true);
		}
		protected function vertex_num(n:uint) : void{
			vertexData = new Vector.<VertexData>(n, true);
		}
		protected function weight_num(n:uint) : void{
			jointData = new Vector.<JointData>(n, true);
		}
		protected function max_j_indices(n:uint,v:Vector.<uint>) : void{
			_maxJointCount=n;
			_meshData ||= new Vector.<MeshData>();
			var l : uint = _meshData.length;
			_meshData[l] = new MeshData();
			_meshData[l].vertexData = vertexData;
			_meshData[l].weightData = jointData;
			_meshData[l].indices=v;
		}
		
	/**
		 * Converts the mesh data to a SkinnedSub instance.
		 * @param vertexData The mesh's vertices.
		 * @param weights The joint weights per vertex.
		 * @param indices The indices for the faces.
		 * @return A SkinnedSubGeometry instance containing all geometrical data for the current mesh.
		 */
		protected function translateGeom(vertexData : Vector.<VertexData>, weights : Vector.<JointData>, indices : Vector.<uint>) : SkinnedSubGeometry
		{
			var len : int = vertexData.length;
			var v1 : int, v2 : int, v3 : int;
			var vertex : VertexData;
			var weight  : JointData;
			var bindPose : Matrix3D;
			var pos : Vector3D;
			var subGeom : SkinnedSubGeometry = new SkinnedSubGeometry(_maxJointCount);
			var uvs : Vector.<Number> = new Vector.<Number>(len * 2, true);
			var vertices : Vector.<Number> = new Vector.<Number>(len * 3, true);
			var jointIndices : Vector.<Number> = new Vector.<Number>(len * _maxJointCount, true);
			var jointWeights : Vector.<Number> = new Vector.<Number>(len * _maxJointCount, true);
			var l : int;

			for (var i : int = 0; i < len; ++i) {
				vertex = vertexData[i];
				v1 = vertex.index * 3;
				v2 = v1 + 1;
				v3 = v1 + 2;
				vertices[v1] = vertices[v2] = vertices[v3] = 0;

				for (var j : int = 0; j < vertex.countWeight; ++j) {
					weight = weights[vertex.startWeight + j];
					bindPose = _bindPoses[weight.joint];
					pos = bindPose.transformVector(weight.pos);
					vertices[v1] += pos.x * weight.bias;
					vertices[v2] += pos.y * weight.bias;
					vertices[v3] += pos.z * weight.bias;

					// indices need to be multiplied by 3 (amount of matrix registers)
					jointIndices[l] = weight.joint * 3;
					jointWeights[l++] = weight.bias;
				}

				for (j = vertex.countWeight; j < _maxJointCount; ++j) {
					jointIndices[l] = 0;
					jointWeights[l++] = 0;
				}

				v1 = vertex.index << 1;
				uvs[v1++] = vertex.s;
				uvs[v1] = vertex.t;
			}

			subGeom.updateVertexData(vertices);
			subGeom.updateUVData(uvs);
			subGeom.updateIndexData(indices);
			subGeom.jointIndexData = jointIndices;
			subGeom.jointWeightsData = jointWeights;

			return subGeom;
		}
		protected function toQuaternion(_x:Number,_y:Number,_z:Number) : Quaternion
		{
			var quat : Quaternion = new Quaternion();
			
			quat.x = _x;
			quat.y = _y;
			quat.z = _z;

			// quat supposed to be unit length
			var t : Number = 1 - quat.x * quat.x - quat.y * quat.y - quat.z * quat.z;
			quat.w = t < 0 ? 0 : -Math.sqrt(t);

			

			var rotQuat : Quaternion = new Quaternion();
			rotQuat.multiply(_rotationQuat, quat);

			return rotQuat;
		}
		
}
}

import flash.geom.Vector3D;

class VertexData
{
	public var index : int;
	public var s : Number;
	public var t : Number;
	public var startWeight : int;
	public var countWeight : int;
	public function VertexData(index : int,s:Number,t:Number,startWeight:int,countWeight:int){
		this.index=index;this.s=s;this.t=t;this.startWeight=startWeight;this.countWeight=countWeight;
	}
}

class JointData
{
	public var index : int;
	public var joint : int;
	public var bias : Number;
	public var pos : Vector3D;
	public function JointData(index:int,joint:int,bias:Number,pos:Vector3D){
		this.index=index;this.joint=joint;this.bias=bias;this.pos=pos;
	}
}

class MeshData
{
	public var vertexData : Vector.<VertexData>;
	public var weightData : Vector.<JointData>;
	public var indices : Vector.<uint>;
}
