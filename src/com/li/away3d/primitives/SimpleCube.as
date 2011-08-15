package com.li.away3d.primitives
{
import away3d.core.base.SubGeometry;
import away3d.materials.MaterialBase;
import away3d.primitives.PrimitiveBase;

/*
    A simple cube primitive with no subdivisions.
    TODO: set tangents, docs, setters and getters, uv build, optimization.
 */
public class SimpleCube extends PrimitiveBase
{
    private var _width:Number;
    private var _height:Number;
    private var _depth:Number;

    public function SimpleCube(material:MaterialBase, width:Number, height:Number, depth:Number)
    {
        super(material);

        _width = width;
        _height = height
        _depth = depth;
    }

    override protected function buildGeometry(target:SubGeometry):void
    {
        var halfW:Number = _width/2;
        var halfH:Number = _height/2;
        var halfD:Number = _depth/2;

        var rawVertices:Vector.<Number> = new Vector.<Number>();
        for(var i:uint; i < 3; i++)
        {
            rawVertices.push(-halfW, halfH, -halfD); // tlf
            rawVertices.push(-halfW, -halfH, -halfD); // blf
            rawVertices.push(halfW, -halfH, -halfD); // brf
            rawVertices.push(halfW, halfH, -halfD); // trf
            rawVertices.push(-halfW, halfH, halfD); // tlb
            rawVertices.push(-halfW, -halfH, halfD); // blb
            rawVertices.push(halfW, -halfH, halfD); // brb
            rawVertices.push(halfW, halfH, halfD); // trb
        }

        var rawIndices:Vector.<uint> =  new Vector.<uint>();
        var off0:uint = 8;
        var off1:uint = 16;
        rawIndices.push(2, 1, 0, 3, 2, 0); // Front.
        rawIndices.push(5, 6, 7, 4, 5, 7); // Back.
        rawIndices.push(off0 + 6, off0 + 2, off0 + 3, off0 + 7, off0 + 6, off0 + 3); // Right.
        rawIndices.push(off0 + 1, off0 + 5, off0 + 4, off0 + 0, off0 + 1, off0 + 4); // Left.
        rawIndices.push(off1 + 3, off1 + 0, off1 + 4, off1 + 7, off1 + 3, off1 + 4); // Top.
        rawIndices.push(off1 + 6, off1 + 5, off1 + 1, off1 + 2, off1 + 6, off1 + 1); // Bottom.

        var rawNormals:Vector.<Number> = new Vector.<Number>();
        rawNormals.push(0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1);
        rawNormals.push(0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1);
        rawNormals.push(-1, 0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0);
        rawNormals.push(-1, 0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0);
        rawNormals.push(0, 1, 0, 0, -1, 0, 0, -1, 0, 0, 1, 0);
        rawNormals.push(0, 1, 0, 0, -1, 0, 0, -1, 0, 0, 1, 0);

        target.updateVertexData(rawVertices);
        target.updateIndexData(rawIndices);
        target.updateVertexNormalData(rawNormals);
    }

    override protected function buildUVs(target:SubGeometry):void
    {
        // Pending.
    }
}
}
