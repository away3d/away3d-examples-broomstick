package com.li.away3d.primitives
{
import away3d.core.base.SubGeometry;
import away3d.materials.MaterialBase;
import away3d.primitives.PrimitiveBase;

import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.geom.Vector3D;

public class FractalTree extends PrimitiveBase
{
    private var _rawVertices:Vector.<Number>;
    private var _rawNormals:Vector.<Number>;
    private var _rawIndices:Vector.<uint>;
    private var _rawUvs:Vector.<Number>;
    private var _rawTangents:Vector.<Number>;
    private var _size:Number;
    private var _off:uint;
    private var _level:uint;
    private var _v0:Vector3D, _v1:Vector3D, _v2:Vector3D, _v3:Vector3D;
    private var _d0:Vector3D, _d1:Vector3D;
    private var _mid:Vector3D, _boxNorm:Vector3D, _triNorm:Vector3D;
    private var _sideLength:Number;
    private var _firstBaseToHeightFactor:Number;
    private var _baseToHeightFactor:Number;
    private var _baseToTriangleHeightFactorRange:Point;
    private var _triangleOffsetFactorRange:Point;
    private var _leafPositions:Vector.<Number>;
    private var _built:Boolean;

    public function FractalTree(material:MaterialBase, width:Number, height:Number, stretching:Number,
                                minAperture:Number, maxAperture:Number,
                                minTwist:Number, maxTwist:Number,
                                level:uint)
    {
        super(material);

        _size = width;
        _level = level;

        _firstBaseToHeightFactor = height;
        _baseToHeightFactor = stretching;
        _baseToTriangleHeightFactorRange = new Point(minAperture, maxAperture);
        _triangleOffsetFactorRange = new Point(minTwist, maxTwist);

        _v0 = new Vector3D();
        _v1 = new Vector3D();
        _v2 = new Vector3D();
        _v3 = new Vector3D();
        _d0 = new Vector3D();
        _d1 = new Vector3D();
        _boxNorm = new Vector3D();

        _leafPositions = new Vector.<Number>();

        buildGeometry(_geometry.subGeometries[0]);
    }

    override protected function buildGeometry(target:SubGeometry):void
    {
        if(_built)
            return;

        _built = true;

        // Init raw buffers.
        _rawVertices = new Vector.<Number>();
        _rawNormals = new Vector.<Number>();
        _rawIndices = new Vector.<uint>();
        _rawUvs = new Vector.<Number>();
        _rawTangents = new Vector.<Number>();

        // Start recursive method.
        buildOpenBox(Vector.<Number>([-_size/2, 0, -_size/2,
                                       _size/2, 0, -_size/2,
                                       _size/2, 0,  _size/2,
                                      -_size/2, 0,  _size/2]), _firstBaseToHeightFactor);
        step(1);

        // Report geom data.
        target.updateVertexData(_rawVertices);
        target.updateVertexNormalData(_rawNormals);
        target.updateIndexData(_rawIndices);
        target.updateVertexTangentData(_rawTangents);
    }

    private function step(level:uint):void
    {
        var last:Vector.<Number> = _rawVertices.slice(_rawVertices.length - 18);
        var right:Vector.<Number> = Vector.<Number>([last[3], last[4], last[5],
                                                     last[6], last[7], last[8],
                                                     last[9], last[10], last[11],
                                                     last[12], last[13], last[14]]);
        var left:Vector.<Number> = Vector.<Number>([last[0], last[1], last[2],
                                                    last[3], last[4], last[5],
                                                    last[12], last[13], last[14],
                                                    last[15], last[16], last[17]])

        if(level > _level)
        {
            // Store the position of the leaves.
            var leaf0:Vector3D = new Vector3D(right[3], right[4], right[5]);
            var leaf1:Vector3D = new Vector3D(left[3], left[4], left[5]);
            _leafPositions.push(leaf0.x, leaf0.y, leaf0.z, leaf1.x, leaf1.y, leaf1.z);

            return;
        }

        buildOpenBox(right);
        step(level + 1);

        buildOpenBox(left);
        step(level + 1);
    }

    // A box consists of a cube without top and bottom with
    // 2 triangles instead at the top.
    private function buildOpenBox(vertices:Vector.<Number>, forceBaseToHeightFactor:Number = -1):void
    {
        // Pre-calculate values for vertices and normals.
        _v0.x = vertices[0];
        _v0.y = vertices[1];
        _v0.z = vertices[2];
        _v1.x = vertices[3];
        _v1.y = vertices[4];
        _v1.z = vertices[5];
        _v2.x = vertices[6];
        _v2.y = vertices[7];
        _v2.z = vertices[8];
        _v3.x = vertices[9];
        _v3.y = vertices[10];
        _v3.z = vertices[11];
        _d0 = _v0.subtract(_v1);
        _d1 = _v0.subtract(_v3);
        _mid = _d1.clone();
        _mid.scaleBy(-rand(_triangleOffsetFactorRange.x, _triangleOffsetFactorRange.y));
        _boxNorm = _d1.crossProduct(_d0);
        _boxNorm.normalize();
        _triNorm = _boxNorm.clone();
        _sideLength = _d0.length;
        _boxNorm.scaleBy((forceBaseToHeightFactor > 0 ? forceBaseToHeightFactor : _baseToHeightFactor)*_sideLength);
        _triNorm.scaleBy(rand(_baseToTriangleHeightFactorRange.x, _baseToTriangleHeightFactorRange.y)*_sideLength);

        // Set vertices.
        for(var i:uint; i < 2; i++)
        {
            _rawVertices.push(_v0.x, _v0.y, _v0.z); // flb (front left bottom)
            _rawVertices.push(_v1.x, _v1.y, _v1.z); // frb
            _rawVertices.push(_v2.x, _v2.y, _v2.z); // brb
            _rawVertices.push(_v3.x, _v3.y, _v3.z); // blb
            _rawVertices.push(_v0.x + _boxNorm.x, _v0.y + _boxNorm.y, _v0.z + _boxNorm.z); // flt
            _rawVertices.push(_v1.x + _boxNorm.x, _v1.y + _boxNorm.y, _v1.z + _boxNorm.z); // frt
            _rawVertices.push(_v2.x + _boxNorm.x, _v2.y + _boxNorm.y, _v2.z + _boxNorm.z); // brt
            _rawVertices.push(_v3.x + _boxNorm.x, _v3.y + _boxNorm.y, _v3.z + _boxNorm.z); // blt
        }
        _rawVertices.push(_v1.x + _boxNorm.x, _v1.y + _boxNorm.y, _v1.z + _boxNorm.z); // flt
        _rawVertices.push(_v1.x + _boxNorm.x + _mid.x + _triNorm.x, _v1.y + _boxNorm.y + _mid.y + _triNorm.y, _v1.z + _boxNorm.z + _mid.z + _triNorm.z); // tri front
        _rawVertices.push(_v2.x + _boxNorm.x, _v2.y + _boxNorm.y, _v2.z + _boxNorm.z); // frt
        _rawVertices.push(_v3.x + _boxNorm.x, _v3.y + _boxNorm.y, _v3.z + _boxNorm.z); // brt
        _rawVertices.push(_v0.x + _boxNorm.x + _mid.x + _triNorm.x, _v0.y + _boxNorm.y + _mid.y + _triNorm.y, _v0.z + _boxNorm.z + _mid.z + _triNorm.z); // tri back
        _rawVertices.push(_v0.x + _boxNorm.x, _v0.y + _boxNorm.y, _v0.z + _boxNorm.z); // blt

        // Set indices.
        var off0:uint = _off + 8;
        _rawIndices.push(_off + 0, _off + 4, _off + 1, _off + 4, _off + 5, _off + 1); // Front.
        _rawIndices.push(_off + 2, _off + 6, _off + 3, _off + 6, _off + 7, _off + 3); // Back.
        _rawIndices.push(off0 + 1, off0 + 5, off0 + 2, off0 + 5, off0 + 6, off0 + 2); // Right.
        _rawIndices.push(off0 + 3, off0 + 7, off0 + 0, off0 + 7, off0 + 4, off0 + 0); // Left.
        _rawIndices.push(off0 + 8, off0 + 9, off0 + 10, off0 + 11, off0 + 12, off0 + 13); // Tris.
        _off += 22;

        // Set uvs.
        _rawUvs.push(0, 1, 1, 1, 0, 1, 1, 1);
        _rawUvs.push(0, 0, 1, 0, 0, 0, 1, 0);
        _rawUvs.push(0, 1, 1, 1, 0, 1, 1, 1);
        _rawUvs.push(0, 0, 1, 0, 0, 0, 1, 0);
        _rawUvs.push(0, 1, 0.5, 0.5, 1, 1);
        _rawUvs.push(0, 1, 0.5, 0.5, 1, 1);

        // Set normals.
        var normFront:Vector3D = _d1.clone();
        normFront.normalize();
        var normBack:Vector3D = normFront.clone();
        normBack.negate();
        var normLeft:Vector3D = _d0.clone();
        normLeft.normalize();
        var normRight:Vector3D = normLeft.clone();
        normRight.negate();
        _rawNormals.push(normFront.x, normFront.y, normFront.z,
                         normFront.x, normFront.y, normFront.z,
                         normBack.x, normBack.y, normBack.z,
                         normBack.x, normBack.y, normBack.z);
        _rawNormals.push(normFront.x, normFront.y, normFront.z,
                         normFront.x, normFront.y, normFront.z,
                         normBack.x, normBack.y, normBack.z,
                         normBack.x, normBack.y, normBack.z);
        _rawNormals.push(normLeft.x, normLeft.y, normLeft.z,
                         normRight.x, normRight.y, normRight.z,
                         normRight.x, normRight.y, normRight.z,
                         normLeft.x, normLeft.y, normLeft.z);
        _rawNormals.push(normLeft.x, normLeft.y, normLeft.z,
                         normRight.x, normRight.y, normRight.z,
                         normRight.x, normRight.y, normRight.z,
                         normLeft.x, normLeft.y, normLeft.z);
        _rawNormals.push(normRight.x, normRight.y, normRight.z,
                         normRight.x, normRight.y, normRight.z,
                         normRight.x, normRight.y, normRight.z,
                         normLeft.x, normLeft.y, normLeft.z,
                         normLeft.x, normLeft.y, normLeft.z,
                         normLeft.x, normLeft.y, normLeft.z);

        // Set tangents.
//        var rotate:Matrix3D = new Matrix3D();
//        var normTop:Vector3D = normRight.crossProduct(normFront);
//        normTop.normalize();
//        rotate.appendRotation(45, normTop);
//        normFront = rotate.transformVector(normFront);
//        normBack = rotate.transformVector(normBack);
//        normRight = rotate.transformVector(normRight);
//        normLeft = rotate.transformVector(normLeft);
        _rawTangents.push(normRight.x, normRight.y, normRight.z,
                          normRight.x, normRight.y, normRight.z,
                          normLeft.x, normLeft.y, normLeft.z,
                          normLeft.x, normLeft.y, normLeft.z);
        _rawTangents.push(normRight.x, normRight.y, normRight.z,
                          normRight.x, normRight.y, normRight.z,
                          normLeft.x, normLeft.y, normLeft.z,
                          normLeft.x, normLeft.y, normLeft.z);
        _rawTangents.push(normBack.x, normBack.y, normBack.z,
                          normFront.x, normFront.y, normFront.z,
                          normFront.x, normFront.y, normFront.z,
                          normBack.x, normBack.y, normBack.z);
        _rawTangents.push(normBack.x, normBack.y, normBack.z,
                          normFront.x, normFront.y, normFront.z,
                          normFront.x, normFront.y, normFront.z,
                          normBack.x, normBack.y, normBack.z);
        _rawTangents.push(normBack.x, normBack.y, normBack.z,
                          normBack.x, normBack.y, normBack.z,
                          normBack.x, normBack.y, normBack.z,
                          normFront.x, normFront.y, normFront.z,
                          normFront.x, normFront.y, normFront.z,
                          normFront.x, normFront.y, normFront.z);
    }

    override protected function buildUVs(target:SubGeometry):void
    {
        target.updateUVData(_rawUvs);
    }

    private function rand(min:Number, max:Number):Number
    {
        return (max - min)*Math.random() + min;
    }

    public function get leafPositions():Vector.<Number>
    {
        return _leafPositions;
    }
}
}
