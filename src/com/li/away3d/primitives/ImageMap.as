package com.li.away3d.primitives
{
import away3d.core.base.SubGeometry;
import away3d.entities.Mesh;
import away3d.materials.MaterialBase;
import away3d.primitives.PrimitiveBase;

import flash.display.BitmapData;

/*
    The idea of the class is to be able to reduce models to images and then
    feed the image to this primitive, which would then reconstruct itself from the image
    at chosen levels of resolution < original res. Such a thing could serve for LOD.

    PROBLEM: The image would only store vertices, but there would be no way of telling
    how the vertices are arranged in the indices to produce triangles.
 */
public class ImageMap extends PrimitiveBase
{
    public function ImageMap(material:MaterialBase, image:BitmapData)
    {
        super(material);
    }

    protected override function buildGeometry(target:SubGeometry):void
    {

    }

    // Incoming mesh bb should be contained in 256x256x256.
    public static function meshToImage(mesh:Mesh):BitmapData
    {
        var vertices:Vector.<Number> = mesh.geometry.subGeometries[0].vertexData;

        var w:Number = vertices.length/3;

        var bmd:BitmapData = new BitmapData(w, 1, false, 0xFFFFFF);

        var i:uint, index:uint;
        var loop:uint = w;
        var r:uint, g:uint, b:uint;
        bmd.lock();
        for(i = 0; i < loop; ++i)
        {
            index = i*3;
            r = vertices[index] + 127;
            g = vertices[index + 1] + 127;
            b = vertices[index + 2] + 127;
            trace(r, g, b);
            bmd.setPixel(i, 0, (r << 16) | (g << 8) | b)
        }
        bmd.unlock();

        return bmd;
    }

    override protected function buildUVs(target:SubGeometry):void
    {
        // Nothing...
    }
}
}
