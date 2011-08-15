package com.li.away3d.primitives
{
import away3d.core.base.SubGeometry;
import away3d.materials.MaterialBase;
import away3d.primitives.PrimitiveBase;

/*
    A simple plane primitive with no subdivisions.
    TODO: docs, setters and getters, uv build, optimization.
 */
public class SimplePlane extends PrimitiveBase
{
    private var _width:Number;
    private var _height:Number;

    public function SimplePlane(material:MaterialBase = null, width:Number = 100, height:Number = 100)
    {
        super(material);

        _width = width;
        _height = height;
    }

    override protected function buildGeometry(target:SubGeometry):void
    {
        var halfW:Number = _width/2;
        var halfH:Number = _height/2;

        var rawVertices:Vector.<Number> = new Vector.<Number>();
        rawVertices.push(-halfW, -halfH, 0);
        rawVertices.push(halfW, -halfH, 0);
        rawVertices.push(-halfW, halfH, 0);
        rawVertices.push(halfW, halfH, 0);

        var rawIndices:Vector.<uint> = Vector.<uint>([0, 2, 1, 2, 3, 1]);

        var rawNormals:Vector.<Number> = Vector.<Number>([0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1]);
        var rawTangents:Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

        target.updateVertexData(rawVertices);
        target.updateIndexData(rawIndices);
        target.updateVertexNormalData(rawNormals);
        target.updateVertexTangentData(rawTangents);
    }

    override protected function buildUVs(target:SubGeometry):void
    {
        // Pending.
    }
}
}
