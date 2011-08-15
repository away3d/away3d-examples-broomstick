package com.li.away3d.primitives
{
import away3d.core.base.SubGeometry;
import away3d.materials.MaterialBase;
import away3d.primitives.PrimitiveBase;

import flash.geom.Vector3D;

/*
    A simple triangle primitive.
    TODO: Add doc, setters and getters, check uv build, optimize.
 */
public class Triangle extends PrimitiveBase
{
    private var _v0:Vector3D;
    private var _v1:Vector3D;
    private var _v2:Vector3D;
    private var _uv0:Vector3D;
    private var _uv1:Vector3D;
    private var _uv2:Vector3D;

    // Define vertices in a clockwise manner.
    public function Triangle(material:MaterialBase, v0:Vector3D, v1:Vector3D, v2:Vector3D,
                                                    uv0:Vector3D = null, uv1:Vector3D = null, uv2:Vector3D = null)
    {
        super(material);

        _v0 = v0;
        _v1 = v1;
        _v2 = v2;
        _uv0 = uv0;
        _uv1 = uv1;
        _uv2 = uv2;
    }

    override protected function buildGeometry(target:SubGeometry):void
    {
        var rawVertices:Vector.<Number> = Vector.<Number>([_v0.x, _v0.y, _v0.z, _v1.x, _v1.y, _v1.z, _v2.x, _v2.y, _v2.z]);
        var rawIndices:Vector.<uint> = Vector.<uint>([0, 1, 2]);

        var d0:Vector3D = _v1.subtract(_v0);
        var d1:Vector3D = _v2.subtract(_v0);
        var rawTangents:Vector.<Number> = Vector.<Number>([0, 0, 0]);

        var normal:Vector3D = d0.crossProduct(d1);
        normal.normalize();
        var rawNormals:Vector.<Number> = Vector.<Number>([normal.x, normal.y, normal.z, normal.x, normal.y, normal.z, normal.x, normal.y, normal.z]);

        target.updateVertexData(rawVertices);
        target.updateIndexData(rawIndices);
        target.updateVertexNormalData(rawNormals);
        target.updateVertexTangentData(rawTangents);
    }

    override protected function buildUVs(target:SubGeometry):void
    {
        if(_uv0 && _uv1 && _uv2)
            var rawUvData:Vector.<Number> = Vector.<Number>([_uv0.x, _uv0.y, _uv1.x, _uv1.y, _uv2.x, _uv2.y]);
    }
}
}
