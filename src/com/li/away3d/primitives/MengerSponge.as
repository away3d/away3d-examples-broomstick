package com.li.away3d.primitives
{
import away3d.arcane;
import away3d.core.base.SubGeometry;
import away3d.materials.MaterialBase;
import away3d.primitives.PrimitiveBase;

use namespace arcane;

/**
 * A Menger Sponge primitive mesh.
 */
public class MengerSponge extends PrimitiveBase
{
    private var _size:Number;
    private var _level:uint;
    private var _off:uint;

    private var _rawVertices:Vector.<Number>;
    private var _rawNormals:Vector.<Number>;
    private var _rawIndices:Vector.<uint>;

    private var _numCubes:uint;
    private var _batchCubes:uint;
    private var _maxCubes:uint;
    private var _target:SubGeometry;

    /**
     * Creates a new Menger Sponge object.
     * @param material The material with which to render the object.
     * @param size The size of the cube along its X, Y and Z axis.
     * @param level The fractal level of the Menger Sponge.
     */
    public function MengerSponge(material:MaterialBase = null, size:Number = 100, level:uint = 1)
    {
        super(material);

        _size = size;
        _level = level;
    }

    /**
     * @inheritDoc
     */
    protected override function buildGeometry(target:SubGeometry):void
    {
        if(_maxCubes != 0)
            return;

        _target = target;

        // Init raw buffers.
        _rawVertices = new Vector.<Number>();
        _rawNormals = new Vector.<Number>();
        _rawIndices = new Vector.<uint>();

        // Recursive method.
        _maxCubes = Math.pow(20, _level);
        step(_level, 0, 0, 0, _size);
    }

    private function step(level:uint, x:Number, y:Number, z:Number, size:Number):void
    {
        if(level == 0)
            buildCube(x, y, z, size);
        else
        {
            var s3:Number = size/3;
            var nLevel:uint = level - 1;
            step(nLevel, x - s3, y + s3, z + s3, s3);
            step(nLevel, x, y + s3, z + s3, s3);
            step(nLevel, x + s3, y + s3, z + s3, s3);
            step(nLevel, x - s3, y, z + s3, s3);
            step(nLevel, x + s3, y, z + s3, s3);
            step(nLevel, x - s3, y - s3, z + s3, s3);
            step(nLevel, x, y - s3, z + s3, s3);
            step(nLevel, x + s3, y - s3, z + s3, s3);
            step(nLevel, x - s3, y + s3, z, s3);
            step(nLevel, x + s3, y + s3, z, s3);
            step(nLevel, x - s3, y - s3, z, s3);
            step(nLevel, x + s3, y - s3, z, s3);
            step(nLevel, x - s3, y + s3, z - s3, s3);
            step(nLevel, x, y + s3, z - s3, s3);
            step(nLevel, x + s3, y + s3, z - s3, s3);
            step(nLevel, x - s3, y, z - s3, s3);
            step(nLevel, x + s3, y, z - s3, s3);
            step(nLevel, x - s3, y - s3, z - s3, s3);
            step(nLevel, x, y - s3, z - s3, s3);
            step(nLevel, x + s3, y - s3, z - s3, s3);
        }
    }

    private function reportGeometry():void
    {
        // Report buffers.
        if(subMeshes.length > 0)
        {
            subMeshes[subMeshes.length - 1].subGeometry.updateVertexData(_rawVertices);
            subMeshes[subMeshes.length - 1].subGeometry.updateVertexNormalData(_rawNormals);
            subMeshes[subMeshes.length - 1].subGeometry.updateIndexData(_rawIndices);
        }
        else
        {
            _target.updateVertexData(_rawVertices);
            _target.updateVertexNormalData(_rawNormals);
            _target.updateIndexData(_rawIndices);
        }

        // Continue if there are still cubes to create.
        if(_numCubes == _maxCubes)
            return;

        // Reset offset and buffers.
        _off = 0;
        _batchCubes = 0;
        _rawVertices = new Vector.<Number>();
        _rawNormals = new Vector.<Number>();
        _rawIndices = new Vector.<uint>();

        // Create next target.
        addSubMesh(new SubGeometry());
    }

    private function buildCube(x:Number, y:Number, z:Number, size:Number):void
    {
        var halfS:Number = size/2;

        for(var i:uint; i < 3; i++)
        {
            _rawVertices.push(x + -halfS, y + halfS, z + -halfS); // tlf
            _rawVertices.push(x +-halfS, y + -halfS, z + -halfS); // blf
            _rawVertices.push(x +halfS, y + -halfS, z + -halfS); // brf
            _rawVertices.push(x +halfS, y + halfS, z + -halfS); // trf
            _rawVertices.push(x +-halfS, y + halfS, z + halfS); // tlb
            _rawVertices.push(x +-halfS, y + -halfS, z + halfS); // blb
            _rawVertices.push(x +halfS, y + -halfS, z + halfS); // brb
            _rawVertices.push(x +halfS, y + halfS, z + halfS); // trb
        }

        var off0:uint = _off + 8;
        var off1:uint = _off + 16;
        _rawIndices.push(_off + 2, _off + 1, _off + 0, _off + 3, _off + 2, _off + 0); // Front.
        _rawIndices.push(_off + 5, _off + 6, _off + 7, _off + 4, _off + 5, _off + 7); // Back.
        _rawIndices.push(off0 + 6, off0 + 2, off0 + 3, off0 + 7, off0 + 6, off0 + 3); // Right.
        _rawIndices.push(off0 + 1, off0 + 5, off0 + 4, off0 + 0, off0 + 1, off0 + 4); // Left.
        _rawIndices.push(off1 + 3, off1 + 0, off1 + 4, off1 + 7, off1 + 3, off1 + 4); // Top.
        _rawIndices.push(off1 + 6, off1 + 5, off1 + 1, off1 + 2, off1 + 6, off1 + 1); // Bottom.
        _off += 24;

        _rawNormals.push(0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1);
        _rawNormals.push(0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1);
        _rawNormals.push(-1, 0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0);
        _rawNormals.push(-1, 0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0);
        _rawNormals.push(0, 1, 0, 0, -1, 0, 0, -1, 0, 0, 1, 0);
        _rawNormals.push(0, 1, 0, 0, -1, 0, 0, -1, 0, 0, 1, 0);

        _numCubes++;
        _batchCubes++;

        // Finished.
        if(_numCubes == _maxCubes) // Finished.
            reportGeometry();
        else if(_rawVertices.length/3 + 24 > 65535) // Reached limit.
            reportGeometry();
    }

    override protected function buildUVs(target:SubGeometry):void
    {
        // Nothing...
    }

    /**
     * The size of the cube along its X-axis.
     */
    public function get size():Number
    {
        return _size;
    }
    public function set size(value:Number):void
    {
        _size = value;
        invalidateGeometry();
    }
}
}