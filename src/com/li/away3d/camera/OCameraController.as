/**
 * Created by IntelliJ IDEA.
 * User: li
 * Date: 1/29/11
 * Time: 1:41 AM
 * To change this template use File | Settings | File Templates.
 */
package com.li.away3d.camera
{
import away3d.cameras.Camera3D;

import flash.geom.Vector3D;

/*
    OrbitCameraController.
    Controls camera motion in spherical coordinates, orbiting a given point.
 */
public class OCameraController
{
    private const PI:Number = Math.PI;
    private const TWOPI:Number = 2*PI;
    private const HALFPI:Number = PI/2;

    private var _camera:Camera3D;
    private var _center:Vector3D;

    private var _cartesianCoordinates:Vector3D;
    private var _sphericalCoorinates:Vector3D; // Azimuth, elevation, radius.

    private var _minAzimuth:Number = 0;
    private var _maxAzimuth:Number = TWOPI; // Azimuth range should stay within [0, 2Pi].
    private var _minElevation:Number = -HALFPI;
    private var _maxElevation:Number = HALFPI; // Elevation range should stay within [-Pi/2, Pi/2].
    private var _minRadius:Number = 0;
    private var _maxRadius:Number = 10000; // Negative values not recommended.

    public var useAzimuthLimit:Boolean = false;

    public function OCameraController(camera:Camera3D)
    {
        _camera = camera;
        _center = new Vector3D();
        _cartesianCoordinates = _camera.position;
        _sphericalCoorinates = cartesianToSpherical(_cartesianCoordinates);
        update();
    }

    public function get sphericalCoordinates():Vector3D
    {
        return _sphericalCoorinates;
    }

    // --------------------
    // Limits.
    // --------------------

    // Azimuth limits.
    public function set minAzimuth(value:Number):void
    {
        _minAzimuth = value;
    }
    public function get minAzimuth():Number
    {
        return _minAzimuth;
    }
    public function set maxAzimuth(value:Number):void
    {
        _maxAzimuth = value;
    }
    public function get maxAzimuth():Number
    {
        return _maxAzimuth;
    }

    // Elevation limits.
    public function set minElevation(value:Number):void
    {
        _minElevation = value;
    }
    public function get minElevation():Number
    {
        return _minElevation;
    }
    public function set maxElevation(value:Number):void
    {
        _maxElevation = value;
    }
    public function get maxElevation():Number
    {
        return _maxElevation;
    }

    // Radius limits.
    public function set minRadius(value:Number):void
    {
        _minRadius = value;
    }
    public function get minRadius():Number
    {
        return _minRadius;
    }
    public function set maxRadius(value:Number):void
    {
        _maxRadius = value;
    }
    public function get maxRadius():Number
    {
        return _maxRadius;
    }

    // --------------------
    // Position change.
    // --------------------

    // Azimuth.
    public function set azimuth(value:Number):void
    {
        if(useAzimuthLimit)
            _sphericalCoorinates.x = containValue(value, _minAzimuth, _maxAzimuth);
        else
            _sphericalCoorinates.x = value;

        update();
    }
    public function get azimuth():Number
    {
        return _sphericalCoorinates.x;
    }

    // Elevation.
    public function set elevation(value:Number):void
    {
        _sphericalCoorinates.y = containValue(value, _minElevation, _maxElevation);
        update();
    }
    public function get elevation():Number
    {
        return _sphericalCoorinates.y;
    }

    // Radius.
    public function set radius(value:Number):void
    {
        _sphericalCoorinates.z = containValue(value, _minRadius, _maxRadius);
        update();
    }
    public function get radius():Number
    {
        return _sphericalCoorinates.z;
    }

    // --------------------
    // Target (look at) position change.
    // --------------------

    // X.
    public function set centerX(value:Number):void
    {
        _center.x = value;
        update();
    }
    public function get centerX():Number
    {
        return _center.x;
    }

    // Y.
    public function set centerY(value:Number):void
    {
        _center.y = value;
        update();
    }
    public function get centerY():Number
    {
        return _center.y;
    }

    // Z.
    public function set centerZ(value:Number):void
    {
        _center.z = value;
        update();
    }
    public function get centerZ():Number
    {
        return _center.z;
    }

    // --------------------
    // Private.
    // --------------------

    // Contains a value between a min and a max.
    private function containValue(value:Number, min:Number, max:Number):Number
    {
        if(value < min)
            return min;
        else if(value > max)
            return max;
        else
            return value;
    }

    // Spherical -> Cartesian and viceversa convertions.
    private function sphericalToCartesian(sphericalCoords:Vector3D):Vector3D
    {
        var cartesianCoords:Vector3D = new Vector3D();
        var r:Number = sphericalCoords.z;
        cartesianCoords.y = _center.y + r*Math.sin(-sphericalCoords.y);
        var cosE:Number = Math.cos(-sphericalCoords.y);
        cartesianCoords.x = _center.x + r*cosE*Math.sin(sphericalCoords.x);
        cartesianCoords.z = _center.z + r*cosE*Math.cos(sphericalCoords.x);
        return cartesianCoords;
    }
    private function cartesianToSpherical(cartesianCoords:Vector3D):Vector3D
    {
        var cartesianFromCenter:Vector3D = new Vector3D();
        cartesianFromCenter.x = cartesianCoords.x - _center.x;
        cartesianFromCenter.y = cartesianCoords.y - _center.y;
        cartesianFromCenter.z = cartesianCoords.z - _center.z;
        var sphericalCoords:Vector3D = new Vector3D();
        sphericalCoords.z = cartesianFromCenter.length;
        sphericalCoords.x = Math.atan2(cartesianFromCenter.x, cartesianFromCenter.z);
        sphericalCoords.y = -Math.asin((cartesianFromCenter.y)/sphericalCoords.z);
        return sphericalCoords;
    }

    // Fixes camera cartesian position to current spherical coordinates.
    private function update():void
    {
        var cartesianCoordinates:Vector3D = sphericalToCartesian(_sphericalCoorinates);
        _camera.x = cartesianCoordinates.x;
        _camera.y = cartesianCoordinates.y;
        _camera.z = cartesianCoordinates.z;
        _camera.lookAt(_center);
    }
}
}
